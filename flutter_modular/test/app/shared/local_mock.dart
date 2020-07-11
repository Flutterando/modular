import 'ilocal_repository.dart';

class LocalMock implements ILocalStorage {
  @override
  Future delete(String key) {
    throw UnimplementedError();
  }

  @override
  Future get(String key) {
    throw UnimplementedError();
  }

  @override
  Future put(String key, String value) {
    throw UnimplementedError();
  }
}
