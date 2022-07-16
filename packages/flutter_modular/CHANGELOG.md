## [5.0.3] - 2022-06-03
- Fix [#713](https://github.com/Flutterando/modular/issues/713)
- Fix [#676](https://github.com/Flutterando/modular/issues/676)
- Fix [#632](https://github.com/Flutterando/modular/issues/632)

## [5.0.2] - 2022-04-22
- Fix: Parse params in RouteOutlet
## [5.0.1] - 2022-04-22
- Fix: Inject.get should return instance.

## [5.0.0] - 2022-04-21
- Support Flutter 3.0.0
- [BREAK CHANGE]: Removed `MaterialApp.modular()` and `Cupertino().modular()`.
  Use instead:
  ```dart
    return MaterialApp.router(
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
    );

  ```
This modification aims to keep Modular support independent of `WidgetApp` updates, and can be used in other bootstraps such as `FluentApp [fluent_ui]`.

- [BREAK CHANGE]: New auto-dispose configuration.
Previously Modular had automatic closing or destruction calls for objects of type `ChangeNotifier/ValueNotifier`, `Stream` and Triple\`s `Stores`.
Starting with version 5.0, Modular will provide the `Bind.onDispose` property for calls to destroy, close or dispose methods FOR EACH BIND. This will make the dispose settings more straightforward and less universal. Therefore, Modular will manage the destruction of Binds that implement `Disposable` only. This is the new configuration:
```dart
@override
final List<Bind> binds = [
  Bind.singleton((i) => MyBloc(), onDispose: (bloc) => bloc.close()),
];
```
The `Bind.onDispose` CANNOT be used in Bind type factory.
You can choose to use `Bind.onDispose` or implement the `Disposable` class.

- Added `Bind.selector`. Generates a reactivity (Listenable/Stream) to be listened to when `context.watch()` is called.
```dart
@override
final List<Bind> binds = [
  //notifier return stream or listenable to use context.watch()
  Bind.singleton((i) => MyBloc(), onDispose: (bloc) => bloc.close(), selector: (bloc) => bloc.stream),
];
```

- [BREAK CHANGE]: As already described above, the reactivities worked externally to Modular, providing a
longer life to the project. For this reason, BLoC or Triple users should use special `Bind's` in order to use the `context.watch()` and auto dispose functionality. They are: `BlocBind()` and `TripleBind()`, which are available through external packages.
[modular_bloc_bind](https://pub.dev/packages/modular_bloc_bind) -> BlocBind <br>
[modular_triple_bind](https://pub.dev/packages/modular_triple_bind) -> TripleBind

Example: 
```dart

@override
final List<Bind> binds = [
  BlocBind.singleton((i) => MyBloc()),
];
```

- [BREAK CHANGE] `Bind.export` works only after imported.
- @deprecated `ModularState`.
A few months of research showed us that ModularState caused unnecessary coupling with the view and made it difficult for those who used it to understand. For this reason, we decided to deprecate it to ensure code congruence for all professionals who use Modular.

- Removed `triple` dependency.
- Simplify docs.
- Added `Modular.setArguments`.
```dart
Modular.setArguments('cody1024d');

// get
Modular.args.data; // -> cody1024d
//or
Bind((i) => MyClass(i.args.data));

```

### Issues

- Fix [#615](https://github.com/Flutterando/modular/issues/615)
- Fix [#643](https://github.com/Flutterando/modular/issues/643)
- Fix [#644](https://github.com/Flutterando/modular/issues/644)
- Fix [#666](https://github.com/Flutterando/modular/issues/666)
- Fix [#668](https://github.com/Flutterando/modular/issues/668)
- Fix [#681](https://github.com/Flutterando/modular/issues/681)
- Fix [#694](https://github.com/Flutterando/modular/issues/694)

## [4.5.1+1] - 2022-04-05
- Fixed `modular_core` and resolve issues [#699] [#671] [#678].

## [4.5.0] - 2022-02-22

- @Deprecated: `.modular()` extension.
  Use instead:
  ```dart
    return MaterialApp.router(
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
    );

  ```
- Added `Modular.setInitialRoute`.
- Added `Modular.setObservers`.
- Added `Modular.setNavigatorKey`.

## [4.4.1] - 2022-02-18

- Fix bugs in lints.

## [4.4.0+1] - 2022-01-22

- Added `CustomTransition Expansion`.

## [4.4.0] - 2022-01-17

- Added `Modular.to.navigateHistory`.
- Added ChildRoute.maintainState property.
- Updated **Triple** version.

## [4.3.1] - 2021-12-10

- Fixed "bind replaced" bug

## [4.3.0] - 2021-12-10

- Added BuildContext extension [context.read()] and [context.watch()];
- The [context.watch()] listen changes of [Listanable], [Stream] and [Store] by Triple;

```dart
class Body extends StatelessWidget {
  Widget build(BuildContext context){
    final notifier = context.watch<ValueNotifier>();
    return Text('${notifier.value}')
  }
}
```

- Use `select` in `.watch()` to select the reactive property:

```dart
class Body extends StatelessWidget {
  Widget build(BuildContext context){
    final bloc = context.watch<CounterBloc>((bloc) => bloc.stream);
    return Text('${bloc.state}')
  }
}
```

Also, use `Store Selectors` in conjunction with `.watch`:

```dart
class OnlyErrorWidget extends StatelessWidget {
  Widget build(BuildContext context){
    // changes with store.setError();
    final store = context.watch<MyTripleStore>((store) => store.selectError);
    return Text('${store.error}')
  }
}
```

See more details [here](https://modular.flutterando.com.br/docs/flutter_modular/watch)

## [4.2.0] - 2021-10-28

- Added cleanInjector() and cleanModular() for restart Modular. [#601](https://github.com/Flutterando/modular/pull/601)
- Updated modular_core.

## [4.1.2] - 2021-10-08

- Added "maintainState" in routes. [#572](https://github.com/Flutterando/modular/issues/572)
- Fixed pushReplacementNamed

## [4.1.0+1] - 2021-10-01

- Modular is now HOT-RELOAD friendly!
- Added ReassembleMixin.

## [4.0.1+1] - 2021-09-22

- Fixed pushNamed.
- Fixed bug that allowed access to parameters and arguments in other modules.
- Fixed transitions bug.
- Fixed navigation blink.

## [4.0.0+12] - 2021-09-16

- New documentation is here! [https://modular.flutterando.com.br](https://modular.flutterando.com.br).
- Modular design now uses Layered Architecture (Clean Architecture) with 100% code coverage.
- Up to 30% improvement in obtaining routes.
- BREAK CHANGE: **RouteGuard([redirectTo])** -> **RouteGuard({String? redirectTo})**.
- BREAK CHANGE: **flutter_modular_test** will be discontinued. Use **modular_test** instead.
- FIX [#516](https://github.com/Flutterando/modular/issues/516)

## [3.4.1+1] - 2021-08-20

- Fix path(remove @)

## [3.4.0] - 2021-08-18

- Added **RedirectRoute**.
- Navigation Transition now is more responsive!
- Triple integration
- Fix Bind when you only have Imports.

## [3.3.1] - 2021-07-07

- Fix popUntil stack overflow
- Fix navigatorObservers

## [3.3.0] - 2021-06-25

- Fix popUntil.
- Fix pushNamedAndRemoveUntil.
- Fix premature instanciation of singleton when flag experimentalNotAllowedParentBinds is true.
- Fix back and forward browser buttons navigation
- Remove RxDart dependency.
- Export ModularError interface.
- Multiples RouterOutlets.

## [3.2.2+1] - 2021-05-19

- Fix popAndPushNamed

## [3.2.1] - 2021-05-11

- Fix AsyncBind (Thanks Ygor and Gil);

## [3.2.0] - 2021-05-03

- Added **AsyncBind** for Future injection binds.

```dart
final List<Bind> binds = [
  AsyncBind((i) => SharedPreferences.getInstance()),
];

...

//get async
final share = await Modular.getAsync<SharedPreferences>();
//or initalize the module first
await Modular.isModuleReady<MyModule>();
final share = Modular.get<SharedPreferences>();

```

- Fix break navigation on **RouteOutlet** when frenetics tab changes
- Bwolf`s commits
- More bugs fixeds (Thanks @Mex978)
- Fix Navigate Flutter Web error.

## [3.1.1] - 2021-04-25

- EXPERIMENTAL: ModularApp.notAllowedParentBinds. If true, all modules will only have access to their Binds, or Binds of imported modules (Module.imports);
- Page Transition use CupertinoPageRoute if application use CupertinoApp.
- A lot of bugs fixeds (Thanks @Mex978)

## [3.1.0] - 2021-04-11

- Added redirect route when RouteGuard fails [#351](https://github.com/Flutterando/modular/issues/3510):

```dart
@override
final List<ModularRoute> routes = [
    ChildRoute(
      '/home',
      child: (context, args) => HomePage(),
      guards: [AuthGuard()],
      guardedRoute: '/login',
    ),
    ChildRoute(
      '/login',
      child: (context, args) => LoginPage(),
    ),
];
```

- Fixed ChildRoute Generic type
- Dispose errors
- Fixed WidgetModule bugs

## [3.0.2] - 2021-03-22

- Support modular_codegen 3.0.0
- Added Support to CupertinoApp.modular()
- Fix bug: Get arguments in RouteGuard

## [3.0.0+1] - 2021-03-12

- Fix pushNamed bug
- Fix parameter bugs
- navigate replaceAll aways true (@deprecated)

## [3.0.0+1] - 2021-03-09

- BIG RELEASE!

## [2.5.0] -

- Navigator 2.0
- Fixed Modular.link
- Refactor RouteGuard
- Added Modular.to.navigate
- Added 3 new bind factories

1.  Bind.factory
2.  Bind.singleton
3.  Bind.lazySingleton

## [2.0.1] - 21 Sep 2020

- added onChangeRoute propety in RouterOutlet

## [2.0.0+1] - 21 Ago 2020

### Welcome to Flutter Modular 2.0!!!

## Break Changes

Router object Renamed to ModularRouter.

```dart
//before
  @override
  List<Router> get routers => [
        Router('/', (i, args) => LoginPage()),
        Router('/home', (i, args) => HomePage()),
      ];
//now 2.0
  @override
  List<ModularRouter> get routers => [
        ModularRouter('/', (i, args) => LoginPage()),
        ModularRouter('/home', (i, args) => HomePage()),
      ];
```

- New Widget `RouterOutletList` (Check doc);
- `Inject.params` is deprecated

## [1.3.2] - 30 Jul 2020

- Fix issue [#210](https://github.com/Flutterando/modular/issues/210)

## [1.3.1] - 19 Jul 2020

- Prevent StackOverflow in Injections

## [1.3.0] - 12 Jul 2020

- modular_codegen integration.
- Added defaul value in Modular.get

```dart
//return AppBlocMock if no injectable AppBloc in module.
var appBloc = Modular.get(defaultValue: AppBlocMock());
```

- Fix CI (Tests) and Lints
- Update docs

## [1.2.7+1] - 26 Jun 2020

- Fix route error issue [#118](https://github.com/Flutterando/modular/issues/118)
- Added WillPopScope in RouterOutlet

## [1.2.6+1] - 23 Jun 2020

- Direct call Inject

```dart
  @override
  List<Bind> get binds => [
        Bind((i) => HomeBloc(repository: i(), appBloc: i())),
        Bind((i) => HomeRepository(dio: i())),
        Bind((i) => Dio()),
      ];
```

Use **i()** instead **i.get()**

## [1.2.5+1] - 26 May 2020

- Fix Modular.link bug
- Smooth Animation Navigator: 56% faster navigation animations

## [1.2.4] - 23 May 2020

- Welcome Navigator API 2.0!!!
- Added push, pushReplacement in Modular.to and Modular.link;
- Added Modular.navigatorDelegate for tests mocks. Just implements IModularNavigator.

```dart
//Modular.to and Modular.link will be called MyNavigatorMock implements!
Modular.navigatorDelegate = MyNavigatorMock();
```

## [1.2.3] - 19 May 2020

- Health suggestions
- Added Contributors in README
- Fix RouterOutlet
- Fix Modular.link

## [1.2.1] - 15 May 2020

- Fix bugs
- new Modular.link for Navigation in Current Module;

```dart
//Modules home>product
Modular.to.pushNamed('/home/product/list');
Modular.to.pushNamed('/home/product/detail/:id');

//into product module, use Modular.link and navigate between routes of current Module (Product)

Modular.link.pushNamed('/list');
Modular.link.pushNamed('/detail/:id');

```

Use Modular.to for literal paths or Modular.link for routes in current module.

- Finally, use Modular.to.path (or Modular.link.path) if you want see the "Current Route Path".

## [1.1.2] - 13 Apr 2020

- Fix bugs

## [1.1.1] - 07 Apr 2020

- Added **showDialog**

```dart
Modular.to.showDialog(
  barrierDismissible: false,
  builder: (_) => AlertDialog(),
);
```

## [1.0.0] - 24 Mar 2020

- Release!!!

## [0.5.6] - 13 Mar 2020

- Added keepAlive flag in RouterOutlet.

## [0.5.5] - 08 Mar 2020

- Fix StackOverflow error
- Fix RouteGuard
- Fix Transitions Animation
- PREVIEW: RouterOutlet Widget
  Use Navigation in BottomBarTab or Drawer

```Dart
PageView(
  controller: controller
  children: [
    RouterOutlet(
      module: Tab1Module()
    ),
    RouterOutlet(
      module: Tab2Module()
    ),
    RouterOutlet(
      module: Tab3Module()
    ),
  ]
),
```

NOTE: Navigation is only Navigator.of (context) and only uses the module's literal route path.

## [0.5.3] - 05 Mar 2020

- Prevent StackOverflow

## [0.5.2] - 20 Feb 2020

- Prevent StackOverflow

## [0.5.1] - 15 Feb 2020

- fix #52

## [0.5.0] - 13 Feb 2020

- Added router generic type

```dart
 @override
  List<ModularRouter> get routers => [
    //type router with return type
    Router<String>('/event', child: (_, args) => EventPage()),
  ]
```

Now you can type your pushNamed and pop

```dart
 String value = await Modular.to.pushNamed<String>();
 //and
 Modular.to.pop('My String');
```

## [0.4.7] - 9 Feb 2020

- Added Custom Transition.
- Added **Modular.args** (get route params in Controller).
- (PREVIEW) RouterGuard in child routes.
- Fix error in WidgetTests
- Added Print routers in debugMode

## [0.4.5] - 7 Feb 2020

- Added not lazy Objects

```dart
@override
  List<Bind> get binds => [
        Bind((i) => OtherWidgetNotLazy(), lazy: false),
      ];
```

## [0.4.4] - 6 Feb 2020

- fix RouterGuards
- Added Modular.debugMode = false;
- Improve documentations
- Fix Error in initalRoute

## [0.4.3] - 1 Feb 2020

- fix RouterGuards
- Added Modular.debugMode = false;

## [0.4.2] - 1 Feb 2020

- fix routerGuards
- fix tests

## [0.4.1] - 30 Jan 2020

- Internal Inject Interface reference

## [0.4.0] - 28 Jan 2020

- added Modular.dispose();
- ModularState
- Removed InjectMixin

## [0.3.5+1] - 26 Jan 2020

- fix module widget
- fix inject error

## [0.3.3+1] - 18 Jan 2020

- Modular is BETA!!!
- You can now control navigation without the context!
- Added **Modular.to** and replace Navigator.of(context)
- Added **Modular.get** and replace AppModule.to.get
- Added flag "singleton" in Bind injection
- Fix Router Guard

## [0.1.8] - 08 Jan 2020

- fix test errors (initModule)
- Added modularException

## [0.1.4] - 24 Dec 2019

- fix #7 and more

## [0.1.3] - 17 Dec 2019

- Route Settings, RemoveUntil fix #11

## [0.1.1] - 17 Dec 2019

- Fix tests

## [0.1.0+1] - 16 Dec 2019

- Added Route Transitions.
- Change ModularWidget to ModularApp.

## [0.0.10] - 14 Dec 2019

- Added logo

## [0.0.8] - 13 Dec 2019

- Route Guard

## [0.0.7] - 10 Dec 2019

- Dynamic Router
- Added Doc Translation
- Change BrowserModule to MainModule
- Change CommonModule to Module
- Corrigido erro de blink na primeira rota
- fix routes param

## [0.0.1] - 8 Dec 2019

- First Release
