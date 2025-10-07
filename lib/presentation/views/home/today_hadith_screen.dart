import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:manara/constants/images.dart';
import 'package:provider/provider.dart';

import '../../../constants/colors.dart';
import '../../../constants/fonts_weights.dart';
import '../../../data/viewmodel/Providers/hadith_provider.dart';

class TodayHadithScreen extends StatelessWidget {
  const TodayHadithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: true,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AssetsPath.background2nd),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHadithDetails(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 40.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            color: AppColors.colorWhiteHighEmp,
          ),
          Text(
            "today_hadith".tr,
            style: TextStyle(
              color: AppColors.colorWhiteHighEmp,
              fontSize: 18.sp,
              fontWeight: FontWeights.semiBold,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHadithDetails() {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.all(16.h),
      margin: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
          color: Colors.transparent, borderRadius: BorderRadius.circular(20)),
      child: Consumer<HadithProvider>(
        builder: (context, hadithProvider, child) {
          return hadithProvider.randomHadithIndex == -1
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      hadithProvider
                          .allHadith![hadithProvider.randomHadithIndex]
                          .hadithArabic!,
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14.sp,
                          overflow: TextOverflow.ellipsis,
                          color: AppColors.colorWhiteHighEmp),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    hadithProvider.language == 'ar'
                        ? const SizedBox()
                        : Text(
                            hadithProvider.language == 'en'
                                ? hadithProvider
                                    .allHadith![
                                        hadithProvider.randomHadithIndex]
                                    .hadithEnglish!
                                : hadithProvider.language == 'ur'
                                    ? hadithProvider
                                        .allHadith![
                                            hadithProvider.randomHadithIndex]
                                        .hadithUrdu!
                                    : hadithProvider.language == 'tr'
                                        ? hadithProvider
                                            .allHadith![hadithProvider
                                                .randomHadithIndex]
                                            .hadithTurkish!
                                        : hadithProvider.language == 'bn'
                                            ? hadithProvider
                                                .allHadith![hadithProvider
                                                    .randomHadithIndex]
                                                .hadithBangla!
                                            : hadithProvider.language == 'fr'
                                                ? hadithProvider
                                                    .allHadith![hadithProvider
                                                        .randomHadithIndex]
                                                    .hadithFrench!
                                                : hadithProvider
                                                    .allHadith![hadithProvider
                                                        .randomHadithIndex]
                                                    .hadithHindi!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.colorWhiteHighEmp),
                          )
                  ],
                );
        },
      ),
    );
  }
}
