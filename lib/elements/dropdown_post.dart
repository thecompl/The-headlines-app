
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// String dropdownValue = 'Select Category';
//
// @override
// Widget build(BuildContext context) {
//   return DropdownButton<String>(
//     value: dropdownValue,
//     icon: const Icon(Icons.arrow_downward),
//     iconSize: 24,
//     elevation: 16,
//     style: const TextStyle(
//         color: Colors.deepPurple
//     ),
//     underline:  Container(
//       height: 2,
//       color: Colors.deepPurpleAccent,
//     ),
//     onChanged: (newValue) => (() {
//         dropdownValue = newValue;
//       }),
//     items: <String>['Select Category','Sports','Bollywood','Politics','Career']
//         .map<DropdownMenuItem<String>>((String value) {
//       return DropdownMenuItem<String>(
//         value: value,
//         child: Text(value,),
//       );
//     })
//         .toList(),
//   );
// }