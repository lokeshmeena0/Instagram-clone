import 'package:flutter/material.dart';

class AppBarProfilePage extends AppBar {
  AppBarProfilePage(BuildContext context):super(
    // backgroundColor: Colors.grey[900],
    elevation: 0,
    automaticallyImplyLeading: false,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock),
        Text('Loki'),
        Icon(Icons.keyboard_arrow_down)
      ],
    )
  );
}