import 'package:jose/jose.dart';

class TokenManager {
  final key = JsonWebKey.fromJson({
    'kty': 'oct',
    'k': 'AyM1SysPpbyDfgZld3umj1qzKObwVMkoqQ-EstJQLr_T-1qS0gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr1Z9CAow',
  });

  int expireTime([Duration duration = const Duration(hours: 3)]) => Duration(milliseconds: DateTime.now().add(duration).millisecondsSinceEpoch).inSeconds;

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

  Future<bool> validateToken(String encoded) async {
    // decode the jwt, note: this constructor can only be used for JWT inside JWS
    // structures
    var jwt = JsonWebToken.unverified(encoded);

    // create key store to verify the signature
    var keyStore = JsonWebKeyStore()..addKey(key);

    var verified = await jwt.verify(keyStore);

    // alternatively, create and verify the JsonWebToken together, this is also
    // applicable for JWT inside JWE
    jwt = await JsonWebToken.decodeAndVerify(encoded, keyStore);

    var violations = jwt.claims.validate();

    if (violations.isNotEmpty) {
      throw violations;
    }

    return verified;
  }
}
