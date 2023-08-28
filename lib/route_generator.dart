import 'package:flutter/material.dart';
import 'package:insta/app_screens/ProfilePage.dart';
import 'package:insta/app_screens/dmPage.dart';
import 'package:insta/app_screens/editProfile.dart';
import 'package:insta/app_screens/firstPage.dart';
import 'package:insta/app_screens/forgotPassword.dart';
import 'package:insta/app_screens/homeMainPage.dart';
import 'package:insta/app_screens/logIn.dart';
import 'package:insta/app_screens/resetPassword.dart';
import 'package:insta/app_screens/signUp.dart';
import 'package:insta/screenArguments.dart';


class RouteGenerator{
  static Route<dynamic> generateRoute(RouteSettings settings){

    final _args = (settings.arguments!=null)? settings.arguments as ScreenArguments: settings.arguments;

    switch(settings.name){
      case '/':
        return MaterialPageRoute(builder: (context) => FirstPage());
      case '/sign-up':
        return MaterialPageRoute(builder: (context) => SignUp());
      case '/log-in':
        return MaterialPageRoute(builder: (context) => LogIn());
      case '/dms':
        return MaterialPageRoute(builder: (context) => DmPage());
      case '/edit-profile':
        if(_args is ScreenArguments){
          return MaterialPageRoute(builder: (context) => EditProfile(user: _args.userDoc));
        }else{
          return MaterialPageRoute(builder: (context) => Container(child: Center(child: Text('Error in routing, should not have landed here 1')),));
        }
      case '/home':
      if(_args is ScreenArguments){
          return MaterialPageRoute(builder: (context) => HomeMainPage(user: _args.userDoc, passedIndex:_args.selectedIndex));
        }else{
          return MaterialPageRoute(builder: (context) => Container(child: Center(child: Text('Error in routing, should not have landed here 2')),));
        }
      case '/profile':
        if(_args is ScreenArguments){
          return MaterialPageRoute(builder: (context) => ProfilePage(user: _args.userDoc));
        }else{
          return MaterialPageRoute(builder: (context) => Container(child: Center(child: Text('Error in routing, should not have landed here 3')),));
        }
      case '/reset-password':
        return MaterialPageRoute(builder: (context) => ResetPassword());
      case '/forgot-password':
        return MaterialPageRoute(builder: (context) => ForgotPassword());
      default:
        return MaterialPageRoute(builder: (context) => LogIn());
    }
  }
}

