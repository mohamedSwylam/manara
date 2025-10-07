import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../constants/localization/messages.dart';
import '../../../constants/images.dart';
import '../../widgets/custom_toast_widget.dart';
import 'widgets/auth_button.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  String? _selectedSubject;

  final List<String> _subjects = [
    'general_inquiry'.tr,
    'technical_support'.tr,
    'feature_request'.tr,
    'bug_report'.tr,
    'feedback'.tr,
    'other'.tr,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement form submission logic
      Get.back();
      CustomToastWidget.show(
        context: context,
        title: "Your message has been sent",
        iconPath: AssetsPath.logo00102PNG,
        iconBackgroundColor: const Color(0xFF8D1B3D),
        backgroundColor: const Color(0xFFFFEFE8),
      );
    }
  }

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
          'contact_us'.tr,
          style: TextStyle(
            color: theme.textTheme.titleMedium?.color,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'contact_us_description'.tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: theme.textTheme.bodyMedium?.color,
                  height: 1.2,
                ),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 16.h),

            // Name Field
            _buildFieldTitle('your_name'.tr),
            SizedBox(height: 6.h),
            _buildTextField(
              controller: _nameController,
              hintText: 'enter_your_name'.tr,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'name_required'.tr;
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // Email Field
            _buildFieldTitle('email_address'.tr),
            SizedBox(height: 6.h),
            _buildTextField(
              controller: _emailController,
              hintText: 'enter_your_email'.tr,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'email_required'.tr;
                }
                if (!GetUtils.isEmail(value.trim())) {
                  return 'email_invalid'.tr;
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // Subject Field
            _buildFieldTitle('subject'.tr),
            SizedBox(height: 6.h),
            _buildDropdownField(),
            SizedBox(height: 16.h),

            // Message Field
            _buildFieldTitle('message'.tr),
            SizedBox(height: 6.h),
            _buildTextField(
              controller: _messageController,
              hintText: 'enter_your_message'.tr,
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'message_required'.tr;
                }
                if (value.trim().length < 10) {
                  return 'message_too_short'.tr;
                }
                return null;
              },
            ),
            SizedBox(height: 24.h),

            // Submit Button
            Center(
              child: AuthButton(
                text: 'submit'.tr,
                onPressed: _submitForm,
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildFieldTitle(String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'IBM Plex Sans Arabic',
        fontWeight: FontWeight.w500,
        fontSize: 12.sp,
        height: 1.0,
        color: theme.textTheme.titleMedium?.color,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return Container(
      height: maxLines == 1 ? 48.h : null,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines == 1 ? 1 : maxLines,
        validator: validator,
        style: TextStyle(
          color: theme.textTheme.bodyMedium?.color,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: theme.textTheme.bodySmall?.color,
            fontSize: 14.sp,
          ),
          filled: true,
          fillColor: theme.cardTheme.color,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: theme.dividerTheme.color ?? Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: theme.dividerTheme.color ?? Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: Color(0xFF8D1B3D)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: Colors.red),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          isDense: false,
          constraints: BoxConstraints(
            minHeight: 48.h,
            maxHeight: maxLines == 1 ? 48.h : double.infinity,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    final theme = Theme.of(context);
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: theme.dividerTheme.color ?? Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedSubject,
        style: TextStyle(
          color: theme.textTheme.bodyMedium?.color,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          isDense: false,
          constraints: BoxConstraints(
            minHeight: 48.h,
            maxHeight: 48.h,
          ),
        ),
        hint: Text(
          'select_subject'.tr,
          style: TextStyle(
            color: theme.textTheme.bodySmall?.color,
            fontSize: 14.sp,
          ),
        ),
        items: _subjects.map((String subject) {
          return DropdownMenuItem<String>(
            value: subject,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Text(
                subject,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedSubject = newValue;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'subject_required'.tr;
          }
          return null;
        },
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: theme.textTheme.bodySmall?.color,
          size: 20.sp,
        ),
        dropdownColor: theme.cardTheme.color,
        elevation: 4,
        borderRadius: BorderRadius.circular(8.r),
        menuMaxHeight: 200.h,
        isExpanded: true,
      ),
    );
  }
}
