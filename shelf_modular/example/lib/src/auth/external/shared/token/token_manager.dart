import 'package:example/src/auth/external/errors/errors.dart';
import 'package:jose/jose.dart';

class TokenManager {
  final key = JsonWebKey.fromJson({
    'kty': 'oct',
    'k':
        'AyM1SysPpbyDfgZld3umj1qzKObwVMkoqQ-EstJQLr_T-1qS0gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr1Z9CAow',
  });

  int expireTime([Duration duration = const Duration(hours: 3)]) => Duration(
          milliseconds: DateTime.now().add(duration).millisecondsSinceEpoch)
      .inSeconds;

  String generateToken(Map<String, dynamic> claimsMap) {
    var claims = JsonWebTokenClaims.fromJson(claimsMap);

    // create a builder, decoding the JWT in a JWS, so using a
    // JsonWebSignatureBuilder
    var builder = JsonWebSignatureBuilder();

    // set the content
    builder.jsonContent = claims.toJson();

    // add a key to sign, can only add one for JWT
    builder.addRecipient(key, algorithm: 'HS256');

    // build the jws
    var jws = builder.build();

    return jws.toCompactSerialization();
  }

  Future<void> validateToken(String encoded) async {
    // create key store to verify the signature
    var keyStore = JsonWebKeyStore()..addKey(key);

    // applicable for JWT inside JWE
    var jwt = await JsonWebToken.decodeAndVerify(encoded, keyStore);

    var violations = jwt.claims.validate();

    if (violations.isNotEmpty) {
      final list = violations.map((e) => e.toString()).toList();
      throw JWTViolations(
          'One or more violations in current access token', list);
    }
  }
}
