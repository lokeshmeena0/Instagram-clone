import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:insta/common/CustomCircularAvatar.dart';
import 'package:insta/screenArguments.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with AutomaticKeepAliveClientMixin {
  List<DocumentSnapshot> _querySearchStore = [];
  List<DocumentSnapshot> _tempSearchStore = [];
  // TextEditingController _searchController = TextEditingController();
  
  @override
  bool get wantKeepAlive => true;

  initiateSearch(String value) async {
    try {
      if(value.length == 0){
        setState(() {
          _querySearchStore = [];
          _tempSearchStore = [];
        });
      }

      String capitalizedValue = (value.length>=1)?value.substring(0,1).toUpperCase() + value.substring(1):"";

      if(_querySearchStore.length==0 && value.length==1){
        var query = await FirebaseFirestore.instance.collection('users').where('searchKey', isEqualTo: capitalizedValue.substring(0,1)).get();
        query.docs.forEach((element) {
          _querySearchStore.add(element);
          setState(() {
            _tempSearchStore.add(element);
          });
        });
      }else{
        _tempSearchStore = [];
        _querySearchStore.forEach((element) {
          if(element['name'].startsWith(capitalizedValue)){
            setState(() {
              _tempSearchStore.add(element);
            });
          }
        });
      }  
    } catch (e) {
      print('Error in initializeSearch function in search page********* : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
          child: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: TextField(
                        // controller: _searchController,
                        onChanged: (val) {
                          initiateSearch(val);
                        },
                        style: TextStyle(
                          fontSize: 20,
                        ),
                        cursorColor: Colors.white,
                        cursorWidth: 0.5,
                        cursorHeight: 23,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            size: 25,
                          ),
                          filled: true,
                          fillColor: Colors.grey[800],
                          hintText: 'Search',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: Icon(
                      Icons.fullscreen_rounded,
                      size: 40,
                    ),
                  )
                ],
              ),
            ),
          ),
      ),
      body: (_tempSearchStore.length==0)?StreamBuilder(
          stream: FirebaseFirestore.instance.collection('posts').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Container(
                color: Colors.grey[900],
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.black,
                          child: StaggeredGridView.countBuilder(
                            itemCount: snapshot.data!.docs.length,
                            staggeredTileBuilder: (index) => (index % 18 == 1 ||
                                    (index % 9 == 0 && (index / 9) % 2 != 0))
                                ? StaggeredTile.count(2, 2)
                                : StaggeredTile.count(1, 1),
                            padding: EdgeInsets.zero,
                            crossAxisSpacing: 1,
                            mainAxisSpacing: 1,
                            crossAxisCount: 3,
                            itemBuilder: (context, index) => Container(
                                child: Image.network(
                                    snapshot.data!.docs[index]['postUrl'],
                                    height: 200,
                                    width: 200,
                                    fit: BoxFit.cover)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Container();
            }
          })
          :ListView.builder(
            itemCount: _tempSearchStore.length,
            itemBuilder: (context, index){
              DocumentSnapshot doc = _tempSearchStore[index];
              String image = doc['profile-pic'] ?? "";
              return Container(
                padding: EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.black,
                ),
                child: GestureDetector(
                  onTap: (){
                    // _searchController.clear();
                    Navigator.of(context).pushNamed('/profile', arguments:ScreenArguments(userDoc: doc));
                  },
                  child: ListTile(
                    leading: CustomCircularAvatar(imgPath: image, storyRing: false, radius: 30,),
                    title: Text(doc['name']),  
                  ),
                ),
              );
            },
          ),
    );
  }
}