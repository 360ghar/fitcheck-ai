# FitCheck AI Flutter App

Flutter mobile app for FitCheck AI.

## Architecture

- State management and routing via GetX
- Feature-first modules under `lib/features/`
- Shared infrastructure in `lib/core/`
- App-level routes/bindings/themes in `lib/app/`

## Main Features

- Authentication
- Dashboard and shell navigation
- Wardrobe and batch extraction flows
- Outfits and try-on
- Recommendations
- Photoshoot generation
- Subscription and referral UX
- Profile/settings/legal/feedback screens

## Setup

```bash
cd flutter
flutter pub get
```

Run app:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://localhost:8000 \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

## Environment

Template: `flutter/.env.example`

Environment loading is handled by `lib/core/config/env_config.dart`:
- compile-time defines via `--dart-define`
- fallback to `.env` asset values when present

Key values:
- `API_BASE_URL`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- optional: `POSTHOG_API_KEY`, `POSTHOG_HOST`

## Project Layout

- `lib/main.dart`: app bootstrap
- `lib/app/`: routes, bindings, theming
- `lib/core/`: config, services, network, utils, widgets
- `lib/features/`: domain feature modules

## Testing

```bash
cd flutter
flutter test
```
