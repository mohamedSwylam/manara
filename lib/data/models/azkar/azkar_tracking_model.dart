class AzkarTrackingModel {
  final String category;
  final int done;
  final int total;

  AzkarTrackingModel({
    required this.category,
    required this.done,
    required this.total,
  });

  factory AzkarTrackingModel.fromJson(Map<String, dynamic> json) {
    return AzkarTrackingModel(
      category: json['category'] ?? '',
      done: json['done'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'done': done,
      'total': total,
    };
  }

  double get progressPercentage {
    if (total == 0) return 0.0;
    return done / total;
  }

  bool get isCompleted {
    return done >= total && total > 0;
  }
}
