"""Deterministic, cacheable artwork for Pro gift vouchers."""

from __future__ import annotations

import io
import random
import textwrap
from datetime import datetime
from pathlib import Path
from typing import Any, Literal

import qrcode
from PIL import Image, ImageDraw, ImageFont

from app.core.config import settings
from app.core.logging_config import get_context_logger
from app.services.object_storage import get_storage_backend

logger = get_context_logger(__name__)

ArtworkVariant = Literal["portrait", "og"]

_REPO_ROOT = Path(__file__).resolve().parents[3]
_MANROPE_FONT = _REPO_ROOT / "frontend" / "public" / "fonts" / "manrope-latin-var.woff2"
_INTER_FONT = _REPO_ROOT / "frontend" / "public" / "fonts" / "inter-latin-var.woff2"

INK = "#151411"
IVORY = "#F7F2E9"
PAPER = "#FFFDF8"
RED = "#E00016"
MUTED = "#6B655D"
HAIRLINE = "#D8CFC1"


def _font(
    size: int,
    *,
    display: bool = False,
    weight: int | None = None,
) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    path = _MANROPE_FONT if display else _INTER_FONT
    try:
        font = ImageFont.truetype(str(path), size=size)
        font.set_variation_by_axes([weight if weight is not None else (500 if display else 400)])
        return font
    except OSError:
        return ImageFont.load_default(size=size)


def _money(cents: int) -> str:
    return f"${cents // 100:,} value"


def _term(months: int) -> str:
    if months == 1:
        return "1 MONTH"
    if months == 12:
        return "1 YEAR"
    return f"{months} MONTHS"


def _draw_tracking_text(
    draw: ImageDraw.ImageDraw,
    position: tuple[int, int],
    text: str,
    *,
    font: ImageFont.ImageFont,
    fill: str,
    tracking: int,
) -> None:
    x, y = position
    for character in text:
        draw.text((x, y), character, font=font, fill=fill)
        width = draw.textlength(character, font=font)
        x += int(width) + tracking


def _fit_text(draw: ImageDraw.ImageDraw, value: str, width: int, start_size: int) -> ImageFont.ImageFont:
    for size in range(start_size, 7, -2):
        font = _font(size, display=True, weight=600)
        if draw.textlength(value, font=font) <= width:
            return font
    return _font(8, display=True, weight=600)


def _make_qr(link: str, size: int) -> Image.Image:
    code = qrcode.QRCode(version=None, error_correction=qrcode.constants.ERROR_CORRECT_M, box_size=8, border=2)
    code.add_data(link)
    code.make(fit=True)
    image = code.make_image(fill_color=INK, back_color=PAPER).convert("RGB")
    return image.resize((size, size), Image.Resampling.NEAREST)


