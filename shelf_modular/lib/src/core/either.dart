import 'package:meta/meta.dart';

abstract class Either<TLeft, TRight> {
  bool get isLeft;
  bool get isRight;

  T fold<T>(T Function(TLeft left) leftFn, T Function(TRight right) rightFn);

  TRight getOrElse(TRight Function(TLeft left) orElse);

  Either<TLeft, T> bind<T>(Either<TLeft, T> Function(TRight right) fn) {
    return fold(left, fn);
  }

  Future<Either<TLeft, T>> asyncBind<T>(Future<Either<TLeft, T>> Function(TRight right) fn) {
    return fold((l) async => left(l), fn);
  }

  Either<T, TRight> leftBind<T>(Either<T, TRight> Function(TLeft left) fn) {
    return fold(fn, right);
  }
}

class _Left<TLeft, TRight> extends Either<TLeft, TRight> {
  final TLeft _value;

  @override
  final bool isLeft = true;

  @override
  final bool isRight = false;

  _Left(this._value);

  @override
  T fold<T>(T Function(TLeft left) leftFn, T Function(TRight right) rightFn) {
    return leftFn(_value);
  }

  @override
  TRight getOrElse(TRight Function(TLeft left) orElse) {
    return orElse(_value);
  }
}

class _Right<TLeft, TRight> extends Either<TLeft, TRight> {
  final TRight _value;

  @override
  final bool isLeft = false;

  @override
  final bool isRight = true;

  _Right(this._value);

  @override
  T fold<T>(T Function(TLeft left) leftFn, T Function(TRight right) rightFn) {
    return rightFn(_value);
  }

  @override
  TRight getOrElse(TRight Function(TLeft left) orElse) {
    return _value;
  }
}

Either<TLeft, TRight> right<TLeft, TRight>(TRight right) => _Right<TLeft, TRight>(right);
Either<TLeft, TRight> left<TLeft, TRight>(TLeft left) => _Left<TLeft, TRight>(left);

T id<T>(T value) => value;

@sealed
abstract class Unit {}

class _Unit implements Unit {
  const _Unit();
}

const unit = _Unit();
