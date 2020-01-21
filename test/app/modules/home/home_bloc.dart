import 'package:flutter_modular/flutter_modular.dart';

import '../../app_bloc.dart';

class HomeBloc extends Disposable {
  String testingText = 'testing inject';
  final AppBloc app;

  HomeBloc(this.app);

  @override
  void dispose() {
    print('call dispose');
  }
}
