import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../../constants/fonts_weights.dart';
import '../../constants/images.dart';
import '../../data/viewmodel/navigation_controller.dart';
import '../widgets/app_background_image_widget.dart';


class LocationAccessScreen extends StatelessWidget {
  const LocationAccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AppBackgroundImageWidget(
              bgImagePath: AssetsPath.backgroundLocationSVG),
          Positioned(
            left: 0,
            right: 0,
            bottom: 50,
            child: Center(
              child: SizedBox(
                width: 150.w,
                height: 46.h,
                child: ElevatedButton(
                  onPressed: () async {
                    await NavigationController.getAppInstallValue();
                    // if (NavigationController.isFirstTimeOpening ?? true) {
                    //   await NavigationController.setAppInstallValue(false);
                    //   Get.offAll(() => SignUpScreen());
                    // } else {
                    //   Get.offAll(() => SignInScreen());
                    // }
                  },
                  child: Text(
                    'get_location'.tr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.colorBlackHighEmp,
                      fontWeight: FontWeights.semiBold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
