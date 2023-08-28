import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({ Key? key }) : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController _current = TextEditingController();
  TextEditingController _new = TextEditingController();
  TextEditingController _confirm = TextEditingController();
  late User? firebaseUser;
  bool isCurrentPasswordValid = true;
  var _formKey = GlobalKey<FormState>();

  Future<bool> validatePassword(String currentPassword) async{
    try {
      firebaseUser = await FirebaseAuth.instance.currentUser;
      var authCredentials = await EmailAuthProvider.credential(
        email: firebaseUser!.email!, 
        password: currentPassword
      );
      var authResult = await firebaseUser!.reauthenticateWithCredential(authCredentials);
      return authResult.user !=null;  
    } catch (e) {
      print("*********** Error in validatePassword: $e");
      return false;
    }
  }

  Future<bool> updatePassword(String newPassword)async {
    try {
      await firebaseUser!.updatePassword(newPassword);
      return true;
    } catch (e) {
      print("********Error in update password function: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = 8;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Reset Password'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: EdgeInsets.only(top: 20),
            child: FractionallySizedBox(
              widthFactor: 0.95,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: bottomPadding),
                      child: TextFormField(
                        obscureText: true,
                        controller: _current,
                        cursorWidth: 1,
                        cursorColor: Colors.white,
                        style: TextStyle(
                          fontSize: 18
                        ),
                        decoration: InputDecoration(
                          hintText: 'Current Password',
                          labelText: 'Current Password',
                          errorText: isCurrentPasswordValid?null:'Enter password is not correct',
                          labelStyle: TextStyle(height: 0.5), 
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: bottomPadding),
                      child: TextFormField(
                        obscureText: true,
                        controller: _new,
                        cursorWidth: 1,
                        cursorColor: Colors.white,
                        style: TextStyle(
                          fontSize: 18
                        ),
                        decoration: InputDecoration(
                          hintText: 'New Password',
                          labelText: 'New Password',
                          labelStyle: TextStyle(height: 0.5), 
                        ),
                        validator: (value){
                          if(value==null) return 'Enter new password';
                          return (value.isEmpty)?'Enter the new password':null;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: bottomPadding),
                      child: TextFormField(
                        obscureText: true,
                        controller: _confirm,
                        cursorWidth: 1,
                        cursorColor: Colors.white,
                        style: TextStyle(
                          fontSize: 18
                        ),
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          labelText: 'Confirm Password',
                          labelStyle: TextStyle(height: 0.5), 
                        ),
                        validator: (value){
                          return (_new.text==value)?null:"Passwords did not match";
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: ElevatedButton(
                        onPressed: () async{

                          isCurrentPasswordValid = await validatePassword(_current.text);
                          setState(() {});

                          if(_formKey.currentState!.validate() && isCurrentPasswordValid){
                            if(await updatePassword(_new.text)){
                              Navigator.pop(context);
                            }
                          }
                        }, 
                        child: Text('Reset',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}