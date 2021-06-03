

import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService{
  String bannerId = 'ca-app-pub-3940256099942544/6300978111';
  String instantiateId = 'ca-app-pub-3940256099942544/8691691433';
  static initialize(){
    if(MobileAds.instance== null){
      MobileAds.instance.initialize();
    }
  }

  BannerAd createbannerAd(){
    BannerAd _ad = BannerAd(size: AdSize.smartBanner, adUnitId: bannerId,
        listener: AdListener(

      onAdClosed: (Ad ad)=>print('adclosed'),
      onAdLoaded: (Ad ad)=>print('adload'),
      onAdOpened: (Ad ad)=>print('ad open'),
      onAdFailedToLoad: (Ad ad ,LoadAdError error)=>print('error=${error}'),
    ), request: AdRequest());
    return _ad;
  }
  InterstitialAd interstitialAd=InterstitialAd(
    adUnitId: 'ca-app-pub-3940256099942544/5224354917',
    request: AdRequest(),
    listener: AdListener(
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        print('Ad failed to load: $error');
      },
      onAdClosed: (Ad ad){
        ad.dispose();


      },

      onAdLoaded: (Ad ad){
        print(ad.isLoaded());
      },
      onRewardedAdUserEarnedReward: (RewardedAd ad, RewardItem reward) {
        print(reward.type);
        print(reward.amount);
      },
    ),
  );
}