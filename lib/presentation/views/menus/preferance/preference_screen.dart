import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:manara/presentation/views/menus/preferance/change_language_screen.dart';
import 'package:manara/presentation/views/menus/preferance/privacy_policy_screen.dart';

import '../../../../constants/colors.dart';
import '../../../../constants/fonts_weights.dart';
import '../../../../constants/images.dart';
import 'about_us_screen.dart';

class PreferenceScreen extends StatefulWidget {
  const PreferenceScreen({super.key});

  @override
  State<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.colorGradient1Start,
              AppColors.colorGradient1End
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 50.h),
            Row(
              children: [
                SizedBox(width: 20.h),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back,
                    size: 22.sp,
                    color: AppColors.colorWhiteHighEmp,
                  ),
                ),
                SizedBox(width: 10.h),
                Text(
                  'preference'.tr,
                  style: TextStyle(
                      fontSize: 18.sp,
                      color: AppColors.colorWhiteHighEmp,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ---- Language change---- //
                  InkWell(
                    onTap: () {
                      Get.to(
                          () => const ChangeLanguageScreen(backButton: true));
                    },
                    child: Container(
                      height: 110.h,
                      width: 102.w,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.colorWhiteHighEmp),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            AssetsPath.changeLanguageIconPNG,
                            height: 32.h,
                            width: 32.w,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'change_language'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                height: 0.9.h,
                                color: AppColors.colorBlackHighEmp,
                                fontSize: 13.sp,
                                fontWeight: FontWeights.semiBold),
                          )
                        ],
                      ),
                    ),
                  ),
                  // ---- Privacy Policy Screen ---- //
                  InkWell(
                    onTap: () {
                      Get.back();
                      Get.to(() => const PrivacyPolicyScreen(
                          privacyPolicyUrl:
                              'https://www.privacypolicygenerator.info/live.php?token=MGD6TLNVqn9yVlzsAyTY3Mh4hlF0toZb'));
                    },
                    child: Container(
                      height: 110.h,
                      width: 102.w,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.colorWhiteHighEmp),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            AssetsPath.policyIconPNG,
                            height: 32.h,
                            width: 32.w,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'privacy_policy'.tr,
                            style: TextStyle(
                                color: AppColors.colorBlackHighEmp,
                                fontSize: 13.sp,
                                fontWeight: FontWeights.semiBold),
                          )
                        ],
                      ),
                    ),
                  ),
                  // ---- About Us Screen ---- //
                  InkWell(
                    onTap: () {
                      Get.back();
                      Get.to(() => const AboutUsScreen());
                    },
                    child: Container(
                      height: 110.h,
                      width: 102.w,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.colorWhiteHighEmp),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            AssetsPath.aboutUsIconPNG,
                            height: 32.h,
                            width: 32.w,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'about_us'.tr,
                            style: TextStyle(
                                color: AppColors.colorBlackHighEmp,
                                fontSize: 14.sp,
                                fontWeight: FontWeights.semiBold),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
