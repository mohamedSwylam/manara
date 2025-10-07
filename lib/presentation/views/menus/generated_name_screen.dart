import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../../../data/viewmodel/Providers/gpt_provider.dart';
import '../../../constants/images.dart';
import '../../widgets/app_background_image_widget.dart';

class GeneratedNameScreen extends StatefulWidget {
  const GeneratedNameScreen({super.key});

  @override
  State<GeneratedNameScreen> createState() => _GeneratedNameScreenState();
}

class _GeneratedNameScreenState extends State<GeneratedNameScreen> {
  String decodeUnicodeEscape(String input) {
    RegExp exp = RegExp(r'\\[uU]([0-9a-fA-F]{4})');
    return input.replaceAllMapped(exp, (match) {
      return String.fromCharCode(int.parse(match.group(1)!, radix: 16));
    });
  }

  String decodeArabic(String input) {
    return json.decode('"$input"');
  }

  @override
  Widget build(BuildContext context) {
    final gptProvider = Provider.of<GPTProvider>(context, listen: false);
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          AppBackgroundImageWidget(bgImagePath: AssetsPath.secondaryBGSVG),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 50.h,),
                  appbarWidget(),
                  SizedBox(height: 20.h,),
                  _buildSuggestedName(gptProvider),
                  SizedBox(height: 50.h,),
                ],
              ),
            ),
          )
        ],
      )
    );
  }

  Widget appbarWidget(){
    return Row(
      children: [
        GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_outlined,
            color: AppColors.colorWhiteHighEmp,
            size: 22.sp,
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          "baby_name2".tr,
          style: TextStyle(
              fontSize: 18.sp,
              color: AppColors.colorWhiteHighEmp
          ),
        )
      ],
    );
  }

  Widget _buildSuggestedName(GPTProvider gptProvider) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
          color: AppColors.colorPrimaryLight,
          borderRadius: BorderRadius.circular(20)
      ),
      child: Text(
        gptProvider.reply,
        style: TextStyle(
          color: AppColors.colorWhiteHighEmp,
          fontSize: 16.sp,
        ),
      ),
    );
  }
}
