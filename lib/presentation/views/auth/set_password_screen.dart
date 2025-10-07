import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../constants/images.dart';
import '../more/widgets/auth_button.dart';
import '../../widgets/custom_toast_widget.dart';
import '../../../data/bloc/auth/change_password_index.dart';
import '../../../data/models/auth/change_password_request_model.dart';



class SetPasswordScreen extends StatefulWidget {
  final bool isChangePassword;
  
  const SetPasswordScreen({
    super.key,
    this.isChangePassword = false,
  });

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChangePasswordBloc(),
      child: BlocListener<ChangePasswordBloc, ChangePasswordState>(
        listener: (context, state) {
                     if (state is ChangePasswordSuccess) {
             // Show success message
             CustomToastWidget.show(
               context: context,
               title: 'password_changed_successfully'.tr,
               iconPath: AssetsPath.logo00102PNG,
               iconBackgroundColor: const Color(0xFF8D1B3D),
             );
             // Navigate back with success result
             Get.back(result: true);
           } else if (state is ChangePasswordFailure) {
             // Show error message
             CustomToastWidget.show(
               context: context,
               title: state.error,
               iconPath: AssetsPath.logo00102PNG,
               iconBackgroundColor: Colors.red,
             );
           }
        },
        child: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return Scaffold(
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
            body: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 24.h),

                            // Title
                            Text(
                              widget.isChangePassword
                                  ? 'change_password'.tr
                                  : 'add_password'.tr,
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontWeight: FontWeight.w500,
                                fontSize: 24.sp,
                                height: 32.h / 24.sp,
                                color: theme.textTheme.titleLarge?.color,
                              ),
                            ),

                            SizedBox(height: 16.h),

                            // Subtitle text
                            Text(
                              'password_requirements'.tr,
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontWeight: FontWeight.w400,
                                fontSize: 13.sp,
                                height: 20.h / 13.sp,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),

                            SizedBox(height: 32.h),

                            // Current password field (only for change password)
                            if (widget.isChangePassword) ...[
                              Text(
                                'current_password'.tr,
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12.sp,
                                  height: 16.h / 12.sp,
                                  color: theme.textTheme.titleMedium?.color,
                                ),
                              ),

                              SizedBox(height: 8.h),

                              BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
                                builder: (context, state) {
                                  if (state is ChangePasswordFormState) {
                                    return Container(
                                    decoration: BoxDecoration(
                                      color: theme.cardTheme.color,
                                      border: Border.all(color: theme.dividerTheme.color ?? Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: TextFormField(
                                      controller: _currentPasswordController,
                                      obscureText: !state.isCurrentPasswordVisible,
                                      style: TextStyle(
                                        color: theme.textTheme.bodyMedium?.color,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'current_password_required'.tr;
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'enter_current_password'.tr,
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16.w, vertical: 12.h),
                                        hintStyle: TextStyle(
                                          fontSize: 14.sp,
                                          color: theme.textTheme.bodySmall?.color,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            state.isCurrentPasswordVisible ? Icons
                                                .visibility : Icons.visibility_off,
                                            color: theme.textTheme.bodySmall?.color,
                                          ),
                                          onPressed: () {
                                            context
                                                .read<ChangePasswordBloc>()
                                                .add(const ToggleChangePasswordVisibility('current'));
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),

                              SizedBox(height: 24.h),
                            ],

                            // New password label
                            Text(
                              'new_password'.tr,
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontWeight: FontWeight.w500,
                                fontSize: 12.sp,
                                height: 16.h / 12.sp,
                                color: theme.textTheme.titleMedium?.color,
                              ),
                            ),

                            SizedBox(height: 8.h),

                            // New password text field
                            BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
                              builder: (context, state) {
                                if (state is ChangePasswordFormState) {
                                  return Container(
                                  decoration: BoxDecoration(
                                    color: theme.cardTheme.color,
                                    border: Border.all(color: theme.dividerTheme.color ?? Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: TextFormField(
                                    controller: _newPasswordController,
                                    obscureText: !state.isNewPasswordVisible,
                                    style: TextStyle(
                                      color: theme.textTheme.bodyMedium?.color,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'new_password_required'.tr;
                                      }
                                      if (value.length < 8) {
                                        return 'password_min_length'.tr;
                                      }
                                      if (!RegExp(
                                          r'^(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>])')
                                          .hasMatch(value)) {
                                        return 'password_complexity'.tr;
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'enter_new_password'.tr,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16.w, vertical: 12.h),
                                      hintStyle: TextStyle(
                                        fontSize: 14.sp,
                                        color: theme.textTheme.bodySmall?.color,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          state.isNewPasswordVisible ? Icons
                                              .visibility : Icons.visibility_off,
                                          color: theme.textTheme.bodySmall?.color,
                                        ),
                                        onPressed: () {
                                          context
                                              .read<ChangePasswordBloc>()
                                              .add(const ToggleChangePasswordVisibility('new'));
                                        },
                                      ),
                                    ),
                                  ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),

                            SizedBox(height: 24.h),

                            // Confirm password label
                            Text(
                              'confirm_new_password'.tr,
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontWeight: FontWeight.w500,
                                fontSize: 12.sp,
                                height: 16.h / 12.sp,
                                color: theme.textTheme.titleMedium?.color,
                              ),
                            ),

                            SizedBox(height: 8.h),

                            // Confirm password text field
                            BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
                              builder: (context, state) {
                                if (state is ChangePasswordFormState) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: theme.cardTheme.color,
                                      border: Border.all(
                                          color: theme.dividerTheme.color ??
                                              Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: TextFormField(
                                      controller: _confirmPasswordController,
                                      obscureText: !state
                                          .isConfirmPasswordVisible,
                                      style: TextStyle(
                                        color: theme.textTheme.bodyMedium
                                            ?.color,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'confirm_password_required'.tr;
                                        }
                                        if (value !=
                                            _newPasswordController.text) {
                                          return 'passwords_not_match'.tr;
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'confirm_password'.tr,
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16.w, vertical: 12.h),
                                        hintStyle: TextStyle(
                                          fontSize: 14.sp,
                                          color: theme.textTheme.bodySmall
                                              ?.color,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            state.isConfirmPasswordVisible
                                                ? Icons
                                                .visibility
                                                : Icons.visibility_off,
                                            color: theme.textTheme.bodySmall
                                                ?.color,
                                          ),
                                          onPressed: () {
                                            context
                                                .read<ChangePasswordBloc>()
                                                .add(
                                                const ToggleChangePasswordVisibility(
                                                    'confirm'));
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),

                            SizedBox(height: 32.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                                 // Save button at the bottom
                 Padding(
                   padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                   child: AuthButton(
                                           onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (widget.isChangePassword) {
                            // Use the BLoC to handle password change
                            final request = ChangePasswordRequestModel(
                              currentPassword: _currentPasswordController.text,
                              newPassword: _newPasswordController.text,
                              newPasswordConfirmation: _confirmPasswordController.text,
                            );
                            
                            context.read<ChangePasswordBloc>().add(ChangePasswordSubmitted(request));
                          } else {
                            // For setting new password (not implemented in this version)
                            Get.snackbar(
                              'Error',
                              'Setting new password not implemented'.tr,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        }
                      },
                     text: widget.isChangePassword
                         ? 'update_password'.tr
                         : 'save'.tr,
                   ),
                 ),
              ],
            ),
          );
        }),
      ));
  }
   }


