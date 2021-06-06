import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:instagram_download/Common/CommonAssest.dart';
import 'package:instagram_download/Common/inputDecoration.dart';
import 'package:instagram_download/Common/loading.dart';
import 'package:instagram_download/Common/toaster.dart';
import 'package:instagram_download/Model/Clipboard.dart';
import 'package:instagram_download/Pages/Preview/VideoPreview.dart';
import 'package:instagram_download/Pages/Preview/mediaPreview.dart';

import 'package:instagram_download/Pages/download.dart';
import 'package:instagram_download/Service/InstaFeed.dart';
import 'package:instagram_download/Service/adService.dart';
import 'package:instagram_download/Widgets/Drawer.dart';
import 'package:instagram_download/Widgets/appbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>with SingleTickerProviderStateMixin {
  Timer adloader ;
  final _formKey= GlobalKey<FormState>();
  InstaFeed _instaFeed;
  bool isFeedUrlEmpty = true;
  Future<void> _initializeVideoPlayerFuture;
  bool loading = true;
  var feedUrl = TextEditingController();
  List<VideoPlayerController> controller=List();
  int pageIndex = 0;
  String _permanentPath;
  List listOfFile = List();
  AdsService adsService = AdsService();
  InterstitialAd rewardedAd;
  final CarouselController _carouselSliderController = CarouselController();
  PageController pageController = PageController();
@override
  void dispose() {
    // TODO: implement dispose
  adsService.createbannerAd()..dispose();
    super.dispose();

  }
  @override
  void initState() {
    // TODO: implement initState
    adloader = Timer.periodic(
      const Duration(seconds: 3),
          (timer)async {
        adsService.interstitialAd.load();

      },
    );
    super.initState();

   // adsService.interstitialAd.load();
  }


