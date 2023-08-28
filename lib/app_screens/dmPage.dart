import 'package:flutter/material.dart';
import 'package:insta/common/CustomCircularAvatar.dart';
import 'package:insta/common/SearchBar.dart';

class DmPage extends StatefulWidget {
  const DmPage({Key? key}) : super(key: key);

  @override
  _DmPageState createState() => _DmPageState();
}

class _DmPageState extends State<DmPage> {
  String userName = 'Loki';
  List<Widget> dmList = [
    DmList(imgPath:'https://wallpaperaccess.com/full/2155536.jpg', storySeen: true, name: 'Danvers', lastMessage: 'see you soon..', time: 'now', storyRing: true,),
    DmList(imgPath:'https://images.hindustantimes.com/rf/image_size_630x354/HT/p2/2019/04/17/Pictures/_b4fc009c-60e8-11e9-a01d-452d93af50a1.jpg', storySeen: false, name: 'Thor', lastMessage: 'see you soon..', time: 'now', storyRing: true,),
    DmList(imgPath:'https://am22.mediaite.com/tms/cnt/uploads/2021/06/Loki-and-Mobius.jpg', storySeen: false, name: 'Mobius', lastMessage: 'see you soon..', time: '1m', storyRing: true,),
    DmList(imgPath:'https://cdn.vox-cdn.com/thumbor/8w6m6Sdl8fkNt7UWPJr5hhNasqA=/0x0:1500x750/1400x1400/filters:focal(762x94:1002x334):format(jpeg)/cdn.vox-cdn.com/uploads/chorus_image/image/51717777/strange.0.jpg', storySeen: true, name: 'Dr. Strange', lastMessage: 'see you soon..', time: '2m', storyRing: false,),
    DmList(imgPath:'https://i0.wp.com/mtcritics.com/wp-content/uploads/2021/07/Sophia-Di-Martino-Reveals-The-Difficulty-She-Faced-In-Loki.png?fit=700%2C525&ssl=1', storySeen: true, name: 'Sylvie', lastMessage: 'see you soon..', time: '5m', storyRing: true,),
    DmList(imgPath:'https://i.insider.com/60491083f196be0018bee9db?width=750&format=jpeg&auto=webp', storySeen: false, name: 'Wanda', lastMessage: 'see you soon..', time: '10m', storyRing: true,),
    DmList(imgPath:'https://qph.fs.quoracdn.net/main-qimg-ed6a2986e8560446cef20a5e0ce5e102', storySeen: false, name: 'Steve', lastMessage: 'see you soon..', time: '15m', storyRing: true,),
    DmList(imgPath:'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQPX1alugCyZ11C9z6dL3FhIBzdUc8kdj8aYbPX3NZAHiBHUNudwXQT0E6XtXFaMEeqFfE&usqp=CAU', storySeen: false, name: 'IronMan', lastMessage: 'see you soon..', time: '1h', storyRing: true,),
    DmList(imgPath:'https://static.wikia.nocookie.net/disney/images/1/1b/Profile_-_Loki_%28Thor_Ragnarok%29.jpg/revision/latest?cb=20210421185239', storySeen: false, name: 'President Loki', lastMessage: 'see you soon..', time: '3h', storyRing: true,),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back_ios_new),
            ),
            Row(
              children: [
                Text(userName),
                GestureDetector(
                  onTap: () {},
                  child: Icon(Icons.keyboard_arrow_down),
                ),
              ],
            ),
            GestureDetector(
                onTap: () {},
                child: Icon(
                  Icons.add_sharp,
                  size: 30,
                ))
          ],
        ),
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SearchBar(),
            // ListView()
            Expanded(
              child: ListView.builder(
                // physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                // shrinkWrap: true,
                itemCount: dmList.length,
                itemBuilder: (context, index) {
                  return dmList[index];
                },
              ),
            ),
            
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[900],
        child: GestureDetector(
          onTap: () {
            print('Camera clicked');
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_rounded, 
                  size: 25,
                  color: Colors.blue[300],
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(5, 0 ,0, 0),
                  child: Text(
                    'Camera',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blue[300],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}



class DmList extends StatefulWidget {
  final bool storyRing;
  final bool storySeen;
  final String imgPath;
  final String name;
  final String lastMessage;
  final String time;
  const DmList({ Key? key,
    required this.imgPath,
    required this.storyRing,
    this.storySeen=false,
    required this.name,
    required this.lastMessage,
    required this.time,
  }) : super(key: key);

  @override
  _DmListState createState() => _DmListState();
}

class _DmListState extends State<DmList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8,0,0,0),
      height: 80,
      // color: Colors.indigo,
      child: Row(
        children: [
          CustomCircularAvatar(
            imgPath: widget.imgPath,
            storyRing: widget.storyRing, 
            storySeen: widget.storySeen, 
            margin: (widget.storyRing)?EdgeInsets.fromLTRB(1,0,6,0):EdgeInsets.fromLTRB(6,0,12,0),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(0,0,0,5),
                  color: Colors.black,
                  child: Text(widget.name),
                ),
                Container(
                  color: Colors.black,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text(
                          widget.lastMessage,
                          style: TextStyle(
                            color: Colors.grey,
                          ),  
                        ),
                      ),
                      Container(
                        child: Text(
                          '. ${widget.time}',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            color: Colors.black,
            padding: EdgeInsets.fromLTRB(15,0,10,0),
            child: Icon(Icons.camera_alt_outlined, size: 30, color: Colors.grey,),
          )

        ],
      ),
    );
  }
}
