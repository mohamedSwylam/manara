import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../constants/images.dart';
import '../more/widgets/auth_button.dart';
import '../menus/account_details_screen.dart';
import '../../widgets/custom_toast_widget.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  
  const VerifyEmailScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
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
              
              // Title
              Text(
                'verify_new_email_address'.tr,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w500,
                  fontSize: 24.sp,
                  height: 32.h / 24.sp,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              
              SizedBox(height: 16.h),
              
                             // Subtitle text
               RichText(
                 text: TextSpan(
                   style: TextStyle(
                     fontFamily: 'IBM Plex Sans Arabic',
                     fontWeight: FontWeight.w400,
                     fontSize: 13.sp,
                     height: 20.h / 13.sp,
                     color: theme.textTheme.bodySmall?.color,
                   ),
                   children: [
                     TextSpan(
                       text: '${'verify_email_subtitle'.tr} ',
                     ),
                     TextSpan(
                       text: widget.email,
                       style: TextStyle(
                         fontFamily: 'IBM Plex Sans Arabic',
                         fontWeight: FontWeight.w600,
                         fontSize: 12.sp,
                         height: 16.h / 12.sp,
                         color: theme.textTheme.titleMedium?.color,
                       ),
                     ),
                   ],
                 ),
               ),
              
              SizedBox(height: 32.h),
              
              // 6-digit code label
              Text(
                'six_digit_code'.tr,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                  height: 16.h / 12.sp,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
              
              SizedBox(height: 8.h),
              
              // 6-digit code text field
              Container(
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  border: Border.all(color: theme.dividerTheme.color ?? Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please_enter_six_digit_code'.tr;
                    }
                    if (value.length != 6) {
                      return 'code_must_be_six_digits'.tr;
                    }
                    if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
                      return 'please_enter_six_digit_code'.tr;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'six_digit_code_hint'.tr,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    counterText: '', // Hide character counter
                  ),
                ),
              ),
              
              const Spacer(),
              
                             // Submit button
               AuthButton(
                 onPressed: () {
                   if (_formKey.currentState!.validate()) {
                     // TODO: Implement verification logic
                     debugPrint('Verifying code: ${_codeController.text} for email: ${widget.email}');
                     // Close all screens back to AccountDetailsScreen and show success toast
                     Get.offAll(() => const AccountDetailsScreen());
                     CustomToastWidget.show(
                       context: context,
                       title: "Changes successfully saved",
                       iconPath: AssetsPath.logo00102PNG,
                       iconBackgroundColor: const Color(0xFF8D1B3D),
                       backgroundColor: const Color(0xFFFFEFE8),
                     );
                   }
                 },
                 text: 'Submit',
               ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
