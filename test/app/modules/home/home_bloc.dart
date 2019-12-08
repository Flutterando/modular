import 'package:modular/modular.dart';

class HomeBloc extends Disposable {

  String testingText = 'testing inject';

  @override
  void dispose() {
    print('call dispose');
  }

}