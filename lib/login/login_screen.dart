import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:gingle_kids/teacher_dashboard.dart';

import 'ForgetPasswordScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;
  String _emailError = '';
  String _passwordError = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _emailError = '';
      _passwordError = '';
    });

    var email = emailController.text.trim();
    var password = passwordController.text.trim();

    bool isValidEmail =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

    if (!isValidEmail) {
      setState(() {
        _emailError = 'Invalid email address';
      });
    }

    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Please enter your password';
      });
    }

    // If both email and password are empty, display both error messages
    if (email.isEmpty && password.isEmpty) {
      setState(() {
        _emailError = 'Please enter your email';
        _passwordError = 'Please enter your password';
      });
      return;
    }

    if (_emailError.isNotEmpty || _passwordError.isNotEmpty) {
      // If there are any errors, return without attempting sign-in
      return;
    }

    var headers = {'Content-Type': 'application/json'};
    var requestBody = json.encode({"email": email, "password": password});
    var response = await http.post(
      Uri.parse('https://bob-magickids.trainingzone.in/api/login'),
      headers: headers,
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print(responseData);
      final String token = responseData['data']['token'];
      final String name = responseData['data']['name'];
       final String role = responseData['data']['role'];



      final storage = const FlutterSecureStorage();
      await storage.write(key: 'token', value: token);
      await storage.write(key: 'name', value: name);
      await storage.write(key: 'role', value: role);


      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TeacherDashboard(
            token: token,
            name: name,
            role: role
          ),
        ),
      );

      print('API Response: $responseData');
    } else {
      final responseData = json.decode(response.body);
      if (responseData.containsKey('errors')) {
        setState(() {
          if (responseData['errors'].containsKey('email')) {
            _emailError = 'Invalid email address';
          }
          if (responseData['errors'].containsKey('password')) {
            _passwordError = responseData['errors']['password'][0];
            if (_emailError.isNotEmpty) {
              _passwordError = '$_passwordError (SMS text: Invalid password)';
            } else {
              _passwordError = '$_passwordError (SMS text: Invalid Password)';
            }
          }
        });
      } else {
        setState(() {
          _passwordError = 'Invalid Email Id or Password'; 
        });
      }
    }

    print('Email: $email');
    print('Password: $password');
    print(_passwordError);
  }

  Widget _buildBouncingAsset(
      String imagePath, double top, double left, double width, double height) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: top + 10 * _controller.value,
          left: left,
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: width,
            height: height,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(19, 70, 18, 40),
              width: double.infinity,
              color: Colors.white,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 0.7 * MediaQuery.of(context).size.width,
                  height: 0.15 * MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/log1.png'),
                      fit: BoxFit.fill,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            SizedBox(height: 5),
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/img2.png',
                    fit: BoxFit.fill,
                  ),
                ),
                _buildBouncingAsset('assets/images/bag.png', 95, 0, 64, 55),
                _buildBouncingAsset('assets/images/globe.png', 20,
                    0.853 * MediaQuery.of(context).size.width, 60, 100),
                _buildBouncingAsset('assets/images/note.png', 50,
                    0.540 * MediaQuery.of(context).size.width, 65, 63),
                _buildBouncingAsset(
                    'assets/images/pencil.png',
                    0.550 * MediaQuery.of(context).size.height,
                    20,
                    65,
                    62),
                _buildBouncingAsset(
                    'assets/images/num.png',
                    0.550 * MediaQuery.of(context).size.height,
                    0.38 * MediaQuery.of(context).size.width,
                    150,
                    62),
                Positioned(
                  top: 0.252 * MediaQuery.of(context).size.width,
                  left: 0.3 * MediaQuery.of(context).size.width,
                  child: Container(
                    child: Center(
                      child: Text(
                        'Login Here',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: MediaQuery.of(context).size.width * 0.06,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0.430 * MediaQuery.of(context).size.width,
                  left: 0.1 * MediaQuery.of(context).size.width,
                  child: Container(
                    width: 0.8 * MediaQuery.of(context).size.width,
                    height: 0.11 * MediaQuery.of(context).size.height,
                    child: TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Enter Mail ID',
                        errorText: _emailError.isNotEmpty ? _emailError : null,
                        errorStyle: TextStyle(color: Colors.transparent),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 16.0),
                        suffixIcon: Icon(
                          Icons.mail,
                          color: Colors.grey,
                          size: MediaQuery.of(context).size.width * 0.080,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0.555 * MediaQuery.of(context).size.width,
                  left: 0.14 * MediaQuery.of(context).size.width,
                  child: Text(
                    _emailError.isNotEmpty ? '$_emailError' : '',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 248, 247, 247),
                      fontSize: 0.04 * MediaQuery.of(context).size.width,
                    ),
                  ),
                ),
                Positioned(
                  top: 0.62 * MediaQuery.of(context).size.width,
                  left: 0.1 * MediaQuery.of(context).size.width,
                  child: Container(
                    width: 0.8 * MediaQuery.of(context).size.width,
                    height: 0.11 * MediaQuery.of(context).size.height,
                    child: TextField(
                      controller: passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Enter Password',
                        errorText:
                            _passwordError.isNotEmpty ? _passwordError : null,
                        errorStyle: TextStyle(color: Colors.transparent, fontSize: 14),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 16.0),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                            size: MediaQuery.of(context).size.width * 0.080,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0.75 * MediaQuery.of(context).size.width,
                  left: 0.14 * MediaQuery.of(context).size.width,
                  child: Text(
                    _passwordError.isNotEmpty ? '$_passwordError' : '',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 248, 247, 247),
                      fontSize: 0.04 * MediaQuery.of(context).size.width,
                    ),
                  ),
                ),
                Positioned(
                  top: 0.8 * MediaQuery.of(context).size.width,
                  left: 0.1 * MediaQuery.of(context).size.width,
                  child: Container(
                    width: 0.8 * MediaQuery.of(context).size.width,
                    height: 0.061 * MediaQuery.of(context).size.height,
                    child: ElevatedButton(
                      onPressed: () {
                        _signIn();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: MediaQuery.of(context).size.width * 0.06,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
  top: 0.95 * MediaQuery.of(context).size.width,
  left: 0.57 * MediaQuery.of(context).size.width,
  child: GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ForgetPasswordScreen()),
      );
    },
    child: Container(
      child: Text(
        'Forgot Password?',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Poppins',
          fontSize: MediaQuery.of(context).size.width * 0.04,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  ),
),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
