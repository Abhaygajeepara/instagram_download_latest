import 'dart:io';

import 'package:flutter/cupertino.dart';
class LocalFileInfo{
  String fileName;
  File path;
  String pathString;
  double size;
  String sizeType;

  LocalFileInfo({
    @required this.fileName,
    @required this.path,
    @required this.pathString,
    @required this.size,
    @required this.sizeType
});
  factory LocalFileInfo.of(  String fileName,File path,String pathString,int size){
    String sizeType ;
    double fileSize ;
    if(size >1024*1024){
      sizeType ='mb';
      fileSize = (size/(1024*1024));
    }else if(size >1024*1024*1024){
      sizeType ='gb';
      fileSize = (size/(1024*1024*1024));
    }
    else{
      sizeType ='kb';
      fileSize = (size/(1024));
    }
    return LocalFileInfo(fileName: fileName, path: path,pathString: pathString, size: fileSize,sizeType: sizeType);
  }
}