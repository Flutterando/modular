import 'package:dartz/dartz.dart';
import 'package:flutter_triple/flutter_triple.dart';

class DartzEitherAdapter<L, R> extends EitherAdapter<L, R> {
  final Either<L, R> usecase;

  DartzEitherAdapter(this.usecase);

  @override
  fold(Function(L l) leftF, Function(R l) rightF) {
    return usecase.fold(leftF, rightF);
  }
}
