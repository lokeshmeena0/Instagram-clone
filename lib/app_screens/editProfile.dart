import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta/common/CustomCircularAvatar.dart';
import 'package:insta/screenArguments.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfile extends StatefulWidget {
  final DocumentSnapshot user;
  EditProfile( {required this.user, Key? key }) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState(user);
}

class _EditProfileState extends State<EditProfile> {
  DocumentSnapshot user;

_EditProfileState(this.user);

  TextEditingController _name = TextEditingController();
  TextEditingController _username = TextEditingController();
  TextEditingController _bio = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _gender = TextEditingController();
  late SharedPreferences _preferences;
  late CollectionReference _usersCollection; 
  late FirebaseAuth _auth;
  late FirebaseStorage _storage;
  late String _imgUrl;
  File? _imagePath;
  bool _profileImageChanged = false;

  @override
  void initState() { 
    super.initState();
    initialize();
  }

  initialize() async{
    try {
      _imgUrl = user['profile-pic'];
      _auth = await FirebaseAuth.instance;
      _preferences = await SharedPreferences.getInstance();
      _usersCollection = await FirebaseFirestore.instance.collection('users');  
      _storage = await FirebaseStorage.instance;
    } catch (err) {
      print('Error in inititalize function in edit profile page*********: $err');
    }
  }

  handleUpdate() async{
    try {
      if(_profileImageChanged){
        final String destination = "/users/avatar/avatar${DateTime.now().millisecondsSinceEpoch}";
        final ref = await _storage.ref().child(destination);
        final uploadTask = await ref.putFile(_imagePath!);
        final downloadUrl = await _storage.ref(destination).getDownloadURL();
        updateUserDatabaseWithImage(downloadUrl);
      }

      if(_name.text.isNotEmpty){
        WriteBatch batch = FirebaseFirestore.instance.batch();
        FirebaseFirestore.instance.collection("posts").where('user_id', isEqualTo:user['id']).get().then((querySnapshot) {
          querySnapshot.docs.forEach((document) {
            try {
                batch.update(document.reference,
                    {"name": _name.text});
            }catch (error) {
              print("************Error in batch update of name in edit profile: $error");
            }
          });
          return batch.commit();
        });
      }

      String? userId = await _preferences.getString('id');
      if(userId!=null){
        await _usersCollection.doc(userId).update({
          'email': (_email.text.isNotEmpty)?_email.text:user['email'],
          'name': (_name.text.isNotEmpty)?_name.text:user['name'],
          'username': (_username.text.isNotEmpty)?_username.text:(user['username'].isNotEmpty)?user['username']:user['name'],
          'phone-number': (_phone.text.isNotEmpty)?_phone.text:user['phone-number'],
          'bio': (_bio.text.isNotEmpty)?_bio.text:(user['bio'] ?? ''),
          'gender': (_gender.text.isNotEmpty)?_gender:(user['gender'] ?? ''),
          'searchKey':(_name.text.isNotEmpty)?_name.text.substring(0,1).toUpperCase():user['searchKey'],
        });
        final userAuth =  await _auth.currentUser;
        if(userAuth!=null){
          if(_email.text.isNotEmpty) await userAuth.updateEmail(_email.text);
          if(_name.text.isNotEmpty) await userAuth.updateDisplayName(_name.text);
          // if(_phone.text.isNotEmpty) userAuth.updatePhoneNumber(_phone.text);
        }
        DocumentSnapshot userDoc = await _usersCollection.doc(userId).get();
        Navigator.of(context).pushReplacementNamed('/home', arguments: ScreenArguments(userDoc: userDoc, selectedIndex: 4));
      }
      
    } catch (e) {
      print('Error in handleUpdate function in edit profile page*********: $e');
    }
  }

