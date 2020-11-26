


import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire/screens/PDFViewer.dart';
import 'package:flutterfire/utils/BlurryDialog.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'LatestFeeds.dart';
import 'home.dart';
class Departments extends StatefulWidget {
  @override
  _DepartmentsState createState() => _DepartmentsState();
}

class _DepartmentsState extends State<Departments> {


  _showDialog(BuildContext context,branch,syllabus)
  {

    VoidCallback continueCallBack = () => {
      Navigator.of(context).pop(),
      // code on continue comes here

    };
    BlurryDialog  alert = BlurryDialog(branch,syllabus,continueCallBack);


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return  Container(
        decoration: BoxDecoration(
          // Box decoration takes a gradient
          gradient: LinearGradient(
            // Where the linear gradient begins and ends
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            // Add one stop for each color. Stops should increase from 0 to 1
            stops: [0.4, 0.7, 0.5, 0.5],
            colors: [
              // Colors are easy thanks to Flutter's Colors class.
              Color(0xfffafdff),
              Color(0xfffafdff),
              Color(0xffE7FFFF),
              Color(0xffE7FFFF),
            ],
          ),
        ),
      child: Center(
        child: SingleChildScrollView(
          child: StreamBuilder(
            stream: departments.snapshots(),

            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(child: CircularProgressIndicator());
                default:
                  return Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: GridView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data.documents.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        final DocumentSnapshot document =
                        snapshot.data.documents[index];



                        return GestureDetector(
                          onTap: (){
                            return _showDialog(context,document["department"],document["syllabus"]);
                            //Navigator.push(context, MaterialPageRoute(builder: (context)=>PDFViewers(url: document["pdfUrl"],)));
                          },
                          child: CourseCard(
                              document["department"], "24", document["image"]),
                        );
                      }, gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2),
                    ),
                  );
              }
            },

          ),
        ),
      ),
    );
  }
}
class CourseCard extends StatefulWidget {
  final String title, count, imagePath;
  CourseCard(
      this.title,
      this.count,
      this.imagePath,
      );
  @override
  _CourseCardState createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  String _dropDownValue;
  String url;
  showAlertDialog(BuildContext context) {

    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("View"),
      onPressed:  () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>PDFView(url: url,)));



      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
      ),
      title: Text("Section"),
      content: SizedBox(
        height: 60.0,
        child:  new StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection("departments").document(widget.title).collection('Schedule').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return new Text("Please wait");
              var length = snapshot.data.documents.length;
              DocumentSnapshot ds = snapshot.data.documents[length - 1];
              return new DropdownButton(
                items: snapshot.data.documents.map((
                    DocumentSnapshot document) {
                  return DropdownMenuItem(
                      value: document.data["section"],
                      child: new Text(document.data["section"]));
                }).toList(),
                value: _dropDownValue,
                onChanged: (value) {


                  Fluttertoast.showToast(msg: value);

                  setState(() {
                   _dropDownValue = value;
                  url= ds['pdfUrl'];
                  });
                },
                hint: new Text(''),
                style: TextStyle(color: Colors.black),

              );
            }
        ),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: Column(

        children: <Widget>[
          Stack(
            children: [
              Container(
                height: 120.0,
                width: 550.0,
                decoration: BoxDecoration(
                    image: DecorationImage(

                        image: CachedNetworkImageProvider(widget.imagePath),fit: BoxFit.cover),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.grey,
                          blurRadius: 15.0,
                          offset: Offset(0.75, 0.95))
                    ],
                    color: Colors.grey),
              ),

            ],

          ),
          Padding(
            padding: const EdgeInsets.all( 8.0),
            child: Text(
              widget.title,
              style: TextStyle(
                  color: Colors.black,

                  letterSpacing: 1.9,
                  fontSize: 12.0),
            ),
          ),
        ],
      ),
    );
  }
}

