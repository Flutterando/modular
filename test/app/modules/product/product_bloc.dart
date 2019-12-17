import 'package:flutter_modular/flutter_modular.dart';

class ProductBloc extends Disposable {

  String testingText = 'testing inject';

  @override
  void dispose() {
    print('call dispose');
  }

}