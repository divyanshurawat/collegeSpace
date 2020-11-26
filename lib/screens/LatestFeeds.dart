import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire/widgets/adsManager.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutterfire/screens/LFeeds.dart';

import 'package:flutterfire/screens/home.dart';
import 'package:flutterfire/utils/BlurryDialog.dart';

import 'dart:math' as math;

import 'package:flutterfire/utils/progress_indicator.dart';
import 'package:page_transition/page_transition.dart';

import 'detailView.dart';

class Feeds extends StatefulWidget {
  final bool admin;
  Feeds({this.admin});
  @override
  _FeedsState createState() => _FeedsState();
}

class _FeedsState extends State<Feeds> {
  InterstitialAd _interstitialAd;
  bool _isInterstitialAdReady;
  _showDialog(BuildContext context, branch, syllabus) {
    VoidCallback continueCallBack = () => {
          Navigator.of(context).pop(),
          // code on continue comes here
        };
    BlurryDialog alert = BlurryDialog(branch, syllabus, continueCallBack);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void initState() {
    _isInterstitialAdReady = false;

    _interstitialAd = InterstitialAd(
      adUnitId: AdManager.interstitialAdUnitId,
      listener: _onInterstitialAdEvent,
    );
    _loadInterstitialAd();
    super.initState();
  }

  void _loadInterstitialAd() {
    _interstitialAd.load();
  }

  void _onInterstitialAdEvent(MobileAdEvent event) {
    switch (event) {
      case MobileAdEvent.loaded:
        _isInterstitialAdReady = true;
        break;
      case MobileAdEvent.failedToLoad:
        _isInterstitialAdReady = false;
        print('Failed to load an interstitial ad');
        break;
      case MobileAdEvent.closed:
        // _moveToHome();
        break;
      default:
      // do nothing
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
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
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[


            //  StreamBuilder(
            //    stream: departments.snapshots(),
            //    builder: (BuildContext context,
            //        AsyncSnapshot<QuerySnapshot> snapshot) {
            //      if (snapshot.hasError)
            //        return new Text('Error: ${snapshot.error}');
            //      switch (snapshot.connectionState) {
            //        case ConnectionState.waiting:
            //          return Center(
            //              child: CircularProgressIndicator(
            //            valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
            //          ));
            //        default:
            //          return Container(
            //            height: 210,
            //            child: ListView.builder(
            //              scrollDirection: Axis.horizontal,
            //              itemCount: snapshot.data.documents.length,
            //              shrinkWrap: true,
            //              itemBuilder: (BuildContext context, int index) {
            //                final DocumentSnapshot document =
            //                    snapshot.data.documents[index];
            //
            //                return GestureDetector(
            //                  onTap: () {
            //                    return _showDialog(context,
            //                        document["department"], document["syllabus"]);
            //                    // Navigator.push(context, MaterialPageRoute(builder: (context)=>PDFViewers(url: document["pdfUrl"],)));
            //                  },
            //                  child: CourseCard(document["department"], "24",
            //                      document["image"]),
            //                );
            //              },
            //            ),
            //          );
            //      }
            //    },
            //  ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Events",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        letterSpacing: 1.9,
                        fontWeight: FontWeight.w700),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: NewsFeed()));
                    },
                    child: Text(
                      "See all",
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                          letterSpacing: 1.9,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
            StreamBuilder(
              stream: Firestore.instance
                  .collection("latestFeeds")
                  .orderBy("timestamp", descending: true)
                  .limit(10)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    return Center(
                      child: Container(
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data.documents.length,
                          shrinkWrap: true,
                          itemBuilder: (context, int index) {
                            final DocumentSnapshot document =
                                snapshot.data.documents[index];

                            return Center(
                                child: GestureDetector(
                                    onTap: () {
                                      if (_isInterstitialAdReady) {
                                        _interstitialAd.show();
                                      } else {
                                        _loadInterstitialAd();
                                      }

                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              type: PageTransitionType
                                                  .rightToLeft,
                                              child: DetailsView(
                                                url: document["thumbnail"],
                                                title: document["title"],
                                                desc: document["description"],
                                                dynamiclink:
                                                    document["dynamiclink"],
                                              )));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Recently(
                                          document['title'],
                                          document['thumbnail'],
                                          document['timestamp']),
                                    )));
                          },
                        ),
                      ),
                    );
                }
              },
            ),
          ],
        ),
      ),
    ));
  }
}

class CourseCard extends StatelessWidget {
  final String title, count, imagePath;

  CourseCard(
    this.title,
    this.count,
    this.imagePath,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: 140.0,
            width: 250.0,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: CachedNetworkImageProvider(imagePath),
                    fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(24),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey,
                      blurRadius: 15.0,
                      offset: Offset(0.75, 0.95))
                ],
                color: Colors.grey),
          ),
          SizedBox(
            height: 16,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              '$title',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.9,
                  fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}

class Recently extends StatelessWidget {
  final String notice;
  final String thumbnail;
  final Timestamp timestamp;
  Recently(this.notice, this.thumbnail, this.timestamp);

  final List colors = [Colors.blue, Colors.black, Colors.green];

  @override
  Widget build(BuildContext context) {
    var rng = new math.Random.secure();
    return ListTile(
      leading: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: CachedNetworkImageProvider(thumbnail),
                fit: BoxFit.cover),
            borderRadius: BorderRadius.circular(10),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey,
                  blurRadius: 15.0,
                  offset: Offset(0.75, 0.95))
            ],
            color: Colors.grey),
        width: 85.0,
        height: 100,
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            notice,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              fontSize: 18,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(
            height: 4,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              timeago.format(timestamp.toDate()),
              style: TextStyle(
                color: Colors.grey[500],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            height: 2,
          ),
        ],
      ),
    );
  }
}
