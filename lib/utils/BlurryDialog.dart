import 'dart:ui';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterfire/Models/user.dart';
import 'package:flutterfire/screens/NotesView.dart';
import 'package:flutterfire/screens/PDFViewer.dart';
import 'package:flutterfire/screens/VideoPlayer.dart';
import 'package:flutterfire/screens/admin/addSem.dart';
import 'package:flutterfire/screens/home.dart';
import 'package:flutterfire/utils/uploadPDF.dart';
import 'package:page_transition/page_transition.dart';

class BlurryDialog extends StatefulWidget {
  String title;
  String content;
  VoidCallback continueCallBack;

  BlurryDialog(this.title, this.content, this.continueCallBack);
  @override
  _BlurryDialogState createState() => _BlurryDialogState();
}

class _BlurryDialogState extends State<BlurryDialog> {
  User user;
  TextStyle textStyle = TextStyle(color: Colors.black);

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Column(
            children: [
              new Text(
                widget.title,
                style: textStyle,
                overflow: TextOverflow.visible,
              ),

              FlatButton(onPressed: (){
                Navigator.push(context,MaterialPageRoute(builder: (context)=>PDFView(url: widget.content,)));
              },
                  child: new Text("View Syllabus")),

         //RaisedButton(onPressed: (){
         //     Navigator.push(context,MaterialPageRoute(builder: (context)=>Semester(branch: widget.title,)));
         //   },
         //      child: new Icon(Icons.add))
            ],
          ),
          content: StreamBuilder(
            stream: departments
                .document(widget.title)
                .collection('Semesters')
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              else if (!snapshot.hasData) {
                return Center(
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: CircularProgressIndicator()));
              }
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                Colors.teal),
                          )));
                default:
                  return Center(
                    child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data.documents.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          final DocumentSnapshot document =
                              snapshot.data.documents[index];

                          return GestureDetector(
                            onDoubleTap: (){
                          //  Navigator.push(context,MaterialPageRoute(builder: (context)=>ProfileAdmin(branch: widget.title,sem:document["title"] ,)));
                            },
                            onTap: () {


                              Navigator.of(context).pop();
                              widget.continueCallBack;
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.rightToLeft,
                                      child: NotesView(
                                        branch: widget.title,
                                        semester:
                                            document["title"].toString(),
                                      )));
                            },
                            child: Card(
                              child: ListTile(
                                leading: Icon(Icons.book),
                                title: Text(document["title"]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
              }
            },
          ),
          actions: <Widget>[
            new FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ));
  }
}
