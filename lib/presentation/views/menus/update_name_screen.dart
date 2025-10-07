import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../constants/images.dart';
import '../../widgets/custom_toast_widget.dart';
import '../more/widgets/auth_button.dart';

class UpdateNameScreen extends StatefulWidget {
  const UpdateNameScreen({super.key});

  @override
  State<UpdateNameScreen> createState() => _UpdateNameScreenState();
}

class _UpdateNameScreenState extends State<UpdateNameScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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
              'update_your_name'.tr,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w500,
                fontSize: 24.sp,
                height: 32.h / 24.sp,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            
            SizedBox(height: 32.h),
            
            // First name section
            Text(
              'first_name'.tr,
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
                       controller: _firstNameController,
                       style: TextStyle(
                         color: theme.textTheme.bodyMedium?.color,
                       ),
                       decoration: InputDecoration(
                         hintText: 'enter_first_name'.tr,
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
                         contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
                       ),
                     ),
            
            SizedBox(height: 24.h),
            
            // Last name section
            Text(
              'last_name'.tr,
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
                       controller: _lastNameController,
                       style: TextStyle(
                         color: theme.textTheme.bodyMedium?.color,
                       ),
                       decoration: InputDecoration(
                         hintText: 'enter_last_name'.tr,
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
                         contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
                       ),
                     ),
            
            const Spacer(),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: AuthButton(
                text: 'save'.tr,
                onPressed: () {
                  // TODO: Implement save functionality
                  String firstName = _firstNameController.text.trim();
                  String lastName = _lastNameController.text.trim();
                  
                  if (firstName.isNotEmpty && lastName.isNotEmpty) {
                    // TODO: Update user name in backend
                    Get.back(result: {
                      'firstName': firstName,
                      'lastName': lastName,
                    });
                    CustomToastWidget.show(
                      context: context,
                      title: 'changes_successfully_saved'.tr,
                      iconPath: AssetsPath.logo00102PNG,
                      iconBackgroundColor: const Color(0xFF8D1B3D),
                      backgroundColor: const Color(0xFFFFEFE8),
                    );
                  } else {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('please_fill_both_names'.tr),
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
}
