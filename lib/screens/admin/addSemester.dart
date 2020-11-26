
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../home.dart';
import 'package:uuid/uuid.dart';
class AddSemester extends StatefulWidget {
  @override
  _AddSemesterState createState() => _AddSemesterState();
}

class _AddSemesterState extends State<AddSemester> {
final GlobalKey<ScaffoldState> scaffold= new GlobalKey<ScaffoldState>();
 final TextEditingController semester = TextEditingController();

 bool isUploading=false;
 String imagefile;
  String _extension;
  bool _multiPick = false;
  String _path;
  String pdffile;


 setData()async{
  String Imgurl = await UploadThumb();
  String pdfUrl= await UploadPdf();
   Firestore.instance.collection('departments').document(semester.text).setData({
     "department":semester.text,
     "image":Imgurl,
     "pdfUrl":pdfUrl
     

   });
   scaffold.currentState.showSnackBar(new SnackBar(content: Text("Semester Added"),));

   Navigator.pop(context);


 }
  Future<String> UploadThumb() async {
    String postID = Uuid().v4();
    StorageUploadTask storageUploadTask = storageref
        .child("${postID}.jpg")
        .putFile(File(imagefile));
    storageUploadTask.events.listen((event) {
      setState(() {
        isUploading = true;
      });
    });
    StorageTaskSnapshot storageTaskSnapshot =
    await storageUploadTask.onComplete;

    String urli = await storageTaskSnapshot.ref.getDownloadURL();

    return urli;
  }
  Future<String> UploadPdf() async {
    String postID = Uuid().v4();
    StorageUploadTask storageUploadTask = storageref
        .child("${postID}.pdf")
        .putFile(File(pdffile));
    storageUploadTask.events.listen((event) {
      setState(() {
        isUploading = true;
      });
    });
    StorageTaskSnapshot storageTaskSnapshot =
    await storageUploadTask.onComplete;

    String urli = await storageTaskSnapshot.ref.getDownloadURL();

    return urli;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffold,
      appBar: AppBar(
        centerTitle: true,
        actions: [
          isUploading?Text(""):FlatButton(
            onPressed: (){
              setData();
            },
            child: Icon(Icons.download_done_rounded),
          )
        ],
        title: Text("Add Branch"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  try {
                    if (_multiPick) {
                      _path = null;
                    } else {
                      _path = await FilePicker.getFilePath(
                          type: FileType.image,
                          allowedExtensions: (_extension
                              ?.isNotEmpty ??
                              false)
                              ? _extension
                              ?.replaceAll(' ', '')
                              ?.split(',')
                              : null);
                      var file = File(_path);

                    }
                  } on PlatformException catch (e) {
                    // print("Unsupported operation" + e.toString());
                  }
                  if (!mounted) return;
                  setState((){
                    print(_path);


                    imagefile = _path;





                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    imagefile!=null?Center(
                      child:  Container(
                        height: 400,
                        child: new Image.file(
                            File(imagefile)),
                      ),



                    ):Icon(Icons.file_upload,size: 40,),
                    isUploading
                        ? Center(
                      child: Container(
                        height: 200,
                        child: AlertDialog(
                          backgroundColor: Colors.transparent,


                          content: Center(
                              child: Container(
                                height: 120.0,
                                width: 200.0,
                                child: Card(
                                  color: Colors.black.withOpacity(0.1),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: <Widget>[
                                      CircularProgressIndicator(
                                        valueColor:
                                        new AlwaysStoppedAnimation<
                                            Color>(Colors.white),
                                      ),
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Uploading",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )

                          ),
                        ),
                      ),
                    ) : Text(""),

                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  try {
                    if (_multiPick) {
                      _path = null;
                    } else {
                      _path = await FilePicker.getFilePath(
                          type: FileType.any,
                          allowedExtensions: (_extension
                              ?.isNotEmpty ??
                              false)
                              ? _extension
                              ?.replaceAll(' ', '')
                              ?.split(',')
                              : null);
                      var file = File(_path);

                    }
                  } on PlatformException catch (e) {
                    // print("Unsupported operation" + e.toString());
                  }
                  if (!mounted) return;
                  setState((){
                    print(_path);


                    pdffile = _path;





                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    pdffile!=null?Center(
                      child:  new Text(pdffile),



                    ):Icon(Icons.picture_as_pdf,size: 40,),
                    isUploading
                        ? Center(
                      child: Container(
                        height: 200,
                        child: AlertDialog(
                          backgroundColor: Colors.transparent,


                          content: Center(
                              child: Container(
                                height: 120.0,
                                width: 200.0,
                                child: Card(
                                  color: Colors.black.withOpacity(0.1),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: <Widget>[
                                      CircularProgressIndicator(
                                        valueColor:
                                        new AlwaysStoppedAnimation<
                                            Color>(Colors.white),
                                      ),
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Uploading",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )

                          ),
                        ),
                      ),
                    ) : Text(""),

                  ],
                ),
              ),

              TextFormField(
                controller: semester,
                autocorrect: true,
                maxLength: 20,
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: 'Branch',
                  suffix: semester.text == "" ||
                      semester.text == null
                      ? Container(
                    height: 0.0,
                    width: 0.0,
                  )
                      : GestureDetector(
                    child: Icon(
                      Icons.close,
                      size: 16.0,
                    ),
                    onTap: () {
                     semester.text = "";
                    },
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}