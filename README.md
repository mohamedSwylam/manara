# Manara - Islamic App

A comprehensive Islamic application built with Flutter, featuring prayer times, Quran reading, and user authentication.

## Features

- **Secure Authentication**: Login and registration with secure token storage
- **Prayer Times**: Accurate prayer time calculations
- **Quran Reading**: Complete Quran with bookmarks and themes
- **Islamic Calendar**: Hijri calendar integration
- **Qibla Direction**: Accurate Qibla direction finder
- **Tasbih Counter**: Digital prayer counter
- **And much more...**

## Authentication System

The app uses a secure authentication system with the following features:

### Secure Storage
- **flutter_secure_storage**: Encrypted storage for sensitive data
- **Token Management**: Secure storage of authentication tokens
- **User Data**: Encrypted storage of user information
- **Automatic Cleanup**: Secure data removal on logout

### API Integration
- **Base URL**: `https://manara.geeltech.space/api`
- **Register Endpoint**: `/users/register`
- **Login Endpoint**: `/users/login`
- **Find User Endpoint**: `/users/find/{userId}`
- **Clean Architecture**: BLoC pattern for state management

## Usage Examples

### Register User
```dart
final request = RegisterRequestModel(
  fullName: 'John Doe',
  email: 'john@example.com',
  password: 'StrongPass!234',
  oneSignalId: 'onesignal-xxxxx',
);

final response = await AuthService.register(request);
print('User registered: ${response.userData.fullName}');
// Token and user data are automatically saved to secure storage
```

### Login User
```dart
final request = LoginRequestModel(
  email: 'john@example.com',
  password: 'StrongPass!234',
  oneSignalId: 'onesignal-xxxxx',
);

final response = await AuthService.login(request);
print('User logged in: ${response.userData.fullName}');
// Token and user data are automatically saved to secure storage
```

### Accessing Secure Storage
```dart
// Get stored token
final token = await SecureStorageManager.getToken();

// Get stored user ID
final userId = await SecureStorageManager.getUserId();

// Get stored user data
final userDataJson = await SecureStorageManager.getUserData();

// Check if user is logged in
final isLoggedIn = await SecureStorageManager.isLoggedIn();

// Clear all auth data (logout)
await SecureStorageManager.logout();
```

### User Data Management
```dart
// Find user by ID from API
final userData = await AuthService.findUserById('1755413662233');

// Refresh user data from API
final freshUserData = await AuthUtils.refreshUserData();

// Validate user session
final isValid = await AuthUtils.validateUserSession();
```

## Security Features

- **Encrypted Storage**: All sensitive data is encrypted using platform-specific encryption
- **Secure Token Management**: Authentication tokens are stored securely
- **Automatic Cleanup**: All sensitive data is removed on logout
- **Platform Security**: Uses Android's EncryptedSharedPreferences and iOS Keychain

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
