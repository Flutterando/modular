import 'package:flutter/material.dart';

class ForbiddenWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Acesso negado"),
      ),
    );
  }
}