class GiftArtworkService:
    """Render premium gift artwork and cache it in the private object store."""

    @staticmethod
    def _message_lines(message: str) -> list[str]:
        return textwrap.TextWrapper(
            width=48,
            max_lines=4,
            placeholder="…",
            break_long_words=True,
            break_on_hyphens=False,
        ).wrap(message)

    @staticmethod
    def storage_key(voucher: dict[str, Any], variant: ArtworkVariant) -> str:
        return (
            f"public/gifts/{voucher['public_id']}/"
            f"v{int(voucher.get('artwork_version') or 1)}/{variant}.png"
        )

    @staticmethod
    def render(
        voucher: dict[str, Any],
        *,
        variant: ArtworkVariant,
        claim_url: str | None = None,
        claim_code: str | None = None,
    ) -> bytes:
        width, height = ((1080, 1350) if variant == "portrait" else (1200, 630))
        image = Image.new("RGB", (width, height), IVORY)
        draw = ImageDraw.Draw(image)
        seed = int(str(voucher["public_id"]).replace("-", "")[:16], 16)
        rng = random.Random(seed)

        # Fine deterministic textile grain. It reads as paper/silk texture but
        # stays small and reproducible for cached social previews.
        for _ in range(int(width * height * 0.006)):
            x, y = rng.randrange(width), rng.randrange(height)
            tone = rng.choice(("#EEE7DB", "#F1EADF", "#FAF6EF"))
            draw.point((x, y), fill=tone)

        margin = 54 if variant == "portrait" else 42
        draw.rounded_rectangle(
            (margin, margin, width - margin, height - margin),
            radius=34,
            fill=PAPER,
            outline=HAIRLINE,
            width=2,
        )

        # Oversized monogram arcs make the card recognizable without stock art.
        arc_width = 12 if variant == "portrait" else 9
        draw.arc(
            (width * 0.62, -height * 0.18, width * 1.22, height * 0.48),
            20,
            250,
            fill=RED,
            width=arc_width,
        )
        draw.arc(
            (-width * 0.2, height * 0.76, width * 0.45, height * 1.3),
            190,
            40,
            fill=INK,
            width=arc_width,
        )

        inner_x = margin + (66 if variant == "portrait" else 54)
        inner_right = width - inner_x
        _draw_tracking_text(
            draw,
            (inner_x, margin + 54),
            "FITCHECK AI  /  PRIVATE GIFT",
            font=_font(20 if variant == "portrait" else 16, display=True),
            fill=MUTED,
            tracking=3,
        )

        if variant == "portrait":
            draw.text((inner_x, 245), "FITCHECK", font=_font(102, display=True, weight=700), fill=INK)
            draw.text((inner_x, 340), "PRO", font=_font(102, display=True, weight=700), fill=RED)
            draw.line((inner_x, 485, inner_right, 485), fill=HAIRLINE, width=2)

            to_name = str(voucher["to_name"])
            draw.text((inner_x, 548), "CREATED FOR", font=_font(21, display=True), fill=MUTED)
            draw.text((inner_x, 588), to_name, font=_fit_text(draw, to_name, inner_right - inner_x, 58), fill=INK)
            draw.text((inner_x, 690), "A GIFT FROM", font=_font(21, display=True), fill=MUTED)
            from_name = str(voucher["from_name"])
            draw.text(
                (inner_x, 730),
                from_name,
                font=_fit_text(draw, from_name, inner_right - inner_x, 38),
                fill=INK,
            )

            message = str(voucher.get("message") or "A private invitation to make getting dressed feel effortless.")
            message_lines = GiftArtworkService._message_lines(message)
            draw.multiline_text(
                (inner_x, 820),
                "\n".join(message_lines),
                font=_font(24),
                fill=MUTED,
                spacing=10,
            )

            term_y = 1012
            draw.rounded_rectangle((inner_x, term_y, 610, term_y + 112), radius=24, fill=INK)
            draw.text((inner_x + 28, term_y + 20), _term(int(voucher["duration_months"])), font=_font(29, display=True, weight=700), fill=PAPER)
            draw.text((inner_x + 28, term_y + 62), _money(int(voucher["retail_value_cents"])), font=_font(21), fill="#D9D1C6")

            if claim_url and claim_code:
                qr = _make_qr(claim_url, 170)
                image.paste(qr, (inner_right - 170, 970))
                code_groups = claim_code.split("-")
                split_at = (len(code_groups) + 1) // 2
                code_lines = (
                    "-".join(code_groups[:split_at]),
                    "-".join(code_groups[split_at:]),
                )
                draw.text(
                    (inner_right, 1151),
                    "VOUCHER CODE",
                    font=_font(11, display=True),
                    fill=MUTED,
                    anchor="ra",
                )
                draw.text(
                    (inner_right, 1170),
                    code_lines[0],
                    font=_font(13, display=True),
                    fill=MUTED,
                    anchor="ra",
                )
                if code_lines[1]:
                    draw.text(
                        (inner_right, 1190),
                        code_lines[1],
                        font=_font(13, display=True),
                        fill=MUTED,
                        anchor="ra",
                    )

            expiry = voucher.get("expires_at")
            if expiry:
                if isinstance(expiry, str):
                    expiry = datetime.fromisoformat(expiry.replace("Z", "+00:00"))
                footer = f"PROMOTIONAL GIFT · CLAIM BY {expiry.strftime('%b %d, %Y').upper()}"
            else:
                footer = "GIFT VOUCHER · NO EXPIRY BEFORE CLAIM"
            draw.text((inner_x, 1245), footer, font=_font(16, display=True), fill=MUTED)
        else:
            draw.text((inner_x, 165), "A FITCHECK PRO GIFT", font=_font(62, display=True, weight=700), fill=INK)
            draw.text((inner_x, 250), f"For {voucher['to_name']}", font=_fit_text(draw, str(voucher["to_name"]), 700, 42), fill=RED)
            from_label = f"From {voucher['from_name']}"
            draw.text(
                (inner_x, 322),
                from_label,
                font=_fit_text(draw, from_label, 700, 28),
                fill=MUTED,
            )
            draw.rounded_rectangle((inner_x, 405, inner_x + 360, 492), radius=22, fill=INK)
            draw.text((inner_x + 25, 421), _term(int(voucher["duration_months"])), font=_font(25, display=True, weight=700), fill=PAPER)
            draw.text((inner_x + 25, 456), _money(int(voucher["retail_value_cents"])), font=_font(18), fill="#D9D1C6")

        output = io.BytesIO()
        image.save(output, format="PNG", optimize=True)
        return output.getvalue()

    @classmethod
    async def get_or_render(
        cls,
        voucher: dict[str, Any],
        *,
        variant: ArtworkVariant,
        claim_url: str | None = None,
        claim_code: str | None = None,
    ) -> bytes:
        key = cls.storage_key(voucher, variant)
        storage_configured = bool(
            settings.OBJECT_STORAGE_ENDPOINT
            and settings.OBJECT_STORAGE_ACCESS_KEY_ID
            and settings.OBJECT_STORAGE_SECRET_ACCESS_KEY
            and settings.OBJECT_STORAGE_BUCKET
        )
        backend = get_storage_backend() if storage_configured else None
        if backend is not None:
            try:
                if await backend.exists(key):
                    return await backend.download(key)
            except Exception as exc:  # noqa: BLE001 - cache miss must not break artwork
                logger.warning("Gift artwork cache read failed", storage_key=key, error=str(exc))

        rendered = cls.render(
            voucher,
            variant=variant,
            claim_url=claim_url,
            claim_code=claim_code,
        )
        if backend is not None:
            try:
                await backend.upload(
                    key=key,
                    data=rendered,
                    content_type="image/png",
                    cache_control="3600",
                )
            except Exception as exc:  # noqa: BLE001 - rendering remains usable
                logger.warning("Gift artwork cache write failed", storage_key=key, error=str(exc))
        return rendered
