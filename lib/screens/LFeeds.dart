import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire/widgets/adsManager.dart';
import 'package:timeago/timeago.dart'as timeago;
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';

import 'package:page_transition/page_transition.dart';


import 'Videos.dart';
import 'detailView.dart';

class NewsFeed extends StatefulWidget {
  final String user;
  NewsFeed({this.user});
  @override
  _NewsFeedState createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {
  InterstitialAd _interstitialAd;
  bool _isInterstitialAdReady;
  static const _adUnitID = "ca-app-pub-2547447950247820/7104037232";

  final _nativeAdController = NativeAdmobController();





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
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Events",style: TextStyle(color: Colors.black),),
      ),
      body: SafeArea(

        child: StreamBuilder(
          stream: Firestore.instance.collection('latestFeeds').orderBy("timestamp",descending: true).snapshots(),

          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

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
                              onTap: (){
                                if(_isInterstitialAdReady){
                                  _interstitialAd.show();
                                }else{
                                  _loadInterstitialAd();
                                }

                                Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child:DetailsView(url: document["thumbnail"],title: document["title"],desc:document["description"] ,dynamiclink: document["dynamiclink"],)));

                              },
                              child: CourseCard(
                                  document["title"], "24", document["thumbnail"],document["timestamp"]
                              ),
                            ));
                      },
                    ),
                  ),
                );
            }
          },

        ),
      ),
    );
  }
}
