import 'package:flutter/material.dart';
import 'package:gingle_kids/Payment/Payment_method.dart';
import 'package:gingle_kids/teacher_dashboard.dart';

class PaymentPage extends StatefulWidget {
  final String token;
  final String name;
  final String role;
  const PaymentPage(
      {required this.token, required this.name, required this.role});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment Details',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            fontStyle: FontStyle.normal,
            height: 1,
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
                builder: (context) => TeacherDashboard(
                  token: widget.token,
                  name: widget.name,
                  role: widget.role,
                ),
              ),
            );
          },
        ),
      ),
      body: ListView(
        children: [
          PaymentCard(
            title: 'Midterm Fees',
            due_date: 'Due date - 12/03/2024',
            additionalText: 'Balance Amount -',
            amount: '\$1000', // Example amount, you can replace with dynamic data
            onPressed: () {
              // Handle payment for midterm fees
            },
          ),
          PaymentCard(
            title: 'Second Midterm Fees',
            due_date: 'Due date - 10/02/2024',

            additionalText: 'Balance Amount -',

            amount: '\$1500', // Example amount, you can replace with dynamic data
            onPressed: () {
              // Handle payment for second midterm fees
            },
          ),
          PaymentCard(
            title: 'Annual Fees',
            due_date: 'Due date - 15/08/2024',

            additionalText: 'Balance Amount -',

            amount: '\$2000', // Example amount, you can replace with dynamic data
            onPressed: () {
              // Handle payment for annual fees
            },
          ),
          PaymentCard(
            title: 'Exam Fees',
            due_date: 'Due date - 20/01/2024',

            additionalText: 'Balance Amount -',

            amount: '\$1200', // Example amount, you can replace with dynamic data
            onPressed: () {
              // Handle payment for exam fees
            },
          ),
          PaymentCard(
            title: 'Events Fees',
            due_date: 'Due date - 19/06/2024',

            additionalText: 'Balance Amount -',

            amount: '\$800', // Example amount, you can replace with dynamic data
            onPressed: () {
              // Handle payment for events fees
            },
          ),
        ],
      ),
    );
  }
}

class PaymentCard extends StatelessWidget {
  final String title;
  final String amount;
  final String due_date; // Add this line
   // final String trailingText; // Add this line

  final String additionalText; // Add this line
  final VoidCallback onPressed;

  const PaymentCard({
    Key? key,
    required this.title,
    required this.amount,
    required this.due_date, 
       // required this.trailingText, // Add this line
// Add this line
    required this.additionalText, // Add this line
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(
            color: Colors.grey, width: 2.0), // Set border color and width
        borderRadius: BorderRadius.circular(8.0), // Set border radius
      ),
       child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Color(0xFF000000),
                fontFamily: 'Poppins',
                fontSize: MediaQuery.of(context).size.width * 0.05,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w500,
                height: 1.1,
                letterSpacing: 2.0,
              ),
            ),
             Text(
              amount,
              style: TextStyle(
                color: Color.fromARGB(255, 19, 170, 42),
                fontFamily: 'Poppins',
                fontSize: 18,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w600,
                height: 2.1,
                letterSpacing: 2.0,
              ),
            ),
           
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              due_date,
              style: TextStyle(
                color: Color(0xFF000000),
                fontFamily: 'Poppins',
                fontSize: 16,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w400,
                height: 2.1,
                letterSpacing: 2.0,
              ),
            ),
            Text(
              additionalText,
              style: TextStyle(
                color: Color(0xFF000000),
                fontFamily: 'Poppins',
                fontSize: 16,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w400,
                height: 1.1,
                letterSpacing: 2.0,
              ),
            ),
          // Add some space between subtitle and additional text
            Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [

                Text(
                  amount, // Display the amount
                  // Additional text below the subtitle
                  style: TextStyle(
                    color: Color.fromARGB(255, 228, 18, 18),
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w400,
                    height: 1.1,
                    letterSpacing: 1.5,
                  ),
                ),
                 ElevatedButton(
 onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentMethodPage(),
              ),
            );
          },              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Color.fromARGB(255, 96, 231, 100),
                ),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
              ),
              child: Text(
                'Pay',
                style: TextStyle(
                  color: Color(0xFF000000),
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w400,
                  height: 1.1,
                  letterSpacing: 0.5,
                ),
              ),
            ),
              ],
            ),
            // SizedBox(
            //   height: 10,
            // ),
          ],
        ),
      

      
      
      
       )   );
  }
}
