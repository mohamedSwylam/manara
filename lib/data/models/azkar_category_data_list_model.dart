class AzkarCategoryDataListModel {
  String? sId;
  String? azkarEnglish;
  String? azkarArabic;
  String? azkarTurkish;
  String? azkarUrdu;
  String? azkarBangla;
  String? azkarHindi;
  String? azkarFrench;
  String? categoryId;
  String? timestamp;
  String? categoryArabic;
  String? categoryEnglish;
  String? categoryTurkish;
  String? categoryUrdu;

  AzkarCategoryDataListModel(
      {
        this.sId,
        this.azkarEnglish,
        this.azkarArabic,
        this.azkarTurkish,
        this.azkarUrdu,
        this.azkarBangla,
        this.azkarHindi,
        this.azkarFrench,
        this.categoryId,
        this.timestamp,
        this.categoryArabic,
        this.categoryEnglish,
        this.categoryTurkish,
        this.categoryUrdu});

  AzkarCategoryDataListModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    azkarEnglish = json['azkarEnglish'];
    azkarArabic = json['azkarArabic'];
    azkarTurkish = json['azkarTurkish'];
    azkarUrdu = json['azkarUrdu'];
    azkarBangla = json['azkarBangla'];
    azkarHindi = json['azkarHindi'];
    azkarFrench = json['azkarFrench'];
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
    data['azkarEnglish'] = azkarEnglish;
    data['azkarArabic'] = azkarArabic;
    data['azkarTurkish'] = azkarTurkish;
    data['azkarUrdu'] = azkarUrdu;
    data['azkarBangla'] = azkarBangla;
    data['azkarHindi'] = azkarHindi;
    data['azkarFrench'] = azkarFrench;
    data['category_id'] = categoryId;
    data['timestamp'] = timestamp;
    data['categoryArabic'] = categoryArabic;
    data['categoryEnglish'] = categoryEnglish;
    data['categoryTurkish'] = categoryTurkish;
    data['categoryUrdu'] = categoryUrdu;
    return data;
  }
}
