import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta/common/InstaLogo.dart';
import 'package:insta/common/MyCustomTextField.dart';
import 'package:insta/screenArguments.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late SharedPreferences _preferences;
  late CollectionReference _usersCollection; 
  late FirebaseAuth _auth;

  @override
  void initState() { 
    super.initState();
    initialize();
  }

  initialize() async{
    try {
      _auth = await FirebaseAuth.instance;
      _preferences = await SharedPreferences.getInstance();
      _usersCollection = await FirebaseFirestore.instance.collection('users');  
    } catch (err) {
      print('Error in inititalize function in login page*********: $err');
    }
    
  }

  handleEmailPasswordLogin() async{
    try {
      print(_emailController.text);
      print(_passwordController.text);
      await _auth.signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
      final User? user = await _auth.currentUser;

      if(user!=null){
        // final userInDB = (await _usersCollection.where('id', isEqualTo: user.uid).get()).docs;
        // if(userInDB.length==0){
        //   await _usersCollection.doc(user.uid).set({
        //     'id': user.uid,
        //     // 'username': user.displayName,
        //     'name': user.displayName,
        //     'profile-pic': user.photoURL,
        //     'email': user.email,
        //     'phone-number': user.phoneNumber,
        //   });
        // }

        await _preferences.setString('id', user.uid);
        await _preferences.setString('name', user.displayName ?? '');
        await _preferences.setString('profile-pic', user.photoURL ?? '');
        
        DocumentSnapshot userDoc = await _usersCollection.doc(user.uid).get();
        Navigator.of(context).pushReplacementNamed('/home', arguments:ScreenArguments(userDoc: userDoc));
      }

    } catch (e) {
      print('Error in handleEmailPasswordLogin funtion **************: $e');
    }
    
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.fromLTRB(0, 100, 0, 80),
                  child: InstaLogo(
                    logoHeight: 50,
                  )),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    MyCustomTextFormField(
                        controller: _emailController,
                        placeholder: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Email cannot be kept empty";
                          }
                        },
                    ),
                    MyCustomTextFormField(
                        controller: _passwordController,
                        placeholder: 'Password',
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Password cannot be kept empty";
                          }
                        },
                        obscureText: true,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 13, 0),
                    child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/forgot-password');
                        }, 
                        child: Text('Forgot Password?')),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 6, 0, 100),
                child: ElevatedButton(
                  onPressed: () {
                    _formKey.currentState!.validate()? handleEmailPasswordLogin(): print('wrong format'); 
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.blue[400]),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 140, vertical: 18),
                    child: Text('Log in'),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 21),
                      child: Divider(
                        color: Colors.grey[700],
                      ),
                      // height:30,
                    ),
                  ),
                  Text(
                    'OR',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 21),
                      child: Divider(
                        color: Colors.grey[700],
                      ),
                      // height:30,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
                    child: Text(
                      "Don't have an Account?",
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                  Container(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/sign-up');
                      },
                      child: Text('Sign Up.'),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 70, 0, 0),
                child: Divider(
                  color: Colors.grey[700],
                ),
              ),
              Center(
                child: Text(
                  'Instagram from Facebook',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
