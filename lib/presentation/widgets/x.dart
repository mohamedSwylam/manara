import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../../constants/images.dart';
import '../../data/bloc/prayer_times_bloc.dart';
import '../../data/models/prayer_times_events.dart';
import '../../data/models/prayer_times_model.dart';
import '../views/prayer/prayer_screen.dart';

class PrayerTimesCard extends StatefulWidget {
  const PrayerTimesCard({super.key});

  @override
  _PrayerTimesCardState createState() => _PrayerTimesCardState();
}

class _PrayerTimesCardState extends State<PrayerTimesCard> {
  @override
  void initState() {
    super.initState();
    // Don't load location here - it's already handled by the home screen BLoC
  }

  DateTime _getCurrentPrayerTime(PrayerTimesModel prayerTimes, String prayerName) {
    switch (prayerName) {
      case 'الصبح':
        return prayerTimes.fajr;
      case 'الشروق':
        return prayerTimes.sunrise;
      case 'الظهر':
        return prayerTimes.dhuhr;
      case 'العصر':
        return prayerTimes.asr;
      case 'المغرب':
        return prayerTimes.maghrib;
      case 'العشاء':
        return prayerTimes.isha;
      default:
        return prayerTimes.asr; // Default to Asr
    }
  }

  String _formatPrayerTime12Hour(DateTime prayerTime) {
    final hour = prayerTime.hour;
    final minute = prayerTime.minute;
    
    // Convert to 12-hour format
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    
    // Format as HH:MM
    final formattedTime = '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    
    return formattedTime;
  }

  String _getTimePeriod(DateTime prayerTime) {
    final hour = prayerTime.hour;
    
    // Morning: 6 AM to 11:59 AM
    if (hour >= 6 && hour < 12) {
      return 'am'.tr;
    }
    // Afternoon/Evening: 12 PM to 5:59 AM (next day)
    else {
      return 'pm'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        if (state.isLoading) {
          return Card(
            margin: const EdgeInsets.all(16),
            color: theme.cardTheme.color,
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (state.error != null) {
          return Card(
            margin: const EdgeInsets.all(16),
            color: theme.cardTheme.color,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'error'.tr + ': ${state.error}',
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Re-add location loading logic if needed, or rely on BLoC
                        // For now, just retry the prayer times load with default coordinates
                        context.read<PrayerTimesBloc>().add(LoadPrayerTimes(
                          latitude: 25.2854, // Default to Doha coordinates
                          longitude: 51.5310,
                        ));
                      },
                      child: Text('retry'.tr),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state.prayerTimes.isEmpty) {
          return Card(
            margin: const EdgeInsets.all(16),
            color: theme.cardTheme.color,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'no_prayer_times_available'.tr,
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
          );
        }

        final todayPrayerTimes = state.prayerTimes.first;
        final bloc = context.read<PrayerTimesBloc>();

        return Card(
          margin: const EdgeInsets.all(16),
          elevation: 4,
          color: theme.cardTheme.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.cardTheme.color ?? const Color(0xFFF8F9FA),
                  theme.cardTheme.color?.withOpacity(0.8) ?? const Color(0xFFE9ECEF),
                ],
              ),
            ),
            child: Column(
              children: [
                // Main content with padding
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Header with countdown and current prayer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Current prayer and date section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bloc.getCurrentPrayerName(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textTheme.titleLarge?.color ?? const Color(0xFF8B1538),
                                ),
                              ),
                              const SizedBox(height: 8),
                              //the Prayer time
                              Row(
                                children: [
                                  Text(
                                    _formatPrayerTime12Hour(_getCurrentPrayerTime(todayPrayerTimes, bloc.getCurrentPrayerName())),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: theme.textTheme.titleMedium?.color ?? Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getTimePeriod(_getCurrentPrayerTime(todayPrayerTimes, bloc.getCurrentPrayerName())),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: theme.textTheme.bodySmall?.color ?? Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'after'.tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.textTheme.bodySmall?.color ?? Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bloc.formatTimeUntilNextPrayer(),
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textTheme.titleLarge?.color ?? Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Divider(
                        color: theme.dividerTheme.color,
                      ),

                      // Prayer times grid
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('d MMMM y', 'ar').format(DateTime.now()),
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textTheme.bodySmall?.color ?? Colors.grey[600],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: _buildPrayerTimeItem('isha'.tr, AssetsPath.aleshaaSVG, bloc.formatPrayerTime(todayPrayerTimes.isha), _isNextPrayer('isha'.tr, bloc.getCurrentPrayerName()))),
                              Expanded(child: _buildPrayerTimeItem('magrib'.tr, AssetsPath.almaghribSVG, bloc.formatPrayerTime(todayPrayerTimes.maghrib), _isNextPrayer('maghrib'.tr, bloc.getCurrentPrayerName()))),
                              Expanded(child: _buildPrayerTimeItem('asr'.tr, AssetsPath.la3srSVG, bloc.formatPrayerTime(todayPrayerTimes.asr), _isNextPrayer('asr'.tr, bloc.getCurrentPrayerName()))),
                              Expanded(child: _buildPrayerTimeItem('duhr'.tr, AssetsPath.alzohrSVG, bloc.formatPrayerTime(todayPrayerTimes.dhuhr), _isNextPrayer('duhr'.tr, bloc.getCurrentPrayerName()))),
                              Expanded(child: _buildPrayerTimeItem('sunrise'.tr, AssetsPath.alfagrSVG, bloc.formatPrayerTime(todayPrayerTimes.sunrise), _isNextPrayer('sunrise'.tr, bloc.getCurrentPrayerName()))),
                              Expanded(child: _buildPrayerTimeItem('fajr'.tr, AssetsPath.alsobhSVG, bloc.formatPrayerTime(todayPrayerTimes.fajr), _isNextPrayer('fajr'.tr, bloc.getCurrentPrayerName()))),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Bottom section - More prayer times link
                GestureDetector(
                  onTap: () {
                    // Get the PrayerTimesBloc instance first
                    final prayerTimesBloc = context.read<PrayerTimesBloc>();
                    
                    // Navigate to the detailed prayer screen with existing PrayerTimesBloc
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: prayerTimesBloc,
                          child: const PrayerScreen(),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: const BoxDecoration(
                      color: Color(0xD5CCA133),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.keyboard_arrow_left,
                          color: Color(0xFF8B1538),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'more_prayer_times'.tr,
                          style: const TextStyle(
                            color: Color(0xFF8B1538),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrayerTimeItem(String name, String assetName, String time, bool isActive) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive ? (theme.cardTheme.color?.withOpacity(0.3) ?? const Color(0xFFF5F5DC)) : Colors.transparent, // Light beige background for active
        borderRadius: BorderRadius.circular(8),
        border: isActive ? Border.all(color: const Color(0xFFD5CCA1), width: 1) : null, // Dark red border for active
      ),
      child: Column(
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isActive ? const Color(0xFF8B1538) : (theme.textTheme.bodySmall?.color ?? Colors.grey[700]), // Dark red for active, grey for inactive
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SvgPicture.asset(
            assetName,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              isActive ? const Color(0xFFD5CCA1) : (theme.textTheme.bodySmall?.color ?? Colors.grey[600]!), // Dark red for active, grey for inactive
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? const Color(0xFF8B1538) : (theme.textTheme.bodySmall?.color ?? Colors.grey[600]), // Dark red for active, grey for inactive
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  bool _isNextPrayer(String prayerName, String currentPrayerName) {
    return prayerName == currentPrayerName;
  }
}
