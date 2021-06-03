import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:instagram_download/Model/Clipboard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import 'package:rxdart/rxdart.dart';
import 'package:workmanager/workmanager.dart';
void callbackhandler(){
  Workmanager().executeTask((taskName, inputData) async {

    print(inputData);
    final fileName = inputData['fileName'];
    print(fileName+"   in worker function");
    final url = inputData['url'];
    final path = inputData['path'];
    final notiId = inputData["id"];
    await Future.delayed(Duration(seconds: 5));
    print(taskName + " success");
    final port = IsolateNameServer.lookupPortByName(fileName);
    final res = await Dio().download(url,path+"/"+fileName,onReceiveProgress: (done,total){
      int p = (done/total * 100).round();
      print(p);
      sendnotification(notiId, p,fileName);
      if(done == total){
        sendnotification(notiId, 101,fileName);
      }
      port.send(p);
    });
    port.send(100);
    return Future.value(true);
  });
}
Future sendnotification(int id,int pro,String filename) async{
  bool showProgress = true;
  String notificationBody = "${pro.toString()}%";
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings("ic_launcher");
  const InitializationSettings initializationSettings = InitializationSettings(android: androidInitializationSettings);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
  print("started");
  if(pro == 101 ){
    showProgress = false;
    notificationBody = "Completed";
  }
  AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'channel id', 'channel name', 'channel description',
    importance: Importance.max,
    priority: Priority.high,
    showProgress: showProgress,
    maxProgress: 100,
    progress: pro,
    onlyAlertOnce: true,
    showWhen: false,
  );
  NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);
   flutterLocalNotificationsPlugin.show(id, "download", notificationBody, platformChannelSpecifics);
}
class DownloadTask{
  static const String STATUS_PENDING = "status_pending";
  static const String STATUS_RUNNING = "status_running";
  String fileName;
  String path;
  int taskId;
  String url;
  String status;
  int notificationId ;
  Function afterDownload;
  DownloadTask({this.url,this.status,this.fileName,this.taskId,this.path,this.notificationId,this.afterDownload});
  ReceivePort port = ReceivePort();
  StreamController<int> _controller = BehaviorSubject<int>();
  Stream<int> get progressStream => _controller.stream;
  Future startDownload()async{
    final res = IsolateNameServer.registerPortWithName(port.sendPort, fileName);
    if(res){
      port.listen((message) {
        print("Filename: ---$fileName" + message.toString());
        int progress = message;
        _controller.sink.add(progress);
        if(message == 100){
          dispose();
          port.close();
        }
      });
    }
    Workmanager().registerOneOffTask(fileName, "DownloadTask",inputData: {
      "url" : url,
      "fileName" : fileName,
      "path" : path,
      "id": notificationId,
    });
  }
  dispose(){
    _controller.close();
  }
}
class InstalPost {

  bool isVideo;
  String displayUrl;
  String contentUrl;
  InstalPost({this.contentUrl,this.isVideo,this.displayUrl});

  @override
  String toString() {
    return 'InstalPost{isVideo: $isVideo, displayUrl: $displayUrl, contentUrl: $contentUrl}';
  }
}
class InstaFeed {
  static final InstaFeed _instaFeed = InstaFeed._internal();
  factory InstaFeed() {
    return _instaFeed;
  }
  int counter = 0;
  String feedUrl = "";
  String _perminentPath;
  List<InstalPost> posts = [];
  // InstaFeed({this.feedUrl});
  bool _isMultiple = false;
  StreamSubscription subscription ;
  List<DownloadTask> downloadQueue = [];
  List<DownloadTask> completed = [];
  int currentDownloading = 0;
  int maxDownloading = 5;
  ReceivePort port = ReceivePort();
  InstaFeed._internal();
  Timer clipboardTriggerTime;





  // StreamController<List<DownloadTask>> _progressStream = BehaviorSubject<List<DownloadTask>>();
  // Stream<List<DownloadTask>> get getProgress => _progressStream.stream;

