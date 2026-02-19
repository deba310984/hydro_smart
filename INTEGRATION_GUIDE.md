# Architectural Integration Guide

## Overview

This document describes the architectural improvements implemented to enhance error handling, navigation structure, and app-level state management in Hydro Smart.

## Changes Made

### 1. **Centralized Error Handler** ✅
**File**: `lib/core/services/error_handler.dart`

**Purpose**: Standardize error mapping across all layers from Firebase/network/generic sources to user-friendly messages.

**Key Components**:
- `AppException` class: Typed exception with message, code, original error, and stack trace
- `ErrorHandler.getErrorMessage()`: Maps error objects to user-friendly strings
- `ErrorHandler.logError()`: Structured error logging with context
- `ErrorHandler.showErrorSnackbar()`: Display errors via SnackBar UI

**Updated Files**:
1. **lib/data/repositories/auth_repository_impl.dart**
   - Added `import '../../core/services/error_handler.dart'`
   - signUp/signIn/signOut/updateProfile methods now:
     - Log errors using `ErrorHandler.logError(e, context: '...')`
     - Throw `AppException` instead of generic `Exception`

2. **lib/data/repositories/farm_repository_impl.dart**
   - Added `import '../../core/services/error_handler.dart'`
   - All methods (createFarm, deleteFarm, getFarm, updateFarm, getUserFarms, streamUserFarms) now:
     - Log errors using `ErrorHandler.logError(e, context: '...')`
     - Throw `AppException` with specific error codes for validation failures

3. **lib/features/auth/login_screen.dart**
   - Added `import '../../core/services/error_handler.dart'`
   - Removed local `_showErrorSnackbar()` and `_extractErrorMessage()` methods
   - `_handleLogin()` now uses `ErrorHandler.showErrorSnackbar(context, e)`

4. **lib/features/auth/register_screen.dart**
   - Added `import '../../core/services/error_handler.dart'`
   - Removed local `_showErrorSnackbar()` and `_extractErrorMessage()` methods
   - `_handleRegister()` now uses `ErrorHandler.showErrorSnackbar(context, e)`
   - Password mismatch and terms validation errors also use `ErrorHandler`

5. **lib/features/farm/farm_setup_screen.dart**
   - Added `import '../../core/services/error_handler.dart'`
   - `_deleteFarm()` catch block now uses `ErrorHandler.showErrorSnackbar(context, e)`
   - Form submission error catching replaced with `ErrorHandler.showErrorSnackbar(context, e)`

**Benefits**:
- Consistent error messaging across the app
- All Firebase errors mapped to user-friendly strings
- Network timeout errors identified and handled
- Single source of truth for error handling
- Improved debugging with structured error logging

---

### 2. **Named Route Navigation** ✅
**File**: `lib/core/navigation/app_router.dart`

**Purpose**: Replace scattered `Navigator.push()` calls with type-safe named routes.

**Key Components**:
- `AppRoutes` constants: /login, /register, /home, /farms, /recommendations, /settings
- `AppRouter.generateRoute()`: Centralized route factory for MaterialApp.onGenerateRoute
- `AppRouter.navigateTo()`: Push with replace (pushNamedAndRemoveUntil)
- `AppRouter.navigateToRoute()`: Push without replace (pushNamed)
- `AppRouter.goBack()`: Pop current route

**Updated Files**:
1. **lib/main.dart**
   - Added `import 'core/navigation/app_router.dart'`
   - Added `import 'features/app/app_state_provider.dart'` for theme provider
   - MaterialApp now uses:
     - `onGenerateRoute: AppRouter.generateRoute`
     - `themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light` (watches themeProvider)

2. **lib/features/auth/login_screen.dart**
   - Added `import '../../core/navigation/app_router.dart'`
   - Sign up button navigation changed from:
     ```dart
     Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen()))
     ```
     to:
     ```dart
     AppRouter.navigateToRoute(context, AppRoutes.register)
     ```

