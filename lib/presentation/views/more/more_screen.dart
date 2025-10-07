import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../data/bloc/prayer_times_bloc.dart';
import '../../../data/viewmodel/theme_controller.dart';
import '../../../data/viewmodel/more_screen_controller.dart';

import '../../../constants/images.dart';
import '../../widgets/sub_category_list_widget.dart';
import '../Duaa/duas_screen.dart';
import 'widgets/auth_button.dart';
import 'widgets/auth_bottom_sheet.dart';
import 'widgets/profile_card.dart';
import 'contact_us_screen.dart';
import 'about_us_screen.dart';
import '../menus/settings_screen.dart';
import '../menus/preferance/change_language_screen.dart';
import '../menus/language_selection_screen.dart';

// Import screens for navigation
import '../al_quran_details_screen.dart';
import '../Qibla/qibla_screen.dart';
import '../home/tasbeh_screen.dart';
import '../home/today_dua_screen.dart';
import '../hadith/hadith_screen.dart';
import '../prayer/prayer_screen.dart';
import '../zakat_calculator/zakat_calculator_screen.dart';
import '../location_access_screen.dart';
import '../quran/quran_index_screen.dart';
import '../islamic_calendar_screen.dart';


class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> with AutomaticKeepAliveClientMixin {
  late MoreScreenController _moreScreenController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _moreScreenController = Get.put(MoreScreenController());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'more'.tr,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.titleMedium?.color ?? Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 16.h),
            
            // Profile Card - Conditionally show login card or profile card
            Obx(() => _moreScreenController.isLoggedIn
                ? ProfileCard(userData: _moreScreenController.userData)
                : Container(
                    width: 328.w,
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Profile Image
                              SvgPicture.asset(
                                AssetsPath.profileSVG,
                                width: 48.w,
                                height: 48.h,
                              ),
                              SizedBox(width: 16.w),
                              // Profile Text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'hi_tap_to'.tr,
                                            style: GoogleFonts.poppins(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w600,
                                              color: theme.textTheme.bodyMedium?.color ?? Colors.black87,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'log_in'.tr,
                                            style: GoogleFonts.poppins(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF8D1B3D),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'login_or_create_account'.tr,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.6) ?? Colors.grey[600],
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          
                          // Login/Signup Button
                          AuthButton(
                            onPressed: () {
                              Get.bottomSheet(
                                const AuthBottomSheet(),
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                              );
                            },
                            text: 'login_register'.tr,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            SizedBox(height: 24.h),
            
            // Menu Items Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: AssetsPath.quraanIconSVG,
                    title: 'quran'.tr,
                    onTap: () {
                      // Navigate to Quran Index screen
                      Get.to(() => const QuranIndexScreen());
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: AssetsPath.quraancolordSVG,
                    title: 'qibla'.tr,
                    onTap: () {
                      // Navigate to Qibla screen
                      Get.to(() => const QiblahScreen());
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: AssetsPath.tasbihcolordSVG,
                    title: 'tasbeh'.tr,
                    onTap: () {
                      // Navigate to Tasbeh screen
                      Get.to(() => const TasbehScreen());
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: AssetsPath.ad3iahSVG,
                    title: 'duas'.tr,
                    onTap: () {
                      // Navigate to Duas screen
                      Get.to(() => const DuaaMainScreen());
                      // Get.to(() => const TodayDuaScreen());
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: AssetsPath.calendarSVG,
                    title: 'calendar'.tr,
                    onTap: () {
                      // Navigate to Islamic Calendar screen
                      Get.to(() => const IslamicCalendarScreen());
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: AssetsPath.masjidSVG,
                    title: 'masjid'.tr,
                    onTap: () {
                      // Navigate to Mosque Location screen
                      Get.to(() => const LocationAccessScreen());
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: AssetsPath.hadithSVG,
                    title: 'hadith'.tr,
                    onTap: () {
                      // Navigate to Hadith screen
                      Get.to(() => const HadithScreen());
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: AssetsPath.prayerSVG,
                    title: 'prayer'.tr,
                    onTap: () {
                      // Navigate to Prayer screen
                      // Get.to(() => const PrayerScreen());

                      final prayerTimesBloc = context.read<PrayerTimesBloc>();

                      // Navigate to the detailed prayer screen with existing PrayerTimesBloc
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: prayerTimesBloc,
                            child: const PrayerScreen(),
                          ),
                        ),
                      );

                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: AssetsPath.zakatSVG,
                    title: 'zakat'.tr,
                    onTap: () {
                      // Navigate to Zakat Calculator screen
                      Get.to(() => const ZakatCalculatorScreen());
                    },
                    showDivider: false,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Settings Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSettingsItem(
                    title: 'contact_us'.tr,
                    onTap: () {
                      Get.to(() => const ContactUsScreen());
                    },
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    title: 'share_app'.tr,
                    onTap: () {
                      // TODO: Share app functionality
                    },
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    title: 'about'.tr,
                    onTap: () {
                      Get.to(() => const AboutUsScreen());
                    },
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    title: 'language'.tr,
                    onTap: () {
                      Get.to(() => const LanguageSelectionScreen());
                    },
                  ),
                  _buildDivider(),
                  _buildThemeToggleItem(),
                  _buildDivider(),
                  _buildSettingsItem(
                    title: 'settings'.tr,
                    onTap: () {
                      Get.to(() => const SettingsScreen());
                    },
                    showDivider: false,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24.h),
          ]),
      ));
  }

  Widget _buildMenuItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                SvgPicture.asset(
                  icon,
                  width: 24.w,
                  height: 24.h,
                  colorFilter: ColorFilter.mode(
                    theme.iconTheme.color ?? const Color(0xFF4F4F4F),
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: theme.textTheme.bodyMedium?.color ?? Colors.black87,
                    ),
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
        if (showDivider) _buildDivider(),
      ],
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: theme.textTheme.bodyMedium?.color ?? Colors.black87,
                    ),
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
        if (showDivider) _buildDivider(),
      ],
    );
  }

  Widget _buildDivider() {
    final theme = Theme.of(context);
    return Divider(
      height: 1,
      thickness: 1,
      color: theme.dividerTheme.color ?? Colors.grey[200],
      // indent: 56.w,
      // endIndent: 16.w,
    );
  }

  Widget _buildThemeToggleItem() {
    final theme = Theme.of(context);
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'dark_mode'.tr,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: theme.textTheme.bodyMedium?.color ?? Colors.black87,
                    ),
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
          ),
        );
      },
    );
  }
}
