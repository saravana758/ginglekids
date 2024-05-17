import 'package:flutter/material.dart';

class CaptionWidget extends StatelessWidget {
    final Function(String) onCaptionChanged;

  CaptionWidget({required this.onCaptionChanged});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
              width: screenWidth * 0.9 ,
              child: Column(
                children: [
                 TextFormField(
  decoration: InputDecoration(
    hintText: 'Add a caption...',
    hintStyle: TextStyle(
      color: Color.fromRGBO(153, 153, 153, 1),
      fontFamily: 'Inter',
      fontSize: screenWidth * 0.05,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    ),
   // contentPadding: EdgeInsets.only(left: screenWidth*0.04,), // Add left padding of 4 pixels
  ),
              onChanged: onCaptionChanged, // Pass entered text to parent widget
//  maxLines: 5,
                      )        ])
);

        
        
  }
}
