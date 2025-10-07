import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../menus/account_details_screen.dart';
import '../../../../data/models/auth/login_response_model.dart';

class ProfileCard extends StatelessWidget {
  final UserData? userData;
  
  const ProfileCard({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Get.to(() => const AccountDetailsScreen());
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Profile Image
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.cardTheme.color?.withOpacity(0.3) ?? const Color(0xFFF1F1F1),
                ),
                child: Icon(
                  Icons.person,
                  color: theme.textTheme.bodySmall?.color,
                  size: 24,
                ),
              ),
              SizedBox(width: 16.w),
              // Profile Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                    userData?.fullName ?? 'hi_user'.tr,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                      height: 20.h / 15.sp,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                    SizedBox(height: 4.h),
                    // User email
                    if (userData?.email != null)
                      Text(
                        userData!.email,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w400,
                          fontSize: 12.sp,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    SizedBox(height: 8.h),
                    // Account details row
                    Row(
                      children: [
                        Text(
                          'account_details_label'.tr,
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                            color: const Color(0xFF8D1B3D),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12.sp,
                          color: const Color(0xFF8D1B3D),
                        ),
                      ],
                    ),
                    
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
