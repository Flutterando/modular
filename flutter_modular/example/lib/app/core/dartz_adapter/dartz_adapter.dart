import 'package:dartz/dartz.dart';
import 'package:flutter_triple/flutter_triple.dart';

class DartzEitherAdapter<L, R> extends EitherAdapter<L, R> {
  final Either<L, R> usecase;

  DartzEitherAdapter(this.usecase);

  @override
  fold(Function(L l) leftF, Function(R l) rightF) {
    return usecase.fold(leftF, rightF);
  }

  static Future<EitherAdapter<L, R>> adapter<L, R>(
      Future<Either<L, R>> usecase) {
    return usecase.then((value) => DartzEitherAdapter(value));
  }
}
