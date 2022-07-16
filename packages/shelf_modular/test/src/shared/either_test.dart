import 'package:shelf_modular/src/shared/either.dart';
import 'package:test/test.dart';

void main() {
  test('left', () {
    final leftEither = left(0);
    expect(leftEither.isLeft, true);
    expect(leftEither.isRight, false);
    expect(leftEither.fold(id, id), 0);
    expect(leftEither.getOrElse((left) => left), 0);
  });

  test('right', () {
    final rightEither = right(1);
    expect(rightEither.isRight, true);
    expect(rightEither.isLeft, false);
    expect(rightEither.fold(id, id), 1);
    expect(rightEither.getOrElse((left) => 0), 1);
  });

  test('bind', () {
    final rightEither = right(0);
    final newEither = rightEither.bind((r) => right(1));
    expect(newEither.getOrElse((left) => 0), 1);
  });

  test('leftBind', () {
    final leftEither = left(0);
    final newEither = leftEither.leftBind((r) => right(1));
    expect(newEither.getOrElse((left) => 0), 1);
  });

  test('asyncBind', () async {
    final rightEither = right(0);
    final newEither = await rightEither.asyncBind((r) async => right(1));
    expect(newEither.getOrElse((left) => 0), 1);
  });

  test('map', () async {
    final rightEither = right(0);
    final newEither = rightEither.map((r) => 1);
    expect(newEither.getOrElse((left) => 0), 1);
  });
  test('leftMap', () async {
    final leftEither = left(0);
    final newEither = leftEither.leftMap((r) => 1);
    expect(newEither.getOrElse(id), 1);
  });
}
