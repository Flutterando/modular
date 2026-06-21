import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:web/web.dart' as web;

import 'url_service.dart';

class WebUrlService extends UrlService {
  @override
  String? getPath() {
    final href = web.window.location.href;

    if (urlStrategy is HashUrlStrategy) {
      if (href.contains('#')) {
        return href.split('#').last;
      } else if (href.endsWith(Modular.initialRoute)) {
        return Modular.initialRoute;
      }
    }

    return resolvePath(href);
  }
}

UrlService create() {
  return WebUrlService();
}
