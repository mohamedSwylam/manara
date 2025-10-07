class CategoryListModel {
  String? sId;
  String? categoryArabic;
  String? categoryEnglish;
  String? categoryTurkish;
  String? categoryUrdu;
  String? categoryBangla;
  String? categoryHindi;
  String? categoryFrench;
  String? timestamp;

  CategoryListModel(
      {
        this.sId,
        this.categoryArabic,
        this.categoryEnglish,
        this.categoryTurkish,
        this.categoryUrdu,
        this.categoryBangla,
        this.categoryHindi,
        this.categoryFrench,
        this.timestamp,
        });

  CategoryListModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    categoryArabic = json['categoryArabic'];
    categoryEnglish = json['categoryEnglish'];
    categoryTurkish = json['categoryTurkish'];
    categoryUrdu = json['categoryUrdu'];
    categoryBangla = json['categoryBangla'];
    categoryHindi = json['categoryHindi'];
    categoryFrench = json['categoryFrench'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['categoryArabic'] = categoryArabic;
    data['categoryEnglish'] = categoryEnglish;
    data['categoryTurkish'] = categoryTurkish;
    data['categoryUrdu'] = categoryUrdu;
    data['categoryBangla'] = categoryBangla;
    data['categoryHindi'] = categoryHindi;
    data['categoryFrench'] = categoryFrench;
    data['timestamp'] = timestamp;
    return data;
  }
}
