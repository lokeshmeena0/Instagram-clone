import 'package:flutter/material.dart';
import 'package:insta/common/InstaLogo.dart';

class AppBarHomePage extends AppBar {
    AppBarHomePage(BuildContext context) : super(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              icon: Icon(Icons.camera_alt_outlined),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
              child: InstaLogo(logoHeight: 30),
            ),
            Row(
              // mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.tv_rounded),
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/dms');
                    },
                    child: Icon(Icons.call_made),
                )
              ],
            ),
          ],
        ),
        
      );
}

