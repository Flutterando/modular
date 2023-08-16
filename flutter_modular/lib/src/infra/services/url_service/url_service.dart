import 'io_url_service.dart'
// for web
    if (dart.library.html) 'html_url_service.dart' as impl;

abstract class UrlService {
  String? getPath();

  static UrlService create() {
    return impl.create();
  }

  String resolvePath(String path) {
    final uri = Uri.parse(path);
    if (uri.hasFragment) {
      return uri.fragment;
    }
    return uri.path;
  }
}
