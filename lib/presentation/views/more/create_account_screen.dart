import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/bloc/auth/register_index.dart';
import '../../../../data/models/auth/register_request_model.dart';
import '../../widgets/custom_toast_widget.dart';
import 'widgets/auth_button.dart';
import '../main_navigation.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (context) => RegisterBloc(),
              child: BlocListener<RegisterBloc, RegisterState>(
          listener: (context, state) {
            if (state is RegisterSuccess) {
              // Show success message
              CustomToastWidget.show(
                context: context,
                title: 'Registration successful! Welcome ${state.response.userData.fullName}',
                iconPath: 'assets/images/success_icon.svg',
                iconBackgroundColor: Colors.green,
              );
              
              // Navigate to home or next screen
              Get.offAll(() => MainNavigation());
            } else if (state is RegisterError) {
              // Show error message
              CustomToastWidget.show(
                context: context,
                title: state.message,
                iconPath: 'assets/images/error_icon.svg',
                iconBackgroundColor: Colors.red,
              );
            }
          },
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: theme.iconTheme.color,
            ),
            onPressed: () => Get.back(),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),
                
                // Title
                Text(
                  'create_account'.tr,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w500,
                    fontSize: 22.sp,
                    height: 32.h / 24.sp,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
                
                SizedBox(height: 8.h),
                
                // Subtitle
                Text(
                  'create_account_subtitle'.tr,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    height: 20.h / 14.sp,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                
                SizedBox(height: 28.h),
                
                // Your name title
                Text(
                  'your_name'.tr,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    height: 20.h / 14.sp,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
                
                SizedBox(height: 8.h),
                
                // Name text field
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    border: Border.all(color: theme.dividerTheme.color ?? Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'name_required'.tr;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'enter_your_name'.tr,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                // Email address title
                Text(
                  'email_address'.tr,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    height: 20.h / 14.sp,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
                
                SizedBox(height: 8.h),
                
                // Email text field
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    border: Border.all(color: theme.dividerTheme.color ?? Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'email_required'.tr;
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'email_invalid'.tr;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'enter_your_email'.tr,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                // Your password title
                Text(
                  'your_password'.tr,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    height: 20.h / 14.sp,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
                
                SizedBox(height: 8.h),
                
                // Password text field with BLoC
                BlocBuilder<RegisterBloc, RegisterState>(
                  builder: (context, state) {
                    if (state is! RegisterFormState) return const SizedBox.shrink();
                    final bool _obscurePassword = state.isPasswordVisible;
                    return Container(
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        border: Border.all(color: theme.dividerTheme.color ?? Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'password_required'.tr;
                          }
                          if (value.length < 8) {
                            return 'password_8_characters'.tr;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'minimum_8_characters'.tr,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                            onPressed: () {
                              BlocProvider.of<RegisterBloc>(context).add(const ToggleRegisterPasswordVisibility());
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                SizedBox(height: 24.h),
                
                // Confirm password title
                Text(
                  'confirm_password'.tr,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    height: 20.h / 14.sp,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
                
                SizedBox(height: 8.h),
                
                // Confirm password text field
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    border: Border.all(color: theme.dividerTheme.color ?? Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'confirm_password_required'.tr;
                      }
                      if (value != _passwordController.text) {
                        return 'passwords_not_match'.tr;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'confirm_your_password'.tr,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 100.h),
                
                // Sign up button
                BlocBuilder<RegisterBloc, RegisterState>(
                  builder: (context, state) {
                    return Center(
                      child: AuthButton(
                        onPressed: state is RegisterLoading ? () {} : () {
                          if (_formKey.currentState!.validate()) {
                            // Create register request
                            final request = RegisterRequestModel(
                              fullName: _nameController.text.trim(),
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                              oneSignalId: "onesignal-xxxxx", // TODO: Get from OneSignal service
                            );
                            
                            // Trigger registration
                            context.read<RegisterBloc>().add(RegisterUser(request: request));
                          }
                        },
                        text: state is RegisterLoading ? 'Creating Account...' : 'sign_up'.tr,
                      ),
                    );
                  },
                ),
                
                SizedBox(height: 24.h),
                
                // Privacy policy text
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.textTheme.bodySmall?.color,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(text: 'by_signing_up_you_agree'.tr),
                      TextSpan(
                        text: 'privacy_policy'.tr,
                        style: const TextStyle(
                          color: Color(0xFF8D1B3D),
                          fontWeight: FontWeight.w700,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // TODO: Navigate to privacy policy
                          },
                      ),
                      TextSpan(text: 'and'.tr),
                      TextSpan(
                        text: 'user_agreement'.tr,
                        style: const TextStyle(
                          color: Color(0xFF8D1B3D),
                          fontWeight: FontWeight.w700,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // TODO: Navigate to user agreement
                          },
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
          ),
        ),
      );
  }
}
