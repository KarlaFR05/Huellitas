import '../../domain/entities/token.dart';

class TokenModel extends Token {
  TokenModel({
    required super.accessToken,
    required super.tokenType,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
    );
  }
}