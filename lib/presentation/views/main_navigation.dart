import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/viewmodel/main_navigation_controller.dart';
import 'home/home_screen.dart';
import 'quran/quran_index_screen.dart';
import 'Qibla/qibla_compass_screen.dart';
import 'home/tasbeh_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/colors.dart';
import '../../constants/images.dart';
import 'package:google_fonts/google_fonts.dart';

import 'more/more_screen.dart';

class NeonGlowIcon extends StatefulWidget {
  final String iconPath;
  final double height;
  final Color glowColor;
  final bool isActive;

  const NeonGlowIcon({
    Key? key,
    required this.iconPath,
    required this.height,
    required this.glowColor,
    required this.isActive,
  }) : super(key: key);

  @override
  State<NeonGlowIcon> createState() => _NeonGlowIconState();
}

class _NeonGlowIconState extends State<NeonGlowIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    if (widget.isActive) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(NeonGlowIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: (widget.isActive && isDarkMode) ? BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(0.3 * _glowAnimation.value),
                blurRadius: 8.0 + (4.0 * _glowAnimation.value),
                spreadRadius: 2.0 + (2.0 * _glowAnimation.value),
              ),
              BoxShadow(
                color: widget.glowColor.withOpacity(0.2 * _glowAnimation.value),
                blurRadius: 16.0 + (8.0 * _glowAnimation.value),
                spreadRadius: 4.0 + (4.0 * _glowAnimation.value),
              ),
            ],
          ) : null,
          child: SvgPicture.asset(
            widget.iconPath,
            height: widget.height,
            colorFilter: ColorFilter.mode(
              widget.isActive ? widget.glowColor : Colors.grey[600]!,
              BlendMode.srcIn,
            ),
          ),
        );
      },
    );
  }
}

class MainNavigation extends StatelessWidget {
  MainNavigation({super.key});

  final MainNavigationController controller =
      Get.put(MainNavigationController());
      




  // Custom text style with IBM Plex Sans Arabic
  TextStyle navigationTextStyle(int index, ThemeData theme) => GoogleFonts.ibmPlexSansArabic(
        fontWeight: FontWeight.w500,
        fontSize: 11.sp,
        height: 12 / 11, // line-height: 12px / font-size: 11px
        letterSpacing: 0,

        color: controller.state.currentIndex.value == index?
        AppColors.colorPrimary : theme.textTheme.bodySmall?.color ?? AppColors.colorGrayEmp,
        // textAlign: TextAlign.center,
      );

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          body: _buildCurrentPage(),
          bottomNavigationBar: _buildBottomNavigation(context),
        ));
  }

  Widget _buildCurrentPage() {
    final currentIndex = controller.state.currentIndex.value;
    
    // Use IndexedStack for all pages including home screen to prevent recreation
    return IndexedStack(
      index: currentIndex,
      children: [
        const QuranIndexScreen(hideBackButton: true),
        const CompassScreen(hideBackButton: true),
        const HomeScreen(loadUserData: false),
        const TasbehScreen(),
        const MoreScreen(),
      ],
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = controller.state.currentIndex.value;
    
    return Container(
      height: 70.h,
      width: double.infinity,
      color: theme.scaffoldBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                controller.state.currentIndex.value = 0;
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NeonGlowIcon(
                    iconPath: AssetsPath.quraanIconSVG,
                    height: 20.h,
                    glowColor: AppColors.colorPrimary,
                    isActive: currentIndex == 0,
                  ),
                  const SizedBox(height: 10,),
                  Text(
                    'alqran'.tr,
                    style: navigationTextStyle(currentIndex == 0 ? 0 : 6, theme),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                controller.state.currentIndex.value = 1;
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NeonGlowIcon(
                    iconPath: AssetsPath.qblaIconSVG,
                    height: 20.h,
                    glowColor: AppColors.colorPrimary,
                    isActive: currentIndex == 1,
                  ),
                  const SizedBox(height: 10,),
                  Text(
                    'alqblah'.tr,
                    style: navigationTextStyle(currentIndex == 1 ? 1 : 6, theme),
                  )
                ],
              ),
            ),
          ),
             InkWell(
              onTap: () {
                controller.state.currentIndex.value = 2;
              },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: NeonGlowIcon(
                iconPath: AssetsPath.appIconSVG,
                height: 50.h,
                glowColor: AppColors.colorPrimary,
                isActive: currentIndex == 2,
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                controller.state.currentIndex.value = 3;
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NeonGlowIcon(
                    iconPath: AssetsPath.sbhaaIconSVG,
                    height: 20.h,
                    glowColor: AppColors.colorPrimary,
                    isActive: currentIndex == 3,
                  ),
                  const SizedBox(height: 10,),
                  Text(
                    "counter".tr,
                    style: navigationTextStyle(currentIndex == 3 ? 3 : 6, theme),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                controller.state.currentIndex.value = 4;
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NeonGlowIcon(
                    iconPath: AssetsPath.moreIconSVG,
                    height: 20.h,
                    glowColor: AppColors.colorPrimary,
                    isActive: currentIndex == 4,
                  ),
                  const SizedBox(height: 10,),
                  Text(
                    'more'.tr,
                    style: navigationTextStyle(currentIndex == 4 ? 4 : 6, theme),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
