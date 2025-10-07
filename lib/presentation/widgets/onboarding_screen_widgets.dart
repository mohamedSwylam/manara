import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../../constants/images.dart';


class OnboardingScreenWidgets extends StatelessWidget {
  const OnboardingScreenWidgets({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.textTitle,
    required this.textDescription,
    required this.onTap,
    required this.bgPath,
    // required this.bgContentImagePath,
  }) : super(key: key);

  final int currentPage;
  final int totalPages;
  final VoidCallback onTap;

  final String bgPath;
  // final String bgContentImagePath;
  final String textTitle;
  final String textDescription;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: SvgPicture.asset(
            bgPath,
            fit: BoxFit.cover,
          ),
        ),

        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SizedBox(height: 442.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(totalPages, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3.0),
                      height: 8.h,
                      width: (index == currentPage) ? 32.w : 16.w,
                      decoration: BoxDecoration(
                        color: (index == currentPage)
                            ? AppColors.indicatorColor
                            : AppColors.colorPrimaryLightest,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                      ),
                    );
                  }),
                ),
                SizedBox(
                  height: 30.h,
                ),
                Text(
                  textTitle.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.colorWhiteHighEmp,
                      height: 1),
                ),
                SizedBox(height: 20.h),
                Text(
                  textDescription.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.colorWhiteHighEmp,
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: onTap,
                    child: SvgPicture.asset(
                      AssetsPath.onboardingButtonSVG,
                      height: 48.h,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
