import 'dart:async';

import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Screens/PDFViewer.dart';
import 'package:clean_connector/Screens/Site_recommandation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

class ViewRecommendation extends StatefulWidget {
  String id, title, cleaner_title, description, cleaner_des, cleaner_image, url;
  ViewRecommendation(
      {required this.id,
      required this.title,
      required this.cleaner_title,
      required this.description,
      required this.url,
      // required this.cleaner_file_type,
      // required this.rec_file_type,
      required this.cleaner_des,
      required this.cleaner_image});

  @override
  State<ViewRecommendation> createState() => _ViewRecommendationState();
}

class _ViewRecommendationState extends State<ViewRecommendation> {
  bool isLoading = false;
  bool isEmptyList = false;
  final Completer<PDFViewController> _pdfViewController =
      Completer<PDFViewController>();
  final StreamController<String> _pageCountController =
      StreamController<String>();
  String file = '';
  String cleanerFileType = '';
  String recFileType = '';

  @override
  void initState() {
    super.initState();
    isLoading = true;
    loading();
  }

  loading() async {
    if (widget.cleaner_image == "") {
      setState(() {
        cleanerFileType = "No Content";
      });
    } else {
      await getFileTypeFromUrl(widget.cleaner_image);
      setState(() {
        cleanerFileType = file;
      });
    }
    if (widget.url == "") {
      setState(() {
        recFileType = "No Content";
      });
    } else {
      await getFileTypeFromUrl(widget.url);
      setState(() {
        recFileType = file;
      });
    }
    print("ok");
    setState(() {
      isLoading = false;
    });
  }

