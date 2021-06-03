import 'dart:io';






import 'package:flutter/material.dart';
import 'package:instagram_download/Common/CommonAssest.dart';
import 'package:instagram_download/Common/loading.dart';

import 'package:video_player/video_player.dart';

class VideoPreviewPage extends StatefulWidget {
  String filepath;
  bool isFile;
  VideoPreviewPage({@required this.filepath,@required this.isFile});
  @override
  _VideoPreviewPageState createState() => _VideoPreviewPageState();
}

class _VideoPreviewPageState extends State<VideoPreviewPage> with SingleTickerProviderStateMixin {
  VideoPlayerController _videoPlayerController;
  Future<void> _initializeVideoPlayerFuture;
  AnimationController _animationController;


  Animation animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController= AnimationController(duration: Duration(seconds: 2),vsync: this);
    animation = Tween(begin: 1.0,end: 0.0).animate(CurvedAnimation(curve: Curves.fastOutSlowIn,parent: _animationController));

    if(widget.isFile){
      File file =File(widget.filepath);
      _videoPlayerController = VideoPlayerController.file(file);
      _initializeVideoPlayerFuture =  _videoPlayerController.initialize();
      _videoPlayerController.setLooping(true);


    }
    else{
      _videoPlayerController = VideoPlayerController.network(widget.filepath);
      _initializeVideoPlayerFuture =  _videoPlayerController.initialize();
      _videoPlayerController.setLooping(true);
    }
    // _videoPlayerController.addListener(()async {
    //   time =  _videoPlayerController.position;});
    _videoPlayerController.play();
    _animationController.forward();


  }
  @override
  void dispose() {
    // TODO: implement dispose
    _animationController.dispose();
    _videoPlayerController.dispose();
    super.dispose();

  }
  @override
  Widget build(BuildContext context) {
    // _videoPlayerController.play();
print(widget.filepath);
return AnimatedBuilder(
    animation: _animationController,
    builder: (BuildContext context, Widget child) {
      return GestureDetector(
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
          ));
    });


  }
}
