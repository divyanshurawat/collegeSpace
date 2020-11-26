import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:documents_picker/documents_picker.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutterfire/widgets/adsManager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:readmore/readmore.dart';
import 'package:screenshot/screenshot.dart';

class DetailsView extends StatefulWidget {
  final String dynamiclink;
  final String url;
  final String linkurl;
  final String title;
  final String desc;
  final String postId;
  final Timestamp timestamp;
 const DetailsView({Key key, @required this.url, this.title, this.desc, this.timestamp,this.postId,this.linkurl,this.dynamiclink}): super(key: key);
  @override
  _DetailsViewState createState() => _DetailsViewState();
}

class _DetailsViewState extends State<DetailsView> {


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
  Future<void> share() async {
    await FlutterShare.share(
        title: widget.title,
        text: "Poly Notes : ${widget.desc}",
        linkUrl: widget.dynamiclink,
        chooserTitle: 'Polynotes');
    if(_isInterstitialAdReady){
      _interstitialAd.show();
    }else{
      _loadInterstitialAd();
    }


  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SafeArea(
        child: ListView(
          children: [
            Stack(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        CachedNetworkImage(imageUrl: widget.url,placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.error),


                        ),


                      ],

                    ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundImage: AssetImage("assets/logo.png"),
                             ),
                        ),
                        Flexible(
                          child: new Container(
                            padding: new EdgeInsets.only(right: 13.0),
                            child: new Text(
                              widget.title,
                              overflow: TextOverflow.ellipsis,
                              style: new TextStyle(
                                fontSize: 13.0,
                                fontFamily: 'Roboto',
                                color: new Color(0xFF212121),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 0.2,
                      color: Colors.grey,

                    ),

                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ReadMoreText(
                        widget.desc,
                        style: TextStyle(fontSize: 18),
                        trimLines: 40,
                        colorClickableText: Colors.pink,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: '...Show more',
                        trimExpandedText: ' show less',
                      ),
                    ),
                    Container(
                      height: 400,
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


                  ],
                ),
                GestureDetector(

                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.arrow_back_ios,color: Colors.white,),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                        RaisedButton(

                            color: Colors.red,

                            shape:RoundedRectangleBorder(



                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.red),

                            ),
                            onPressed: () {

                             share();
                            },
                            child: Icon(Icons.share_rounded,color: Colors.white,),
                          )
                        ],
                      ),
                    ),
                  ],
                )

              ],

            ),
          ],

        ),
      ),
    );
  }
}
