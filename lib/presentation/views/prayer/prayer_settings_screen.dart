import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../constants/colors.dart';
import '../../../constants/fonts_weights.dart';
import '../../../constants/images.dart';
import '../../../data/bloc/prayer_settings/prayer_settings_bloc.dart';
import '../../../data/models/adhan_sound_model.dart';
import '../../../data/bloc/prayer_times_bloc.dart';
import '../../../data/bloc/location_settings/location_settings_bloc.dart';
import '../../../data/services/location_service.dart';
import 'location_settings_screen.dart';
import '../../widgets/custom_toast_widget.dart';

class PrayerSettingsScreen extends StatefulWidget {
  const PrayerSettingsScreen({super.key});

  @override
  State<PrayerSettingsScreen> createState() => _PrayerSettingsScreenState();
}

class _PrayerSettingsScreenState extends State<PrayerSettingsScreen> {
  final List<AdhanSoundModel> _adhanSounds = [
    AdhanSoundModel(name: 'Default Ringtone', assetPath: ''),
    AdhanSoundModel(name: 'Long Beep', assetPath: ''),
    AdhanSoundModel(name: 'Athan (Dousary)', assetPath: 'assets/azan/azan_dousary.mp3'),
    AdhanSoundModel(name: 'Athan (Makkah)', assetPath: 'assets/azan/azan_makah.mp3'),
    AdhanSoundModel(name: 'Athan (Madina)', assetPath: 'assets/azan/azan_madinah.mp3'),
    AdhanSoundModel(name: 'Athan (Nasser Al Qatami)', assetPath: 'assets/azan/azan_naser.mp3'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = PrayerSettingsBloc();
        bloc.add(LoadPrayerSettings());
        return bloc;
      },
      child: Consumer<LocationService>(
        builder: (context, locationService, child) {
          return BlocBuilder<PrayerSettingsBloc, PrayerSettingsState>(
            builder: (context, state) {
              // Load settings if we're in initial state
              if (state is PrayerSettingsInitial) {
                return _buildScaffold(const Center(child: CircularProgressIndicator()));
              }
              
              if (state is PrayerSettingsLoading) {
                return _buildScaffold(const Center(child: CircularProgressIndicator()));
              }
              
              if (state is PrayerSettingsError) {
                return _buildScaffold(Center(child: Text(state.message)));
              }
              
              if (state is PrayerSettingsLoaded) {
                return _buildScaffold(
                  Column(
                    children: [
                      // Notification Banner
                      if (state.showNotificationBanner) _buildNotificationBanner(context),
                      
                      // Main Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            children: [
                              // Current Location Card
                              _buildLocationCard(context, locationService.currentLocation),
                              
                              SizedBox(height: 16.h),
                              
                              // Notifications Toggle
                              _buildNotificationsToggle(context, state.notificationsEnabled),

                              SizedBox(height: 16.h),

                              // Notifications Sound Card
                              _buildNotificationsSoundCard(context, state.selectedAdhanSound, state.customRingtones),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return _buildScaffold(const SizedBox());
            },
          );
        },
      ),
    );
  }

  Widget _buildScaffold(Widget body) {
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
            size: 24.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Prayer Settings',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeights.semiBold,
            color: theme.textTheme.titleMedium?.color,
          ),
        ),
        centerTitle: true,
      ),
      body: body,
    );
  }

  Widget _buildNotificationBanner(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      height: 80.h,
      width: double.infinity,
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: SvgPicture.asset(
              AssetsPath.pannerbgSVG,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  transform: GradientRotation(153.53 * 3.14159 / 180),
                  colors: [
                    Color(0xFF916B46),
                    Color(0x00926B45),
                  ],
                  stops: [0.0755, 0.9885],
                ),
              ),
            ),
          ),
          
          // Content overlay
          Container(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                // Bell Icon
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    color: const Color(0xFF8D1B3D),
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 8.w),
                
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't miss any prayer reminders,",
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeights.medium,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "tap to enable notifications",
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeights.regular,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Enable Button
                ElevatedButton(
                  onPressed: () async {
                    final status = await Permission.notification.request();
                    if (status.isGranted) {
                      final bloc = BlocProvider.of<PrayerSettingsBloc>(context);
                      bloc.add(const ToggleNotifications(true));
                      bloc.add(DismissNotificationBanner());
                      CustomToastWidget.show(
                        context: context,
                        title: "Notifications enabled successfully",
                        iconPath: AssetsPath.logo00102PNG,
                        iconBackgroundColor: const Color(0xFF8D1B3D),
                        backgroundColor: const Color(0xFFFFEFE8),
                      );
                    } else {
                      await AppSettings.openAppSettings();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF8D1B3D),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  ),
                  child: Text(
                    'Enable',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeights.medium,
                    ),
                  ),
                ),
                
                SizedBox(width: 4.w),
                
                // Dismiss Button
                GestureDetector(
                  onTap: () {
                    final bloc = BlocProvider.of<PrayerSettingsBloc>(context);
                    bloc.add(DismissNotificationBanner());
                  },
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, String location) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (context) => PrayerSettingsBloc()),
                BlocProvider(create: (context) => PrayerTimesBloc()),
                BlocProvider(create: (context) => LocationSettingsBloc()),
              ],
              child: const LocationSettingsScreen(),
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'current_location'.tr,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeights.semiBold,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  location,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeights.regular,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: theme.textTheme.bodySmall?.color,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsToggle(BuildContext context, bool enabled) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Notifications',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeights.semiBold,
              color: theme.textTheme.titleMedium?.color,
            ),
          ),
          Switch(
            value: enabled,
            onChanged: (value) {
              final bloc = BlocProvider.of<PrayerSettingsBloc>(context);
              bloc.add(ToggleNotifications(value));
              if (value) {
                CustomToastWidget.show(
                  context: context,
                  title: "Notifications enabled",
                  iconPath: AssetsPath.logo00102PNG,
                  iconBackgroundColor: const Color(0xFF8D1B3D),
                  backgroundColor: const Color(0xFFFFEFE8),
                );
              }
            },
            activeColor: const Color(0xFF8D1B3D),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSoundCard(BuildContext context, String selectedSound, List<String> customRingtones) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Notifications Sound',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeights.semiBold,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Built-in azan sounds
          ..._adhanSounds.map((sound) => _buildSoundOption(context, sound, selectedSound)),
          _buildCustomRingtoneOption(context, customRingtones, selectedSound),
        ],
      ),
    );
  }

  Widget _buildSoundOption(BuildContext context, AdhanSoundModel sound, String selectedSound) {
    final theme = Theme.of(context);
    final isSelected = sound.name == selectedSound;
    
    return GestureDetector(
      onTap: () {
        final bloc = BlocProvider.of<PrayerSettingsBloc>(context);
        bloc.add(SelectAdhanSound(sound.name));
        
        // Play the sound if it has an asset path
        if (sound.assetPath.isNotEmpty) {
          _playAzanSound(sound.assetPath);
        }
        
        CustomToastWidget.show(
          context: context,
          title: "${sound.name} selected",
          iconPath: AssetsPath.logo00102PNG,
          iconBackgroundColor: const Color(0xFF8D1B3D),
          backgroundColor: const Color(0xFFFFEFE8),
        );
      },
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? (theme.cardTheme.color?.withOpacity(0.3) ?? const Color(0xFFF1F1F1)) : Colors.transparent,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      AssetsPath.soundSVG,
                      width: 24.sp,
                      height: 24.sp,
                      colorFilter: const ColorFilter.mode(Color(0xFF0CB002), BlendMode.srcIn),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        sound.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeights.medium,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check,
                        color: const Color(0xFF0CB002),
                        size: 20.sp,
                      ),
                  ],
                ),
              ),
            ),
    );
  }



  void _playCustomRingtone(String filePath) async {
    try {
      // Stop any currently playing audio
      await _currentPlayer?.stop();
      await _currentPlayer?.dispose();
      
      // Create new player
      _currentPlayer = AudioPlayer();
      
      // Play the custom ringtone from file path
      await _currentPlayer!.play(DeviceFileSource(filePath));
      
      // Stop playing after 10 seconds
      Future.delayed(const Duration(seconds: 10), () async {
        await _currentPlayer?.stop();
        await _currentPlayer?.dispose();
        _currentPlayer = null;
      });
    } catch (e) {
      print('Custom ringtone playback error: $e');
      CustomToastWidget.show(
        context: context,
        title: "Error playing custom ringtone",
        iconPath: AssetsPath.logo00102PNG,
        iconBackgroundColor: const Color(0xFFE33C3C),
        backgroundColor: const Color(0xFFFFEFE8),
      );
    }
  }

  Widget _buildCustomRingtoneOption(BuildContext context, List<String> customRingtones, String selectedSound) {
    final theme = Theme.of(context);
    final hasCustomRingtone = customRingtones.isNotEmpty;
    
    if (hasCustomRingtone) {
      // Show custom ringtone as selectable option
      final customRingtoneName = customRingtones.first;
      final isSelected = customRingtoneName == selectedSound;
      
      return GestureDetector(
        onTap: () async {
          final bloc = BlocProvider.of<PrayerSettingsBloc>(context);
          bloc.add(SelectAdhanSound(customRingtoneName));
          
          // Play the custom ringtone
          try {
            final prefs = await SharedPreferences.getInstance();
            final filePath = prefs.getString('custom_ringtone_path');
            if (filePath != null && filePath.isNotEmpty) {
              _playCustomRingtone(filePath);
            }
          } catch (e) {
            print('Error playing custom ringtone: $e');
          }
          
          CustomToastWidget.show(
            context: context,
            title: "$customRingtoneName selected",
            iconPath: AssetsPath.logo00102PNG,
            iconBackgroundColor: const Color(0xFF8D1B3D),
            backgroundColor: const Color(0xFFFFEFE8),
          );
        },
        child: Container(
          width: double.infinity,

          decoration: BoxDecoration(
            color: isSelected ? (theme.cardTheme.color?.withOpacity(0.3) ?? const Color(0xFFF1F1F1)) : Colors.transparent,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0,bottom: 16),
            child: Row(
              children: [
                SvgPicture.asset(
                  AssetsPath.soundSVG,
                  width: 24.sp,
                  height: 24.sp,
                  colorFilter: const ColorFilter.mode(Color(0xFF0CB002), BlendMode.srcIn),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Custom Ringtone',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeights.medium,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      Text(
                        customRingtoneName.length > 25
                            ? '${customRingtoneName.substring(0, 25)}...'
                            : customRingtoneName,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check,
                    color: const Color(0xFF0CB002),
                    size: 20.sp,
                  ),
                SizedBox(width: 8.w),
                // Delete button
                GestureDetector(
                  onTap: () async {
                    final bloc = BlocProvider.of<PrayerSettingsBloc>(context);
                    bloc.add(const DeleteCustomRingtone());
                    CustomToastWidget.show(
                      context: context,
                      title: "Custom ringtone deleted",
                      iconPath: AssetsPath.logo00102PNG,
                      iconBackgroundColor: const Color(0xFFE33C3C),
                      backgroundColor: const Color(0xFFFFEFE8),
                    );
                  },
                  child: Container(
                    width: 32.w,
                    height: 32.h,
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color?.withOpacity(0.8) ?? const Color(0xCCFFFFFF),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: theme.dividerTheme.color ?? const Color(0xFFE0E0E0),
                        width: 1,
                      ),
                    ),
                    child: SvgPicture.asset(
                      AssetsPath.basketSVG,
                      width: 16.sp,
                      height: 16.sp,
                      colorFilter: const ColorFilter.mode(Color(0xFFE33C3C), BlendMode.srcIn),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  } else {
    // Show add button when no custom ringtone exists
      return Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0,bottom: 16),
        child: Row(
          children: [
                        SvgPicture.asset(
                AssetsPath.soundSVG,
                width: 24.sp,
                height: 24.sp,
                colorFilter: const ColorFilter.mode(Color(0xFF0CB002), BlendMode.srcIn),
              ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Custom Ringtone',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeights.medium,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
            ),
            Container(

              height: 28.h,
              decoration: BoxDecoration(
                color: theme.cardTheme.color?.withOpacity(0.8) ?? const Color(0xCCFFFFFF),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: theme.dividerTheme.color ?? const Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    await _pickCustomRingtone(context);
                  },
                  borderRadius: BorderRadius.circular(14.r),
                  child: Container(
                    padding: EdgeInsets.only(
                      top: 6.h,
                      right: 16.w,
                      bottom: 6.h,
                      left: 16.w,
                    ),
                    child: Center(
                      child: Text(
                        'Add',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeights.medium,
                          color: AppColors.colorPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  AudioPlayer? _currentPlayer;

  void _playAzanSound(String assetPath) async {
    try {
      // Stop any currently playing audio
      await _currentPlayer?.stop();
      await _currentPlayer?.dispose();
      
      // Create new player
      _currentPlayer = AudioPlayer();
      
      // Remove 'assets/' prefix and use the correct asset path format
      final cleanPath = assetPath.replaceFirst('assets/', '');
      await _currentPlayer!.play(AssetSource(cleanPath));
      
      // Stop playing after 10 seconds
      Future.delayed(const Duration(seconds: 10), () async {
        await _currentPlayer?.stop();
        await _currentPlayer?.dispose();
        _currentPlayer = null;
      });
    } catch (e) {
      print('Audio playback error: $e');
      CustomToastWidget.show(
        context: context,
        title: "Error playing audio: ${e.toString()}",
        iconPath: AssetsPath.logo00102PNG,
        iconBackgroundColor: const Color(0xFFE33C3C),
        backgroundColor: const Color(0xFFFFEFE8),
      );
    }
  }

  Future<void> _pickCustomRingtone(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // Pick a media file (this includes audio files)
      final XFile? pickedFile = await picker.pickMedia();
      
      if (pickedFile != null) {
        final String fileName = pickedFile.name;
        final String filePath = pickedFile.path;
        
        // Check if it's an audio file (exclude video formats)
        final audioExtensions = ['mp3', 'wav', 'm4a', 'aac', 'ogg'];
        final fileExtension = fileName.split('.').last.toLowerCase();
        
        if (audioExtensions.contains(fileExtension)) {
          // Copy file to app's documents directory
          final appDir = await getApplicationDocumentsDirectory();
          final customRingtonesDir = Directory('${appDir.path}/custom_ringtones');
          if (!await customRingtonesDir.exists()) {
            await customRingtonesDir.create(recursive: true);
          }
          
          final savedFilePath = '${customRingtonesDir.path}/custom_ringtone.$fileExtension';
          
          // Copy the picked file to app directory
          await File(filePath).copy(savedFilePath);
          
          // Add to BLoC
          final bloc = BlocProvider.of<PrayerSettingsBloc>(context);
          bloc.add(AddCustomRingtone(fileName, filePath: savedFilePath));
          
          CustomToastWidget.show(
            context: context,
            title: "Custom ringtone added: $fileName",
            iconPath: AssetsPath.logo00102PNG,
            iconBackgroundColor: const Color(0xFF8D1B3D),
            backgroundColor: const Color(0xFFFFEFE8),
          );
        } else {
          CustomToastWidget.show(
            context: context,
            title: "Please select an audio file (mp3, wav, m4a, aac, ogg)",
            iconPath: AssetsPath.logo00102PNG,
            iconBackgroundColor: const Color(0xFFE33C3C),
            backgroundColor: const Color(0xFFFFEFE8),
          );
        }
      }
    } catch (e) {
      print('File picker error: $e');
      CustomToastWidget.show(
        context: context,
        title: "Error picking audio file. Please try again.",
        iconPath: AssetsPath.logo00102PNG,
        iconBackgroundColor: const Color(0xFFE33C3C),
        backgroundColor: const Color(0xFFFFEFE8),
      );
    }
  }



  @override
  void dispose() {
    _currentPlayer?.stop();
    _currentPlayer?.dispose();
    super.dispose();
  }
}
