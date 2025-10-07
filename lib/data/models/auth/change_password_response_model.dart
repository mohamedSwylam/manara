class ChangePasswordResponseModel {
  final String message;
  final int statusCode;

  ChangePasswordResponseModel({
    required this.message,
    required this.statusCode,
  });

  factory ChangePasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponseModel(
      message: json['message'] ?? 'Password changed successfully',
      statusCode: json['status_code'] ?? 200,
    );
  }
}
