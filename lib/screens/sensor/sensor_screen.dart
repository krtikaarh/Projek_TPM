import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';

class SensorScreen extends StatefulWidget {
  @override
  _SensorScreenState createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  AccelerometerEvent? _accelerometerEvent;
  GyroscopeEvent? _gyroscopeEvent;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  double _shakeThreshold = 12.0;
  DateTime? _lastShakeTime;
  int _shakeCount = 0;
  bool _isPlaying = false;

  List<String> _playActivities = [
    'Playing fetch! 🎾',
    'Tug of war! 🪢',
    'Chase game! 🏃‍♂️',
    'Gentle petting 🤗',
    'Treat time! 🦴',
    'Belly rubs! 😊',
  ];

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  void _startListening() {
    _accelerometerSubscription = accelerometerEvents.listen((
      AccelerometerEvent event,
    ) {
      setState(() {
        _accelerometerEvent = event;
      });
      _detectShake(event);
    });

    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeEvent = event;
      });
    });
  }

  void _stopListening() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
  }

  void _detectShake(AccelerometerEvent event) {
    double acceleration = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    if (acceleration > _shakeThreshold) {
      DateTime now = DateTime.now();

      if (_lastShakeTime == null ||
          now.difference(_lastShakeTime!).inMilliseconds > 500) {
        _lastShakeTime = now;
        setState(() {
          _shakeCount++;
          _isPlaying = true;
        });

        // Stop playing animation after 2 seconds
        Timer(Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isPlaying = false;
            });
          }
        });
      }
    }
  }

  String _getCurrentActivity() {
    if (!_isPlaying) return 'Pet is resting 😴';
    return _playActivities[_shakeCount % _playActivities.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pet Play Sensor')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Pet Play Detector',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _isPlaying ? Colors.green[100] : Colors.grey[100],
                          border: Border.all(
                            color: _isPlaying ? Colors.green : Colors.grey,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isPlaying ? Icons.pets : Icons.pause,
                                size: 40,
                                color: _isPlaying ? Colors.green : Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                _isPlaying ? 'Playing!' : 'Resting',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _isPlaying ? Colors.green : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        _getCurrentActivity(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              _isPlaying ? Colors.green[700] : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Shake your phone to simulate playing with your pet!',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Play Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                            'Play Sessions',
                            _shakeCount.toString(),
                            Icons.play_arrow,
                          ),
                          _buildStatCard(
                            'Status',
                            _isPlaying ? 'Active' : 'Inactive',
                            Icons.info,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sensor Data',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      if (_accelerometerEvent != null) ...[
                        Text(
                          'Accelerometer:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('X: ${_accelerometerEvent!.x.toStringAsFixed(2)}'),
                        Text('Y: ${_accelerometerEvent!.y.toStringAsFixed(2)}'),
                        Text('Z: ${_accelerometerEvent!.z.toStringAsFixed(2)}'),
                        SizedBox(height: 8),
                      ],
                      if (_gyroscopeEvent != null) ...[
                        Text(
                          'Gyroscope:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('X: ${_gyroscopeEvent!.x.toStringAsFixed(2)}'),
                        Text('Y: ${_gyroscopeEvent!.y.toStringAsFixed(2)}'),
                        Text('Z: ${_gyroscopeEvent!.z.toStringAsFixed(2)}'),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How it works',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This feature uses your phone\'s accelerometer to detect movement and simulate playing with your pet. Shake your phone to trigger different play activities!',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
