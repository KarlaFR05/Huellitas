class Token {
  final String accessToken;
  final String tokenType;
  final dynamic user;

  Token({
    required this.accessToken,
    required this.tokenType,
    this.user,
  });
}