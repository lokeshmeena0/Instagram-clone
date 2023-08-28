import 'package:flutter/material.dart';
import 'package:insta/common/SearchBar.dart';

class AppBarSearchPage extends PreferredSize {
  AppBarSearchPage(BuildContext context):super(
    preferredSize: Size.fromHeight(80),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: SearchBar(),
                    ),
      
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: Icon(
                        Icons.fullscreen_rounded,
                        size: 40,
                      ),
                    )
                  ],
                ),
          ),
          
        ),
  );
  
}