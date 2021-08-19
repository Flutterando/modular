import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/src/domain/errors/errors.dart';
import 'package:shelf_modular/src/domain/usecases/dispose_bind.dart';
import 'package:shelf_modular/src/domain/usecases/finish_module.dart';
import 'package:shelf_modular/src/domain/usecases/get_bind.dart';
import 'package:shelf_modular/src/domain/usecases/module_ready.dart';
import 'package:shelf_modular/src/domain/usecases/start_module.dart';

abstract class IModularBase {
  void init(Module module);
  void destroy();
  Future<void> isModuleReady<M extends Module>();
  Future<B> getAsync<B extends Object>({B? defaultValue});

  B get<B extends Object>({
    B? defaultValue,
  });

  bool dispose<B extends Object>();
}

class ModularBase implements IModularBase {
  final DisposeBind disposeBind;
  final FinishModule finishModule;
  final GetBind getBind;
  final StartModule startModule;
  final IsModuleReadyImpl isModuleReadyImpl;

  bool _moduleHasBeenStarted = false;

  ModularBase(this.disposeBind, this.finishModule, this.getBind, this.startModule, this.isModuleReadyImpl);

  @override
  bool dispose<B extends Object>() => disposeBind<B>().getOrElse((left) => false);

  @override
  B get<B extends Object>({B? defaultValue}) {
    return getBind<B>().getOrElse((left) {
      if (defaultValue != null) {
        return defaultValue;
      }
      throw left;
    });
  }

  @override
  Future<B> getAsync<B extends Object>({B? defaultValue}) {
    return getBind<Future<B>>().getOrElse((left) {
      if (defaultValue != null) {
        return Future.value(defaultValue);
      }
      throw left;
    });
  }

  @override
  void init(Module module) {
    if (!_moduleHasBeenStarted) {
      startModule(module);
      _moduleHasBeenStarted = true;
    } else {
      throw ModuleStartedException('Module ${module.runtimeType} is already started');
    }
  }

  @override
  Future<void> isModuleReady<M extends Module>() => isModuleReadyImpl<M>();

  @override
  void destroy() => finishModule();
}
