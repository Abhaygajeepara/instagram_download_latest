
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

toaster() {
  Fluttertoast.showToast(
      msg: "Download Start In Few Seconds",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Color(0xfffcd195b),
      textColor: Colors.white,
      fontSize: 16.0,
  );
}