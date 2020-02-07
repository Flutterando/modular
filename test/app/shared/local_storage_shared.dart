import 'ILocalRepository.dart';

class LocalStorageSharePreference implements ILocalStorage {
  @override
  Future delete(String key) {}

  @override
  Future get(String key) {}

  @override
  Future put(String key, String value) {}
}
