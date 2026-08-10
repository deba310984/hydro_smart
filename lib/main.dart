import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';

import 'firebase_options.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/home_screen.dart';
import 'features/auth/auth_controller.dart';
import 'features/splash/splash_screen.dart';
import 'core/providers/update_providers.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/update_dialog.dart';
import 'core/models/update_model.dart';

// Splash screen state provider
final splashCompleteProvider = StateProvider<bool>((ref) => false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (kIsWeb) {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    }

    runApp(const ProviderScope(child: MyApp()));
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Firebase Init Error: $e')),
        ),
      ),
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splashComplete = ref.watch(splashCompleteProvider);
    final authState = ref.watch(authStateProvider);

    // Auto-check for updates when app starts
    ref.watch(autoUpdateCheckProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: splashComplete
          ? authState.when(
              loading: () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Scaffold(
                body: Center(child: Text('Auth Error: $e')),
              ),
              data: (user) {
                if (user == null) {
                  return const LoginScreen();
                } else {
                  return const AppWithUpdateCheck();
                }
              },
            )
          : SplashScreen(
              onComplete: () {
                ref.read(splashCompleteProvider.notifier).state = true;
              },
            ),
    );
  }
}

/// Wrapper widget that includes update notification
class AppWithUpdateCheck extends ConsumerStatefulWidget {
  const AppWithUpdateCheck({super.key});

  @override
  ConsumerState<AppWithUpdateCheck> createState() => _AppWithUpdateCheckState();
}

class _AppWithUpdateCheckState extends ConsumerState<AppWithUpdateCheck> {
  bool _forcedUpdateDialogShown = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  void _maybeShowForcedUpdateDialog() {
    if (_forcedUpdateDialogShown || !mounted) return;

    final updateState = ref.read(updateProvider);
    final version = updateState.availableVersion;
    if (updateState.status == UpdateStatus.available &&
        version != null &&
        version.isForced) {
      _forcedUpdateDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showUpdateDialog(context, version);
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.status;
    debugPrint('Location permission status: $status');

    if (status.isDenied || status.isRestricted) {
      final result = await Permission.location.request();
      debugPrint('Location permission request result: $result');
    } else if (status.isPermanentlyDenied) {
      debugPrint('Location permanently denied - opening app settings');
      await openAppSettings();
    } else {
      debugPrint('Location permission already granted');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<UpdateState>(updateProvider, (_, __) => _maybeShowForcedUpdateDialog());
    _maybeShowForcedUpdateDialog();

    return const Scaffold(
      body: Stack(
        children: [
          HomeScreen(),
          // Update notification overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: UpdateNotificationWidget(),
            ),
          ),
        ],
      ),
    );
  }
}
