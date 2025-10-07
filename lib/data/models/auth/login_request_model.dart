class LoginRequestModel {
  final String email;
  final String password;
  final String oneSignalId;

  LoginRequestModel({
    required this.email,
    required this.password,
    required this.oneSignalId,
  });

  Map<String, dynamic> toJson() {
    return {
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
    return 'LoginRequestModel(email: $email, password: $password, oneSignalId: $oneSignalId)';
  }
}
