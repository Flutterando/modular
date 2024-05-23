// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'url_service.dart';

class WebUrlService extends UrlService {
  @override
  String? getPath() {
    final href = window.location.href;

    if (urlStrategy is HashUrlStrategy) {
      if (href.endsWith(Modular.initialRoute)) {
        return Modular.initialRoute;
      } else if (href.contains('#')) {
        return href.split('#').last;
      }
    }

    return resolvePath(href);
  }
}

UrlService create() {
  return WebUrlService();
}
