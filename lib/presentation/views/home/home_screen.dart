import 'dart:convert';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../constants/images.dart';
import '../../../data/bloc/prayer_times_bloc.dart';
import '../../../data/bloc/qibla_bloc.dart';
import '../../../data/models/prayer_times_events.dart';
import '../../../data/models/prayer_times_model.dart';
import '../../../data/models/qibla_events.dart';
import '../../../data/models/qibla_state.dart';
import '../../../data/viewmodel/Providers/hadith_provider.dart';
import '../../../data/viewmodel/Providers/link_provider.dart';
import '../../../data/viewmodel/Providers/location_provider.dart';
import '../../../data/viewmodel/Providers/user_provider.dart';
import '../../widgets/loading_popup_widget.dart';
import '../../widgets/x.dart';
import '../../../data/services/last_read_service.dart';
import '../../../data/services/location_service.dart';
import '../quran/quran_reading_screen.dart';
import '../search/search_screen.dart';
import '../islamic_calendar_screen.dart';
import '../home/today_dua_screen.dart';
import '../home/tasbeh_screen.dart';
import '../Qibla/qibla_screen.dart';
import '../al_quran_details_screen.dart';
import '../quran/quran_index_screen.dart';
import '../Duaa/duas_screen.dart';
import '../Duaa/widget/duaa_mood_category_widget.dart';
import '../../../data/bloc/search/search_bloc.dart';
import 'nearby_mosques_map.dart';

class HomeScreen extends StatefulWidget {
  final bool loadUserData;

  const HomeScreen({super.key, required this.loadUserData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  // Static method to refresh last read card
  static void refreshLastReadCard() {
    // This will be called from navigation
    print('🔄 Refreshing last read card...');
  }
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  //Fetch Zikir from json
  List _zikir = [];
  int _lastReadKey = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    readJson();

    // Defer provider calls to after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
      _refreshLastReadData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh last read data when app is resumed
      _refreshLastReadData();
    }
  }

  void _refreshLastReadData() {
    // Force refresh of last read data by updating the key
    setState(() {
      _lastReadKey = DateTime.now().millisecondsSinceEpoch;
    });
  }

  Future<void> loadData() async {
    Provider.of<UserProvider>(context, listen: false)
        .fetchLoggedInUserData(widget.loadUserData);
    Provider.of<HadithProvider>(context, listen: false).getLanguage();
    Provider.of<LocationProvider>(context, listen: false).getLocation();
    Provider.of<LinkProvider>(context, listen: false).fetchData();
  }

  //Fetch Zikir from json
  Future<void> readJson() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('language');
    print(language);
    String jsonAssetPath = 'assets/locales/zikir_ar.json';
    if (language == 'en') {
      jsonAssetPath = 'assets/locales/zikir_en.json';
    } else if (language == 'ar') {
      jsonAssetPath = 'assets/locales/zikir_ar.json';
    }

    final String response = await rootBundle.loadString(jsonAssetPath);
    final data = await json.decode(response);
    setState(() {
      _zikir = data['data'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => PrayerTimesBloc()),
        BlocProvider(create: (context) => QiblaBloc()),
      ],
      child: _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent>
    with WidgetsBindingObserver {
  bool _blocsInitialized = false;
  bool _locationUpdateInProgress = false;
  int _lastReadKey = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Single post-frame callback to handle all initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_blocsInitialized) {
        setState(() {
          _blocsInitialized = true;
        });
        _initializeBLoCs();
        _refreshLastReadCard();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh last read card when app is resumed
      _refreshLastReadCard();
    }
  }

  void _refreshLastReadCard() {
    setState(() {
      _lastReadKey = DateTime.now().millisecondsSinceEpoch;
    });
  }

