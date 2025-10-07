import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/utility/urls.dart';
import '../../../constants/colors.dart';
import '../../../constants/fonts_weights.dart';
import '../../../data/viewmodel/Providers/user_provider.dart';
import '../../../data/viewmodel/auth/user_data_controller.dart';
import '../../../data/viewmodel/edit_profile_screen_controller.dart';
import '../../../constants/images.dart';
import '../../widgets/functions_and_methods.dart';
import '../../widgets/loading_popup_widget.dart';
import '../../widgets/app_background_image_widget.dart';
import '../../widgets/custom_appbar_widget.dart';
import '../../widgets/form_field_widget.dart';
import '../auth/signup_screen.dart';
import 'package:http/http.dart' as http;
import 'change_password_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameTEController = TextEditingController();
  final TextEditingController emailTEController = TextEditingController();
  final TextEditingController passwordTEController = TextEditingController();
  final TextEditingController confirmPasswordTEController = TextEditingController();
  String userName = '';
  String userMail = '';
  String userId = '';

  @override
  void initState() {
    // Load/Fetch user data
    loadUserData();
    super.initState();
  }

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

  // Load/Fetch user data method
  Future<void> loadUserData() async {
    //Access userNme on shared pref
    await UserDataController.getUserName();
    //Access userMail on shared pref
    await UserDataController.getUserMail();
    //Access userId on shared pref
    await UserDataController.getUserId();
    // Set and update user data value
    setState(() {
      userName = UserDataController.userName ?? '';
      userMail = UserDataController.userMail ?? '';
      userId = UserDataController.userId ?? '';
      nameTEController.text = userName;
      emailTEController.text = userMail;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          AppBackgroundImageWidget(bgImagePath: AssetsPath.background03SVG),

          Column(
            children: [
              CustomAppbarWidget(screenTitle: 'profile'.tr),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      /// Profile card section
                      _buildUserInfo(),
                      SizedBox(height: 20.h),
                      // Form section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 28.h),
                        child: Column(
                          children: [
                            _buildEditField(),
                            SizedBox(height: 18.h),
                            _buildChangePassword(context),
                            SizedBox(height: 32.h),
                            _buildSaveButton(),
                            SizedBox(height: 100.h),
                            _buildDeleteAccount(context),
                            SizedBox(height: 32.h),
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

  Widget _buildUserInfo() {
    return Stack(
      children: [
        Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        selectedImagePath == ''
                            ? userProvider.userData!.thumbnailUrl == null ||
                                    userProvider.userData!.thumbnailUrl ==
                                        'Null' ||
                                    userProvider.userData!.thumbnailUrl == ''
                                ? ClipOval(
                                    child: Image.asset(
                                      AssetsPath.profileAvatarPNG,
                                      height: 100.h,
                                      width: 100.w,
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Container(
                                      height: 100.w,
                                      width: 100.w,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          color: AppColors.colorWhiteHighEmp),
                                      child: Image.network(
                                        userProvider.userData!.thumbnailUrl!,
                                        fit: BoxFit.cover,
                                        height: 100.w,
                                        width: 100.w,
                                      ),
                                    ),
                                  )
                            : ClipOval(
                                child: Image.file(
                                  File(selectedImagePath),
                                  height: 100.w,
                                  width: 100.w,
                                  fit: BoxFit.fill,
                                ),
                              ),
                        Positioned(
                          right: 5.h,
                          bottom: 5.h,
                          child: InkWell(
                            onTap: () async {
                              selectedImagePath =
                                  await selectImageFromGallery();

                              if (selectedImagePath != '') {
                                setState(() {
                                  imageFile = File(selectedImagePath);
                                });
                              }
                            },
                            child: Image.asset(
                              AssetsPath.avatarEditPNG,
                              height: 20.h,
                              width: 20.w,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      userName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.colorWhiteHighEmp,
                        fontSize: 20.sp,
                        fontWeight: FontWeights.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      userMail,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.colorWhiteHighEmp,
                        fontSize: 14.sp,
                        fontWeight: FontWeights.regular,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        )
      ],
    );
  }

  Widget _buildEditField() {
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
          hintText: 'example@domain.com',
          controller: emailTEController,
          keyboardType: TextInputType.emailAddress,
          readOnly: true,
        ),
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

  Widget _buildChangePassword(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChangePasswordScreen(name: nameTEController.text,)),
        );
      },
      child: Row(
        children: [
          SvgPicture.asset(AssetsPath.key),
          SizedBox(width: 8.h),
          Text(
            'change_password'.tr,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeights.semiBold,
                color: AppColors.colorSecondaryLightest),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteAccount(BuildContext context) {
    return InkWell(
      onTap: () async {
        await showDialogDeleteConfirmation(context);
      },
      child: Container(
        height: 70.h,
        padding: EdgeInsets.all(4.h),
        decoration: BoxDecoration(
            color: AppColors.colorDonationGradient1Start,
            borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            SizedBox(width: 18.h),
            Image.asset(
              AssetsPath.user,
              height: 30,
              width: 30,
            ),
            SizedBox(width: 12.h),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'delete_account2'.tr,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeights.semiBold,
                        color: AppColors.colorBlack),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'deleting_account_info'.tr,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeights.regular,
                          color: AppColors.colorBlack),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<dynamic> showDialogDeleteConfirmation(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Modified title
            IconButton(
              icon: Image.asset(
                AssetsPath.close,
                height: 25,
                width: 25,
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('account_deletion'.tr,
                style: TextStyle(
                    fontSize: 24.sp,
                    color: AppColors.colorBlack,
                    fontWeight: FontWeights.bold)),
            const SizedBox(height: 8.0),
            // Adding some space between the content and subtitle
            Text(
              'confirm_delete_account'.tr, // Added subtitle
              style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.colorAlert,
                  fontWeight: FontWeights.light),
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: () {
                print("----------------Delete");
                deleteData();
              },
              child: Text(
                'delete'.tr,
                style: const TextStyle(color: AppColors.colorError),
              ), // Modified text button
            ),
            SizedBox(
              height: 46.h,
              width: 140.w,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                child: Text(
                  'close'.tr,
                  style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.colorBlackHighEmp,
                      fontWeight: FontWeights.semiBold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool deletingAccount = false;

  Future<void> deleteData() async {
    Navigator.pop(context);
    showLoadingDialog(context);
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    String? userId = sharedPreferences.getString('user_id');

    print(".........................${Urls.deleteAccount}$userId");
    final response = await http.delete(
      Uri.parse("${Urls.deleteAccount}$userId"),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => SignUpScreen(isParent: true)),
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.pop(context);
      makeSnack('please_try_again'.tr);
    }
  }

  ///Form error checking method
  void checkFormErrors() async {
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
    // Loading indicator method
    showLoadingDialog(context);
    Map<String, dynamic> requestBody = {};
    if (passwordTEController.text.isEmpty) {
      requestBody = {"fullName": nameTEController.text.trim()};
    } else {
      requestBody = {
        "fullName": nameTEController.text.trim(),
        "password": passwordTEController.text
      };
    }
    print(requestBody);
    // Update method
    updateUserData(requestBody, context);
  }

  /// Update method
  Future<void> updateUserData(
      Map<String, dynamic> requestBody, BuildContext context) async {
    bool imageUpload;
    if (selectedImagePath != '') {
      imageUpload = true;
    } else {
      imageUpload = false;
    }
    final response = await Get.find<EditProfileScreenController>()
        .updateUserData(requestBody, userId, imageUpload, imageFile);
    if (response) {
      await UserDataController.setUserName(nameTEController.text.trim());
      Get.back();
      loadUserData();
      makeSnack('data_update_success'.tr);
      Provider.of<UserProvider>(context, listen: false)
          .fetchLoggedInUserData(true);
    } else {
      Get.back();
      makeSnack(Get.find<EditProfileScreenController>().message);
    }
  }

  /// Loading indicator
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
