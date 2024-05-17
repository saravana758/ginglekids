import 'package:flutter/material.dart';

class LikeButtonWidget extends StatefulWidget {
  final Function(bool likeStatus, bool commentStatus) onStatusChanged;

  LikeButtonWidget({required this.onStatusChanged});

  @override
  _LikeButtonWidgetState createState() => _LikeButtonWidgetState();
}

class _LikeButtonWidgetState extends State<LikeButtonWidget> {

  bool firstSwitch = false;
  bool secondSwitch = false;
  
  // Method to invoke the onStatusChanged callback with the current switch statuses
  void _updateStatus() {
    widget.onStatusChanged(firstSwitch, secondSwitch);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.thumb_up_off_alt,
              size: screenWidth * 0.1,
            ),
            onPressed: () {
              firstSwitch = !firstSwitch; // Toggle the like switch status
              _updateStatus(); // Invoke the callback to print the status
            },
          ),
          SizedBox(width: screenWidth * 0.02),
          Switch(
            value: firstSwitch,
            onChanged: (value) {
              setState(() {
                firstSwitch = value;
                if (value && !secondSwitch) {
                  secondSwitch = true;
                }
              });
          widget.onStatusChanged(firstSwitch, secondSwitch);
              print('Like Switch clicked: $firstSwitch');
            },
          ),
          SizedBox(width: screenWidth * 0.18),
          Switch(
            value: secondSwitch,
            onChanged: (value) {
              setState(() {
                secondSwitch = value;
                if (value && !firstSwitch) {
                  firstSwitch = true;
                }
              });
          widget.onStatusChanged(firstSwitch, secondSwitch);
              print('Comment Switch clicked: $secondSwitch');
            },
          ),
          SizedBox(width: screenWidth * 0.02),
          IconButton(
            icon: Icon(
              Icons.comment,
              size: screenWidth * 0.1,
            ),
            onPressed: () {
              secondSwitch = !secondSwitch; // Toggle the comment switch status
              _updateStatus(); // Invoke the callback to print the status
              print('Comment Switch clicked: $secondSwitch');
            },
          ),
        ],
      ),
    );
  }
}
