import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../constants/images.dart';
import '../../../../data/bloc/auth/register_index.dart';
import '../../../../data/models/auth/login_request_model.dart';
import '../../../../data/viewmodel/more_screen_controller.dart';
import 'auth_button.dart';
import '../create_account_screen.dart';
import '../../auth/reset_password_screen.dart';
import '../../../widgets/custom_toast_widget.dart';
import '../../main_navigation.dart';

class AuthBottomSheet extends StatefulWidget {
  const AuthBottomSheet({super.key});

  @override
  State<AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends State<AuthBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.status == LoginStatus.success) {
            CustomToastWidget.show(
              context: context,
              title: 'Login successful! Welcome ${state.response?.userData.fullName??''}',
              iconPath: 'assets/images/user.svg',
              iconBackgroundColor: Colors.green,
            );
            Get.back(); // Close the bottom sheet
            // Refresh the more screen to show user data
            Get.find<MoreScreenController>().updateLoginStatus(true, userData: state.response?.userData);
          } else if (state.status == LoginStatus.error) {
            CustomToastWidget.show(
              context: context,
              title: state.errorMessage??'',
              iconPath: 'assets/images/email.svg',
              iconBackgroundColor: Colors.red,
            );
          }
        },
        child: _buildContent(theme),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        margin: EdgeInsets.only(top: 165.h),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Header with close button
                Padding(
                  padding: EdgeInsets.only(top: 16.h, right: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(
                          Icons.close, 
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Main content
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      // Title
                      Text(
                        'log_in_to_account'.tr,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w500,
                          fontSize: 24.sp,
                          height: 32.h / 24.sp,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: 8.h),
                      
                      // Subtitle
                      Text(
                        'login_or_create_account'.tr,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w400,
                          fontSize: 12.sp,
                          height: 16.h / 12.sp,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      // Google Sign In Button
                      Container(
                        width: 328.w,
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          border: Border.all(
                            color: theme.dividerTheme.color ?? const Color(0xFFE0E0E0), 
                            width: 1
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement Google sign in
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SvgPicture.asset(
                                AssetsPath.googleSVG,
                                width: 24.w,
                                height: 24.h,
                              ),
                              Text(
                                'continue_with_google'.tr,
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13.sp,
                                  height: 20.h / 13.sp,
                                  color: const Color(0xFF8D1B3D),
                                ),
                              ),
                              const SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 12.h),
                      
                      // Apple Sign In Button
                      Container(
                        width: 328.w,
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          border: Border.all(
                            color: theme.dividerTheme.color ?? const Color(0xFFE0E0E0), 
                            width: 1
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement Apple sign in
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SvgPicture.asset(
                                AssetsPath.appleSVG,
                                width: 24.w,
                                height: 24.h,
                                colorFilter: ColorFilter.mode(
                                  theme.brightness == Brightness.dark 
                                    ? Colors.grey[400]! 
                                    : Colors.black,
                                  BlendMode.srcIn,
                                ),
                              ),
                              Text(
                                'continue_with_apple'.tr,
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13.sp,
                                  height: 20.h / 13.sp,
                                  color: const Color(0xFF8D1B3D),
                                ),
                              ),
                              const SizedBox.shrink(),
                            ],
                          ),
                                                  ),
                        ),
                        
                        // Password error display
                        BlocBuilder<LoginBloc, LoginState>(
                          builder: (context, state) {
                            if (state.passwordError != null) {
                              return Padding(
                                padding: EdgeInsets.only(top: 4.h, left: 4.w),
                                child: Text(
                                  state.passwordError!,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        
                        SizedBox(height: 24.h),
                      
                      // Divider text
                      Text(
                        'or_sign_in_with_email'.tr,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w400,
                          fontSize: 12.sp,
                          height: 16.h / 12.sp,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      // Email field
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.dividerTheme.color ?? Colors.grey[300]!
                          ),
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
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                          decoration: InputDecoration(
                            hintText: 'email_address'.tr,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            hintStyle: TextStyle(
                              fontSize: 14.sp,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ),
                      ),
                      
                      // Email error display
                      BlocBuilder<LoginBloc, LoginState>(
                        builder: (context, state) {
                          if (state.emailError != null) {
                            return Padding(
                              padding: EdgeInsets.only(top: 4.h, left: 4.w),
                              child: Text(
                                state.emailError!,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.sp,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      
                      SizedBox(height: 4.h),
                      
                      // Password field
                      BlocBuilder<LoginBloc, LoginState>(
                        builder: (context, state) {
                          final bool _obscurePassword = state.isPasswordVisible;

                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.dividerTheme.color ?? Colors.grey[300]!
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'password_required'.tr;
                                }
                                if (value.length < 6) {
                                  return 'password_min_length'.tr;
                                }
                                return null;
                              },
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                              decoration: InputDecoration(
                                hintText: 'password'.tr,
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
                                    BlocProvider.of<LoginBloc>(context).add(const ToggleLoginPasswordVisibility());
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      // Login button
                      BlocBuilder<LoginBloc, LoginState>(
                        builder: (context, state) {
                          return AuthButton(
                            onPressed: state.status == LoginStatus.loading ? () {} : () {
                              if (_formKey.currentState!.validate()) {
                                final request = LoginRequestModel(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                  oneSignalId: "onesignal-xxxxx", // TODO: Get from OneSignal service
                                );
                                context.read<LoginBloc>().add(LoginUser(request: request));
                              }
                            },
                            text: state.status == LoginStatus.loading ? 'Logging in...' : 'log_in'.tr,
                          );
                        },
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // Bottom row with sign up and reset password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left side - Sign up text
                          Row(
                            children: [
                              Text(
                                'dont_have_account'.tr,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              GestureDetector(
                                onTap: () {
                                  Get.back(); // Close the bottom sheet first
                                  Get.to(() => const CreateAccountScreen());
                                },
                                child: Text(
                                  'sign_up'.tr,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF8D1B3D),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          // Right side - Reset password
                          GestureDetector(
                            onTap: () {
                              Get.back(); // Close the bottom sheet first
                              Get.to(() => const ResetPasswordScreen());
                            },
                            child: Text(
                              'reset_password'.tr,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF8D1B3D),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // Privacy policy text
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: theme.textTheme.bodySmall?.color,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(text: 'by_logging_in_you_agree'.tr),
                            const TextSpan(text: ' '),
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
                            const TextSpan(text: ' '),
                            TextSpan(text: 'and'.tr),
                            const TextSpan(text: ' '),
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
              ],
            ),
          ),
        ),
      );
  }
}
