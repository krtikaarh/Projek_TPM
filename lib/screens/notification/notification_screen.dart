import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Pet {
  final String name;
  final DateTime nextVaccination;
  final DateTime nextBath;

  Pet({
    required this.name,
    required this.nextVaccination,
    required this.nextBath,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      name: json['name'],
      nextVaccination: DateTime.parse(json['nextVaccination']),
      nextBath: DateTime.parse(json['nextBath']),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'nextVaccination': nextVaccination.toIso8601String(),
    'nextBath': nextBath.toIso8601String(),
  };
}

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool notificationsEnabled = true;
  List<Pet> pets = [];

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _initializeNotifications();
    _loadSettings();
    _loadPets();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', notificationsEnabled);
  }

  Future<void> _loadPets() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> petStrings = prefs.getStringList('pets') ?? [];
    setState(() {
      pets = petStrings.map((str) => Pet.fromJson(json.decode(str))).toList();
    });
  }

  Future<void> _scheduleNotification(
    String title,
    String body,
    DateTime scheduledTime,
  ) async {
    if (!notificationsEnabled) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'pet_care_channel',
          'Pet Care Reminders',
          channelDescription: 'Notifications for pet care reminders',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      platformDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> _showImmediateNotification() async {
    if (!notificationsEnabled) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'pet_care_channel',
          'Pet Care Reminders',
          channelDescription: 'Notifications for pet care reminders',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      1,
      'Pet Care Reminder Test',
      'This is a test notification!',
      platformDetails,
    );
  }

  List<Widget> _getUpcomingReminders() {
    List<Widget> reminders = [];
    DateTime now = DateTime.now();

    for (Pet pet in pets) {
      if (pet.nextVaccination.isAfter(now)) {
        int daysUntil = pet.nextVaccination.difference(now).inDays;
        reminders.add(
          ListTile(
            leading: Icon(Icons.medical_services, color: Colors.red),
            title: Text('${pet.name} - Vaccination'),
            subtitle: Text(
              'Due in $daysUntil days (${_formatDate(pet.nextVaccination)})',
            ),
            trailing:
                daysUntil <= 7
                    ? Icon(Icons.warning, color: Colors.orange)
                    : null,
          ),
        );
      }

      if (pet.nextBath.isAfter(now)) {
        int daysUntil = pet.nextBath.difference(now).inDays;
        reminders.add(
          ListTile(
            leading: Icon(Icons.bathtub, color: Colors.blue),
            title: Text('${pet.name} - Bath'),
            subtitle: Text(
              'Due in $daysUntil days (${_formatDate(pet.nextBath)})',
            ),
            trailing:
                daysUntil <= 3
                    ? Icon(Icons.warning, color: Colors.orange)
                    : null,
          ),
        );
      }
    }

    return reminders;
  }

  @override
  Widget build(BuildContext context) {
    // Jangan tampilkan AppBar di sini, biarkan HomeScreen yang menampilkan AppBar dan BottomNavigationBar
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.all(8),
            child: SwitchListTile(
              title: Text('Enable Notifications'),
              subtitle: Text('Receive reminders for pet care'),
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
                _saveSettings();
              },
            ),
          ),
          Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text('Test Notification'),
              subtitle: Text('Send a test notification now'),
              trailing: ElevatedButton(
                onPressed: _showImmediateNotification,
                child: Text('Test'),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Upcoming Reminders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 300,
            child:
                _getUpcomingReminders().isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          Text('No upcoming reminders'),
                          Text('Add pets to see reminders here'),
                        ],
                      ),
                    )
                    : ListView(children: _getUpcomingReminders()),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
