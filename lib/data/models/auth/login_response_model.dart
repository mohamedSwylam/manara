class LoginResponseModel {
  final UserData userData;
  final int statusCode;
  final String token;

  LoginResponseModel({
    required this.userData,
    required this.statusCode,
    required this.token,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      userData: UserData.fromJson(json['0']),
      statusCode: json['1'],
      token: json['token'],
    );
  }

  @override
  String toString() {
    return 'LoginResponseModel(userData: $userData, statusCode: $statusCode, token: $token)';
  }
}

class UserData {
  final String id;
  final String fullName;
  final String email;
  final String timestamp;
  final String totalDonation;
  final FileUrl fileUrl;
  final String oneSignalId;

  UserData({
    required this.id,
    required this.fullName,
    required this.email,
    required this.timestamp,
    required this.totalDonation,
    required this.fileUrl,
    required this.oneSignalId,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      timestamp: json['timestamp'] ?? '',
      totalDonation: json['totalDonation'] ?? '0',
      fileUrl: FileUrl.fromJson(json['fileUrl'] ?? {}),
      oneSignalId: json['oneSignalId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'timestamp': timestamp,
      'totalDonation': totalDonation,
      'fileUrl': fileUrl.toJson(),
      'oneSignalId': oneSignalId,
    };
  }

  @override
  String toString() {
    return 'UserData(id: $id, fullName: $fullName, email: $email, timestamp: $timestamp, totalDonation: $totalDonation, fileUrl: $fileUrl, oneSignalId: $oneSignalId)';
  }
}

class FileUrl {
  final String originalUrl;
  final String thumbnailUrl;

  FileUrl({
    required this.originalUrl,
    required this.thumbnailUrl,
  });

  factory FileUrl.fromJson(Map<String, dynamic> json) {
    return FileUrl(
      originalUrl: json['originalUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originalUrl': originalUrl,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  @override
  String toString() {
    return 'FileUrl(originalUrl: $originalUrl, thumbnailUrl: $thumbnailUrl)';
  }
}
