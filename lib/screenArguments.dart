import 'package:cloud_firestore/cloud_firestore.dart';

class ScreenArguments{
  DocumentSnapshot userDoc;
  int selectedIndex;

  ScreenArguments({required this.userDoc, this.selectedIndex = 0});
}