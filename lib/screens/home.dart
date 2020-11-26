import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutterfire/Models/user.dart';
import 'package:flutterfire/screens/Departments.dart';
import 'package:flutterfire/screens/LatestFeeds.dart';
import 'package:flutterfire/screens/PDFViewer.dart';
import 'package:flutterfire/screens/VideoPlayer.dart';
import 'package:flutterfire/screens/college_select.dart';
import 'package:flutterfire/utils/constants.dart';
import 'package:flutterfire/widgets/adsManager.dart';
import 'package:flutterfire/widgets/appbar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterfire/widgets/notification_dialog.dart';
import 'package:native_updater/native_updater.dart';
import 'package:package_info/package_info.dart';
import 'package:page_transition/page_transition.dart';

import 'Videos.dart';

final versionCode = Firestore.instance.collection('version');
final DateTime timestamp = DateTime.now();
final StorageReference storageref = FirebaseStorage.instance.ref();

final departments = Firestore.instance.collection('departments');
final videos = Firestore.instance.collection('videos');
final currentuser = Firestore.instance.collection('users');
User currentUser;

class Home extends StatefulWidget {
  final FirebaseUser user;

  const Home({Key key, @required this.user}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'PolyNotes',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );
  bool updatePrompt = false;
  static const _adUnitID = "ca-app-pub-2547447950247820/7104037232";

  final _nativeAdController = NativeAdmobController();
  int _selectedIndex = 0;
  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  StreamSubscription iosSubscription;

  void onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget tabItems() {
    return Center(
      child: Text("TAB ITEM $_selectedIndex"),
    );
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
    //checkForVersion();
  }

  checkForVersion() async {
    print(_packageInfo.version);
    DocumentSnapshot documentSnapshot =
        await versionCode.document("versionUp").get();
    if (documentSnapshot.exists) {
      String versionCode = documentSnapshot['versionCode'];
      if (versionCode != _packageInfo.version) {
        setState(() {
          updatePrompt = true;
        });
      }
    }
    return null;
  }

