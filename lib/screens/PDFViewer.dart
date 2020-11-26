import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutterfire/utils/constants.dart';

void main() => runApp(PDFView());

class PDFView extends StatefulWidget {
  final String url;
  final String subject;
  final String dynamiclink;
  PDFView({this.url,this.subject,this.dynamiclink});
  @override
  _PDFViewState createState() => _PDFViewState();
}

class _PDFViewState extends State<PDFView> {
  bool _isLoading = true;
  PDFDocument document;

  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  loadDocument() async {
    document = await PDFDocument.fromURL(
        widget.url);

    setState(() => _isLoading = false);
  }
@override
  void dispose() {

    super.dispose();
  }
  Future<void> share() async {
    await FlutterShare.share(
        title: widget.subject,
        text: "${widget.subject} PDF Notes",
        linkUrl: widget.dynamiclink,
        chooserTitle: 'Polynotes');


  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Constants.lightPrimary,
        centerTitle: true,
        title: Text(widget.subject!=null?widget.subject:"",style: TextStyle(color: Colors.white),),
        actions: [
          GestureDetector(
            onTap: (){
            share();
            },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.share_rounded,size: 18,),
              ))
        ],
      )
      ,
        body: Center(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.teal),))
              : PDFViewer(
            document: document,
            zoomSteps: 1,
            //uncomment below line to preload all pages
            lazyLoad: false,
            indicatorBackground: Colors.teal,
            showPicker: true,
            panLimit: 5,
            tooltip: PDFViewerTooltip(
              first: "First",jump: "Jump"
            ),
            // uncomment below line to scroll vertically
            scrollDirection: Axis.vertical,

            //uncomment below code to replace bottom navigation with your own
           navigationBuilder:
                      (context, page, totalPages, jumpToPage, animateToPage) {
                    return ButtonBar(
                      alignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.first_page),
                          onPressed: () {
                            jumpToPage(page: 0);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            animateToPage(page: page - 2);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward),
                          onPressed: () {
                            animateToPage(page: page);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.last_page),
                          onPressed: () {
                            jumpToPage(page: totalPages - 1);
                          },
                        ),
                      ],
                    );
                  },
          ),
        ),

    );
  }
}