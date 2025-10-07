import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/colors.dart';
import '../../../constants/fonts_weights.dart';
import 'prayer_screen.dart';

class PrayerDemo extends StatelessWidget {
  const PrayerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Prayer Demo',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeights.semiBold,
            color: theme.textTheme.titleMedium?.color,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Prayer Screen Demo',
              style: GoogleFonts.poppins(
                fontSize: 24.sp,
                fontWeight: FontWeights.bold,
                color: AppColors.colorBlackHighEmp,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'This demonstrates the new prayer screen\nwith timeline view and prayer times\nusing BLoC pattern',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeights.medium,
                color: AppColors.colorBlackMidEmp,
              ),
            ),
            SizedBox(height: 40.h),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PrayerScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.colorPrimary,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Open Prayer Screen',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeights.medium,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
