import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:app_settings/app_settings.dart';
import '../../../constants/images.dart';
import '../../../data/viewmodel/theme_controller.dart';
import 'reminders_notifications_screen.dart';
import 'quran_settings_screen.dart';
import 'package:manara/presentation/views/prayer/prayer_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
        title: Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
            color: theme.textTheme.titleMedium?.color,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 60.h, left: 16.w, right: 16.w),
        child: Container(
          width: 328.w,
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFEAEAEA), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Quran Settings
              _buildSettingsOption(
                theme: theme,
                title: 'Quran Settings',
                subtitle: 'Edit on quran view',
                onTap: () {
                  Get.to(() => const QuranSettingsScreen());
                },
              ),
              
              const Divider(height: 1, color: Color(0xFFEAEAEA)),
              
              // Prayer Settings
              _buildSettingsOption(
                theme: theme,
                title: 'Prayer Settings',
                subtitle: 'Edit your location & prayer notifications',
                onTap: () {
                  Get.to(() => const PrayerSettingsScreen());
                },
              ),
              
              const Divider(height: 1, color: Color(0xFFEAEAEA)),
              
              // Reminders & Notifications
              _buildSettingsOption(
                theme: theme,
                title: 'Reminders & Notifications',
                subtitle: 'Edit prayer and holiday notifications',
                onTap: () {
                  Get.to(() => const RemindersNotificationsScreen());
                },
              ),
              
              const Divider(height: 1, color: Color(0xFFEAEAEA)),
              
              // Theme Toggle
              _buildThemeToggleOption(theme),
              
              const Divider(height: 1, color: Color(0xFFEAEAEA)),
              
              // System Settings
              _buildSettingsOption(
                theme: theme,
                title: 'System Settings',
                subtitle: 'Will open phone settings',
                onTap: () {
                  AppSettings.openAppSettings();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsOption({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: theme.textTheme.bodyMedium?.color ?? Colors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.6) ?? Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: theme.iconTheme.color?.withOpacity(0.6) ?? Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggleOption(ThemeData theme) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dark Mode',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: theme.textTheme.bodyMedium?.color ?? Colors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Toggle dark theme',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.6) ?? Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: themeController.isDarkMode,
                onChanged: (value) {
                  themeController.toggleTheme();
                },
                activeColor: const Color(0xFF8D1B3D),
              ),
            ],
          ),
        );
      },
    );
  }
}
