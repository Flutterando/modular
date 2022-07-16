import 'dart:async';

import 'package:postgres/postgres.dart';
import 'package:shelf_modular/shelf_modular.dart';

abstract class IPostgresConnect implements Disposable {
  Future<PostgreSQLConnection> get connection;
}

class PostgresConnect implements IPostgresConnect {
  final _completer = Completer<PostgreSQLConnection>();

  PostgresConnect() {
    _completer.complete(_openConection());
  }

  Future<PostgreSQLConnection> _openConection() async {
    final connection = PostgreSQLConnection('localhost', 5432, 'postgres',
        username: 'postgres', password: 'postgres');
    await connection.open();
    return connection;
  }

  @override
  void dispose() async {
    final pg = await _completer.future;
    await pg.close();
    print('Postgres Closed!');
  }

  @override
  Future<PostgreSQLConnection> get connection => _completer.future;
}
