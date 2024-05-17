import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PDFViewerPage extends StatefulWidget {
  final String pdfUrl;

  PDFViewerPage({required this.pdfUrl});

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  String? _pdfPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print(widget.pdfUrl);
    _loadPdf();
  }

  Future<void> _loadPdf() async {
  try {
    // Check if the URL is complete
    if (!widget.pdfUrl.startsWith('http')) {
      throw ArgumentError('Invalid PDF URL: Missing protocol and host');
    }

    final response = await http.get(Uri.parse(widget.pdfUrl));
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/document.pdf');
    await file.writeAsBytes(response.bodyBytes);
    if (mounted) {
      setState(() {
        _pdfPath = file.path;
        _isLoading = false;
      });
    }
  } catch (e) {
    print('Error loading PDF: $e');
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

Future<void> _downloadPDF() async {
    // URL of the PDF to download
    String pdfUrl = widget.pdfUrl;

    // Directory where the file will be saved
    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/magickids.pdf';

    // Download the PDF file
    var response = await http.get(Uri.parse(pdfUrl));
    File pdfFile = File(filePath);
    await pdfFile.writeAsBytes(response.bodyBytes);

    // Set _pdfPath to the downloaded file path
    setState(() {
      _pdfPath = filePath;
      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
        actions: <Widget>[
          // IconButton(
          //   icon: Icon(Icons.download),
          //   onPressed: _downloadPDF,
          // ),
        ],
      ),
      
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _pdfPath != null
              ? PDFView(
                  filePath: _pdfPath!,
                )
              : Center(child: Text('Failed to load PDF')),
    );
  }
}
