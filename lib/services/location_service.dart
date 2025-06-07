import 'package:geolocator/geolocator.dart';
import '../models/clinic.dart';

class LocationService {
  static Future<Position?> getCurrentPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  static double calculateDistance(
    double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // km
  }

  static List<Clinic> sortClinicsByDistance(
    List<Clinic> clinics, Position userPosition) {
    clinics.forEach((clinic) {
      clinic.toJson()['distance'] = calculateDistance(
        userPosition.latitude,
        userPosition.longitude,
        clinic.latitude,
        clinic.longitude,
      );
    });

    clinics.sort((a, b) {
      double distanceA = calculateDistance(
        userPosition.latitude, userPosition.longitude,
        a.latitude, a.longitude);
      double distanceB = calculateDistance(
        userPosition.latitude, userPosition.longitude,
        b.latitude, b.longitude);
      return distanceA.compareTo(distanceB);
    });

    return clinics;
  }
}
