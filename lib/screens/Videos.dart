import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutterfire/widgets/adsManager.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:flutterfire/screens/VideoPlayer.dart';
import 'package:page_transition/page_transition.dart';

import 'home.dart';
class Video extends StatefulWidget {
  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<Video> {
  InterstitialAd _interstitialAd;
  BannerAd _bannerAd;
  bool _isInterstitialAdReady;
  static const _adUnitID = "ca-app-pub-2547447950247820/2896196273";

  final _nativeAdController = NativeAdmobController();
@override
  void initState() {
  _isInterstitialAdReady = false;


  _interstitialAd = InterstitialAd(
    adUnitId: AdManager.interstitialAdUnitId,
    listener: _onInterstitialAdEvent,
  );
  _loadInterstitialAd();
  _bannerAd = BannerAd(
    adUnitId: AdManager.bannerAdUnitId,
    size: AdSize.banner,
  );
  _loadBannerAd();
    super.initState();
  }
  void _loadInterstitialAd() {
    _interstitialAd.load();
  }
  void _loadBannerAd() {
    _bannerAd
      ..load()
      ..show(anchorType: AnchorType.top);
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
  double height = MediaQuery.of(context).size.height;
  double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Container(
        color: Colors.white,
        height: height,
        width: width,
        child: Center(
          child: StreamBuilder(
            stream: videos.orderBy("timestamp",descending: true).snapshots(),

            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(child: Image.asset("assets/icons/loading.gif"));
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
                          if(index%5==5){
                            return  Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 250.0,
                                width: 550.0,
                                decoration: BoxDecoration(

                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                          color: Colors.grey,
                                          blurRadius: 15.0,
                                          offset: Offset(0.75, 0.95))
                                    ],
                                    color: Colors.white),
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.only(bottom: 20.0),
                                child: NativeAdmob(
                                  // Your ad unit id
                                  adUnitID: _adUnitID,
                                  numberAds: 3,
                                  controller: _nativeAdController,
                                  type: NativeAdmobType.full,
                                ),
                              ),
                            );
                          }
                          final DocumentSnapshot document =
                          snapshot.data.documents[index];





                          return GestureDetector(
                            onTap: (){
                              if(_isInterstitialAdReady){
                                _interstitialAd.show();
                              }else{
                                _loadInterstitialAd();
                              }

                              Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: MyHomePage(id: document["id"],description: document["description"],)));

                            },
                            child: Center(
                              child: CourseCard(
                                  document["title"], "24", document["thumbnail"],document["timestamp"]),
                            ),
                          );
                        },
                      ),
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
class CourseCard extends StatelessWidget {
final String title, count, imagePath;
final Timestamp timestamp;

CourseCard(
    this.title,
    this.count,
    this.imagePath,
    this.timestamp
    );

@override
Widget build(BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(8.0),
    child: Column(
      children: <Widget>[
        Container(
          height: 250.0,
          width: 550.0,
          decoration: BoxDecoration(
              image: DecorationImage(

                  image: CachedNetworkImageProvider(imagePath), fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(24),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey,
                    blurRadius: 15.0,
                    offset: Offset(0.75, 0.95))
              ],
              color: Colors.grey),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all( 10.0),
              child: Text(

                '$title',
                style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.9,
                    fontSize: 16.0,),
                overflow: TextOverflow.fade,
              ),

            ),

          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all( 10.0),
              child: Text(

                timeago.format(timestamp.toDate()),
                style: TextStyle(
                  color: Colors.grey,

                  letterSpacing: 1.9,
                  fontSize: 12.0,),
                overflow: TextOverflow.ellipsis,
              ),

            ),
          ],
        )
      ],

    ),
  );
}
}