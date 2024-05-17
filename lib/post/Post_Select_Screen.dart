import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Create_Btn.dart';
import 'Post_Screen.dart';

class PostSelect extends StatefulWidget {
  final String token;
  final String name;
  final String role;
  final String classroomName;
  final String commentsurl;

  PostSelect({required this.token, required this.name, required this.role,required this.classroomName,required this.commentsurl});

  @override
  _PostSelectState createState() => _PostSelectState();
}

class _PostSelectState extends State<PostSelect> {
  late Future<List<String>> _classroomNamesFuture;
  List<String> _selectedClassrooms = [];

  Future<List<String>> fetchClassroomNames(String token) async {
    final String apiUrl =
        'https://bob-magickids.trainingzone.in/api/ClassroomStudents/classrooms';

    var headers = {
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(Uri.parse(apiUrl), headers: headers);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var classrooms = data[1].cast<String>();
      return classrooms;
    } else {
      throw Exception('Failed to load classroom names');
    }
  }

  @override
  void initState() {
    super.initState();
    _classroomNamesFuture = fetchClassroomNames(widget.token);
  }

  void _navigateToCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateButton(
          token: widget.token,
          name: widget.name,
          selectedClassrooms: _selectedClassrooms,
          onPressed: () {},
          role: widget.role, classroomName: widget.classroomName, commentsurl: widget.commentsurl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostScreen(
              token: widget.token,
              name: widget.name,
              role: widget.role,
              classroomName: '', commentsurl: '',
            ),
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PostScreen(
                    token: widget.token,
                    name: widget.name,
                    role: widget.role,
                    classroomName: '', commentsurl: widget.commentsurl,
                  ),
                ),
              );
            },
          ),
          title: Text(
            'Post Creation',
            style: TextStyle(
              color: const Color(0xFFFFFFFF),
              fontFamily: 'Poppins',
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          backgroundColor: const Color(0xFF8779A6),
        ),
        body: Stack(
          children: [
            FutureBuilder<List<String>>(
              future: _classroomNamesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return Column(
                    children: [
                      Expanded(
                        child: buildClassroomList(snapshot.data!),
                      ),
                      if (_selectedClassrooms.isNotEmpty)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: screenHeight * 0.1),
                            child: CreateButton(
                              token: widget.token,
                              name: widget.name,
                              selectedClassrooms: _selectedClassrooms,
                              onPressed: _navigateToCreate,
                              role: widget.role, classroomName: widget.classroomName, commentsurl: widget.commentsurl,
                            ),
                          ),
                        ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildClassroomList(List<String> classroomNames) {
    return ListView.builder(
      itemCount: classroomNames.length,
      itemBuilder: (context, index) {
        String classroomName = classroomNames[index];
        bool isSelected = _selectedClassrooms.contains(classroomName);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white),
              boxShadow: [
                const BoxShadow(
                  color: Color.fromARGB(207, 114, 85, 157),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedClassrooms.remove(classroomName);
                  } else {
                    _selectedClassrooms.add(classroomName);
                    print(classroomName); // Print classroom name
                  }
                });
              },
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12.0),
                    child: isSelected
                        ? Icon(
                            Icons.check_box,
                            size: 24,
                            color: Color.fromRGBO(135, 121, 166, 0.5),
                          )
                        : Icon(
                            Icons.check_box_outline_blank,
                            size: 24,
                            color: Color.fromRGBO(135, 121, 166, 0.5),
                          ),
                  ),
                  SizedBox(width: 20),
                  Text(
                    classroomName,
                    style: TextStyle(
                      color: Color(0xFF000000),
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                      fontStyle: FontStyle.normal,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
