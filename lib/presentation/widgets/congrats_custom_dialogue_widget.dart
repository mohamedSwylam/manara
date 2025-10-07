import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../../constants/fonts_weights.dart';
import '../../constants/images.dart';

class CongratulationsCustomAlertDialogWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onContinuePressed;

  const CongratulationsCustomAlertDialogWidget({
    Key? key,
    required this.title,
    required this.message,
    required this.onContinuePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: SvgPicture.asset(AssetsPath.popupBGSVG, fit: BoxFit.cover,),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 16,
                left: 24,
                right: 24,
                bottom: 40,
              ),
              child: Column(
                children: [
                  Text(
                    title.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: AppColors.colorBlackHighEmp,
                      fontWeight: FontWeights.semiBold,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Text(
                    message.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.colorBlackMidEmp,
                      fontSize: 16.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeights.regular,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  SizedBox(
                    height: 52.h,
                    width: 140.w,
                    child: ElevatedButton(
                      onPressed: onContinuePressed,
                      child: Text(
                        'continue_btn_txt'.tr,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16.sp,
                          color: AppColors.colorBlackHighEmp,
                          fontWeight: FontWeights.semiBold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class SignInRequiredDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onContinuePressed;

  const SignInRequiredDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.onContinuePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: SvgPicture.asset(AssetsPath.popupBGSVG,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 16,
                left: 24,
                right: 24,
                bottom: 40,
              ),
              child: Column(
                children: [
                  Text(
                    title.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: AppColors.colorBlackHighEmp,
                      fontWeight: FontWeights.semiBold,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Text(
                    message.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.colorBlackMidEmp,
                      fontSize: 16.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeights.regular,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  SizedBox(
                    height: 52.h,

                    child: ElevatedButton(
                      onPressed: onContinuePressed,
                      child: Text(
                        'sign_in'.tr,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16.sp,
                          color: AppColors.colorBlackHighEmp,
                          fontWeight: FontWeights.semiBold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                    },
                      child: Text("skip".tr)
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
