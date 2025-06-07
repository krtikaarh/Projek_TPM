import 'package:flutter/material.dart';

class TimeConverterScreen extends StatefulWidget {
  @override
  _TimeConverterScreenState createState() => _TimeConverterScreenState();
}

class _TimeConverterScreenState extends State<TimeConverterScreen> {
  DateTime selectedDateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Time Converter')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Date & Time',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: Text('Date'),
                  subtitle: Text(_formatDate(selectedDateTime)),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDateTime,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDateTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          selectedDateTime.hour,
                          selectedDateTime.minute,
                        );
                      });
                    }
                  },
                ),
              ),
              Card(
                child: ListTile(
                  title: Text('Time'),
                  subtitle: Text(_formatTime(selectedDateTime)),
                  trailing: Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                    );
                    if (time != null) {
                      setState(() {
                        selectedDateTime = DateTime(
                          selectedDateTime.year,
                          selectedDateTime.month,
                          selectedDateTime.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  },
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Time Zones',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _buildTimeZoneCard('WIB (UTC+7)', selectedDateTime, 7),
              _buildTimeZoneCard('WITA (UTC+8)', selectedDateTime, 8),
              _buildTimeZoneCard('WIT (UTC+9)', selectedDateTime, 9),
              _buildTimeZoneCard('London (UTC+0)', selectedDateTime, 0),
              SizedBox(height: 16),
              Text(
                'Useful for scheduling pet care when traveling across time zones',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeZoneCard(String zoneName, DateTime dateTime, int utcOffset) {
    DateTime convertedTime = dateTime.add(
      Duration(hours: utcOffset - 7),
    ); // Assuming input is WIB

    return Card(
      child: ListTile(
        title: Text(zoneName),
        subtitle: Text(
          '${_formatDate(convertedTime)} ${_formatTime(convertedTime)}',
        ),
        leading: Icon(Icons.public),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
