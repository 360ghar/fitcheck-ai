# Flutter

Last updated: 2026-07-22

Mobile client under `flutter/` using GetX feature modules.

## Commands

```bash
cd flutter
flutter pub get
flutter test
flutter run \
  --dart-define=API_BASE_URL=http://localhost:8000 \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

Env can also load via asset `.env` through `lib/core/config/env_config.dart`. Template: `flutter/.env.example`.

## Structure

```text
lib/
├── main.dart
├── app/           # routes, bindings, theme
├── core/          # config, network, shared services/utils/widgets
└── features/      # auth, wardrobe, outfits, photoshoot, recommendations, …
```

## Conventions

- Feature-first modules under `features/`
- GetX routes + bindings under `app/`
- Shared infra only under `core/`
- Talk to the same FastAPI backend as web (`API_BASE_URL`)

## Batch / AI

Prefer backend batch extract JSON base64 start endpoint from Flutter; SSE for progress. Align with `docs/BACKEND.md` batch section.

## CI

- `.github/workflows/flutter-ci.yml`
- Mobile build workflows for APK/iOS under `.github/workflows/`

## Notes

Deep feature behavior should be documented in `product-specs/` and implementation status. Expand this file when mobile-specific architecture decisions accumulate.