  StreamController<String> progressStream = BehaviorSubject<String>();
  Stream<String> get getProgress => progressStream.stream;
  void dispose(){
    progressStream.close();
  }








  Future initialize(String url)async{
    feedUrl = url;
    downloadQueue = [];
    posts = [];
    String filepath = (await getExternalStorageDirectory()).path;

    print(filepath);
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



    _perminentPath = newpath;
    Directory d = Directory(newpath);
    if(!await d.exists()){
      d.create(recursive: true);
    }

    // Directory directory = Directory(filepath);
    // if(await directory.exists()){
    // directory.create(recursive: true);
    // }
    String urlT = feedUrl.trim();
    List<String> urls = urlT.split("?");
    String newUrl = urls[0]+"?__a=1";
    final response = await http.get(newUrl);
    print(response.body);
    final data = json.decode(response.body);
    final graphql = data["graphql"];
    final shortcode_media = graphql["shortcode_media"];
    final multi = shortcode_media["edge_sidecar_to_children"];
    print("multiple" + multi.toString());
    if(multi != null)
      _isMultiple = true;
    else
      _isMultiple = false;
    if(_isMultiple){
      final multiple = multi["edges"];
      for(int i=0;i<multiple.length; i++){
        final singledata = multiple[i]["node"];
        bool isVideo = singledata["is_video"];
        String displayUrl;
        String contentUrl;
        if(isVideo){
          displayUrl = singledata["display_url"];
          contentUrl = singledata["video_url"];
          print("video : --"+contentUrl);
        }
        else{
          contentUrl = singledata["display_url"];
          displayUrl = contentUrl;
          print("Image : --"+contentUrl);
        }
        InstalPost post = InstalPost(contentUrl: contentUrl,isVideo: isVideo,displayUrl: displayUrl);
        posts.add(post);
      }
      print("lenght :" + multiple.length.toString());
    }
    else{
      bool isVideo = shortcode_media["is_video"];
      String displayUrl;
      String contentUrl;
      if(isVideo){
        displayUrl = shortcode_media["display_url"];
        contentUrl = shortcode_media["video_url"];
        print("video : --"+contentUrl);
      }
      else{
        contentUrl = shortcode_media["display_url"];
        displayUrl = contentUrl;
        print("Image : --"+contentUrl);
      }
      InstalPost post = InstalPost(contentUrl: contentUrl,isVideo: isVideo,displayUrl: displayUrl);
      posts.add(post);
    }
    print(posts.toString());
    IsolateNameServer.registerPortWithName(port.sendPort, "DownloadTask");
    // port.listen((message) {
    //   print(message.toString() + "in Class");
    // });
  }
  void removeFromDownloadQueue(DownloadTask task){

  }

