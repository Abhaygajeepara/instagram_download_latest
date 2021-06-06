import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:instagram_download/Common/CommonAssest.dart';
import 'package:instagram_download/Model/FileInfo.dart';
import 'package:instagram_download/Pages/Preview/VideoPreview.dart';
import 'package:instagram_download/Pages/Preview/mediaPreview.dart';

import 'package:instagram_download/Service/adService.dart';

import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
class DownloadPage extends StatefulWidget {
  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {

@override
  void dispose() {
    // TODO: implement dispose
  for(int i =0;i<controllerList.length;i++){
    controllerList[i].dispose();
  }
  adsService.createbannerAd().dispose();
    super.dispose();


  }

  void initState() {
    // TODO: implement initState
    super.initState();

    getFile();
    _imageScrollController.addListener(() {
      if(_imageScrollController.position.pixels == _imageScrollController.position.maxScrollExtent){
          moreImage();
      }
    });
    _videoScrollController.addListener(() {
      if(_videoScrollController.position.pixels == _videoScrollController.position.maxScrollExtent){
      moreVideo();
      }
    });

  }
  moreImage(){
if(currentImage<listOfImage.length-1){
  print('currentImage${currentImage}');

  for(int i = currentImage;i<maxImage;i++){
    displayOfImage.add(listOfImage[i]);
    currentImage   =i+1;
  }
  print(maxImage);
  maxImage = maxImage+10 <listOfImage.length?maxImage+10:maxImage+(listOfImage.length-maxImage);

  setState(() {

  });
}

  }
  moreVideo()async{
    for(int i = currentVideo;i<maxVideo;i++){
      displayOffVideo.add(listOfVideo[i]);
      currentVideo   =i+1;
      VideoPlayerController _controller =   VideoPlayerController.file(listOfVideo[i].path);
      _initializeVideoPlayerFuture =
          _controller.initialize();
      _controller.setLooping(true);
      controllerList.add(_controller);
    }

    maxVideo = maxVideo+10 <listOfVideo.length?maxVideo+10:maxVideo+ (listOfVideo.length-maxVideo);

    setState(() {

    });


  }
  int pageIndex =0;
  String _permanentPath;
  List listOfFile = List();
  List<LocalFileInfo> listOfImage = List();
  List<LocalFileInfo> listOfVideo = List();
  List<LocalFileInfo> displayOfImage = List();
  List<LocalFileInfo> displayOffVideo = List();
  List<VideoPlayerController> controllerList;
  Future<void> _initializeVideoPlayerFuture;
  AdsService adsService = AdsService();
  int  currentImage =0;
  int  currentVideo = 0;
  int maxImage =0;
  int maxVideo = 0;
List fileTypeList =['Image','video'];
  ScrollController _imageScrollController = ScrollController();
  ScrollController _videoScrollController = ScrollController();
  getFile()async{
    listOfVideo.clear();
    listOfImage.clear();
    listOfFile.clear();
    controllerList = List();

    // List videoExtensionList =  ['mp4','mov','wmv','flv','avi','avchd','webm','mkv'];
    // //List videoExtensionList =  ['mp4','mov','WMV','FLV','AVI','AVCHD','WebM','MKV'];
    // List imageExtensionList =  ['jpg','png'];

    var permission=  Permission.storage;
    if(await permission.isGranted){
      String filepath = (await getExternalStorageDirectory()).path;
      permission.request();
      String newpath = "";
      List<String> listFolders = filepath.split("/");
      for (int i = 1; i < listFolders.length; i++) {
        String s = listFolders[i];
        if (s != "Android") {
          newpath = newpath + "/" + s;
        }
        else {
          break;
        }
      }
      newpath = newpath + "/" + "insta";
      _permanentPath = newpath;
      Directory d = Directory(newpath);

      if(!await d.exists()){
        d.create(recursive: true);
      }

    List  listOf = Directory("$_permanentPath/").listSync();
      listOfFile= listOf.reversed.toList();
for(int i =0;i<listOfFile.length;i++){
  print(listOfFile[i].toString());
}
      for(int i=0;i<listOfFile.reversed.length;i++){
   if(listOfFile[i].toString().substring(0,4)=='File'){
     String filepathString = listOfFile[i].toString();
     var firstIndexOfComa=  filepathString.indexOf("'");
     var lastIndexOfComa=  filepathString.lastIndexOf("'");
     String actualFilePathString = filepathString.substring(firstIndexOfComa+1,lastIndexOfComa);

//print(mimeType);

       File filepath = listOfFile[i];



       var indexOfDots=  actualFilePathString.lastIndexOf('.');

       var lashIndex = actualFilePathString.lastIndexOf('/');
     //  String fileExtension= filepathString.substring(indexOfDots+1,indexOfComa);
       final mimeType = lookupMimeType(actualFilePathString);
       var filename  =  actualFilePathString.substring(lashIndex+1);
       int fileSize =filepath.lengthSync();
       // print(mimeType);
       //video/
       if(mimeType.startsWith('video/')){



         LocalFileInfo localFileInfo = LocalFileInfo.of(filename, filepath,actualFilePathString, fileSize);
         listOfVideo.add(localFileInfo);
       }
       else if(mimeType.startsWith('image/')){
         LocalFileInfo localFileInfo = LocalFileInfo.of(filename, filepath,actualFilePathString, fileSize);
         listOfImage.add(localFileInfo);

       }
   }




      }


maxImage  = listOfImage.length<11?listOfImage.length:10;
      maxVideo =listOfVideo.length<11?listOfVideo.length:10;
      moreImage();
      moreVideo();
    }
    else if(await permission.isPermanentlyDenied){
      openAppSettings();
    }
    else{
      permission.request();
      setState(() {

      });
    }
setState(() {

});
   // listOfImage.reversed;
    //listOfVideo.reversed;
  }
  @override
  Widget build(BuildContext context) {
final size = MediaQuery.of(context).size;


    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width*0.01, vertical: size.height*0.02),
      child: Column(
        children: [
          // Container(
          //   height: 50,
          //   child: AdWidget(
          //     ad:adsService.createbannerAd()..load(),
          //     key: UniqueKey(),
          //   ),
          //
          // ),
          Container(
            height: size.height*0.05,
            child: ListView.builder(

              itemExtent: size.width/2,
              scrollDirection: Axis.horizontal,
                itemCount: fileTypeList.length,
                itemBuilder:(context,index){
                  return GestureDetector(
                    onTap: (){
                      setState(() {
                        pageIndex=index;
                      });

                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color:pageIndex == index?  selectFileTypeBorder:Colors.transparent,
                          )
                        )
                      ),
                      child: Center(child: Text(fileTypeList[index],style: TextStyle(
                          fontSize: size.height*0.025,
                          fontWeight: FontWeight.bold,
                          color:pageIndex == index? selectFileType:defaultTextColor
                      ),)),
                    ),
                  );
                }),
          ),


