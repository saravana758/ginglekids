import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class ImageWithDownloadButton extends StatefulWidget {
  @override
  _ImageWithDownloadButtonState createState() =>
      _ImageWithDownloadButtonState();
}

class _ImageWithDownloadButtonState extends State<ImageWithDownloadButton> {
  TextEditingController _urlController = TextEditingController();

  String sanitizeFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[^\w\s.]+'), '');
  }

  Future<void> _downloadImage() async {
    String imageUrl = _urlController.text;

    if (imageUrl.isEmpty) {
      _showUrlError();
      return;
    }

    // Check if permission is already granted or if a permission request is ongoing
    if (await Permission.storage.status.isGranted) {
      // Permission already granted, proceed with image download
      _performImageDownload(imageUrl);
    } else if (await Permission.storage.status.isDenied ||
        await Permission.storage.status.isPermanentlyDenied) {
      // Permission is denied, show a dialog or request the permission
      await _requestStoragePermission(imageUrl);
    }
    // If the permission is already requested and in progress, do nothing for now
  }

  Future<void> _requestStoragePermission(String imageUrl) async {
    // Request storage permission
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      // Permission granted, proceed with image download
      _performImageDownload(imageUrl);
    } else if (status.isDenied || status.isPermanentlyDenied) {
      // Handle the case if the permission is not granted
      _showPermissionError();
    }
  }

  void _showPermissionError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Storage permission is required to download the image.'),
      ),
    );
  }

  void _showUrlError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please enter a valid image URL.'),
      ),
    );
  }

  Future<void> _performImageDownload(String imageUrl) async {
  try {
    var response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      List<int> bytes = response.bodyBytes;

      final Directory? downloadsDirectory = await getDownloadsDirectory();

      if (downloadsDirectory != null) {
        final String dir = downloadsDirectory.path;
        final String fileName = sanitizeFileName(imageUrl.split('/').last);
        final String path = '$dir/$fileName';

        File file = File(path);
        await file.writeAsBytes(bytes);

        print('Download successfully. Image saved to: $path');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image downloaded to $path'),
          ),
        );
      } else {
        print('Error: Downloads directory is null.');
      }
    } else {
      print('Error downloading image. Status code: ${response.statusCode}');
    }
  } catch (e, stackTrace) {
    print('Error downloading image: $e');
    print('Stack trace: $stackTrace');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error downloading image. Please try again. Error: $e'),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Download Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Image URL',
                hintText: 'Enter image URL',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _downloadImage,
              icon: Icon(Icons.download),
              label: Text('Download Image'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: ImageWithDownloadButton(),
    ),
  );
}
