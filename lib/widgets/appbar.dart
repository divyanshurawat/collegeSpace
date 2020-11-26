import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire/screens/admin/addSemester.dart';
import 'package:flutterfire/screens/admin/adminPage.dart';
import 'package:flutterfire/utils/uploadPDF.dart';

import 'logout.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({Key key, @required this.selectedIndex,this.imgageurl}) : super(key: key);
  final int selectedIndex;
  final String imgageurl;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      centerTitle: true,
      titleSpacing: 8.0,
      backgroundColor: Theme.of(context).primaryColor,

      title: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: new Text(
          'College Space',
          style: new TextStyle(
              color: Colors.black,

              fontWeight: FontWeight.w600,
              fontSize: 20.0),
        ),
      ),
      actions: <Widget>[
        new IconButton(
            iconSize: 28.0,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent, //
            icon: selectedIndex == 2
                ? GestureDetector(
              onLongPress: (){
                Navigator.push(context,MaterialPageRoute(builder: (context)=>AdminPage()));
              },

                  child: IconButton(
                      icon: Icon(Icons.settings),
                      onPressed: () => {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => Logout(),
                            )
                          }),
                )
                : CircleAvatar(

              backgroundImage: imgageurl!=null? CachedNetworkImageProvider(imgageurl):CachedNetworkImageProvider('https://www.allthetests.com/quiz22/picture/pic_1171831236_1.png'),
            ),
            onPressed: () {
              // Navigator.of(context).pushNamed("/notifications");
            }),
      ],
    );
  }
}
