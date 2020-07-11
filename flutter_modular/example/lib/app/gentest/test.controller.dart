import 'package:flutter_modular/flutter_modular.dart';
import '../app_bloc.dart';

part 'test.controller.g.dart';

@Injectable()
class HomeRealController {
  final AppBloc bloc;
  HomeRealController(this.bloc);
}
