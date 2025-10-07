class RegisterRequestModel {
  final String fullName;
  final String email;
  final String password;
  final String oneSignalId;

  RegisterRequestModel({
    required this.fullName,
    required this.email,
    required this.password,
    required this.oneSignalId,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'oneSignalId': oneSignalId,
    };
  }

  Map<String, dynamic> toApiFormat() {
    return {
      'data': toJson(),
    };
  }

  @override
  String toString() {
    return 'RegisterRequestModel(fullName: $fullName, email: $email, password: $password, oneSignalId: $oneSignalId)';
  }
}
