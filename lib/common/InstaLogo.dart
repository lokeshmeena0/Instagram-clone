import 'package:flutter/material.dart';

class InstaLogo extends StatefulWidget {
  final double logoHeight;
  const InstaLogo({ Key? key ,required this.logoHeight}) : super(key: key);

  @override
  _InstaLogoState createState() => _InstaLogoState();
}

class _InstaLogoState extends State<InstaLogo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image(
        height: widget.logoHeight,
        image: AssetImage('assets/Insta_logo.png'),
      ),
    );
  }
}