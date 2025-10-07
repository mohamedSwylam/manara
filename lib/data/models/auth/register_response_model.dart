class RegisterResponseModel {
  final UserData userData;
  final int statusCode;
  final String token;

  RegisterResponseModel({
    required this.userData,
    required this.statusCode,
    required this.token,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      userData: UserData.fromJson(json['0']),
      statusCode: json['1'],
      token: json['token'],
    );
  }

  @override
  String toString() {
    return 'RegisterResponseModel(userData: $userData, statusCode: $statusCode, token: $token)';
  }
}

class UserData {
  final String fullName;
  final String email;
  final String id;
  final String timestamp;
  final FileUrl fileUrl;
  final String oneSignalId;

  UserData({
    required this.fullName,
    required this.email,
    required this.id,
    required this.timestamp,
    required this.fileUrl,
    required this.oneSignalId,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      id: json['_id'] ?? '',
      timestamp: json['timestamp'] ?? '',
      fileUrl: FileUrl.fromJson(json['fileUrl'] ?? {}),
      oneSignalId: json['oneSignalId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      '_id': id,
      'timestamp': timestamp,
      'fileUrl': fileUrl.toJson(),
      'oneSignalId': oneSignalId,
    };
  }

  @override
  String toString() {
    return 'UserData(fullName: $fullName, email: $email, id: $id, timestamp: $timestamp, fileUrl: $fileUrl, oneSignalId: $oneSignalId)';
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
