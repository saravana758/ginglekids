 import 'package:flutter/material.dart';

// class CustomPostContainer extends StatelessWidget {
//   final String buttonText;
//   final VoidCallback onPressed;

//   const CustomPostContainer({
//     required Key key,
//     this.buttonText = 'Post',
//     required this.onPressed,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 199,
//       height: 69,
//       decoration: BoxDecoration(
//         color: Colors.black,
//         borderRadius: BorderRadius.circular(50),
//         gradient: LinearGradient(
//           colors: [Color(0xFF8779A6), Color(0xFF8779A6)],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(50),
//           onTap: onPressed,
//           child: Center(
//             child: Text(
//               buttonText,
//               style: TextStyle(
//                 color: Color(0xFFFFFFFF), // White color
//                 fontFamily: "Inter",
//                 fontSize: 28,
//                 fontWeight: FontWeight.w600,
//                 fontStyle: FontStyle.normal,
//                 letterSpacing: 0.28,
//                 height: 0.78571, // Equivalent to 22px based on font size 28px
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final BoxDecoration? decoration;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.decoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onPressed,
      child: Container(
        width: screenWidth * 0.40,
        height: screenHeight * 0.06,
        decoration: decoration ?? defaultDecoration(),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Inter",
              fontSize: screenWidth * 0.08,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.28,
              height: 22 / 28,
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration defaultDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(50),
      color: Color.fromRGBO(135, 121, 166, 1),
    );
  }
}

