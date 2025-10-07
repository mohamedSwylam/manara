import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../constants/images.dart';
import '../../../constants/localization/messages.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'about'.tr,
          style: TextStyle(
            color: theme.textTheme.titleMedium?.color,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Container with Gradient Background
            Container(
              width: double.infinity,
              height: 148.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF8D1B3D),
                    Color(0xFF80082C),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Panner Image
                  Positioned.fill(
                    child: SvgPicture.asset(
                      AssetsPath.aboutFrameSVG,
                      width: double.infinity,
                      height: 100.h,
                      // fit: BoxFit.cover,
                    ),
                  ),
                  // Logo in Center
                  Center(
                    child: SvgPicture.asset(
                      AssetsPath.aboutlogoSVG,
                      height: 100.h,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Title Text
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'about_us_title'.tr,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w700,
                  fontSize: 17.sp,
                  height: 24.h / 17.sp, // line-height: 24px
                  color: theme.textTheme.titleLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Description Text
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'about_us_description'.tr,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w400,
                  fontSize: 15.sp,
                  height: 20.h / 15.sp, // line-height: 20px
                  color: theme.textTheme.bodyMedium?.color,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
