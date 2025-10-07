import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manara/data/models/al_quran_surah/full_surah_details_model.dart';

import '../../constants/colors.dart';
import '../../constants/images.dart';
import '../../data/viewmodel/full_surah_details_controller.dart';
import '../widgets/app_background_image_widget.dart';
import '../widgets/custom_appbar_widget.dart';
import '../widgets/loading_popup_widget.dart';
import '../widgets/surah_ayat_details_card_widget.dart';
import '../widgets/surah_datails_card_widget.dart';

class AlQuranScreen extends StatefulWidget {
  const AlQuranScreen({
    Key? key,
    required this.surahName,
    required this.surahNumber,
  }) : super(key: key);

  final String surahName;
  final int surahNumber;

  @override
  State<AlQuranScreen> createState() => _AlQuranScreenState();
}

class _AlQuranScreenState extends State<AlQuranScreen> {
  int selectedCardIndex = -1;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentIndex = 0;
  bool _isAudioPlaying = false;
  List<String> surahUrlsList = [];

  // Play audio method

  void _initAudioPlayer() {
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isAudioPlaying = false;
        if (_currentIndex < surahUrlsList.length - 1) {
          _currentIndex++;
          _playAudio(surahUrlsList[_currentIndex]);
        }
      });
    });
  }

  // Audio play method
  Future<void> _playAudio(String url) async {
    await _audioPlayer.play(UrlSource(url));
    setState(() {
      _isAudioPlaying = true;
    });
  }

  // Audio pause method
  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
    setState(() {
      _isAudioPlaying = false;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Get.find<FullSurahDetailsController>()
          .getFullSurahDetails(widget.surahNumber);
    });
    super.initState();
    // Play audio method
    _initAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AppBackgroundImageWidget(
            bgImagePath: AssetsPath.secondaryBGSVG,
          ),
          CustomAppbarWidget(
            screenTitle: widget.surahName,
          ),
          GetBuilder<FullSurahDetailsController>(
            builder: (fullSurahDetailsController) {
              if (fullSurahDetailsController.fullSurahFetchInProgress) {
                return const LoadingPopupWidget();
              }
              final List<Verses> versesDataList =
                  fullSurahDetailsController.versesList!;
              surahUrlsList.clear();
              for (int i = 0; i < versesDataList.length; i++) {
                surahUrlsList.add(versesDataList[i].audio!.primary!);
              }
              return Padding(
                padding: const EdgeInsets.only(
                  top: 97,
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.only(top: 0),
                  itemCount: versesDataList.length,
                  itemBuilder: (context, index) {
                    final verse = versesDataList[index];
                    if (index == 0) {
                      return SurahAyatDetailsCardWidget(
                        arabic: verse.text?.arab ?? '',
                        english: verse.translation?.en ?? '',
                        surahName: widget.surahName,
                        onIconTap: () {
                          if (selectedCardIndex == -1) {
                            if (_isAudioPlaying) {
                              _pauseAudio();
                            } else {
                              _playAudio(surahUrlsList[_currentIndex]);
                            }
                          }
                        },
                        isAudioPlaying: _isAudioPlaying,
                      );
                    } else {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCardIndex =
                                selectedCardIndex == index ? -1 : index;
                            _currentIndex = selectedCardIndex;
                            _pauseAudio();
                            if (selectedCardIndex == -1) {
                              _currentIndex = 0;
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedCardIndex == index
                                  ? AppColors.colorInfo
                                  : Colors.transparent,
                              width: selectedCardIndex == index ? 2 : 0,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: SurahDetailsCardWidget(
                            surahEnglish: verse.translation?.en ?? '',
                            surahArabic: verse.text?.arab ?? '',
                          ),
                        ),
                      );
                    }
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(
                      height: 8,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: selectedCardIndex != -1
          ? FloatingActionButton(
              backgroundColor: AppColors.colorPrimary,
              onPressed: () {
                setState(() {
                  if (_isAudioPlaying) {
                    _pauseAudio();
                  } else {
                    _playAudio(surahUrlsList[_currentIndex]);
                  }
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                _isAudioPlaying ? Icons.pause : Icons.play_arrow,
                color: AppColors.colorWhiteHighEmp,
              ),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
