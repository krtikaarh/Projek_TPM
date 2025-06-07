import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';

class SensorService {
  static StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  static StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  
  static Function(double)? onShakeDetected;
  static Function(AccelerometerEvent)? onAccelerometerUpdate;
  static Function(GyroscopeEvent)? onGyroscopeUpdate;

  static double shakeThreshold = 12.0;
  static DateTime? lastShakeTime;

  static void startListening() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      onAccelerometerUpdate?.call(event);
      _detectShake(event);
    });

    _gyroscopeSubscription = gyroscopeEvents.listen((event) {
      onGyroscopeUpdate?.call(event);
    });
  }

  static void stopListening() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
  }

  static void _detectShake(AccelerometerEvent event) {
    double acceleration = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z
    );

    if (acceleration > shakeThreshold) {
      DateTime now = DateTime.now();
      
      if (lastShakeTime == null || 
          now.difference(lastShakeTime!).inMilliseconds > 500) {
        lastShakeTime = now;
        onShakeDetected?.call(acceleration);
      }
    }
  }

  static double calculateTiltAngle(AccelerometerEvent event) {
    return atan2(event.y, event.x) * 180 / pi;
  }

  static bool isDeviceStable(AccelerometerEvent event, {double threshold = 1.0}) {
    double totalAcceleration = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z
    );
    return totalAcceleration < threshold;
  }
}
