import 'package:flutter/material.dart';

class CustomCircularAvatar extends StatefulWidget {
  // final bool isNetworkImage;
  final bool storyRing;
  final bool storySeen;
  String imgPath;
  final double radius;
  final EdgeInsetsGeometry? margin;
  final double width;
  final double paddingBetween;
  CustomCircularAvatar({ Key? key,
    // required this.isNetworkImage, 
    required this.storyRing, 
    this.storySeen=false, 
    required this.imgPath, 
    this.radius=30, 
    this.margin,
    this.width=70,
    this.paddingBetween=3,
  }) : super(key: key);

  @override
  _CustomCircularAvatarState createState() => _CustomCircularAvatarState();
}

class _CustomCircularAvatarState extends State<CustomCircularAvatar> {
  @override
  Widget build(BuildContext context) {
    
    widget.imgPath = (widget.imgPath.isNotEmpty)?widget.imgPath:'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png';
    return Container(
      child: (widget.storyRing)?withRing():withoutRing(),
    );
  }
  Widget withRing(){
    Color ringColor = (widget.storySeen)?Colors.grey:Colors.red;
    double borderWidth = (widget.storySeen)?1:2;
    return Container(
        margin: widget.margin,
        padding: (widget.storySeen)?EdgeInsets.all(widget.paddingBetween):EdgeInsets.all(widget.paddingBetween-2),
        width: widget.width,
        height: widget.width,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ringColor, width: borderWidth),
        ),
        child: CircleAvatar(
          backgroundImage:NetworkImage(widget.imgPath),
        ),
      );
  }

  Widget withoutRing(){
    return Container(
      margin: widget.margin,
      child: CircleAvatar(
            backgroundImage: NetworkImage(widget.imgPath),
            radius: widget.radius,
      ),
    );
  }
}