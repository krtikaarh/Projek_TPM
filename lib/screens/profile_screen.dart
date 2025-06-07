import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        elevation: 0,
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section with gradient background
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue[600]!, Colors.blue[400]!],
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  // Profile picture
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundImage: AssetImage('assets/images/profile.png'),
                      child: null,
                    ),
                  ),
                  SizedBox(height: 15),
                  // Name
                  Text(
                    'Kartika Rahmi Anjani',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Pet Care App Developer',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),

            // Content section
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About section
                  _buildSectionCard(
                    title: 'Tentang Saya',
                    icon: Icons.info_outline,
                    content:
                        'Saya mahasiswi semester 6, dengan NIM 123220143, sangat suka mata kuliah ini',
                  ),

                  SizedBox(height: 15),

                  // Experience/Kesan section
                  _buildSectionCard(
                    title: 'Kesan',
                    icon: Icons.lightbulb_outline,
                    content:
                        'Flutter itu kayak kopi pahit - nggak enak di awal, bikin melek, dan lama-lama kecanduan (atau mungkin cuma Stockholm syndrome?). Yang penting bisa lulus!',
                  ),

                  SizedBox(height: 15),

                  // Message/Pesan section
                  _buildSectionCard(
                    title: 'Pesan',
                    icon: Icons.message_outlined,
                    content:
                        'Kasi deadline lebih lama pakk, ini projek numpuk semuaa jadi saya tidak bisa maksimal mengerjakan matkul mobile kesayangan ini, semoga nilainya gak pas-pasan ya pak',
                  ),

                  SizedBox(height: 15),

                  // Contact info
                  _buildSectionCard(
                    title: 'Kontak',
                    icon: Icons.contact_mail_outlined,
                    content: 'Email: 123220143@student.upnyk.ac.id',
                  ),

                  SizedBox(height: 30),

                  // App info
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.pets, size: 40, color: Colors.blue[400]),
                        SizedBox(height: 10),
                        Text(
                          'Pet Care Reminder App',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[600], size: 24),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
