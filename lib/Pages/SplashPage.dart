import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:instagram_download/Pages/home.dart';
import 'package:instagram_download/Service/InstaFeed.dart';
import 'package:instagram_download/Service/InstaFeed.dart';
import 'package:instagram_download/Service/adService.dart';

import 'package:provider/provider.dart';
class SplashPage extends StatefulWidget {
  InstaFeed instaFeed;
  SplashPage({@required this.instaFeed});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>with SingleTickerProviderStateMixin {
  bool isSplash = true;
  AnimationController _animationController;
  Animation animation;
  AdsService adsService = AdsService();
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    adsService.interstitialAd.dispose();
  }
  // InterstitialAd interstitialAd=InterstitialAd(
  //   adUnitId: 'ca-app-pub-3940256099942544/5224354917',
  //   request: AdRequest(),
  //   listener: AdListener(
  //     onAdFailedToLoad: (Ad ad, LoadAdError error) {
  //       print('Ad failed to load: $error');
  //     },
  //     onAdClosed: (Ad ad){
  //       ad.dispose();
  //
  //
  //     },
  //
  //     onAdLoaded: (Ad ad){
  //       print(ad.isLoaded());
  //       print('ad us loadd');
  //     },
  //     onRewardedAdUserEarnedReward: (RewardedAd ad, RewardItem reward) {
  //       print(reward.type);
  //       print(reward.amount);
  //     },
  //   ),
  // );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController= AnimationController(duration: Duration(seconds: 4),vsync: this);
    animation = IntTween(begin: 0,end: 3).animate(CurvedAnimation(curve: Curves.fastOutSlowIn,parent: _animationController));
    wait();
    _animationController.repeat();

  }
  wait()async{
    await adsService.interstitialAd.load();
    await widget.instaFeed.getClipData();





    Timer(Duration(seconds:6), (){
      setState(() {
        isSplash = false;
        adsService.interstitialAd.show();
      });
    });
  }
  @override

  Widget build(BuildContext context) {

     final _instaFeedProvider= Provider.of<InstaFeed>(context);
     // _instaFeedProvider.getClipData();
    final size = MediaQuery.of(context).size;

    return isSplash? Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,

            end: Alignment.bottomRight,
          colors: [
            Color(0xfff9b054),
            Color(0xfff8a14e),
            Color(0xfff04839),
            Color(0xffe23050),
            Color(0xffe23050),
            Color(0xffb81776),
            Color(0xff801bb3),
          ]
        )
      ),
    //  height: size.height,

      child: AnimatedBuilder(
          animation: _animationController,
          builder: (BuildContext context, Widget child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                
                Image.asset('assest/SplashLogo.png',
                  height: size.height*0.15,


                  ),
                SizedBox(height: size.height*0.01,),
                Container(
                  height: size.height*0.045,
                  width: size.width*0.38,

                  child: Center(
                    child: ListView.builder(
                        itemCount: 4,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index){
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: size.width*0.05,
                              alignment: Alignment.center,
                              child: Container(

                                decoration: BoxDecoration(
                                  //  color: animation.value== index ?Colors.orange:Colors.white,
                                //  borderRadius: BorderRadius.circular(10),
                                    shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      tileMode: TileMode.repeated,
                                      end: Alignment.topRight,
                                      colors:animation.value==index? [
                                        Color(0xffff00cb),
                                        Color(0xffff00af),
                                        Color(0xffff0092),

                                        Color(0xffff0046),
                                        //Color(0xfffcd195b),
                                      ]:[
                                        Color(0xffffffff),
                                        Color(0xffffffff),
                                      ]
                                  )
                                  ),


                              ),
                            ),
                          );
                        }),
                  ),
                ),
              ],
            );
          }),
    ):Home();
  }
}
