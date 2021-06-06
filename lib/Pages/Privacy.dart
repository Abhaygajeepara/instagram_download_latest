import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:instagram_download/Common/CommonAssest.dart';
import 'package:instagram_download/Service/adService.dart';
import 'package:instagram_download/Widgets/Drawer.dart';
import 'package:instagram_download/Widgets/appbar.dart';

class Privacy extends StatefulWidget {
  @override
  _PrivacyState createState() => _PrivacyState();
}

class _PrivacyState extends State<Privacy> {

  AdsService adsService = AdsService();
  @override
  void dispose() {
    // TODO: implement dispose
    adsService.createbannerAd()..load();
    super.dispose();

  }
  @override
  Widget build(BuildContext context) {
    final size= MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar('Privacy & Policy',context),
      body: Text('add policy'),
      drawer: AppDrawer(),
      //   bottomNavigationBar: Container(
      //      height: 50,
      //      child: AdWidget(
      //        ad:adsService.createbannerAd()..load(),
      //        key: UniqueKey(),
      //      ),
      //
      //    )
    );
  }
}
