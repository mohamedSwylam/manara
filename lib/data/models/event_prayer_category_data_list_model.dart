class EventPrayerCategoryDataListModel {
  String? sId;
  String? eventPrayerArabic;
  String? eventPrayerEnglish;
  String? categoryArabic;
  String? categoryEnglish;
  int? timestamp;

  EventPrayerCategoryDataListModel(
      {this.sId,
      this.eventPrayerArabic,
      this.eventPrayerEnglish,
      this.categoryArabic,
      this.categoryEnglish,
      this.timestamp});

  EventPrayerCategoryDataListModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    eventPrayerArabic = json['eventPrayerArabic'];
    eventPrayerEnglish = json['eventPrayerEnglish'];
    categoryArabic = json['categoryArabic'];
    categoryEnglish = json['categoryEnglish'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['eventPrayerArabic'] = eventPrayerArabic;
    data['eventPrayerEnglish'] = eventPrayerEnglish;
    data['categoryArabic'] = categoryArabic;
    data['categoryEnglish'] = categoryEnglish;
    data['timestamp'] = timestamp;
    return data;
  }
}
