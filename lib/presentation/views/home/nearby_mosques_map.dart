import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:manara/data/models/mosque_model.dart';

import '../../../constants/images.dart';

class NearbyMosquesMapScreen extends StatefulWidget {
  final List<dynamic> mosques;
  final double userLat;
  final double userLng;

  const NearbyMosquesMapScreen({
    super.key,
    required this.mosques,
    required this.userLat,
    required this.userLng,
  });

  @override
  State<NearbyMosquesMapScreen> createState() => _NearbyMosquesMapScreenState();
}

class _NearbyMosquesMapScreenState extends State<NearbyMosquesMapScreen> {
  late GoogleMapController _mapController;
  MapType _mapType = MapType.normal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.userLat, widget.userLng),
              zoom: 14,
            ),
            markers: widget.mosques.map((m) {
              return Marker(
                markerId: MarkerId(m.name),
                position: LatLng(m.latitude, m.longitude),
                infoWindow: InfoWindow(title: m.name),
              );
            }).toSet(),
            mapType: _mapType,
            onMapCreated: (c) => _mapController = c,
          ),

          // ✅ Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 220,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.mosques.length,
                itemBuilder: (context, index) {
                  final mosque = widget.mosques[index];
                  return GestureDetector(
                    onTap: () {
                      _mapController.animateCamera(
                        CameraUpdate.newLatLng(
                          LatLng(mosque.latitude, mosque.longitude),
                        ),
                      );
                    },
                    child: Container(
                      width: 260,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[100],
                      ),
                      child: Column(
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
                                  mosque.name,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textTheme.titleMedium?.color ?? Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  mosque.location,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: theme.textTheme.bodySmall?.color ?? Colors.grey[600],
                                  ),
                                ),
                                const Spacer(),
                                InkWell(
                                  // onTap: ()=> openLocationOnMap(lat,lng),
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
                          // Padding(
                          //   padding: const EdgeInsets.all(8.0),
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Text(mosque.name, style: TextStyle(fontWeight: FontWeight.bold)),
                          //       Text(mosque.location, style: TextStyle(color: Colors.grey)),
                          //       Text("${mosque.distance} km", style: TextStyle(color: Colors.black54)),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ✅ زر لتغيير نوع الخريطة
          Positioned(
            top: 60,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              child: Icon(Icons.layers),
              onPressed: () {
                setState(() {
                  _mapType = _mapType == MapType.normal
                      ? MapType.satellite
                      : MapType.normal;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
