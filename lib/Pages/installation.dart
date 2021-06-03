import 'package:flutter/material.dart';
import 'package:instagram_download/Widgets/Drawer.dart';
import 'package:instagram_download/Widgets/appbar.dart';

class Installation extends StatefulWidget {
  @override
  _InstallationState createState() => _InstallationState();
}

class _InstallationState extends State<Installation> {
  @override
  Widget build(BuildContext context) {
    final size= MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar('Installation',context),
      drawer: AppDrawer(),
    );
  }
}
