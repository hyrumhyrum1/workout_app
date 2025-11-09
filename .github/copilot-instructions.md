# AI Assistant Instructions for workout_app

## Project Overview
This is a cross-platform Flutter application designed to automate workout planning and provide real-time, individualized feedback to optimize performance. The app is built using Flutter SDK ^3.9.2 and follows Material Design principles.

## Architecture Overview
- **Entry Point**: `lib/main.dart` - Contains the root `MainApp` widget and theme configuration
- **Navigation**: `lib/navigation.dart` - Implements bottom navigation bar with 4 main sections:
  - Plan (Home)
  - Training
  - Profile
  - Test

The app uses a straightforward widget-based architecture typical of Flutter applications, with stateless and stateful widgets managing the UI and state.

## Key Development Workflows

### Setup and Running
1. Ensure Flutter SDK ^3.9.2 is installed
2. Run `flutter pub get` to install dependencies
3. Use `flutter run` to launch the app on your chosen platform

### Platform-Specific Development
- Android: Check `android/` directory for Gradle configurations
- iOS: Navigate to `ios/` for XCode project settings
- Web: Basic configuration in `web/`
- Desktop: Support files in `linux/`, `windows/`, and `macos/` directories

## Project Conventions

### Widget Structure
- Each major screen is represented as a widget
- Navigation is handled through the custom `NavigationBar` widget in `navigation.dart`
- Bottom navigation uses Material icons for consistency

### State Management
- Currently using basic Flutter state management with `setState`
- Screen state is managed within individual StatefulWidget classes

### Code Organization
- Main application code lives in `lib/`
- Platform-specific code is separated into respective directories
- Assets (when added) should go in an `assets/` directory and be declared in `pubspec.yaml`

## Dependencies
- Core Flutter SDK
- `flutter_lints: ^5.0.0` for code quality
- Material Design components through `uses-material-design: true`

## Common Tasks
- Adding a new screen: Create a new widget class and add to `_pages` list in `navigation.dart`
- Updating theme: Modify `ThemeData` in `main.dart`
- Adding dependencies: Declare in `pubspec.yaml` and run `flutter pub get`