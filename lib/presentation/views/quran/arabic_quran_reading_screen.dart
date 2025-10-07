import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../constants/images.dart';
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
import '../../../data/services/last_read_service.dart';
import '../../widgets/custom_toast_widget.dart';

class ArabicQuranReadingScreen extends StatelessWidget {
  const ArabicQuranReadingScreen({
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
          create: (context) => QuranThemeBloc()..add(const LoadThemeSettings()),
        ),
        BlocProvider<BookmarkBloc>(
          create: (context) => BookmarkBloc(),
        ),
      ],
      child: const ArabicQuranReadingView(),
    );
  }
}

class ArabicQuranReadingView extends StatefulWidget {
  const ArabicQuranReadingView({Key? key}) : super(key: key);

  @override
  State<ArabicQuranReadingView> createState() => _ArabicQuranReadingViewState();
}

class _ArabicQuranReadingViewState extends State<ArabicQuranReadingView>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final Map<int, GlobalKey> _ayahKeys = {};

  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;
  bool _hasNavigatedToBookmark = false;

  // Arabic tafsir cache
  final Map<String, String> _arabicTafsirCache = {};
  final Map<String, bool> _tafsirLoadingStates = {};

  // Scroll controllers for each page
  final Map<int, ScrollController> _pageScrollControllers = {};

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

    // Add page controller listener for haptic feedback on manual swiping
    _pageController.addListener(() {
      // Only add haptic feedback when page changes significantly (manual swiping)
      if (_pageController.page != null) {
        final currentPage = _pageController.page!.round();
        final actualPage = _pageController.page!;

        // Only trigger haptic when actively swiping (not at exact page positions)
        if ((actualPage - currentPage).abs() > 0.1) {
          HapticFeedback.selectionClick();
        }
      }
    });
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    _pageController.dispose();
    // Dispose all scroll controllers
    for (final controller in _pageScrollControllers.values) {
      controller.dispose();
    }
    _pageScrollControllers.clear();
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
          if (state.toastMessage != null) {
            CustomToastWidget.show(
              context: context,
              title: state.toastMessage!,
              iconPath: state.toastIconPath ?? AssetsPath.save,
            );
          }

          // Save last read position for Arabic Quran
          _saveLastReadPosition(state);

          // Handle highlight animation
          if (state.isHighlightAnimationActive &&
              state.highlightedAyahIndex != null) {
            _pulseAnimationController.repeat(reverse: true);
          } else {
            _pulseAnimationController.stop();
          }

          // Handle auto-scroll and auto-swipe for currently playing ayah
          if (state.isAudioPlaying && state.currentAyahIndex != null) {
            _handleCurrentlyPlayingAyah(state);
          }

          final bookmarkBloc = context.read<BookmarkBloc>();
          bookmarkBloc.add(CheckBookmarkStatus(
            surahId: state.surahNumber.toString(),
          ));

          // Handle bookmark navigation
          final quranReadingScreen =
              context.findAncestorWidgetOfExactType<ArabicQuranReadingScreen>();
          if (quranReadingScreen?.highlightAyah != null &&
              !_hasNavigatedToBookmark &&
              !state.isHighlightAnimationActive &&
              state.highlightedAyahIndex == null) {
            _hasNavigatedToBookmark = true;
            Future.delayed(const Duration(milliseconds: 2000), () {
              if (mounted) {
                context.read<QuranReadingBloc>().add(
                      HighlightBookmarkedAyah(
                          ayahNumber: quranReadingScreen!.highlightAyah!),
                    );
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
      toolbarHeight: 48.h,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios,
            color: themeState.textColor, size: 20.sp),
        onPressed: () => Navigator.pop(context),
      ),
      title: BlocBuilder<QuranReadingBloc, QuranReadingState>(
        builder: (context, readingState) {
          if (readingState is QuranReadingLoaded) {
            // Get the actual juz number from the first ayah
            final juzNumber = readingState.ayahs.isNotEmpty
                ? int.tryParse(readingState.ayahs.first['juz'].toString()) ?? 1
                : 1;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Surah name in white rectangle
                Container(
                  height: 40.h,
                  width: 104.w,
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    // color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: themeState.textColor.withOpacity(0.2)),
                  ),
                  child: Center(
                    child: Text(
                      readingState.surahName
                          .replaceAll('سُورَةُ ', '')
                          .replaceAll('سورة ', ''),
                      style: TextStyle(
                        fontFamily: 'KFGQPCUthmanicScriptHAFS',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: themeState.textColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                // Juz number in white rectangle
                Container(
                  height: 40.h,
                  width: 104.w,
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: themeState.textColor.withOpacity(0.2)),
                  ),
                  child: Center(
                    child: Text(
                      'الجزء ${_toArabicDigits('$juzNumber')}',
                      style: TextStyle(
                        fontFamily: 'KFGQPCUthmanicScriptHAFS',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: themeState.textColor,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return Text(
            'quran_reading'.tr,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: themeState.textColor,
            ),
          );
        },
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
    print('DEBUG: _buildBody called with state: ${readingState.runtimeType}');

    if (readingState is QuranReadingLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: CircularProgressIndicator(
              color: themeState.titleColor,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading Quran...',
            style: TextStyle(
              color: themeState.textColor,
              fontSize: 16.sp,
            ),
          ),
        ],
      );
    }

    if (readingState is QuranReadingError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: themeState.titleColor,
              size: 48.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              'Error loading Quran: ${readingState.message}',
              style: TextStyle(
                color: themeState.textColor,
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                // Retry loading - get the surah data from the parent widget
                final quranReadingScreen = context
                    .findAncestorWidgetOfExactType<ArabicQuranReadingScreen>();
                if (quranReadingScreen != null) {
                  context.read<QuranReadingBloc>().add(LoadSurahData(
                        surahNumber: quranReadingScreen.surahNumber,
                        surahName: quranReadingScreen.surahName,
                        startAyah: quranReadingScreen.startAyah,
                      ));
                }
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (readingState is QuranReadingLoaded) {
      // Group ayahs by their actual page numbers from the API
      final pages = _groupAyahsByPage(readingState.ayahs);

      return Center(
        child: Column(
          children: [
            // Surah title
            Padding(
              padding: EdgeInsets.only(top: 180.h,right: 16.w, left: 16.w),
              child: _buildSurahTitle(readingState, themeState),
            ),

            // Page view for horizontal sliding
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                itemBuilder: (context, pageIndex) {
                  return _buildQuranPage(
                    context,
                    pages[pageIndex],
                    pageIndex,
                    readingState,
                    themeState,
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    // Fallback for any other state
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.help_outline,
            color: themeState.titleColor,
            size: 48.sp,
          ),
          SizedBox(height: 16.h),
          Text(
            'Unknown state: ${readingState.runtimeType}',
            style: TextStyle(
              color: themeState.textColor,
              fontSize: 16.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              // Retry loading
              final quranReadingScreen = context
                  .findAncestorWidgetOfExactType<ArabicQuranReadingScreen>();
              if (quranReadingScreen != null) {
                context.read<QuranReadingBloc>().add(LoadSurahData(
                      surahNumber: quranReadingScreen.surahNumber,
                      surahName: quranReadingScreen.surahName,
                      startAyah: quranReadingScreen.startAyah,
                    ));
              }
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  List<List<Map<String, dynamic>>> _groupAyahsByPage(
      List<Map<String, dynamic>> ayahs) {
    final Map<int, List<Map<String, dynamic>>> pageGroups = {};

    for (final ayah in ayahs) {
      final pageNumber = int.tryParse(ayah['page'].toString()) ?? 1;
      if (!pageGroups.containsKey(pageNumber)) {
        pageGroups[pageNumber] = [];
      }
      pageGroups[pageNumber]!.add(ayah);
    }

    // Sort pages by page number and return as list
    final sortedPages = pageGroups.keys.toList()..sort();
    return sortedPages.map((pageNumber) => pageGroups[pageNumber]!).toList();
  }

  Widget _buildQuranPage(
    BuildContext context,
    List<Map<String, dynamic>> pageAyahs,
    int pageIndex,
    QuranReadingLoaded readingState,
    QuranThemeLoaded themeState,
  ) {
    // Get the actual page number from the first ayah in this page
    final actualPageNumber = pageAyahs.isNotEmpty
        ? int.tryParse(pageAyahs.first['page'].toString()) ?? (pageIndex + 1)
        : (pageIndex + 1);

    // Create scroll controller for this page if it doesn't exist
    if (!_pageScrollControllers.containsKey(pageIndex)) {
      _pageScrollControllers[pageIndex] = ScrollController();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      // padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      color: themeState.backgroundColor,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
              child: RichText(
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'KFGQPCUthmanicScriptHAFS',
                    fontSize: 22.0,
                    height: 1.7,
                    color: themeState.textColor,
                    // letterSpacing: 1.5,
                    // wordSpacing: 2.0,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                  ),
                  children: pageAyahs.expand((ayah) {
                    final ayahIndex = readingState.ayahs.indexOf(ayah);

                    if (!_ayahKeys.containsKey(ayahIndex)) {
                      _ayahKeys[ayahIndex] = GlobalKey();
                    }

                    return _buildQuranAyahh(
                      context,
                      ayah,
                      ayahIndex,
                      readingState,
                      themeState,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Page number (Arabic, aligned left)
          Align(
            alignment: Alignment.centerLeft,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  AssetsPath.pageNumber,
                  width: 40.w,
                  height: 40.h,
                ),
                Text(
                  _toArabicDigits('$actualPageNumber'),
                  style: TextStyle(
                    fontFamily: 'UthmanTN1-Ver10',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: themeState.textColor,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _toArabicDigits(String input) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var out = input;
    for (int i = 0; i < western.length; i++) {
      out = out.replaceAll(western[i], eastern[i]);
    }
    return out;
  }

  Widget _buildTopHeader(
    BuildContext context,
    QuranReadingLoaded readingState,
    QuranThemeLoaded themeState,
  ) {
    final isArabic = Get.locale?.languageCode == 'ar';

    // Get the actual juz number from the first ayah
    final juzNumber = readingState.ayahs.isNotEmpty
        ? int.tryParse(readingState.ayahs.first['juz'].toString()) ?? 1
        : 1;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Center(
        child: Text(
          '${readingState.surahName} الجزء ${_toArabicDigits('$juzNumber')}',
          style: TextStyle(
            fontFamily: 'KFGQPCUthmanicScriptHAFS',
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: themeState.textColor,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

 Widget _buildSurahTitle(
  QuranReadingLoaded readingState,
  QuranThemeLoaded themeState,
) {
  return Stack(
    alignment: Alignment.center,
    children: [
      SizedBox(
        width: double.infinity,
        child: SvgPicture.asset(
          AssetsPath.surahTitleSVG,
          height: 40.h,
          fit: BoxFit.fitWidth, 
          colorFilter: ColorFilter.mode(
            themeState.titleColor,
            BlendMode.srcIn,
          ),
        ),
      ),
      Positioned.fill(
        child: Center(
          child: Text(
            readingState.surahName
                .replaceAll('سُورَةُ ', '')
                .replaceAll('سورة ', ''),
            style: TextStyle(
              fontFamily: 'KFGQPCUthmanicScriptHAFS',
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: themeState.textColor,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ],
  );
}

  List<InlineSpan> _buildQuranAyahh(
    BuildContext context,
    Map<String, dynamic> ayah,
    int ayahIndex,
    QuranReadingLoaded readingState,
    QuranThemeLoaded themeState,
  ) {
    // Ensure the GlobalKey exists for this ayah
    if (!_ayahKeys.containsKey(ayahIndex)) {
      _ayahKeys[ayahIndex] = GlobalKey();
      print(
          'DEBUG: Created GlobalKey in _buildQuranAyahh for ayah index: $ayahIndex');
    }

    // Check if this ayah is bookmarked
    bool isBookmarkedAyah = false;
    final bookmarkBloc = context.read<BookmarkBloc>();
    if (bookmarkBloc.state is BookmarkLoaded) {
      final bookmarkState = bookmarkBloc.state as BookmarkLoaded;
      isBookmarkedAyah = bookmarkState.bookmarks.any(
        (bookmark) =>
            bookmark.surahId == readingState.surahNumber.toString() &&
            bookmark.ayahNumber == ayah['number'] &&
            bookmark.type == BookmarkType.ayah,
      );
    }

    return [
      TextSpan(
        text: ayah['text'].trim() + '\u00A0',
        style: TextStyle(
          fontFamily: 'AmiriQuran',
          fontWeight: FontWeight.w400,
          height: 1.5,
          fontStyle: FontStyle.normal,
          fontSize: themeState.quranFontSize,
          color: themeState.textColor,
          backgroundColor: Colors.transparent,
          
        ),
        recognizer: TapGestureRecognizer()
          ..onTapDown = (details) {
            context
                .read<QuranReadingBloc>()
                .add(HighlightAyah(ayahIndex: ayahIndex));
            _showAyahPopupMenu(
              context,
              details.globalPosition,
              ayah,
              ayahIndex,
              readingState,
              themeState,
              isBookmarkedAyah,
            );
          },
      ),
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: GestureDetector(
          key: _ayahKeys[ayahIndex], // Assign the GlobalKey here
          onTapDown: (details) {
            context
                .read<QuranReadingBloc>()
                .add(HighlightAyah(ayahIndex: ayahIndex));
            _showAyahPopupMenu(
              context,
              details.globalPosition,
              ayah,
              ayahIndex,
              readingState,
              themeState,
              isBookmarkedAyah,
            );
          },
          child: Container(
            width: themeState.quranFontSize * 1.2,
            height: themeState.quranFontSize * 1.4,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  '۝',
                  style: TextStyle(
                    fontFamily: 'KFGQPCUthmanicScriptHAFS',
                    fontSize: 22.0 * 1.2,
                      color: Color(0xFFA7805A),
                    height: 1.0,
                  ),
                ),
                Text(
                  _toArabicDigits('${ayah['number']}'),
                  style: const TextStyle(
                    fontFamily: 'KFGQPCUthmanicScriptHAFS',
                    fontSize: 25.0 / 2.0,
                    fontWeight: FontWeight.bold,
                      color: Color(0xFFA7805A),
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      TextSpan(text: '\u00A0'),
    ];
  }

  void _handleCurrentlyPlayingAyah(QuranReadingLoaded state) {
    if (state.currentAyahIndex == null) return;

    print('DEBUG: Handling currently playing ayah: ${state.currentAyahIndex}');

    // Get current page index
    final pages = _groupAyahsByPage(state.ayahs);
    int currentPageIndex = 0;

    // Find which page contains the current ayah
    for (int i = 0; i < pages.length; i++) {
      final pageAyahs = pages[i];
      final ayahIndices =
          pageAyahs.map((ayah) => state.ayahs.indexOf(ayah)).toList();

      if (ayahIndices.contains(state.currentAyahIndex)) {
        currentPageIndex = i;
        break;
      }
    }

    print('DEBUG: Current page index: $currentPageIndex');

    // Check if current ayah is the last ayah on the current page
    final currentPageAyahs = pages[currentPageIndex];
    final currentPageAyahIndices =
        currentPageAyahs.map((ayah) => state.ayahs.indexOf(ayah)).toList();
    final isLastAyahOnPage =
        currentPageAyahIndices.last == state.currentAyahIndex;

    print('DEBUG: Is last ayah on page: $isLastAyahOnPage');

    // Auto-scroll to the currently playing ayah if it's not visible
    _scrollToCurrentAyah(state, currentPageIndex);

    // If it's the last ayah on the page and not the last page, prepare for auto-swipe
    if (isLastAyahOnPage && currentPageIndex < pages.length - 1) {
      // Store the current page index for auto-swipe when audio completes
      _lastPageIndexForAutoSwipe = currentPageIndex;
      print('DEBUG: Prepared for auto-swipe from page $currentPageIndex');

      // Set a timer to auto-swipe after a delay (simulating audio completion)
      Future.delayed(const Duration(milliseconds: 3000), () {
        if (mounted &&
            _pageController.hasClients &&
            _lastPageIndexForAutoSwipe == currentPageIndex) {
          print('DEBUG: Auto-swiping to next page after delay');
          _swipeToPage(currentPageIndex + 1);
          _lastPageIndexForAutoSwipe = null; // Reset to prevent multiple swipes
        }
      });
    }
  }

  int? _lastPageIndexForAutoSwipe;

  void _scrollToCurrentAyah(QuranReadingLoaded state, int currentPageIndex) {
    final scrollController = _pageScrollControllers[currentPageIndex];
    if (scrollController == null || !scrollController.hasClients) {
      print(
          'DEBUG: Scroll controller not available for page $currentPageIndex');
      return;
    }

    // Ensure the GlobalKey exists for the current ayah
    if (!_ayahKeys.containsKey(state.currentAyahIndex)) {
      _ayahKeys[state.currentAyahIndex] = GlobalKey();
      print(
          'DEBUG: Created GlobalKey for ayah index: ${state.currentAyahIndex}');
    }

    final key = _ayahKeys[state.currentAyahIndex];
    if (key != null && key.currentContext != null) {
      try {
        // Check if the ayah is visible on screen
        final RenderBox renderBox =
            key.currentContext!.findRenderObject() as RenderBox;
        final position = renderBox.localToGlobal(Offset.zero);
        final screenHeight = MediaQuery.of(context).size.height;

        print(
            'DEBUG: Ayah position: ${position.dy}, screen height: $screenHeight');

        // If ayah is not visible (below the screen), scroll to it immediately
        if (position.dy > screenHeight * 0.8) {
          print('DEBUG: Auto-scrolling to ayah');
          Scrollable.ensureVisible(
            key.currentContext!,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            alignment: 0.3, // Position ayah at 30% from top
          );
        }
      } catch (e) {
        // Handle any rendering errors gracefully
        print('Error scrolling to ayah: $e');
      }
    } else {
      print('DEBUG: Ayah key or context not available, retrying in 500ms');
      // Retry after a short delay to allow the widget to be built
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _scrollToCurrentAyah(state, currentPageIndex);
        }
      });
    }
  }

  void _swipeToPage(int pageIndex) {
    if (_pageController.hasClients) {
      // Add haptic feedback for page swiping
      HapticFeedback.selectionClick();

      _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Unused legacy builder retained for reference; not used in new layout.
  Widget _buildQuranAyah(
    BuildContext context,
    Map<String, dynamic> ayah,
    int ayahIndex,
    QuranReadingLoaded readingState,
    QuranThemeLoaded themeState,
  ) {
    final isHighlighted = readingState.highlightedAyahIndex == ayahIndex;
    final isHighlightedBookmark =
        readingState.isHighlightAnimationActive && isHighlighted;

    // Check if this ayah is bookmarked
    bool isBookmarkedAyah = false;
    final bookmarkBloc = context.read<BookmarkBloc>();
    if (bookmarkBloc.state is BookmarkLoaded) {
      final bookmarkState = bookmarkBloc.state as BookmarkLoaded;
      isBookmarkedAyah = bookmarkState.bookmarks.any(
        (bookmark) =>
            bookmark.surahId == readingState.surahNumber.toString() &&
            bookmark.ayahNumber == ayah['number'] &&
            bookmark.type == BookmarkType.ayah,
      );
    }

    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        context
            .read<QuranReadingBloc>()
            .add(HighlightAyah(ayahIndex: ayahIndex));
        _showAyahPopupMenu(context, details.globalPosition, ayah, ayahIndex,
            readingState, themeState, isBookmarkedAyah);
      },
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isHighlightedBookmark ? _pulseAnimation.value : 1.0,
            child: Container(
              key: _ayahKeys[ayahIndex],
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isBookmarkedAyah
                    ? themeState.titleColor.withOpacity(0.1)
                    : isHighlighted
                        ? themeState.titleColor.withOpacity(0.05)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: isBookmarkedAyah
                    ? Border.all(
                        color: themeState.titleColor.withOpacity(0.3),
                        width: 1,
                      )
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    child: RichText(
                      textDirection: TextDirection.rtl,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: ayah['text'].trim() + '\u00A0',
                            style: TextStyle(
                              fontFamily: 'KFGQPCUthmanicScriptHAFS',
                              fontSize: 22.0,
                              color: themeState.textColor,
                              height: 1.0,
                              letterSpacing: 1.5,
                              wordSpacing: 4.0,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                          WidgetSpan(
                            child: Transform.translate(
                              offset: const Offset(0, -2),
                              child: Container(
                                width: themeState.quranFontSize * 1.4,
                                height: themeState.quranFontSize * 1.4,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Text(
                                      '۝',
                                      style: TextStyle(
                                        fontFamily: 'KFGQPCUthmanicScriptHAFS',
                                        fontSize: 22.0 * 1.4,
                                        color: themeState.textColor,
                                        height: 1.0,
                                      ),
                                    ),
                                    Text(
                                      _toArabicDigits('${ayah['number']}'),
                                      style: TextStyle(
                                        fontFamily: 'KFGQPCUthmanicScriptHAFS',
                                        fontSize: 22.0 / 1.8,
                                        fontWeight: FontWeight.w700,
                                        color: themeState.textColor,
                                        height: 1.0,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            alignment: PlaceholderAlignment.middle,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Bookmark indicator
                  if (isBookmarkedAyah) ...[
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.bookmark,
                      size: 14.sp,
                      color: themeState.titleColor.withOpacity(0.7),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
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
                              icon: isBookmarkedAyah
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
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
                                _showArabicTafsir(
                                    context, ayah, readingState, themeState);
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: themeState.titleColor,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: themeState.titleColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showArabicTafsir(
    BuildContext context,
    Map<String, dynamic> ayah,
    QuranReadingLoaded readingState,
    QuranThemeLoaded themeState,
  ) {
    final tafsirKey = '${readingState.surahNumber}:${ayah['number']}';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: themeState.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.book,
                      size: 24.sp,
                      color: themeState.titleColor,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'tafsir'.tr,
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: themeState.titleColor,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, color: themeState.textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                FutureBuilder<String>(
                  future: _getArabicTafsir(tafsirKey),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: themeState.titleColor,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Text(
                        'error_loading_tafsir'.tr,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: themeState.textColor.withOpacity(0.7),
                        ),
                      );
                    }

                    return Text(
                      snapshot.data ?? 'no_tafsir_available'.tr,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        height: 1.6,
                        color: themeState.textColor,
                      ),
                      textAlign: TextAlign.justify,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String> _getArabicTafsir(String tafsirKey) async {
    // Check cache first
    if (_arabicTafsirCache.containsKey(tafsirKey)) {
      return _arabicTafsirCache[tafsirKey]!;
    }

    // Check if already loading
    if (_tafsirLoadingStates[tafsirKey] == true) {
      return 'loading_tafsir'.tr;
    }

    _tafsirLoadingStates[tafsirKey] = true;

    try {
      // Use a reliable Arabic tafsir API
      final response = await http.get(
        Uri.parse('https://api.quran.gading.dev/tafsir/ar-muyassar/$tafsirKey'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tafsirText = data['data']['text'] ?? 'no_tafsir_available'.tr;

        // Cache the result
        _arabicTafsirCache[tafsirKey] = tafsirText;
        _tafsirLoadingStates[tafsirKey] = false;

        return tafsirText;
      } else {
        // Fallback to sample Arabic tafsir
        final sampleTafsir = _getSampleArabicTafsir(tafsirKey);
        _arabicTafsirCache[tafsirKey] = sampleTafsir;
        _tafsirLoadingStates[tafsirKey] = false;
        return sampleTafsir;
      }
    } catch (e) {
      print('Error fetching Arabic tafsir: $e');
      final sampleTafsir = _getSampleArabicTafsir(tafsirKey);
      _arabicTafsirCache[tafsirKey] = sampleTafsir;
      _tafsirLoadingStates[tafsirKey] = false;
      return sampleTafsir;
    }
  }

  String _getSampleArabicTafsir(String tafsirKey) {
    // Sample Arabic tafsir for common ayahs
    final sampleTafsir = {
      '1:1':
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ - أي: أبدأ قراءة القرآن باسم الله، مستعيناً به، متبركاً به، والله هو المعبود المستحق للعبادة، والرحمن الرحيم من أسماء الله الحسنى، الدالة على سعة رحمته التي وسعت كل شيء.',
      '1:2':
          'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ - أي: الثناء على الله بصفاته التي كلها أوصاف كمال، وبنعمه الظاهرة والباطنة، الدينية والدنيوية، وفي ضمنه أمر لعباده أن يحمدوه، فهو المستحق وحده للحمد والثناء، وله الأسماء الحسنى والصفات العلى، لا إله إلا هو.',
      '1:3':
          'الرَّحْمَٰنِ الرَّحِيمِ - أي: ذي الرحمة الواسعة العظيمة التي وسعت كل شيء، وعمت كل حي، وكتبها للمتقين المتبعين لأنبيائه ورسله.',
      '1:4':
          'مَالِكِ يَوْمِ الدِّينِ - أي: يوم الجزاء والحساب، وهو يوم القيامة، وخص بالذكر لأنه لا ملك ظاهراً فيه لأحد إلا لله تعالى، بدليل قوله تعالى: "لمن الملك اليوم لله" وفي ذلك اليوم يظهر للخلق جميعاً عدم صحة ما كانوا يعتقدونه، وتبطل جميع الأنداد والآلهة التي كانوا يعبدونها من دون الله.',
      '1:5':
          'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ - أي: نخصك وحدك بالعبادة، ونخصك وحدك بالاستعانة، فلا نعبد أحداً سواك، ولا نستعين بأحد غيرك، وهذا هو كمال الطاعة، والدين كله يرجع إلى هذين المعنيين.',
      '1:6':
          'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ - أي: دلنا وأرشدنا، وثبتنا على الصراط المستقيم، وهو الإسلام، الذي هو الطريق الواضح الموصل إلى رضوان الله وإلى جنته، الذي دل عليه خاتم رسله وأنبيائه محمد صلى الله عليه وسلم، فلا سبيل إلى سعادة العبد إلا بالاستقامة عليه.',
      '1:7':
          'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ - أي: طريق الذين أنعمت عليهم من النبيين والصدقين والشهداء والصالحين، فهم أهل الهداية والاستقامة، ولا تجعلنا ممن سلك طريق المغضوب عليهم، وهم اليهود، ومن كان على شاكلتهم، والضالين، وهم النصارى، ومن اتبع سنتهم.',
    };

    return sampleTafsir[tafsirKey] ?? 'التفسير غير متوفر حالياً لهذه الآية.';
  }

  void _handleSaveAyah(BuildContext context, Map<String, dynamic> ayah,
      QuranReadingLoaded readingState) {
    final bookmarkBloc = context.read<BookmarkBloc>();
    final bookmarkState = bookmarkBloc.state;

    if (bookmarkState is BookmarkLoaded) {
      final existingBookmark = bookmarkState.bookmarks
          .where(
            (bookmark) =>
                bookmark.surahId == readingState.surahNumber.toString() &&
                bookmark.ayahNumber == ayah['number'] &&
                bookmark.type == BookmarkType.ayah,
          )
          .firstOrNull;

      if (existingBookmark != null) {
        // Remove bookmark
        bookmarkBloc.add(RemoveBookmark(bookmarkId: existingBookmark.id));
      } else {
        // Add bookmark
        bookmarkBloc.add(AddAyahBookmark(
          surahId: readingState.surahNumber.toString(),
          surahName: readingState.surahName,
          surahNumber: readingState.surahNumber,
          ayahNumber: ayah['number'],
          ayahText: ayah['text'],
          ayahTranslation: ayah['translation'] ?? '',
          pageNumber: int.tryParse(ayah['page'].toString()) ?? 1,
          juzNumber: int.tryParse(ayah['juz'].toString()) ?? 1,
          scrollPosition: 0.0, // Default scroll position
        ));
      }
    }
  }

  void _saveLastReadPosition(QuranReadingLoaded state) async {
    try {
      if (state.ayahs.isNotEmpty) {
        final firstAyah = state.ayahs.first;
        final pageNumber = int.tryParse(firstAyah['page'].toString()) ?? 1;
        final juzNumber = int.tryParse(firstAyah['juz'].toString()) ?? 1;
        final ayahNumber = int.tryParse(firstAyah['number'].toString()) ?? 1;

        print('DEBUG: Arabic Quran - Saving last read data:');
        print('  Surah: ${state.surahNumber} - ${state.surahName}');
        print('  Page: $pageNumber');
        print('  Juz: $juzNumber');
        print('  Ayah: $ayahNumber');

        await LastReadService.saveLastRead(
          surahNumber: state.surahNumber,
          surahName: state.surahName,
          pageNumber: pageNumber,
          juzNumber: juzNumber,
          ayahNumber: ayahNumber,
        );
      }
    } catch (e) {
      print('Error saving last read position: $e');
    }
  }

  void _togglePageBookmark(BuildContext context, QuranThemeLoaded themeState) {
    final bookmarkBloc = context.read<BookmarkBloc>();
    final bookmarkState = bookmarkBloc.state;

    if (bookmarkState is BookmarkLoaded) {
      final readingState = context.read<QuranReadingBloc>().state;
      if (readingState is QuranReadingLoaded) {
        final existingBookmark = bookmarkState.bookmarks
            .where(
              (bookmark) =>
                  bookmark.surahId == readingState.surahNumber.toString() &&
                  bookmark.type == BookmarkType.page,
            )
            .firstOrNull;

        if (existingBookmark != null) {
          bookmarkBloc.add(RemoveBookmark(bookmarkId: existingBookmark.id));
        } else {
          bookmarkBloc.add(AddPageBookmark(
            surahId: readingState.surahNumber.toString(),
            surahName: readingState.surahName,
            surahNumber: readingState.surahNumber,
            pageNumber: 1,
            juzNumber: 1,
          ));
        }
      }
    }
  }
}
