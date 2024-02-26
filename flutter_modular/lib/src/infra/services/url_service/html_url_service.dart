// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';

import 'url_service.dart';

class WebUrlService extends UrlService {
  @override
  String? getPath() {
    final href = window.location.href;

    if (href.contains('#')) {
      return href.split('#').last;
    }

    return '/';
  }
}

UrlService create() {
  return WebUrlService();
}
