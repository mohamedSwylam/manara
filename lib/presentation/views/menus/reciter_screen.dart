import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../constants/images.dart';
import '../../widgets/custom_dialog_widget.dart';
import '../../widgets/custom_toast_widget.dart';

class ReciterScreen extends StatefulWidget {
  const ReciterScreen({super.key});

  @override
  State<ReciterScreen> createState() => _ReciterScreenState();
}

class _ReciterScreenState extends State<ReciterScreen> {
  final List<Map<String, dynamic>> reciters = [
    {
      'name': 'Abdul Basit Abdus Samad',
      'image': 'assets/images/reciter1.png', // You'll need to add these images
      'size': '252.32 MB',
      'state': 'downloaded', // 'initial', 'downloading', 'downloaded'
      'downloadProgress': 0.0,
      'status': 'Available offline • 252.32 MB',
    },
    {
      'name': 'Mishari Rashid al-Afasy',
      'image': 'assets/images/reciter2.png',
      'size': '112.52 MB',
      'state': 'initial',
      'downloadProgress': 0.0,
      'status': '112.52 MB',
    },
    {
      'name': 'Abdul-Rahman Al-Sudais',
      'image': 'assets/images/reciter3.png',
      'size': '952.12 MB',
      'state': 'initial',
      'downloadProgress': 0.0,
      'status': '952.12 MB',
    },
    {
      'name': 'Saleh Ahmen Saleh',
      'image': 'assets/images/reciter4.png',
      'size': '635.30 MB',
      'state': 'initial',
      'downloadProgress': 0.0,
      'status': '635.30 MB',
    },
    {
      'name': 'Hussan Saleh Mujawwad',
      'image': 'assets/images/reciter5.png',
      'size': '122.16 MB',
      'state': 'initial',
      'downloadProgress': 0.0,
      'status': '122.16 MB',
    },
    {
      'name': 'Ibrahim Ahmed Mir',
      'image': 'assets/images/reciter6.png',
      'size': '952.12 MB',
      'state': 'initial',
      'downloadProgress': 0.0,
      'status': '952.12 MB',
    },
    {
      'name': 'Omar Al Qazabri',
      'image': 'assets/images/reciter7.png',
      'size': '252.32 MB',
      'state': 'initial',
      'downloadProgress': 0.0,
      'status': '252.32 MB',
    },
    {
      'name': 'Muhammad Al Faqih',
      'image': 'assets/images/reciter8.png',
      'size': '952.12 MB',
      'state': 'initial',
      'downloadProgress': 0.0,
      'status': '952.12 MB',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Reciter',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w, bottom: 32.h),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFEAEAEA), width: 1),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reciters.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              color: Color(0xFFEAEAEA),
            ),
            itemBuilder: (context, index) {
              final reciter = reciters[index];
              return _buildReciterItem(reciter);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildReciterItem(Map<String, dynamic> reciter) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          // Profile Picture
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: ClipOval(
              child: reciter['image'] != null
                  ? Image.asset(
                      reciter['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            size: 24.sp,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    )
                  : Icon(
                      Icons.person,
                      size: 24.sp,
                      color: Colors.grey[600],
                    ),
            ),
          ),
          
          SizedBox(width: 12.w),
          
          // Reciter Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reciter['name'],
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  reciter['status'],
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
                     // Action Icons
           Row(
             mainAxisSize: MainAxisSize.min,
             children: [
               if (reciter['state'] == 'initial') ...[
                 // Download icon for initial state
                 GestureDetector(
                   onTap: () {
                     _startDownload(reciter['name']);
                   },
                   child: SvgPicture.asset(
                     AssetsPath.downloadSVG,
                     width: 20.w,
                     height: 20.h,
                     colorFilter: ColorFilter.mode(
                       const Color(0xFF8D1B3D),
                       BlendMode.srcIn,
                     ),
                   ),
                 ),
               ] else if (reciter['state'] == 'downloading') ...[
                 // Pause icon for downloading state
                 GestureDetector(
                   onTap: () {
                     _pauseDownload(reciter['name']);
                   },
                   child: SvgPicture.asset(
                     AssetsPath.pauseSVG,
                     width: 20.w,
                     height: 20.h,
                     colorFilter: ColorFilter.mode(
                       const Color(0xFF8D1B3D),
                       BlendMode.srcIn,
                     ),
                   ),
                 ),
               ] else if (reciter['state'] == 'downloaded') ...[
                 // Basket icon for downloaded state
                 GestureDetector(
                   onTap: () {
                     _showDeleteDialog(reciter['name']);
                   },
                   child: SvgPicture.asset(
                     AssetsPath.basketSVG,
                     width: 20.w,
                     height: 20.h,
                     colorFilter: ColorFilter.mode(
                       Colors.red[400]!,
                       BlendMode.srcIn,
                     ),
                   ),
                 ),
               ],
             ],
           ),
        ],
      ),
    );
  }

  void _startDownload(String reciterName) {
    print('Starting download for $reciterName...');
    
    // Find and update the reciter state
    final index = reciters.indexWhere((reciter) => reciter['name'] == reciterName);
    if (index != -1) {
      setState(() {
        reciters[index]['state'] = 'downloading';
        reciters[index]['downloadProgress'] = 0.0;
        reciters[index]['status'] = 'Downloading 0 / ${reciters[index]['size']} 2mps';
      });
    }
    
    // Simulate download progress
    _simulateDownloadProgress(reciterName);
  }

  void _pauseDownload(String reciterName) {
    print('Pausing download for $reciterName...');
    
    // Find and update the reciter state
    final index = reciters.indexWhere((reciter) => reciter['name'] == reciterName);
    if (index != -1) {
      setState(() {
        reciters[index]['state'] = 'initial';
        reciters[index]['downloadProgress'] = 0.0;
        reciters[index]['status'] = reciters[index]['size'];
      });
    }
    
    CustomToastWidget.show(
      context: context,
      title: 'Download Paused',
      iconPath: AssetsPath.logo00102PNG,
      iconBackgroundColor: const Color(0xFF8D1B3D),
      backgroundColor: const Color(0xFFFFEFE8),
    );
  }

  void _simulateDownloadProgress(String reciterName) {
    final index = reciters.indexWhere((reciter) => reciter['name'] == reciterName);
    if (index == -1) return;

    double progress = 0.0;
    const totalSize = 100.0; // Simulate 100% progress
    
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (reciters[index]['state'] != 'downloading') {
        timer.cancel();
        return;
      }
      
      progress += 10.0; // Increment by 10% every 500ms
      
      if (progress >= totalSize) {
        // Download completed
        setState(() {
          reciters[index]['state'] = 'downloaded';
          reciters[index]['downloadProgress'] = 1.0;
          reciters[index]['status'] = 'Available offline • ${reciters[index]['size']}';
        });
        timer.cancel();
        
                 CustomToastWidget.show(
           context: context,
           title: 'Download Complete',
           iconPath: AssetsPath.logo00102PNG,
           iconBackgroundColor: const Color(0xFF8D1B3D),
           backgroundColor: const Color(0xFFFFEFE8),
         );
      } else {
        // Update progress
        setState(() {
          reciters[index]['downloadProgress'] = progress / totalSize;
          final downloadedMB = (progress / totalSize * double.parse(reciters[index]['size'].replaceAll(' MB', ''))).toStringAsFixed(1);
          reciters[index]['status'] = 'Downloading $downloadedMB / ${reciters[index]['size']} 2mps';
        });
      }
    });
  }

  void _showDeleteDialog(String reciterName) {
    CustomDialogWidget.show(
      context: context,
      title: 'Delete Reciter',
      subtitle: 'Are you sure you want to delete $reciterName? This will free up 252.32 MB of storage.',
      firstChoiceText: 'Cancel',
      secondChoiceText: 'Delete',
      onFirstChoicePressed: () {
        Navigator.of(context).pop();
      },
      onSecondChoicePressed: () {
        Navigator.of(context).pop();
        _deleteReciter(reciterName);
      },
      firstChoiceColor: const Color(0xFF4F4F4F),
      secondChoiceColor: const Color(0xFFE33C3C),
    );
  }

  void _deleteReciter(String reciterName) {
    print('Deleting $reciterName...');
    
    // Find and update the reciter state back to initial
    final index = reciters.indexWhere((reciter) => reciter['name'] == reciterName);
    if (index != -1) {
      setState(() {
        reciters[index]['state'] = 'initial';
        reciters[index]['downloadProgress'] = 0.0;
        reciters[index]['status'] = reciters[index]['size'];
      });
    }
    
    CustomToastWidget.show(
      context: context,
      title: 'Deleted',
      iconPath: AssetsPath.logo00102PNG,
      iconBackgroundColor: const Color(0xFF8D1B3D),
      backgroundColor: const Color(0xFFFFEFE8),
    );
  }
}
