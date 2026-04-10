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
      final fragmentUri = Uri.parse(uri.fragment);
      if (fragmentUri.query.isNotEmpty) {
        return '${fragmentUri.path}?${fragmentUri.query}';
      }
      return uri.fragment;
    }
    if (uri.query.isNotEmpty) {
      return '${uri.path}?${uri.query}';
    }
    return uri.path;
  }
}
