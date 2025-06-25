import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../authentication/welcome_screen.dart';

import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<AdminNavItem> _navItems = [
    AdminNavItem(icon: Icons.dashboard, title: 'Dashboard'),
    AdminNavItem(icon: Icons.local_hospital, title: 'Doctors'),
    AdminNavItem(icon: Icons.people, title: 'Patients'),
    AdminNavItem(icon: Icons.business, title: 'Hospitals'),
    AdminNavItem(icon: Icons.local_pharmacy, title: 'Pharmacies'),
    AdminNavItem(icon: Icons.science, title: 'Labs'),
  ];

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _signOut() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (shouldLogout == true && mounted) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    if (isDesktop) {
      return _buildDesktopLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 280,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1E3A5F), Color(0xFF0F1922)],
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(0xFF004B95),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tameny Admin',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Healthcare Management',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: StreamBuilder<int>(
                    stream: _getPendingApprovalsCount(),
                    builder: (context, snapshot) {
                      final pendingCount = snapshot.data ?? 0;

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        itemCount: _navItems.length,
                        itemBuilder: (context, index) {
                          final item = _navItems[index];
                          final isSelected = _selectedIndex == index;
                          final showBadge = index == 0 && pendingCount > 0;

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? const Color(0xFF004B95)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: Icon(
                                item.icon,
                                color:
                                    isSelected
                                        ? Colors.white
                                        : Colors.grey[400],
                                size: 22,
                              ),
                              title: Text(
                                item.title,
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Colors.grey[400],
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                              trailing:
                                  showBadge
                                      ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          pendingCount.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                      : null,
                              onTap: () => _onNavItemTapped(index),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _signOut,
                      icon: const Icon(Icons.logout, size: 16),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Column(
              children: [
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        _navItems[_selectedIndex].title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E3B4E),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => setState(() {}),
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Refresh Data',
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    children: const [
                      DashboardOverviewPage(),
                      DoctorsManagementPage(),
                      PatientsManagementPage(),
                      HospitalsManagementPage(),
                      PharmaciesManagementPage(),
                      LabsManagementPage(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_navItems[_selectedIndex].title),
        backgroundColor: const Color(0xFF004B95),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _signOut),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: const [
          DashboardOverviewPage(),
          DoctorsManagementPage(),
          PatientsManagementPage(),
          HospitalsManagementPage(),
          PharmaciesManagementPage(),
          LabsManagementPage(),
        ],
      ),
      bottomNavigationBar: StreamBuilder<int>(
        stream: _getPendingApprovalsCount(),
        builder: (context, snapshot) {
          final pendingCount = snapshot.data ?? 0;

          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onNavItemTapped,
            selectedItemColor: const Color(0xFF004B95),
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            elevation: 8,
            items:
                _navItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final showBadge = index == 0 && pendingCount > 0;

                  return BottomNavigationBarItem(
                    icon:
                        showBadge
                            ? Badge(
                              label: Text(pendingCount.toString()),
                              child: Icon(item.icon),
                            )
                            : Icon(item.icon),
                    label: item.title,
                  );
                }).toList(),
          );
        },
      ),
    );
  }

  Stream<int> _getPendingApprovalsCount() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .where('approvalStatus', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}

class AdminNavItem {
  final IconData icon;
  final String title;

  AdminNavItem({required this.icon, required this.title});
}

