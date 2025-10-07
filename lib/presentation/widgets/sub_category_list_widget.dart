import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manara/data/models/category_list_model.dart';
import 'package:manara/presentation/views/al_quran_details_screen.dart';
import 'package:manara/presentation/views/all_category_details_screen.dart';

import '../../constants/colors.dart';
import '../../constants/images.dart';
import '../../data/viewmodel/category_list_controller.dart';
import '../../data/viewmodel/check_language_controller.dart';
import 'app_background_image_widget.dart';
import 'category_item_card_widget.dart';
import 'custom_appbar_widget.dart';
import 'loading_popup_widget.dart';

class SubCategoryListWidget extends StatefulWidget {
  const SubCategoryListWidget(
      {super.key,
      required this.categoryTitle,
      required this.iconPath,
      required this.categoryName,
      required this.cateSign});

  final String categoryTitle, iconPath, categoryName, cateSign;

  @override
  State<SubCategoryListWidget> createState() => _SubCategoryListWidgetState();
}

class _SubCategoryListWidgetState extends State<SubCategoryListWidget> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      widget.cateSign == 'AL-QURAN'
          ? await Get.find<CategoryListController>()
              .getCategoryList(widget.cateSign)
          : await Get.find<CategoryListController>()
              .getCategoryList(widget.categoryName);
      await LanguageCheckingController.getLanguage();
    });
    super.initState();
    setState(() {});
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
            screenTitle: widget.categoryTitle,
          ),
          GetBuilder<CategoryListController>(builder: (categoryListController) {
            if (categoryListController.categoryDataFetchInProgress) {
              return const LoadingPopupWidget();
            }
            if (categoryListController.categoryList.isEmpty &&
                (categoryListController.surahListModel.data?.isEmpty ?? true)) {
              return Center(
                child: Text(
                  '${widget.categoryTitle.tr} is empty!',
                  style: const TextStyle(
                      color: AppColors.colorWhiteHighEmp, fontSize: 20),
                ),
              );
            }
            final List<CategoryListModel> categoryListData =
                categoryListController.categoryList;
            return Padding(
              padding: const EdgeInsets.only(
                  top: 97, left: 16, right: 16, bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: ShapeDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment(0.00, -1.00),
                    end: Alignment(0, 1),
                    colors: [
                      AppColors.colorGradient1Start,
                      AppColors.colorGradient1End
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: 0),
                  itemCount: widget.cateSign == 'AL-QURAN'
                      ? categoryListController.surahListModel.data?.length ?? 0
                      : categoryListData.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () async {
                        widget.cateSign == 'AL-QURAN'
                            ? Get.to(() => AlQuranScreen(
                                  surahName:
                                      LanguageCheckingController.setLang == 'ar'
                                          ? categoryListController
                                              .surahListModel
                                              .data![index]
                                              .name!
                                              .short!
                                          : categoryListController
                                              .surahListModel
                                              .data![index]
                                              .name!
                                              .transliteration!
                                              .en!,
                                  surahNumber: index + 1,
                                ))
                            : Get.to(
                                () => AllCategoryDetailsWidgets(
                                  categoryName: LanguageCheckingController.setLang ==
                                          'en'
                                      ? categoryListData[index].categoryEnglish ??
                                          ''
                                      : LanguageCheckingController.setLang ==
                                              'tr'
                                          ? categoryListData[index]
                                                  .categoryTurkish ??
                                              ''
                                          : LanguageCheckingController.setLang ==
                                                  'ur'
                                              ? categoryListData[index]
                                                      .categoryUrdu ??
                                                  ''
                                              : LanguageCheckingController
                                                          .setLang ==
                                                      'bn'
                                                  ? categoryListData[index]
                                                          .categoryBangla ??
                                                      ''
                                                  : LanguageCheckingController
                                                              .setLang ==
                                                          'fr'
                                                      ? categoryListData[index]
                                                              .categoryFrench ??
                                                          ''
                                                      : LanguageCheckingController
                                                                  .setLang ==
                                                              'hi'
                                                          ? categoryListData[index]
                                                                  .categoryHindi ??
                                                              ''
                                                          : categoryListData[index]
                                                                  .categoryArabic ??
                                                              '',
                                  cateSign: widget.cateSign,
                                  categoryNameEng:
                                      categoryListData[index].categoryEnglish ??
                                          '',
                                  id: categoryListData[index].sId ?? '',
                                ),
                              );
                      },

                      ///Surah name
                      ///hadith
                      ///Azkar Dua
                      child: CategoryItemCardWidget(
                        iconImagePath: widget.iconPath,
                        title: widget.cateSign == 'AL-QURAN'
                            ? LanguageCheckingController.setLang == 'ar'
                                ? categoryListController
                                    .surahListModel.data![index].name!.short!
                                : categoryListController.surahListModel
                                    .data![index].name!.transliteration!.en!
                            : LanguageCheckingController.setLang == 'en'
                                ? categoryListData[index].categoryEnglish ?? ''
                                : LanguageCheckingController.setLang == 'tr'
                                    ? categoryListData[index].categoryTurkish ??
                                        ''
                                    : LanguageCheckingController.setLang == 'ur'
                                        ? categoryListData[index]
                                                .categoryUrdu ??
                                            ''
                                        : LanguageCheckingController.setLang ==
                                                'bn'
                                            ? categoryListData[index]
                                                    .categoryBangla ??
                                                ''
                                            : LanguageCheckingController
                                                        .setLang ==
                                                    'fr'
                                                ? categoryListData[index]
                                                        .categoryFrench ??
                                                    ''
                                                : LanguageCheckingController
                                                            .setLang ==
                                                        'hi'
                                                    ? categoryListData[index]
                                                            .categoryHindi ??
                                                        ''
                                                    : categoryListData[index]
                                                            .categoryArabic ??
                                                        '',
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
