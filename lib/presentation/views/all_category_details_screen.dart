import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manara/data/models/azkar_category_data_list_model.dart';
import 'package:manara/data/models/dua_category_data_list_model.dart';
import 'package:manara/data/models/event_prayer_category_data_list_model.dart';
import 'package:manara/data/models/hadith_category_data_list_model.dart';

import '../../constants/colors.dart';
import '../../constants/images.dart';
import '../../data/viewmodel/azkar_category_data_list_controller.dart';
import '../../data/viewmodel/dua_category_data_list_controller.dart';
import '../../data/viewmodel/event_prayer_category_data_list_controller.dart';
import '../../data/viewmodel/hadith_category_data_list_controller.dart';
import '../widgets/app_background_image_widget.dart';
import '../widgets/azkar_details_card_widget.dart';
import '../widgets/category_data_details_card_widget.dart';
import '../widgets/custom_appbar_widget.dart';
import '../widgets/loading_popup_widget.dart';

class AllCategoryDetailsWidgets extends StatefulWidget {
  const AllCategoryDetailsWidgets({
    Key? key,
    required this.id,
    required this.categoryName,
    required this.cateSign,
    required this.categoryNameEng,
  }) : super(key: key);

  final String categoryName;
  final String categoryNameEng;
  final String cateSign;
  final String id;

  @override
  State<AllCategoryDetailsWidgets> createState() =>
      _AllCategoryDetailsWidgetsState();
}

class _AllCategoryDetailsWidgetsState extends State<AllCategoryDetailsWidgets> {
  List<HadithCategoryDataListModel> hadithCategoryDataList = [];
  List<DuaCategoryDataListModel> duaCategoryDataList = [];
  List<AzkarCategoryDataListModel> azkarCategoryDataList = [];
  List<EventPrayerCategoryDataListModel> eventPrayersCategoryDataList = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // Loading indicator method
      showLoadingDialog(context);
      await callAPIController();

      Get.back();
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Widget Function(int)> cardBuilders = {
      'HADITH': buildHadithCard,
      'DUA': buildDuaCard,
      'AZKAR': buildAzkarCard,
      'EVENT-PRAYERS': buildEventPrayersCard,
    };

    final List? dataList = getDataList();

    return Scaffold(
      body: Stack(
        children: [
          AppBackgroundImageWidget(
            bgImagePath: AssetsPath.secondaryBGSVG,
          ),
          CustomAppbarWidget(
            screenTitle: widget.categoryName,
          ),
          dataList!.isEmpty
              ? const Center(
                  child: Text(
                  "",
                  style: TextStyle(
                      color: AppColors.colorWhiteHighEmp, fontSize: 20),
                ))
              : Padding(
                  padding: const EdgeInsets.only(
                      top: 97, left: 16, right: 16, bottom: 16),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 0),
                    itemCount: dataList.length,
                    itemBuilder: (context, index) {
                      final builder = cardBuilders[widget.cateSign];
                      if (builder != null) {
                        return builder(index);
                      }
                      return null;
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(
                        height: 8,
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  List? getDataList() {
    switch (widget.cateSign) {
      case 'HADITH':
        return hadithCategoryDataList;
      case 'DUA':
        return duaCategoryDataList;
      case 'AZKAR':
        return azkarCategoryDataList;
      case 'EVENT-PRAYERS':
        return eventPrayersCategoryDataList;
      default:
        return null;
    }
  }

  Widget buildHadithCard(int index) {
    final data = hadithCategoryDataList[index];
    return CategoryDataDetailsCardWidget(
      amolEnglish: data.hadithEnglish ?? '',
      amolArabic: data.hadithArabic ?? '',
      authorName: data.narratedBy ?? '',
      title: data.referenceBook ?? '',
      amolTurkish: data.hadithTurkish ?? '',
      amolUrdu: data.hadithUrdu ?? '',
      amolBangla: data.hadithBangla ?? '',
      amolFrench: data.hadithFrench ?? '',
      amolHindi: data.hadithHindi ?? '',
    );
  }

  Widget buildDuaCard(int index) {
    final data = duaCategoryDataList[index];
    return CategoryDataDetailsCardWidget(
      amolEnglish: data.duaEnglish ?? '',
      amolArabic: data.duaArabic ?? '',
      title: data.titleEnglish ?? '',
      amolTurkish: data.duaTurkish ?? '',
      amolUrdu: data.duaArabic ?? '',
      amolBangla: data.duaBangla ?? '',
      amolFrench: data.duaFrench ?? '',
      amolHindi: data.duaHindi ?? '',
    );
  }

  Widget buildAzkarCard(int index) {
    final data = azkarCategoryDataList[index];
    return AzkarDetailsCardWidget(
      azkarEnglish: data.azkarEnglish ?? '',
      azkarArabic: data.azkarArabic ?? '',
      azkarTurkish: data.azkarTurkish ?? '',
      azkarUrdu: data.azkarUrdu ?? '',
      azkarBangla: data.azkarBangla ?? '',
      azkarFrench: data.azkarFrench ?? '',
      azkarHindi: data.azkarHindi ?? '',
    );
  }

  Widget buildEventPrayersCard(int index) {
    final data = eventPrayersCategoryDataList[index];
    return AzkarDetailsCardWidget(
      azkarEnglish: data.eventPrayerEnglish ?? '',
      azkarArabic: data.eventPrayerArabic ?? '',
      azkarTurkish: '',
      azkarUrdu: '',
      azkarBangla: '',
      azkarFrench: '',
      azkarHindi: '',
    );
  }

  Future<void> callAPIController() async {
    switch (widget.cateSign) {
      case 'HADITH':
        await fetchHadithData();
        break;
      case 'DUA':
        await fetchDuaData();
        break;
      case 'AZKAR':
        await fetchAzkarData();
        break;
      case 'EVENT-PRAYERS':
        await fetchEventPrayersData();
        break;
      default:
        break;
    }
  }

  Future<void> fetchHadithData() async {
    await Get.find<HadithCategoryDataListController>()
        .getHadithCategoryData(widget.id);
    hadithCategoryDataList =
        Get.find<HadithCategoryDataListController>().hadithCategoryDataList;
  }

  Future<void> fetchDuaData() async {
    await Get.find<DuaCategoryDataListController>()
        .getDuaCategoryData(widget.id);
    duaCategoryDataList =
        Get.find<DuaCategoryDataListController>().duaCategoryDataList;
  }

  Future<void> fetchAzkarData() async {
    await Get.find<AzkarCategoryDataListController>()
        .getAzkarCategoryData(widget.id);
    azkarCategoryDataList =
        Get.find<AzkarCategoryDataListController>().azkarCategoryDataList;
  }

  Future<void> fetchEventPrayersData() async {
    await Get.find<EventPrayerCategoryDataListController>()
        .getEventPrayerCategoryData(widget.id);
    eventPrayersCategoryDataList =
        Get.find<EventPrayerCategoryDataListController>()
            .eventPrayerCategoryDataList;
  }

  // Loading indicator
  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const LoadingPopupWidget();
      },
    );
  }
}
