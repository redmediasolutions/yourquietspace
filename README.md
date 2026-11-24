# Therapist App

A privacy-first, anonymous mental health support app, built in Flutter. This is the UI only, with in-memory demo data and no backend.

Dark-first design system: near-black surfaces, hairline borders, one muted cool-blue accent and a restrained warm tone for safety. Inter is used for text, with JetBrains Mono for small technical labels.

## Run
```bash
flutter create . --project-name therapist_app   # generates android/ios/web/macos folders
flutter pub get
flutter run            # phone
flutter run -d chrome  # admin dashboard looks best on a wide window
```

## Entry points (Welcome screen footer)
- **Get started**: client flow
- **Therapist login**: therapist app (any password with 6+ characters, OTP `123456`)
- **Admin**: desktop-first admin console (responsive)
- **Components**: design-system reference and reusable system states

## Client
Splash → Welcome → Privacy intro → Anonymous profile → Concerns → Tell us more →
Finding therapist (orbital animation) → Match → Therapist profile → Private chat.
Bottom nav: Home · Chat · Journal · Mood · Profile.
Also: mood check-in and history (7/30 days), journal (home, empty state, editor, reading view),
emergency support, privacy center ("who can see what"), notification center and settings,
report/block with confirmations, session closed, therapist unavailable.

**Chat states**: open the chat's `•••` menu → *Preview states · demo* to switch between
empty, long history, typing, offline/network lost (messages fail → tap to retry), therapist away/offline,
unread divider, session ending, closed and reassigned. Message status cycles automatically:
sending → sent → delivered → read.

## Therapist
Login + 2-step code, dashboard, availability control, conversation list (split view on
tablets ≥900px), chat with an intake card, **private notes panel** (a separate warm "paper" surface,
never part of the conversation), close session, request reassignment, account.
Closing QuietMind55's session also closes it on the client side.

## Admin
Overview, therapists (view/edit/disable), clients (anonymous only), assignments (assign/reassign,
auto-assign), reports (New/Reviewing/Resolved with moderation actions; reported content needs
the reporter's consent plus a second admin's approval), settings (emergency numbers, matching, retention).

## Structure
```
lib/
  main.dart
  core/       theme.dart · widgets.dart (components) · visuals.dart (brand, orbit, lock)
              state.dart (models + demo store) · design_system.dart
  client/     onboarding · matching · shell (nav + home) · chat · mood · journal · profile
  therapist/  therapist_app.dart
  admin/      admin.dart
```
Emergency numbers (India: 112, Tele-MANAS 14416) live in `EmergencyConfig` in `core/state.dart`.
