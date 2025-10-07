import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class TafsirScreen extends StatefulWidget {
  const TafsirScreen({super.key});

  @override
  State<TafsirScreen> createState() => _TafsirScreenState();
}

class _TafsirScreenState extends State<TafsirScreen> {
  final List<Map<String, dynamic>> tafsirOptions = [
    {
      'name': 'Tafsir Tabari',
      'isSelected': true,
    },
    {
      'name': 'Tanwir al-Miqbas min Tafsir Ibn \'Abbas',
      'isSelected': false,
    },
    {
      'name': 'Asbab Al-Nuzul by Al-Wahidi',
      'isSelected': false,
    },
    {
      'name': 'Tafsir al-Trhustari',
      'isSelected': false,
    },
    {
      'name': 'Kashani Tafsir',
      'isSelected': false,
    },
    {
      'name': 'Al Qushairi Tafsir',
      'isSelected': false,
    },
    {
      'name': 'Kashf Al-Asrar Tafsir',
      'isSelected': false,
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
          'Tafsir',
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
            itemCount: tafsirOptions.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              color: Color(0xFFEAEAEA),
            ),
            itemBuilder: (context, index) {
              final tafsir = tafsirOptions[index];
              return _buildTafsirItem(tafsir, index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTafsirItem(Map<String, dynamic> tafsir, int index) {
    return GestureDetector(
      onTap: () {
        _selectTafsir(index);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: tafsir['isSelected'] 
              ? const Color(0xFFF1F1F1).withOpacity(0.4) // #F1F1F166
              : Colors.transparent,
        ),
        child: Row(
          children: [
            // Tafsir Name
            Expanded(
              child: Text(
                tafsir['name'],
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                  color: Colors.black,
                ),
              ),
            ),
            
            // Selection Indicator
            if (tafsir['isSelected'])
              Icon(
                Icons.check,
                size: 20.sp,
                color: Colors.green,
              ),
          ],
        ),
      ),
    );
  }

  void _selectTafsir(int selectedIndex) {
    setState(() {
      // Deselect all options
      for (int i = 0; i < tafsirOptions.length; i++) {
        tafsirOptions[i]['isSelected'] = false;
      }
      // Select the chosen option
      tafsirOptions[selectedIndex]['isSelected'] = true;
    });
    
    // TODO: Save the selected Tafsir preference
    print('Selected Tafsir: ${tafsirOptions[selectedIndex]['name']}');
  }
}
