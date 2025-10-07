import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../../constants/images.dart';
import '../../../constants/colors.dart';
import '../../../data/bloc/quran_reading/quran_reading_bloc.dart';
import '../../../data/bloc/quran_reading/quran_reading_event.dart';
import '../../../data/bloc/quran_reading/quran_reading_state.dart';
import '../../../data/bloc/quran_theme/quran_theme_bloc.dart';
import '../../../data/bloc/quran_theme/quran_theme_event.dart';
import '../../../data/bloc/quran_theme/quran_theme_state.dart';
import '../../../data/bloc/bookmark/bookmark_bloc.dart';
import '../../../data/bloc/bookmark/bookmark_event.dart';
import '../../../data/bloc/bookmark/bookmark_state.dart';
import '../../../data/models/quran/quran_ayah_bookmark_model.dart';
import '../../widgets/custom_toast_widget.dart';
import '../../../data/viewmodel/language_controller.dart';
import '../../../data/services/last_read_service.dart';
import 'arabic_quran_reading_screen.dart';

class QuranReadingScreen extends StatelessWidget {
  const QuranReadingScreen({
    Key? key,
    required this.surahName,
    required this.surahNumber,
    this.startAyah = 1,
    this.endAyah,
    this.highlightAyah,
  }) : super(key: key);

  final String surahName;
  final int surahNumber;
  final int startAyah;
  final int? endAyah;
  final int? highlightAyah;

  @override
  Widget build(BuildContext context) {
    // Check if app is in Arabic mode
    final currentLanguage = Get.find<LocalizationController>().locale.languageCode;
    final isArabic = currentLanguage == 'ar';
    
    // If Arabic mode, use the Arabic Quran reading screen
    if (isArabic) {
      return ArabicQuranReadingScreen(
        surahName: surahName,
        surahNumber: surahNumber,
        startAyah: startAyah,
        endAyah: endAyah,
        highlightAyah: highlightAyah,
      );
    }
    
    // Otherwise, use the original English reading screen
    return MultiBlocProvider(
      providers: [
        BlocProvider<QuranReadingBloc>(
          create: (context) => QuranReadingBloc()
            ..add(LoadSurahData(
              surahNumber: surahNumber,
              surahName: surahName,
              startAyah: startAyah,
            )),
        ),
        BlocProvider<QuranThemeBloc>(
          create: (context) => QuranThemeBloc()
            ..add(const LoadThemeSettings()),
        ),
        BlocProvider<BookmarkBloc>(
          create: (context) => BookmarkBloc(),
        ),
      ],
      child: const QuranReadingView(),
    );
  }
}

class QuranReadingView extends StatefulWidget {
  const QuranReadingView({Key? key}) : super(key: key);

  @override
  State<QuranReadingView> createState() => _QuranReadingViewState();
}