  // Listen to location changes and update BLoCs
  void _onLocationChanged() {
    if (mounted && _blocsInitialized && !_locationUpdateInProgress) {
      _locationUpdateInProgress = true;

      final locationService =
          Provider.of<LocationService>(context, listen: false);
      final prayerTimesBloc = context.read<PrayerTimesBloc>();
      final qiblaBloc = context.read<QiblaBloc>();

      print(
          '🔄 Location changed, updating BLoCs with: ${locationService.currentLatitude}, ${locationService.currentLongitude}');

      prayerTimesBloc.add(LoadPrayerTimes(
        latitude: locationService.currentLatitude,
        longitude: locationService.currentLongitude,
      ));

      qiblaBloc.add(LoadQiblaDirection(
        latitude: locationService.currentLatitude,
        longitude: locationService.currentLongitude,
      ));

      // Reset flag after a delay to prevent rapid successive updates
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _locationUpdateInProgress = false;
        }
      });
    }
  }

  Future<void> _initializeBLoCs() async {
    try {
      print('🚀 Starting BLoC initialization...');

      // Get location from the global location service
      final locationService =
          Provider.of<LocationService>(context, listen: false);
      final lat = locationService.currentLatitude;
      final lng = locationService.currentLongitude;

      print('📍 Using location from service: $lat, $lng');

      if (mounted) {
        // Access providers through the widget tree
        final prayerTimesBloc = context.read<PrayerTimesBloc>();
        final qiblaBloc = context.read<QiblaBloc>();

        // Initialize both BLoCs simultaneously
        print('🔄 Dispatching BLoC events...');
        prayerTimesBloc.add(LoadPrayerTimes(
          latitude: lat,
          longitude: lng,
        ));

        qiblaBloc.add(LoadQiblaDirection(
          latitude: lat,
          longitude: lng,
        ));

        print('✅ BLoC initialization completed');
      }
    } catch (e) {
      print('❌ Error during BLoC initialization: $e');
      // Fallback to default coordinates
      if (mounted) {
        final prayerTimesBloc = context.read<PrayerTimesBloc>();
        final qiblaBloc = context.read<QiblaBloc>();

        prayerTimesBloc.add(const LoadPrayerTimes(
          latitude: 25.2854,
          longitude: 51.5310,
        ));

        qiblaBloc.add(const LoadQiblaDirection(
          latitude: 25.2854,
          longitude: 51.5310,
        ));

        print('✅ BLoC initialization with fallback completed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.userDataLoading) {
          return Scaffold(
            backgroundColor: Colors.black.withOpacity(0.4),
            body: const LoadingPopupWidget(),
          );
        }

        final theme = Theme.of(context);
        return Consumer<LocationService>(
          builder: (context, locationService, child) {
            // Only listen to location changes if BLoCs are initialized
            if (_blocsInitialized) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _onLocationChanged();
              });
            }

            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildAppBar(),
                      const PrayerTimesCard(),
                      SizedBox(height: 16.h),
                      _buildFeaturesGrid(),
                      SizedBox(height: 16.h),
                      _buildQuranReadingCard(),
                      SizedBox(height: 16.h),
                      _buildNearbyMosquesCard(),
                      SizedBox(height: 16.h),
                      _buildDailyDuaCard(),
                      SizedBox(height: 16.h),
                      _buildQiblaCard(),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // App Bar - Full width light gray bar with search, filter, and location
  Widget _buildAppBar() {
    return BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
      builder: (context, state) {
        final bloc = context.read<PrayerTimesBloc>();
        final locationName = _extractCountryName(
            state.locationName.isNotEmpty ? state.locationName : 'الدوحة، قطر');
        final currentPrayer = bloc.getCurrentPrayerName();
        final timeUntilNext = bloc.formatTimeUntilNextPrayer();

        final theme = Theme.of(context);
        return Container(
          height: 60.h,
          width: double.infinity,
          color: theme.scaffoldBackgroundColor,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                // Right side - Location pin and text (RTL layout)
                Row(
                  children: [
                    SvgPicture.asset(
                      AssetsPath.locationSVG,
                      height: 20.sp,
                      width: 20.sp,
                      colorFilter: const ColorFilter.mode(
                        Colors.brown,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // RTL alignment
                      children: [
                        Text(
                          locationName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodyMedium?.color ??
                                Colors.grey[800],
                          ),
                          textAlign: TextAlign.right,
                        ),
                        Text(
                          '${currentPrayer.tr} ${"in".tr} $timeUntilNext',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.textTheme.bodySmall?.color ??
                                Colors.grey[600],
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                // Left side - Search and Filter icons (no containers)
                Row(
                  children: [
                    SvgPicture.asset(
                      AssetsPath.optionsSVG,
                      height: 24.sp,
                      width: 24.sp,
                      colorFilter: ColorFilter.mode(
                        theme.textTheme.titleMedium?.color ?? Colors.black87,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => SearchBloc(),
                              child: const SearchScreen(),
                            ),
                          ),
                        );
                      },
                      child: SvgPicture.asset(
                        AssetsPath.searchSVG,
                        height: 24.sp,
                        width: 24.sp,
                        colorFilter: ColorFilter.mode(
                          theme.textTheme.titleMedium?.color ?? Colors.black87,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _extractCountryName(String fullLocation) {
    // Split the location string by commas and get the last part (country)
    final parts = fullLocation.split(',');
    if (parts.isNotEmpty) {
      // Get the last part and trim whitespace
      final country = parts.last.trim();
      return country;
    }
    return fullLocation; // Return original if splitting fails
  }

  // Features Grid - Horizontal scrollable feature cards
  Widget _buildFeaturesGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: SizedBox(
        height: 78.h,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildHorizontalFeatureCard(
                'dua'.tr, AssetsPath.ad3iahSVG, () => _navigateToDuas()),
            SizedBox(width: 12.w),
            _buildHorizontalFeatureCard(
                'quran'.tr, AssetsPath.quranIconSVG, () => _navigateToQuran()),
            SizedBox(width: 12.w),
            _buildHorizontalFeatureCard(
                'qibla'.tr, AssetsPath.qblaIconSVG, () => _navigateToQibla()),
            SizedBox(width: 12.w),
            _buildHorizontalFeatureCard('tasbih'.tr, AssetsPath.tasbihcolordSVG,
                () => _navigateToTasbih()),
            SizedBox(width: 12.w),
            _buildHorizontalFeatureCard('calendar'.tr, AssetsPath.calendarSVG,
                () => _navigateToCalendar()),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalFeatureCard(
      String title, String svgAsset, VoidCallback? onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72.h,
        height: 78.h,
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: theme.dividerTheme.color ?? Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgAsset,
              width: 24.w,
              height: 24.h,
              colorFilter: const ColorFilter.mode(
                Color(0xFF8B1538), // Dark red color for icons
                BlendMode.srcIn,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyMedium?.color ??
                    Colors.grey[700], // Dark gray color for text
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Quran Reading Card
  Widget _buildQuranReadingCard() {
    final currentLanguage = Get.locale?.languageCode ?? 'en';
    return FutureBuilder<Map<String, dynamic>?>(
      key: ValueKey(
          'last_read_$currentLanguage'), // Force rebuild when language changes
      future: LastReadService.getLastRead(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: 328.w,
            height: 98.h,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xE0926B45),
                  Color(0xFF916B46),
                ],
                stops: [0.0755, 0.9885],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          );
        }

        final lastRead = snapshot.data;
        if (lastRead == null) {
          // Don't show the card if there's no last read data
          return const SizedBox.shrink();
        }

        final surahName = lastRead['surahName'] as String? ?? 'Unknown';
        final juzNumber = int.tryParse(lastRead['juzNumber'].toString()) ?? 1;
        final pageNumber = int.tryParse(lastRead['pageNumber'].toString()) ?? 1;
        final ayahNumber = int.tryParse(lastRead['ayahNumber'].toString()) ?? 1;

        return GestureDetector(
          onTap: () {
            // Navigate to the last read surah at the specific ayah
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuranReadingScreen(
                  surahName: surahName,
                  surahNumber: lastRead['surahNumber'],
                  startAyah: ayahNumber,
                  highlightAyah: ayahNumber, // Highlight the ayah when opening
                ),
              ),
            );
          },
          child: Container(
            width: 328.w,
            height: 98.h,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xE0926B45),
                  Color(0xFF916B46),
                ],
                stops: [0.0755, 0.9885],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background pattern image
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SvgPicture.asset(
                      AssetsPath.pannerbgSVG,
                      fit: BoxFit.fitWidth,
                      colorFilter: ColorFilter.mode(
                        Colors.white.withOpacity(0.08),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'last_read'.tr,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              surahName,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${"juz".tr} $juzNumber | ${"page".tr} $pageNumber',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'continue_reading'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Nearby Mosques Card
  Widget _buildNearbyMosquesCard() {
    final theme = Theme.of(context);
    return BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'nearby_mosques'.tr,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color:
                          theme.textTheme.titleMedium?.color ?? Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      // ✅ افتح صفحة عرض المساجد كلها على الخريطة
                      Get.to(() => NearbyMosquesMapScreen(
                            mosques: state.nearbyMosques,
                            userLat: state.userLat ?? 31.12,
                            userLng: state.userLng ?? 30.11,
                          ));
                    },
                    child: Row(
                      children: [
                        Text(
                          'more'.tr,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF8B1538),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            size: 12.sp, color: const Color(0xFF8B1538)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              SizedBox(
                height: 85.h,
                child: state.nearbyMosques.isEmpty
                    ? Center(
                        child: Text(
                          'loading_nearby_mosques'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.nearbyMosques.length,
                        itemBuilder: (context, index) {
                          final mosque = state.nearbyMosques[index];
                          return Padding(
                            padding: EdgeInsets.only(right: 12.w),
                            child: _buildMosqueCard(
                                mosqueName: mosque.name,
                                location: mosque.location,
                                distance: mosque.distance,
                                lat: mosque.latitude,
                                lng: mosque.longitude),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMosqueCard(
      {required String mosqueName,
      required String location,
      required String distance,
      required double lat,
      required double lng}) {
    final theme = Theme.of(context);
    return Container(
      width: 328.w,
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28.w,
              height: 28.h,
              decoration: BoxDecoration(
                color: const Color(0xFFECECEC), // #ECECEC background
                borderRadius: BorderRadius.circular(14), // Circular background
              ),
              child: Center(
                child: SvgPicture.asset(
                  AssetsPath.mousqSVG,
                  width: 16.w,
                  height: 16.h,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF8B1538), // Dark red color for icon
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mosqueName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          theme.textTheme.titleMedium?.color ?? Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    location,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color:
                          theme.textTheme.bodySmall?.color ?? Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => openLocationOnMap(lat, lng),
                    child: Row(
                      children: [
                        Text(
                          'get_directions'.tr,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF8B1538),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12.sp,
                          color: const Color(0xFF8B1538),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              distance,
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.textTheme.bodySmall?.color ?? Colors.grey[600],
              ),
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Future<void> openLocationOnMap(double lat, double lng) async {
    final googleUrl =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    final appleUrl = Uri.parse("http://maps.apple.com/?q=$lat,$lng");

    if (Platform.isIOS) {
      if (await canLaunchUrl(appleUrl)) {
        await launchUrl(appleUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(googleUrl)) {
        await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
      } else {
        throw "Could not launch map";
      }
    } else {
      if (await canLaunchUrl(googleUrl)) {
        await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
      } else {
        throw "Could not launch map";
      }
    }
  }

  // Daily Dua Card
  Widget _buildDailyDuaCard() {
    final theme = Theme.of(context);

    // Mood categories with emojis
    final List<MoodCategory> moodCategories = [
      MoodCategory(emoji: "😊", title: "happy".tr),
      MoodCategory(emoji: "😌", title: "grateful".tr),
      MoodCategory(emoji: "😭", title: "depressed".tr),
      MoodCategory(emoji: "😡", title: "angry".tr),
      MoodCategory(emoji: "😐", title: "anxious".tr),
      MoodCategory(emoji: "😠", title: "lazy".tr),
      MoodCategory(emoji: "😢", title: "lonely".tr),
      MoodCategory(emoji: "😵", title: "tired".tr),
      MoodCategory(emoji: "🤢", title: "suicidal".tr),
      MoodCategory(emoji: "😬", title: "nervous".tr),
      MoodCategory(emoji: "😥", title: "sad".tr),
      MoodCategory(emoji: "🙄", title: "jealous".tr),
    ];

    // Sample dua data with mood categories - you can replace this with actual data from your backend
    final List<Map<String, dynamic>> duas = [
      {
        'title': '1',
        'arabicText':
            'اَللّٰهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ زَوَالِ نِعْمَتِكَ، وَتَحَوُّلِ عَافِيَتِكَ، وَفُجَاءَةِ نِقْمَتِكَ، وَجَمِيعِ سَخَطِكَ',
        'englishText':
            'O Allah! I seek refuge in You from the decline of Your blessings, the passing of safety, the sudden onset of Your punishment and from all that displeases you.',
        'moodIndex': 0 // happy
      },
      {
        'title': '2',
        'arabicText': 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
        'englishText': 'I seek refuge in Allah from the accursed Satan',
        'moodIndex': 1 // grateful
      },
      {
        'title': '3',
        'arabicText': 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ',
        'englishText':
            'O Allah, send blessings upon Muhammad and the family of Muhammad',
        'moodIndex': 0 // happy
      },
      {
        'title': '4',
        'arabicText': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
        'englishText': 'Glory be to Allah and all praise is due to Him',
        'moodIndex': 1 // grateful
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'my_duas'.tr,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color ?? Colors.black87,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DuaaMainScreen(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'more'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF8B1538),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 12.sp, color: const Color(0xFF8B1538))
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 170.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: duas.length,
              itemBuilder: (context, index) {
                final dua = duas[index];
                final moodIndex = dua['moodIndex'] as int;
                final moodCategory = moodCategories[moodIndex];
                return Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: _buildDuaCard(
                    dua['title']!,
                    dua['arabicText']!,
                    dua['englishText']!,
                    moodCategory,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuaCard(String title, String arabicText, String englishText,
      MoodCategory moodCategory) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DuaaMainScreen(),
          ),
        );
      },
      child: Container(
        width: 280.w,
        decoration: BoxDecoration(
          color: theme.cardTheme.color ?? Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Mood icon in circular container
                  Container(
                    width: 28.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      color:
                          isDark ? Colors.grey[800] : const Color(0xFFECECEC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        moodCategory.emoji,
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Mood text with specified color
                  Text(
                    moodCategory.title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF8D1B3D),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: Text(
                  arabicText,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.bodyMedium?.color ?? Colors.black87,
                    height: 24 / 17, // line-height: 24px
                    fontFamily: 'IBM Plex Sans Arabic',
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                englishText,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: theme.textTheme.bodySmall?.color ?? Colors.grey[600],
                  height: 20 / 13, // line-height: 20px
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
                textAlign: TextAlign.justify,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Qibla Card
  Widget _buildQiblaCard() {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Separated title
          Text(
            'qibla'.tr,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleMedium?.color ?? Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          // Qibla card with map
          Container(
            height: 200.h,
            decoration: BoxDecoration(
              color: theme.cardTheme.color ?? Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BlocBuilder<QiblaBloc, QiblaState>(
                builder: (context, state) {
                  final bloc = context.read<QiblaBloc>();

                  // Debug prints (only in debug mode)
                  if (kDebugMode) {
                    print('Qibla State - isLoading: ${state.isLoading}');
                    print('Qibla State - error: ${state.error}');
                    print('Qibla State - latitude: ${state.latitude}');
                    print('Qibla State - longitude: ${state.longitude}');
                    print(
                        'Qibla State - qiblaDirection: ${state.qiblaDirection}');
                    print('Qibla State - isMapLoaded: ${state.isMapLoaded}');
                  }

                  return Stack(
                    children: [
                      // Map or loading state
                      _buildQiblaMap(state),
                      // Qibla compass overlay
                      if (state.qiblaDirection != null)
                        Positioned(
                          top: 16.h,
                          right: 16.w,
                          child: _buildQiblaCompass(state, bloc),
                        ),
                      // Location info overlay
                      Positioned(
                        bottom: 16.h,
                        left: 16.w,
                        right: 16.w,
                        child: _buildQiblaInfo(state, bloc),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQiblaCompass(QiblaState state, QiblaBloc bloc) {
    final theme = Theme.of(context);
    final direction = state.qiblaDirection ?? 0.0;
    final directionText = bloc.getDirectionText(direction);

    return Container(
      width: 50.w,
      height: 50.h,
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Transform.rotate(
          angle: direction * (3.14159 / 180),
          child: Icon(
            Icons.navigation,
            size: 24.sp,
            color: Colors.brown,
          ),
        ),
      ),
    );
  }

  Widget _buildQiblaInfo(QiblaState state, QiblaBloc bloc) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final direction = state.qiblaDirection;
    final directionText = direction != null
        ? bloc.getDirectionText(direction)
        : 'جاري التحميل...';
    final angleText =
        direction != null ? '(${direction.toStringAsFixed(1)}°)' : '';

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withOpacity(0.8)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.compass_calibration,
            size: 16.sp,
            color: Colors.brown,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اتجاه القبلة',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color:
                        theme.textTheme.titleSmall?.color ?? Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '$directionText $angleText',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: theme.textTheme.bodySmall?.color ?? Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.brown.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'القبلة',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.brown,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQiblaMap(QiblaState state) {
    if (kDebugMode) {
      print('Building Qibla Map with state:');
      print('- isLoading: ${state.isLoading}');
      print('- error: ${state.error}');
      print('- latitude: ${state.latitude}');
      print('- longitude: ${state.longitude}');
      print('- isMapLoaded: ${state.isMapLoaded}');
    }

    if (state.isLoading) {
      final theme = Theme.of(context);
      return Container(
        color: theme.scaffoldBackgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
              ),
              SizedBox(height: 8.h),
              Text(
                'جاري تحديد الموقع...',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.textTheme.bodySmall?.color ?? Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.error != null ||
        state.latitude == null ||
        state.longitude == null) {
      final theme = Theme.of(context);
      return Container(
        color: theme.scaffoldBackgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 32.sp,
                color: theme.textTheme.bodySmall?.color ?? Colors.grey[400],
              ),
              SizedBox(height: 8.h),
              Text(
                'لا يمكن تحديد الموقع',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.textTheme.bodySmall?.color ?? Colors.grey[400],
                ),
              ),
              if (state.error != null) ...[
                SizedBox(height: 8.h),
                Text(
                  'Error: ${state.error}',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.red[400],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    }

    // Use default coordinates for testing if the state coordinates are null
    final lat = state.latitude ?? 25.2854;
    final lng = state.longitude ?? 51.5310;

    // TEMPORARY: Use a simple container instead of Google Maps to test
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      key: ValueKey('qibla_map_${lat}_${lng}'),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: isDark ? Colors.blue[300]! : Colors.blue[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 48.sp,
              color: isDark ? Colors.blue[300] : Colors.blue[400],
            ),
            SizedBox(height: 8.h),
            Text(
              'خريطة القبلة',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.blue[300] : Colors.blue[700],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'خط العرض: ${lat.toStringAsFixed(4)}',
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? Colors.blue[300] : Colors.blue[600],
              ),
            ),
            Text(
              'خط الطول: ${lng.toStringAsFixed(4)}',
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? Colors.blue[300] : Colors.blue[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Navigation methods for feature cards
  void _navigateToDuas() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DuaaMainScreen(),
      ),
    );
  }

  void _navigateToTasbih() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TasbehScreen(),
      ),
    );
  }

  void _navigateToQibla() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QiblahScreen(),
      ),
    );
  }

  void _navigateToQuran() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QuranIndexScreen(),
      ),
    );
  }

  void _navigateToCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const IslamicCalendarScreen(),
      ),
    );
  }
}
