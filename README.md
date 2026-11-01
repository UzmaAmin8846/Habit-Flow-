# HabitFlow 🔥

A habit tracker built with **Flutter + Riverpod + GoRouter + Firebase (Auth & Firestore)**.

## App Specification
- **Problem:** People start good habits but lose motivation because they can't see their consistency.
- **Target user:** Students and young professionals who want a simple daily habit check-in with streaks.
- **Core features (5):**
  1. Authentication (sign up, log in, log out, password reset)
  2. Create / edit / delete habits (Firestore CRUD, per-user data)
  3. Daily check-in with one tap
  4. Streaks + weekly progress + 14-day history
  5. Light / Dark / Auto theme (saved locally)
- **Out of scope (v1):** reminders/notifications, social sharing, widgets, Google sign-in, charts over months.
- **Success metric:** A new user can sign up, create a habit and check it in within 60 seconds, and sees the streak update instantly (also offline).

## Architecture
`Data Source -> Repository -> Notifier/Provider -> UI` (feature-first).

## Setup
From the project root, install dependencies and generate Firebase configuration for your Firebase project:
```
flutter pub get
dart pub global activate flutterfire_cli
firebase login
flutterfire configure
```
Select the Firebase project and Web platform when prompted. This generates `lib/firebase_options.dart`.

To run in Chrome:
```
flutter run -d chrome
```
