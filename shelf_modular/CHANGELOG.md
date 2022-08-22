## 2.0.1 - 2022/07/22
- fix: Bind aways Scoped.

## 2.0.0 - 2022/07/21

- [BREAK CHANGE]: Update to new Dart 2.17.
Preview version will no longer be supported.

- [BREAK CHANGE]: New auto-dispose configuration.
Starting with version 2.0, Modular will provide the `Bind.onDispose` property for calls to destroy, close or dispose methods FOR EACH BIND. This will make the dispose settings more straightforward and less universal. Therefore, Modular will manage the destruction of Binds that implement `Disposable` only. This is the new configuration:
```dart
@override
final List<Bind> binds = [
  Bind.singleton((i) => MyBloc(), onDispose: (bloc) => bloc.close()),
];
```
The `Bind.onDispose` CANNOT be used in Bind type factory.
You can choose to use `Bind.onDispose` or implement the `Disposable` class.

- [BREAK CHANGE] `Bind.export` works only after imported.

- feat: Added `middlewares` propertie in Modular() handler;

```dart
final handler = Modular(
    module: AppModule(),
    middlewares: [
      logRequests(), //add any shelf middleware
      CustomModularMiddleware(), // implementations of ModularMiddleware
    ],
  );

  var server = await io.serve(handler, '0.0.0.0', 4000);
  print('Serving at http://${server.address.host}:${server.port}');
```

- feat: Added new Middleware system:
```dart
class AuthGuard extends ModularMiddleware {
  @override
  Handler execute(Handler handler, [ModularRoute? route]) {
    return (request) {
      final accessToken = request.headers['Authorization']?.split(' ').last;
      if (accessToken == null || accessToken.isEmpty || accessToken != '1234') {
        return Response.forbidden(jsonEncode({'error': 'Not authorized'}));
      }
      return handler(request);
    };
  }
}
```


## 1.0.2 - 2022/04/05

* Update modular_core

## 1.0.1 - 2021/12/31

* Fixed "bind replaced" bug

## 1.0.0 - 2021/10/20

* initial release.
* New doc!
