import 'user.dart';

class Tokenization {
  final String token;
  final int expires;
  final User user;

  const Tokenization({required this.token, required this.expires, required this.user});
}