3. **lib/features/auth/register_screen.dart**
   - No direct navigation changes needed (only updates to error handling)
   - Future enhancement: Can use `AppRouter.navigateTo(context, AppRoutes.login)` after signup success

**Benefits**:
- Type-safe route references (compiler catches typos)
- Centralized route definitions
- Easy to add deep linking support later
- Single place to modify navigation behavior
- Reduced boilerplate (no MaterialPageRoute wrapping)

**Usage Pattern**:
```dart
// Instead of:
// Navigator.push(context, MaterialPageRoute(builder: (_) => MyScreen()))

// Use:
AppRouter.navigateToRoute(context, AppRoutes.myScreen);

// For redirects (replacing stack):
// AppRouter.navigateTo(context, AppRoutes.home);

// For going back:
// AppRouter.goBack(context);
```

---

### 3. **App-Level State Management** ✅
**File**: `lib/features/app/app_state_provider.dart`

**Purpose**: Manage global application state (connectivity, theme, loading, errors) accessible from any screen.

**Key Providers**:
1. **connectivityProvider**: `StreamProvider<List<ConnectivityResult>>`
   - Monitors real-time connection changes
   - Can detect when app goes offline/online

2. **isOnlineProvider**: `FutureProvider<bool>`
   - Checks current online status immediately

3. **themeProvider**: `StateNotifierProvider<ThemeNotifier, bool>`
   - Manages light/dark mode toggle
   - Watches from main.dart for theme switching

4. **globalLoadingProvider**: `StateNotifierProvider<LoadingNotifier, bool>`
   - App-wide loading indicator state
   - Can show overlay spinner across entire app

5. **globalErrorProvider**: `StateNotifierProvider<ErrorNotifier, String?>`
   - Store app-wide error for display
   - Can show persistent error banner

6. **appStateProvider**: `Provider<AppState>`
   - Combines all above providers
   - Single provider to watch for all global state

**Updated Files**:
1. **lib/main.dart**
   - Added `import 'features/app/app_state_provider.dart'`
   - MyApp now watches `themeProvider` for dark mode

**Usage Examples**:
```dart
// Check if online
final isOnline = ref.watch(isOnlineProvider);
isOnline.when(
  data: (online) => !online ? Text('Offline mode') : Container(),
  loading: () => SizedBox.shrink(),
  error: (_, __) => SizedBox.shrink(),
);

// Toggle theme
ref.read(themeProvider.notifier).toggle();

// Show loading
ref.read(globalLoadingProvider.notifier).setLoading(true);

// Watch all global state
final appState = ref.watch(appStateProvider);
```

**Future Integration Points**:
- Offline-first UI when `isOnline == false`
- Global loading overlay
- Persistent error messages
- FCM notification state
- User preferences (language, notification settings)

---

### 4. **Project Structure** ✅

**New Core Files**:
```
lib/
├── core/
│   ├── services/
│   │   └── error_handler.dart (NEW)
│   ├── navigation/
│   │   └── app_router.dart (NEW)
│   └── ...existing files...
├── features/
│   ├── app/
│   │   └── app_state_provider.dart (NEW)
│   └── ...existing screens...
└── main.dart (UPDATED with routing + theme)
```

---

## Verification Steps

### 1. **Compile Check**
```bash
flutter pub get
flutter analyze
```

Expected: 0 errors across all Dart files (ignoring unrelated lint warnings)

### 2. **Navigation Test**
1. Run app in emulator
2. Login → navigates to HomeScreen (via authStateProvider routing)
3. On LoginScreen, tap "Create Account" → should navigate to RegisterScreen via AppRouter
4. On RegisterScreen, tap back → should return to LoginScreen via AppRouter

### 3. **Error Handler Test**
1. Try login with invalid email → should show user-friendly error message via ErrorHandler
2. Try login with non-existent account → should show "No user found with this email"
3. Try login with wrong password → should show "Incorrect password"
4. Try creating farm with empty name → should show "Farm name cannot be empty"

