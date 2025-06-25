import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctors_choices_screen.dart'; 

class OnlineDoctorScreen extends StatefulWidget {
  const OnlineDoctorScreen({super.key});

  @override
  State<OnlineDoctorScreen> createState() => _OnlineDoctorScreenState();
}

class _OnlineDoctorScreenState extends State<OnlineDoctorScreen> {
  final List<String> _specializations = [];
  String? _selectedSpecialization;

  @override
  void initState() {
    super.initState();
    _fetchSpecializations();
  }

  Future<void> _fetchSpecializations() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('specializations').get();

    setState(() {
      _specializations.clear();
      final list = snapshot.docs.first['name'];
      if (list is List) {
        _specializations.addAll(List<String>.from(list));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Background image.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Text(
              'Online',
              style: TextStyle(
                fontFamily: 'GoiaDisplayVariable',
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSpecialization,
                    hint: const Text("Choose a medical specialty"),
                    isExpanded: true,
                    items:
                        _specializations.map((specialty) {
                          return DropdownMenuItem<String>(
                            value: specialty,
                            child: Text(specialty),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSpecialization = value;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildButton(
              context,
              "Go to Dr.'s Choices",
              const Color(0xFF004B95),
              () {
                if (_selectedSpecialization != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => DoctorsChoicesScreen(
                            specialization: _selectedSpecialization!,
                            connectionTypeFilter:
                                "Online", 
                          ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please choose a specialization'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: 280,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}


