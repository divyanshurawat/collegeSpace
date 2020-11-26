import 'package:flutter/material.dart';
import 'package:flutterfire/screens/admin/AddNews.dart';
import 'package:flutterfire/screens/admin/AddVideo.dart';
import 'addSemester.dart';
class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)
                ),
                onPressed: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context)=>AddSemester()));

                },
                child: Text("Add Branch"),
              ),
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                ),
                onPressed: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context)=>AddNews()));

                },
                child: Text("Add News"),
              ),
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                ),
                onPressed: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context)=>AddVideo()));
                },
                child: Text("Add Video"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