class _QuranReadingViewState extends State<QuranReadingView> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = {};
  final Map<int, DateTime> _lastSaveTime = {}; // Track last save time for each ayah
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;
  bool _hasNavigatedToBookmark = false; // Flag to prevent multiple navigation triggers

  @override
  void initState() {
    super.initState();
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Add scroll listener to track reading progress
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // This will be called whenever the user scrolls
    // We can use this to track reading progress
    final state = context.read<QuranReadingBloc>().state;
    if (state is QuranReadingLoaded) {
      // Calculate which ayah is currently most visible
      final scrollOffset = _scrollController.offset;
      final screenHeight = MediaQuery.of(context).size.height;
      final centerY = scrollOffset + (screenHeight / 2);
      
      // Estimate which ayah is at the center of the screen
      // This is a simple estimation - you might want to make it more sophisticated
      final estimatedAyahIndex = (centerY / 100).floor(); // Assuming ~100px per ayah
      
      if (estimatedAyahIndex >= 0 && estimatedAyahIndex < state.ayahs.length) {
        // Save the last read position every 5 seconds to avoid too frequent saves
        if (!_lastSaveTime.containsKey(estimatedAyahIndex) || 
            DateTime.now().difference(_lastSaveTime[estimatedAyahIndex]!).inSeconds > 5) {
          _lastSaveTime[estimatedAyahIndex] = DateTime.now();
          context.read<QuranReadingBloc>().add(
            SaveLastReadPosition(ayahIndex: estimatedAyahIndex),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuranReadingBloc, QuranReadingState>(
      listener: (context, state) {
        if (state is QuranReadingError) {
          CustomToastWidget.show(
            context: context,
            title: state.message,
            iconPath: AssetsPath.cancelIconSVG,
          );
        }

        if (state is QuranReadingLoaded) {
          // Handle toast messages
          if (state.toastMessage != null) {
            CustomToastWidget.show(
              context: context,
              title: state.toastMessage!,
              iconPath: state.toastIconPath ?? AssetsPath.save,
            );
          }

          // Handle scrolling
          if (state.shouldScrollToAyah && state.scrollToAyahIndex != null) {
            print('DEBUG: BLoC triggered scroll to ayah index: ${state.scrollToAyahIndex}');
            _scrollToAyah(state.scrollToAyahIndex!);
          }

          // Handle scroll to position
          if (state.shouldScrollToPosition && state.scrollToPosition != null) {
            print('DEBUG: BLoC triggered scroll to position: ${state.scrollToPosition}');
            _scrollToPosition(state.scrollToPosition!);
          }

          // Handle highlight animation
          if (state.isHighlightAnimationActive && state.highlightedAyahIndex != null) {
            print('DEBUG: Starting highlight animation for ayah index: ${state.highlightedAyahIndex}');
            _pulseAnimationController.repeat(reverse: true);
          } else {
            _pulseAnimationController.stop();
          }

          // Check bookmark status
          final bookmarkBloc = context.read<BookmarkBloc>();
          bookmarkBloc.add(CheckBookmarkStatus(
            surahId: state.surahNumber.toString(),
          ));

          // Handle bookmark navigation
          final quranReadingScreen = context.findAncestorWidgetOfExactType<QuranReadingScreen>();
          if (quranReadingScreen?.highlightAyah != null && 
              !_hasNavigatedToBookmark && 
              !state.isHighlightAnimationActive && 
              state.highlightedAyahIndex == null) {
            _hasNavigatedToBookmark = true; // Set flag to prevent multiple triggers
            Future.delayed(const Duration(milliseconds: 2000), () {
              if (mounted) {
                print('DEBUG: Navigating to bookmarked ayah: ${quranReadingScreen!.highlightAyah}');
                
                // First, try to find the bookmark with saved scroll position
                final bookmarkBloc = context.read<BookmarkBloc>();
                if (bookmarkBloc.state is BookmarkLoaded) {
                  final bookmarkState = bookmarkBloc.state as BookmarkLoaded;
                  final bookmark = bookmarkState.bookmarks.where(
                    (b) => b.surahId == state.surahNumber.toString() && 
                           b.ayahNumber == quranReadingScreen.highlightAyah &&
                           b.type == BookmarkType.ayah
                  ).firstOrNull;

                  // Find the ayah index from the current state's ayahs list
                  final ayahIndex = state.ayahs.indexWhere(
                    (ayah) => ayah['number'] == quranReadingScreen.highlightAyah,
                  );
                  
                  if (bookmark != null && bookmark.scrollPosition != null && ayahIndex != -1) {
                    print('DEBUG: Found bookmark with saved scroll position: ${bookmark.scrollPosition} for ayah index: $ayahIndex');
                    context.read<QuranReadingBloc>().add(
                      ScrollToPosition(
                        scrollPosition: bookmark.scrollPosition!,
                        ayahIndex: ayahIndex, // Pass ayahIndex for highlight
                      ),
                    );
                  } else {
                    print('DEBUG: No saved scroll position or ayah index not found, using ayah number navigation');
                    context.read<QuranReadingBloc>().add(
                      HighlightBookmarkedAyah(ayahNumber: quranReadingScreen.highlightAyah!),
                    );
                  }
                } else {
                  print('DEBUG: Bookmark state not loaded, using ayah index navigation');
                  context.read<QuranReadingBloc>().add(
                    HighlightBookmarkedAyah(ayahNumber: quranReadingScreen.highlightAyah!),
                  );
                }
              }
            });
          }
        }
      },
      child: BlocBuilder<QuranThemeBloc, QuranThemeState>(
        builder: (context, themeState) {
          if (themeState is QuranThemeLoaded) {
            return BlocBuilder<QuranReadingBloc, QuranReadingState>(
              builder: (context, readingState) {
                return Scaffold(
                  backgroundColor: themeState.backgroundColor,
                  appBar: _buildAppBar(context, themeState),
                  body: _buildBody(context, readingState, themeState),
                );
              },
            );
          }
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    QuranThemeLoaded themeState,
  ) {
    return AppBar(
      backgroundColor: themeState.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: themeState.textColor),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'quran_reading'.tr,
        style: GoogleFonts.poppins(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: themeState.textColor,
        ),
      ),
      centerTitle: true,
      actions: [
        BlocBuilder<BookmarkBloc, BookmarkState>(
          builder: (context, bookmarkState) {
            bool isPageBookmarked = false;
            if (bookmarkState is BookmarkLoaded) {
              isPageBookmarked = bookmarkState.isPageBookmarked;
            }
            
            return IconButton(
              icon: Icon(
                isPageBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: themeState.textColor,
              ),
              onPressed: () => _togglePageBookmark(context, themeState),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    QuranReadingState readingState,
    QuranThemeLoaded themeState,
  ) {
    if (readingState is QuranReadingLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: themeState.titleColor,
        ),
      );
    }

    if (readingState is QuranReadingLoaded) {
      return ListView.builder(
        controller: _scrollController,
        itemCount: readingState.ayahs.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: _buildSurahTitle(readingState, themeState),
            );
          } else {
            final ayahIndex = index - 1;
            final ayah = readingState.ayahs[ayahIndex];
            
            if (!_ayahKeys.containsKey(ayahIndex)) {
              _ayahKeys[ayahIndex] = GlobalKey();
            }
            
            return _buildAyahCard(
              context,
              ayah,
              ayahIndex,
              readingState,
              themeState,
            );
          }
        },
      );
    }

    if (readingState is QuranReadingError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: themeState.titleColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'error_loading_surah'.tr,
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: themeState.textColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              readingState.message,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: themeState.textColor.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                context.read<QuranReadingBloc>().add(
                  LoadSurahData(
                    surahNumber: readingState.surahNumber,
                    surahName: readingState.surahName,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeState.titleColor,
                foregroundColor: themeState.backgroundColor,
              ),
              child: Text(
                'retry'.tr,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSurahTitle(
    QuranReadingLoaded readingState,
    QuranThemeLoaded themeState,
  ) {
    final currentLanguage = Get.find<LocalizationController>().locale.languageCode;
    final isEnglish = currentLanguage == 'en';
    
    return Column(
      children: [
        if (isEnglish) ...[
          Text(
            '${readingState.surahNumber}. ${_getEnglishSurahName(readingState.surahNumber)}',
            style: GoogleFonts.poppins(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: themeState.textColor,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getSurahTranslation(readingState.surahNumber),
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: themeState.textColor.withOpacity(0.7),
                ),
              ),
              SvgPicture.asset(
                AssetsPath.ka3baaSVG,
                width: 32.w,
                height: 32.h,
                colorFilter: ColorFilter.mode(
                  themeState.titleColor,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ],
        Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              AssetsPath.surahTitleSVG,
              height: 50.h,
              colorFilter: ColorFilter.mode(
                themeState.titleColor,
                BlendMode.srcIn,
              ),
            ),
            Text(
              readingState.surahName,
              style: GoogleFonts.amiri(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: themeState.textColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

     Widget _buildAyahCard(
     BuildContext context,
     Map<String, dynamic> ayah,
     int ayahIndex,
     QuranReadingLoaded readingState,
     QuranThemeLoaded themeState,
   ) {
     final isCurrentAyah = ayahIndex == readingState.currentAyahIndex && readingState.isAudioPlaying;
     final isExpanded = readingState.expandedAyahs.contains(ayahIndex);
     final isHighlighted = readingState.highlightedAyahIndex == ayahIndex;
     
     // Check if this ayah is bookmarked from BookmarkBloc state
     bool isBookmarkedAyah = false;
     final bookmarkBloc = context.read<BookmarkBloc>();
     if (bookmarkBloc.state is BookmarkLoaded) {
       final bookmarkState = bookmarkBloc.state as BookmarkLoaded;
       isBookmarkedAyah = bookmarkState.bookmarks.any(
         (bookmark) => bookmark.surahId == readingState.surahNumber.toString() &&
                      bookmark.ayahNumber == ayah['number'] &&
                      bookmark.type == BookmarkType.ayah,
       );
     }
     
     // Also check if it's highlighted with animation (for bookmark navigation)
     final isHighlightedBookmark = readingState.isHighlightAnimationActive && isHighlighted;
     
     final tafsirKey = '${readingState.surahNumber}:${ayah['number']}';
     final tafsirText = readingState.tafsirData[tafsirKey];

    return Column(
      children: [
        GestureDetector(
                     onTapDown: (TapDownDetails details) {
             context.read<QuranReadingBloc>().add(HighlightAyah(ayahIndex: ayahIndex));
             _showAyahPopupMenu(context, details.globalPosition, ayah, ayahIndex, readingState, themeState, isBookmarkedAyah);
           },
                     child: AnimatedBuilder(
             animation: _pulseAnimation,
             builder: (context, child) {
               return Transform.scale(
                 scale: isHighlightedBookmark ? _pulseAnimation.value : 1.0,
                 child: AnimatedContainer(
                   duration: const Duration(milliseconds: 300),
                   curve: Curves.easeInOut,
                   key: _ayahKeys[ayahIndex],
                                       decoration: BoxDecoration(
                      color: isBookmarkedAyah
                          ? themeState.backgroundColor.withOpacity(0.3)
                          : isHighlighted
                              ? const Color(0x1AA7805A)
                              : isCurrentAyah
                                  ? themeState.titleColor.withOpacity(0.05)
                                  : Colors.transparent,
                                           border: isBookmarkedAyah
                          ? Border.all(
                              color: themeState.titleColor.withOpacity(0.3),
                              width: 1.5,
                            )
                          : null,
                      borderRadius: isBookmarkedAyah
                          ? BorderRadius.circular(8)
                          : null,
                      boxShadow: isBookmarkedAyah
                          ? [
                              BoxShadow(
                                color: themeState.titleColor.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                   ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RichText(
                          textDirection: TextDirection.rtl,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: ayah['text'].trim() + '\u00A0',
                                style: GoogleFonts.amiri(
                                  fontSize: themeState.quranFontSize,
                                  color: themeState.textColor,
                                ),
                              ),
                              WidgetSpan(
                                child: Transform.translate(
                                  offset: const Offset(0, -4),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        AssetsPath.ayahNumSVG,
                                        width: themeState.quranFontSize.w * 1.2,
                                      ),
                                      Text(
                                        '${ayah['number']}',
                                        style: GoogleFonts.amiri(
                                          fontSize: themeState.quranFontSize / 1.5,
                                          fontWeight: FontWeight.bold,
                                          color: themeState.textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                alignment: PlaceholderAlignment.middle,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(left: 16.w, right: 16.w),
                          child: Text(
                            ayah['translation'],
                            style: GoogleFonts.poppins(
                              fontSize: themeState.tafsirFontSize,
                              color: themeState.textColor.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                                                 if (isBookmarkedAyah) ...[
                           SizedBox(height: 8.h),
                           Row(
                             mainAxisAlignment: MainAxisAlignment.end,
                             children: [
                               Icon(
                                 Icons.bookmark,
                                 size: 16.sp,
                                 color: themeState.titleColor.withOpacity(0.7),
                               ),
                               SizedBox(width: 4.w),
                               Text(
                                 'bookmarked'.tr,
                                 style: GoogleFonts.poppins(
                                   fontSize: 12.sp,
                                   color: themeState.titleColor.withOpacity(0.7),
                                   fontWeight: FontWeight.w500,
                                 ),
                               ),
                             ],
                           ),
                         ],
                        if (isExpanded) ...[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: themeState.titleColor.withOpacity(0.05),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.book,
                                      size: 20.sp,
                                      color: themeState.titleColor,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'tafsir'.tr,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: themeState.titleColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  tafsirText ?? 'loading_tafsir'.tr,
                                  style: GoogleFonts.poppins(
                                    fontSize: themeState.tafsirFontSize - 2,
                                    height: 1.6,
                                    color: themeState.textColor.withOpacity(0.9),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(
          thickness: 0.5,
          color: Color(0x8B364254),
        ),
      ],
    );
  }

     void _showAyahPopupMenu(
     BuildContext context,
     Offset position,
     Map<String, dynamic> ayah,
     int ayahIndex,
     QuranReadingLoaded readingState,
     QuranThemeLoaded themeState,
     bool isBookmarkedAyah,
   ) {
    final screenSize = MediaQuery.of(context).size;
    final popupWidth = 320.0;
    final popupHeight = 80.0;

    double left = position.dx - (popupWidth / 2);
    double top = position.dy - 10;

    if (left < 16) {
      left = 16;
    } else if (left + popupWidth > screenSize.width - 16) {
      left = screenSize.width - popupWidth - 16;
    }

    if (top + popupHeight > screenSize.height - 16) {
      top = position.dy - popupHeight - 10;
    }

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return GestureDetector(
          onTap: () => Navigator.pop(dialogContext),
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned(
                  left: left,
                  top: top,
                  child: GestureDetector(
                    onTap: () {},
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildPopupMenuItem(
                              icon: Icons.play_arrow,
                              label: 'play'.tr,
                              themeState: themeState,
                              onTap: () {
                                Navigator.pop(dialogContext);
                                context.read<QuranReadingBloc>().add(
                                  HandlePopupMenuAction(
                                    action: 'play',
                                    ayahIndex: ayahIndex,
                                    ayah: ayah,
                                  ),
                                );
                              },
                            ),
                            _buildPopupMenuItem(
                              icon: Icons.share,
                              label: 'share'.tr,
                              themeState: themeState,
                              onTap: () {
                                Navigator.pop(dialogContext);
                                context.read<QuranReadingBloc>().add(
                                  HandlePopupMenuAction(
                                    action: 'share',
                                    ayahIndex: ayahIndex,
                                    ayah: ayah,
                                  ),
                                );
                              },
                            ),
                            _buildPopupMenuItem(
                              icon: Icons.copy,
                              label: 'copy'.tr,
                              themeState: themeState,
                              onTap: () {
                                Navigator.pop(dialogContext);
                                context.read<QuranReadingBloc>().add(
                                  HandlePopupMenuAction(
                                    action: 'copy',
                                    ayahIndex: ayahIndex,
                                    ayah: ayah,
                                  ),
                                );
                              },
                            ),
                                                         _buildPopupMenuItem(
                               icon: isBookmarkedAyah ? Icons.bookmark : Icons.bookmark_border,
                               label: 'save'.tr,
                               themeState: themeState,
                               onTap: () {
                                 Navigator.pop(dialogContext);
                                 _handleSaveAyah(context, ayah, readingState);
                               },
                             ),
                            _buildPopupMenuItem(
                              icon: Icons.book,
                              label: 'tafsir'.tr,
                              themeState: themeState,
                              onTap: () {
                                Navigator.pop(dialogContext);
                                context.read<QuranReadingBloc>().add(
                                  HandlePopupMenuAction(
                                    action: 'tafsir',
                                    ayahIndex: ayahIndex,
                                    ayah: ayah,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopupMenuItem({
    required IconData icon,
    required String label,
    required QuranThemeLoaded themeState,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: themeState.titleColor,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: themeState.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSaveAyah(BuildContext context, Map<String, dynamic> ayah, QuranReadingLoaded readingState) {
    final bookmarkBloc = context.read<BookmarkBloc>();
    final currentScrollPosition = _scrollController.hasClients ? _scrollController.offset : 0.0;
    
    bookmarkBloc.add(AddAyahBookmark(
      surahId: readingState.surahNumber.toString(),
      surahName: readingState.surahName,
      surahNumber: readingState.surahNumber,
      ayahNumber: ayah['number'],
      ayahText: ayah['text'],
      ayahTranslation: ayah['translation'],
      pageNumber: 1,
      juzNumber: 1,
      scrollPosition: currentScrollPosition,
    ));
  }

  void _scrollToAyah(int ayahIndex) {
    final key = _ayahKeys[ayahIndex];
    if (key != null && key.currentContext != null) {
      print('DEBUG: Scrolling to ayah index: $ayahIndex');
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        alignment: 0.3, // Position the ayah at 30% from the top of the screen
      );
    } else {
      print('DEBUG: GlobalKey not found for ayah index: $ayahIndex, using alternative approach');
      _scrollToAyahAlternative(ayahIndex);
    }
  }

  void _scrollToPosition(double position) {
    if (_scrollController.hasClients) {
      print('DEBUG: Scrolling to position: $position');
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      print('DEBUG: ScrollController not ready, retrying scroll to position...');
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToPosition(position);
      });
    }
  }

  void _scrollToAyahAlternative(int ayahIndex) {
    if (!_scrollController.hasClients) {
      print('DEBUG: ScrollController not ready, retrying...');
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToAyahAlternative(ayahIndex);
      });
      return;
    }

    // Alternative approach: Scroll to a position that ensures the ayah is visible
    // This approach is more reliable because it doesn't try to be too precise initially
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final currentOffset = _scrollController.offset;
    
    // Calculate a target position that should bring the ayah into view
    // Use a more conservative approach
    final estimatedAyahHeight = 120.0; // Conservative estimate
    final surahTitleHeight = 100.0;
    final estimatedPosition = surahTitleHeight + (ayahIndex * estimatedAyahHeight);
    
    // Add some offset to ensure we're not too close to the top
    final targetPosition = (estimatedPosition - 100).clamp(0.0, maxScrollExtent);
    
    print('DEBUG: Alternative scroll approach - target position: $targetPosition');
    
    _scrollController.animateTo(
      targetPosition,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    ).then((_) {
      // After scrolling, wait a bit and then try to use GlobalKey
      Future.delayed(const Duration(milliseconds: 300), () {
        _retryScrollWithGlobalKey(ayahIndex, 0);
      });
    });
  }

  void _retryScrollWithGlobalKey(int ayahIndex, int attemptCount) {
    if (attemptCount >= 5) {
      print('DEBUG: Max retry attempts reached for ayah index: $ayahIndex');
      return;
    }

    final key = _ayahKeys[ayahIndex];
    if (key != null && key.currentContext != null) {
      print('DEBUG: GlobalKey available on attempt ${attemptCount + 1}, fine-tuning scroll position');
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );
    } else {
      print('DEBUG: GlobalKey not available on attempt ${attemptCount + 1}, retrying...');
      Future.delayed(const Duration(milliseconds: 200), () {
        _retryScrollWithGlobalKey(ayahIndex, attemptCount + 1);
      });
    }
  }

  void _togglePageBookmark(BuildContext context, QuranThemeLoaded themeState) {
    final bookmarkBloc = context.read<BookmarkBloc>();
    final readingState = context.read<QuranReadingBloc>().state;
    
    if (readingState is QuranReadingLoaded) {
      if (bookmarkBloc.state is BookmarkLoaded) {
        final currentBookmarkState = bookmarkBloc.state as BookmarkLoaded;
        final isPageBookmarked = currentBookmarkState.isPageBookmarked;

        if (isPageBookmarked) {
          final pageBookmark = currentBookmarkState.bookmarks.where(
            (bookmark) => bookmark.surahId == readingState.surahNumber.toString() && 
                         bookmark.type == BookmarkType.page,
          ).firstOrNull;
          
          if (pageBookmark != null) {
            bookmarkBloc.add(RemoveBookmark(bookmarkId: pageBookmark.id));
            CustomToastWidget.show(
              context: context,
              title: 'page_unbookmarked'.tr,
              iconPath: AssetsPath.save,
            );
          }
        } else {
          bookmarkBloc.add(AddPageBookmark(
            surahId: readingState.surahNumber.toString(),
            surahName: readingState.surahName,
            surahNumber: readingState.surahNumber,
            pageNumber: 1,
            juzNumber: 1,
          ));
          CustomToastWidget.show(
            context: context,
            title: 'page_bookmarked'.tr,
            iconPath: AssetsPath.save,
          );
        }
      } else {
        bookmarkBloc.add(AddPageBookmark(
          surahId: readingState.surahNumber.toString(),
          surahName: readingState.surahName,
          surahNumber: readingState.surahNumber,
          pageNumber: 1,
          juzNumber: 1,
        ));
        CustomToastWidget.show(
          context: context,
          title: 'page_bookmarked'.tr,
          iconPath: AssetsPath.save,
        );
      }
    }
  }

 String _getSurahTranslation(int surahNumber) {
  final translations = [
    'surah_names.$surahNumber',
    'surah_names["$surahNumber"]',
    'surah_names${surahNumber}',
  ];
  
  for (String key in translations) {
    final result = key.tr;
    if (result != key) {
      return result; 
    }
  }
  
  // If all translations fail, fall back to English method
  return _getEnglishSurahName(surahNumber);
}
  String _getEnglishSurahName(int surahNumber) {
    final englishSurahNames = {
      1: 'Al Fatiah',
      2: 'Al Baqarah',
      3: 'Al Imran',
      4: 'An Nisa',
      5: 'Al Maida',
      6: 'Al Anam',
      7: 'Al Araf',
      8: 'Al Anfal',
      9: 'At Taubah',
      10: 'Yunus',
      11: 'Hud',
      12: 'Yusuf',
      13: 'Ar Ra\'d',
      14: 'Ibraheem',
      15: 'Al Hijr',
      16: 'An Nahl',
      17: 'Al Isra',
      18: 'Al Kahf',
      19: 'Maryam',
      20: 'Ta Ha',
      21: 'Al Anbiya',
      22: 'Al Hajj',
      23: 'Al Mu\'minun',
      24: 'An Nur',
      25: 'Al Furqan',
      26: 'Ash Shuara',
      27: 'An Naml',
      28: 'Al Qasas',
      29: 'Al Ankabut',
      30: 'Ar Rum',
      31: 'Luqman',
      32: 'As Sajda',
      33: 'Al Ahzab',
      34: 'Saba',
      35: 'Fatir',
      36: 'Ya Sin',
      37: 'As Saffat',
      38: 'Sad',
      39: 'Az Zumar',
      40: 'Ghafir',
      41: 'Fussilat',
      42: 'Ash Shura',
      43: 'Az Zukhruf',
      44: 'Ad Dukhan',
      45: 'Al Jathiya',
      46: 'Al Ahqaf',
      47: 'Muhammad',
      48: 'Al Fath',
      49: 'Al Hujurat',
      50: 'Qaf',
      51: 'Adh Dhariyat',
      52: 'At Tur',
      53: 'An Najm',
      54: 'Al Qamar',
      55: 'Ar Rahman',
      56: 'Al Waqia',
      57: 'Al Hadid',
      58: 'Al Mujadila',
      59: 'Al Hashr',
      60: 'Al Mumtahana',
      61: 'As Saf',
      62: 'Al Jumuah',
      63: 'Al Munafiqun',
      64: 'At Taghabun',
      65: 'At Talaq',
      66: 'At Tahrim',
      67: 'Al Mulk',
      68: 'Al Qalam',
      69: 'Al Haqqa',
      70: 'Al Maarij',
      71: 'Nuh',
      72: 'Al Jinn',
      73: 'Al Muzzammil',
      74: 'Al Muddathir',
      75: 'Al Qiyama',
      76: 'Al Insan',
      77: 'Al Mursalat',
      78: 'An Naba',
      79: 'An Naziat',
      80: 'Abasa',
      81: 'At Takwir',
      82: 'Al Infitar',
      83: 'Al Mutaffifin',
      84: 'Al Inshiqaq',
      85: 'Al Buruj',
      86: 'At Tariq',
      87: 'Al Ala',
      88: 'Al Ghashiya',
      89: 'Al Fajr',
      90: 'Al Balad',
      91: 'Ash Shams',
      92: 'Al Layl',
      93: 'Ad Duha',
      94: 'Ash Sharh',
      95: 'At Tin',
      96: 'Al Alaq',
      97: 'Al Qadr',
      98: 'Al Bayyina',
      99: 'Az Zalzala',
      100: 'Al Adiyat',
      101: 'Al Qaria',
      102: 'At Takathur',
      103: 'Al Asr',
      104: 'Al Humaza',
      105: 'Al Fil',
      106: 'Quraysh',
      107: 'Al Maun',
      108: 'Al Kawthar',
      109: 'Al Kafirun',
      110: 'An Nasr',
      111: 'Al Masad',
      112: 'Al Ikhlas',
      113: 'Al Falaq',
      114: 'An Nas',
    };
    
    return englishSurahNames[surahNumber] ?? 'Unknown';
  }
}
