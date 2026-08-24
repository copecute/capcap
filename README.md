# Cap Cap

Cap Cap is a free and easy-to-use video editing application designed for fast content creation across mobile, tablet, and desktop devices.

## Project Goals
- Provide a simple and friendly video editing experience
- Keep core features free and accessible
- Deliver a modern cross-platform UI built with Flutter
- Prepare the architecture for high-performance media processing in C++

## Current MVP
- 3-step onboarding flow:
  - Introduction screen
  - Language selection
  - Light / Dark / System theme selection
  - Required permissions flow
  - Demo Google sign-in
- Home screen with 4 main tabs:
  - Edit
  - Templates
  - Projects
  - Account
- Automatic locale detection:
  - Uses Vietnamese when the device language is `vi`
  - Falls back to English for other locales

## Tech Stack
- **UI / Frontend:** Flutter
- **State management:** Provider
- **Local settings storage:** SharedPreferences
- **Planned media engine:** C++

## Architecture Direction
The project is planned in two layers:
- **Flutter layer:** navigation, app state, interface, and user interaction
- **C++ layer:** video/audio processing, effects, encoding, decoding, and performance-critical media tasks

In later phases, Flutter will communicate with the C++ media layer through FFI or platform channels.

## Suggested Roadmap
1. Finish the new project flow and media import.
2. Build a basic timeline for trimming, splitting, and arranging clips.
3. Add video export with progress feedback.
4. Integrate C++ modules for:
   - Video decoding / encoding
   - Basic filters and effects
   - Audio / video synchronization
5. Optimize performance for mid-range devices.

## Run the Project
```bash
flutter pub get
flutter run
```

## Android Note
If Android builds on Windows fail because Kotlin incremental caches conflict across different drive roots, keep this in `android/gradle.properties`:

```properties
kotlin.incremental=false
```

## Notes
- The current version focuses on UI and onboarding flow.
- Google sign-in is currently demo-only.
- Real media editing features will be implemented progressively in C++.
