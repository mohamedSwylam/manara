import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:manara/presentation/views/auth/reset_password_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../constants/colors.dart';
import '../../../constants/fonts_weights.dart';
import '../../../constants/images.dart';
import '../../../data/viewmodel/auth/verify_otp_screen_controller.dart';
import '../../widgets/app_background_image_widget.dart';
import '../../widgets/custom_appbar_widget.dart';
import '../../widgets/functions_and_methods.dart';
import '../../widgets/loading_popup_widget.dart';

class VerifyOtpScreen extends StatelessWidget {
  VerifyOtpScreen({super.key, required this.email});

  final String email;

  final TextEditingController otpTEController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          AppBackgroundImageWidget(bgImagePath: AssetsPath.background03SVG),
          // Custom Appbar
          CustomAppbarWidget(screenTitle: 'verify_otp'.tr),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 16.h),
                    // Pin code design section
                    _buildPinInputField(context),
                    SizedBox(height: 32.h),
                    _buildSubmitButton(context),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'otp_field_title'.tr,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16.sp,
          color: AppColors.backgroundColor,
        ),
      ),
    );
  }

  Widget _buildPinInputField(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      length: 4,
      obscureText: false,
      animationType: AnimationType.fade,
      pinTheme: PinTheme(
        selectedFillColor: AppColors.colorPrimaryLighter,
        borderWidth: 0,
        activeBorderWidth: 0,
        selectedBorderWidth: 0,
        inactiveColor: AppColors.backgroundColor,
        inactiveFillColor: AppColors.backgroundColor,
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(8),
        fieldHeight: 52.h,
        fieldWidth: 50.80.w,
        activeFillColor: AppColors.backgroundColor,
      ),
      animationDuration: const Duration(milliseconds: 300),
      enableActiveFill: true,
      controller: otpTEController,
      onCompleted: (v) {
        print("Completed = $v");
      },
      onChanged: (value) {},
      beforeTextPaste: (text) {
        print("Allowing to paste $text");
        return true;
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return GetBuilder<OtpVerificationController>(
        builder: (otpVerificationController) {
      // Elevated button
      return SizedBox(
        height: 54.h,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            checkFormErrors(otpVerificationController, context);
            print(otpTEController.text.toString());
          },
          child: Text(
            'continue_btn_txt'.tr,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: AppColors.colorBlackHighEmp,
                fontWeight: FontWeights.semiBold),
          ),
        ),
      );
    });
  }

  //Form error checking method
  void checkFormErrors(
      OtpVerificationController controller, BuildContext context) {
    if (otpTEController.text.length == 4) {
      // Loading indicator method
      showLoadingDialog(context);
      // Forgot password method
      verifyOTP(controller);
    } else {
      makeSnack('incomplete_otp'.tr);
    }
  }

  // Loading indicator
  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const LoadingPopupWidget();
      },
    );
  }

  // Signup method
  Future<void> verifyOTP(OtpVerificationController controller) async {
    final response =
        await controller.verifyOtp(email, otpTEController.text.trim());
    print(response);
    if (response) {
      Get.back();
      // Navigate to reset password screen
      // Get.to(() => ResetPasswordScreen(
      //       email: email,
      //       otp: otpTEController.text.trim(),
      //     ));
    } else {
      Get.back();
      makeSnack(controller.message);
    }
  }
}
