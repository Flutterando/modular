
import '../../flutter_modular.dart';
import 'utils_test.dart';

enum ModularTestType { resetModule, keepModulesOnMemory }

abstract class IModularTest {
  final ModularTestType modularTestType;
  IModularTest({this.modularTestType: ModularTestType.resetModule});

  ChildModule module();
  List<Bind> binds();
  List<IModularTest> modularDependencies();

  void load({
    List<IModularTest> dependencies,
    List<Bind> changeBinds,
    bool isLoadDependencies = true,
  }) {
    dependencies ??= this.modularDependencies();
    changeBinds ??= this.binds();
    
    assert(
      !_isDependenciesRequired(dependencies, isLoadDependencies),
      "Dependencies must not be null when isLoadDependencies is true",
    );
    assert(
      changeBinds != null,
      "changeBinds must not be null",
    );

    _memoryManage();
    this._loadModularDependencies(isLoadDependencies, dependencies);
    initModule(
      this.module(),
      changeBinds: changeBinds,
    );
  }

  bool _isDependenciesRequired(List<IModularTest> dependencies, bool isLoadDependencies) => dependencies == null && isLoadDependencies;

  void _memoryManage() {
    if (this.modularTestType == ModularTestType.resetModule)
      Modular.removeModule(this.module());
  }

  void _loadModularDependencies(
    bool isLoadDependencies,
    List<IModularTest> dependencies,
  ) {
    if (isLoadDependencies) {
      dependencies.forEach((element) {
        element.load();
      });
    }
  }
}
