import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:manara/constants/colors.dart';
import 'package:manara/presentation/views/auth/signup_screen.dart';
import 'package:manara/presentation/views/auth/verify_email_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../constants/fonts_weights.dart';
import '../../../constants/images.dart';
import '../../../data/viewmodel/auth/signin_screen_controller.dart';
import '../../widgets/app_background_image_widget.dart';
import '../../widgets/form_field_widget.dart';
import '../../widgets/functions_and_methods.dart';
import '../../widgets/loading_popup_widget.dart';
import '../home/home_screen.dart';

class SignInScreen extends StatefulWidget {
  SignInScreen({Key? key, required this.isParent}) : super(key: key);
  final bool isParent;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailTEController = TextEditingController();
  final TextEditingController passwordTEController = TextEditingController();

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
                SizedBox(
                  height: 116.h,
                ),
                _buildHeader(),
                SizedBox(height: 24.h),
                // Form section
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildInputField(),
                        SizedBox(height: 12.h),
                        _buildForgetPassword(),
                        SizedBox(height: 32.h),
                        _buildSubmitButton(context),
                        SizedBox(height: 20.h),
                        _buildToRegistration(),
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
            'sign_in_title'.tr,
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
            'sign_in_subtitle'.tr,
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
      ],
    );
  }

  Widget _buildForgetPassword() {
    return InkWell(
      onTap: () {
        // Get.to(() => VerifyEmailScreen());
      },
      child: Text(
        'forgot_password'.tr,
        style: TextStyle(
          color: AppColors.colorPrimaryLighter,
          fontSize: 16.sp,
          fontFamily: 'Poppins',
          fontWeight: FontWeights.semiBold,
        ),
      ),
    );
  }

  Widget _buildToRegistration() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'no_account'.tr,
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
            text: 'resister'.tr,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.colorPrimaryLighter,
              fontFamily: 'Poppins',
              fontWeight: FontWeights.semiBold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                widget.isParent
                    ? Get.to(() => SignUpScreen(
                          isParent: false,
                        ))
                    : Get.offAll(() => SignUpScreen(
                          isParent: true,
                        ));
              },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return GetBuilder<SignInScreenController>(
        builder: (signInScreenController) {
      return SizedBox(
        height: 54.h,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            FocusScope.of(context).requestFocus(FocusNode());
            checkFormErrors(context, signInScreenController);
          },
          child: Text(
            'sign_in'.tr,
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

  //Form error checking method
  void checkFormErrors(
      BuildContext context, SignInScreenController controller) {
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
    // Loading indicator method
    showLoadingDialog(context);

    // Signup method
    signIn(controller);
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
  Future<void> signIn(SignInScreenController controller) async {
    final response = await controller.signIn(
      emailTEController.text.trim(),
      passwordTEController.text,
      userAdId,
    );
    print(response);
    if (response) {
      //print('Go Home');
      Get.back();
      Get.offAll(() => const HomeScreen(
            loadUserData: true,
          ));
      //print('Home');
    } else {
      Get.back();
      makeSnack(controller.message);
    }
  }
}
