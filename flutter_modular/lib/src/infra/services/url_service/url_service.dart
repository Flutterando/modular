abstract class UrlService {
  String? getPath();

  String resolvePath(String path) {
    final uri = Uri.parse(path);
    if (uri.hasFragment) {
      return uri.fragment;
    }
    return uri.path;
  }
}
