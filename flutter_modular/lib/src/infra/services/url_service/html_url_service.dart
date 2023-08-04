// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';

import 'url_service.dart';

class WebUrlService extends UrlService {
  @override
  String? getPath() => resolvePath(window.location.href);
}

UrlService create() {
  return WebUrlService();
}
