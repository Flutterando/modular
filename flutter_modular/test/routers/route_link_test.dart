import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class NavigatorMock extends Mock implements RouteLink {}

void main() {
  RouteLink link;

  setUpAll(() {
    link = NavigatorMock();
  });

  group('Navigation', () {
    test('canPop', () {
      when(link.canPop()).thenReturn(true);
      expect(link.canPop(), true);
    });

    test('maybePop', () {
      when(link.maybePop()).thenAnswer((_) => Future.value(true));
      expect(link.maybePop(), completion(true));
    });
  });
}
