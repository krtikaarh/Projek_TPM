import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'dart:async';

import 'screens/pet/pet_list_screen.dart';
import 'screens/notification/notification_screen.dart';
import 'screens/time/time_converter_screen.dart';
import 'screens/currency/currency_converter_screen.dart';
import 'screens/location/location_screen.dart';
import 'screens/sensor/sensor_screen.dart';
import 'screens/login_screen.dart'; 

void main() {
  runApp(PetCareApp());
}

class PetCareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Care Reminder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(), 
      debugShowCheckedModeBanner: false,
    );
  }
}
