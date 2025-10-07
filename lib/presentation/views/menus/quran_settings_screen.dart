import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/images.dart';
import '../../../data/bloc/quran_theme/quran_theme_bloc.dart';
import '../../../data/bloc/quran_theme/quran_theme_event.dart';
import '../../../data/bloc/quran_theme/quran_theme_state.dart';

class QuranSettingsScreen extends StatelessWidget {
  const QuranSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuranThemeBloc()..add(const LoadThemeSettings()),
      child: const QuranSettingsView(),
    );
  }
}

class QuranSettingsView extends StatelessWidget {
  const QuranSettingsView({super.key});

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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Quran Settings',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
            color: theme.textTheme.titleMedium?.color,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<QuranThemeBloc, QuranThemeState>(
        builder: (context, state) {
          if (state is QuranThemeLoaded) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(top: 60.h, left: 16.w, right: 16.w, bottom: 32.h),
              child: Column(
                children: [
                  _buildThemeCard(context, state),
                  SizedBox(height: 16.h),
                  _buildFontSizeCard(context, state),
                  SizedBox(height: 16.h),
                  _buildTafsirFontSizeCard(context, state),
                  SizedBox(height: 16.h),
                  _buildOptionsCard(context, state),
                ],
              ),
            );
          }
          
          if (state is QuranThemeError) {
            final theme = Theme.of(context);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading settings',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    state.message,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context, QuranThemeLoaded state) {
    final theme = Theme.of(context);
    return Container(
      width: 328.w,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFEAEAEA), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w),
            child: Text(
              'Theme',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 140.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: state.themes.length,
              itemBuilder: (context, index) {
                 final themeData = state.themes[index];
                 final isSelected = state.selectedThemeIndex == index;
                
                return GestureDetector(
                  onTap: () {
                    context.read<QuranThemeBloc>().add(SetThemeIndex(index: index));
                  },
                  child: Container(
                    width: 84.w,
                    height: 120.h,
                    margin: EdgeInsets.only(right: 12.w),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFD5CCA1): Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFD5CCA1) : const Color(0xFFD5CCA1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0,left: 6,right: 6),
                          child: Container(
                            height: 100.h,
                             decoration: BoxDecoration(
                               color: themeData['bgColor'],
                               borderRadius: BorderRadius.circular(10),
                             ),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 3,right: 2,left: 2),
                              child: Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          AssetsPath.surahTitleSVG,
                                          height: 10.h,
                                            colorFilter: ColorFilter.mode(
                                             themeData['titleColor'],
                                             BlendMode.srcIn,
                                           ),
                                        ),
                                           Text(
                                           'ٱلْفَاتِحَةُ',
                                           style: GoogleFonts.amiri(
                                             fontSize: 3,
                                             fontWeight: FontWeight.bold,
                                             color: themeData['textColor'],
                                           ),
                                         ),
                                      ],
                                    ),
                                    //ayah list
                                    Padding(
                                      padding: EdgeInsets.only(top: 4.h),
                                      child: RichText(
                                        textAlign: TextAlign.center,
                                        textDirection: TextDirection.rtl,
                                        text: TextSpan(
                                            style: GoogleFonts.amiri(
                                             fontSize: 5,
                                             height: 2,
                                             color: themeData['textColor'],
                                           ),
                                          children: _getAyahList().asMap().entries.expand((entry) {
                                            int index = entry.key + 1;
                                            String text = entry.value;
                                            return [
                                              TextSpan(text: '$text '),
                                              WidgetSpan(
                                                alignment: PlaceholderAlignment.middle,
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    SvgPicture.asset(
                                                      AssetsPath.ayahNumSVG,
                                                      width: 6.w,
                                                      height: 6.h,
                                                    ),
                                                    Text(
                                                      '$index',
                                                      style: GoogleFonts.amiri(
                                                        fontSize: 3,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const TextSpan(text: ' '),
                                            ];
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ),
                        ),
                        SizedBox(height: 5.h,),
                                                 Text(
                           themeData['name'],
                           style: TextStyle(
                             fontFamily: 'IBM Plex Sans Arabic',
                             fontSize: 12.sp,
                             color: isSelected ? Colors.white : (theme.textTheme.bodyMedium?.color ?? Colors.black),
                             fontWeight: FontWeight.w600,
                           ),
                           textAlign: TextAlign.center,
                         ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildFontSizeCard(BuildContext context, QuranThemeLoaded state) {
    final theme = Theme.of(context);
    return Container(
      width: 328.w,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFEAEAEA), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w),
            child: Text(
              'Quran Font Size',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Text(
                  'A',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.textTheme.bodySmall?.color ?? Colors.grey,
                  ),
                ),
                                 Expanded(
                   child: Slider(
                     value: state.quranFontSize,
                     min: 12.0,
                     max: 32.0,
                     divisions: 20,
                     activeColor: const Color(0xFFA7805A),
                     inactiveColor: const Color(0xFFA7805A).withOpacity(0.3),
                     onChanged: (value) {
                       context.read<QuranThemeBloc>().add(SetQuranFontSize(size: value));
                     },
                   ),
                 ),
                Text(
                  'A',
                  style: TextStyle(
                    fontSize: 20.sp,
                    color: theme.textTheme.bodySmall?.color ?? Colors.grey,
                  ),
                ),
              ],
            ),
          ),
                     Padding(
             padding: EdgeInsets.symmetric(horizontal: 16.w),
             child: Text(
               '${state.quranFontSize.toInt()}',
               style: TextStyle(
                 fontFamily: 'IBM Plex Sans Arabic',
                 fontSize: 14.sp,
                 color: theme.textTheme.bodySmall?.color ?? Colors.grey,
               ),
             ),
           ),
           SizedBox(height: 12.h),
           // Font Preview Example
           Container(
             width: 296.w,
             height: 64.h,
             margin: EdgeInsets.symmetric(horizontal: 16.w),
             decoration: BoxDecoration(
               color: theme.brightness == Brightness.dark 
                   ? const Color(0xFF1E1E1E).withOpacity(0.4)
                   : const Color(0xFFF1F1F1).withOpacity(0.4),
               borderRadius: BorderRadius.circular(10),
             ),
             child: Center(
               child: Text(
                 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
                 style: GoogleFonts.amiri(
                   fontSize: state.quranFontSize,
                   color: theme.textTheme.bodyMedium?.color ?? Colors.black,
                   height: 1.5,
                 ),
                 textAlign: TextAlign.center,
               ),
             ),
           ),
           SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildTafsirFontSizeCard(BuildContext context, QuranThemeLoaded state) {
    final theme = Theme.of(context);
    return Container(
      width: 328.w,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFEAEAEA), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w),
            child: Text(
              'Tafsir Font Size',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Text(
                  'A',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.textTheme.bodySmall?.color ?? Colors.grey,
                  ),
                ),
                                 Expanded(
                   child: Slider(
                     value: state.tafsirFontSize,
                     min: 12.0,
                     max: 32.0,
                     divisions: 20,
                     activeColor: const Color(0xFFA7805A),
                     inactiveColor: const Color(0xFFA7805A).withOpacity(0.3),
                     onChanged: (value) {
                       context.read<QuranThemeBloc>().add(SetTafsirFontSize(size: value));
                     },
                   ),
                 ),
                Text(
                  'A',
                  style: TextStyle(
                    fontSize: 20.sp,
                    color: theme.textTheme.bodySmall?.color ?? Colors.grey,
                  ),
                ),
              ],
            ),
          ),
                     Padding(
             padding: EdgeInsets.symmetric(horizontal: 16.w),
             child: Text(
               '${state.tafsirFontSize.toInt()}',
               style: TextStyle(
                 fontFamily: 'IBM Plex Sans Arabic',
                 fontSize: 14.sp,
                 color: theme.textTheme.bodySmall?.color ?? Colors.grey,
               ),
             ),
           ),
           SizedBox(height: 12.h),
           // Font Preview Example
           Container(
             width: 296.w,
             height: 64.h,
             margin: EdgeInsets.symmetric(horizontal: 16.w),
             decoration: BoxDecoration(
               color: theme.brightness == Brightness.dark 
                   ? const Color(0xFF1E1E1E).withOpacity(0.4)
                   : const Color(0xFFF1F1F1).withOpacity(0.4),
               borderRadius: BorderRadius.circular(10),
             ),
             child: Center(
               child: Text(
                 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
                 style: GoogleFonts.amiri(
                   fontSize: state.tafsirFontSize,
                   color: theme.textTheme.bodyMedium?.color ?? Colors.black,
                   height: 1.5,
                 ),
                 textAlign: TextAlign.center,
               ),
             ),
           ),
           SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildOptionsCard(BuildContext context, QuranThemeLoaded state) {
    final theme = Theme.of(context);
    return Container(
      width: 328.w,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFEAEAEA), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w),
            child: Text(
              'Options',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text(
                       'Tajweed Rules',
                       style: TextStyle(
                         fontFamily: 'IBM Plex Sans Arabic',
                         fontSize: 14.sp,
                         color: theme.textTheme.bodyMedium?.color ?? Colors.black,
                       ),
                     ),
                    Switch(
                      value: state.tajweedRules,
                      onChanged: (value) {
                        context.read<QuranThemeBloc>().add(SetTajweedRules(value: value));
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text(
                       'Vibration on New Page',
                       style: TextStyle(
                         fontFamily: 'IBM Plex Sans Arabic',
                         fontSize: 14.sp,
                         color: theme.textTheme.bodyMedium?.color ?? Colors.black,
                       ),
                     ),
                    Switch(
                      value: state.vibrationOnNewPage,
                      onChanged: (value) {
                        context.read<QuranThemeBloc>().add(SetVibrationOnNewPage(value: value));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  List<String> _getAyahList() {
    return [
      'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
      'ٱلْحَمْدُ لِلّٰهِ رَبِّ ٱلْعَٰلَمِينَ',
      'ٱلرَّحْمَٰنِ الرَّحِيمِ',
      'مَٰلِكِ يَوْمِ ٱلدِّينِ',
      'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
      'ٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ',
      'صِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ ٱلْمَغْضُوبِ عَلَيْهِمْ وَلَا ٱلضَّالِّينَ',
    ];
  }
}