class DashboardOverviewPage extends StatelessWidget {
  const DashboardOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF004B95), Color(0xFF01B5A2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to Tameny Admin',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Manage your healthcare platform efficiently',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.dashboard, color: Colors.white, size: 64),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          StreamBuilder<List<DashboardMetric>>(
            stream: _getDashboardMetrics(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF004B95),
                      ),
                    ),
                  ),
                );
              }

              final metrics = snapshot.data ?? [];

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 4 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isDesktop ? 1.3 : 1.4,
                ),
                itemCount: metrics.length,
                itemBuilder: (context, index) {
                  final metric = metrics[index];
                  return MetricCard(metric: metric, isDesktop: isDesktop);
                },
              );
            },
          ),

          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.pending_actions,
                      color: Color(0xFF004B95),
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Pending Doctor Approvals',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E3B4E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const PendingDoctorApprovals(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Stream<List<DashboardMetric>> _getDashboardMetrics() {
    return FirebaseFirestore.instance.collection('users').snapshots().asyncMap((
      usersSnapshot,
    ) async {
      final hospitalsSnapshot =
          await FirebaseFirestore.instance.collection('hospitals').get();
      final pharmaciesSnapshot =
          await FirebaseFirestore.instance.collection('pharmacies').get();
      final labsSnapshot =
          await FirebaseFirestore.instance.collection('labs_centres').get();

      int totalPatients = 0;
      int approvedDoctors = 0;
      int pendingApprovals = 0;

      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        final role = data['role'] ?? '';
        final approvalStatus = data['approvalStatus'] ?? '';

        if (role == 'patient') {
          totalPatients++;
        } else if (role == 'doctor') {
          if (approvalStatus == 'approved') {
            approvedDoctors++;
          } else if (approvalStatus == 'pending') {
            pendingApprovals++;
          }
        }
      }

      return [
        DashboardMetric(
          title: 'Total Patients',
          value: totalPatients.toString(),
          icon: Icons.people,
          color: const Color(0xFF004B95),
        ),
        DashboardMetric(
          title: 'Approved Doctors',
          value: approvedDoctors.toString(),
          icon: Icons.local_hospital,
          color: const Color(0xFF01B5A2),
        ),
        DashboardMetric(
          title: 'Hospitals',
          value: hospitalsSnapshot.docs.length.toString(),
          icon: Icons.business,
          color: const Color(0xFF7C4DFF),
        ),
        DashboardMetric(
          title: 'Pending Approvals',
          value: pendingApprovals.toString(),
          icon: Icons.pending,
          color: const Color(0xFFFF9800),
        ),
        DashboardMetric(
          title: 'Pharmacies',
          value: pharmaciesSnapshot.docs.length.toString(),
          icon: Icons.local_pharmacy,
          color: const Color(0xFF4CAF50),
        ),
        DashboardMetric(
          title: 'Labs & Centers',
          value: labsSnapshot.docs.length.toString(),
          icon: Icons.science,
          color: const Color(0xFFE91E63),
        ),
      ];
    });
  }
}

