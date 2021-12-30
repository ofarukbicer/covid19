import 'package:flutter/material.dart';

class CountryInformation {
  final String flag;
  final String countryName;
  final String confirmedCount;
  final String deathCount;
  final String recovryCount;
  final Color labelColor;

  CountryInformation({
    required this.flag,
    required this.countryName,
    required this.confirmedCount,
    required this.deathCount,
    required this.recovryCount,
    required this.labelColor,
  });
}
