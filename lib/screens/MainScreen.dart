import 'package:flutter/material.dart';
import 'package:projek_tpm/screens/pet/pet_list_screen.dart';
import 'package:projek_tpm/screens/notification/notification_screen.dart';
import 'package:projek_tpm/screens/time/time_converter_screen.dart';
import 'package:projek_tpm/screens/currency/currency_converter_screen.dart';
import 'package:projek_tpm/screens/location/location_screen.dart';
import 'package:projek_tpm/screens/sensor/sensor_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      PetListScreen(),
      NotificationScreen(),
      TimeConverterScreen(),
      CurrencyConverterScreen(),
      LocationScreen(),
      SensorScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Pets'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Time'),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Currency',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Location',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.sensors), label: 'Sensor'),
        ],
      ),
    );
  }
}
