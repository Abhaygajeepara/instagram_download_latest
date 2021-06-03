import 'package:flutter/material.dart';
import 'package:instagram_download/Common/CommonAssest.dart';


Widget CommonAppBar(String pageTitle,BuildContext context){
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  return AppBar(
//assest/menuBtn.png
    title: Text(pageTitle,style: TextStyle(
      color: appNameColor
    ),),
    leading: Builder(
      builder: (context) => IconButton(
        icon: Image.asset(
          "assest/menuBtn.png",

        ),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
    ),
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          colors: <Color>[
            Color(0xfff34a36),

            Color(0xfffe62a3f),
            Color(0xfffcd195b),
          ],
        ),
      ),
    ),
  );
}
