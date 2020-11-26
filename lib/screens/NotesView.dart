import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire/screens/PDFViewer.dart';

import 'package:flutterfire/utils/constants.dart';
import 'package:flutterfire/widgets/adsManager.dart';
import 'package:page_transition/page_transition.dart';

import 'Videos.dart';
class NotesView extends StatefulWidget {
  final String branch;
  final String semester;
  NotesView({@required this.branch,this.semester});
  @override
  _NotesViewState createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  Stream slides;
  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;
  bool _isInterstitialAdReady;
  @override
  void initState() {

  getData();
  getTimeLine();

  _bannerAd = BannerAd(
    adUnitId: AdManager.bannerAdUnitId,
    size: AdSize.banner,
  );
  _loadBannerAd();

   _isInterstitialAdReady = false;


   _interstitialAd = InterstitialAd(
     adUnitId: AdManager.interstitialAdUnitId,
     listener: _onInterstitialAdEvent,
   );
   _loadInterstitialAd();
    super.initState();
  }
  void _loadBannerAd() {
    _bannerAd
      ..load()
      ..show(anchorType: AnchorType.bottom);
  }
  getData()async{
    Query query = await Firestore.instance.collection(widget.branch).where('semester',isEqualTo: '1').orderBy('timestamp',descending: true);

    setState(() {
      slides = query
          .snapshots().map((list) => list.documents.map((doc) => doc.data));
    });
  }

  Future<void> getTimeLine() async {
    Query query = await Firestore.instance.collection(widget.branch).where('semester',isEqualTo: '1');
    setState(() {
      slides = query
          .snapshots()
          .map((list) => list.documents.map((doc) => doc.data));
    });
    return;
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
  delete(postId){
    Firestore.instance.collection(widget.branch).document(postId).delete();
  }
  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.lightPrimary,
        centerTitle: true,
        title: Text(widget.branch,style: TextStyle(color: Colors.white),),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection(widget.branch).where('semester',isEqualTo: widget.semester).orderBy("timestamp",descending: true).snapshots(),

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

                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data.documents.length,
                  shrinkWrap: true,
                  itemBuilder: (context, int index) {

                    final DocumentSnapshot document =
                    snapshot.data.documents[index];



                    return Center(
                      child: GestureDetector(
                        onLongPress: (){
                          delete(document["postID"]);
                          
                        },
                        onTap: (){
                          if (_isInterstitialAdReady) {
                            _interstitialAd.show();
                          }else{
                            _loadInterstitialAd();
                          }

                          Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child:PDFView(url: document["pdfurl"],subject: document["title"],dynamiclink: document["dynamiclink"],)));

                        },
                        child: CourseCard(
                          document["title"], "24", document["thumbnail"],document["timestamp"]
                    ),
                      ));
                  },
                ),
              );
          }
        },

      ),
    );

  }
}
