import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../data/viewmodel/Providers/hadith_provider.dart';
import '../../data/viewmodel/Providers/user_provider.dart';
import '../../data/viewmodel/Providers/wallpaper_provider.dart';
import '../../constants/images.dart';
import 'main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late GeolocatorPlatform _geolocator;
  late LocationPermission _permission;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _geolocator = GeolocatorPlatform.instance;
    
    // Start initialization immediately but don't wait for it
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      print('🔄 Starting splash screen initialization...');
      
      // Add a timeout to prevent getting stuck
      final timeout = Future.delayed(const Duration(seconds: 3));
      
      // 1. CRITICAL: Get location permission (required for app functionality)
      await _getLocationPermission();
      
      // 2. NON-CRITICAL: Start data fetching in parallel (don't wait for completion)
      _startDataFetching();
      
      // 3. Navigate to home screen after minimum splash time or timeout
      await Future.any([
        Future.delayed(const Duration(milliseconds: 800)), // Reduced from 1500ms
        timeout,
      ]);
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        
        // Navigate to main navigation which contains the bottom navigation bar
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigation(),
          ),
        );
      }
      
    } catch (e) {
      print('❌ Error during splash initialization: $e');
      // Still navigate to main navigation even if initialization fails
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigation(),
          ),
        );
      }
    }
  }

  Future<void> _getLocationPermission() async {
    try {
      _permission = await _geolocator.checkPermission();
      if (_permission == LocationPermission.denied) {
        _permission = await _geolocator.requestPermission();
        if (_permission != LocationPermission.whileInUse &&
            _permission != LocationPermission.always) {
          _permission = await _geolocator.requestPermission();
        }
      }
      if (_permission == LocationPermission.deniedForever) {
        print('⚠️ Location permission denied forever');
      }
    } catch (e) {
      print('❌ Error getting location permission: $e');
    }
  }

  void _startDataFetching() {
    // Start all data fetching operations in parallel without waiting
    try {
      // Hadith data
      Provider.of<HadithProvider>(context, listen: false).fetchAllHadithData();
      Provider.of<HadithProvider>(context, listen: false).fetchAllDuaData();
      
      // User data
      Provider.of<UserProvider>(context, listen: false).fetchAllCurrencyData();
      
      // Wallpaper data
      Provider.of<WallPaperProvider>(context, listen: false).fetchAllWallpapers();
      
      // Language data
      Provider.of<HadithProvider>(context, listen: false).getLanguage();
      
      print('✅ Data fetching started in background');
    } catch (e) {
      print('❌ Error starting data fetching: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SvgPicture.asset(
        AssetsPath.splashBgSVG,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
