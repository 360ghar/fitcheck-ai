#!/usr/bin/env python3
"""
Girlfriend's Day promo email campaign.

Emails every FitCheck user a shareable promo code (e.g. GFDAY2026): they pass
it to their girlfriend / girlies, who register and redeem 1 month of Pro free.

No DB writes: redemption happens through the standard promo-code machinery
(redeem_promo_atomic), so this script only reads users and sends mail.

Transport split (Resend has a 100/day cap): the first RESEND_DAILY_CAP
recipients go through Resend, everyone after that through Gmail SMTP. The
audit file records which transport each user got, so re-running after a
failure resumes exactly where it stopped and never double-sends.

Usage:
    cd backend
    export SUPABASE_URL=... SUPABASE_SECRET_KEY=...   # service-role key
    export RESEND_API_KEY=re_... FROM_EMAIL='FitCheck AI <team@fitcheckaiapp.com>'
    export SMTP_USERNAME=... SMTP_PASSWORD=...        # Gmail app password
    export SMTP_FROM='FitCheck AI <you@gmail.com>'

    # 1) preview (sends nothing, no env needed):
    python scripts/girlfriend_day_campaign.py --code GFDAY2026 --preview

    # 2) test send to one inbox (no audit record; SMTP by default):
    python scripts/girlfriend_day_campaign.py --code GFDAY2026 \
        --to saksham1991999@gmail.com --name Saksham

    # 3) full send to all users (first 100 via Resend, rest via Gmail SMTP):
    python scripts/girlfriend_day_campaign.py --code GFDAY2026

Optional env:
    RESEND_DAILY_CAP=100        # recipients sent via Resend before SMTP
    EMAIL_TRANSPORT=split       # 'split' (default) | 'resend' | 'smtp'
    EMAIL_RATE_LIMIT_MS=250     # throttle between sends
    PAGE_SIZE=500
    AUDIT_FILE=backend/logs/girlfriend_day_emails.jsonl   # default: <backend>/logs/...

Notes:
    - The promo code must already exist (scripts/create_promo_code.py); the
      script fails fast if it is missing from the hosted DB.
    - Gmail SMTP requires an App Password and forces From to match the
      authenticated account. Gmail caps ~500 sends/day per account; refused
      addresses are not audited, so the run can resume next day.
    - Recipients on bogus/reserved domains (example.com, ...) are skipped to
      avoid guaranteed bounces.
    - A lockfile (<audit>.lock) prevents two concurrent runs from double-
      sending; re-running after a crash/interrupt resumes from the audit.
"""
from __future__ import annotations

import json
import os
import smtplib
import ssl
import sys
import time
from datetime import datetime, timezone
from email.message import EmailMessage
from email.utils import parseaddr
from pathlib import Path
from typing import Any

import httpx
from supabase import create_client

RESEND_URL = "https://api.resend.com/emails"
DEFAULT_CODE = "GFDAY2026"

# Default audit path resolves relative to the repo backend root (scripts/..),
# so the script works from any cwd: <backend>/logs/girlfriend_day_emails.jsonl.
DEFAULT_AUDIT_PATH = Path(__file__).resolve().parents[1] / "logs" / "girlfriend_day_emails.jsonl"

# Domains we never send to - reserved/fake TLDs that receivers reject or
# that would hard-bounce. Kept explicit; not a generic regex (same list as
# grant_free_pro_month.py).
BOGUS_EMAIL_DOMAINS = {
    "example.com", "example.org", "example.net",
    "test.com", "test.org",
    "localhost", "localhost.com",
    "fake.com", "invalid.com",
}

SUBJECT = "Happy Girlfriend's Day \u2764\ufe0f \u2014 give her 1 month of Pro, on us"


def _is_bogus_email(email: str) -> bool:
    _, addr = parseaddr(email)
    if "@" not in addr:
        return True
    domain = addr.rsplit("@", 1)[1].lower().strip()
    return domain in BOGUS_EMAIL_DOMAINS


# --------------------------------------------------------------------------- #
# helpers
# --------------------------------------------------------------------------- #
def _env(name: str, default: str | None = None, *, required: bool = False) -> str:
    value = os.environ.get(name, default)
    if required and not value:
        print(f"ERROR: missing required env var {name}", file=sys.stderr)
        sys.exit(1)
    return value or ""


