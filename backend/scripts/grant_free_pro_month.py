#!/usr/bin/env python3
"""
Grant every user a 1-month Pro trial and email them about it.

Self-contained one-off campaign script. No app imports (mirrors
seed_app_store_reviewer.py). Campaign state (who was granted / emailed)
lives in a JSONL audit file so re-runs are idempotent and the companion
revert_expired_pro_trials.py can target exactly this campaign without any
DB schema change.

Usage:
    cd backend
    export SUPABASE_URL=https://YOUR_PROJECT.supabase.co
    export SUPABASE_SECRET_KEY=eyJ...        # service-role key
    export RESEND_API_KEY=re_...             # https://resend.com/api-keys
    export FROM_EMAIL='FitCheck AI <team@fitcheckaiapp.com>'

    # 1) preview (writes / sends nothing):
    DRY_RUN=1 python scripts/grant_free_pro_month.py

    # 2) grant + email for real:
    python scripts/grant_free_pro_month.py

Optional env:
    DURATION_MONTHS=1          # length of the gifted trial
    SKIP_EMAIL=0               # 1 = grant only, skip the email blast
    EMAIL_TRANSPORT=resend     # resend | smtp  (smtp = Gmail etc. via STARTTLS)
    AUDIT_FILE=backend/logs/pro_grant.jsonl
    PAGE_SIZE=500
    EMAIL_RATE_LIMIT_MS=250    # throttle between sends

SMTP transport env (only read when EMAIL_TRANSPORT=smtp):
    SMTP_HOST=smtp.gmail.com
    SMTP_PORT=587
    SMTP_USERNAME=...
    SMTP_PASSWORD=...          # app password; never written to .env by this script
    SMTP_FROM='Saksham Mittal <saksham@fitcheckaiapp.com>'
    SMTP_REPLY_TO=...

Notes:
    - EMAIL_TRANSPORT=resend: FROM_EMAIL domain must be verified in Resend or
      sends will 401.
    - EMAIL_TRANSPORT=smtp: Gmail forces From to match the authenticated
      account unless a "Send mail as" alias is set up for SMTP_FROM's address.
      SPF for the From domain may not fully align when relaying through Gmail;
      strict receivers (e.g. yahoo.com with DMARC p=reject) may spam-folder it.
    - Paid users (stripe_subscription_id IS NOT NULL) are emailed but NOT
      granted a trial - their paid subscription row is never overwritten.
    - Recipients on bogus/reserved domains (example.com, test.com, ...) are
      skipped to avoid guaranteed bounces; they stay marked un-emailed.
    - The audit file is the source of truth for this campaign; back it up.
      revert_expired_pro_trials.py depends on it to know which trials to
      revert after the month ends.
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
from dateutil.relativedelta import relativedelta
from supabase import create_client

RESEND_URL = "https://api.resend.com/emails"

# Domains we never send to - reserved/fake TLDs that receivers reject or
# that would hard-bounce. Kept explicit; not a generic regex.
BOGUS_EMAIL_DOMAINS = {
    "example.com", "example.org", "example.net",
    "test.com", "test.org",
    "localhost", "localhost.com",
    "fake.com", "invalid.com",
}


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


def _env_bool(name: str, default: bool = False) -> bool:
    return os.environ.get(name, "1" if default else "0").strip() in {"1", "true", "yes", "on"}


def _env_int(name: str, default: int) -> int:
    raw = os.environ.get(name, str(default)).strip()
    try:
        return int(raw)
    except ValueError:
        print(f"WARNING: {name}={raw!r} is not an int, using {default}", file=sys.stderr)
        return default


def _utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def _load_audit(path: Path) -> dict[str, set[str]]:
    granted: set[str] = set()
    emailed: set[str] = set()
    if not path.exists():
        return {"granted": granted, "emailed": emailed}
    with path.open("r", encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                rec = json.loads(line)
            except json.JSONDecodeError:
                continue
            uid = rec.get("user_id")
            if not uid:
                continue
            action = rec.get("action")
            if action == "granted":
                granted.add(uid)
            elif action == "emailed":
                emailed.add(uid)
    return {"granted": granted, "emailed": emailed}


def _append_audit(path: Path, record: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as fh:
        fh.write(json.dumps(record, separators=(",", ":")) + "\n")


def _fetch_subscriptions(db: Any, user_ids: list[str]) -> dict[str, dict[str, Any]]:
    """Return {user_id: subscription_row} for the given user_ids (paged)."""
    out: dict[str, dict[str, Any]] = {}
    page = 500
    for i in range(0, len(user_ids), page):
        chunk = user_ids[i : i + page]
        res = db.table("subscriptions").select("user_id,plan_type,status,stripe_subscription_id").in_(
            "user_id", chunk
        ).execute()
        for row in (res.data or []):
            out[row["user_id"]] = row
    return out


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


# --------------------------------------------------------------------------- #
# email
# --------------------------------------------------------------------------- #
def _render_email(full_name: str | None, trial_end: str) -> tuple[str, str]:
    first = (full_name or "").strip().split(" ", 1)[0]
    greeting = f"Hi {first}," if first else "Hi there,"
    html = f"""<!DOCTYPE html>
