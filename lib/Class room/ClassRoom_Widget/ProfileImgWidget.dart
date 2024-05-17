import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  final String? hashid; // Add hashid parameter

  const ProfileImage({Key? key, this.hashid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    print(hashid);
    return Container(
      height: screenWidth * 0.3,
      width: screenWidth * 0.3,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 248, 247, 245),
        shape: BoxShape.circle,
      ),
      child:ClipOval(
  child: Image.network(
    'https://bob-magickids.trainingzone.in/student/$hashid/student-images',
    fit: BoxFit.contain,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) {
        // Image is loaded successfully
        return child;
      } else {
        // Image is still loading, you can show a placeholder or loading indicator here
        return CircularProgressIndicator();
      }
    },
    errorBuilder: (context, error, stackTrace) {
      // Error occurred while loading image, you can show an error message or placeholder here
      return Icon(Icons.person,size: screenWidth*0.2,color: Color(0xFF8779A6),);
    },
  ),
)

    );
  }
}

class NameWidget extends StatelessWidget {
  final String text;

  NameWidget({required this.text});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black, // Use black color
          fontFamily: 'Poppins',
          fontSize: screenWidth * 0.06,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w700,
          letterSpacing: 5,
          // Line height might not be needed here, as it's calculated automatically
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class classwidget extends StatelessWidget {
  final String text;
  classwidget({required this.text});
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      alignment: Alignment.center,
      child: Text(
        text, // Add your blue text here
        style: TextStyle(
          color: Colors.blue, // Use blue color
          fontFamily: 'Poppins',
          fontSize: screenWidth * 0.05,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w500,
          letterSpacing: 1,
          // Line height might not be needed here, as it's calculated automatically
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
