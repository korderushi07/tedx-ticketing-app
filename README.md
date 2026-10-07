# ticketingapp

A new Flutter project.

## API configuration

The API base URL is loaded from `.env` and exposed through `ApiConfig.baseUrl`
in `lib/config/api_config.dart`.

Copy `.env.example` to `.env` before building or running the app, then set
`BASE_URL` to the backend URL. The provided URL targets the backend from an
Android emulator; for a physical device, use the development computer's
reachable LAN address instead.

The `.env` file is bundled into the Flutter app, so it must contain public
configuration only. Do not put secrets in it.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
