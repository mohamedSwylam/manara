import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/colors.dart';
import '../../../data/viewmodel/Providers/gpt_provider.dart';
import '../../../data/viewmodel/Providers/location_provider.dart';
import '../../../constants/images.dart';
import '../../widgets/functions_and_methods.dart';
import '../../widgets/app_background_image_widget.dart';
import '../../widgets/form_field_widget.dart';
import 'generated_name_screen.dart';

class IslamicBabyNameScreen extends StatefulWidget {
  const IslamicBabyNameScreen({super.key});

  @override
  State<IslamicBabyNameScreen> createState() => _IslamicBabyNameScreenState();
}

class _IslamicBabyNameScreenState extends State<IslamicBabyNameScreen> {
  final TextEditingController initialLetterController = TextEditingController();
  String? selectedType;
  List<String> typeList = ['Boy baby', 'Girl baby'];

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    initialLetterController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gptProvider = Provider.of<GPTProvider>(context, listen: false);
    final provider = Provider.of<LocationProvider>(context, listen: false);
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          AppBackgroundImageWidget(bgImagePath: AssetsPath.secondaryBGSVG),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50.h),
                appbarWidget(),
                SizedBox(height: 30.h),
                _buildDropDownField(),
                SizedBox(height: 20.h),
                _buildInputField(),
                SizedBox(height: 46.h),
                _buildGeneratedButton(gptProvider, context)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget appbarWidget() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
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
            color: AppColors.colorWhiteHighEmp,
          ),
        )
      ],
    );
  }

  Widget _buildDropDownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "name_type".tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16.sp,
            color: AppColors.colorWhiteHighEmp,
          ),
        ),
        SizedBox(height: 6.h),
        DropdownButtonFormField<String>(
          value: selectedType,
          onChanged: (String? newValue) {
            // You can update the state or perform any other actions here
            setState(() {
              selectedType = newValue!;
            });
          },
          hint: Text(
            'name_type'.tr,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.colorDisabled,
            ),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.colorWhiteHighEmp,
            contentPadding: const EdgeInsets.fromLTRB(16, -0, 16, -0),
            // sets the padding for the text input field content
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.colorWhiteHighEmp,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.colorWhiteHighEmp,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.colorPrimary,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.colorPrimary,
                width: 1,
              ),
            ),
          ),
          items: typeList.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInputField() {
    return FormFieldWidget(
      formTitle: 'initial_letter'.tr,
      hintText: 'eg. A/B/C',
      controller: initialLetterController,
      keyboardType: TextInputType.text,
      obscureText: false,
    );
  }

  Widget _buildGeneratedButton(GPTProvider gptProvider, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? language = prefs.getString('language') ?? 'en';
        final String? apiKey = dotenv.env['chatGPT_Api'];
        if (selectedType != null) {
          if (initialLetterController.text.isNotEmpty) {
            if (initialLetterController.text.length >= 2) {
              makeSnack(
                  "Initial letter should not be more than one letter");
            } else {
              _loaderDialog();
              final allOk = await gptProvider.sendCompilation(selectedType!,
                  initialLetterController.text, apiKey!, language);
              if (allOk) {
                _dismissLoader();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GeneratedNameScreen(),
                  ),
                );
              }else{
                _dismissLoader();
                makeSnack("Something went wrong! Please try again later.");
              }
            }
          } else {
            makeSnack(
                "Enter initial letter");
          }
        } else {
          makeSnack("Select a type");
        }
      },
      child: Container(
        height: 55.h,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: AppColors.indicatorColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Center(
          child: Text(
            "generate".tr,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  //Custom loader showing while request ongoing
  void _loaderDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            height: 90.w,
            width: 90.w,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.colorPrimary),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.colorWhiteHighEmp,
              ),
            ),
          ),
        );
      },
    );
  }

  //Dismiss custom loader after request done
  void _dismissLoader() {
    Navigator.pop(context);
  }
}
