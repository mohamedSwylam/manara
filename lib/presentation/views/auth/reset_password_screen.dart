import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../more/widgets/auth_button.dart';
import 'verify_email_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.iconTheme.color,
          ),
          onPressed: () => Get.back(),
        ),

      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),
              Text(
                'reset_password_title'.tr,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w500,
                  fontSize: 24.sp,
                  height: 32.h / 24.sp,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              // Subtitle text
              Text(
                'reset_password_subtitle'.tr,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w400,
                  fontSize: 13.sp,
                  height: 20.h / 13.sp,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              
              SizedBox(height: 32.h),
              
              // Email address label
              Text(
                'email_address_label'.tr,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                  height: 16.h / 12.sp,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
              
              SizedBox(height: 8.h),
              
              // Email text field
              Container(
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  border: Border.all(color: theme.dividerTheme.color ?? Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please_enter_your_email'.tr;
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'please_enter_valid_email'.tr;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'enter_your_email_address'.tr,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
                             // Reset password button
               AuthButton(
                 onPressed: () {
                   if (_formKey.currentState!.validate()) {
                     // Navigate to verify email screen
                     Get.to(() => VerifyEmailScreen(email: _emailController.text));
                   }
                 },
                 text: 'reset_password'.tr,
               ),
              
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