getPermission()async{
    var permission=  Permission.storage;
    if(await permission.isGranted){


    }
     else if(await permission.isPermanentlyDenied){
       openAppSettings();
    }
     else{
      permission.request();
    }

}


  @override
  Widget build(BuildContext context) {
  final _instaFeedProvider= Provider.of<InstaFeed>(context);
    final size= MediaQuery.of(context).size;
    final fontSize= size.height*0.0225;
    final verSpace = size.height*0.01;
    final horSpaceBtwButton =size.width *0.04;
    final horSpaceBtwBtnText = size.width *0.01;
    final btnTextSize = size.height*0.02;

    return Scaffold(
      backgroundColor: homeBackground,
      appBar: CommonAppBar('InStore',context),
      body:pageIndex  ==1?DownloadPage():homeWidget(context),
      drawer: AppDrawer(),
    bottomNavigationBar: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
       pageIndex==0? Container(
          height: 50,
          child: AdWidget(
            ad:adsService.createbannerAd()..load(),
            key: UniqueKey(),
          ),

        ):Container(),
        Theme(
          data: Theme.of(context).copyWith(
              primaryColor:bottomBarIconColor
          ),
          child: BottomNavigationBar(
              onTap: (val)async{
                var permission=  Permission.storage;
                if(await permission.isGranted){
                  setState(() {
                    pageIndex=  val;
                  });
                }else{
                 _instaFeed.getPermission([]);
                }

              },
              currentIndex: pageIndex,
              type: BottomNavigationBarType.fixed, // This is all you need!
              items:[
                BottomNavigationBarItem(

                  icon: Icon(FontAwesomeIcons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.download),
                  label:  'Download',
                ),
              ]
          ),
        ),


      ],
    )
    );
  }
  Widget homeWidget(BuildContext context){
    final _instaFeedProvider= Provider.of<InstaFeed>(context);

    return StreamBuilder<ClipBoardModel>(
        stream: _instaFeedProvider.CLIPSTREAM,
        builder: (context,clipsnapshot) {

          if(clipsnapshot.hasData){
            //print(clipsnapshot.data.url);
            feedUrl.text = clipsnapshot.data.url;
          //  feedUrl.text= clipsnapshot.data.url!= ' ' || !null ?clipsnapshot.data.url:'';
return localHome(feedUrl.text, context);
            // if(feedUrl.text!=''){
            //
            // }
// return Container(child: Text('ss'),);

          }
          else if(clipsnapshot.hasError){
            return Text(clipsnapshot.error.toString());
          }
          else {
            feedUrl.clear();
            return localHome(feedUrl.text, context);
          }
          // print(clipsnapshot.data.url);



        }
    );
  }
  Widget localHome(String postURL,BuildContext context,){

    final size= MediaQuery.of(context).size;
    final fontSize= size.height*0.0225;
    final verSpace = size.height*0.01;
    final horSpaceBtwButton =size.width *0.04;
    final horSpaceBtwBtnText = size.width *0.01;
    final btnTextSize = size.height*0.02;

   return  SingleChildScrollView(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
          size.width * 0.1, size.height * 0.05, size.width * 0.1,
          0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(''
                'Download Posts,Videos',
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: verSpace,),
            TextFormField(
              // initialValue: feedUrl,
              //   onChanged: (val)=>feedUrl = val,
                controller: feedUrl,
                decoration: inputDecoration.copyWith(
                    suffixIcon: IconButton(
                        icon: Icon(Icons.cancel), onPressed: () {
                      setState(() {
                        feedUrl.clear();
                        // controller.pause();
                        isFeedUrlEmpty = true;
                        print(feedUrl);
                      });
                    }))
            ),
            SizedBox(height: verSpace,),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04),
              child: Row(
                children: [
                  Expanded(
                      child: GestureDetector(

                        onTap: () async {


                          setState(() {
                            isFeedUrlEmpty = false;
                            loading = true;
                          });
                          print(feedUrl.text);
                          if (feedUrl.text.isNotEmpty){
                            _instaFeed =
                                InstaFeed();

                            controller.clear();

                            await _instaFeed.initialize(feedUrl.text);

                            // controller[0]?.dispose();
                            for(int i=0;i<_instaFeed.posts.length;i++){
                              VideoPlayerController _con;
                              if (_instaFeed.posts[i].isVideo) {
                                _con = VideoPlayerController.network(
                                    _instaFeed.posts[i].contentUrl);
                                _initializeVideoPlayerFuture =
                                    _con.initialize();
                                _con.setLooping(true);
                              }
                              controller.add(_con);
                            }





                          }
                          else{
                            isFeedUrlEmpty = true;
                          }




                          loading = false;
                          setState(() {


                          });



                        },
                        child: Container(
                            height: size.height * 0.06,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  5.0),
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xff8754ae),
                                    Color(0xff734db4),
                                    Color(0xff6246b7)
                                  ]
                              ),

                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .center,
                              children: [
                                FaIcon(FontAwesomeIcons.link,
                                  color: homeButtonIconColor,),
                                SizedBox(
                                  width: horSpaceBtwBtnText,),
                                Text(
                                  'Paste Link',
                                  style: TextStyle(
                                      color: homeButtonTextColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: btnTextSize
                                  ),
                                )

                              ],
                            )
                        ),
                      )
                  ),
                  SizedBox(width: horSpaceBtwButton,),
                  Expanded(child: GestureDetector(
                    onTap: () async {

                      //rewardedAd.show();
                      //await adsService.interstitialAd.load();

                      await adsService.interstitialAd.show();


                      if (!isFeedUrlEmpty) {
                        //feedUrl.text != null
                        //  await _instaFeed.getImageFromFeedUrl();
                        _instaFeed.getPermission(_instaFeed.posts);

                        return toaster();
                      }
                    },
                    child: Container(
                        height: size.height * 0.06,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xff5387b3),
                                Color(0xff408cc8),
                                Color(0xff2b93e2)
                              ]
                          ),

                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .center,
                          children: [
                            FaIcon(FontAwesomeIcons.download,
                              color: homeButtonIconColor,),
                            SizedBox(width: horSpaceBtwBtnText,),
                            Text(
                              'Download',
                              style: TextStyle(
                                  color: homeButtonTextColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: btnTextSize
                              ),
                            )

                          ],
                        )
                    ),
                  )),
                ],
              ),
            ),
            SizedBox(height: verSpace,),
            // Text(_instaFeed
            //     .posts[0].isVideo.toString()),
            Container(
                height: size.height * 0.3,
                width: size.width,
                decoration: BoxDecoration(

                ),
                child: isFeedUrlEmpty ? Center(
                    child: Container()) :
                //Container()
                loading ? Center(child: loadingWidget()) :
                Container(
                  width: size.width*0.8,
                  color: Colors.black,
                  padding: EdgeInsets.all(8.0),
                  child: PageView.builder(
                    controller: pageController,

                    itemCount: _instaFeed.posts.length,
                    itemBuilder: (BuildContext context,postindex){
                      return GestureDetector(
                        onTap: ()async{
                          await adsService.interstitialAd.show();

                          return    Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => MediaPreview(filepath:_instaFeed.posts ,isFile: false,file: File(''),),
                              transitionDuration: Duration(seconds: 0),
                            ),
                          );
                        },
                        child: Container(
                          child: Stack(
                            // mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${postindex+1}/${_instaFeed
                                  .posts.length}',style: TextStyle(
                                  color: homeButtonTextColor
                              ),),
                              _instaFeed
                                  .posts[postindex].isVideo ? Stack(
                                    children: [
                                      Center(
                                        child: FutureBuilder(
                                          future: _initializeVideoPlayerFuture,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.done) {

                                              return AspectRatio(aspectRatio: controller[postindex].value.aspectRatio,child: VideoPlayer(controller[postindex]));
                                            } else {
                                              return Center(child: loadingWidget());
                                            }
                                          },
                                        ),
                                      ),
                                      Container(

                                          child: Center(child: Icon(
                                            Icons.play_arrow,
                                            color: homeButtonIconColor,
                                          ),))
                                    ],
                                  ) :
                              Stack(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: _instaFeed.posts[postindex].displayUrl,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: imageProvider,
                                              // fit: BoxFit.scaleDown,
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
                                  Center(child: Icon(Icons.play_arrow))
                                ],
                              )
                            ],
                          ),
                        ),
                      );

                    },
                  ),
                )
              //
            ),


          ],
        ),
      ),
    ),
  );
  }
}
