import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isDropdownVisible = false;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          _userData = doc.data();
          _populateControllers();
        } else {
          // If no user document exists, create one with basic info
          _userData = {
            'username': user.displayName ?? 'User',
            'email': user.email ?? '',
            'phoneNumber': user.phoneNumber ?? '',
            'address': '',
            'role': 'patient',
          };
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      // Fallback data if Firebase fails
      _userData = {
        'username': 'User',
        'email': 'user@example.com',
        'phoneNumber': '',
        'address': '',
        'role': 'patient',
      };
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateControllers() {
    if (_userData != null) {
      _nameController.text = _userData!['username'] ?? '';
      _emailController.text = _userData!['email'] ?? '';
      _phoneController.text = _userData!['phoneNumber'] ?? '';
      _addressController.text = _userData!['address'] ?? '';
    }
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'username': _nameController.text,
          'email': _emailController.text,
          'phoneNumber': _phoneController.text,
          'address': _addressController.text,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Update email in Firebase Auth if changed
        if (_emailController.text != user.email) {
          await user.updateEmail(_emailController.text);
        }

        setState(() {
          _isEditing = false;
          _userData!['username'] = _nameController.text;
          _userData!['email'] = _emailController.text;
          _userData!['phoneNumber'] = _phoneController.text;
          _userData!['address'] = _addressController.text;
        });

        _showSuccessMessage('Profile updated successfully!');
      }
    } catch (e) {
      print('Error saving profile: $e');
      _showErrorMessage('Error updating profile: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _navigateToService(String service) {
    // Close dropdown first
    setState(() {
      _isDropdownVisible = false;
    });

    switch (service.toLowerCase()) {
      case 'doctors':
        Navigator.pushNamed(context, '/doctorOptions');
        break;
      case 'hospitals':
        Navigator.pushNamed(context, '/hospitalEmergency');
        break;
      case 'labs':
        Navigator.pushNamed(context, '/labTypeSelection');
        break;
      case 'scans':
        Navigator.pushNamed(context, '/scanTypeSelection');
        break;
      case 'pharmacies':
      case 'pharmacy':
        Navigator.pushNamed(context, '/pharmacyList');
        break;
      case 'chat':
      case 'chatbot':
        Navigator.pushNamed(context, '/chatbot');
        break;
      case 'guide':
        Navigator.pushNamed(context, '/emergencyGuide');
        break;
      case 'my reservations':
        Navigator.pushNamed(context, '/reservations_search');
        break;
      case 'order history':
        Navigator.pushNamed(context, '/patientBookingsDashboard');
        break;
      case 'medical history':
        _showMedicalHistory();
        break;
      default:
        _showErrorMessage('Unknown service: $service');
        break;
    }
  }

  void _showMedicalHistory() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Row(
              children: [
                Icon(Icons.folder_shared, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text('Medical History'),
              ],
            ),
            content: const Text(
              'Medical history feature is coming soon! This will include your complete medical records, test results, and treatment history.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK', style: TextStyle(color: Colors.blue[600])),
              ),
            ],
          ),
    );
  }

  void _handleLogout() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Row(
              children: [
                Icon(Icons.logout, color: Colors.red[600]),
                const SizedBox(width: 8),
                const Text('Logout'),
              ],
            ),
            content: const Text(
              'Are you sure you want to logout from your account?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await _auth.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  } catch (e) {
                    print('Logout error: $e');
                    _showErrorMessage('Error logging out. Please try again.');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  void _handleDropdownNavigation(String action) {
    print('🔥 Dropdown action triggered: $action');

    setState(() {
      _isDropdownVisible = false;
    });

    try {
      switch (action) {
        case 'dashboard':
          print('🔥 Navigating to dashboard');
          Navigator.pushReplacementNamed(context, '/patientDashboard');
          break;
        case 'reservations':
          print('🔥 Navigating to reservations');
          Navigator.pushNamed(context, '/reservations_search');
          break;
        case 'orders':
          print('🔥 Navigating to orders');
          Navigator.pushNamed(context, '/patientBookingsDashboard');
          break;
        case 'medical':
          print('🔥 Showing medical history');
          _showMedicalHistory();
          break;
        case 'logout':
          print('🔥 Handling logout');
          _handleLogout();
          break;
        default:
          print('🔥 Unknown action: $action');
          _showErrorMessage('Navigation option not available');
      }
    } catch (e) {
      print('🔥 Navigation error: $e');
      _showErrorMessage('Navigation failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1E3A8A), // Deep blue at top
                    Color(0xFF3B82F6), // Lighter blue at bottom
                  ],
                ),
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child:
                        _isLoading
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                            : SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  _buildSearchBar(),
                                  const SizedBox(height: 20),
                                  _buildProfileSection(),
                                  const SizedBox(height: 25),
                                  _buildServiceGrid(),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                  ),
                ],
              ),
            ),
            // Dropdown overlay with animation
            if (_isDropdownVisible) _buildProfileDropdown(),
            // Invisible overlay to close dropdown when tapping outside
            if (_isDropdownVisible)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _isDropdownVisible = false),
                  child: Container(color: Colors.transparent),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF1D4ED8)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Enhanced top row with back arrow, logo and icons
          Row(
            children: [
              // Back Arrow Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Enhanced Tameny Logo
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/tameny_header_logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFF1E3A8A),
                        size: 24,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'Tameny',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              // Enhanced Header Icons
              GestureDetector(
                onTap: () {
                  _showSuccessMessage('Notifications feature coming soon!');
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Profile Icon with Dropdown Toggle
              GestureDetector(
                onTap: () {
                  print(
                    '🔥 Profile icon tapped. Current state: $_isDropdownVisible',
                  );
                  setState(() => _isDropdownVisible = !_isDropdownVisible);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                        _isDropdownVisible
                            ? Colors.white.withOpacity(0.25)
                            : Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        _isDropdownVisible
                            ? Border.all(color: Colors.white.withOpacity(0.3))
                            : null,
                  ),
                  child: Icon(
                    _isDropdownVisible
                        ? Icons.close_rounded
                        : Icons.person_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Enhanced Navigation Menu
          _buildNavigationMenu(),
        ],
      ),
    );
  }

  Widget _buildNavigationMenu() {
    final services = [
      {'name': 'Doctors', 'icon': Icons.medical_services},
      {'name': 'Hospitals', 'icon': Icons.local_hospital},
      {'name': 'Labs', 'icon': Icons.biotech},
      {'name': 'Scans', 'icon': Icons.monitor_heart},
      {'name': 'Pharmacies', 'icon': Icons.medication},
      {'name': 'Guide', 'icon': Icons.help_outline},
      {'name': 'Chat', 'icon': Icons.support_agent_outlined},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            services.map((service) {
              return Container(
                margin: const EdgeInsets.only(right: 24),
                child: GestureDetector(
                  onTap: () => _navigateToService(service['name'] as String),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        service['icon'] as IconData,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service['name'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/search');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.blue.withOpacity(0.03),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF10B981),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Search for doctors, hospitals, labs...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _showSuccessMessage('Voice search coming soon!');
                },
                child: Icon(
                  Icons.mic_rounded,
                  color: Colors.grey[500],
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: const Color(0xFF3B82F6),
                child: Text(
                  _userData?['username']
                          ?.toString()
                          .substring(0, 1)
                          .toUpperCase() ??
                      'U',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${_userData?['username'] ?? 'User'}!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Email: ${_userData?['email'] ?? ''} | Phone: ${_userData?['phoneNumber'] ?? ''}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Edit Profile Button
          if (!_isEditing)
            ElevatedButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

          // Edit Form
          if (_isEditing) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    'Full Name',
                    _nameController,
                    Icons.person,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInputField(
                    'Email',
                    _emailController,
                    Icons.email,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    'Phone',
                    _phoneController,
                    Icons.phone,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInputField(
                    'Address',
                    _addressController,
                    Icons.location_on,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        _isSaving
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'Save Changes',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _populateControllers(); // Reset to original values
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF3B82F6)),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceGrid() {
    final services = [
      {
        'title': 'Doctors',
        'subtitle': 'Book appointments with specialists',
        'icon': Icons.medical_services,
        'color': const Color(0xFF3B82F6),
      },
      {
        'title': 'Hospitals',
        'subtitle': 'Find and visit medical facilities',
        'icon': Icons.local_hospital,
        'color': const Color(0xFF06B6D4),
      },
      {
        'title': 'Labs',
        'subtitle': 'Schedule medical tests and check-ups',
        'icon': Icons.science,
        'color': const Color(0xFFF59E0B),
      },
      {
        'title': 'Scans',
        'subtitle': 'Book diagnostic imaging services',
        'icon': Icons.monitor_heart,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'title': 'Pharmacy',
        'subtitle': 'Order medications and health products',
        'icon': Icons.local_pharmacy,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Chatbot',
        'subtitle': 'Get instant medical assistance',
        'icon': Icons.chat_bubble_outline,
        'color': const Color(0xFF06B6D4),
      },
      {
        'title': 'My Reservations',
        'subtitle': 'View and manage your hospital bookings',
        'icon': Icons.calendar_today,
        'color': const Color(0xFFF59E0B),
      },
      {
        'title': 'Order History',
        'subtitle': 'Check all your past orders and activities',
        'icon': Icons.history,
        'color': const Color(0xFFEF4444),
      },
      {
        'title': 'Medical History',
        'subtitle': 'Review your personal medical records',
        'icon': Icons.folder_shared,
        'color': const Color(0xFF06B6D4),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return _buildServiceCard(
            service['title'] as String,
            service['subtitle'] as String,
            service['icon'] as IconData,
            service['color'] as Color,
          );
        },
      ),
    );
  }

  Widget _buildServiceCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () => _navigateToService(title),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    height: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDropdown() {
    return Positioned(
      top: 120, // Position below the header
      right: 20,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 40,
              offset: const Offset(0, 16),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User info header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF3B82F6),
                    child: Text(
                      _userData?['username']
                              ?.toString()
                              .substring(0, 1)
                              .toUpperCase() ??
                          'U',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userData?['username'] ?? 'User',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _userData?['email'] ?? 'user@example.com',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Menu items
            _buildDropdownItem(
              icon: Icons.dashboard_rounded,
              title: 'Dashboard',
              onTap:
                  () => Navigator.pushReplacementNamed(
                    context,
                    '/patientDashboard',
                  ),
            ),
            _buildDropdownItem(
              icon: Icons.calendar_today_rounded,
              title: 'My Reservations',
              onTap: () => Navigator.pushNamed(context, '/reservations_search'),
            ),
            _buildDropdownItem(
              icon: Icons.history_rounded,
              title: 'Order History',
              onTap:
                  () =>
                      Navigator.pushNamed(context, '/patientBookingsDashboard'),
            ),
            _buildDropdownItem(
              icon: Icons.folder_shared_rounded,
              title: 'Medical History',
              onTap: () => _showMedicalHistory(),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            _buildDropdownItem(
              icon: Icons.logout_rounded,
              title: 'Logout',
              onTap: () => _handleLogout(),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print('🔥 Dropdown item tapped: $title');
          onTap();
        },
        borderRadius: BorderRadius.circular(8),
        splashColor:
            isDestructive
                ? Colors.red.withOpacity(0.1)
                : Colors.blue.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color:
                    isDestructive ? Colors.red[600] : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color:
                      isDestructive ? Colors.red[600] : const Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
