import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctors_choices_screen.dart'; 

class NeedVisitSpecializationScreen extends StatefulWidget {
  const NeedVisitSpecializationScreen({super.key});

  @override
  State<NeedVisitSpecializationScreen> createState() =>
      _NeedVisitSpecializationScreenState();
}

class _NeedVisitSpecializationScreenState
    extends State<NeedVisitSpecializationScreen> {
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
              'Need a Visit',
              style: TextStyle(
                fontFamily: 'GoiaDisplayVariable',
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSpecialization,
                    isExpanded: true,
                    hint: const Text("Choose a medical specialty"),
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
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004B95),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                if (_selectedSpecialization != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => DoctorsChoicesScreen(
                            specialization: _selectedSpecialization!,
                            connectionTypeFilter: "Need a visit",
                          ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a specialization'),
                    ),
                  );
                }
              },
              child: const Text(
                "Go to Dr.'s Choices",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


