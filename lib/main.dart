import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:manara/presentation/views/prayer/prayer_bloc.dart';
import 'package:manara/purchase/purchase_api.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app.dart';
import 'constants/localization/dependency_inj.dart';
import 'data/bloc/prayer_times_bloc.dart';
import 'data/services/workmanager_notification_service.dart';
import 'data/services/quran_api_service.dart';
import 'data/services/location_service.dart';
import 'data/services/dua_cache_service.dart';
import 'data/viewmodel/Providers/counter_provider.dart';
import 'data/viewmodel/Providers/gpt_provider.dart';
import 'data/viewmodel/Providers/hadith_provider.dart';
import 'data/viewmodel/Providers/link_provider.dart';
import 'data/viewmodel/Providers/location_provider.dart';
import 'data/viewmodel/Providers/note_provider.dart';
import 'data/viewmodel/Providers/user_provider.dart';
import 'data/viewmodel/Providers/wallpaper_provider.dart';
import 'data/models/quran/quran_ayah_bookmark_model.dart';
import 'data/models/dua/dua_category_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Show the app immediately with a lightweight splash while heavy work runs.
  runApp(const _BootStrapApp());

  // Kick off heavy initialization fully asynchronously.
  _initializeAppInBackground();
}

// Lightweight bootstrap app that displays Splash instantly
class _BootStrapApp extends StatelessWidget {
  const _BootStrapApp();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _ColdStartSplash(),
    );
  }
}

// Very small splash to avoid jank on cold start
class _ColdStartSplash extends StatelessWidget {
  const _ColdStartSplash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

// Performs heavy initialization off the UI thread as much as possible
Future<void> _initializeAppInBackground() async {
  print('🚀 App startup initiated (async)');

  try {
    // Load env and init timezone first (fast operations)
    await dotenv.load(fileName: ".env");
    tz.initializeTimeZones();

    // Start independent tasks in parallel
    final hiveAndCache = _initHiveAndCaches();
    final firebaseAndPurchases = _initFirebaseAndPurchases();
    final locationInit = _safeLocationInit();
    final workManagerInit = _initWorkManager();

    // Load languages while others run
    final languagesFuture = LanguageDependency.init();

    // Wait for minimum required: languages to render the app shell
    final languages = await languagesFuture;

    // Now replace bootstrap with the full app shell
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => NoteProvider()),
          ChangeNotifierProvider(create: (context) => ZikirProvider()),
          ChangeNotifierProvider(create: (context) => LocationProvider()),
          ChangeNotifierProvider(create: (context) => HadithProvider()),
          ChangeNotifierProvider(create: (context) => UserProvider()),
          ChangeNotifierProvider(create: (context) => GPTProvider()),
          ChangeNotifierProvider(create: (context) => WallPaperProvider()),
          ChangeNotifierProvider(create: (context) => LinkProvider()),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => PrayerBloc()),
            BlocProvider(create: (_) => PrayerTimesBloc()),
          ],
          child: JazakAllah(languages: languages),
        ),
      ),
    );

    // Await remaining background initializations without blocking UI
    await Future.wait([
      hiveAndCache,
      firebaseAndPurchases,
      locationInit,
      workManagerInit,
      _initializeBackgroundServices(),
    ]);

    print('🎉 App startup completed (async)');
  } catch (e) {
    print('❌ Critical error during async startup: $e');

    // Try to at least render the app with fallback languages
    final languages = await LanguageDependency.init();
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => NoteProvider()),
          ChangeNotifierProvider(create: (context) => LocationProvider()),
          ChangeNotifierProvider(create: (context) => HadithProvider()),
          ChangeNotifierProvider(create: (context) => UserProvider()),
          ChangeNotifierProvider(create: (context) => GPTProvider()),
          ChangeNotifierProvider(create: (context) => WallPaperProvider()),
          ChangeNotifierProvider(create: (context) => LinkProvider()),
        ],
        child: JazakAllah(languages: languages),
      ),
    );
  }
}

Future<void> _initHiveAndCaches() async {
  try {
    await QuranApiService.initializeHive();
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(QuranAyahBookmarkModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(BookmarkTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(DuaCategoryModelAdapter());
    }
    await DuaCacheService.initialize();
    print('✅ Hive and caches initialized');
  } catch (e) {
    print('⚠️ Hive/cache init failed: $e');
  }
}

Future<void> _initFirebaseAndPurchases() async {
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized');
  } catch (e) {
    print('⚠️ Firebase initialization failed (continuing): $e');
  }
  try {
    await PurchaseApi.init();
    print('✅ Purchase API initialized');
  } catch (e) {
    print('⚠️ Purchase API initialization failed (continuing): $e');
  }
}

Future<void> _safeLocationInit() async {
  try {
    await LocationService().initialize();
    print('✅ Location service initialized');
  } catch (e) {
    print('⚠️ Location service initialization failed: $e');
  }
}

Future<void> _initWorkManager() async {
  try {
    final workManagerService = WorkManagerNotificationService();
    await workManagerService.initialize();
    await workManagerService.requestNotificationPermissions();
    await workManagerService.initializeWorkManager();
    await Future.delayed(const Duration(milliseconds: 200));
    print('✅ WorkManager notification service initialized');
  } catch (e) {
    print('⚠️ WorkManager init failed: $e');
  }
}

// Initialize non-critical services in background
Future<void> _initializeBackgroundServices() async {
  try {
    // Initialize OneSignal
    final oneSignalKey = dotenv.env['oneSignalKey'];
    if (oneSignalKey != null &&
        oneSignalKey.isNotEmpty &&
        !oneSignalKey.contains('YOUR ONESIGNAL APP ID HERE')) {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.initialize(oneSignalKey);
      await OneSignal.Notifications.requestPermission(true);
      print('✅ OneSignal initialized');
    }

    // WorkManager already initialized in main function
    print('✅ WorkManager already initialized in main function');

    // Preload Quran data
    await QuranApiService.preloadQuarterAyahTexts();
    print('✅ Quran data preloaded');
  } catch (e) {
    print('❌ Background service initialization failed: $e');
  }
}
