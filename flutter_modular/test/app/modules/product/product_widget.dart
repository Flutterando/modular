import 'package:flutter/widgets.dart';

import 'product_bloc.dart';
import 'product_module.dart';


class ProductWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {



    return Container(
      child: Text(ProductModule.to.get<ProductBloc>().testingText),
    );
  }
}