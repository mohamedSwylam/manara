import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../data/viewmodel/Providers/location_provider.dart';
import '../../data/viewmodel/navigation_controller.dart';
import '../../data/viewmodel/onboarding_screen_controller.dart';
import '../../constants/images.dart';
import '../widgets/onboarding_screen_widgets.dart';
import 'home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<LocationProvider>(context, listen: false).setBool();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<OnboardingScreenController>(
          builder: (onboardingScreenController) {
        return PageView(
          controller: _pageController,
          onPageChanged: (int page) {
            print(page);
            onboardingScreenController.updatePageIndex(page);
          },
          children: <Widget>[
            OnboardingScreenWidgets(
              currentPage: onboardingScreenController.currentPageIndex,
              totalPages: 3,
              textTitle: 'onboarding_text1'.tr,
              textDescription: 'onboarding_text2'.tr,
              onTap: () {
                changeOnboarding(onboardingScreenController);
              },
              bgPath: AssetsPath.onboarding01BgSVG,
            ),
            OnboardingScreenWidgets(
              currentPage: onboardingScreenController.currentPageIndex,
              totalPages: 3,
              textTitle: 'onboarding_text3'.tr,
              textDescription: 'onboarding_text4'.tr,
              onTap: () {
                changeOnboarding(onboardingScreenController);
              },
              bgPath: AssetsPath.onboarding02BgSVG,
            ),
            OnboardingScreenWidgets(
              currentPage: onboardingScreenController.currentPageIndex,
              totalPages: 3,
              textTitle: 'onboarding_text5'.tr,
              textDescription: 'onboarding_text6'.tr,
              onTap: () {
                changeOnboarding(onboardingScreenController);
              },
              bgPath: AssetsPath.onboarding03BgSVG,
            ),
          ],
        );
      }),
    );
  }

  Future<void> changeOnboarding(OnboardingScreenController controller) async {
    if (controller.currentPageIndex == 2) {
      await NavigationController.setOnboardingValue(false);
      Get.offAll(() => const HomeScreen(
            loadUserData: false,
          ));
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }
  }
}
