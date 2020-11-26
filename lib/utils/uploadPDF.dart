import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterfire/screens/home.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

class ProfileAdmin extends StatefulWidget {
  final String link,branch,sem;
  final String currentUserid;

  ProfileAdmin({this.currentUserid, this.link,this.branch,this.sem});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<ProfileAdmin> {
  PageController _pageController;
  int pageIndex = 0;
  String _path;
  bool photoSelected = false;
  bool pdfSelected = false;
  bool isUploading = false;

  String _extension;
  bool _multiPick = false;

  TextEditingController displayNameController = TextEditingController();
  TextEditingController bio = TextEditingController()..text = "+91";
  TextEditingController username = TextEditingController();
  TextEditingController fb = TextEditingController();
  TextEditingController insta = TextEditingController();
  TextEditingController twitter = TextEditingController();

  TextEditingController giflink = TextEditingController();
  bool checkusername = false;
  bool isLoading = false;
  bool _bioValid = true;
  bool _displayName = true;
  String Imgurl;
  String pdfurl;
  String imagefile;
  String pdffile;
  @override
  void initState() {
    // TODO: implement initState
   // getUser();
    _pageController = PageController();
print(widget.branch);
print(widget.sem);
    super.initState();
  }

  uploadingPhoto() async {
    if (photoSelected) {
      Imgurl = await UploadThumb();
      print(Imgurl);
      setState(() {
        isUploading = false;
      });
      uploadingPDF();

    }
    return ;
  }
  uploadingPDF() async {
    if (pdfSelected) {
   pdfurl = await UploadPDF();
      print(Imgurl);
      setState(() {
        isUploading = false;
      });
      updateProfileWithData();
    }
    return ;
  }



  updateProfileWithData()async {

    String postID = Uuid().v4();

    var dynamicLink = await createDynamicLink(pdfurl);


    setState(() {
      displayNameController.text.trim().length < 3 ||
          displayNameController.text.isEmpty
          ? _displayName = false
          : _displayName = true;
      bio.text.trim().length > 100 ? _bioValid = false : _bioValid = true;
      //username.text.trim().length < 6 ? _username = false : _username = true;
      // giflink.text.trim().length ==0 ? _giflink = false : _giflink = true;
      if (_displayName && _bioValid) {

        Firestore.instance
            .collection(widget.branch)
            .document(postID)
            .setData({
          "title": displayNameController.text,
          "pdfurl": pdfurl,
          "postID":postID,
          "timestamp":timestamp,
          "thumbnail":Imgurl,
          "dynamiclink":dynamicLink.toString(),
          "semester":widget.sem,
          "type":"PDF",
          
          "views": 0,


        });
        Fluttertoast.showToast(msg: "Updated");
      }
    });
    Navigator.pop(context);
  }
  Future<Uri> createDynamicLink(@required String username) async {
    print(username);
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://poly.page.link',
      link:
      Uri.parse('https://poly.page.link/groupinvite?username=$username'),
      androidParameters: AndroidParameters(
        packageName: 'com.poly.notes',
        minimumVersion: 1,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.poly.notes',
        minimumVersion: '1',
        appStoreId: '',
      ),
    );
    final link = await parameters.buildUrl();
    final ShortDynamicLink shortenedLink =
    await DynamicLinkParameters.shortenUrl(
      link,
      DynamicLinkParametersOptions(
          shortDynamicLinkPathLength: ShortDynamicLinkPathLength.unguessable),
    );
    return shortenedLink.shortUrl;
  }



  Column buildDisplayName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Subject Name",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextFormField(
          maxLength: 40,
          maxLines: 1,

          controller: displayNameController,
          decoration: InputDecoration(
              border: InputBorder.none,
              icon: Icon(
                Icons.tag,
                color: Colors.black,
              ),
              hintText: "Title",
              errorText: _displayName ? null : "Title is too short"),
        )
      ],
    );
  }





  // get username from firestore

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
  Future<String> UploadPDF() async {
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

  onPageChange(int page) {
    setState(() {
      this.pageIndex = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () {
              uploadingPhoto();
            },
          )
        ],
        automaticallyImplyLeading: true,
        bottomOpacity: 0.1,
        elevation: 0.6,
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            "${widget.branch} ${widget.sem}",
            style: TextStyle(color: Colors.black, fontSize: 10),
          ),
        ),
      ),
      body: isLoading
          ? Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      )
          : SingleChildScrollView(
            child: SafeArea(
        child: Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Column(
              children: <Widget>[
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


                     imagefile = _path;
                      photoSelected=true;




                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 8),
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
                      pdfSelected=true;




                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 8),
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        pdffile!=null?Center(
                          child:  Container(
                            height: 400,
                            child: Text(pdffile)),



                        ):Icon(Icons.picture_as_pdf),
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
                ),

                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0, top: 20, right: 20.0),
                          child: buildDisplayName(),
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),
        ),
      ),
          ),
    );
  }
}
