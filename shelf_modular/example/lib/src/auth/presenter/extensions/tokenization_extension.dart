import 'dart:convert';

import 'package:example/src/auth/domain/entities/tokenization.dart';
import 'user_extension.dart';

extension UserExtension on Tokenization {
  Map<String, dynamic> toMap() {
    return {
      'expires': expires,
      'token': token,
      'user': user.toMap(),
    };
  }

  String toJson() => jsonEncode(toMap());
}
