import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../constants/colors.dart';
import 'duaa_card_widget.dart';

class DuaaCarouselSection extends StatelessWidget {
  final CarouselSliderController _carouselController = CarouselSliderController();
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);

  DuaaCarouselSection({super.key});

  final List<Map<String, String>> duaas = [
    {
      'title': '1',
      'arabicText': 'اَللّٰهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ زَوَالِ نِعْمَتِكَ، وَتَحَوُّلِ عَافِيَتِكَ، وَفُجَاءَةِ نِقْمَتِكَ، وَجَمِيعِ سَخَطِكَ',
      'englishText': 'O Allah! I seek refuge in You from the decline of Your blessings, the passing of safety, the sudden onset of Your punishment and from all that displeases you.'
    },
    {
      'title': '2',
      'arabicText': 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
      'englishText': 'I seek refuge in Allah from the accursed Satan'
    },
    {
      'title': '3',
      'arabicText': 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ',
      'englishText': 'O Allah, send blessings upon Muhammad and the family of Muhammad'
    },
    {
      'title': '4',
      'arabicText': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      'englishText': 'Glory be to Allah and all praise is due to Him'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: duaas.length,
          options: CarouselOptions(
            height: 260.h, // Match the specified height
            viewportFraction: 0.95,
            enlargeCenterPage: true,
            autoPlay: false,
            onPageChanged: (index, reason) {
              _currentIndex.value = index;
            },
          ),
          itemBuilder: (context, index, realIndex) {
            return SizedBox(
              width: 328.w, // Match the specified width
              height: 260.h, // Match the specified height
              child: DuaaCardWidget(
                title: duaas[index]['title']!,
                arabicText: duaas[index]['arabicText']!,
                englishText: duaas[index]['englishText']!,
                isFavorite: false,
                onFavoriteToggle: () {},
              ),
            );
          },
        ),
        SizedBox(height: 16.h),
        ValueListenableBuilder<int>(
          valueListenable: _currentIndex,
          builder: (context, currentIndex, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(duaas.length, (index) {
                return Container(
                  width: 8.w,
                  height: 8.h,
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentIndex == index
                        ? AppColors.colorPrimary
                        : theme.textTheme.bodySmall?.color?.withOpacity(0.3) ?? Colors.grey[300],
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}