<html>
  <body style="margin:0;padding:0;background:#f6f7f9;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;color:#111827;">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="padding:32px 0;">
      <tr><td align="center">
        <table role="presentation" width="560" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 1px 3px rgba(0,0,0,0.08);">
          <tr><td style="padding:32px 40px 8px 40px;">
            <h1 style="margin:0 0 8px 0;font-size:22px;font-weight:600;">You&#39;ve got Pro, on us.</h1>
          </td></tr>
          <tr><td style="padding:0 40px 24px 40px;">
            <p style="margin:0 0 16px 0;font-size:15px;line-height:1.6;">{greeting}</p>
            <p style="margin:0 0 16px 0;font-size:15px;line-height:1.6;">
              As one of our earliest users, your support means everything to us.
              To say thank you, we&#39;ve enabled <strong>FitCheck Pro free for the next month</strong>.
              No card, no catch.
            </p>
            <p style="margin:0 0 16px 0;font-size:15px;line-height:1.6;">
              Your Pro features are already active. Enjoy higher limits on
              wardrobe extraction, AI outfit generation, and more.
            </p>
            <p style="margin:0 0 8px 0;font-size:13px;line-height:1.5;color:#6b7280;">
              Your Pro access runs until {trial_end}, after which your account
              returns to the free plan automatically.
            </p>
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
        "As one of our earliest users, your support means everything to us. "
        "To say thank you, we've enabled FitCheck Pro free for the next month. "
        "No card, no catch.\n\n"
        "Your Pro features are already active. Enjoy higher limits on wardrobe "
        "extraction, AI outfit generation, and more.\n\n"
        f"Your Pro access runs until {trial_end}, after which your account "
        "returns to the free plan automatically.\n\n"
        "-- The FitCheck AI team\nhttps://www.fitcheckaiapp.com\n"
    )
    return html, text


