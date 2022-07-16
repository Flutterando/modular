import 'dart:async';

import 'package:redis_dart/redis_dart.dart';
import 'package:shelf_modular/shelf_modular.dart';

abstract class IRedisService implements Disposable {
  Future<RedisReply> setMap(
      String key, Map<String, dynamic> map, Duration expiresIn);

  Future<Map<String, dynamic>> getMap(String key);
  Future<void> delete(String key);
}

class RedisService implements IRedisService {
  final _completer = Completer<RedisClient>();

  RedisService() {
    _completer.complete(RedisClient.connect('localhost'));
  }

  @override
  Future<RedisReply> setMap(
      String key, Map<String, dynamic> map, Duration expiresIn) async {
    final redis = await _completer.future;
    final result = await redis.setMap(key, map);
    await redis.expireAt(key, DateTime.now().add(expiresIn));
    return result;
  }

  @override
  Future<Map<String, dynamic>> getMap(String key) async {
    final redis = await _completer.future;
    final reply = await redis.getMap(key);
    return (reply.value as Map).cast<String, dynamic>();
  }

  @override
  Future<void> delete(String key) async {
    final redis = await _completer.future;
    await redis.delete(key);
  }

  @override
  void dispose() async {
    final redis = await _completer.future;
    await redis.close();
    print('Redis Closed!');
  }
}
