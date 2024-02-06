import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'dart:async';

import '../Constant/style.dart';


class PDFViewer extends StatefulWidget {
  PDFViewer({Key? key, required this.pdfAssetPath}) : super(key: key);
  final String pdfAssetPath;

  @override
  _PDFViewerState createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {

  @override
  void initState() {
    print("Open pdf");
    super.initState();
  }


  final Completer<PDFViewController> _pdfViewController =
      Completer<PDFViewController>();
  final StreamController<String> _pageCountController =
      StreamController<String>();

  bool _isLastPage = false;
  bool _isAgreed = false;


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PDF View', style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: kiconColor)),
          centerTitle: true,
          backgroundColor: Colors.white,
          actions: <Widget>[
            StreamBuilder<String>(
                stream: _pageCountController.stream,
                builder: (_, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasData) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        // decoration: BoxDecoration(
                        //   shape: BoxShape.circle,
                        //   border: Border.all(width: 1, color: kiconColor),
                        //   color: Colors.white,
                        // ),
                        child: Text(snapshot.data!, style: TextStyle(color: kiconColor),),
                      ),
                    );
                  }
                  return const SizedBox();
                }),
          ],
            leading: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: kiconColor,
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.arrow_back,
                      color: kiconColor,
                    ),
                  ),
                )
              ),
            )
        ),
        body: PDF(
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: false,
          pageFling: false,
          onPageChanged: (int? current, int? total) {
            _pageCountController.add('${current! + 1} - $total');
          },
          onViewCreated: (PDFViewController pdfViewController) async {
            _pdfViewController.complete(pdfViewController);
            final int currentPage = await pdfViewController.getCurrentPage() ?? 0;
            final int? pageCount = await pdfViewController.getPageCount();
            _pageCountController.add('${currentPage + 1} - $pageCount');
          },
        ).fromAsset(
        widget.pdfAssetPath,
        errorWidget: (dynamic error) => Center(child: Text(error.toString())),
        ),
      ),
    );
  }
}



