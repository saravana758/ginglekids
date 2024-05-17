import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DottedOutlinePainter extends CustomPainter {
    bool showOutline;

  DottedOutlinePainter({required this.showOutline, required bool isVideoSelected});

  @override
  void paint(Canvas canvas, Size size) {
        if (!showOutline) return; 

    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double dashWidth = 5;
    double dashSpace = 5;
    bool isPaintingLine = true;

    // Draw top border
    for (double i = 0; i < size.width; i += dashWidth + dashSpace) {
      if (isPaintingLine) {
        canvas.drawLine(Offset(i, 0), Offset(i + dashWidth, 0), paint);
      }
      isPaintingLine = !isPaintingLine;
    }

    // Draw right border
    for (double i = 0; i < size.height; i += dashWidth + dashSpace) {
      if (isPaintingLine) {
        canvas.drawLine(
            Offset(size.width, i), Offset(size.width, i + dashWidth), paint);
      }
      isPaintingLine = !isPaintingLine;
    }

    // Draw bottom border
    for (double i = size.width; i > 0; i -= dashWidth + dashSpace) {
      if (isPaintingLine) {
        canvas.drawLine(
            Offset(i, size.height), Offset(i - dashWidth, size.height), paint);
      }
      isPaintingLine = !isPaintingLine;
    }

    // Draw left border
    for (double i = size.height; i > 0; i -= dashWidth + dashSpace) {
      if (isPaintingLine) {
        canvas.drawLine(Offset(0, i), Offset(0, i - dashWidth), paint);
      }
      isPaintingLine = !isPaintingLine;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class CustomTextStyle extends StatelessWidget {
  final String text;

  const CustomTextStyle({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontFamily: 'Inter',
       // fontSize: 30,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w500,
        height: 1.1,
        letterSpacing: 0.2,
      ),
    );
  }
}


class PlaceholderWidget extends StatefulWidget {
  final String selectedText;
  final Function(XFile?) onImageSelected; // Modify the callback to accept XFile?

    final Function(String?) onDocumentSelected; // Add this line


  const PlaceholderWidget({Key? key, required this.selectedText,
   required this.onImageSelected,
    required this.onDocumentSelected}) 
   : super(key: key);

  @override
  State<PlaceholderWidget> createState() => _PlaceholderWidgetState();
  
}

class _PlaceholderWidgetState extends State<PlaceholderWidget> {
  XFile? _selectedImage; // Declare _selectedImage as a nullable XFile variable
    //final String selectedText;
  String? _selectedDocument; // Declare _selectedDocument as a nullable String variable


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        if (widget.selectedText == 'Img') {
          print('hi'); // Print "hi" when the image icon is clicked
                _showImagePicker(context);
                print('shaky');
                

        }
        if (widget.selectedText == 'Video') {
          print('am invideo'); // Print "hi" when the image icon is clicked
        }
        if (widget.selectedText == 'Doc') {
                    print('am in docs selection'); // Print "hi" when the image icon is clicked

  // Logic to handle document upload
  _selectDocument(context);
}
      },
      
     child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Conditional rendering based on the selected image
          if (_selectedImage != null)
            _buildSelectedImage(_selectedImage!),
          if (_selectedDocument != null)
            _buildSelectedDocument(_selectedDocument!),
          if (_selectedImage == null && _selectedDocument == null )
            Icon(
              getSelectedIcon(widget.selectedText),
              size: screenWidth * 0.2,
              color: const Color.fromRGBO(199, 106, 106, 1),
            ),
             // Render selected  image
          const SizedBox(height: 10),
        //  if (_selectedImage == null)
            Visibility(
                    visible: _selectedImage == null && _selectedDocument == null, 
          child: Text(
            getSelectedMessage(widget.selectedText),
            style: TextStyle(
              color: const Color.fromRGBO(153, 153, 153, 1.0),
              fontSize:screenWidth* 0.05,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.18,
              height: 1.222,
            ),
          ),
        ),

          // if (_selectedImage == null)
          //   ContentInput(
          //     textEditingController: textEditingController,
          //   ),
        ],
      ),
    );
  }
 Future<void> _selectDocument(BuildContext context) async {
  try {
    
    print('Attempting to pick a document file...');
    
    // Use file_picker to select a document file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );


    if (result != null) {
      PlatformFile file = result.files.first;
      // Handle the selected document file (file.path)
      print('Selected document path: ${file.path}');
      setState(() {
          _selectedDocument = file.path;
        });
            widget.onDocumentSelected(_selectedDocument);

      // You can perform further operations like uploading the file here
    } else {
      print('No document file selected.');
    }
  } catch (e) {
    print('Error selecting document file: $e');
    // Handle the error
  }}
