import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:manara/constants/images.dart';
import 'package:sensors_plus/sensors_plus.dart' as sensors;

import '../../../data/bloc/qibla_bloc.dart';
import '../../../data/models/qibla_events.dart';
import '../../../data/models/qibla_state.dart';
import '../../widgets/qibla_compass_widget.dart';
import '../../widgets/qibla_map_widget.dart';

class QiblahScreen extends StatefulWidget {
  final bool hideBackButton;
  
  const QiblahScreen({Key? key, this.hideBackButton = false}) : super(key: key);

  @override
  State<QiblahScreen> createState() => _QiblahScreenState();
}

Animation<double>? animation;
AnimationController? _animationController;
double begin = 0.0;

class _QiblahScreenState extends State<QiblahScreen>
    with SingleTickerProviderStateMixin {
  StreamSubscription<dynamic>? _accelerometerSubscription;
  bool _accelerometerInitialized = false;
  int _selectedTabIndex = 0; // 0 for Compass, 1 for Map
  QiblaBloc? _qiblaBloc; // Store reference to BLoC
  
  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    animation = Tween(begin: 0.0, end: 0.0).animate(_animationController!);
    
    // Set up accelerometer detection with error handling
    _setupAccelerometerDetection();
    
    super.initState();
  }

  void _setupAccelerometerDetection() {
    if (_accelerometerInitialized) return;
    
    try {
      _accelerometerSubscription = sensors.accelerometerEvents.listen((event) {
        _checkPhoneFlatness(event);
      });
      _accelerometerInitialized = true;
    } catch (e) {
      // Fallback: assume phone is lying flat
      // This part of the logic needs to be adapted to work with the new QiblaBloc
      // For now, we'll just continue, as the QiblaBloc handles updates.
    }
  }

  void _checkPhoneFlatness(dynamic event) {
    try {
      // Check if phone is lying flat (Z-axis should be close to 9.8 m/s² when flat)
      // and X, Y should be close to 0 when flat on a surface
      double x = event.x.toDouble();
      double y = event.y.toDouble();
      double z = event.z.toDouble();
      
      // Check if phone is lying flat
      // Z-axis should be close to 9.8 m/s² when flat (gravity)
      // X and Y should be close to 0 when flat on a surface
      // More sensitive detection for better user experience
      bool isFlat = (z.abs() > 6.0 && x.abs() < 4.0 && y.abs() < 4.0);
      

      
      // Update BLoC state with phone flatness
      if (mounted && _qiblaBloc != null) {
        _qiblaBloc!.add(UpdatePhoneFlatness(isLyingFlat: isFlat));
      }
    } catch (e) {
      // Error handling for accelerometer data
      print('Error checking phone flatness: $e');
    }
  }

  void _showCalibrationBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 300.h,
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "calibrate_your_phone".tr,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.titleMedium?.color ?? const Color(0xFF424242),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: theme.textTheme.bodySmall?.color ?? const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              
              // Calibration diagram (infinity symbol)
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      AssetsPath.unionSVG,
                      width: 120.w,
                      height: 80.h,
                      colorFilter: ColorFilter.mode(
                        theme.textTheme.bodySmall?.color ?? const Color(0xFF666666),
                        BlendMode.srcIn,
                      ),
                    ),
                    Positioned(
                      right: 50.w,
                      top: 62.h,
                      child: SvgPicture.asset(
                        AssetsPath.unarrowSVG,
                        width: 20.w,
                        height: 20.h,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFE74C3C),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              
              // Instructions
              Text(
                "place_mobile_horizontally".tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: theme.textTheme.bodyMedium?.color ?? const Color(0xFF666666),
                  height: 1.4,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "recalibrate_eight_direction".tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: theme.textTheme.bodyMedium?.color ?? const Color(0xFF666666),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateDistanceToMakka(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return "0";
    
    // Kaaba coordinates (Mecca, Saudi Arabia)
    const double kaabaLat = 21.4225;
    const double kaabaLng = 39.8262;
    
    // Calculate distance using Haversine formula
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    double lat1 = latitude * pi / 180;
    double lng1 = longitude * pi / 180;
    double lat2 = kaabaLat * pi / 180;
    double lng2 = kaabaLng * pi / 180;
    
    double dLat = lat2 - lat1;
    double dLng = lng2 - lng1;
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;
    
    return distance.toInt().toString();
  }

  String _getDirectionText(double angle) {
    if (angle >= 337.5 || angle < 22.5) return 'N';
    if (angle >= 22.5 && angle < 67.5) return 'NE';
    if (angle >= 67.5 && angle < 112.5) return 'E';
    if (angle >= 112.5 && angle < 157.5) return 'SE';
    if (angle >= 157.5 && angle < 202.5) return 'S';
    if (angle >= 202.5 && angle < 247.5) return 'SW';
    if (angle >= 247.5 && angle < 292.5) return 'W';
    if (angle >= 292.5 && angle < 337.5) return 'NW';
    return 'N';
  }

  Future<void> _initializeLocation(QiblaBloc bloc) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // Initialize QiblaBloc with current location
      bloc.add(LoadQiblaDirection(
        latitude: position.latitude,
        longitude: position.longitude,
      ));
      
    } catch (e) {
      // Use default coordinates (Doha, Qatar) as fallback
      bloc.add(LoadQiblaDirection(
        latitude: 25.2854,
        longitude: 51.5310,
      ));
    }
  }

  @override
  void dispose() {
    // Dispose of the AnimationController
    _animationController?.dispose();
    
    // Dispose of accelerometer subscription
    _accelerometerSubscription?.cancel();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = QiblaBloc();
        // Initialize with current location
        _initializeLocation(bloc);
        return bloc;
      },
      child: BlocBuilder<QiblaBloc, QiblaState>(
        builder: (context, state) {
          // Setup accelerometer after BLoC is available (only once)
          final bloc = context.read<QiblaBloc>();
          _qiblaBloc = bloc; // Store BLoC reference
          
          if (!_accelerometerInitialized) {
            _setupAccelerometerDetection();
          }
          
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: PopScope(
              canPop: true,
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: 145.h,
                      child: SvgPicture.asset(
                        AssetsPath.pannerbgSVG,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        colorFilter: isDark
                            ? ColorFilter.mode(Colors.grey[600]!, BlendMode.srcIn)
                            : const ColorFilter.mode(Color(0xFFDFDFDF), BlendMode.srcIn),
                      ),
                    ),
                  ),
                  // Custom App Bar
                  Container(
                    color: theme.appBarTheme.backgroundColor,
                    padding: EdgeInsets.only(
                      top: 50.h,
                      left: 16.w,
                      right: 16.w,
                      bottom: 16.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (!widget.hideBackButton)
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: theme.iconTheme.color,
                                ),
                              ),
                            Text(
                              "qibla".tr,
                              style: TextStyle(
                                color: theme.textTheme.titleMedium?.color,
                                fontSize: 20.sp,
                                fontFamily: 'Barlow',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            // Show calibration bottom sheet
                            _showCalibrationBottomSheet(context);
                          },
                          icon: SvgPicture.asset(
                            AssetsPath.refreshSVG,
                            width: 24.w,
                            height: 24.h,
                            colorFilter: ColorFilter.mode(
                              theme.iconTheme.color ?? Colors.black,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                    // Main Content
                    Padding(
                      padding: EdgeInsets.only(top: 120.h),
                      child: Column(
                        children: [
                          // Location Card (Shared between tabs)
                          BlocBuilder<QiblaBloc, QiblaState>(
                            builder: (context, state) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                    top: 12.0, left: 16.0, right: 16.0),
                                child: Container(
                                  width: double.infinity,
                                  constraints:
                                  BoxConstraints(maxWidth: 350.w),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      color: theme.cardTheme.color,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]),
                                  child: Padding(
                                    padding: EdgeInsets.all(12.w),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "distance_to_qibla".tr,
                                              style: TextStyle(
                                                color: const Color(0xFF666666),
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              "${_calculateDistanceToMakka(state.latitude, state.longitude)} km",
                                              style: TextStyle(
                                                color: const Color(0xFF424242),
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "angle".tr,
                                              style: TextStyle(
                                                color: const Color(0xFF666666),
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              "${state.qiblahAngle?.abs().toInt() ?? 0}° ${_getDirectionText(state.qiblahAngle ?? 0)}",
                                              style: TextStyle(
                                                color: const Color(0xFF424242),
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 10.h,),
                          // Tab Bar
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16.w),
                            decoration: BoxDecoration(
                              color: theme.cardTheme.color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedTabIndex = 0),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 12.h),
                                      decoration: BoxDecoration(
                                        color: _selectedTabIndex == 0 
                                          ? theme.scaffoldBackgroundColor
                                          : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: _selectedTabIndex == 0 ? [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ] : null,
                                      ),
                                      child: Text(
                                        "compass".tr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: _selectedTabIndex == 0 
                                            ? theme.textTheme.titleMedium?.color ?? const Color(0xFF424242)
                                            : theme.textTheme.bodySmall?.color ?? const Color(0xFF666666),
                                          fontSize: 14.sp,
                                          fontWeight: _selectedTabIndex == 0 
                                            ? FontWeight.w600 
                                            : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedTabIndex = 1),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 12.h),
                                      decoration: BoxDecoration(
                                        color: _selectedTabIndex == 1 
                                          ? theme.scaffoldBackgroundColor
                                          : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: _selectedTabIndex == 1 ? [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ] : null,
                                      ),
                                      child: Text(
                                        "map".tr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: _selectedTabIndex == 1 
                                            ? theme.textTheme.titleMedium?.color ?? const Color(0xFF424242)
                                            : theme.textTheme.bodySmall?.color ?? const Color(0xFF666666),
                                          fontSize: 14.sp,
                                          fontWeight: _selectedTabIndex == 1 
                                            ? FontWeight.w600 
                                            : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Tab Content
                          Expanded(
                            child: IndexedStack(
                              index: _selectedTabIndex,
                              children: [
                                // Compass Tab
                                QiblaCompassWidget(
                                  animationController: _animationController,
                                  begin: begin,
                                ),
                                // Map Tab
                                const QiblaMapWidget(),
                              ],
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
      ),
    );
  }
}