  updateUserDatabaseWithImage(String downloadUrl) async{
    await _usersCollection.doc(user['id']).update({
      'profile-pic': downloadUrl,
    });
    WriteBatch batch = FirebaseFirestore.instance.batch();
    FirebaseFirestore.instance.collection("posts").where('user_id', isEqualTo:user['id']).get().then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        try {
            batch.update(document.reference,
                {"profile_pic": downloadUrl});
        }catch (error) {
          print("************Error in batch update in edit profile: $error");
        }
      });
      return batch.commit();
    });
  }

  selectImageSource(ImageSource source) async {
    try {
      //open image picker
      final picker = ImagePicker();
      XFile? _profileImage = await picker.pickImage(source: source);
      if(_profileImage!=null){
        _imagePath = await File(_profileImage.path);
        setState(() {
          _profileImageChanged = true;
        });  
      }
       
    } catch (e) {
      print('Error in selectImageSource function inside edit profile******: $e');
    }
  }

  updateProfilePhoto(){
    //show the modal bottom sheet to select image source from camera/gallery
    showModalBottomSheet(
      isScrollControlled: true,
      context: context, 
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.18,
        child:ListView(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Camera'),
              onTap: () {
                // Navigator.pop(context);
                selectImageSource(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                selectImageSource(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    ); 
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = 8;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                }, 
                child: Text('Cancel', style: TextStyle(color: Colors.white),),
              ),
              Text('Edit Profile'),
              TextButton(
                onPressed: handleUpdate, 
                child: Text('Done', style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          // color: Colors.red,
          child: Center(
            child: FractionallySizedBox(
              widthFactor: 0.95,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    child: (_profileImageChanged)?CircleAvatar(
                      radius: 50,
                      backgroundImage: FileImage(_imagePath!),
                    )
                    :CustomCircularAvatar(
                      radius: 50,
                      storyRing: false, 
                      imgPath: _imgUrl,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 1),
                    child: TextButton(
                      onPressed: updateProfilePhoto, 
                      child: Text('Change Photo',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: bottomPadding),
                    child: TextField(
                      controller: _name,
                      cursorWidth: 1,
                      cursorColor: Colors.white,
                      style: TextStyle(
                        fontSize: 18
                      ),
                      decoration: InputDecoration(
                        
                        hintText: 'Name',
                        labelText: 'Name',
                        labelStyle: TextStyle(height: 0.5),
                        
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: bottomPadding),
                    child: TextField(
                      controller: _username,
                      cursorWidth: 1,
                      cursorColor: Colors.white,
                      style: TextStyle(
                        fontSize: 18
                      ),
                      decoration: InputDecoration(
                        
                        hintText: 'Username',
                        labelText: 'Username',
                        labelStyle: TextStyle(height: 0.5),
                        
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: bottomPadding),
                    child: TextField(
                      controller: _bio,
                      maxLines: null,
                      cursorWidth: 1,
                      cursorColor: Colors.white,
                      style: TextStyle(
                        fontSize: 18
                      ),
                      decoration: InputDecoration(
                        hintText: 'Bio',
                        labelText: 'Bio',
                        labelStyle: TextStyle(height: 0.5),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 3),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/reset-password');
                      }, 
                      child: Text('Reset Password',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: bottomPadding),
                    child: TextField(
                      controller: _email,
                      // keyboardType: ,
                      cursorWidth: 1,
                      cursorColor: Colors.white,
                      style: TextStyle(
                        fontSize: 18
                      ),
                      decoration: InputDecoration(
                        hintText: 'Email',
                        labelText: 'Email',
                        labelStyle: TextStyle(height: 0.5),
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding: EdgeInsets.only(bottom: bottomPadding),
                  //   child: TextField(
                  //     controller: _phone,
                  //     cursorWidth: 1,
                  //     cursorColor: Colors.white,
                  //     style: TextStyle(
                  //       fontSize: 18
                  //     ),
                  //     decoration: InputDecoration(
                  //       hintText: 'Phone',
                  //       labelText: 'Phone',
                  //       labelStyle: TextStyle(height: 0.5),
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: EdgeInsets.only(bottom: bottomPadding),
                    child: TextField(
                      controller: _gender,
                      cursorWidth: 1,
                      cursorColor: Colors.white,
                      style: TextStyle(
                        fontSize: 18
                      ),
                      decoration: InputDecoration(
                        hintText: 'Gender',
                        labelText: 'Gender',
                        labelStyle: TextStyle(height: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}