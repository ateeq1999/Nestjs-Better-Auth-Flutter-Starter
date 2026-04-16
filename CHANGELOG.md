# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-04-16

### Added
- Initial project setup with Flutter + GetX
- Authentication module (Sign In, Sign Up, Forgot Password, Reset Password, Verify Email, Two Factor)
- Home and Profile modules
- Settings module with theme toggle, change password, and 2FA support
- DioService with interceptors for auth token handling
- AuthService for secure token storage
- NotificationService for Firebase Cloud Messaging
- Deep link support for OAuth callbacks
- Unit tests for AuthRepository, AuthMiddleware, AuthService
- Widget tests for SignInView
- Integration tests for authentication flow
- Android intent filter for deep links
- iOS URL scheme configuration

### Features
- Bearer token authentication with automatic refresh
- Secure token storage (iOS Keychain / Android Keystore)
- Push notifications via Firebase Cloud Messaging
- Local notifications with flutter_local_notifications
- Avatar upload with image_picker
- Form validation with flutter_form_builder
- GetX state management and routing
- GetX middleware for route guards

### Dependencies
- get: State management, routing, dependency injection
- dio: HTTP client
- flutter_secure_storage: Secure token storage
- get_storage: Local preferences
- flutter_dotenv: Environment variables
- firebase_core, firebase_messaging, firebase_analytics: Firebase
- flutter_local_notifications: Local notifications
- image_picker: Image selection
- cached_network_image: Image caching
- app_links: Deep linking

### Documentation
- README.md with comprehensive documentation
- CONTRIBUTING.md guidelines
- LICENSE (MIT)
- TODO.md for project tracking
- todo.txt for manual setup instructions
