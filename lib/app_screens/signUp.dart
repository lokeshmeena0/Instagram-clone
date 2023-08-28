import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta/screenArguments.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/InstaLogo.dart';
import '../common/MyCustomTextField.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _name = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _confirmPassword = TextEditingController();
  late SharedPreferences _preferences;
  late CollectionReference _usersCollection; 
  late FirebaseAuth _auth;
  final _formKey = GlobalKey<FormState>();

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
      print('Error in inititalize function in sign up page*********: $err');
    }
    
  }

  handleUserSignUp() async{
    try {
      await _auth.createUserWithEmailAndPassword(email: _email.text, password: _password.text);
      final User? user = await _auth.currentUser;
      if(user!=null){
        final userInDB = (await _usersCollection.where('id', isEqualTo: user.uid).get()).docs;
        if(userInDB.length==0){
          await _usersCollection.doc(user.uid).set({
            'id': user.uid,
            'username': _name.text,
            'name': _name.text,
            'profile-pic': user.photoURL ?? 'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png',
            'email': user.email,
            'phone-number': user.phoneNumber,
            'bio':"",
            'gender':"",
            'searchKey':_name.text.substring(0,1).toUpperCase(),
            'num-posts':0,
            'num-followers':0,
            'num-following':0,
            'followers':[],
            'posts-liked':[],
          });
        }

        await _preferences.setString('id', user.uid);
        await _preferences.setString('name', user.displayName ?? '');
        await _preferences.setString('profile-pic', user.photoURL ?? '');
        
        DocumentSnapshot userDoc = await _usersCollection.doc(user.uid).get();
        Navigator.of(context).pushReplacementNamed('/home', arguments:ScreenArguments(userDoc: userDoc));
      }

    } catch (err) {
      print('Error in handleUserSignUp function in sign up page*********: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 60, 0, 0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                  child: InstaLogo(
                    logoHeight: 50,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      MyCustomTextFormField(
                        controller: _name,
                          placeholder: 'Name',
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Name cannot be kept empty";
                            }
                          },
                      ),
                      MyCustomTextFormField(
                        controller: _email,
                          placeholder: 'Email',
                          // ignore: todo
                          //TODO add a email and password validator
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Email cannot be kept empty";
                            }
                          },
                          keyboardType: TextInputType.emailAddress,
                      ),
                      MyCustomTextFormField(
                        controller: _password,
                          placeholder: 'Password',
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Password cannot be kept empty";
                            }
                          },
                          obscureText: true,
                      ),
                      MyCustomTextFormField(
                        controller: _confirmPassword,
                          placeholder: 'Confirm Password',
                          validator: (value) {
                            if (value!=_password.text) {
                              return "Password didn't match";
                            }
                          },
                          obscureText: true,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 6, 0, 100),
                        child: ElevatedButton(
                          onPressed: () {
                            if(_formKey.currentState!.validate()){
                              handleUserSignUp();
                            }else{
                              print("Wrong format for credentials");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              primary: Colors.blue[400]),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 135, vertical: 18),
                            child: Text('Sign up'),
                          ),
                        ),
                      ),
                    ],
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
                        'Have an Account?',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                    Container(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/log-in');
                        },
                        child: Text('Log In.'),
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
      ),
    );
  }
}

