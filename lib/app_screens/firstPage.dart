import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:insta/screenArguments.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/InstaLogo.dart';

class FirstPage extends StatefulWidget {

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  bool pageInitialized = false;
  late SharedPreferences _preferences;
  final usersCollection = FirebaseFirestore.instance.collection('users');
  final firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() { 
    super.initState();
    checkUserSignedIn();
  }

  checkUserSignedIn() async{
    try{
      _preferences = await SharedPreferences.getInstance();
      String userId = await _preferences.getString('id') ?? '';
      bool isUserSignedIn = userId.isNotEmpty;
      
      if(isUserSignedIn){
        final DocumentSnapshot user = await usersCollection.doc(userId).get();
        Navigator.of(context).pushReplacementNamed('/home', arguments: ScreenArguments(userDoc: user));
      }else{
        setState(() {
          pageInitialized = true;
        });
      }
    }catch(err){
      print("Error in checkUserSignedIn function*****: $err");
    }
  }



  handleGoogleSignIn() async{
    try {
      final GoogleSignIn googleSignIn = await GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if(googleUser==null) return;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await firebaseAuth.signInWithCredential(credential);
      final User? user = await firebaseAuth.currentUser;

      if(user!=null){
        final userInDB = (await usersCollection.where('id', isEqualTo: user.uid).get()).docs;

        if(userInDB.length==0){
          await usersCollection.doc(user.uid).set({
            'id': user.uid,
            'username': user.displayName,
            'name': user.displayName,
            'profile-pic': user.photoURL,
            'email': user.email,
            'phone-number': user.phoneNumber,
            'bio':"",
            'gender':"",
            'searchKey':(user.displayName!=null)?user.displayName!.substring(0,1).toUpperCase():"A",
            'num-posts': 0,
            'num-followers':0,
            'num-following':0,
            'followers':[],
            'posts-liked':[],
          });
        }

        await _preferences.setString('id', user.uid);
        await _preferences.setString('name', user.displayName ?? '');
        await _preferences.setString('profile-pic', user.photoURL ?? '');
        
        DocumentSnapshot userDoc = await usersCollection.doc(user.uid).get();
        Navigator.of(context).pushReplacementNamed('/home', arguments:ScreenArguments(userDoc: userDoc));
      
      }

    } catch (err) {
      print('Error in handleGoogleSignIn Function**************: $err');
    }
  }

  

  @override
  Widget build(BuildContext context) {
    // double height = MediaQuery.of(context).size.height;
    // double width = MediaQuery.of(context).size.width;
    return (pageInitialized) ? Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InstaLogo(logoHeight: 50),
            Container(
              margin: EdgeInsets.only(top: 80),
              child: FractionallySizedBox(
                widthFactor:0.8,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/log-in');
                  }, 
                  style: ElevatedButton.styleFrom(primary: Colors.blue[400]),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Log in'),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 40),
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/sign-up');
                  }, 
                  style: ElevatedButton.styleFrom(primary: Colors.blue[400]),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Sign up'),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 40),
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: ElevatedButton(
                  onPressed: handleGoogleSignIn,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.orange,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text('Sign in with Google'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    )
    : 
    Center(
      child: SizedBox(
        height: 36, 
        width: 36, 
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ),
    );
  }
}