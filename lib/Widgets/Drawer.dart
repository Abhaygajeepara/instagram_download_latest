import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:instagram_download/Common/CommonAssest.dart';
import 'package:instagram_download/Pages/Privacy.dart';
import 'package:instagram_download/Pages/Setting.dart';
import 'package:instagram_download/Pages/installation.dart';
import 'package:instagram_download/Service/adService.dart';




class AppDrawer extends StatefulWidget {

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  AdsService adsService = AdsService();
  @override
  void dispose() {
    adsService.createbannerAd().dispose();
    // TODO: implement dispose
    super.dispose();

  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textSize = size.height*0.022;
    final iconSize = size.height*0.033;
    final spaceHor =size.width*0.03;

    return Drawer(
        child: Column(
          children: [


           Expanded(
             child: Column(
               children: [
                 Container(

                     height: size.height*0.25,
                     width: size.width,
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
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Padding(
                           padding:  EdgeInsets.fromLTRB(size.width*0.02,0,0,0),
                           child: Text(appName,
                             textAlign: TextAlign.center,
                             style: TextStyle(
                                 color: appNameColor,

                                 fontSize: size.height*0.05,
                                 fontWeight: FontWeight.bold
                             ),),
                         ),
                       ],
                     )
                 ),
                 // ListTile(
                 //     onTap: (){
                 //       Navigator.pop(context);
                 //       return    Navigator.push(
                 //         context,
                 //         PageRouteBuilder(
                 //           pageBuilder: (_, __, ___) => Setting(),
                 //           transitionDuration: Duration(seconds: 0),
                 //         ),
                 //       );
                 //     },
                 //     title: Row(
                 //
                 //       children: [
                 //         Container(
                 //           height: size.height*0.05,
                 //           width: size.width*0.1,
                 //           decoration: BoxDecoration(
                 //             borderRadius: BorderRadius.circular(20.0),
                 //             gradient: LinearGradient(
                 //               begin: Alignment.topLeft,
                 //               end: Alignment.topRight,
                 //               colors: <Color>[
                 //                 Color(0xfff34a36),
                 //
                 //                 Color(0xfffe62a3f),
                 //                 Color(0xfffcd195b),
                 //               ],
                 //             ),
                 //           ),
                 //           child: Center(child: Icon(Icons.settings,color: drawerIconColor,size: iconSize,),),
                 //         ),
                 //         SizedBox(width: spaceHor,),
                 //         Text('Setting',style: TextStyle(
                 //             fontSize: textSize
                 //         ),),
                 //       ],
                 //     )
                 // ),
                 ListTile(
                     onTap: (){
                      Navigator.pop(context);
                       return    Navigator.push(
                         context,
                         PageRouteBuilder(
                           pageBuilder: (_, __, ___) => Installation(),
                           transitionDuration: Duration(seconds: 0),
                         ),
                       );
                     },
                     title: Row(

                       children: [
                         Container(
                           height: size.height*0.05,
                           width: size.width*0.1,
                           decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(20.0),
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
                           child: Center(child: Icon(Icons.download_sharp,color: drawerIconColor,size: iconSize,),),
                         ),
                         SizedBox(width: spaceHor,),
                         Text('How to Download',style: TextStyle(
                             fontSize: textSize
                         ),),
                       ],
                     )
                 ),
                 ListTile(
                     onTap: (){
                       showDialog(
                           context: context,
                           builder: (context){
                            // Navigator.pop(context);
                             return AlertDialog(
                               content: Text('add Something'),
                             );
                           }
                       );
                       // return    Navigator.push(
                       //   context,
                       //   PageRouteBuilder(
                       //     pageBuilder: (_, __, ___) => Installation(),
                       //     transitionDuration: Duration(seconds: 0),
                       //   ),
                       // );
                     },
                     title: Row(

                       children: [
                         Container(
                           height: size.height*0.05,
                           width: size.width*0.1,
                           decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(20.0),
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
                           child: Center(child: Icon(Icons.share,color: drawerIconColor,size: iconSize,),),
                         ),
                         SizedBox(width: spaceHor,),
                         Text('Share',style: TextStyle(
                             fontSize: textSize
                         ),),
                       ],
                     )
                 ),
                 ListTile(
                   onTap: (){
                    Navigator.pop(context);
                     return    Navigator.push(
                       context,
                       PageRouteBuilder(
                         pageBuilder: (_, __, ___) => Privacy(),
                         transitionDuration: Duration(seconds: 0),
                       ),
                     );
                   },
                   title: Row(

                     children: [
                       Container(
                         height: size.height*0.05,
                         width: size.width*0.1,
                         decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(20.0),
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
                         child: Center(child: Icon(Icons.lock_outline,color: drawerIconColor,size: iconSize,),),
                       ),
                       SizedBox(width: spaceHor,),
                       Text('Privacy & Policy',style: TextStyle(
                           fontSize: textSize
                       ),),
                     ],
                   ),

                 ),
               ],
             ),
           ),
            Container(
              height: 50,
              child: AdWidget(
                ad: adsService.createbannerAd()..load(),
                key: UniqueKey(),
              ),

            ),
          ],
        ),

    );
  }
}

