// import 'package:flutter/material.dart';

// class SearchResultScreen extends StatelessWidget {
//   final List<String> studentList;
//   final String searchQuery;

//   SearchResultScreen({required this.studentList, required this.searchQuery});

//   @override
//   Widget build(BuildContext context) {
//     // Filter the student list based on the search query
//     List<String> filteredStudents =
//         studentList.where((student) => student.toLowerCase().contains(searchQuery.toLowerCase())).toList();

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Search Results'),
//       ),
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: BoxDecoration(
//           color: Color(0xff8679a5),
//         ),
//         padding: EdgeInsets.all(10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             IconButton(
//               icon: Icon(Icons.arrow_back),
//               color: Colors.white,
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//             ),
//             SizedBox(height: 10),
//             Text(
//               'Search Query: $searchQuery',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//               ),
//             ),
//             SizedBox(height: 10),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: filteredStudents.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(
//                       filteredStudents[index],
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SearchScreen extends StatefulWidget {
//   @override
//   _SearchScreenState createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   TextEditingController _searchController = TextEditingController();
//   String searchQuery = '';
//   List<String> studentList = [
//     'Manoj',
//     'Bala',
//     'Dev',
//     'Anto',
//     'Sha',
//     'Hema',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(() {
//       setState(() {
//         searchQuery = _searchController.text;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Search'),
//       ),
//       body: Container(
//         padding: EdgeInsets.all(8),
//         child: Row(
//           children: [
//             SizedBox(width: 8),
//             Expanded(
//               child: Container(
//                 margin: EdgeInsets.symmetric(vertical: 5),
//                 padding: EdgeInsets.symmetric(horizontal: 10),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(20),
//                   color: Colors.grey[300],
//                 ),
//                 child: Row(
//                   children: [
//                     IconButton(
//                       icon: Icon(
//                         Icons.search,
//                         color: Colors.grey,
//                       ),
//                       onPressed: () {
//                         // Implement search functionality here
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => SearchResultScreen(
//                               studentList: studentList,
//                               searchQuery: searchQuery,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     SizedBox(width: 8),
//                     Expanded(
//                       child: TextField(
//                         controller: _searchController,
//                         style: TextStyle(
//                           fontSize: 17,
//                           color: Colors.black,
//                         ),
//                         decoration: InputDecoration(
//                           hintText: "Search for a student...",
//                           hintStyle: TextStyle(
//                             fontSize: 17,
//                             color: Colors.grey,
//                             fontWeight: FontWeight.w400,
//                           ),
//                           border: InputBorder.none,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// void main() {
//   runApp(MaterialApp(
//     home: SearchScreen(),
//   ));
// }
