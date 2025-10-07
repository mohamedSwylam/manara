import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../../constants/colors.dart';
import '../../data/viewmodel/Providers/location_provider.dart';

class NextPrayerCardWidget extends StatefulWidget {
  const NextPrayerCardWidget({Key? key}) : super(key: key);

  @override
  State<NextPrayerCardWidget> createState() => _NextPrayerCardWidgetState();
}

class _NextPrayerCardWidgetState extends State<NextPrayerCardWidget> {
  Timer? _timer;
  Duration _timeRemaining = Duration.zero;
  String _nextPrayerName = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeRemaining();
    });
  }

  void _updateTimeRemaining() {
    final provider = Provider.of<LocationProvider>(context, listen: false);
    if (provider.prayerTimes == null || provider.prayerTimes!.isEmpty) return;

    final now = DateTime.now();
    final prayerTimes = provider.prayerTimes![0];
    
    // Get all prayer times for today
    final today = DateTime(now.year, now.month, now.day);
    final fajr = today.add(Duration(hours: prayerTimes.fajr.hour, minutes: prayerTimes.fajr.minute));
    final sunrise = today.add(Duration(hours: prayerTimes.sunrise.hour, minutes: prayerTimes.sunrise.minute));
    final dhuhr = today.add(Duration(hours: prayerTimes.dhuhr.hour, minutes: prayerTimes.dhuhr.minute));
    final asr = today.add(Duration(hours: prayerTimes.asr.hour, minutes: prayerTimes.asr.minute));
    final maghrib = today.add(Duration(hours: prayerTimes.maghrib.hour, minutes: prayerTimes.maghrib.minute));
    final isha = today.add(Duration(hours: prayerTimes.isha.hour, minutes: prayerTimes.isha.minute));

    // Find next prayer
    DateTime? nextPrayer;
    String prayerName = '';

    if (now.isBefore(fajr)) {
      nextPrayer = fajr;
      prayerName = 'fajr'.tr;
    } else if (now.isBefore(sunrise)) {
      nextPrayer = sunrise;
      prayerName = 'sunrise'.tr;
    } else if (now.isBefore(dhuhr)) {
      nextPrayer = dhuhr;
      prayerName = 'dhuhr'.tr;
    } else if (now.isBefore(asr)) {
      nextPrayer = asr;
      prayerName = 'asr'.tr;
    } else if (now.isBefore(maghrib)) {
      nextPrayer = maghrib;
      prayerName = 'maghrib'.tr;
    } else if (now.isBefore(isha)) {
      nextPrayer = isha;
      prayerName = 'isha'.tr;
    } else {
      // If all prayers passed, next prayer is tomorrow's fajr
      nextPrayer = fajr.add(const Duration(days: 1));
      prayerName = 'fajr'.tr;
    }

    if (mounted) {
      setState(() {
        _timeRemaining = nextPrayer!.difference(now);
        _nextPrayerName = prayerName;
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'next_prayer'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  _nextPrayerName,
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  _formatDuration(_timeRemaining),
                  style: TextStyle(
                    fontSize: 20.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.access_time,
              color: Colors.white,
              size: 32.sp,
            ),
          ),
        ],
      ),
    );
  }
} 
