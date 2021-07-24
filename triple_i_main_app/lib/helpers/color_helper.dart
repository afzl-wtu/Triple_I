import 'package:flutter/material.dart';

Color determineColorBasedOnChange(double change) {
  return change < 0 ? Colors.red : Colors.green;
}

TextStyle determineTextStyleBasedOnChange(double change) {
  return change < 0 ? kNegativeChange : kPositiveChange;
}

const TextStyle kPositiveChange = const TextStyle(
    color: Colors.green, fontSize: 16, fontWeight: FontWeight.w800);

const TextStyle kNegativeChange = const TextStyle(
    color: Colors.red, fontSize: 16, fontWeight: FontWeight.w800);