  Future<String> getFileTypeFromUrl(String fileUrl) async {
    try {
      final response = await http.head(Uri.parse(fileUrl));
      if (response.headers.containsKey('content-type')) {
        String fileType = response.headers['content-type']!;
        print('File type: $fileType');
        if (fileType == "application/pdf") {
          setState(() {
            file = "Pdf";
          });
        } else if (fileType == "image/jpeg" ||
            fileType == "image/png" ||
            fileType == "image/jpg") {
          setState(() {
            file = "Image";
          });
        }
        return response.headers['content-type']!;
      } else {
        // If Content-Type header is not present, you may need to handle this case accordingly.
        return 'Unknown';
      }
    } catch (e) {
      print('Error retrieving file type: $e');
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const SiteRecomondationScreen()),
            (Route<dynamic> route) => false,
          );
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text(
              "SITE RECOMONDATION",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 20, color: kiconColor),
            ),
            backgroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(8.0), // Add rounded corners
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(2, 2),
                          blurRadius: 2,
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.cleaner_title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: kiconColor),
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  " + widget.cleaner_des,
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 15,
                                  color: kiconColor),
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            cleanerFileType == "Pdf"
                                ? Center(
                                    child: Container(
                                      height: 500,
                                      width: MediaQuery.of(context).size.width -
                                          200,
                                      color: Colors.grey[200],
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Stack(
                                          alignment: Alignment.bottomCenter,
                                          children: [
                                            Column(
                                              children: [
                                                Expanded(
                                                  child: PDF(
                                                    enableSwipe: true,
                                                    swipeHorizontal: false,
                                                    autoSpacing: false,
                                                    pageFling: false,
                                                    onPageChanged:
                                                        (int? current,
                                                            int? total) {
                                                      _pageCountController.add(
                                                          '${current! + 1} - $total');
                                                    },
                                                    onViewCreated:
                                                        (PDFViewController
                                                            pdfViewController) async {
                                                      _pdfViewController
                                                          .complete(
                                                              pdfViewController);
                                                      final int currentPage =
                                                          await pdfViewController
                                                                  .getCurrentPage() ??
                                                              0;
                                                      final int? pageCount =
                                                          await pdfViewController
                                                              .getPageCount();
                                                      _pageCountController.add(
                                                          '${currentPage + 1} - $pageCount');
                                                    },
                                                  ).fromUrl(
                                                      widget.cleaner_image),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              height: 50,
                                              color: Colors.grey[200],
                                              child: Center(
                                                child: TextButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute<
                                                                dynamic>(
                                                            builder: (_) =>
                                                                PDFViewer(
                                                                    pdfAssetPath:
                                                                        widget
                                                                            .cleaner_image)),
                                                      );
                                                    },
                                                    child: const Text(
                                                        "Read full document")),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      //child: Image(image: NetworkImage(widget.url))),
                                    ),
                                  )
                                : cleanerFileType == "Image"
                                    ? Center(
                                        child: Container(
                                            height: 300,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                200,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.grey[200],
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Image(
                                                image: NetworkImage(
                                                    widget.cleaner_image),
                                                fit: BoxFit.cover,
                                              ),
                                            )),
                                      )
                                    : (cleanerFileType == "No Content")
                                        ? const SizedBox()
                                        : (isLoading == true)
                                            ? const Padding(
                                                padding:
                                                    EdgeInsets.only(left: 20.0),
                                                child: SpinKitDualRing(
                                                  color: kiconColor,
                                                  size: 30,
                                                ),
                                              )
                                            : Center(
                                                child: Container(
                                                  height: 50,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      200,
                                                  color: Colors.grey[200],
                                                  child: const Center(
                                                      child: Text(
                                                    "Unsupported file type",
                                                    textAlign: TextAlign.center,
                                                  )),
                                                ),
                                              ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 20.0, bottom: 20.0),
                              child: Divider(
                                thickness: 5,
                                color: Colors.grey[200],
                              ),
                            ),
                            const Text(
                              "Admin\'s Recommendation",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  color: kiconColor),
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              widget.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: kiconColor),
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "  " + widget.description,
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 15,
                                  color: kiconColor),
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            recFileType == "Pdf"
                                ? Center(
                                    child: Container(
                                      height: 500,
                                      width: MediaQuery.of(context).size.width -
                                          200,
                                      color: Colors.grey[200],
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Stack(
                                          alignment: Alignment.bottomCenter,
                                          children: [
                                            Column(
                                              children: [
                                                Expanded(
                                                  child: PDF(
                                                    enableSwipe: true,
                                                    swipeHorizontal: false,
                                                    autoSpacing: false,
                                                    pageFling: false,
                                                    onPageChanged:
                                                        (int? current,
                                                            int? total) {
                                                      _pageCountController.add(
                                                          '${current! + 1} - $total');
                                                    },
                                                    onViewCreated:
                                                        (PDFViewController
                                                            pdfViewController) async {
                                                      _pdfViewController
                                                          .complete(
                                                              pdfViewController);
                                                      final int currentPage =
                                                          await pdfViewController
                                                                  .getCurrentPage() ??
                                                              0;
                                                      final int? pageCount =
                                                          await pdfViewController
                                                              .getPageCount();
                                                      _pageCountController.add(
                                                          '${currentPage + 1} - $pageCount');
                                                    },
                                                  ).fromUrl(widget.url),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              height: 50,
                                              color: Colors.grey[200],
                                              child: Center(
                                                child: TextButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute<
                                                                dynamic>(
                                                            builder: (_) =>
                                                                PDFViewer(
                                                                    pdfAssetPath:
                                                                        widget
                                                                            .url)),
                                                      );
                                                    },
                                                    child: const Text(
                                                        "Read full document")),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      //child: Image(image: NetworkImage(widget.url))),
                                    ),
                                  )
                                : recFileType == "Image"
                                    ? Center(
                                        child: Container(
                                            height: 300,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                200,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.grey[200],
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Image(
                                                image: NetworkImage(widget.url),
                                                fit: BoxFit.cover,
                                              ),
                                            )),
                                      )
                                    : (cleanerFileType == "No Content")
                                        ? const SizedBox()
                                        : (isLoading == true)
                                            ? const Padding(
                                                padding:
                                                    EdgeInsets.only(left: 20.0),
                                                child: SpinKitDualRing(
                                                  color: kiconColor,
                                                  size: 30,
                                                ),
                                              )
                                            : Center(
                                                child: Container(
                                                  height: 50,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      200,
                                                  color: Colors.grey[200],
                                                  child: const Center(
                                                      child: Text(
                                                    "Unsupported file type",
                                                    textAlign: TextAlign.center,
                                                  )),
                                                ),
                                              ),
                          ],
                        ),
                      ),
                    ),
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