def _send_email(client: httpx.Client, api_key: str, from_email: str,
                to_email: str, subject: str, html: str, text: str) -> tuple[bool, Any]:
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
        # Create context that doesn't verify the cert hostname to be forgiving
        # of shared SMTP relays; TLS still encrypts the connection.
        ctx = ssl.create_default_context()
        with smtplib.SMTP(host, port, timeout=30) as server:
            server.ehlo()
            server.starttls(context=ctx)
            server.ehlo()
            server.login(username, password)
            refused = server.send_message(msg)
            # send_message returns a dict of refused recipients (empty = ok).
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
def main() -> int:
    supabase_url = _env("SUPABASE_URL", required=True).rstrip("/")
    supabase_key = _env("SUPABASE_SECRET_KEY", required=True)

    duration_months = _env_int("DURATION_MONTHS", 1)
    if duration_months < 1:
        print(f"ERROR: DURATION_MONTHS={duration_months} must be at least 1", file=sys.stderr)
        sys.exit(1)
    skip_email = _env_bool("SKIP_EMAIL", False)
    dry_run = _env_bool("DRY_RUN", False)
    page_size = _env_int("PAGE_SIZE", 500)
    rate_ms = _env_int("EMAIL_RATE_LIMIT_MS", 250)
    audit_path = Path(_env("AUDIT_FILE", "backend/logs/pro_grant.jsonl"))

    # Email transport selection.
    email_transport = _env("EMAIL_TRANSPORT", "resend").strip().lower()
    if email_transport not in ("resend", "smtp"):
        print(f"ERROR: EMAIL_TRANSPORT={email_transport!r} must be 'resend' or 'smtp'", file=sys.stderr)
        sys.exit(1)

    # SMTP settings (only validated when used).
    smtp_host = _env("SMTP_HOST", "smtp.gmail.com")
    smtp_port = _env_int("SMTP_PORT", 587)
    smtp_username = _env("SMTP_USERNAME", "")
    smtp_password = _env("SMTP_PASSWORD", "")
    smtp_from = _env("SMTP_FROM", "")
    smtp_reply_to = _env("SMTP_REPLY_TO", "")
    if email_transport == "smtp":
        for n, v in (("SMTP_USERNAME", smtp_username), ("SMTP_PASSWORD", smtp_password),
                     ("SMTP_FROM", smtp_from)):
            if not v:
                print(f"ERROR: EMAIL_TRANSPORT=smtp requires {n}", file=sys.stderr)
                sys.exit(1)
        if not smtp_reply_to:
            smtp_reply_to = smtp_from

    now = datetime.now(timezone.utc)
    trial_end_dt = now + relativedelta(months=duration_months)
    now_iso = now.isoformat()
    trial_end_iso = trial_end_dt.isoformat()
    trial_end_pretty = trial_end_dt.strftime("%b %d, %Y")

    db = create_client(supabase_url, supabase_key)

    mode = "DRY-RUN" if dry_run else "LIVE"
    print(f"[{mode}] grant Free Pro Month to all users")
    print(f"  now          = {now_iso}")
    print(f"  trial_end    = {trial_end_iso} ({duration_months} month(s))")
    print(f"  skip_email   = {skip_email}")
    print(f"  transport    = {email_transport}")
    if email_transport == "smtp":
        print(f"  smtp_host    = {smtp_host}:{smtp_port}")
        print(f"  smtp_from    = {smtp_from}")
        print(f"  smtp_reply_to= {smtp_reply_to}")
    print(f"  audit_file   = {audit_path}")
    print()

    # --- preview email --------------------------------------------------------
    sample_html, sample_text = _render_email("Alex", trial_end_pretty)
    if dry_run:
        print("---- email preview (subject) ----")
        print("You've got Pro, on us. Thanks for being an early FitCheck user.")
        print("---- email preview (text) ----")
        print(sample_text)
        print("---- email preview (html, first 600 chars) ----")
        print(sample_html[:600])
        print()

    # --- collect users --------------------------------------------------------
    users: list[dict[str, Any]] = list(_page_users(db, page_size))
    if not users:
        print("no users found; nothing to do.")
        return 0
    user_ids = [u["id"] for u in users]
    subs = _fetch_subscriptions(db, user_ids)

    print(f"users found: {len(users)}")

    # Decouple grant from email:
    #   - paid users (live stripe_subscription_id) -> email only; their paid
    #     subscription row is NEVER overwritten with a trial.
    #   - everyone else -> grant a 1-month trial AND email.
    email_only: list[dict[str, Any]] = []
    eligible: list[dict[str, Any]] = []
    for u in users:
        sub = subs.get(u["id"])
        has_stripe = bool(sub and sub.get("stripe_subscription_id"))
        if has_stripe:
            email_only.append(u)
        else:
            eligible.append(u)

    print(f"  paid (email only, no grant): {len(email_only)}")
    print(f"  non-paid (grant + email):    {len(eligible)}")

    if dry_run:
        sample = eligible[0] if eligible else None
        if sample:
            print()
            print("---- sample upsert payload ----")
            print(json.dumps({
                "user_id": sample["id"],
                "plan_type": "pro_monthly",
                "status": "trial",
                "current_period_start": now_iso,
                "current_period_end": trial_end_iso,
                "trial_end": trial_end_iso,
                "cancel_at_period_end": True,
            }, indent=2))
        print()
        print("DRY-RUN: no writes, no emails sent.")
        return 0

    # --- live run -------------------------------------------------------------
    state = _load_audit(audit_path)
    print(f"audit: {len(state['granted'])} already granted, {len(state['emailed'])} already emailed")

    # Step 1: grants (batched upsert per page of eligible users not yet granted)
    to_grant = [u for u in eligible if u["id"] not in state["granted"]]
    print(f"\n[grant] {len(to_grant)} users to grant...")

    granted_now = 0
    grant_failed = 0
    newly_granted: set[str] = set()
    batch = 100
    for i in range(0, len(to_grant), batch):
        chunk = to_grant[i : i + batch]
        rows = [
            {
                "user_id": u["id"],
                "plan_type": "pro_monthly",
                "status": "trial",
                "current_period_start": now_iso,
                "current_period_end": trial_end_iso,
                "trial_end": trial_end_iso,
                "cancel_at_period_end": True,
            }
            for u in chunk
        ]
        try:
            db.table("subscriptions").upsert(rows, on_conflict="user_id").execute()
        except Exception as e:
            print(f"  ERROR upserting batch {i}-{i+len(chunk)}: {e}", file=sys.stderr)
            grant_failed += len(chunk)
            continue
        for u in chunk:
            newly_granted.add(u["id"])
            _append_audit(audit_path, {
                "user_id": u["id"],
                "action": "granted",
                "granted_at": now_iso,
                "trial_end": trial_end_iso,
            })
        granted_now += len(chunk)
        print(f"  granted {granted_now}/{len(to_grant)}")

    # All granted users = previously granted (from audit) + newly granted.
    all_granted = state["granted"] | newly_granted

    # Step 2: emails
    if skip_email:
        print("\n[email] SKIP_EMAIL=1; not sending.")
        return 1 if grant_failed > 0 else 0

    # Only email users who were actually granted (not failed batches) plus
    # the email_only (paid) users. This prevents falsely telling a user their
    # Pro is active when the upsert didn't succeed.
    to_email_all = [
        u for u in (eligible + email_only)
        if u["id"] not in state["emailed"]
        and (u["id"] in all_granted or u in email_only)
    ]

    # Drop recipients on bogus/reserved domains (example.com, test.com, ...).
    # These would hard-bounce or be rejected; we leave them un-emailed so they
    # stay visible in the audit as not-yet-contacted.
    skipped_bogus: list[str] = []
    to_email: list[dict[str, Any]] = []
    for u in to_email_all:
        if _is_bogus_email(u.get("email", "")):
            skipped_bogus.append(u["email"])
            continue
        to_email.append(u)

    print(f"\n[email] transport={email_transport} to_email={len(to_email)}"
          f" skipped_bogus={len(skipped_bogus)}")
    if skipped_bogus:
        print("  skipped bogus-domain addresses:")
        for e in skipped_bogus:
            print(f"    - {e}")

    subject = "You've got Pro, on us. Thanks for being an early FitCheck user."
    sent = 0
    email_failed = 0

    if email_transport == "smtp":
        # SMTP: one connection per recipient (simple, robust to mid-run drops).
        for u in to_email:
            html, text = _render_email(u.get("full_name"), trial_end_pretty)
            ok, detail = _send_email_smtp(
                smtp_host, smtp_port, smtp_username, smtp_password,
                smtp_from, u["email"], smtp_reply_to, subject, html, text,
            )
            if ok:
                _append_audit(audit_path, {
                    "user_id": u["id"],
                    "action": "emailed",
                    "emailed_at": _utc_now_iso(),
                    "transport": "smtp",
                    "email": u["email"],
                })
                sent += 1
                if sent % 25 == 0:
                    print(f"  emailed {sent}/{len(to_email)}")
            else:
                email_failed += 1
                print(f"  FAIL {u['email']}: {detail}", file=sys.stderr)
            if rate_ms > 0:
                time.sleep(rate_ms / 1000.0)
    else:
        # Resend over httpx. Validate Resend credentials here (not at the top
        # of main()) so that SMTP mode and SKIP_EMAIL=1 don't need the key.
        resend_key = _env("RESEND_API_KEY", required=True)
        from_email = _env("FROM_EMAIL", "FitCheck AI <team@fitcheckaiapp.com>")
        with httpx.Client() as client:
            for u in to_email:
                html, text = _render_email(u.get("full_name"), trial_end_pretty)
                ok, detail = _send_email(
                    client, resend_key, from_email, u["email"], subject, html, text
                )
                if ok:
                    _append_audit(audit_path, {
                        "user_id": u["id"],
                        "action": "emailed",
                        "emailed_at": _utc_now_iso(),
                        "transport": "resend",
                        "email": u["email"],
                    })
                    sent += 1
                    if sent % 25 == 0:
                        print(f"  emailed {sent}/{len(to_email)}")
                else:
                    email_failed += 1
                    print(f"  FAIL {u['email']}: {detail}", file=sys.stderr)
                if rate_ms > 0:
                    time.sleep(rate_ms / 1000.0)

    total_failed = grant_failed + email_failed
    print()
    print(f"DONE. granted_now={granted_now} grant_failed={grant_failed} emailed_now={sent} email_failed={email_failed}")
    if grant_failed > 0:
        print(f"  {grant_failed} grant(s) failed (see stderr above).", file=sys.stderr)
    if email_failed > 0:
        print(f"  {email_failed} email(s) failed (see stderr above).", file=sys.stderr)
    return 1 if total_failed > 0 else 0


if __name__ == "__main__":
    raise SystemExit(main())
