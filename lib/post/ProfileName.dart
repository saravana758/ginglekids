import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ProfileNameWidget extends StatefulWidget {
  final String token;
  final String name;

  ProfileNameWidget({required this.token,required this.name});

  @override
  _ProfileNameWidgetState createState() => _ProfileNameWidgetState();
}

class _ProfileNameWidgetState extends State<ProfileNameWidget> {
  bool hasData = false;
String? imageUrl;
  @override
  void initState() {
    super.initState();
    fetchData(widget.token);
  }
  Future<void> fetchData(String token) async {
  try {
    var response = await http.get(
      Uri.parse('https://bob-magickids.trainingzone.in/api/General/postview'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      if (data['post'].isEmpty) {
        setState(() {
          hasData = false;
        });
      } else {
        setState(() {
          hasData = true;
          // Accessing imageUrl asynchronously
          imageUrl = 'https://bob-magickids.trainingzone.in/teacher/${data['post'][0]['created_by']['teacher']['hashid']}/teacher-images';
        });
      }
    } else {
      print('Failed to fetch data: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception during data fetching: $e');
  }
}


  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
    child: Row(
      children: [
        SizedBox(
          width: screenWidth * 0.11,
          height: screenWidth * 0.11,
          child: Container(
           
            child: ClipOval(
              child: imageUrl != null 
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    width: screenHeight * 0.06,
                    height: screenHeight * 0.06,
                  )
                : Container(), // Placeholder when imageUrl is null
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.02), // Adding spacing between circle and text
        Text(
          widget.name,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: screenWidth * 0.062,
            fontWeight: FontWeight.w600,
            color: Colors.black, // Assuming black text color
            height: 1.2267, // Calculated line height for consistent spacing
            letterSpacing: 0.24,
          ),
        ),
        SizedBox(width: screenWidth * 0.01),
        Text(
          "(Teacher)",
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize:screenWidth * 0.044,
            fontWeight: FontWeight.w500,
            color: Color(
                0xFF999999), // Using the specified gray color or fallback to black
            height: 1.2267, // Calculated line height for consistent spacing
            letterSpacing: 0.18,
          ),
        ),
      ],
    ),
  );
}
}