import 'dart:convert';

import 'package:search/app/search/domain/entities/result.dart';

class ResultModel extends Result {
  final String image;
  final String name;
  final String nickname;
  final String url;

  const ResultModel(
      {required this.image,
      required this.name,
      required this.nickname,
      required this.url})
      : super(image: image, name: name, nickname: nickname, url: url);

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'name': name,
      'nickname': nickname,
      'url': url,
    };
  }

  static ResultModel fromMap(Map<String, dynamic> map) {
    return ResultModel(
      image: map['image'],
      name: map['name'],
      nickname: map['nickname'],
      url: map['url'],
    );
  }

  String toJson() => json.encode(toMap());

  static ResultModel fromJson(String source) => fromMap(json.decode(source));
}
