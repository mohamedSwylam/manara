// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import '../widgets/app_background_image_widget.dart';
// import '../widgets/custom_appbar_widget.dart';
// import '../widgets/category_item_card_widget.dart';
// import '../../constants/images.dart';
// import 'auth/signin_screen.dart';
// import 'menus/edit_profile_screen.dart';
// import 'al_quran_details_screen.dart';
// import 'Qibla/qibla_compass_screen.dart';
// import 'home/tasbeh_screen.dart';
// import 'home/today_dua_screen.dart';
// import 'home/today_hadith_screen.dart';
// import 'menus/prayer_time_screen.dart';
// import 'menus/zakat_calculator.dart';
// import 'menus/preferance/about_us_screen.dart';
// import 'menus/preferance/preference_screen.dart';
// import 'menus/preferance/change_language_screen.dart';
// import '../views/location_access_screen.dart';
//
// class MoreScreen extends StatelessWidget {
//   const MoreScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           const AppBackgroundImageWidget(bgImagePath: 'assets/images/background03.svg'),
//           Column(
//             children: [
//               const CustomAppbarWidget(screenTitle: 'more', backButton: false),
//               SizedBox(height: 16.h),
//               const LoginProfileCard(),
//               SizedBox(height: 16.h),
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 12.w),
//                     child: Column(
//                       children: [
//                         // Main menu items
//                         _buildMenuSection([
//                           _MenuItem(
//                             icon: AssetsPath.quranIconSVG,
//                             label: 'al_quran'.tr,
//                             onTap: () => Get.to(() => const AlQuranScreen(surahName: 'Al-Fatiha', surahNumber: 1)),
//                           ),
//                           _MenuItem(
//                             icon: AssetsPath.compassIconSVG,
//                             label: 'qibla_compass2'.tr,
//                             onTap: () => Get.to(() => const CompassScreen()),
//                           ),
//                           _MenuItem(
//                             icon: AssetsPath.tasbihCounterIconPNG,
//                             label: 'tasbih'.tr,
//                             onTap: () => Get.to(() => const TasbehScreen()),
//                           ),
//                           _MenuItem(
//                             icon: AssetsPath.duaIconSVG,
//                             label: 'dua'.tr,
//                             onTap: () => Get.to(() => const TodayDuaScreen()),
//                           ),
//                           _MenuItem(
//                             icon: AssetsPath.calenderIconPNG,
//                             label: 'islamic_calender2'.tr,
//                             onTap: () {},
//                           ),
//                           _MenuItem(
//                             icon: AssetsPath.mosqueIconPNG,
//                             label: 'mosque_location',
//                             onTap: () => Get.to(() => const LocationAccessScreen()),
//                           ),
//                           _MenuItem(
//                             icon: AssetsPath.hadithIconSVG,
//                             label: 'hadith'.tr,
//                             onTap: () => Get.to(() => const TodayHadithScreen()),
//                           ),
//                           _MenuItem(
//                             icon: AssetsPath.notification,
//                             label: 'prayer_times'.tr,
//                             onTap: () => Get.to(() => const PrayerTimeScreen()),
//                           ),
//                           _MenuItem(
//                             icon: AssetsPath.zakatIconPNG,
//                             label: 'jakat_calculator2'.tr,
//                             onTap: () => Get.to(() => const ZakatCalculator()),
//                           ),
//                         ]),
//                         SizedBox(height: 24.h),
//                         // Secondary menu items
//                         _buildMenuSection([
//                           _MenuItem(
//                             icon: AssetsPath.accountIconPNG,
//                             label: 'contact_us'.tr,
//                             onTap: () {},
//                           ),
//                           _MenuItem(
//                             icon: AssetsPath.notification,
//                             label: 'share_app'.tr,
//                             onTap: () {},
//                           ),
//                           _MenuItem(
//                             icon: AssetsPath.aboutUsIconPNG,
//                             label: 'about_us'.tr,
//                             onTap: () => Get.to(() => const AboutUsScreen()),
//                           ),
//                           _MenuItem(
//                             icon: AssetsPath.changeLanguageIconPNG,
//                             label: 'change_language'.tr,
//                             onTap: () => Get.to(() => const ChangeLanguageScreen(backButton: true)),
//                           ),
//                           _MenuItem(
//                             icon: AssetsPath.preferencesIconPNG,
//                             label: 'preference'.tr,
//                             onTap: () => Get.to(() => const PreferenceScreen()),
//                           ),
//                         ]),
//                         SizedBox(height: 24.h),
//                         // Open phone settings
//                         _buildMenuSection([
//                           _MenuItem(
//                             icon: AssetsPath.phone,
//                             label: 'open_phone_settings'.tr,
//                             onTap: () {},
//                           ),
//                         ]),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMenuSection(List<_MenuItem> items) {
//     return Card(
//       color: Colors.white.withOpacity(0.1),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Column(
//         children: items
//             .map((item) => InkWell(
//                   onTap: item.onTap,
//                   child: CategoryItemCardWidget(
//                     iconImagePath: item.icon,
//                     title: item.label.tr,
//                   ),
//                 ))
//             .toList(),
//       ),
//     );
//   }
// }
//
// class LoginProfileCard extends StatelessWidget {
//   const LoginProfileCard({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final bool isLoggedIn = false;
//     final String userName = 'User';
//     return Card(
//       margin: EdgeInsets.symmetric(horizontal: 8.w),
//       color: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: EdgeInsets.all(16.w),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 28.r,
//                   backgroundImage: AssetImage(AssetsPath.profileAvatarPNG),
//                 ),
//                 SizedBox(width: 16.w),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         isLoggedIn ? 'welcome'.tr : 'hello_guest'.tr,
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16.sp,
//                         ),
//                       ),
//                       SizedBox(height: 4.h),
//                       Text(
//                         isLoggedIn ? userName : 'login_or_create_account'.tr,
//                         style: TextStyle(fontSize: 13.sp),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 12.h),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.deepPurple,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 onPressed: () {
//                   if (isLoggedIn) {
//                     Get.to(() => const EditProfileScreen());
//                   } else {
//                     Get.to(() => SignInScreen(isParent: true));
//                   }
//                 },
//                 child: Text(
//                   isLoggedIn ? 'edit_profile'.tr : 'login_register'.tr,
//                   style: TextStyle(color: Colors.white, fontSize: 15.sp),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _MenuItem {
//   final String icon;
//   final String label;
//   final VoidCallback onTap;
//   _MenuItem({required this.icon, required this.label, required this.onTap});
// }
