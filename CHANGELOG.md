## [0.5.1] - 15 Feb 2020
* fix #52

## [0.5.0] - 13 Feb 2020

* Added router generic type
```dart
 @override
  List<Router> get routers => [
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

* Added Custom Transition.
* Added **Modular.args** (get route params in Controller).
* (PREVIEW) RouterGuard in child routes.
* Fix error in WidgetTests
* Added Print routers in debugMode

## [0.4.5] - 7 Feb 2020

* Added not lazy Objects
```dart
@override
  List<Bind> get binds => [
        Bind((i) => OtherWidgetNotLazy(), lazy: false),
      ];
```

## [0.4.4] - 6 Feb 2020

* fix RouterGuards
* Added Modular.debugMode = false;
* Improve documentations
* Fix Error in initalRoute

## [0.4.3] - 1 Feb 2020

* fix RouterGuards
* Added Modular.debugMode = false;

## [0.4.2] - 1 Feb 2020

* fix routerGuards
* fix tests

## [0.4.1] - 30 Jan 2020

* Internal Inject Interface reference


## [0.4.0] - 28 Jan 2020
* added Modular.dispose();
* ModularState
* Removed InjectMixin


## [0.3.5+1] - 26 Jan 2020

* fix module widget
* fix inject error


## [0.3.3+1] - 18 Jan 2020

* Modular is BETA!!!
* You can now control navigation without the context!
* Added **Modular.to** and replace Navigator.of(context)
* Added **Modular.get** and replace AppModule.to.get
* Added flag "singleton" in Bind injection
* Fix Router Guard

## [0.1.8] - 08 Jan 2020

* fix test errors (initModule)
* Added modularException

## [0.1.4] - 24 Dec 2019

* fix #7 and more

## [0.1.3] - 17 Dec 2019

* Route Settings, RemoveUntil fix #11

## [0.1.1] - 17 Dec 2019

* Fix tests

## [0.1.0+1] - 16 Dec 2019

* Added Route Transitions.
* Change ModularWidget to ModularApp.

## [0.0.10] - 14 Dec 2019

* Added logo

## [0.0.8] - 13 Dec 2019

* Route Guard

## [0.0.7] - 10 Dec 2019

* Dynamic Router
* Added Doc Translation
* Change BrowserModule to MainModule
* Change CommonModule to ChildModule
* Corrigido erro de blink na primeira rota
* fix routes param

## [0.0.1] - 8 Dec 2019

* First Release
