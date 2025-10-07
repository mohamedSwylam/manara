import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../more/widgets/auth_button.dart';
import '../auth/verify_email_screen.dart';

class UpdateEmailScreen extends StatefulWidget {
  const UpdateEmailScreen({super.key});

  @override
  State<UpdateEmailScreen> createState() => _UpdateEmailScreenState();
}

class _UpdateEmailScreenState extends State<UpdateEmailScreen> {
  final TextEditingController _emailController = TextEditingController();

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
          icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main title
            Text(
              'update_your_email'.tr,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w500,
                fontSize: 24.sp,
                height: 32.h / 24.sp,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Description text
            Text(
              'email_update_description'.tr,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                height: 20.h / 14.sp,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            
            SizedBox(height: 32.h),
            
            // Email address section
            Text(
              'email_address'.tr,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
                height: 16.h / 12.sp,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
            
            SizedBox(height: 8.h),
            
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color,
              ),
              decoration: InputDecoration(
                hintText: 'enter_email_address'.tr,
                hintStyle: TextStyle(
                  color: theme.textTheme.bodySmall?.color,
                  fontSize: 14.sp,
                ),
                filled: true,
                fillColor: theme.cardTheme.color,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: theme.dividerTheme.color ?? Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: theme.dividerTheme.color ?? Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF8D1B3D)),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h), // Reduced from 16.h to 13.h
              ),
            ),
            
            const Spacer(),
            
            // Send OTP button
            SizedBox(
              width: double.infinity,
              child: AuthButton(
                text: 'send_otp'.tr,
                onPressed: () {
                  String email = _emailController.text.trim();
                  
                  if (email.isNotEmpty && _isValidEmail(email)) {
                    // Navigate to VerifyEmailScreen
                    Get.to(() => VerifyEmailScreen(email: email));
                  } else {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('please_enter_valid_email_address'.tr),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ),
            
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
