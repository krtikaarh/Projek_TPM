import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Position? currentPosition;
  bool isLoading = false;
  String locationStatus = 'Not determined';

  // Mock veterinary clinics data
  final List<Map<String, dynamic>> mockClinics = [
    {
      'name': 'Pet Care Clinic Depok',
      'address': 'Jl. Margonda Raya No. 123, Depok',
      'lat': -6.3728,
      'lng': 106.8345,
      'phone': '021-1234567',
      'rating': 4.5,
    },
    {
      'name': 'Animal Hospital Sawangan',
      'address': 'Jl. Raya Sawangan No. 45, Depok',
      'lat': -6.4028,
      'lng': 106.8145,
      'phone': '021-2345678',
      'rating': 4.2,
    },
    {
      'name': 'Veterinary Clinic Beji',
      'address': 'Jl. Beji Raya No. 67, Depok',
      'lat': -6.3628,
      'lng': 106.8245,
      'phone': '021-3456789',
      'rating': 4.7,
    },
    {
      'name': 'Pet Health Center Lenteng Agung',
      'address': 'Jl. Lenteng Agung No. 89, Jakarta Selatan',
      'lat': -6.3428,
      'lng': 106.8445,
      'phone': '021-4567890',
      'rating': 4.3,
    },
    {
      'name': 'Emergency Pet Clinic UI',
      'address': 'Jl. Lingkar Kampus UI, Depok',
      'lat': -6.3528,
      'lng': 106.8285,
      'phone': '021-5678901',
      'rating': 4.6,
    },
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoading = true;
      locationStatus = 'Getting location...';
    });

    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            locationStatus = 'Location permission denied';
            isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          locationStatus = 'Location permission permanently denied';
          isLoading = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        currentPosition = position;
        locationStatus = 'Location found';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        locationStatus = 'Error getting location: $e';
        isLoading = false;
      });
    }
  }

  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) /
        1000; // Convert to km
  }

  List<Map<String, dynamic>> _getNearestClinics() {
    if (currentPosition == null) return [];

    List<Map<String, dynamic>> clinicsWithDistance =
        mockClinics.map((clinic) {
          double distance = _calculateDistance(
            currentPosition!.latitude,
            currentPosition!.longitude,
            clinic['lat'],
            clinic['lng'],
          );
          return {...clinic, 'distance': distance};
        }).toList();

    clinicsWithDistance.sort((a, b) => a['distance'].compareTo(b['distance']));
    return clinicsWithDistance;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Location',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  if (isLoading)
                    Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text(locationStatus),
                      ],
                    )
                  else if (currentPosition != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: $locationStatus'),
                        Text(
                          'Latitude: ${currentPosition!.latitude.toStringAsFixed(6)}',
                        ),
                        Text(
                          'Longitude: ${currentPosition!.longitude.toStringAsFixed(6)}',
                        ),
                        Text(
                          'Accuracy: ${currentPosition!.accuracy.toStringAsFixed(1)}m',
                        ),
                      ],
                    )
                  else
                    Text(locationStatus),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Nearest Veterinary Clinics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height:
                400, // Atur tinggi agar ListView bisa tampil di dalam SingleChildScrollView
            child:
                currentPosition == null
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          Text('Location not available'),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _getCurrentLocation,
                            child: Text('Get Location'),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: _getNearestClinics().length,
                      itemBuilder: (context, index) {
                        final clinic = _getNearestClinics()[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red[100],
                              child: Icon(
                                Icons.local_hospital,
                                color: Colors.red,
                              ),
                            ),
                            title: Text(clinic['name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(clinic['address']),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.orange,
                                    ),
                                    Text(' ${clinic['rating']}'),
                                    SizedBox(width: 16),
                                    Icon(
                                      Icons.phone,
                                      size: 16,
                                      color: Colors.green,
                                    ),
                                    Text(' ${clinic['phone']}'),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${clinic['distance'].toStringAsFixed(1)} km',
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () {
                              _showClinicDetails(clinic);
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  void _showClinicDetails(Map<String, dynamic> clinic) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(clinic['name']),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Address: ${clinic['address']}'),
                SizedBox(height: 8),
                Text('Phone: ${clinic['phone']}'),
                SizedBox(height: 8),
                Text('Rating: ${clinic['rating']} ⭐'),
                SizedBox(height: 8),
                Text('Distance: ${clinic['distance'].toStringAsFixed(1)} km'),
                SizedBox(height: 8),
                Text('Coordinates: ${clinic['lat']}, ${clinic['lng']}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Opening maps... (Feature not implemented in demo)',
                      ),
                    ),
                  );
                },
                child: Text('Open Maps'),
              ),
            ],
          ),
    );
  }
}
