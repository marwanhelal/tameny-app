import 'package:flutter/material.dart';
import 'booking_doctor/doctor_options_screen.dart';
import 'labs/labs_and_scan_selection_screen.dart';

class ReservationsSearchScreen extends StatelessWidget {
  const ReservationsSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF004B95), Color(0xFF01B5A2)],
            ),
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.search_rounded, size: 22),
            SizedBox(width: 8),
            Text(
              'Reservations / Search',
              style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {
              
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F9FF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 12, top: 4),
                  child: Text(
                    'What are you looking for?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF004B95).withOpacity(0.9),
                    ),
                  ),
                ),
                _buildCategoryCard(
                  context,
                  title: 'Doctors',
                  subtitle: 'Find specialists & book appointments',
                  imagePath: 'assets/Doctors.png',
                  icon: Icons.medical_services_rounded,
                  gradientColors: const [Color(0xFF004B95), Color(0xFF01B5A2)],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DoctorOptionsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),
                _buildCategoryCard(
                  context,
                  title: 'Labs and Scan Centre',
                  subtitle: 'Book tests & diagnostic services',
                  imagePath: 'assets/Labs and scan centre.png',
                  icon: Icons.biotech_rounded,
                  gradientColors: const [Color(0xFF01B5A2), Color(0xFF00DEC7)],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => const LabsAndScanSelectionScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),
                _buildCategoryCard(
                  context,
                  title: 'Hospitals',
                  subtitle: 'Find the best hospitals near you',
                  imagePath: 'assets/Hospitals.png',
                  icon: Icons.local_hospital_rounded,
                  gradientColors: const [Color(0xFF004B95), Color(0xFF01B5A2)],
                  onTap: () {
                    Navigator.pushNamed(context, '/hospitalEmergency');
                  },
                ),
                const SizedBox(height: 15),
                _buildCategoryCard(
                  context,
                  title: 'Pharmacy',
                  subtitle: 'Order medicines & healthcare products',
                  imagePath: 'assets/Pharmacy.png',
                  icon: Icons.local_pharmacy_rounded,
                  gradientColors: const [Color(0xFF01B5A2), Color(0xFF00DEC7)],
                  onTap: () {
                    Navigator.pushNamed(context, '/pharmacyList');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imagePath,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.white.withOpacity(0.1),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 140,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        gradientColors[0].withOpacity(0.85),
                        gradientColors[1].withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                bottom: 0,
                left: 20,
                right: 20,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: gradientColors[0], size: 26),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                              shadows: const [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
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
}


