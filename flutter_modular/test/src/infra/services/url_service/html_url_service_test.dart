import 'package:flutter_modular/src/infra/services/url_service/url_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('html url service ...', () {
    final service = _TestUrlService();

    expect(service.resolvePath('http://flutterexample.dev/#/path/to/screen'), '/path/to/screen');
    expect(service.resolvePath('http://flutterexample.dev/path/to/screen'), '/path/to/screen');
  });
}

class _TestUrlService extends UrlService {
  @override
  String? getPath() {
    return null;
  }
}
