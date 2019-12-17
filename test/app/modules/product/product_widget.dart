import 'package:flutter/material.dart';

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