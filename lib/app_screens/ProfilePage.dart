import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta/common/CustomCircularAvatar.dart';
import 'package:insta/screenArguments.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget{
  final DocumentSnapshot user;
  const ProfilePage({ Key? key , required this.user}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState(user:user);
}

class _ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin{
  late CollectionReference ref;
  List _followers=[];
  bool _isBeingFollowed = false;
  int _numFollowers = 0;
  int _numFollowing = 0;
  int _numPosts = 0;
  bool _pageInitialized = false;
  bool _isOtherUserProfile = false;
  String? _authUserId = "";
  DocumentSnapshot user;
  _ProfilePageState({required this.user});

  int totalPosts = 0;
  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() async{
    print('initialize called');
    ref = await FirebaseFirestore.instance.collection('users');
    user = await ref.doc(user['id']).get();
    _followers = user['followers'];
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    _authUserId = await _preferences.getString('id');
    if(_authUserId != user['id']){
      _isOtherUserProfile = true;
    }
    setState(() {
      if(_followers.contains(_authUserId)){
        _isBeingFollowed = true;
      }
      
      _numPosts = user['num-posts'];
      _numFollowers = user['num-followers'];
      _numFollowing = user['num-following'];
      _pageInitialized = true;
    });
  }

  handleFollow() async{
    if(_isBeingFollowed==false){
      await ref.doc(user['id']).update({
        'num-followers': FieldValue.increment(1),
        'followers': FieldValue.arrayUnion([_authUserId]),
      });
      await ref.doc(_authUserId).update({
        'num-following': FieldValue.increment(1),
      });
    }else{
      await ref.doc(user['id']).update({
        'num-followers': FieldValue.increment(-1),
        'followers': FieldValue.arrayRemove([_authUserId]),
      });
      await ref.doc(_authUserId).update({
        'num-following': FieldValue.increment(-1),
      });
    }
    setState(() {
      _numFollowers = (_isBeingFollowed)?_numFollowers-1:_numFollowers+1;
      _isBeingFollowed = !_isBeingFollowed;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if(user['id']==_authUserId){
      ref.doc(_authUserId).get().then((document) {
        if(document['num-following']!=_numFollowing || document['num-followers']!=_numFollowers){
          setState(() {
            _numFollowing = document['num-following'];
            _numFollowers = document['num-followers'];
          });
        }
      });
    }
    return (_pageInitialized)?Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: (_isOtherUserProfile)?true:false,
        title: Container(
          margin: (_isOtherUserProfile)?EdgeInsets.only():EdgeInsets.only(left: 60),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock),
              Text((user['username'].isEmpty)?user['name']:user['username']),
              Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async{
              await FirebaseAuth.instance.signOut();
              final preferences = await SharedPreferences.getInstance();
              preferences.clear();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            }, 
            child: Text('Logout', style: TextStyle(color: Colors.white),),
          ),
        ]
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').where('user_id', isEqualTo: user['id']).orderBy('created_at', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if ((snapshot.hasData && snapshot.data!=null)) {
            return Container(
            color: Colors.grey[900],
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Header(user),
                )),
                SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: (_isOtherUserProfile==false)
                  ?EditButton(user)
                  :Container(
                    margin: EdgeInsets.only(top: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          // width: 150,
                          width: MediaQuery.of(context).size.width*0.4,
                          child: ElevatedButton(
                            onPressed: handleFollow, 
                            child: Text(
                              (_isBeingFollowed)?'Unfollow':'Follow',
                              style: TextStyle(fontSize: 18),
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 0, 
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width*0.4,
                          child: ElevatedButton(
                            onPressed: (){}, 
                            child: Text('Messsage',
                              style: TextStyle(fontSize: 18),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.black,
                              elevation: 0,
                              side: BorderSide(color: Colors.grey[700]!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
                SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                  ), 
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Container(
                        child: Image.network(snapshot.data!.docs[index]['postUrl'], fit: BoxFit.cover,),
                      );
                    },
                    childCount: snapshot.data!.docs.length,
                  ),
                ),
              ],
            ),  
          );
          } else {
            return Container();
          }
        }
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

  Header(user){
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomCircularAvatar(
                  imgPath: user['profile-pic'],
                  storyRing: true,
                  storySeen: true,
                  width: 90,
                  paddingBetween: 4,
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_numPosts.toString(), style: TextStyle(fontSize: 21),),
                    Text('Posts', style: TextStyle(fontSize: 15),),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_numFollowers.toString(), style: TextStyle(fontSize: 21),),
                    Text('Followers', style: TextStyle(fontSize: 15),),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_numFollowing.toString(), style: TextStyle(fontSize: 21),),
                    Text('Following', style: TextStyle(fontSize: 15),),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10,),
            Text(user['name'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
            Text(user['bio'], style: TextStyle(fontSize: 14),),
          ],
        ),
      );
  }
}

class EditButton extends StatelessWidget {
  final DocumentSnapshot user;
  const EditButton(this.user, { Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/edit-profile', arguments: ScreenArguments(userDoc: user));
          },
          child: Text('Edit Profile' ,style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            primary: Colors.black,
            side: BorderSide(color: Colors.grey[700]!),
          ),
      
        ),
    );
  }
}