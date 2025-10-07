import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/images.dart';
import '../../data/bloc/qibla_bloc.dart';
import '../../data/models/qibla_state.dart';

class QiblaMapWidget extends StatefulWidget {
  const QiblaMapWidget({Key? key}) : super(key: key);

  @override
  State<QiblaMapWidget> createState() => _QiblaMapWidgetState();
}

class _QiblaMapWidgetState extends State<QiblaMapWidget>
    with TickerProviderStateMixin {
  bool _isGlobalView = false;
  bool _showMeccaView = false;
  MapController? _mapController;

  // Animation controllers
  late AnimationController _waveController;
  late AnimationController _scaleController;
  late AnimationController _meccaViewController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _meccaViewAnimation;

  // Kaaba coordinates (Mecca, Saudi Arabia)
  static const LatLng kaabaLocation = LatLng(21.4225, 39.8262);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _mapController = MapController();
  }

  void _initializeAnimations() {
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _meccaViewController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _meccaViewAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _meccaViewController,
      curve: Curves.easeInOut,
    ));
  }

  void _toggleView() {
    setState(() {
      _isGlobalView = !_isGlobalView;
      _showMeccaView = false; // Reset Mecca view when toggling
    });

    // Trigger animations
    _scaleController.forward().then((_) => _scaleController.reverse());
    _waveController.forward().then((_) => _waveController.reset());

    // Update map view
    _updateMapView();
  }

  void _toggleMeccaView() {
    setState(() {
      _showMeccaView = !_showMeccaView;
    });

    if (_showMeccaView) {
      _meccaViewController.forward();
    } else {
      _meccaViewController.reverse();
    }

    // Update map view
    _updateMapView();
  }

  void _updateMapView() {
    if (_mapController == null) return;

    if (_showMeccaView) {
      _mapController!.move(kaabaLocation, 15.0);
    } else if (_isGlobalView) {
      // Fit camera to show both current location and Kaaba
      final currentLocation = LatLng(25.2854, 51.5310); // Default location
      final bounds = LatLngBounds.fromPoints([currentLocation, kaabaLocation]);
      _mapController!.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50),
        ),
      );
    } else {
      // Local view - show current location
      final currentLocation = LatLng(25.2854, 51.5310); // Default location
      _mapController!.move(currentLocation, 12.0);
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _scaleController.dispose();
    _meccaViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<QiblaBloc, QiblaState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: theme.scaffoldBackgroundColor,
            ),
          );
        }

        if (state.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48.sp,
                  color: theme.textTheme.bodyMedium?.color,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Error loading map',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          );
        }

        if (state.latitude == null || state.longitude == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off,
                  size: 48.sp,
                  color: theme.textTheme.bodyMedium?.color,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Location not available',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          );
        }

        LatLng currentLocation = LatLng(state.latitude!, state.longitude!);

        return Stack(
          children: [
            // Main Map using flutter_map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _showMeccaView
                    ? kaabaLocation
                    : (_isGlobalView
                        ? LatLng(
                            (currentLocation.latitude +
                                    kaabaLocation.latitude) /
                                2,
                            (currentLocation.longitude +
                                    kaabaLocation.longitude) /
                                2)
                        : currentLocation),
                initialZoom:
                    _showMeccaView ? 15.0 : (_isGlobalView ? 3.0 : 12.0),
                onMapReady: () {
                  if (!_showMeccaView) {
                    _updateMapView();
                  }
                },
              ),
              children: [
                // OpenStreetMap tiles
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.manara.app',
                  additionalOptions: const {
                    'User-Agent': 'ManaraApp/1.0 (contact: support@manara.app)'
                  },
                ),
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.manara.app',
                  additionalOptions: const {
                    'User-Agent': 'ManaraApp/1.0 (contact: support@manara.app)'
                  },
                ),

                // Current location marker (only show if not in Mecca view)
                if (!_showMeccaView)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: currentLocation,
                        width: 50,
                        height: 50,
                        child: Transform.rotate(
                          angle: ((state.qiblahAngle ?? 0) - 30) * (pi / 180),
                          child: SvgPicture.asset(
                            AssetsPath.qiblaarrowSVG,
                            width: 50,
                            height: 50,
                          ),
                        ),
                      ),
                    ],
                  ),

                // Kaaba marker (always show)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: kaabaLocation,
                      width: _showMeccaView ? 50 : 40,
                      height: _showMeccaView ? 50 : 40,
                      child: Transform.rotate(
                        angle: 0, // No rotation for Kaaba marker
                        child: Image.asset(
                          AssetsPath.makkaENBPNG,
                          width: _showMeccaView ? 50 : 40,
                          height: _showMeccaView ? 50 : 40,
                        ),
                      ),
                    ),
                  ],
                ),

                // Qibla direction line (only show if not in Mecca view)
                if (!_showMeccaView)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _buildGreatCirclePath(
                            kaabaLocation, currentLocation,
                            segments: 64),
                        strokeWidth: 3,
                        color: const Color(0xFFE74C3C),
                      ),
                    ],
                  ),
              ],
            ),

            // Mini Mecca Map Circle (Bottom Left)
            Positioned(
              bottom: 20.h,
              left: 20.w,
              child: GestureDetector(
                onTap: () {
                  _toggleMeccaView();
                },
                child: AnimatedBuilder(
                  animation:
                      Listenable.merge([_scaleAnimation, _meccaViewAnimation]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 80.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.cardTheme.color,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Stack(
                            children: [
                              // Mini map showing dynamic location
                              FlutterMap(
                                key: ValueKey(
                                    _showMeccaView), // Force rebuild when state changes
                                options: MapOptions(
                                  initialCenter: _showMeccaView
                                      ? currentLocation
                                      : kaabaLocation,
                                  initialZoom: 10,
                                  keepAlive: false,
                                  onTap: (tapPosition, point) {
                                    // Toggle Mecca view on tap
                                    _toggleMeccaView();
                                  },
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.example.app',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: _showMeccaView
                                            ? currentLocation
                                            : kaabaLocation,
                                        width: 40,
                                        height: 40,
                                        child: _showMeccaView
                                            ? Transform.rotate(
                                                angle:
                                                    ((state.qiblahAngle ?? 0) -
                                                            30) *
                                                        (pi / 180),
                                                child: SvgPicture.asset(
                                                  AssetsPath.qiblaarrowSVG,
                                                  width: 40,
                                                  height: 40,
                                                ),
                                              )
                                            : Image.asset(
                                                AssetsPath.makkaENBPNG,
                                                width: 40,
                                                height: 40,
                                              ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // Overlay with close icon when in Mecca view
                              if (_showMeccaView)
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE74C3C)
                                        .withOpacity(0.8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // View Mode Toggle (Bottom Right)
            Positioned(
              bottom: 20.h,
              right: 20.w,
              child: GestureDetector(
                onTap: _toggleView,
                child: Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.cardTheme.color,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _isGlobalView ? Icons.my_location : Icons.map,
                      color: const Color(0xFFE74C3C),
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
            ),

            // View Mode Indicator
            Positioned(
              bottom: 110.h,
              left: 20.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  _showMeccaView
                      ? 'Mecca View'
                      : (_isGlobalView ? 'Global' : 'Local'),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyMedium?.color ??
                        const Color(0xFF424242),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Great-circle path between two points using spherical linear interpolation (slerp)
  List<LatLng> _buildGreatCirclePath(LatLng start, LatLng end,
      {int segments = 64}) {
    final List<LatLng> points = [];

    double lat1 = start.latitude * (pi / 180.0);
    double lon1 = start.longitude * (pi / 180.0);
    double lat2 = end.latitude * (pi / 180.0);
    double lon2 = end.longitude * (pi / 180.0);

    final double d = _centralAngle(lat1, lon1, lat2, lon2);
    if (d == 0) return [start, end];

    for (int i = 0; i <= segments; i++) {
      final double f = i / segments;
      final double A = sin((1 - f) * d) / sin(d);
      final double B = sin(f * d) / sin(d);

      final double x = A * cos(lat1) * cos(lon1) + B * cos(lat2) * cos(lon2);
      final double y = A * cos(lat1) * sin(lon1) + B * cos(lat2) * sin(lon2);
      final double z = A * sin(lat1) + B * sin(lat2);

      final double newLat = atan2(z, sqrt(x * x + y * y));
      final double newLon = atan2(y, x);

      points.add(LatLng(newLat * (180.0 / pi), newLon * (180.0 / pi)));
    }

    return points;
  }

  double _centralAngle(double lat1, double lon1, double lat2, double lon2) {
    return acos(
        sin(lat1) * sin(lat2) + cos(lat1) * cos(lat2) * cos(lon2 - lon1));
  }
}
