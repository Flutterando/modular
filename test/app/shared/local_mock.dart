import 'ILocalRepository.dart';

class LocalMock implements ILocalStorage {
  @override
  Future delete(String key) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future get(String key) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future put(String key, String value) {
    // TODO: implement put
    throw UnimplementedError();
  }
}
