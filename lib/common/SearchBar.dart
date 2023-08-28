import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {


  
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: TextField(
        onChanged:(val) {
        },
        style: TextStyle(
          fontSize: 20,
        ),
        cursorColor: Colors.white,
        cursorWidth: 0.5,
        cursorHeight: 23,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            size: 25,
          ),
          filled: true,
          fillColor: Colors.grey[800],
          hintText: 'Search',
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
          ),
        ),
      ),
    );
  }
}