          pageIndex==0?imageWidget():videoWidget()
        ],
      ),
    );
  }
  Widget imageWidget(){
    final size= MediaQuery.of(context).size;

    return Expanded(child: ListView.builder(
        controller: _imageScrollController,
        itemCount: displayOfImage.length,
        itemExtent: size.height/8,
        itemBuilder:(context,index){


          return Card(
            child: ListTile(
              onTap: (){
                // showImage(displayOfImage[index].path);
                return    Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => MediaPreview(filepath:[] ,isFile: true,file:displayOfImage[index].path ,),
                    transitionDuration: Duration(seconds: 0),
                  ),
                );

              },
             leading: Image.file(displayOfImage[index].path),
              title: Text(
                  displayOfImage[index].fileName.toString()
              ),
              subtitle:Row(

                children: [
                  Expanded(
                    child: Text(
                        displayOfImage[index].size.toStringAsFixed(2)+displayOfImage[index].sizeType
                    ),
                  ),
                  IconButton(icon:Icon(Icons.share),onPressed: (){
                    Share.shareFiles(['${displayOfImage[index].pathString}'], text: 'Add playstore link');
                  },)
                ],
              )
            ),
          );
        })
    );
  }
  Widget videoWidget(){

    final size= MediaQuery.of(context).size;
    return Expanded(child: ListView.builder(
      controller: _videoScrollController,
       itemExtent: size.height/8,
        itemCount: displayOffVideo.length,
        itemBuilder:(context,index){
          print(displayOffVideo[index].path);
       return   Card(
         child: ListTile(
  onTap: ()async{
print(displayOffVideo[index].path);
    // return    Navigator.push(
    //   context,
    //   PageRouteBuilder(
    //     pageBuilder: (_, __, ___) => ImagePreview(filepath:[] ,isFile: true,file:displayOffVideo[index].path,),
    //     transitionDuration: Duration(seconds: 0),
    //   ),
    // );
   // await launch(listOfVideo[index].fileName);
    return    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => VideoPreviewPage(filepath:displayOffVideo[index].pathString ,isFile: true,),
        transitionDuration: Duration(seconds: 0),
      ),
    );
  },
leading: Container(width: size.width*0.2,child: VideoPlayer(controllerList[index])),
           title: Text(displayOffVideo[index].fileName),
           subtitle:
           Row(

             children: [
               Expanded(
                 child: Text(displayOffVideo[index].size.toStringAsFixed(2)+displayOffVideo[index].sizeType),
               ),
               IconButton(icon:Icon(Icons.share),onPressed: (){
                 Share.shareFiles(['${displayOffVideo[index].pathString}'], text: 'Add playstore link');
               },)
             ],
           )



         ),
       );
    // return Text(listOfVideo[index].toString());
       //   return VideoPlayer(controllerList[index]);
        })
    );
  }

   showImage(File file) {
     showDialog(context: context,builder: (context){
     return AlertDialog(content:  Image.file(file),backgroundColor: Colors.transparent,);

     }

     );
   }
}
