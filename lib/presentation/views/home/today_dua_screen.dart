import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../constants/fonts_weights.dart';
import '../../../constants/images.dart';
import '../../../constants/colors.dart';
import '../../../data/viewmodel/Providers/hadith_provider.dart';

class TodayDuaScreen extends StatelessWidget {
  const TodayDuaScreen({super.key});

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
              _buildAppbar(context),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildDuaDetails(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppbar(BuildContext context) {
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
            "today_dua".tr,
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

  Widget _buildDuaDetails() {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.all(16.h),
      margin: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
          color: Colors.transparent, borderRadius: BorderRadius.circular(20)),
      child: Consumer<HadithProvider>(builder: (context, duaProvider, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            duaProvider.randomDuaIndex == -1
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Text(
                        duaProvider
                            .allDua![duaProvider.randomDuaIndex].duaArabic!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14.sp,
                            //overflow: TextOverflow.ellipsis,
                            color: AppColors.colorWhiteHighEmp),
                      ),
                      SizedBox(
                        height: 16.h,
                      ),
                      Text(
                        duaProvider.language == 'ar'
                            ? duaProvider.allDua![duaProvider.randomDuaIndex].duaArabic!
                            : duaProvider.language == 'en' ? duaProvider.allDua![duaProvider.randomDuaIndex].duaEnglish!
                            : duaProvider.language == 'ur' ? duaProvider.allDua![duaProvider.randomDuaIndex].duaUrdu!
                            : duaProvider.language == 'tr' ? duaProvider.allDua![duaProvider.randomDuaIndex].duaTurkish!
                            : duaProvider.language == 'bn' ? duaProvider.allDua![duaProvider.randomDuaIndex].duaBangla!
                            : duaProvider.language == 'fr' ? duaProvider.allDua![duaProvider.randomDuaIndex].duaFrench!
                            : duaProvider.allDua![duaProvider.randomDuaIndex].duaHindi!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14.sp,
                            //overflow: TextOverflow.ellipsis,
                            color: AppColors.colorWhiteHighEmp),
                      ),
                    ],
                  ),
          ],
        );
      }),
    );
  }
}
