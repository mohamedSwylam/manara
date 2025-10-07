import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../constants/fonts_weights.dart';
import '../../../constants/images.dart';
import '../../../data/bloc/location_settings/location_settings_bloc.dart';
import '../../../data/bloc/prayer_settings/prayer_settings_bloc.dart';
import '../../../data/services/location_service.dart';
import '../../widgets/custom_toast_widget.dart';

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load location settings when screen initializes
    context.read<LocationSettingsBloc>().add(LoadLocationSettings());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.iconTheme.color,
            size: 24.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'location_settings'.tr,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeights.semiBold,
            color: theme.textTheme.titleMedium?.color,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<LocationSettingsBloc, LocationSettingsState>(
        listener: (context, state) {
          if (state is LocationSettingsError) {
            CustomToastWidget.show(
              context: context,
              title: state.message,
              iconPath: AssetsPath.logo00102PNG,
              iconBackgroundColor: const Color(0xFFE33C3C),
              backgroundColor: const Color(0xFFFFEFE8),
            );
          }
        },
        child: BlocBuilder<LocationSettingsBloc, LocationSettingsState>(
          builder: (context, state) {
            if (state is LocationSettingsInitial || state is LocationSettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is LocationSettingsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.sp,
                      color: Colors.red,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      state.message,
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        context.read<LocationSettingsBloc>().add(LoadLocationSettings());
                      },
                      child: Text('retry'.tr),
                    ),
                  ],
                ),
              );
            }

            if (state is LocationSettingsLoaded) {
              return Stack(
                children: [
                  _buildContent(context, state),
                  // Loading overlay - only show when getting current location
                  if (state.isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.all(24.w),
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 24.sp,
                                height: 24.sp,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    const Color(0xFF8D1B3D),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),
                                                             Text(
                                 'finding_your_location'.tr,
                                 style: GoogleFonts.poppins(
                                   fontSize: 16.sp,
                                   fontWeight: FontWeights.medium,
                                   color: theme.textTheme.bodyMedium?.color,
                                 ),
                               ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, LocationSettingsLoaded state) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Auto-detect Location Toggle
                _buildAutoDetectToggle(context, state),
                
                SizedBox(height: 16.h),
                
                // Only show manual location options if auto-detect is OFF
                if (!state.autoDetectEnabled) ...[
                  // Get My Location Button
                  _buildGetMyLocationButton(context, state),
                  
                  SizedBox(height: 16.h),
                  
                  // Current/Selected Location Display
                  if (state.selectedLocation.isNotEmpty)
                    _buildCurrentLocationDisplay(context, state),
                  
                  SizedBox(height: 16.h),
                  
                  // Search Location
                  _buildSearchLocation(context, state),
                  
                  SizedBox(height: 16.h),
                  
                  // Search Results
                  if (state.searchResults.isNotEmpty)
                    _buildSearchResults(context, state),
                ],
              ],
            ),
          ),
        ),
        
        // Save Button
        _buildSaveButton(context, state),
      ],
    );
  }

  Widget _buildAutoDetectToggle(BuildContext context, LocationSettingsLoaded state) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'auto_detect_location'.tr,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeights.semiBold,
              color: theme.textTheme.titleMedium?.color,
            ),
          ),
          Switch(
            value: state.autoDetectEnabled,
            onChanged: (value) {
              context.read<LocationSettingsBloc>().add(ToggleAutoDetectLocation(value));
            },
            activeColor: const Color(0xFF8D1B3D),
          ),
        ],
      ),
    );
  }

  Widget _buildGetMyLocationButton(BuildContext context, LocationSettingsLoaded state) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: state.isLoading ? null : () {
          context.read<LocationSettingsBloc>().add(GetCurrentLocation());
        },
        child: Row(
          children: [
            SvgPicture.asset(
              AssetsPath.locationSVG,
              width: 24.sp,
              height: 24.sp,
              colorFilter: const ColorFilter.mode(Color(0xFFE33C3C), BlendMode.srcIn),
            ),
            SizedBox(width: 12.w),
            Text(
              'get_my_location'.tr,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeights.medium,
                color: const Color(0xFFE33C3C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLocationDisplay(BuildContext context, LocationSettingsLoaded state) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFF8D1B3D).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: const Color(0xFF8D1B3D),
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'current_location'.tr,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeights.medium,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  state.selectedLocation,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeights.semiBold,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: const Color(0xFF8D1B3D),
            size: 20.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchLocation(BuildContext context, LocationSettingsLoaded state) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'select_location'.tr,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeights.semiBold,
              color: theme.textTheme.titleMedium?.color,
            ),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'type_city_name'.tr,
              hintStyle: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: theme.textTheme.bodySmall?.color,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: theme.textTheme.bodySmall?.color,
                size: 20.sp,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: theme.dividerTheme.color ?? Colors.grey[300]!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: theme.dividerTheme.color ?? Colors.grey[300]!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(
                  color: Color(0xFF8D1B3D),
                ),
              ),
              filled: true,
              fillColor: theme.cardTheme.color,
            ),
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: theme.textTheme.bodyMedium?.color,
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                context.read<LocationSettingsBloc>().add(SearchLocation(value));
              } else {
                context.read<LocationSettingsBloc>().add(SearchLocation(''));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, LocationSettingsLoaded state) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: state.searchResults.map((location) {
          return GestureDetector(
            onTap: () {
              context.read<LocationSettingsBloc>().add(SelectLocation(location));
              _searchController.clear();
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerTheme.color ?? Colors.grey[300]!,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: theme.textTheme.bodySmall?.color,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      location.name,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeights.medium,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: theme.textTheme.bodySmall?.color,
                    size: 16.sp,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, LocationSettingsLoaded state) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      child: ElevatedButton(
        onPressed: () async {
          // Update global location service (this will notify all screens)
          final locationService = Provider.of<LocationService>(context, listen: false);
          await locationService.updateLocation(
            state.selectedLocation,
            state.selectedLatitude,
            state.selectedLongitude,
          );

          // Update prayer settings bloc
          context.read<PrayerSettingsBloc>().add(UpdateLocation(state.selectedLocation));

          // Show success message and pop back
          CustomToastWidget.show(
            context: context,
            title: 'location_saved'.tr,
            iconPath: AssetsPath.logo00102PNG,
            iconBackgroundColor: const Color(0xFF8D1B3D),
            backgroundColor: const Color(0xFFFFEFE8),
          );
          
          // Pop back to previous screen
          Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8D1B3D),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h),
        ),
        child: Text(
          'save'.tr,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeights.medium,
          ),
        ),
      ),
    );
  }
}
