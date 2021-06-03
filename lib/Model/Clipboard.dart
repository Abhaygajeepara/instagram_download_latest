import 'package:flutter/cupertino.dart';

class ClipBoardModel{
  String url;
  ClipBoardModel({@required this.url});

  factory ClipBoardModel.of(String text){
    return ClipBoardModel(url: text);
  }
}