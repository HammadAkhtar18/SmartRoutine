# SmartRoutine

SmartRoutine is a Flutter habit-tracking app that uses Provider for state management, MVVM architecture, and Hive for local storage.

## Features
- Splash screen
- Mocked login and signup
- Home dashboard with daily habits
- Add, edit, delete habits
- Mark habits as completed
- Track streaks
- Simple stats screen

## Folder Structure
```
lib/
  core/
    models/
    services/
    viewmodels/
  ui/
    theme/
    views/
    widgets/
  main.dart
```

## Getting Started
1. Install Flutter 3.x.
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Notes
- Authentication is mocked and does not connect to a backend.
- Data persists locally using Hive.
