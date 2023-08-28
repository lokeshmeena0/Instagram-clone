import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta/app_screens/ProfilePage.dart';
import 'package:insta/app_screens/homeScreen.dart';
import 'package:insta/app_screens/searchPage.dart';
import 'package:insta/screenArguments.dart';

class HomeMainPage extends StatefulWidget {
  final DocumentSnapshot user;
  final int passedIndex;
  const HomeMainPage({required this.user, this.passedIndex = 0});

  @override
  _HomeMainPageState createState() => _HomeMainPageState(user, passedIndex);
}

class _HomeMainPageState extends State<HomeMainPage> {
  bool isVideo = false;
  DocumentSnapshot user;
  int passedIndex;
  _HomeMainPageState(this.user, this.passedIndex);
  String postCaption = '';
  TextEditingController _caption = TextEditingController();
  late FirebaseStorage _storage;
  late CollectionReference _usersCollection;
  late CollectionReference _postsCollection; 
  
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() { 
    super.initState();
    print("***user***: $user");
    print(user['name']);
    _pageController = PageController(initialPage: passedIndex);
    _currentIndex = passedIndex;
    initialize();
  }

  initialize() async{
    try {
      _postsCollection = await FirebaseFirestore.instance.collection('posts');  
      _usersCollection = await FirebaseFirestore.instance.collection('users');  
      _storage = await FirebaseStorage.instance;
    } catch (err) {
      print('Error in inititalize function in home main page*********: $err');
    }
  }

  addPostedImage(String downloadUrl) async{
    try {
      await _postsCollection.doc().set({
            'caption': postCaption,
            'profile_pic': user['profile-pic'],
            'name': user['name'],
            'email': user['email'],
            'type': 'image',
            'postUrl': downloadUrl,
            'num_likes': 0,
            'created_at': FieldValue.serverTimestamp(),
            'user_id':user['id'],
      });
      await _usersCollection.doc(user['id']).update({
        'num-posts':FieldValue.increment(1),
      });
      Navigator.of(context).pushReplacementNamed('/home', arguments: ScreenArguments(userDoc: user));
      // setState(() {});  
    } catch (e) {
      print('Error in addPostImage function in home main page*********: $e');
    }
    
  }

  upload(File imagePath) async {
    final String destination = "/posts/user${user['id']}/post${DateTime.now().millisecondsSinceEpoch}";
    final ref = await _storage.ref().child(destination);
    final uploadTask = await ref.putFile(imagePath);
    final downloadUrl = await _storage.ref(destination).getDownloadURL();
    print(downloadUrl);
    addPostedImage(downloadUrl);
  }

  selectImageSource(ImageSource source) async {
    try {
      //open image picker
      final picker = ImagePicker();
      XFile? _postImage = await picker.pickImage(source: source);
      if(_postImage!=null){
        final imagePath = File(_postImage.path); 
        print (imagePath);
        showDialog(
          context: context, 
          builder: (context) => AlertDialog(
            title: Text(
              'Add a Caption', 
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Builder(
              builder: (context){
                var _height = MediaQuery.of(context).size.height;
                var _width = MediaQuery.of(context).size.width;
                return Container(
                  height: 150,
                  width: _width-100,
                    margin: EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 30),
                          child: TextField(
                            cursorWidth: 1,
                            cursorColor: Colors.white,
                            controller: _caption,
                            maxLines: null,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                postCaption = _caption.text;
                                _caption.clear();
                                postCaption = '';
                              }, 
                              child: Text('Cancel Upload'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                postCaption = _caption.text;
                                _caption.clear();
                                print(postCaption);
                                upload(imagePath);
                              }, 
                              child: Text('Upload'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
              }, 
            ),
          ),
        );
      }
    } catch (e) {
      print('Error in selectImageSource function inside home main page******: $e');
    }
  }

  uploadPost(){
    showModalBottomSheet(
        isScrollControlled: true,
        context: context, 
        builder: (context) => FractionallySizedBox(
          heightFactor: 0.4,
          child:ListView(
            children: [
              Container(
                margin: EdgeInsets.only(top: 20, bottom: 10),
                child: Center(
                  child: Text(
                    'Upload Post',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  selectImageSource(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('Upload image from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  selectImageSource(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam),
                title: Text('Take a Video'),
                onTap: () {
                  Navigator.pop(context);
                  isVideo = true;
                },
              ),
              ListTile(
                leading: Icon(Icons.video_library),
                title: Text('Upload video from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  isVideo = true;
                },
              ),
            ],
            
          ),
        ),
      ); 
  }

  
  _onPageChanged(int index){
    setState(() {
      _currentIndex = index;
    });
  }
  
  _onTapBottomNavIcon(int selectedIndex){
    if(selectedIndex == 2){
      uploadPost();
    }else{
      _pageController.jumpToPage(selectedIndex);
    }
  }
  
  @override
  Widget build(BuildContext context) {

    List<Widget> _screens = [
      HomePage(), 
      SearchPage(),  
      HomePage(),
      Scaffold(appBar: AppBar(title: Text('To be Made'),),), 
      ProfilePage(user: user),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: _onTapBottomNavIcon,
        backgroundColor: Colors.grey[900],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search', 
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Add Post', 
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Search', 
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile', 
          ),
        ],
      ), 
    );
  }
}