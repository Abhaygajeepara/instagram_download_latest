import 'package:flutter/material.dart';
import 'package:instagram_download/Common/CommonAssest.dart';
import 'package:instagram_download/Widgets/Drawer.dart';
import 'package:instagram_download/Widgets/appbar.dart';

class Installation extends StatefulWidget {
  @override
  _InstallationState createState() => _InstallationState();
}

class _InstallationState extends State<Installation> {
  List data =[
    {
      'text':"Press 'Paste Link' button to load videos/images/reels",
      'asset':"assest/download/1.png"
    },
    {
      'text':"To download multiple images/videos press 'Download'  button",
      'asset':"assest/download/2.png"
    },
    {
      'text':"To download single photo/video/reel press download button on top-right corner of screen",
      'asset':"assest/download/3.png"
    }

    ];
  @override
  Widget build(BuildContext context) {
    final size= MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar('Installation',context),
      body: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context,index){
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                        height: size.height*0.07,
                          width: size.width*0.06,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
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
                          child: Center(
                            child: Text((index+1).toString(),style: TextStyle(
                           color: homeButtonTextColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),),
                          ),
                        ),
                      ),
                      Expanded(child: Text(data[index]['text'],
                       style: TextStyle(

                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),))
                    ],
                  ),
                  Image.asset(data[index]['asset']),
                ],
              ),
            );
          }),
      drawer: AppDrawer(),
    );
  }
}
