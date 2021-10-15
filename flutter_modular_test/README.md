# flutter_modular_test

@DEPRECATED: This package will be discontinued. Use [modular_test](https://pub.dev/packages/modular_test) instead


Init Modules and test the integration

## Getting Started

Add in your pubspec.yaml

```yaml

dev_dependencies:
  flutter_modular_test:

```

## Using

### Start a Module

```dart

main(){
    setUp(){
        initModule(AppModule());
    }
}

```

### Start more then one Module

```dart

main(){
    setUp(){
        initModules([AppModule(), HomeModule(), PerfilModule()]);
    }
}

```

### Replace binds of Module

```dart

main(){

    final dioMock = DioMock();

    setUp(){
        initModule(AppModule(), replaceBinds: [
            Bind.instance<Dio>(dioMock),
        ]);
    }
}

```


