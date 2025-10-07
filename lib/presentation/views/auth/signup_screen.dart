import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:manara/constants/colors.dart';
import 'package:manara/presentation/views/auth/signin_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../constants/fonts_weights.dart';
import '../../../constants/images.dart';
import '../../../data/viewmodel/auth/signup_screen_controller.dart';
import '../../widgets/app_background_image_widget.dart';
import '../../widgets/congrats_custom_dialogue_widget.dart';
import '../../widgets/form_field_widget.dart';
import '../../widgets/functions_and_methods.dart';
import '../../widgets/loading_popup_widget.dart';
import '../home/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key? key, required this.isParent}) : super(key: key);
  final bool isParent;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameTEController = TextEditingController();

  final TextEditingController emailTEController = TextEditingController();

  final TextEditingController passwordTEController = TextEditingController();

  final TextEditingController confirmPasswordTEController =
      TextEditingController();

  String userAdId = '';

  void getAndSaveDeviceId() async {
    userAdId = OneSignal.User.pushSubscription.id!;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAndSaveDeviceId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          AppBackgroundImageWidget(bgImagePath: AssetsPath.background03SVG),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                SizedBox(height: 116.h),
                _buildHeader(),
                SizedBox(height: 24.h),
                // Form section
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildInputField(),
                        SizedBox(height: 32.h),
                        _buildSubmitButton(context),
                        SizedBox(height: 20.h),
                        _buildToSignIn(),
                        SizedBox(height: 50.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Text(
            'signup_title'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24.sp,
              fontWeight: FontWeights.semiBold,
              color: AppColors.backgroundColor,
            ),
          ),
          SizedBox(
            height: 8.h,
          ),
          Text(
            'signup_subtitle'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16.sp,
              color: AppColors.backgroundColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Column(
      children: [
        FormFieldWidget(
          formTitle: 'auth_name'.tr,
          hintText: 'auth_name_hint'.tr,
          controller: nameTEController,
          keyboardType: TextInputType.text,
        ),
        SizedBox(height: 16.h),
        FormFieldWidget(
          formTitle: 'auth_email'.tr,
          hintText: 'example@domain.com'.tr,
          controller: emailTEController,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16.h),
        FormFieldWidget(
          formTitle: 'auth_password'.tr,
          hintText: '****************',
          controller: passwordTEController,
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
        ),
        SizedBox(height: 16.h),
        FormFieldWidget(
          formTitle: 'auth_confirm_password'.tr,
          hintText: '****************',
          controller: confirmPasswordTEController,
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
        )
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return GetBuilder<SignUpScreenController>(
        builder: (signUpScreenController) {
      return SizedBox(
        height: 54.h,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            FocusScope.of(context).requestFocus(FocusNode());
            checkFormErrors(context, signUpScreenController);
          },
          child: Text(
            'sign_up'.tr,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16.sp,
                color: AppColors.colorBlackHighEmp,
                fontWeight: FontWeights.semiBold),
          ),
        ),
      );
    });
  }

  Widget _buildToSignIn() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'already_have_account'.tr,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16.sp,
              color: AppColors.backgroundColor,
            ),
          ),
          const WidgetSpan(
            child: SizedBox(width: 5),
          ),
          TextSpan(
            text: 'sign_in'.tr,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.colorPrimaryLighter,
              fontFamily: 'Poppins',
              fontWeight: FontWeights.semiBold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                widget.isParent
                    ? Get.to(() => SignInScreen(
                          isParent: false,
                        ))
                    : Get.offAll(() => SignInScreen(
                          isParent: true,
                        ));
              },
          ),
        ],
      ),
    );
  }

  //Form error checking method
  void checkFormErrors(
      BuildContext context, SignUpScreenController controller) {
    if (nameTEController.text.isEmpty) {
      makeSnack('error_name_hint'.tr);
      return;
    }
    if (emailTEController.text.isEmpty) {
      makeSnack('error_email_hint'.tr);
      return;
    }
    if (!GetUtils.isEmail(emailTEController.text)) {
      makeSnack('error_valid_email_hint'.tr);
      return;
    }
    if (passwordTEController.text.isEmpty) {
      makeSnack('error_password_hint'.tr);
      return;
    }
    if (passwordTEController.text.length < 8) {
      makeSnack('error_password_hint2'.tr);
      return;
    }
    if (confirmPasswordTEController.text.isEmpty) {
      makeSnack('error_confirm_password_hint'.tr);
      return;
    }
    if (confirmPasswordTEController.text != passwordTEController.text) {
      makeSnack('error_confirm_password_hint2'.tr);
      return;
    }
    // Loading indicator method
    showLoadingDialog(context);

    // Signup method
    signUp(controller, context);
  }

  //Account creation successful popup method
  void showCustomAlertDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CongratulationsCustomAlertDialogWidget(
          title: 'congratulations_txt'.tr,
          message: 'successfully_account_create_msg'.tr,
          onContinuePressed: () {
            Get.offAll(
              () => const HomeScreen(
                loadUserData: true,
              ),
            );
          },
        );
      },
    );
  }

  // Signup method
  Future<void> signUp(
      SignUpScreenController controller, BuildContext context) async {
    final response = await controller.signUp(nameTEController.text.trim(),
        emailTEController.text.trim(), passwordTEController.text, userAdId);
    if (response) {
      Get.back();
      showCustomAlertDialog(context);
    } else {
      Get.back();
      makeSnack(controller.message);
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
}
