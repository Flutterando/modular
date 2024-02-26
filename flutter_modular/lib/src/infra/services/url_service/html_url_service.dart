// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';

import 'package:flutter_web_plugins/url_strategy.dart';

import 'url_service.dart';

class WebUrlService extends UrlService {
  @override
  String? getPath() {
    final href = window.location.href;

    if (urlStrategy is PathUrlStrategy) {
      return resolvePath(href);
    } else if (href.contains('#')) {
      return href.split('#').last;
    }

    return null;
  }
}

UrlService create() {
  return WebUrlService();
}
