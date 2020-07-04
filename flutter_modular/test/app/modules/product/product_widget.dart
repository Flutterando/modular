import 'package:flutter/widgets.dart';

import '../../../../lib/flutter_modular.dart';
import 'product_bloc.dart';

class ProductWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(Modular.get<ProductBloc>().testingText),
    );
  }
}
