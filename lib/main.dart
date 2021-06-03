import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:instagram_download/Pages/SplashPage.dart';
import 'package:instagram_download/Service/InstaFeed.dart';


import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  Workmanager().initialize(
      callbackhandler, // The top level function, aka callbackDispatcher
      isInDebugMode: false // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  );



  runApp(Provider<InstaFeed>.value(
      value: InstaFeed(),
      child: MyApp()),);
}

class MyApp extends StatelessWidget {




  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    final _instaFeedProvider= Provider.of<InstaFeed>(context);
    _instaFeedProvider.getClipData();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,

        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