Widget _buildSelectedDocument(String documentPath) {
  return Column(
    children: [
      const Text(
        'Selected Document:',
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w300,
        ),
      ),
      const SizedBox(height: 10),
      GestureDetector(
        onTap: () {
          // Handle opening the PDF document here
        },
        child: 
         
            Center(
              child:   Image.asset(
              'assets/images/pdf.png', // Replace 'pdf.png' with the actual file name of your PDF image
              width: 100, // Set the width of the image
              height: 100, // Set the height of the image
            ),
            ),
            
          
        ),
      
    ],
  );
}

 Future<void> _showImagePicker(BuildContext context) async {
  
   final picker = ImagePicker();
    final imageSource = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            
            child: const Text('Gallery'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Camera'),
          ),
        ],
      ),
    );

  if (imageSource != null) {
    final pickedImage = await picker.pickImage(
      source: imageSource,
      maxHeight: 400,
      maxWidth: 400,
      imageQuality: 50,
      preferredCameraDevice: CameraDevice.rear,
    );
    print('Picked image result: $pickedImage');

    if (pickedImage != null) {
  setState(() {
    _selectedImage = XFile(pickedImage.path);
  });
        print('image seletced');

      print(_selectedImage);
        print('Image selected');
      print(_selectedImage);

      // Extracting file name and removing "scaled_"
      String fileName = _selectedImage!.path.split('/').last;
      fileName = fileName.replaceAll('scaled_', '');
      print(fileName);

      print('Selected image path: $fileName'); // Debug print


        print('Selected image path: ${_selectedImage!.path}'); // Debug print

      widget.onImageSelected(_selectedImage);
}
  }
}

Widget _buildSelectedImage(XFile image) {
    if (kIsWeb) {
      // For web, use Image.network instead of Image.file
      return Image.network(
        image.path,
        fit: BoxFit.contain,
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment
                  .topRight, // Align the close icon to the top-right corner
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),

                  // Set the width as needed
                  child: Image.file(
                    File(image.path),
                    height: 200, // Set the height as needed
                    width: 200,
                     fit: BoxFit.cover,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    color: Colors.black.withOpacity(0.3),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24, // Adjust the size of the close icon as needed
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

}
class ContentInput extends StatelessWidget {
  final TextEditingController textEditingController;

  const ContentInput({Key? key, required this.textEditingController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: textEditingController,
        decoration: const InputDecoration(
          hintText: 'Enter your thoughts...',
          border: InputBorder.none,
        ),
        style: TextStyle(
          color: Colors.grey,
          fontSize: screenWidth * 0.05,
        ),
        maxLines: null,
      ),
    );
  }
}

class SelectionBar extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final String selectedText;
  final Function(String) onSelect;
    final Function(bool) onToggleOutline;


  const SelectionBar({
    Key? key,
    required this.screenWidth,
    required this.screenHeight,
    required this.selectedText,
    required this.onSelect,
        required this.onToggleOutline,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: screenHeight * 0.07,
          width: screenWidth * 0.8,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(135, 121, 166, 0.5),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            children: [
              SizedBox(width: screenWidth * 0.03),
              buildCustomTextStyle(
                text: "Img",
                isSelected: selectedText == "Img",
                onSelect: onSelect,
              ),
              SizedBox(width: screenWidth * 0.08),
              buildCustomTextStyle(
                text: "Video",
                isSelected: selectedText == "Video",
                onSelect: onSelect,
              ),
              SizedBox(width: screenWidth * 0.08),
              buildCustomTextStyle(
                text: "Doc",
                isSelected: selectedText == "Doc",
                onSelect: onSelect,
              ),
              SizedBox(width: screenWidth * 0.08),
              buildCustomTextStyle(
                text: "Content",
                isSelected: selectedText == "Content",
                onSelect: onSelect,
              ),
            ],
          ),
        ),
      
    
    // SizedBox(height: screenHeight * 0.02),
    //     Row(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Text(
    //           'Show Outline: ',
    //           style: TextStyle(fontSize: screenWidth * 0.04),
    //         ),
    //         Switch(
    //           value: selectedText == 'Video',
    //           onChanged: onToggleOutline,
    //         ),
    //       ],
    //     ),
      ]
    );
  }

  Widget buildCustomTextStyle({
    required String text,
    required bool isSelected,
    required Function(String) onSelect,
  }) {
    return GestureDetector(
      onTap: () {
        onSelect(text);
      },
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontSize: screenWidth * 0.05,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

String getSelectedMessage(String selectedText) {
  switch (selectedText) {
    case 'Img':
      return 'Choose image to upload';
    case 'Video':
      return 'Choose video to upload';
    case 'Doc':
      return 'Choose doc to upload';
    default:
      return '';
  }
}

IconData getSelectedIcon(String selectedText) {
  switch (selectedText) {
    case 'Img':
      return Icons.image;
    case 'Video':
      return Icons.video_library;
    case 'Doc':
      return Icons.description;
    default:
      return Icons.image;
  }
}
// Function to show image picker options


