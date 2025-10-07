import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../widgets/app_background_image_widget.dart';
import '../widgets/custom_appbar_widget.dart';
import '../../constants/images.dart';

class PrayerTimesSettingScreen extends StatefulWidget {
  const PrayerTimesSettingScreen({Key? key}) : super(key: key);

  @override
  State<PrayerTimesSettingScreen> createState() => _PrayerTimesSettingScreenState();
}

class _PrayerTimesSettingScreenState extends State<PrayerTimesSettingScreen> {
  bool notificationsEnabled = false;
  int selectedSound = 2;
  final List<_SoundItem> sounds = [
    _SoundItem('default_tone', true),
    _SoundItem('long_buzz', false),
    _SoundItem('adhan', false),
    _SoundItem('adhan_makkah', false),
    _SoundItem('adhan_madina', false),
    _SoundItem('adhan_qatami', false),
    _SoundItem('adhan_qatami2', false),
    _SoundItem('custom_tone', false, isCustom: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AppBackgroundImageWidget(bgImagePath: 'assets/images/background03.svg'),
          Column(
            children: [
              CustomAppbarWidget(screenTitle: 'prayer_times_settings'.tr),
              _buildInfoBanner(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLocationSelector(),
                        SizedBox(height: 20.h),
                        _buildNotificationToggle(),
                        SizedBox(height: 20.h),
                        _buildSoundList(),
                        SizedBox(height: 16.h),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 0,
                              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                            ),
                            onPressed: () {},
                            child: Text('add'.tr, style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 0),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFB98A5A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'prayer_times_settings_info'.tr,
                  style: TextStyle(color: Colors.white, fontSize: 13.sp),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Icon(Icons.notifications_active, color: Colors.white, size: 28.sp),
              SizedBox(height: 4.h),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
                ),
                onPressed: () {
                  setState(() {
                    notificationsEnabled = true;
                  });
                },
                child: Text('activate'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSelector() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(Icons.arrow_back_ios, color: Colors.black),
        title: Text('current_location'.tr, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Doha, Qatar', style: TextStyle(fontSize: 13.sp)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
        onTap: () {},
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return Row(
      children: [
        Expanded(
          child: Text('notifications'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
        ),
        Switch(
          value: notificationsEnabled,
          onChanged: (val) {
            setState(() {
              notificationsEnabled = val;
            });
          },
          activeColor: Colors.red,
        ),
      ],
    );
  }

  Widget _buildSoundList() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Text('notification_sound'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp)),
            ),
            ...List.generate(sounds.length, (i) {
              final sound = sounds[i];
              return ListTile(
                leading: i == selectedSound
                    ? Icon(Icons.check, color: Colors.green)
                    : SizedBox(width: 24.w),
                title: Text(sound.isCustom ? 'custom_tone'.tr : sound.label.tr),
                trailing: IconButton(
                  icon: Icon(Icons.volume_up, color: Colors.green),
                  onPressed: () {},
                ),
                onTap: () {
                  setState(() {
                    selectedSound = i;
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SoundItem {
  final String label;
  final bool isDefault;
  final bool isCustom;
  _SoundItem(this.label, this.isDefault, {this.isCustom = false});
}
