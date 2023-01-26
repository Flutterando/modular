import 'package:modular_core/modular_core.dart';
import 'package:test/test.dart';

void main() {
  test('Bind factories', () {
    final injector = AutoInjector();
    expect((Bind.instance('instance') as InstanceBind).instance, 'instance');
    injector.removeAll();
    expect(Bind.factory((i) => 'instance')..includeInjector(injector), isA<FactoryBind>());
    injector.removeAll();
    expect(Bind.singleton((i) => 'instance'), isA<SingletonBind>());
    injector.removeAll();
    expect(Bind.lazySingleton((i) => 'instance')..includeInjector(injector), isA<LazySingletonBind>());
    injector.removeAll();
  });
  test('AutoBind factories', () {
    final injector = AutoInjector();

    final empty = AutoBind.emptyInstance();
    expect(empty..includeInjector(injector), isA<AutoBind<String>>());

    expect((AutoBind.instance('instance') as InstanceBind).instance, 'instance');
    injector.removeAll();
    expect(AutoBind.factory(() => 'instance')..includeInjector(injector), isA<FactoryBind>());
    injector.removeAll();
    expect(AutoBind.singleton(() => 'instance'), isA<SingletonBind>());
    injector.removeAll();
    expect(AutoBind.lazySingleton(() => 'instance')..includeInjector(injector), isA<LazySingletonBind>());
    injector.removeAll();
  });
}