### 4. **Theme Toggle Test** (when UI added)
1. Access theme toggle somewhere in app
2. Calling `ref.read(themeProvider.notifier).toggle()` should switch dark/light mode
3. Verify in main.dart that `themeMode` switches correctly

### 5. **Connectivity Test** (optional)
1. Turn off device WiFi/mobile data
2. Watch `isOnlineProvider` to confirm status changes
3. Verify app can be used in offline mode (cached data)

---

## Code Coverage

**Error Handling Integration**:
- ✅ Firebase Auth errors (signUp, signIn, signOut, updateProfile)
- ✅ Farm CRUD operations (validation errors, Firestore errors)
- ✅ UI error display (login/register/farm screens)
- ⏳ Sensor streaming errors (already uses AsyncValue)
- ⏳ Recommendation API errors (already uses try-catch in controller)

**Navigation Integration**:
- ✅ Main app routing (Firebase auth → HomeScreen/LoginScreen)
- ✅ Auth flow routing (LoginScreen ↔ RegisterScreen)
- ⏳ Farm management routing (Home → FarmSetupScreen)
- ⏳ Recommendation routing (Home → RecommendationScreen)

**State Management**:
- ✅ Theme switching (dark/light mode)
- ✅ Connectivity monitoring (online/offline detection)
- ⏳ Global loading indicator (UI component needed)
- ⏳ Global error state (UI component needed)

---

## Performance Impact

- **Memory**: Negligible increase (few additional providers)
- **Build Time**: No change (providers are lazy-loaded)
- **Runtime**: Slight overhead from error mapping (microseconds), acceptable trade-off for consistency
- **App Size**: ~2KB additional for error_handler.dart + navigation/state files

---

## Breaking Changes

**None**. All changes are:
- **Additive** (new files created, existing interfaces unchanged)
- **Backward Compatible** (old error handling still works, just mapped through ErrorHandler)
- **Gradual Integration** (files updated one by one, can be reverted individually)

---

## Future Enhancements

### Phase 2: Polish
1. **Global Loading Overlay**: Create UI component watching `globalLoadingProvider`
2. **Persistent Error Banner**: UI watching `globalErrorProvider`
3. **Offline Indicators**: Show "Offline Mode" banner when `!isOnline`
4. **Deep Linking**: Expand AppRouter to support URL-based navigation

### Phase 3: Advanced Features
1. **Request Deduplication**: Cache API responses in Hive
2. **Delta Sync**: Track changes and sync incrementally
3. **Retry Logic**: Exponential backoff for failed requests
4. **Analytics**: Log user actions via Firebase Analytics

### Phase 4: Monitoring
1. **Error Reporting**: Send AppException telemetry to Firebase Crashlytics
2. **Performance Metrics**: Track navigation timing, API latency
3. **User Tracking**: Session-based analytics with Mixpanel/Amplitude

---

## Rollback Instructions

If any integration needs to be reverted:

1. **Remove ErrorHandler usage**:
   - Delete `lib/core/services/error_handler.dart`
   - Replace `ErrorHandler.showErrorSnackbar()` back to manual SnackBar
   - Replace `ErrorHandler.logError()` back to Logger

2. **Remove Named Routes**:
   - Delete `lib/core/navigation/app_router.dart`
   - Replace `AppRouter.navigateTo()` back to `Navigator.push()`
   - Remove `onGenerateRoute` from MaterialApp

3. **Remove App State**:
   - Delete `lib/features/app/app_state_provider.dart`
   - Remove `themeProvider` watch from main.dart
   - Remove theme toggle functionality

Each change is isolated and can be reverted independently without affecting others.

---

## Summary

This integration improves the codebase in three key areas:

1. **Reliability**: Centralized error handling ensures users see consistent, helpful error messages
2. **Maintainability**: Named routes and centralized navigation make code changes easier
3. **Scalability**: App-state providers provide foundation for offline support, theming, and analytics

All changes follow clean architecture principles with proper layer separation (data → domain → presentation) and no breaking changes to existing functionality.

