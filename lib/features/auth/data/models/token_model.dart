import '../../domain/entities/token.dart';
import 'usuario_model.dart';

class TokenModel extends Token {
  @override
  final UsuarioModel? user; 

  TokenModel({
    required super.accessToken,
    required super.tokenType,
    this.user, 
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      user: json['user'] != null ? UsuarioModel.fromJson(json['user']) : null, 
    );
  }
}