  // Future getImageFromFeedUrl() async {
  //  // final respons = await http.get(contentUrl);
  //  // print(respons.body);
  //
  //   final byteDatas =  NetworkAssetBundle(Uri.parse(contentUrl))
  //       .load("");
  //   subscription = byteDatas.asStream().listen((event) {
  //     print(event.lengthInBytes);
  //   });
  //   final  byteData = await byteDatas;
  //   print("chaced");
  //   _tempFile = isVideo ? File(_tempVideo) : File(_tempImage);
  //   print(_getFileName());
  //   final fu =  _tempFile.writeAsBytes(byteData.buffer.asInt8List(byteData.offsetInBytes,byteData.lengthInBytes));
  //   await fu;
  // }
  void addToDownloadQueue(){
    downloadQueue = [];
    for(InstalPost i in posts){
      DownloadTask d = DownloadTask(url: i.contentUrl,status: DownloadTask.STATUS_PENDING,fileName: _getFileName(i.isVideo),path: _perminentPath,notificationId: counter);
      counter++;
      downloadQueue.add(d);
    }
    refreshDownloadTask();
  }
  void refreshDownloadTask(){
    // if(currentDownloading == maxDownloading)
    //   return;

    for(DownloadTask d in downloadQueue){
      // if (currentDownloading == maxDownloading)
      //   break;
      if(d.status == DownloadTask.STATUS_PENDING){
        d.startDownload();
        d.status = DownloadTask.STATUS_RUNNING;
        currentDownloading++;
      }
    }

  }
  Future saveToLocal() async{
    // _tempFile.copy(_perminentPath+"/"+_getFileName());
    for(InstalPost post in posts){
      final byteData = await NetworkAssetBundle(Uri.parse(post.contentUrl)).load("");
      File fileToStore =  File(_getFileName(post.isVideo));
      await fileToStore.writeAsBytes(byteData.buffer.asInt8List(byteData.offsetInBytes,byteData.lengthInBytes));
    }
  }
  // Future downloadFiles() async {
  //   final byteData = await NetworkAssetBundle(Uri.parse("")).load("");
  //   final taskId = await FlutterDownloader.enqueue(url: "https://instagram.fstv11-1.fna.fbcdn.net/v/t50.2886-16/173410855_239128041331474_5737761605319330355_n.mp4?_nc_ht=instagram.fstv11-1.fna.fbcdn.net&_nc_cat=110&_nc_ohc=-Xw7LSz3WiQAX_15KGg&edm=AABBvjUBAAAA&ccb=7-4&oe=60AB4141&oh=e8f4a251f7b1c902f2b8c78aac292fb5&_nc_sid=83d603.mp4", savedDir: _perminentPath);
  // }
  String _getFileName(bool isVideo){
    DateTime d = DateTime.now();
    // return "IMG_"+d.year.toString()+d.month.toString()+d.day.toString()+d.hour.toString()+d.minute.toString()+d.second.toString()+d.microsecond.toString();
    return !isVideo ?   "IMG_"+d.microsecondsSinceEpoch.toString()+".jpg" :  "VD_"+d.microsecondsSinceEpoch.toString()+".mp4";
  }
StreamController<ClipBoardModel> clipController = BehaviorSubject<ClipBoardModel>();
Stream<ClipBoardModel> get CLIPSTREAM =>clipController.stream;
getClipData()async{
  clipboardTriggerTime = Timer.periodic(
    const Duration(seconds: 2),
        (timer)async {
      ClipboardData data = await Clipboard.getData('text/plain');

      if(data == null){

        ClipBoardModel clipboard = ClipBoardModel.of('Incorrect');
        return    clipController.sink.add(clipboard);

      }
      else{

        Clipboard.getData('text/plain').then((clipboarContent) {

          ClipBoardModel clipboard;
           clipboard = ClipBoardModel.of(' ');
             clipController.sink.add(clipboard);
          if(clipboarContent.text.contains('https://www.instagram.com')){
            clipboard = ClipBoardModel.of(clipboarContent.text);
            return   clipController.sink.add(clipboard);

          }
          else{

             clipboard =   ClipBoardModel.of('');
             return   clipController.sink.add(clipboard);

          }

        });
      }
    },
  );
}
}

// StreamController<ClipBoardModel> clipController = BehaviorSubject<ClipBoardModel>();
// Stream<ClipBoardModel> get CLIPSTREAM =>clipController.stream;
// getClipData()async{
//   clipboardTriggerTime = Timer.periodic(
//     const Duration(seconds: 2),
//         (timer)async {
//       ClipboardData data = await Clipboard.getData('text/plain');
//       if(data == null){}
//       else{
//         Clipboard.getData('text/plain').then((clipboarContent) {
//           if(clipboarContent.text.contains('https://www.instagram.com')){
//             ClipBoardModel clipboard = ClipBoardModel.of(clipboarContent.text);
//             return   clipController.sink.add(clipboard);
//           }
//           else{
//             ClipBoardModel clipboard = ClipBoardModel.of('Incorrect');
//             return    clipController.sink.add(clipboard);
//           }
//         });
//       }
//     },
//   );
// }


