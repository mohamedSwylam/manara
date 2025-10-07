
class DuaCategoryDataListModel {
  String? sId;
  String? duaArabic;
  String? duaEnglish;
  String? duaTurkish;
  String? duaUrdu;
  String? duaBangla;
  String? duaHindi;
  String? duaFrench;
  String? titleBangla;
  String? titleHindi;
  String? titleFrench;
  String? titleArabic;
  String? titleEnglish;
  String? titleTurkish;
  String? titleUrdu;
  String? categoryId;
  String? timestamp;
  String? categoryArabic;
  String? categoryEnglish;
  String? categoryTurkish;
  String? categoryUrdu;

  DuaCategoryDataListModel(
      {
        this.sId,
        this.duaArabic,
        this.duaEnglish,
        this.duaTurkish,
        this.duaUrdu,
        this.duaBangla,
        this.duaHindi,
        this.duaFrench,
        this.titleBangla,
        this.titleHindi,
        this.titleFrench,
        this.titleArabic,
        this.titleEnglish,
        this.titleTurkish,
        this.titleUrdu,
        this.categoryId,
        this.timestamp,
        this.categoryArabic,
        this.categoryEnglish,
        this.categoryTurkish,
        this.categoryUrdu});

  DuaCategoryDataListModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    duaArabic = json['duaArabic'];
    duaEnglish = json['duaEnglish'];
    duaTurkish = json['duaTurkish'];
    duaUrdu = json['duaUrdu'];
    duaBangla = json['duaBangla'];
    duaHindi = json['duaHindi'];
    duaFrench = json['duaFrench'];
    titleBangla = json['titleBangla'];
    titleHindi = json['titleHindi'];
    titleFrench = json['titleFrench'];
    titleArabic = json['titleArabic'];
    titleEnglish = json['titleEnglish'];
    titleTurkish = json['titleTurkish'];
    titleUrdu = json['titleUrdu'];
    categoryId = json['category_id'];
    timestamp = json['timestamp'];
    categoryArabic = json['categoryArabic'];
    categoryEnglish = json['categoryEnglish'];
    categoryTurkish = json['categoryTurkish'];
    categoryUrdu = json['categoryUrdu'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['duaArabic'] = duaArabic;
    data['duaEnglish'] = duaEnglish;
    data['duaTurkish'] = duaTurkish;
    data['duaUrdu'] = duaUrdu;
    data['duaBangla'] = duaBangla;
    data['duaHindi'] = duaHindi;
    data['duaFrench'] = duaFrench;
    data['titleBangla'] = titleBangla;
    data['titleHindi'] = titleHindi;
    data['titleFrench'] = titleFrench;
    data['titleArabic'] = titleArabic;
    data['titleEnglish'] = titleEnglish;
    data['titleTurkish'] = titleTurkish;
    data['titleUrdu'] = titleUrdu;
    data['category_id'] = categoryId;
    data['timestamp'] = timestamp;
    data['categoryArabic'] = categoryArabic;
    data['categoryEnglish'] = categoryEnglish;
    data['categoryTurkish'] = categoryTurkish;
    data['categoryUrdu'] = categoryUrdu;
    return data;
  }
}
