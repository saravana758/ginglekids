import 'package:flutter/material.dart';

import 'Event_Screen.dart';

class EventDetailsScreen extends StatelessWidget {
  final String eventName;
  final String eventDate;
  final String eventDescription;
  final String evenendDate;
  final String name;
  final String token;
  final String role;

  EventDetailsScreen(
      {required this.eventName,
      required this.eventDate,
      required this.eventDescription,
      required this.evenendDate,
      required this.name,
      required this.role,
      required this.token});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
        onWillPop: () async {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  EventScreen(
                token: token,
                name: name,
                role: role,
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(-1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end).chain(
                  CurveTween(curve: curve),
                );
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );

          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Event Details',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            backgroundColor: Color(0xFF8779A6),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: MediaQuery.of(context).size.width * 0.07,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        EventScreen(
                      token: token,
                      name: name,
                      role: role,
                    ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(-1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;
                      var tween = Tween(begin: begin, end: end).chain(
                        CurveTween(curve: curve),
                      );
                      var offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
          ),
          body:  GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              // Swiped from left to right
              Navigator.pop(context);
            }
          },
          child:Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eventName,
                      style: TextStyle(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF484058),
                        fontFamily: 'Poppins',
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.03),
                      child: Text(
                        'Description',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF626262),
                          fontFamily: 'Poppins',
                          fontStyle: FontStyle.normal,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Divider(
                      color: Color(0xFF999999),
                      thickness: 1,
                      indent: 10,
                      endIndent: 10,
                    ),
                    SizedBox(height: screenWidth * 0.04),
                    Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.03),
                      child: Text(
                        eventDescription,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Color(0xFF463866),
                          fontFamily: 'Poppins',
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.03),
                      child: Text(
                        'Hold at',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF626262),
                          fontFamily: 'Poppins',
                          fontStyle: FontStyle.normal,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Divider(
                      color: Color(0xFF999999),
                      thickness: 1,
                      indent: 10,
                      endIndent: 10,
                    ),
                    SizedBox(height: screenWidth * 0.04),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: screenWidth * 0.03),
                          child: Text(
                            "From : ",
                            style: TextStyle(
                              color: Color(0xFF636363),
                              fontFamily: 'Poppins',
                              fontSize: screenWidth * 0.04,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Text(
                          "$eventDate",
                          style: TextStyle(
                            color: Color(0xFF636363),
                            fontFamily: 'Poppins',
                            fontSize: 16.0,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(
                          width: screenWidth * 0.2,
                        ),
                        Text(
                          "To : ",
                          style: TextStyle(
                            color: Color(0xFF636363),
                            fontFamily: 'Poppins',
                            fontSize: screenWidth * 0.04,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "$evenendDate",
                          style: TextStyle(
                            color: Color(0xFF636363),
                            fontFamily: 'Poppins',
                            fontSize: 16.0,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: screenWidth * 0.02,
                left: 0,
                right: 0,
                child: Container(
                  height: screenHeight * 0.3,
                  child: Image.asset(
                    'assets/images/event.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        )));
  }
}
