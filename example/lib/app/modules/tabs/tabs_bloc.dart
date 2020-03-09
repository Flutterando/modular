import 'package:flutter_modular/flutter_modular.dart';
import 'package:rxdart/rxdart.dart';

class TabsBloc implements Disposable {
  final selectedPage = BehaviorSubject<int>.seeded(0);

  @override
  void dispose() {
    selectedPage.close();
  }
}
