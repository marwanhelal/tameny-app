import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HospitalConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> hospital;
  final DateTime appointmentDate;
  final TimeOfDay appointmentTime;
  final String emergencyType;
  final String paymentMethod;
  final String email;
  final int price;
  final double originalPrice;
  final double discountPercentage;
  final double finalPrice;
  final bool insuranceVerified;
  final String insuranceProvider;

  HospitalConfirmationScreen({
    super.key,
    required this.hospital,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.emergencyType,
    required this.paymentMethod,
    required this.email,
    required this.price,
    this.originalPrice = 0.0,
    this.discountPercentage = 0.0,
    this.finalPrice = 0.0,
    this.insuranceVerified = false,
    this.insuranceProvider = '',
  });

  final String referenceNumber =
      "HOSP-${Random().nextInt(1000000).toString().padLeft(6, '0')}";

  @override
  State<HospitalConfirmationScreen> createState() =>
      _HospitalConfirmationScreenState();
}

class _HospitalConfirmationScreenState extends State<HospitalConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _checkController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    
    _fadeController.forward();
    _slideController.forward();
    Future.delayed(Duration(milliseconds: 500), () {
      _checkController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  void _navigateToHome(BuildContext context) async {
    
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection('hospital_bookings').add({
      'userId': user?.uid ?? 'anonymous',
      'hospitalName': widget.hospital['name'],
      'hospitalId': widget.hospital['id'] ?? '',
      'appointmentDate': widget.appointmentDate,
      'appointmentTime': widget.appointmentTime.format(context),
      'emergencyType': widget.emergencyType,
      'paymentMethod': widget.paymentMethod,
      'email': widget.email,
      'originalPrice':
          widget.originalPrice > 0
              ? widget.originalPrice
              : widget.price.toDouble(),
      'discountPercentage': widget.discountPercentage,
      'finalPrice':
          widget.finalPrice > 0 ? widget.finalPrice : widget.price.toDouble(),
      'insuranceVerified': widget.insuranceVerified,
      'insuranceProvider': widget.insuranceProvider,
      'timestamp': FieldValue.serverTimestamp(),
    });

    
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/patient_dashboard', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  
                  _buildSuccessIcon(),

                  const SizedBox(height: 30),

                  
                  _buildSuccessMessage(),

                  const SizedBox(height: 40),

                  
                  _buildAppointmentDetailsCard(),

                  const SizedBox(height: 30),

                  
                  if (widget.insuranceVerified) ...[
                    _buildInsuranceCard(),
                    const SizedBox(height: 30),
                  ],

                  
                  _buildReferenceNumberCard(),

                  const SizedBox(height: 40),

                  
                  _buildActionButton(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return AnimatedBuilder(
      animation: _checkController,
      builder: (context, child) {
        return Transform.scale(
          scale: _checkAnimation.value,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF388E3C),
                  const Color(0xFF2E7D32),
                  const Color(0xFF1B5E20),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(Icons.check_rounded, color: Colors.white, size: 50),
          ),
        );
      },
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        Text(
          "Appointment Confirmed!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          widget.insuranceVerified
              ? "Your medical appointment has been successfully booked with insurance benefits applied"
              : "Your medical appointment has been successfully booked",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade300,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAppointmentDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade800, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.medical_information_outlined,
                  color: const Color(0xFF64B5F6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                "Appointment Details",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          
          _buildDetailRow(
            icon: Icons.medical_services_outlined,
            label: "Medical Case",
            value: widget.emergencyType,
            iconColor: const Color(0xFFE91E63),
          ),

          const SizedBox(height: 16),

          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: "Date",
            value:
                "${widget.appointmentDate.day}/${widget.appointmentDate.month}/${widget.appointmentDate.year}",
            iconColor: const Color(0xFF4CAF50),
          ),

          const SizedBox(height: 16),

          _buildDetailRow(
            icon: Icons.access_time_outlined,
            label: "Time",
            value: widget.appointmentTime.format(context),
            iconColor: const Color(0xFFFF9800),
          ),

          const SizedBox(height: 16),

          _buildDetailRow(
            icon: Icons.payment_outlined,
            label: "Payment",
            value: widget.paymentMethod,
            iconColor: const Color(0xFF9C27B0),
          ),

          const SizedBox(height: 16),

          
          if (widget.insuranceVerified) ...[
            _buildDetailRow(
              icon: Icons.attach_money_outlined,
              label: "Original Amount",
              value: "EGP ${widget.originalPrice.toInt()}",
              iconColor: const Color(0xFF757575),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.discount_outlined,
              label:
                  "Insurance Discount (${widget.discountPercentage.toInt()}%)",
              value:
                  "-EGP ${(widget.originalPrice * widget.discountPercentage / 100).toInt()}",
              iconColor: const Color(0xFF2E7D5E),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2E7D5E).withOpacity(0.2),
                    const Color(0xFF1B5E20).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2E7D5E).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D5E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.savings_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Final Amount",
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFF2E7D5E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "EGP ${widget.finalPrice.toInt()}",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D5E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'SAVED ${widget.discountPercentage.toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else
            _buildDetailRow(
              icon: Icons.attach_money_outlined,
              label: "Amount",
              value: "EGP ${widget.price}",
              iconColor: const Color(0xFF00BCD4),
            ),
        ],
      ),
    );
  }

  Widget _buildInsuranceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00BCD4),
            const Color(0xFF0097A7),
            const Color(0xFF00695C),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00BCD4).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.health_and_safety_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Insurance Benefits Applied",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.insuranceProvider,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D5E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.discountPercentage.toInt()}% OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "You Saved",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      "EGP ${(widget.originalPrice * widget.discountPercentage / 100).toInt()}",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.savings_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceNumberCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1565C0), const Color(0xFF0D47A1)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            "Booking Reference",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              widget.referenceNumber,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Save this reference number for your records",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          _navigateToHome(context);
        },
        icon: Icon(Icons.home_outlined, color: Colors.white, size: 24),
        label: Text(
          "Back to Home",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: const Color(0xFF2E7D32).withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}


