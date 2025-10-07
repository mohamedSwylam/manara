import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../../../constants/fonts_weights.dart';
import '../../../constants/images.dart';
import '../../../data/viewmodel/Providers/user_provider.dart';
import '../../../data/viewmodel/auth/user_data_controller.dart';
import '../../../data/viewmodel/edit_profile_screen_controller.dart';
import '../../widgets/app_background_image_widget.dart';
import '../../widgets/custom_appbar_widget.dart';
import '../../widgets/form_field_widget.dart';
import '../../widgets/functions_and_methods.dart';
import '../../widgets/loading_popup_widget.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String name;

  const ChangePasswordScreen({super.key, required this.name});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {

  final TextEditingController passwordTEController = TextEditingController();
  final TextEditingController confirmPasswordTEController =
      TextEditingController();
  String userId = '';
  String selectedImagePath = '';
  File? imageFile;

  selectImageFromGallery() async {
    XFile? file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 10,
    );
    if (file != null) {
      return file.path;
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          AppBackgroundImageWidget(bgImagePath: AssetsPath.background03SVG),
          // Custom Appbar

          Column(
            children: [
              CustomAppbarWidget(screenTitle: 'change_password'.tr),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      // Form section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 28.h),
                        child: Column(
                          children: [
                            _buildEditField(),
                            SizedBox(height: 32.h),
                            _buildSaveButton(),
                            SizedBox(height: 50.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditField() {
    return Column(
      children: [
        // SizedBox(height: 16.h),
        // FormFieldWidget(
        //   formTitle: 'current_password'.tr,
        //   hintText: '****************',
        //   controller: currentPasswordController,
        //   keyboardType: TextInputType.visiblePassword,
        //   obscureText: true,
        // ),
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

  Widget _buildSaveButton() {
    return SizedBox(
      height: 54.h,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          checkFormErrors();
        },
        child: Text(
          'save_btn_text'.tr,
          style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16.sp,
              color: AppColors.colorBlackHighEmp,
              fontWeight: FontWeights.semiBold),
        ),
      ),
    );
  }

  void checkFormErrors() {
    if (passwordTEController.text.isNotEmpty &&
        passwordTEController.text.length < 8) {
      makeSnack('error_password_hint2'.tr);
      return;
    }
    if (passwordTEController.text.isNotEmpty &&
        (confirmPasswordTEController.text != passwordTEController.text)) {
      makeSnack('error_confirm_password_hint2'.tr);
      return;
    }
    showLoadingDialog(context);
    Map<String, dynamic> requestBody = {
      "fullName": widget.name,
      "password": passwordTEController.text
    };
    updateUserData(requestBody, context);
  }

  Future<void> updateUserData(
      Map<String, dynamic> requestBody, BuildContext context) async {
    await UserDataController.getUserId();
    final response = await Get.find<EditProfileScreenController>()
        .updateUserData(requestBody, UserDataController.userId!, false, null);
    if (response) {
      await UserDataController.setUserName(widget.name);
      Get.back();
      makeSnack('data_update_success'.tr);
      Provider.of<UserProvider>(context, listen: false)
          .fetchLoggedInUserData(true);
    } else {
      Get.back();
      makeSnack(Get.find<EditProfileScreenController>().message);
    }
  }

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