def _env_int(name: str, default: int) -> int:
    raw = os.environ.get(name, str(default)).strip()
    try:
        return int(raw)
    except ValueError:
        print(f"WARNING: {name}={raw!r} is not an int, using {default}", file=sys.stderr)
        return default


def _page_users(db: Any, page_size: int):
    offset = 0
    while True:
        res = (
            db.table("users")
            .select("id,email,full_name")
            .order("id")
            .range(offset, offset + page_size - 1)
            .execute()
        )
        rows = res.data or []
        if not rows:
            return
        for row in rows:
            yield row
        if len(rows) < page_size:
            return
        offset += page_size


def _load_sent(path: Path) -> set[str]:
    """User ids already emailed (any transport), from the audit file."""
    sent: set[str] = set()
    if not path.exists():
        return sent
    with path.open("r", encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                rec = json.loads(line)
            except json.JSONDecodeError:
                continue
            if rec.get("action") == "sent" and rec.get("user_id"):
                sent.add(rec["user_id"])
    return sent


def _append_audit(path: Path, record: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as fh:
        fh.write(json.dumps(record, separators=(",", ":")) + "\n")


def _promo_code_exists(db: Any, code: str) -> bool:
    """Fail-fast check that the campaign code actually exists (read-only)."""
    try:
        res = (
            db.table("promo_codes")
            .select("code,active")
            .ilike("code", code.strip().lower())
            .maybe_single()
            .execute()
        )
        return bool(res and res.data and res.data.get("active", True))
    except Exception as e:
        print(f"WARNING: could not verify promo code {code}: {e}", file=sys.stderr)
        return True  # never block the campaign on a read-only check failure


def _acquire_lock(audit_path: Path) -> Path:
    """Take an exclusive lock next to the audit file (atomic O_EXCL create).

    Two concurrent campaign runs would both read an empty audit and double-
    send, so a second run refuses to start. A lock whose owning PID is gone
    (crash / kill -9) is reclaimed automatically.
    """
    lock_path = Path(str(audit_path) + ".lock")
    try:
        fd = os.open(lock_path, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
    except FileExistsError:
        try:
            pid = int(lock_path.read_text().strip().split()[0])
            os.kill(pid, 0)  # raises ProcessLookupError if the owner is gone
        except (ValueError, ProcessLookupError, FileNotFoundError):
            lock_path.unlink(missing_ok=True)
            fd = os.open(lock_path, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
        else:
            print(
                f"ERROR: another campaign run is in progress (pid {pid}, lock {lock_path}). "
                "Refusing to start to avoid double-sending.",
                file=sys.stderr,
            )
            sys.exit(2)
    os.write(fd, f"{os.getpid()} {datetime.now(timezone.utc).isoformat()}\n".encode())
    os.close(fd)
    return lock_path

# --------------------------------------------------------------------------- #
# email
# --------------------------------------------------------------------------- #
def _render_email(first_name: str | None, code: str, share_url: str) -> tuple[str, str]:
    """HTML + plain-text Girlfriend's Day email. Same code for every user."""
    first = (first_name or "").strip().split(" ", 1)[0]
    greeting = f"Hi {first}," if first else "Hi there,"
    code_upper = code.strip().upper()

    html = f"""<!DOCTYPE html>
<html>
  <body style="margin:0;padding:0;background:#f6f7f9;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;color:#111827;">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="padding:32px 0;">
      <tr><td align="center">
        <table role="presentation" width="560" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 1px 3px rgba(0,0,0,0.08);">
          <tr><td style="padding:32px 40px 8px 40px;">
            <h1 style="margin:0 0 8px 0;font-size:22px;font-weight:600;">Happy Girlfriend&#39;s Day &#128149;</h1>
          </td></tr>
          <tr><td style="padding:0 40px 24px 40px;">
            <p style="margin:0 0 16px 0;font-size:15px;line-height:1.6;">{greeting}</p>
            <p style="margin:0 0 16px 0;font-size:15px;line-height:1.6;">
              Today is all about celebrating her &#8212; and we&#39;re helping you do it
              with a little style. Here&#39;s a code, and it&#39;s <strong>made for sharing</strong>:
            </p>
            <p style="margin:0 0 16px 0;text-align:center;">
              <span style="display:inline-block;background:#f3f4f6;border:2px dashed #d1d5db;border-radius:8px;padding:10px 24px;font-family:Menlo,Consolas,monospace;font-size:20px;font-weight:700;letter-spacing:1px;">{code_upper}</span>
            </p>
            <p style="margin:0 0 16px 0;font-size:15px;line-height:1.6;">
              Send it to your girlfriend &#8212; or your <em>girlies</em>, no gatekeeping
              here &#8212; and they get <strong>1 month of FitCheck Pro free</strong>:
            </p>
            <p style="margin:0 0 16px 0;text-align:center;">
              <a href="{share_url}" style="display:inline-block;background:#4f46e5;color:#ffffff;text-decoration:none;border-radius:8px;padding:12px 28px;font-size:15px;font-weight:600;">Claim 1 month free</a>
            </p>
            <p style="margin:0 0 16px 0;font-size:15px;line-height:1.6;">
              Pro unlocks AI outfit visualizations, virtual try-on, wardrobe
              analytics and priority support &#8212; everything that makes getting
              ready together more fun (and faster).
            </p>
            <p style="margin:0 0 16px 0;font-size:15px;line-height:1.6;">
              They just sign up, enter the code, and Pro is theirs for a month.
              No card required.
            </p>
            <p style="margin:0 0 8px 0;font-size:15px;line-height:1.6;">Share it far. Happy Girlfriend&#39;s Day! &#128149;</p>
            <p style="margin:0;font-size:14px;color:#6b7280;">&#8212; The FitCheck AI team</p>
          </td></tr>
          <tr><td style="padding:16px 40px 32px 40px;border-top:1px solid #f0f0f0;">
            <p style="margin:0;font-size:12px;line-height:1.5;color:#9ca3af;">
              The FitCheck AI team &middot; <a href="https://www.fitcheckaiapp.com" style="color:#9ca3af;text-decoration:underline;">fitcheckaiapp.com</a>
            </p>
          </td></tr>
        </table>
      </td></tr>
    </table>
  </body>
</html>"""

    text = (
        f"{greeting}\n\n"
        "Happy Girlfriend's Day! \u2764\ufe0f Today is all about celebrating her \u2014 "
        "and we're helping you do it with a little style. Here's a code, and it's made for sharing:\n\n"
        f"    {code_upper}\n\n"
        "Send it to your girlfriend \u2014 or your girlies, no gatekeeping here \u2014 "
        f"and they get 1 month of FitCheck Pro free:\n\n    {share_url}\n\n"
        "Pro unlocks AI outfit visualizations, virtual try-on, wardrobe analytics "
        "and priority support \u2014 everything that makes getting ready together "
        "more fun (and faster).\n\n"
        "They just sign up, enter the code, and Pro is theirs for a month. "
        "No card required.\n\n"
        "Share it far. Happy Girlfriend's Day! \u2764\ufe0f\n\n"
        "-- The FitCheck AI team\nhttps://www.fitcheckaiapp.com\n"
    )
    return html, text


def _send_email_resend(
    client: httpx.Client,
    api_key: str,
    from_email: str,
    to_email: str,
    subject: str,
    html: str,
    text: str,
) -> tuple[bool, Any]:
    """Send one email via Resend. Returns (ok, detail)."""
    try:
        resp = client.post(
            RESEND_URL,
            headers={
                "Authorization": f"Bearer {api_key}",
                "Content-Type": "application/json",
            },
            json={"from": from_email, "to": [to_email], "subject": subject, "html": html, "text": text},
            timeout=30.0,
        )
    except httpx.HTTPError as e:
        return False, f"network error: {e}"
    if resp.status_code >= 400:
        try:
            body = resp.json()
        except Exception:
            body = resp.text
        return False, f"HTTP {resp.status_code}: {body}"
    return True, resp.json()


def _send_email_smtp(
    host: str,
    port: int,
    username: str,
    password: str,
    from_addr: str,
    to_addr: str,
    reply_to: str,
    subject: str,
    html: str,
    text: str,
) -> tuple[bool, Any]:
    """Send one MIME message via SMTP STARTTLS. Returns (ok, detail)."""
    msg = EmailMessage()
    msg["From"] = from_addr
    msg["To"] = to_addr
    msg["Subject"] = subject
    if reply_to:
        msg["Reply-To"] = reply_to
    msg.set_content(text)
    msg.add_alternative(html, subtype="html")

    try:
        # Context that doesn't verify the cert hostname to be forgiving of
        # shared SMTP relays; TLS still encrypts the connection.
        ctx = ssl.create_default_context()
        with smtplib.SMTP(host, port, timeout=30) as server:
            server.ehlo()
            server.starttls(context=ctx)
            server.ehlo()
            server.login(username, password)
            refused = server.send_message(msg)
            if refused:
                return False, f"recipient refused: {refused}"
        return True, "sent"
    except smtplib.SMTPAuthenticationError as e:
        return False, f"SMTP auth error: {e.smtp_code} {e.smtp_error.decode('utf-8', 'replace') if isinstance(e.smtp_error, bytes) else e.smtp_error}"
    except smtplib.SMTPException as e:
        return False, f"SMTP error: {e}"
    except OSError as e:
        return False, f"network error: {e}"


# --------------------------------------------------------------------------- #
# main
# --------------------------------------------------------------------------- #
def _get_transport_plan(recipients: list[dict[str, Any]], resend_cap: int, mode: str) -> dict[str, Any]:
    """Decide how many recipients go via Resend vs SMTP.

    mode: 'split' -> first `resend_cap` via Resend, rest via SMTP
          'resend' -> all via Resend
          'smtp'   -> all via SMTP
    """
    if mode == "resend":
        return {"resend": list(recipients), "smtp": []}
    if mode == "smtp":
        return {"resend": [], "smtp": list(recipients)}
    n_resend = min(resend_cap, len(recipients))
    return {"resend": recipients[:n_resend], "smtp": recipients[n_resend:]}


def main() -> int:
    import argparse

    parser = argparse.ArgumentParser(description="Girlfriend's Day promo email campaign")
    parser.add_argument("--code", default=DEFAULT_CODE, help="Promo code to embed (default GFDAY2026)")
    parser.add_argument("--preview", action="store_true", help="Print the email and exit (no env needed)")
    parser.add_argument("--to", default=None, help="Send a test email to this single address")
    parser.add_argument("--name", default=None, help="First name used for the test email greeting")
    parser.add_argument("--force", action="store_true", help="Skip the fail-fast promo-code existence check")
    args = parser.parse_args()

    share_url = f"{_env('FRONTEND_URL', 'https://fitcheckaiapp.com').rstrip('/')}/auth/register?promo={args.code.strip()}"
    sample_html, sample_text = _render_email(args.name or "Alex", args.code, share_url)

    if args.preview:
        print("---- subject ----")
        print(SUBJECT)
        print("---- text ----")
        print(sample_text)
        print("---- html (first 600 chars) ----")
        print(sample_html[:600])
        return 0

    # Live/test run: validate env up front so we never half-send.
    supabase_url = _env("SUPABASE_URL", required=True).rstrip("/")
    supabase_key = _env("SUPABASE_SECRET_KEY", required=True)
    resend_cap = _env_int("RESEND_DAILY_CAP", 100)
    rate_ms = _env_int("EMAIL_RATE_LIMIT_MS", 250)
    page_size = _env_int("PAGE_SIZE", 500)
    audit_path = Path(_env("AUDIT_FILE", str(DEFAULT_AUDIT_PATH)))
    transport_mode = _env("EMAIL_TRANSPORT", "split").strip().lower()
    if transport_mode not in ("split", "resend", "smtp"):
        print(f"ERROR: EMAIL_TRANSPORT={transport_mode!r} must be 'split', 'resend' or 'smtp'", file=sys.stderr)
        return 2

    smtp_host = _env("SMTP_HOST", "smtp.gmail.com")
    smtp_port = _env_int("SMTP_PORT", 587)
    smtp_username = _env("SMTP_USERNAME", "")
    smtp_password = _env("SMTP_PASSWORD", "")
    smtp_from = _env("SMTP_FROM", "")
    smtp_reply_to = _env("SMTP_REPLY_TO", "") or smtp_from

    db = create_client(supabase_url, supabase_key)

    if args.to:
        # ---- test mode: one address, no audit, honors EMAIL_TRANSPORT ----
        html, text = _render_email(args.name, args.code, share_url)
        if transport_mode == "resend":
            if not _env("RESEND_API_KEY", ""):
                print("ERROR: EMAIL_TRANSPORT=resend requires RESEND_API_KEY", file=sys.stderr)
                return 2
            resend_key = _env("RESEND_API_KEY")
            from_email = _env("FROM_EMAIL", "FitCheck AI <team@fitcheckaiapp.com>")
            with httpx.Client() as client:
                ok, detail = _send_email_resend(client, resend_key, from_email, args.to, SUBJECT, html, text)
        else:
            if not (smtp_username and smtp_password and smtp_from):
                print("ERROR: test email via SMTP requires SMTP_USERNAME, SMTP_PASSWORD, SMTP_FROM", file=sys.stderr)
                return 2
            ok, detail = _send_email_smtp(
                smtp_host, smtp_port, smtp_username, smtp_password, smtp_from,
                args.to, smtp_reply_to, SUBJECT, html, text,
            )
        if not ok:
            print(f"FAIL test email to {args.to}: {detail}", file=sys.stderr)
            return 1
        print(f"OK test email sent to {args.to} (subject: {SUBJECT})")
        return 0

    # ---- full send ----
    if not args.force and not _promo_code_exists(db, args.code):
        print(
            f"ERROR: promo code {args.code} does not exist (or is inactive) in the "
            "hosted DB. Create it first: python scripts/create_promo_code.py "
            f"--code {args.code} --plan pro_monthly --months 1",
            file=sys.stderr,
        )
        return 1

    if transport_mode != "smtp":
        _env("RESEND_API_KEY", required=True)
        _env("FROM_EMAIL", "FitCheck AI <team@fitcheckaiapp.com>")
    if transport_mode != "resend":
        for n, v in (("SMTP_USERNAME", smtp_username), ("SMTP_PASSWORD", smtp_password),
                     ("SMTP_FROM", smtp_from)):
            if not v:
                print(f"ERROR: transport {transport_mode} requires {n}", file=sys.stderr)
                return 2

    users = list(_page_users(db, page_size))
    recipients = [u for u in users if not _is_bogus_email(u.get("email") or "")]
    already = _load_sent(audit_path)
    pending = [u for u in recipients if u["id"] not in already]
    plan = _get_transport_plan(pending, resend_cap, transport_mode)

    print(f"users found:       {len(users)}")
    print(f"bogus skipped:     {len(users) - len(recipients)}")
    print(f"already sent:      {len(already)}")
    print(f"to send:           {len(pending)}")
    print(f"  via resend:      {len(plan['resend'])}")
    print(f"  via smtp:        {len(plan['smtp'])}")
    if not pending:
        print("nothing to send.")
        return 0

    # Exclusive lock: a concurrent run would double-send the same users.
    lock_path = _acquire_lock(audit_path)

    resend_key = _env("RESEND_API_KEY", "") if transport_mode != "smtp" else ""
    from_email = _env("FROM_EMAIL", "FitCheck AI <team@fitcheckaiapp.com>")
    sent = 0
    failed = 0

    with httpx.Client() as client:
        for transport, group in (("resend", plan["resend"]), ("smtp", plan["smtp"])):
            if not group:
                continue
            for i, u in enumerate(group):
                html, text = _render_email(u.get("full_name"), args.code, share_url)
                to_email = u["email"]
                if transport == "resend":
                    ok, detail = _send_email_resend(client, resend_key, from_email, to_email, SUBJECT, html, text)
                else:
                    ok, detail = _send_email_smtp(
                        smtp_host, smtp_port, smtp_username, smtp_password, smtp_from,
                        to_email, smtp_reply_to, SUBJECT, html, text,
                    )
                if ok:
                    _append_audit(audit_path, {
                        "user_id": u["id"],
                        "email": to_email,
                        "action": "sent",
                        "transport": transport,
                        "code": args.code,
                        "sent_at": datetime.now(timezone.utc).isoformat(),
                    })
                    sent += 1
                    if sent % 25 == 0:
                        print(f"  sent {sent}/{len(pending)}")
                else:
                    failed += 1
                    print(f"  FAIL {to_email} ({transport}): {detail}", file=sys.stderr)
                if rate_ms > 0:
                    time.sleep(rate_ms / 1000.0)

    lock_path.unlink(missing_ok=True)
    print(f"DONE. sent={sent} failed={failed} (audit: {audit_path})")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
