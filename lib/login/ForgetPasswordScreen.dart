import 'package:flutter/material.dart';
import 'package:gingle_kids/login/login_screen.dart';

class ForgetPasswordScreen extends StatefulWidget {
  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  bool emailSent = false;
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Forget Password',
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
              MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20.0),
            Text(
              emailSent
                  ? 'Enter the OTP sent to your email'
                  : 'Enter your email to reset your password',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            if (!emailSent) ...[
              Form(
                key: _emailFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                                r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null; // Return null if validation passes
                      },
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_emailFormKey.currentState!.validate()) {
                          setState(() {
                            emailSent = true;
                          });
                          // Add logic to send reset password link here
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Color(0xFF8779A6)),
                        minimumSize: MaterialStateProperty.all<Size>(
                            Size(200.0, 50.0)), // Decrease the width to 200.0
                      ),
                      child: Text(
                        'Send',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
            if (emailSent) ...[
              Text(
                'Email: ${_emailController.text}',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  6,
                  (index) => Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 7.0), // Add spacing between boxes
                    child: SizedBox(
                      width: 40.0,
                      height: 40.0,
                      child: TextFormField(
                        controller: index == 0 ? _otpController : null,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          counterText: "", // Hide character count
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            if (index < 5) {
                              // Move focus to the next TextFormField
                              FocusScope.of(context).nextFocus();
                            } else {
                              // Last box, perform final actions if needed
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResetPasswordScreen(),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xFF8779A6)),
                  minimumSize: MaterialStateProperty.all<Size>(
                      Size(200.0, 50.0)), // Decrease the width to 200.0
                ),
                child: Text(
                  'Verify',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              )
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}

class ResetPasswordScreen extends StatelessWidget {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reset Password',
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
              MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirm New Password'),
              obscureText: true,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Add logic to reset the password
              },
               style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xFF8779A6)),
                  minimumSize: MaterialStateProperty.all<Size>(
                      Size(200.0, 50.0)), // Decrease the width to 200.0
                ),
                child: Text(
                  'Reset Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              )
            
          ],
        ),
      ),
    );
  }
}
