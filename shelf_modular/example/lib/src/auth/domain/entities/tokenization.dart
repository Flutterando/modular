class Tokenization {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  const Tokenization(
      {required this.accessToken,
      required this.refreshToken,
      required this.expiresIn});
}
