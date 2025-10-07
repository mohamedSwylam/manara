import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/fonts_weights.dart';
import '../../../../constants/images.dart';
import '../../../widgets/app_background_image_widget.dart';
import '../../../widgets/custom_appbar_widget.dart';


class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AppBackgroundImageWidget(
            bgImagePath: AssetsPath.secondaryBGSVG,
          ),
          const CustomAppbarWidget(screenTitle: 'about_us'),
          Padding(
            padding: EdgeInsets.only(top: 97.h, left: 16.h, right: 16.h, bottom: 16.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 24.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: AppColors.colorPrimaryLight,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'about_us'.tr,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                        color: AppColors.colorWhiteHighEmp,
                        fontSize: 14.sp,
                        fontWeight: FontWeights.semiBold),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'about1'.tr,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                        color: AppColors.colorWhiteMidEmp,
                        fontSize: 12.sp,
                        fontWeight: FontWeights.regular),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'about2'.tr,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                        color: AppColors.colorWhiteMidEmp,
                        fontSize: 12.sp,
                        fontWeight: FontWeights.regular),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'about3'.tr,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                        color: AppColors.colorWhiteMidEmp,
                        fontSize: 12.sp,
                        fontWeight: FontWeights.regular),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
