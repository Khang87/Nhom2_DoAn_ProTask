# ProTask Project Overview

ProTask is a task and project management application built with Flutter. It focuses on team collaboration, tracking project progress, and personal task management.

## Tech Stack
- **Framework:** Flutter (Dart)
- **State Management:** Provider
- **Backend/Auth:** Firebase (Core, Auth, Firestore, Google Sign In)
- **Local Storage:** SQLite (via `sqflite`), `shared_preferences`
- **Other Tools:** `intl` (localization), `url_launcher`

## Project Structure
- `lib/main.dart`: Entry point, Firebase initialization, and Provider setup.
- `lib/database/`: SQLite helper for local data management.
- `lib/model/`: Data models for Tasks, Projects, and Users.
- `lib/provider/`: Logic and state management (Auth, Theme, Locale, Project, Task).
- `lib/screen/`: UI screens for authentication, home dashboard, profiles, etc.
- `lib/firebase_options.dart`: Auto-generated Firebase configuration.

## Key Features
- **Authentication:** Supports Firebase Email/Password and Google Sign-in.
- **Data Sync:** Synchronizes user data between Firebase and local SQLite.
- **Theme & Localization:** Supports Light/Dark mode and multiple languages.
- **Project Management:** Create and track project progress with member collaboration.
- **Task Management:** Individual task tracking with status and deadlines.

## Building and Running
1.  **Prerequisites:**
    - Flutter SDK installed.
    - Android Studio / VS Code with Flutter extension.
    - Firebase project configured (see `firebase.json` and `google-services.json`).
2.  **Commands:**
    - Get dependencies: `flutter pub get`
    - Run the app: `flutter run`
    - Build for Android: `flutter build apk`
    - Build for iOS: `flutter build ios` (macOS only)

## Development Conventions
- **State Management:** Use `Provider` and `Consumer` for UI updates. Business logic should reside in the `provider/` directory.
- **Database:** Use `DatabaseHelper` for all SQLite operations. Always sync local changes with Firebase when online.
- **UI:** Follow Material 3 design principles. Use `MediaQuery` to handle different screen sizes and text scaling.
- **Naming:** Follow standard Dart/Flutter naming conventions (PascalCase for classes, camelCase for variables/functions).
- **Localization:** Use `LocaleProvider` and `intl` for string management.
