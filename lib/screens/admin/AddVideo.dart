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

class AddVideo extends StatefulWidget {
  final String link;
  final String currentUserid;

  AddVideo({this.currentUserid, this.link});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<AddVideo> {
  PageController _pageController;
  int pageIndex = 0;
  String _path;
  bool photoSelected = false;
  bool isUploading = false;

  String _extension;
  bool _multiPick = false;

  TextEditingController displayNameController = TextEditingController();

  TextEditingController username = TextEditingController();
  TextEditingController fb = TextEditingController();


  TextEditingController linkurl = TextEditingController();
  bool checkusername = false;
  bool isLoading = false;
  bool _bioValid = true;
  bool _displayName = true;

  String imagefile;

  @override
  void initState() {
    // TODO: implement initState
   // getUser();
    _pageController = PageController();

    super.initState();
  }

  uploadingPhoto() async {
    if (photoSelected) {
      String Imgurl = await UploadThumb();
      print(Imgurl);
      setState(() {
        isUploading = false;
      });
      updateProfileWithData(Imgurl);
    }
    return ;
  }

  updateProfileWithData(Imgurl)async {
    print("updated");
    String postID = Uuid().v4();
    var dynamicLink = await createDynamicLink(postID);
    setState(() {

       
        Firestore.instance
            .collection('videos')
            .document(postID)
            .setData({
          "description": displayNameController.text,
          "thumbnail": Imgurl,
          "id":fb.text,
          "title":linkurl.text,
          "shareurl":dynamicLink.toString(),
          "type":"Video",
          "postID":postID,
          "timestamp":timestamp,
          



        });
        Fluttertoast.showToast(msg: "Uploaded");

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
            "Description",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(

          controller: displayNameController,
          decoration: InputDecoration(
              border: InputBorder.none,
              icon: Icon(
                Icons.description,
                color: Colors.black,
              ),
              hintText: "Description",
              errorText: _displayName ? null : "Display Name is too Short"),
        )
      ],
    );
  }
  Column buildlinkurl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Title",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(

          controller: linkurl,
          decoration: InputDecoration(
              border: InputBorder.none,
              icon: Icon(
                Icons.title,
                color: Colors.black,
              ),
              hintText: "Title",
              errorText: _displayName ? null : "Display Name is too Short"),
        )
      ],
    );
  }
  Column buildSocialFb() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Video ID",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: fb,
          decoration: InputDecoration(
              border: InputBorder.none,
              icon: Icon(Icons.title),
              hintText: "i23vuwriwq",
              errorText: _displayName ? null : "YT Video id"),
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
          !isUploading?IconButton(
            icon: Icon(Icons.done),
            onPressed: () {
              photoSelected?uploadingPhoto():Text("");
            },
          ):Column(
            children: [
              CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.teal),),
            ],
          )
        ],
        automaticallyImplyLeading: true,
        bottomOpacity: 0.1,
        elevation: 0.6,
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            "ADD VIDEO",
            style: TextStyle(color: Colors.black, fontSize: 15),
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
          : SafeArea(
        child: ListView(
          children: <Widget>[

            Container(
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              //  print(pageIndex);
                              _pageController.jumpToPage(0);
                            },
                            child: Text(
                              "Description",
                              style: TextStyle(
                                  color: pageIndex == 0
                                      ? Colors.black
                                      : Colors.grey,
                                  fontSize: 16),
                            ),
                          ),
                        ),
                        Container(
                          height: 15,
                          width: 1,
                          color: Colors.white,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              // print(pageIndex);
                              _pageController.jumpToPage(
                                1,
                              );
                            },
                            child: Text("Title",
                                style: TextStyle(
                                    color: pageIndex == 1
                                        ? Colors.black
                                        : Colors.grey,
                                    fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 500,
                    height: 400,
                    child: PageView(
                      onPageChanged: onPageChange,
                      controller: _pageController,
                      children: <Widget>[
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
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, top: 20, right: 20.0),
                                  child: buildlinkurl(),
                                ),
                              ),

                            ],
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
                                  child: buildSocialFb(),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
