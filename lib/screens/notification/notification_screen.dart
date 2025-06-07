
class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool notificationsEnabled = true;
  List<Pet> pets = [];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadSettings();
    _loadPets();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    
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

  Future<void> _scheduleNotification(String title, String body, DateTime scheduledTime) async {
    if (!notificationsEnabled) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'pet_care_channel',
      'Pet Care Reminders',
      channelDescription: 'Notifications for pet care reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await flutterLocalNotificationsPlugin.schedule(
      0,
      title,
      body,
      scheduledTime,
      platformChannelSpecifics,
    );
  }

  Future<void> _showImmediateNotification() async {
    if (!notificationsEnabled) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'pet_care_channel',
      'Pet Care Reminders',
      channelDescription: 'Notifications for pet care reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await flutterLocalNotificationsPlugin.show(
      1,
      'Pet Care Reminder Test',
      'This is a test notification for your pet care app!',
      platformChannelSpecifics,
    );
  }

  List<Widget> _getUpcomingReminders() {
    List<Widget> reminders = [];
    DateTime now = DateTime.now();
    
    for (Pet pet in pets) {
      // Check vaccination
      if (pet.nextVaccination.isAfter(now)) {
        int daysUntil = pet.nextVaccination.difference(now).inDays;
        reminders.add(
          ListTile(
            leading: Icon(Icons.medical_services, color: Colors.red),
            title: Text('${pet.name} - Vaccination'),
            subtitle: Text('Due in $daysUntil days (${_formatDate(pet.nextVaccination)})'),
            trailing: daysUntil <= 7 ? Icon(Icons.warning, color: Colors.orange) : null,
          ),
        );
      }
      
      // Check bath
      if (pet.nextBath.isAfter(now)) {
        int daysUntil = pet.nextBath.difference(now).inDays;
        reminders.add(
          ListTile(
            leading: Icon(Icons.bathtub, color: Colors.blue),
            title: Text('${pet.name} - Bath'),
            subtitle: Text('Due in $daysUntil days (${_formatDate(pet.nextBath)})'),
            trailing: daysUntil <= 3 ? Icon(Icons.warning, color: Colors.orange) : null,
          ),
        );
      }
    }
    
    return reminders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: Column(
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
          Expanded(
            child: _getUpcomingReminders().isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                        Text('No upcoming reminders'),
                        Text('Add pets to see reminders here'),
                      ],
                    ),
                  )
                : ListView(
                    children: _getUpcomingReminders(),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}