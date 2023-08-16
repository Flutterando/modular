import 'package:modular_core/modular_core.dart';
import 'package:test/test.dart';

void main() {
  test('Return trace errors', () {
    final error = TrackerNotInitiated('Test', StackTrace.current);
    expect(error.toString(), isA<String>());
  });
}
