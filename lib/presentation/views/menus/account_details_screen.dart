import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'dart:convert'; // Added for jsonDecode
import '../../../constants/images.dart';
import '../../../data/services/password_service.dart';
import '../../../data/utility/secure_storage_manager.dart';
import '../../../data/models/auth/login_response_model.dart';
import '../../../data/viewmodel/more_screen_controller.dart';
import '../../widgets/custom_dialog_widget.dart';
import '../../widgets/custom_toast_widget.dart';
import 'update_name_screen.dart';
import 'update_email_screen.dart';
import '../auth/set_password_screen.dart';

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  bool _isPasswordSet = false;
  String _lastPasswordChange = '';
  UserData? _userData;
  final MoreScreenController _moreScreenController = Get.find<MoreScreenController>();

  @override
  void initState() {
    super.initState();
    _checkPasswordStatus();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userDataJson = await SecureStorageManager.getUserData();
    if (userDataJson != null) {
      try {
        final userData = UserData.fromJson(jsonDecode(userDataJson));
        setState(() {
          _userData = userData;
        });
      } catch (e) {
        print('Error parsing user data: $e');
      }
    }
  }

  Future<void> _checkPasswordStatus() async {
    final isSet = await PasswordService.isPasswordSet();
    final setDate = await PasswordService.getPasswordSetDate();
    
    setState(() {
      _isPasswordSet = isSet;
      if (setDate != null) {
        _lastPasswordChange = PasswordService.formatDate(setDate);
      }
    });
  }

  void _handlePasswordTap() async {
    // Always navigate to SetPasswordScreen for editing
    final result = await Get.to(() => const SetPasswordScreen(isChangePassword: true));
    if (result == true) {
      // Refresh password status after change
      _checkPasswordStatus();
    }
  }

  Future<void> _handleLogout() async {
    await _moreScreenController.logout();
    Get.back(); // Go back to previous screen
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
          'account_details'.tr,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
            color: theme.textTheme.titleMedium?.color,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top row with profile image and user info
            Container(
              margin: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  // Profile image with edit button
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 30.r,
                        backgroundImage: _userData?.fileUrl.originalUrl.isNotEmpty == true
                            ? NetworkImage(_userData!.fileUrl.originalUrl)
                            : AssetImage(AssetsPath.profileAvatarPNG) as ImageProvider,
                      ),
                         Positioned(
                         bottom: 0,
                         right: 0,
                         child: Container(
                           padding: EdgeInsets.all(4.w),
                           decoration: const BoxDecoration(
                             color: Color(0x8bffffff),
                             shape: BoxShape.circle,
                           ),
                           child: SvgPicture.asset(
                             AssetsPath.editSVG,
                             width: 16.w,
                             height: 16.h,
                           ),
                         ),
                       ),
                    ],
                  ),
                  SizedBox(width: 16.w),
                  // User info column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                                                 Text(
                           _userData?.fullName ?? 'user_name'.tr,
                           style: TextStyle(
                             fontFamily: 'IBM Plex Sans Arabic',
                             fontWeight: FontWeight.w700,
                             fontSize: 17.sp,
                             height: 24.h / 17.sp,
                             color: theme.textTheme.titleLarge?.color,
                           ),
                         ),
                         SizedBox(height: 4.h),
                         Text(
                           _userData?.id ?? 'user_id'.tr,
                           style: TextStyle(
                             fontFamily: 'IBM Plex Sans Arabic',
                             fontWeight: FontWeight.w400,
                             fontSize: 11.sp,
                             height: 16.h / 11.sp,
                             color: theme.textTheme.bodySmall?.color,
                           ),
                         ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

                         // Profile card
             Container(
               margin: EdgeInsets.symmetric(horizontal: 16.w),
               decoration: BoxDecoration(
                 color: theme.cardTheme.color,
                 borderRadius: BorderRadius.circular(10),
                 border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFEAEAEA), width: 1),
               ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                                         Text(
                       'your_profile'.tr,
                       style: TextStyle(
                         fontFamily: 'IBM Plex Sans Arabic',
                         fontWeight: FontWeight.w600,
                         fontSize: 16.sp,
                         height: 24.h / 16.sp,
                         color: theme.textTheme.titleMedium?.color,
                       ),
                     ),
                    SizedBox(height: 16.h),

                    // Username row
                    _buildProfileRow(
                      iconPath: AssetsPath.userSVG,
                      text: _userData?.fullName ?? 'User Name',
                      valid: _userData?.fullName != null && _userData!.fullName.isNotEmpty,
                      rightWidget: GestureDetector(
                        onTap: () {
                          Get.to(() => const UpdateNameScreen());
                        },
                        child: Text(
                          'edit'.tr,
                          style: TextStyle(
                            color: const Color(0xFF8D1B3D),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    const Divider(),
                    SizedBox(height: 8.h),
                    
                                         // Email row
                     _buildProfileRow(
                       iconPath: AssetsPath.emailSVG,
                       text: _userData?.email ?? 'user_email'.tr,
                       valid : _userData?.email != null && _userData!.email.isNotEmpty,
                       rightWidget: GestureDetector(
                         onTap: () {
                           Get.to(() => const UpdateEmailScreen());
                         },
                         child: Text(
                           'edit'.tr,
                           style: TextStyle(
                             color: const Color(0xFF8D1B3D),
                             fontSize: 14.sp,
                             fontWeight: FontWeight.w700,
                           ),
                         ),
                       ),
                     ),

                    SizedBox(height: 8.h),
                    const Divider(),
                    SizedBox(height: 8.h),
                    
                    // Password row
                    _buildProfileRow(
                      iconPath: AssetsPath.passwordSVG,
                      text: '***********',
                      valid: _isPasswordSet,
                      rightWidget: GestureDetector(
                        onTap: _handlePasswordTap,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'change'.tr,
                              style: TextStyle(
                                color: const Color(0xFF8D1B3D),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (_isPasswordSet && _lastPasswordChange.isNotEmpty) ...[
                              SizedBox(height: 4.h),
                                                             Text(
                                 _lastPasswordChange,
                                 style: TextStyle(
                                   fontSize: 11.sp,
                                   color: theme.textTheme.bodySmall?.color,
                                 ),
                               ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),

                         // Connected Accounts card
             Container(
               margin: EdgeInsets.symmetric(horizontal: 16.w),
               decoration: BoxDecoration(
                 color: theme.cardTheme.color,
                 borderRadius: BorderRadius.circular(10),
                 border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFEAEAEA), width: 1),
               ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                                         Text(
                       'connected_accounts'.tr,
                       style: TextStyle(
                         fontFamily: 'IBM Plex Sans Arabic',
                         fontWeight: FontWeight.w600,
                         fontSize: 16.sp,
                         height: 24.h / 16.sp,
                         color: theme.textTheme.titleMedium?.color,
                       ),
                     ),
                    SizedBox(height: 16.h),
                    
                    // Google row
                    _buildConnectedAccountRow(
                      imagePath: AssetsPath.googleSVG,
                      text: 'connected_with_google'.tr,
                      isConnected: true,
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Apple row
                    _buildConnectedAccountRow(
                      imagePath: AssetsPath.appleSVG,
                      text: 'connected_with_apple'.tr,
                      isConnected: true,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),

                         // Authorized Devices card
             Container(
               margin: EdgeInsets.symmetric(horizontal: 16.w),
               decoration: BoxDecoration(
                 color: theme.cardTheme.color,
                 borderRadius: BorderRadius.circular(10),
                 border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFEAEAEA), width: 1),
               ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                                         Text(
                       'authorized_devices'.tr,
                       style: TextStyle(
                         fontFamily: 'IBM Plex Sans Arabic',
                         fontWeight: FontWeight.w600,
                         fontSize: 16.sp,
                         height: 24.h / 16.sp,
                         color: theme.textTheme.titleMedium?.color,
                       ),
                     ),
                    SizedBox(height: 16.h),
                    
                    // Current device row
                    _buildDeviceRow(
                      deviceName: 'Pixel 8',
                      deviceType: 'this_device'.tr,
                      showDelete: false,
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Other device row
                    _buildDeviceRow(
                      deviceName: 'iPhone 15',
                      deviceType: 'iOS',
                      showDelete: true,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 32.h),

            // Action buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  // Save Changes button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement save changes
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8D1B3D),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'save_changes'.tr,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Log out button
                  GestureDetector(
                    onTap: () => _handleLogout(),
                    child: Container(
                      width: 328.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 16.w),
                          Icon(
                            Icons.logout,
                            size: 20.sp,
                            color: const Color(0xFFE33C3C),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'log_out'.tr,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFE33C3C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Delete Account button
                  GestureDetector(
                    onTap: () {
                      _showDeleteAccountDialog();
                    },
                    child: Container(
                      width: 328.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 16.w),
                          SvgPicture.asset(
                            AssetsPath.basketSVG,
                            width: 20.w,
                            height: 20.h,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFFE33C3C),
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'delete_account'.tr,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFE33C3C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

           Widget _buildProfileRow({
      required String iconPath,
      required String text,
      required Widget rightWidget, required bool valid,
    }) {
      final theme = Theme.of(context);
      return Row(
        children: [
          SvgPicture.asset(
            iconPath,
            width: 20.w,
            height: 20.h,
            colorFilter: ColorFilter.mode(
              theme.textTheme.bodyMedium?.color ?? Colors.black,
              BlendMode.srcIn,
            ),
          ),
         SizedBox(width: 12.w),
         Text(
           text,
           style: TextStyle(
             fontSize: 14.sp,
             fontWeight: FontWeight.w600,
             color: theme.textTheme.bodyMedium?.color,
           ),
         ),
         valid?Icon(
           Icons.check,
           color: Colors.green,
           size: 16.sp,
         ):const SizedBox(),
         const Spacer(),
         rightWidget,
       ],
     );
   }

           Widget _buildConnectedAccountRow({
      required String imagePath,
      required String text,
      required bool isConnected,
    }) {
      final theme = Theme.of(context);
      return GestureDetector(
        onTap: () {
          if (isConnected) {
            _showDisconnectDialog(text);
          }
        },
        child: Row(
          children: [
            SvgPicture.asset(
              imagePath,
              width: 24.w,
              height: 24.h,
              colorFilter: imagePath.contains('apple') 
                ? ColorFilter.mode(
                    theme.brightness == Brightness.dark 
                      ? Colors.grey[400]! 
                      : Colors.black,
                    BlendMode.srcIn,
                  )
                : null,
            ),
           SizedBox(width: 12.w),
           Expanded(
             child: Text(
               text,
               style: TextStyle(
                 fontSize: 14.sp,
                 color: theme.textTheme.bodyMedium?.color,
               ),
             ),
           ),
           if (isConnected)
             Icon(
               Icons.check,
               color: Colors.green,
               size: 20.sp,
             ),
         ],
       ),
     );
   }

  void _showDisconnectDialog(String accountType) {
    CustomDialogWidget.show(
      context: context,
      title: "disconnect_account_dialog_title".tr,
      firstChoiceText: "disconnect_account".tr,
      secondChoiceText: "cancel".tr,
      onFirstChoicePressed: () {
        Navigator.of(context).pop();
        _handleDisconnectAccount(accountType);
      },
      onSecondChoicePressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  void _handleDisconnectAccount(String accountType) {
    // TODO: Implement actual disconnect logic
    print("Disconnecting $accountType account");
    
    // Show success message
    CustomToastWidget.show(
      context: context,
      title: "$accountType ${'account_disconnected_successfully'.tr}",
      iconPath: AssetsPath.logo00102PNG,
      iconBackgroundColor: const Color(0xFF8D1B3D),
      backgroundColor: const Color(0xFFFFEFE8),
    );
  }

     Widget _buildDeviceRow({
     required String deviceName,
     required String deviceType,
     required bool showDelete,
   }) {
     final theme = Theme.of(context);
     return Row(
       children: [
         Icon(
           Icons.phone_android,
           size: 20.sp,
           color: theme.textTheme.bodySmall?.color,
         ),
         SizedBox(width: 12.w),
         Expanded(
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(
                 deviceName,
                 style: TextStyle(
                   fontSize: 14.sp,
                   color: theme.textTheme.bodyMedium?.color,
                   fontWeight: FontWeight.w500,
                 ),
               ),
               Text(
                 deviceType,
                 style: TextStyle(
                   fontSize: 12.sp,
                   color: theme.textTheme.bodySmall?.color,
                 ),
               ),
             ],
           ),
         ),
        if (showDelete)
          IconButton(
            onPressed: () {
              _showRemoveDeviceDialog(deviceName);
            },
                         icon: Container(
               width: 32.w,
               height: 32.h,
               decoration: BoxDecoration(
                 color: theme.cardTheme.color,
                 borderRadius: BorderRadius.circular(10),
                 border: Border.all(
                   color: theme.dividerTheme.color ?? const Color(0xFFE0E0E0),
                   width: 1,
                 ),
                 boxShadow: [
                   BoxShadow(
                     color: const Color(0xFF1C2932).withValues(alpha: 0.1),
                     offset: const Offset(0, 2),
                     blurRadius: 8,
                   ),
                 ],
               ),
              padding: EdgeInsets.all(8.w),
              child: SvgPicture.asset(
                AssetsPath.basketSVG,
                width: 16.w,
                height: 16.h,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFE33C3C),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showRemoveDeviceDialog(String deviceName) {
    CustomDialogWidget.show(
      context: context,
      title: "${'remove_device_dialog_title'.tr} $deviceName?",
      subtitle: "remove_device_dialog_subtitle".tr,
      firstChoiceText: "remove".tr,
      secondChoiceText: "cancel".tr,
      onFirstChoicePressed: () {
        Navigator.of(context).pop();
        _handleRemoveDevice(deviceName);
      },
      onSecondChoicePressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  void _handleRemoveDevice(String deviceName) {
    // TODO: Implement actual device removal logic
    print("Removing device: $deviceName");
    
    // Show success message
    CustomToastWidget.show(
      context: context,
      title: "$deviceName ${'device_removed_successfully'.tr}",
      iconPath: AssetsPath.logo00102PNG,
      iconBackgroundColor: const Color(0xFF8D1B3D),
      backgroundColor: const Color(0xFFFFEFE8),
    );
  }

  void _showDeleteAccountDialog() {
    CustomDialogWidget.show(
      context: context,
      title: "delete_account_dialog_title".tr,
      subtitle: "delete_account_dialog_subtitle".tr,
      firstChoiceText: "delete_account_button".tr,
      secondChoiceText: "cancel".tr,
      onFirstChoicePressed: () {
        Navigator.of(context).pop();
        _handleDeleteAccount();
      },
      onSecondChoicePressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  void _handleDeleteAccount() {
    // TODO: Implement actual account deletion logic
    print("Deleting Manara account");
    
    // Show success message
    CustomToastWidget.show(
      context: context,
      title: "account_deleted_successfully".tr,
      iconPath: AssetsPath.logo00102PNG,
      iconBackgroundColor: const Color(0xFF8D1B3D),
      backgroundColor: const Color(0xFFFFEFE8),
    );
  }
}
