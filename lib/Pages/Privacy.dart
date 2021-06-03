import 'package:flutter/material.dart';
import 'package:instagram_download/Widgets/Drawer.dart';
import 'package:instagram_download/Widgets/appbar.dart';

class Privacy extends StatefulWidget {
  @override
  _PrivacyState createState() => _PrivacyState();
}

class _PrivacyState extends State<Privacy> {
  @override
  Widget build(BuildContext context) {
    final size= MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar('Privacy & Policy',context),
      drawer: AppDrawer(),
    );
  }
}