// class InstaFeed {
//   String feedUrl = "";
//   String _directoryPath;
//   String _tempImage;
//   String _tempVideo;
//   String contentUrl="";
//   String displayUrl ="";
//   bool isVideo = false;
//   File _tempFile;
//   Timer clipboardTriggerTime;
//   String _perminentPath;
//   InstaFeed({this.feedUrl, url});
//   Future initialize()async{
//     String filepath = (await getExternalStorageDirectory()).path;
//      _tempImage = filepath+"/img.jpeg";
//     _tempVideo = filepath +"/video.mp4";
//     print(filepath);
//     String newpath = "";
//     List<String> listFolders = filepath.split("/");
//     for (int i = 1; i < listFolders.length; i++) {
//     String s = listFolders[i];
//     if (s != "Android") {
//     newpath = newpath + "/" + s;
//     }
//     else {
//     break;
//     }
//     }
//     newpath = newpath + "/" + "insta";
//     _perminentPath = newpath;
//     Directory d = Directory(newpath);
//     if(!await d.exists()){
//     d.create(recursive: true);
//     }
//     Directory directory = Directory(filepath);
//     if(await directory.exists()){
//     directory.create(recursive: true);
//     }
//     String urlT = feedUrl.trim();
//     List<String> urls = urlT.split("?");
//     String newUrl = urls[0]+"?__a=1";
//     final response = await http.get(newUrl);
//     //print(response.body);
//     final data = json.decode(response.body);
//     final graphql = data["graphql"];
//     final shortcode_media = graphql["shortcode_media"];
//
//     isVideo = shortcode_media["is_video"];
//     print(isVideo);
//     if(isVideo){
//       displayUrl = shortcode_media["display_url"];
//       contentUrl = shortcode_media["video_url"];
//       //print("video : --"+contentUrl);
//     }
//     else{
//       contentUrl = shortcode_media["display_url"];
//       displayUrl = contentUrl;
//       //print("Image : --"+contentUrl);
//     }
//     //print(isVideo);
//   }
//   Future getImageFromFeedUrl() async {
//     final byteData = await NetworkAssetBundle(Uri.parse(contentUrl))
//         .load("");
//     _tempFile = isVideo ? File(_tempVideo) : File(_tempImage);
//     //print(_getFileName());
//     await _tempFile.writeAsBytes(byteData.buffer.asInt8List(byteData.offsetInBytes,byteData.lengthInBytes));
//   }
//   Future saveToLocal(){
//     _tempFile.copy(_perminentPath+"/"+_getFileName());
//   }
//   String _getFileName(){
//     DateTime d = DateTime.now();
//     // return "IMG_"+d.year.toString()+d.month.toString()+d.day.toString()+d.hour.toString()+d.minute.toString()+d.second.toString()+d.microsecond.toString();
//     return !isVideo ? "IMG_"+d.microsecondsSinceEpoch.toString()+".jpg" : "VD_"+d.microsecondsSinceEpoch.toString()+".mp4";
//   }
//   Future<ClipBoardModel> clipBoard()async{
//     ClipboardData data = await Clipboard.getData('text/plain');
//     ClipBoardModel clipboard = ClipBoardModel.of(data.text);
//     return clipboard;
//   }
//   StreamController<ClipBoardModel> clipController = BehaviorSubject<ClipBoardModel>();
//   Stream<ClipBoardModel> get CLIPSTREAM =>clipController.stream;
//    getClipData()async{
//
//
//
//     clipboardTriggerTime = Timer.periodic(
//
//     const Duration(seconds: 1),
//      (timer) {
//      Clipboard.getData('text/plain').then((clipboarContent) {
//
//
//        if(clipboarContent.text.contains('https://www.instagram.com')){
//          ClipBoardModel clipboard = ClipBoardModel.of(clipboarContent.text);
//          return   clipController.sink.add(clipboard);
//        }
//        else{
//          ClipBoardModel clipboard = ClipBoardModel.of('Incorrect');
//          clipController.sink.add(clipboard);
//        }
//
//
//      });
//      },
//      );
//
//
//
//   }
//
// }