class DashboardMetric {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  DashboardMetric({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class MetricCard extends StatelessWidget {
  final DashboardMetric metric;
  final bool isDesktop;

  const MetricCard({super.key, required this.metric, this.isDesktop = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
          ),
        ],
      ),
      padding: EdgeInsets.all(isDesktop ? 16 : 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: metric.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              metric.icon,
              color: metric.color,
              size: isDesktop ? 24 : 20,
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              metric.value,
              style: TextStyle(
                fontSize: isDesktop ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E3B4E),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              metric.title,
              style: TextStyle(
                fontSize: isDesktop ? 12 : 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class PendingDoctorApprovals extends StatefulWidget {
  const PendingDoctorApprovals({super.key});

  @override
  State<PendingDoctorApprovals> createState() => _PendingDoctorApprovalsState();
}

class _PendingDoctorApprovalsState extends State<PendingDoctorApprovals> {
  final Set<String> _approvingDoctors = <String>{};

  Future<void> approveDoctor(BuildContext context, String userId) async {
    if (mounted) {
      setState(() {
        _approvingDoctors.add(userId);
      });
    }

    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      if (!userDoc.exists) {
        throw Exception('Doctor not found');
      }

      final data = userDoc.data()!;
      final batch = FirebaseFirestore.instance.batch();

      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId);
      batch.update(userRef, {
        'approvalStatus': 'approved',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final doctorRef = FirebaseFirestore.instance
          .collection('doctors')
          .doc(userId);
      batch.set(doctorRef, {
        'approvalStatus': 'approved',
        'email': data['email'] ?? '',
        'name': data['name'] ?? '',
        'phoneNumber': data['phoneNumber'] ?? '',
        'specialization': data['specialization'] ?? '',
        'address': data['address'] ?? '',
        'gender': data['gender'] ?? '',
        'age': data['age'] ?? 0,
        'price': data['price'] ?? 0,
        'role': data['role'] ?? 'doctor',
        'userId': userId,
        'connectionTypes': data['connectionTypes'] ?? [],
        'createdAt': FieldValue.serverTimestamp(),
        'migratedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to approve doctor'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _approvingDoctors.remove(userId);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'doctor')
              .where('approvalStatus', isEqualTo: 'pending')
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF004B95)),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Error loading pending approvals',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            child: const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: Colors.green,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No pending doctor approvals',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final userId = docs[index].id;
            final connectionTypes =
                (data['connectionTypes'] as List<dynamic>?)?.cast<String>() ??
                [];

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E3B4E),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(Icons.email, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            data['email'] ?? 'N/A',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(
                          Icons.medical_services,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Specialization: ${data['specialization'] ?? 'N/A'}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          size: 16,
                          color: Color(0xFF01B5A2),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Price: ${data['price'] ?? 0} EGP',
                          style: const TextStyle(
                            color: Color(0xFF01B5A2),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    if (connectionTypes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Connection Types:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF004B95),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children:
                            connectionTypes.map((type) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF004B95,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF004B95,
                                    ).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  type,
                                  style: const TextStyle(
                                    color: Color(0xFF004B95),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ],

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            _approvingDoctors.contains(userId)
                                ? null
                                : () => approveDoctor(context, userId),
                        icon:
                            _approvingDoctors.contains(userId)
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Icon(Icons.check, size: 18),
                        label: Text(
                          _approvingDoctors.contains(userId)
                              ? 'Approving...'
                              : 'Approve',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _approvingDoctors.contains(userId)
                                  ? Colors.grey
                                  : const Color(0xFF01B5A2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class DoctorsManagementPage extends StatefulWidget {
  const DoctorsManagementPage({super.key});

  @override
  State<DoctorsManagementPage> createState() => _DoctorsManagementPageState();
}

class _DoctorsManagementPageState extends State<DoctorsManagementPage> {
  String _searchQuery = '';
  String _sortBy = 'name';
  bool _sortAscending = true;
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
        child: Column(
          children: [
            if (isDesktop)
              _buildDesktopControlsRow()
            else
              _buildMobileControlsColumn(),
            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('doctors')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

                  docs = _filterAndSortDoctors(docs);

                  if (docs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No doctors found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  if (isDesktop) {
                    return _buildDesktopTable(docs);
                  } else {
                    return _buildMobileList(docs);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopControlsRow() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search doctors...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            value: _statusFilter,
            decoration: InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All')),
              DropdownMenuItem(value: 'approved', child: Text('Approved')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
            ],
            onChanged: (value) {
              setState(() {
                _statusFilter = value!;
              });
            },
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            value: _sortBy,
            decoration: InputDecoration(
              labelText: 'Sort by',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'name', child: Text('Name')),
              DropdownMenuItem(value: 'specialization', child: Text('Spec.')),
              DropdownMenuItem(value: 'price', child: Text('Price')),
              DropdownMenuItem(value: 'createdAt', child: Text('Date')),
            ],
            onChanged: (value) {
              setState(() {
                _sortBy = value!;
              });
            },
          ),
        ),
        const SizedBox(width: 8),

        IconButton(
          onPressed: () {
            setState(() {
              _sortAscending = !_sortAscending;
            });
          },
          icon: Icon(
            _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
          ),
          tooltip: _sortAscending ? 'Ascending' : 'Descending',
        ),
      ],
    );
  }

  Widget _buildMobileControlsColumn() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search doctors...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _statusFilter,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'approved', child: Text('Approved')),
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                ],
                onChanged: (value) {
                  setState(() {
                    _statusFilter = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: DropdownButtonFormField<String>(
                value: _sortBy,
                decoration: InputDecoration(
                  labelText: 'Sort',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'name', child: Text('Name')),
                  DropdownMenuItem(
                    value: 'specialization',
                    child: Text('Spec.'),
                  ),
                  DropdownMenuItem(value: 'price', child: Text('Price')),
                  DropdownMenuItem(value: 'createdAt', child: Text('Date')),
                ],
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),

            IconButton(
              onPressed: () {
                setState(() {
                  _sortAscending = !_sortAscending;
                });
              },
              icon: Icon(
                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<QueryDocumentSnapshot> _filterAndSortDoctors(
    List<QueryDocumentSnapshot> docs,
  ) {
    if (_searchQuery.isNotEmpty) {
      docs =
          docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['name'] ?? '').toString().toLowerCase();
            final email = (data['email'] ?? '').toString().toLowerCase();
            final specialization =
                (data['specialization'] ?? '').toString().toLowerCase();

            return name.contains(_searchQuery) ||
                email.contains(_searchQuery) ||
                specialization.contains(_searchQuery);
          }).toList();
    }

    if (_statusFilter != 'all') {
      docs =
          docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return (data['approvalStatus'] ?? '') == _statusFilter;
          }).toList();
    }

    docs.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;

      dynamic aValue, bValue;

      switch (_sortBy) {
        case 'name':
          aValue = aData['name'] ?? '';
          bValue = bData['name'] ?? '';
          break;
        case 'specialization':
          aValue = aData['specialization'] ?? '';
          bValue = bData['specialization'] ?? '';
          break;
        case 'price':
          aValue = aData['price'] ?? 0;
          bValue = bData['price'] ?? 0;
          break;
        case 'createdAt':
          aValue = aData['createdAt'] ?? Timestamp.now();
          bValue = bData['createdAt'] ?? Timestamp.now();
          break;
        default:
          aValue = aData['name'] ?? '';
          bValue = bData['name'] ?? '';
      }

      if (aValue is String && bValue is String) {
        return _sortAscending
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      } else if (aValue is num && bValue is num) {
        return _sortAscending
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      } else if (aValue is Timestamp && bValue is Timestamp) {
        return _sortAscending
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      }

      return 0;
    });

    return docs;
  }

  Widget _buildDesktopTable(List<QueryDocumentSnapshot> docs) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
          columnSpacing: 20,
          dataRowMinHeight: 56,
          dataRowMaxHeight: 72,
          columns: const [
            DataColumn(
              label: Text(
                'Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Email',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Specialization',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Price',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Actions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows:
              docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final status = data['approvalStatus'] ?? 'pending';

                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 120,
                        child: Text(
                          data['name'] ?? 'N/A',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 150,
                        child: Text(
                          data['email'] ?? 'N/A',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 100,
                        child: Text(
                          data['specialization'] ?? 'N/A',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(Text('${data['price'] ?? 0} EGP')),
                    DataCell(_buildStatusChip(status)),
                    DataCell(_buildActionsRow(doc.id, data)),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileList(List<QueryDocumentSnapshot> docs) {
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final data = docs[index].data() as Map<String, dynamic>;
        final docId = docs[index].id;
        final status = data['approvalStatus'] ?? 'pending';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF004B95),
                      child: Text(
                        (data['name'] ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['name'] ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            data['specialization'] ?? 'N/A',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.email, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data['email'] ?? 'N/A',
                        style: const TextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${data['price'] ?? 0} EGP',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildActionsRow(docId, data),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'approved':
        color = Colors.green;
        text = 'Approved';
        break;
      case 'pending':
        color = Colors.orange;
        text = 'Pending';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Rejected';
        break;
      default:
        color = Colors.grey;
        text = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildActionsRow(String docId, Map<String, dynamic> data) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _editDoctor(docId, data),
          icon: const Icon(Icons.edit, color: Color(0xFF004B95), size: 20),
          tooltip: 'Edit',
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        IconButton(
          onPressed: () => _deleteDoctor(docId, data['name'] ?? 'Doctor'),
          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
          tooltip: 'Delete',
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        if (data['approvalStatus'] == 'pending')
          IconButton(
            onPressed: () => _updateDoctorStatus(docId, 'approved'),
            icon: const Icon(Icons.check, color: Colors.green, size: 20),
            tooltip: 'Approve',
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
      ],
    );
  }

  void _editDoctor(String docId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => DoctorEditDialog(docId: docId, initialData: data),
    );
  }

  void _deleteDoctor(String docId, String doctorName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Doctor'),
            content: Text('Are you sure you want to delete $doctorName?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  try {
                    await FirebaseFirestore.instance
                        .collection('doctors')
                        .doc(docId)
                        .delete();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Doctor deleted successfully'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error deleting doctor: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _updateDoctorStatus(String docId, String status) async {
    try {
      await FirebaseFirestore.instance.collection('doctors').doc(docId).update({
        'approvalStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Doctor ${status == 'approved' ? 'approved' : 'rejected'} successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating doctor: $e')));
      }
    }
  }
}

class DoctorEditDialog extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> initialData;

  const DoctorEditDialog({
    super.key,
    required this.docId,
    required this.initialData,
  });

  @override
  State<DoctorEditDialog> createState() => _DoctorEditDialogState();
}

class _DoctorEditDialogState extends State<DoctorEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _specializationController;
  late TextEditingController _priceController;
  late TextEditingController _addressController;
  String _selectedStatus = 'pending';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialData['name'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.initialData['email'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.initialData['phoneNumber'] ?? '',
    );
    _specializationController = TextEditingController(
      text: widget.initialData['specialization'] ?? '',
    );
    _priceController = TextEditingController(
      text: (widget.initialData['price'] ?? 0).toString(),
    );
    _addressController = TextEditingController(
      text: widget.initialData['address'] ?? '',
    );
    _selectedStatus = widget.initialData['approvalStatus'] ?? 'pending';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Doctor'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width > 600 ? 500 : double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _specializationController,
                decoration: const InputDecoration(
                  labelText: 'Specialization',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price (EGP)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'approved', child: Text('Approved')),
                  DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveChanges,
          child:
              _isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Save'),
        ),
      ],
    );
  }

  void _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.docId)
          .update({
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'phoneNumber': _phoneController.text.trim(),
            'specialization': _specializationController.text.trim(),
            'price': int.tryParse(_priceController.text) ?? 0,
            'address': _addressController.text.trim(),
            'approvalStatus': _selectedStatus,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating doctor: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

class PatientsManagementPage extends StatefulWidget {
  const PatientsManagementPage({super.key});

  @override
  State<PatientsManagementPage> createState() => _PatientsManagementPageState();
}

class _PatientsManagementPageState extends State<PatientsManagementPage> {
  String _searchQuery = '';
  String _sortBy = 'name';
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
        child: Column(
          children: [
            if (isDesktop)
              _buildDesktopControlsRow()
            else
              _buildMobileControlsColumn(),
            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('users')
                        .where('role', isEqualTo: 'patient')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

                  docs = _filterAndSortPatients(docs);

                  if (docs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No patients found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final docId = docs[index].id;

                      String patientName = _getPatientName(data);
                      String patientEmail = _getPatientEmail(data);
                      String patientPhone = _getPatientPhone(data);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF01B5A2),
                            child: Text(
                              patientName.isNotEmpty
                                  ? patientName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            patientName.isNotEmpty
                                ? patientName
                                : 'Unknown Patient',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (patientEmail.isNotEmpty)
                                Text(
                                  patientEmail,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (patientPhone.isNotEmpty)
                                Text(
                                  'Phone: $patientPhone',
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (data['createdAt'] != null)
                                Text(
                                  'Joined: ${DateFormat('MMM dd, yyyy').format((data['createdAt'] as Timestamp).toDate())}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder:
                                (context) => [
                                  const PopupMenuItem(
                                    value: 'view',
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.visibility, size: 16),
                                        SizedBox(width: 8),
                                        Text('View'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                            onSelected: (value) {
                              if (value == 'view') {
                                _viewPatientDetails(data, patientName);
                              } else if (value == 'delete') {
                                _deletePatient(docId, patientName);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopControlsRow() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search patients...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            value: _sortBy,
            decoration: InputDecoration(
              labelText: 'Sort by',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'name', child: Text('Name')),
              DropdownMenuItem(value: 'email', child: Text('Email')),
              DropdownMenuItem(value: 'createdAt', child: Text('Join Date')),
            ],
            onChanged: (value) {
              setState(() {
                _sortBy = value!;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            setState(() {
              _sortAscending = !_sortAscending;
            });
          },
          icon: Icon(
            _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileControlsColumn() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search patients...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _sortBy,
                decoration: InputDecoration(
                  labelText: 'Sort by',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'name', child: Text('Name')),
                  DropdownMenuItem(value: 'email', child: Text('Email')),
                  DropdownMenuItem(value: 'createdAt', child: Text('Date')),
                ],
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                setState(() {
                  _sortAscending = !_sortAscending;
                });
              },
              icon: Icon(
                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getPatientName(Map<String, dynamic> data) {
    if (data['name'] != null && data['name'].toString().isNotEmpty) {
      return data['name'].toString();
    }
    if (data['username'] != null && data['username'].toString().isNotEmpty) {
      return data['username'].toString();
    }
    if (data['displayName'] != null &&
        data['displayName'].toString().isNotEmpty) {
      return data['displayName'].toString();
    }
    if (data['fullName'] != null && data['fullName'].toString().isNotEmpty) {
      return data['fullName'].toString();
    }

    String email = _getPatientEmail(data);
    if (email.isNotEmpty) {
      return email.split('@')[0];
    }
    return 'Unknown Patient';
  }

  String _getPatientEmail(Map<String, dynamic> data) {
    if (data['email'] != null && data['email'].toString().isNotEmpty) {
      return data['email'].toString();
    }
    if (data['emailAddress'] != null &&
        data['emailAddress'].toString().isNotEmpty) {
      return data['emailAddress'].toString();
    }
    return '';
  }

  String _getPatientPhone(Map<String, dynamic> data) {
    if (data['phoneNumber'] != null &&
        data['phoneNumber'].toString().isNotEmpty) {
      return data['phoneNumber'].toString();
    }
    if (data['phone'] != null && data['phone'].toString().isNotEmpty) {
      return data['phone'].toString();
    }
    return '';
  }

  List<QueryDocumentSnapshot> _filterAndSortPatients(
    List<QueryDocumentSnapshot> docs,
  ) {
    if (_searchQuery.isNotEmpty) {
      docs =
          docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = _getPatientName(data).toLowerCase();
            final email = _getPatientEmail(data).toLowerCase();

            return name.contains(_searchQuery) || email.contains(_searchQuery);
          }).toList();
    }

    docs.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;

      dynamic aValue, bValue;

      switch (_sortBy) {
        case 'name':
          aValue = _getPatientName(aData);
          bValue = _getPatientName(bData);
          break;
        case 'email':
          aValue = _getPatientEmail(aData);
          bValue = _getPatientEmail(bData);
          break;
        case 'createdAt':
          aValue = aData['createdAt'] ?? Timestamp.now();
          bValue = bData['createdAt'] ?? Timestamp.now();
          break;
        default:
          aValue = _getPatientName(aData);
          bValue = _getPatientName(bData);
      }

      if (aValue is String && bValue is String) {
        return _sortAscending
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      } else if (aValue is Timestamp && bValue is Timestamp) {
        return _sortAscending
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      }

      return 0;
    });

    return docs;
  }

  void _viewPatientDetails(Map<String, dynamic> data, String patientName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Patient Details - $patientName'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: $patientName'),
                Text('Email: ${_getPatientEmail(data)}'),
                Text('Phone: ${_getPatientPhone(data)}'),
                Text('Gender: ${data['gender'] ?? 'N/A'}'),
                Text('Age: ${data['age'] ?? 'N/A'}'),
                Text('Address: ${data['address'] ?? 'N/A'}'),
                if (data['createdAt'] != null)
                  Text(
                    'Joined: ${DateFormat('MMM dd, yyyy - HH:mm').format((data['createdAt'] as Timestamp).toDate())}',
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _deletePatient(String docId, String patientName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Patient'),
            content: Text('Are you sure you want to delete $patientName?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  try {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(docId)
                        .delete();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Patient deleted successfully'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error deleting patient: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}

class HospitalsManagementPage extends StatefulWidget {
  const HospitalsManagementPage({super.key});

  @override
  State<HospitalsManagementPage> createState() =>
      _HospitalsManagementPageState();
}

class _HospitalsManagementPageState extends State<HospitalsManagementPage> {
  String _searchQuery = '';
  String _sortBy = 'name';
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
        child: Column(
          children: [
            if (isDesktop)
              _buildDesktopControlsRow()
            else
              _buildMobileControlsColumn(),
            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('hospitals')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

                  docs = _filterAndSortHospitals(docs);

                  if (docs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_hospital,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No hospitals found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 3 : 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isDesktop ? 1.3 : 1.8,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final docId = docs[index].id;
                      final emergencyServices =
                          (data['emergencyServices'] as List<dynamic>?)
                              ?.cast<String>() ??
                          [];

                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF004B95,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.local_hospital,
                                      color: Color(0xFF004B95),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      data['name'] ?? 'N/A',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  PopupMenuButton(
                                    iconSize: 20,
                                    itemBuilder:
                                        (context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.edit, size: 16),
                                                SizedBox(width: 8),
                                                Text('Edit'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                  size: 16,
                                                ),
                                                SizedBox(width: 8),
                                                Text('Delete'),
                                              ],
                                            ),
                                          ),
                                        ],
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _editHospital(docId, data);
                                      } else if (value == 'delete') {
                                        _deleteHospital(
                                          docId,
                                          data['name'] ?? 'Hospital',
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['address'] ?? 'No address',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.attach_money,
                                          size: 14,
                                          color: Colors.green,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${data['price'] ?? 0} EGP',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (emergencyServices.isNotEmpty) ...[
                                      const Text(
                                        'Emergency Services:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Wrap(
                                            spacing: 4,
                                            runSpacing: 4,
                                            children:
                                                emergencyServices.take(4).map((
                                                  service,
                                                ) {
                                                  return Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFF01B5A2,
                                                      ).withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      service,
                                                      style: const TextStyle(
                                                        fontSize: 9,
                                                        color: Color(
                                                          0xFF01B5A2,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                          ),
                                        ),
                                      ),
                                      if (emergencyServices.length > 4)
                                        Text(
                                          '+${emergencyServices.length - 4} more',
                                          style: const TextStyle(
                                            fontSize: 9,
                                            color: Colors.grey,
                                          ),
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopControlsRow() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search hospitals...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            value: _sortBy,
            decoration: InputDecoration(
              labelText: 'Sort by',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'name', child: Text('Name')),
              DropdownMenuItem(value: 'address', child: Text('Address')),
              DropdownMenuItem(value: 'price', child: Text('Price')),
            ],
            onChanged: (value) {
              setState(() {
                _sortBy = value!;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            setState(() {
              _sortAscending = !_sortAscending;
            });
          },
          icon: Icon(
            _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => _addNewHospital(),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF004B95),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileControlsColumn() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search hospitals...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _sortBy,
                decoration: InputDecoration(
                  labelText: 'Sort by',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'name', child: Text('Name')),
                  DropdownMenuItem(value: 'address', child: Text('Address')),
                  DropdownMenuItem(value: 'price', child: Text('Price')),
                ],
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                setState(() {
                  _sortAscending = !_sortAscending;
                });
              },
              icon: Icon(
                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<QueryDocumentSnapshot> _filterAndSortHospitals(
    List<QueryDocumentSnapshot> docs,
  ) {
    if (_searchQuery.isNotEmpty) {
      docs =
          docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['name'] ?? '').toString().toLowerCase();
            final address = (data['address'] ?? '').toString().toLowerCase();

            return name.contains(_searchQuery) ||
                address.contains(_searchQuery);
          }).toList();
    }

    docs.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;

      dynamic aValue, bValue;

      switch (_sortBy) {
        case 'name':
          aValue = aData['name'] ?? '';
          bValue = bData['name'] ?? '';
          break;
        case 'address':
          aValue = aData['address'] ?? '';
          bValue = bData['address'] ?? '';
          break;
        case 'price':
          aValue = aData['price'] ?? 0;
          bValue = bData['price'] ?? 0;
          break;
        default:
          aValue = aData['name'] ?? '';
          bValue = bData['name'] ?? '';
      }

      if (aValue is String && bValue is String) {
        return _sortAscending
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      } else if (aValue is num && bValue is num) {
        return _sortAscending
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      }

      return 0;
    });

    return docs;
  }

  void _addNewHospital() {
    showDialog(
      context: context,
      builder: (context) => const HospitalEditDialog(),
    );
  }

  void _editHospital(String docId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => HospitalEditDialog(docId: docId, initialData: data),
    );
  }

  void _deleteHospital(String docId, String hospitalName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Hospital'),
            content: Text('Are you sure you want to delete $hospitalName?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  try {
                    await FirebaseFirestore.instance
                        .collection('hospitals')
                        .doc(docId)
                        .delete();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Hospital deleted successfully'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error deleting hospital: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}

class HospitalEditDialog extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? initialData;

  const HospitalEditDialog({super.key, this.docId, this.initialData});

  @override
  State<HospitalEditDialog> createState() => _HospitalEditDialogState();
}

class _HospitalEditDialogState extends State<HospitalEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _priceController;
  List<String> _emergencyServices = [];
  bool _isLoading = false;

  final List<String> _availableServices = [
    'Dermatology',
    'Neurology',
    'General surgery',
    'Cardiology',
    'Emergency',
    'Orthopedics',
    'Pediatrics',
    'Gynecology',
    'Psychiatry',
    'Oncology',
    'Radiology',
    'Urology',
    'Internal Medicine',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialData?['name'] ?? '',
    );
    _addressController = TextEditingController(
      text: widget.initialData?['address'] ?? '',
    );
    _priceController = TextEditingController(
      text: (widget.initialData?['price'] ?? 0).toString(),
    );
    _emergencyServices =
        (widget.initialData?['emergencyServices'] as List<dynamic>?)
            ?.cast<String>() ??
        [];
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.docId != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Hospital' : 'Add New Hospital'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width > 600 ? 500 : double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Hospital Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price (EGP)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Emergency Services:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _availableServices.map((service) {
                      final isSelected = _emergencyServices.contains(service);
                      return FilterChip(
                        label: Text(service),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _emergencyServices.add(service);
                            } else {
                              _emergencyServices.remove(service);
                            }
                          });
                        },
                        selectedColor: const Color(0xFF004B95).withOpacity(0.2),
                        checkmarkColor: const Color(0xFF004B95),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveHospital,
          child:
              _isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : Text(isEditing ? 'Save' : 'A'),
        ),
      ],
    );
  }

  void _saveHospital() async {
    if (_nameController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter hospital name')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'price': int.tryParse(_priceController.text) ?? 0,
        'emergencyServices': _emergencyServices,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.docId != null) {
        await FirebaseFirestore.instance
            .collection('hospitals')
            .doc(widget.docId)
            .update(data);
      } else {
        data['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('hospitals').add(data);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hospital ${widget.docId != null ? 'updated' : 'added'} successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving hospital: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}

class PharmaciesManagementPage extends StatefulWidget {
  const PharmaciesManagementPage({super.key});

  @override
  State<PharmaciesManagementPage> createState() =>
      _PharmaciesManagementPageState();
}

class _PharmaciesManagementPageState extends State<PharmaciesManagementPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search pharmacies...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged:
                        (value) =>
                            setState(() => _searchQuery = value.toLowerCase()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('pharmacies')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

                  if (_searchQuery.isNotEmpty) {
                    docs =
                        docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final name =
                              (data['name'] ?? '').toString().toLowerCase();
                          final city =
                              (data['city'] ?? '').toString().toLowerCase();
                          return name.contains(_searchQuery) ||
                              city.contains(_searchQuery);
                        }).toList();
                  }

                  if (docs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_pharmacy,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No pharmacies found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 3 : 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isDesktop ? 1.2 : 2.0,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final docId = docs[index].id;

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF4CAF50,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.local_pharmacy,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      data['name'] ?? 'N/A',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  PopupMenuButton(
                                    itemBuilder:
                                        (context) => [
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                SizedBox(width: 8),
                                                Text('Delete'),
                                              ],
                                            ),
                                          ),
                                        ],
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        _deletePharmacy(
                                          docId,
                                          data['name'] ?? 'Pharmacy',
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${data['address'] ?? ''}, ${data['city'] ?? ''}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    data['city'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deletePharmacy(String docId, String pharmacyName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Pharmacy'),
            content: Text('Are you sure you want to delete $pharmacyName?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  try {
                    await FirebaseFirestore.instance
                        .collection('pharmacies')
                        .doc(docId)
                        .delete();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pharmacy deleted successfully'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error deleting pharmacy: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}

class LabsManagementPage extends StatefulWidget {
  const LabsManagementPage({super.key});

  @override
  State<LabsManagementPage> createState() => _LabsManagementPageState();
}

class _LabsManagementPageState extends State<LabsManagementPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search labs...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged:
                        (value) =>
                            setState(() => _searchQuery = value.toLowerCase()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('labs_centres')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];

                  final filteredDocs =
                      _searchQuery.isEmpty
                          ? docs
                          : docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final name =
                                (data['name'] ?? '').toString().toLowerCase();
                            final type =
                                (data['type'] ?? '').toString().toLowerCase();
                            final location =
                                (data['location'] ?? '')
                                    .toString()
                                    .toLowerCase();
                            return name.contains(_searchQuery) ||
                                type.contains(_searchQuery) ||
                                location.contains(_searchQuery);
                          }).toList();

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final data =
                          filteredDocs[index].data() as Map<String, dynamic>;
                      final docId = filteredDocs[index].id;
                      final availableTimes =
                          (data['availableTimes'] as List<dynamic>?)
                              ?.cast<String>() ??
                          [];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE91E63).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.science,
                              color: Color(0xFFE91E63),
                            ),
                          ),
                          title: Text(
                            data['name'] ?? 'N/A',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Type: ${data['type'] ?? 'N/A'}'),
                              Text('Location: ${data['location'] ?? 'N/A'}'),
                              Text('Price: ${data['price'] ?? 0} EGP'),
                              if (availableTimes.isNotEmpty)
                                Text(
                                  'Available: ${availableTimes.join(', ')}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder:
                                (context) => [
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                            onSelected: (value) {
                              if (value == 'delete') {
                                _deleteLab(docId, data['name'] ?? 'Lab');
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteLab(String docId, String labName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Lab'),
            content: Text('Are you sure you want to delete $labName?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  try {
                    await FirebaseFirestore.instance
                        .collection('labs_centres')
                        .doc(docId)
                        .delete();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lab deleted successfully'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error deleting lab: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