  void fetchLinkData() async {
    var link = await FirebaseDynamicLinks.instance.getInitialLink();
    handleLinkData(link);
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      handleLinkData(dynamicLink);
    });
  }

  void handleLinkData(PendingDynamicLinkData data) async {
    final Uri uri = data?.link;
    if (uri != null) {
      final queryParams = uri.queryParameters;
      if (queryParams.length > 0) {
        String url = queryParams["username"];
        print(" ${url}");
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.downToUp,
                child: PDFView(
                  url: url,
                )));

        return;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    //getUser();
    //checkVersion();

    fetchLinkData();
    if (!kIsWeb) {
      if (Platform.isIOS) {
        iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
          print(data);
          _saveDeviceToken();
        });

        _fcm.requestNotificationPermissions(IosNotificationSettings());
      } else {
        _saveDeviceToken();
      }

      _fcm.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");

          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => NotificationDialog(
              onOk: this.onOkDialog,
              onClose: this.onCloseDialog,
              title: message['notification']['title'],
              description: message['notification']['body'],
            ),
          );
        },
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");

          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => NotificationDialog(
              onOk: this.onOkDialog,
              onClose: this.onCloseDialog,
              title: Platform.isIOS
                  ? message['title']
                  : message['notification']['title'],
              description: Platform.isIOS
                  ? message['body']
                  : message['notification']['body'],
            ),
          );
        },
        onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");

          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => NotificationDialog(
              onOk: this.onOkDialog,
              onClose: this.onCloseDialog,
              title: Platform.isIOS
                  ? message['title']
                  : message['notification']['title'],
              description: Platform.isIOS
                  ? message['body']
                  : message['notification']['body'],
            ),
          );
        },
      );
    }
  }

  Future<void> checkVersion() async {
    /// For example: You got status code of 412 from the
    /// response of HTTP request.
    /// Let's say the statusCode 412 requires you to force update
    int statusCode = 412;

    /// This could be kept in our local
    int localVersion = 9;

    /// This could get from the API
    int serverLatestVersion = 10;

    Future.delayed(Duration.zero, () {
      if (statusCode == 412) {
        NativeUpdater.displayUpdateAlert(
          context,
          forceUpdate: true,
          appStoreUrl: '<Your App Store URL>',
          playStoreUrl:
              'https://play.google.com/store/apps/details?id=com.poly.notes',
          iOSDescription: '',
          iOSUpdateButtonLabel: 'Upgrade',
          iOSCloseButtonLabel: 'Exit',
        );
      } else if (serverLatestVersion > localVersion) {
        NativeUpdater.displayUpdateAlert(
          context,
          forceUpdate: false,
          appStoreUrl: '<Your App Store URL>',
          playStoreUrl:
              'https://play.google.com/store/apps/details?id=com.poly.notes',
          iOSDescription: '',
          iOSUpdateButtonLabel: 'Upgrade',
          iOSIgnoreButtonLabel: 'Later',
        );
      }
    });
  }

  @override
  void dispose() {
    if (iosSubscription != null) iosSubscription.cancel();
    super.dispose();
  }

  void onCloseDialog() {
    Navigator.pop(context);
  }

  void onOkDialog() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return showDialog(
              context: context,
              builder: (context) => new AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.white)),
                title: new Text('Are you sure you want to exit?'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      "No",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Constants.lightPrimary)),
                    color: Constants.lightPrimary,
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      "Exit",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ) ??
            false;
      },
      child: Scaffold(
        drawer: Drawer(
          child: Column(
            children: [
              new DrawerHeader(
                child: Column(
                  children: [
                    new CircleAvatar(
                      radius: 50,
                      backgroundImage:
                         widget.user.photoUrl!=null? CachedNetworkImageProvider(widget.user.photoUrl):CachedNetworkImageProvider('https://www.allthetests.com/quiz22/picture/pic_1171831236_1.png'),
                    ),

                   Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: new Text(widget.user.displayName),
                   )
                  ],
                ),

              ),
              Container(
                height: 0.5,
                color: Colors.grey,
              ),
              ListTile(
                leading: Icon(Icons.book_outlined),
                title: Text("Quantum Series"),
              ),
              ListTile(
                leading: Icon(Icons.settings_applications),
                title: Text("Logout"),
              )
            ],
          ),
        ),
        appBar: new PreferredSize(
          preferredSize: Size.fromHeight(58.0),
          child: CustomAppBar(
            selectedIndex: _selectedIndex,
            imgageurl: widget.user.photoUrl,
          ),
        ),
        body: Stack(
          children: [
            _selectedIndex == 0
                ? Feeds()
                : _selectedIndex == 1
                    ? Departments()
                    : _selectedIndex == 2
                        ? Video()
                        : _selectedIndex == 3
                            ? tabItems()
                            : _selectedIndex == 4
                                ? tabItems()
                                : Container(),
            updatePrompt
                ? AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    title: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.info,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Update Required!"),
                        ),
                      ],
                    ),
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("New Version Available"),
                      ],
                    ),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () {
                          AdManager.launchURLUpdate(
                              'https://play.google.com/store/apps/details?id=com.poly.notes');
                        },
                        child: Text("Update"),
                      )
                    ],
                  )
                : Text(""),
          ],
        ),
        bottomNavigationBar: SizedBox(
          height: 60.0,
          child: BottomNavigationBar(
            backgroundColor: Colors.black,
            onTap: onTabTapped,
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.green,
            unselectedItemColor: Color(0xff95989A),
            showUnselectedLabels: true,
            unselectedLabelStyle: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 11.0),
            selectedLabelStyle: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 11.0),
            iconSize: 18.0,
            type: BottomNavigationBarType.fixed,
            items: [
              new BottomNavigationBarItem(
                title: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'EVENTS',
                  ),
                ),
                icon: Icon(Icons.home_filled),
              ),
              new BottomNavigationBarItem(
                title: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('DEPARTMENTS'),
                ),
                icon: Icon(Icons.category_rounded),
              ),
              new BottomNavigationBarItem(
                title: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('VIDEO'),
                ),
                icon: Icon(Icons.video_collection_rounded),
              ),
            ],
          ),
        ),
        backgroundColor: Color(0xFFF1F1F1),
      ),
    );
  }

  /// Get the token, save it to the database for current user
  _saveDeviceToken() async {
    // Get the current user
    String uid = widget.user.uid;
    // FirebaseUser user = await _auth.currentUser();

    // Get the token for this device
    String fcmToken = await _fcm.getToken();

    // Save it to Firestore
    if (fcmToken != null) {
      var user = await _db.collection('users').document(uid).get();
      if (!user.exists) {
        // final collegename = await Navigator.push(context, MaterialPageRoute(
        //   builder: (context)=> SelectCollege()
        // ));
        await user.reference.setData({
          "displayName": widget.user.displayName,
          "email": widget.user.email,
          "photoUrl": widget.user.photoUrl,
          "ban": false,
          "badge": false,
          "collegename": null
        });
      }
      DocumentSnapshot doc = await currentuser.document(widget.user.uid).get();
      currentUser = User.fromDocument(doc);
      print(currentUser?.admin);

      var tokens = _db
          .collection('users')
          .document(uid)
          .collection('tokens')
          .document(fcmToken);
      var token = await tokens.get();
      if (!token.exists) {
        await tokens.setData({
          'token': fcmToken,
          'createdAt': FieldValue.serverTimestamp(), // optional
          'platform': Platform.operatingSystem // optional
        });
      }
    }
  }
}
