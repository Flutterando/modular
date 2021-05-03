import 'package:flutter/material.dart';

import 'package:example/app/search/domain/entities/result.dart';
import 'package:flutter_modular/flutter_modular.dart';

class DetailsPage extends StatefulWidget {
  final Result result;
  const DetailsPage({
    Key? key,
    required this.result,
  }) : super(key: key);
  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    print(Modular.args?.queryParams['id']);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.result.nickname),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: widget.result.image,
              child: CircleAvatar(
                backgroundImage: NetworkImage(widget.result.image),
              ),
            ),
            Text(widget.result.nickname),
          ],
        ),
      ),
    );
  }
}
