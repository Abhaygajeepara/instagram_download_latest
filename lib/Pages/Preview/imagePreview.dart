import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram_download/Common/CommonAssest.dart';
import 'package:instagram_download/Common/loading.dart';
import 'package:instagram_download/Common/toaster.dart';
import 'package:instagram_download/Service/InstaFeed.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:video_player/video_player.dart';
class ImagePreview extends StatefulWidget {
  List<InstalPost> filepath;
  bool isFile;
  File file;

  ImagePreview({@required this.filepath,@required this.isFile,@required this.file});
  @override
  _ImagePreviewState createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview>  with SingleTickerProviderStateMixin{
  String downloadLink;
  InstaFeed  instaFeed =InstaFeed();
  VideoPlayerController _videoPlayerController;
  AnimationController _animationController;
  Animation animation;
  Future<void> _initializeVideoPlayerFuture;
  final CarouselController _carouselSliderController = CarouselController();
  PageController  pageviewController = PageController(initialPage: 0,viewportFraction: 1.0);
  Future<File> file(String filename) async {
    Directory dir = await getApplicationDocumentsDirectory();
    String pathName = p.join(dir.path, filename);
    return File(pathName);
  }
@override
  void dispose() {
    // TODO: implement dispose
  _animationController.dispose();
  _videoPlayerController?.dispose();
    super.dispose();

  }
@override
  void initState() {
    // TODO: implement initState
  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    super.initState();


  _animationController= AnimationController(duration: Duration(seconds: 2),vsync: this);
  if(!widget.isFile){
    downloadLink  = widget.filepath[0].isVideo?widget.filepath[0].contentUrl:widget.filepath[0].displayUrl;
    if(widget.filepath[0].isVideo){
      if(widget.isFile){
        //File file =File(widget.file);
        _videoPlayerController = VideoPlayerController.file(widget.file);
        _initializeVideoPlayerFuture =  _videoPlayerController.initialize();
        _videoPlayerController.setLooping(true);


      }
      else{
        _videoPlayerController = VideoPlayerController.network(widget.filepath[0].contentUrl);
        _initializeVideoPlayerFuture =  _videoPlayerController.initialize();
        _videoPlayerController.setLooping(true);
      }
    }
  }

  animation = Tween(begin: 1.0,end: 0.0).animate(CurvedAnimation(curve: Curves.fastOutSlowIn,parent: _animationController));

  }
  @override
  Widget build(BuildContext context) {


final size = MediaQuery.of(context).size;
return Scaffold(
  body:  AnimatedBuilder(
    animation: _animationController,
    builder: (BuildContext context, Widget child) {
      return Container(
        color: Colors.black,
        height: size.height,
        child: widget.isFile?Image.file(widget.file):
        PageView.builder(
            controller: pageviewController,
            onPageChanged: (val){
              downloadLink = widget.filepath[val].isVideo?widget.filepath[val].contentUrl: widget.filepath[val].displayUrl;
              _videoPlayerController?.dispose();
              if(widget.filepath[val].isVideo){
                _videoPlayerController.play();
              }
              setState(() {

              });
            },
            itemCount: widget.filepath.length,
            itemBuilder: (BuildContext context,postindex){
              // if(widget.filepath[postindex].isVideo){
              //   _videoPlayerController.play();
              // }
              return  Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(icon:Icon(Icons.download_sharp,color: Colors.white,),onPressed: ()async{
                     instaFeed.getPermission([widget.filepath[postindex]]);

                      return toaster();


                    },),
                  ),
                  Expanded(
                    child:widget.filepath[postindex].isVideo? GestureDetector(
                        onTap: () async {
                          _animationController.reset();
                          _animationController.forward();
                          //    _animationController.reverse();
                          setState(() {
                            if (_videoPlayerController.value.isPlaying) {
                              _videoPlayerController.pause();
                            }
                            else {
                              _videoPlayerController.play();
                            }
                          });
                        },
                        child: Stack(
                          children: [
                            Center(
                              child: AspectRatio(
                                aspectRatio: _videoPlayerController.value.aspectRatio,
                                child: FutureBuilder(
                                  future: _initializeVideoPlayerFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      print(_videoPlayerController.position.toString());
                                      return VideoPlayer(_videoPlayerController,);
                                    } else {
                                      return Center(child: loadingWidget());
                                    }
                                  },
                                ),
                              ),
                            ),
                            Container(

                                child: Center(child: Icon(
                                  _videoPlayerController.value.isPlaying ? Icons
                                      .play_arrow : Icons.pause,
                                  color: videoPlayerPlayIconColor
                                      .withOpacity(animation.value),)))
                          ],
                        )):CachedNetworkImage(
                      imageUrl: widget.filepath[postindex].displayUrl,
                      imageBuilder: (context, imageProvider) =>
                          Container(
                            width: size.width*0.8,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                //  fit: BoxFit.fill
                                // colorFilter:
                                // ColorFilter.mode(Colors.red, BlendMode.colorBurn)
                              ),
                            ),
                          ),
                      placeholder: (context, url) =>
                          Center(child: loadingWidget()),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error),
                    ),
                  ),
                ],
              );
            }
        ),
      );
    })

);


  }
}
