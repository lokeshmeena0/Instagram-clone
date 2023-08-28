import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta/common/InstaLogo.dart';
import 'package:insta/common/MyCustomTextField.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({ Key? key }) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  // bool _emailSent =  false;

  sendEmail(String email) async{
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Navigator.pop(context);
      // setState(() {
      //   _emailSent = true;
      // });
    } catch (e) {
      print("*************Error in sending reset password link: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.black,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 100, 0, 80),
                child: InstaLogo(
                  logoHeight: 50,
                ),
              ),

              Form(
                key: _formKey,
                child: MyCustomTextFormField(
                    controller: _emailController,
                    placeholder: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Email cannot be kept empty";
                      }
                    },
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 100),
                child: ElevatedButton(
                  onPressed: () {
                    _formKey.currentState!.validate()? sendEmail(_emailController.text): print('wrong format');
                    // if(_emailSent){
                    //   Scaffold.of(context).showSnackBar(
                    //     SnackBar(
                    //       backgroundColor: Colors.black,
                    //       duration: Duration(seconds: 1),
                    //       content: Container(
                    //         margin: EdgeInsets.symmetric(vertical: 10),
                    //         child: Text(
                    //           'Link to reset password has been sent to your email',
                    //           textAlign: TextAlign.center,
                    //           style: TextStyle(color: Colors.white, fontSize: 15),
                    //         ),
                    //       ),
                    //     ),
                    //   );  
                    // }
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.blue[400]),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 140, vertical: 16),
                    child: Text('Reset'),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}