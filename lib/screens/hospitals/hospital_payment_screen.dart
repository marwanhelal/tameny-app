import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/email_service.dart';
import 'hospital_summary_screen.dart';

class HospitalPaymentScreen extends StatefulWidget {
  final Map<String, dynamic> hospitalData;
  final String hospitalId;
  final String emergencyType;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;

  const HospitalPaymentScreen({
    super.key,
    required this.hospitalData,
    required this.hospitalId,
    required this.emergencyType,
    required this.selectedDate,
    required this.selectedTime,
  });

  @override
  State<HospitalPaymentScreen> createState() => _HospitalPaymentScreenState();
}

class _HospitalPaymentScreenState extends State<HospitalPaymentScreen>
    with TickerProviderStateMixin {
  String? paymentMethod;
  final emailController = TextEditingController();
  final insuranceIdController = TextEditingController();
  bool isProcessing = false;
  bool isVerifyingInsurance = false;
  bool insuranceVerified = false;
  double discountPercentage = 0.0;
  String insuranceProvider = '';

  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _glowController;
  late AnimationController _scanController;
  late AnimationController _breatheController;
  late AnimationController _floatController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _scanAnimation;
  late Animation<double> _breatheAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);

    _scanController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _breatheController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _floatController = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scanController, curve: Curves.linear));

    _breatheAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _glowController.dispose();
    _scanController.dispose();
    _breatheController.dispose();
    _floatController.dispose();
    emailController.dispose();
    insuranceIdController.dispose();
    super.dispose();
  }

  
  double get finalPrice {
    final originalPrice = double.parse(widget.hospitalData['price'].toString());
    final discountAmount = originalPrice * (discountPercentage / 100);
    return originalPrice - discountAmount;
  }

  
  Future<void> _verifyInsurance() async {
    if (insuranceIdController.text.trim().isEmpty) return;

    setState(() => isVerifyingInsurance = true);

    try {
      final insuranceId = insuranceIdController.text.trim();

      
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection('insurance_providers')
              .where('insuranceId', isEqualTo: insuranceId)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;

        setState(() {
          insuranceVerified = true;
          discountPercentage = (data['discountPercentage'] ?? 0.0).toDouble();
          insuranceProvider = data['provider'] ?? 'Unknown Provider';
        });

        
        await FirebaseFirestore.instance
            .collection('insurance_verifications')
            .add({
              'insuranceId': insuranceId,
              'provider': insuranceProvider,
              'discountPercentage': discountPercentage,
              'verifiedAt': FieldValue.serverTimestamp(),
              'userId': 'anonymous', 
            });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Insurance verified! ${discountPercentage.toInt()}% discount applied',
            ),
            backgroundColor: const Color(0xFF2E7D5E),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        setState(() {
          insuranceVerified = false;
          discountPercentage = 0.0;
          insuranceProvider = '';
        });

        
        await FirebaseFirestore.instance
            .collection('insurance_verifications')
            .add({
              'insuranceId': insuranceId,
              'status': 'failed',
              'reason': 'Insurance ID not found',
              'attemptedAt': FieldValue.serverTimestamp(),
              'userId': 'anonymous', 
            });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insurance ID not found'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        insuranceVerified = false;
        discountPercentage = 0.0;
        insuranceProvider = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error verifying insurance: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => isVerifyingInsurance = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hospital = widget.hospitalData;
    final appointmentDate = widget.selectedDate;
    final appointmentTime = widget.selectedTime;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FFFE), 
              Color(0xFFF0F8FF), 
              Color(0xFFE8F4FD), 
              Color(0xFFE1F0FA), 
              Color(0xFFDAECF7), 
            ],
          ),
        ),
        child: Stack(
          children: [
            
            ...List.generate(
              15,
              (index) => AnimatedBuilder(
                animation: _floatAnimation,
                builder: (context, child) {
                  return Positioned(
                    left:
                        (index * 140.0 + 60) %
                        MediaQuery.of(context).size.width,
                    top:
                        (index * 200.0 + 80 + _floatAnimation.value) %
                        MediaQuery.of(context).size.height,
                    child: Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            index % 3 == 0
                                ? const Color(0xFF2E7D5E).withOpacity(
                                  0.4,
                                ) 
                                : index % 3 == 1
                                ? const Color(0xFF1976D2).withOpacity(
                                  0.3,
                                ) 
                                : const Color(
                                  0xFF546E7A,
                                ).withOpacity(0.2), 
                            Colors.transparent,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            ),

            
            AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height,
                  ),
                  painter: MedicalGridPainter(_scanAnimation.value),
                );
              },
            ),

            SafeArea(
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      
                      Row(
                        children: [
                          
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: AnimatedBuilder(
                              animation: _breatheAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _breatheAnimation.value,
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(
                                          0xFF2E7D5E,
                                        ).withOpacity(0.2),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF2E7D5E,
                                          ).withOpacity(0.1),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 20,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back_ios_rounded,
                                      color: Color(0xFF2E7D5E),
                                      size: 20,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const Spacer(),
                          
                          AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF2E7D5E,
                                    ).withOpacity(0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF2E7D5E,
                                      ).withOpacity(0.1 * _glowAnimation.value),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2E7D5E),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF2E7D5E,
                                            ).withOpacity(0.4),
                                            blurRadius: 4,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "SECURE",
                                      style: TextStyle(
                                        color: Color(0xFF2E7D5E),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      
                      AnimatedBuilder(
                        animation: _breatheAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _breatheAnimation.value,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(
                                    0xFF1976D2,
                                  ).withOpacity(0.1),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF1976D2,
                                    ).withOpacity(0.08),
                                    blurRadius: 25,
                                    spreadRadius: 3,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 40,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(
                                                0xFF1976D2,
                                              ).withOpacity(0.1),
                                              const Color(
                                                0xFF1976D2,
                                              ).withOpacity(0.05),
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.account_balance_outlined,
                                          color: Color(0xFF1976D2),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Payment Portal",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1976D2),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Secure Medical Transaction",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: const Color(
                                                0xFF546E7A,
                                              ).withOpacity(0.8),
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          const Color(
                                            0xFF1976D2,
                                          ).withOpacity(0.2),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    hospital['name'],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF263238),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              
                              buildInsuranceSection(),

                              const SizedBox(height: 24),

                              
                              buildPaymentMethodSection(),

                              const SizedBox(height: 24),

                              
                              buildEmailSection(),

                              const SizedBox(height: 28),

                              
                              buildAppointmentSummary(),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      
                      buildConfirmationButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInsuranceSection() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00BCD4).withOpacity(0.1),
                          const Color(0xFF00BCD4).withOpacity(0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.health_and_safety_outlined,
                      color: Color(0xFF00BCD4),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Health Insurance",
                    style: TextStyle(
                      color: Color(0xFF00BCD4),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  if (insuranceVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D5E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${discountPercentage.toInt()}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      insuranceVerified
                          ? const Color(0xFF2E7D5E).withOpacity(0.3)
                          : const Color(0xFF00BCD4).withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (insuranceVerified
                            ? const Color(0xFF2E7D5E)
                            : const Color(0xFF00BCD4))
                        .withOpacity(0.08 * _glowAnimation.value),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: insuranceIdController,
                    style: const TextStyle(
                      color: Color(0xFF263238),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: "Enter insurance ID (case-sensitive)",
                      hintStyle: const TextStyle(
                        color: Color(0xFF90A4AE),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              (insuranceVerified
                                      ? const Color(0xFF2E7D5E)
                                      : const Color(0xFF00BCD4))
                                  .withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.card_membership_outlined,
                          color:
                              insuranceVerified
                                  ? const Color(0xFF2E7D5E)
                                  : const Color(0xFF00BCD4),
                          size: 18,
                        ),
                      ),
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        child: GestureDetector(
                          onTap: isVerifyingInsurance ? null : _verifyInsurance,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF00BCD4),
                                  const Color(0xFF0097A7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child:
                                isVerifyingInsurance
                                    ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : const Text(
                                      'Verify',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (insuranceVerified) ...[
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF2E7D5E).withOpacity(0.1),
                            const Color(0xFF2E7D5E).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF2E7D5E).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D5E),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  insuranceProvider,
                                  style: const TextStyle(
                                    color: Color(0xFF2E7D5E),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${discountPercentage.toInt()}% discount applied',
                                  style: const TextStyle(
                                    color: Color(0xFF546E7A),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D5E),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '-EGY ${(double.parse(widget.hospitalData['price'].toString()) * discountPercentage / 100).toInt()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildPaymentMethodSection() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2E7D5E).withOpacity(0.1),
                          const Color(0xFF2E7D5E).withOpacity(0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.payment_outlined,
                      color: Color(0xFF2E7D5E),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Payment Method",
                    style: TextStyle(
                      color: Color(0xFF2E7D5E),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF2E7D5E).withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF2E7D5E,
                    ).withOpacity(0.08 * _glowAnimation.value),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  hintStyle: const TextStyle(
                    color: Color(0xFF90A4AE),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2E7D5E).withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Color(0xFF2E7D5E),
                      size: 18,
                    ),
                  ),
                ),
                hint: const Text("Select payment method"),
                value: paymentMethod,
                dropdownColor: Colors.white,
                style: const TextStyle(
                  color: Color(0xFF263238),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                iconEnabledColor: const Color(0xFF2E7D5E),
                iconSize: 24,
                items: [
                  DropdownMenuItem(
                    value: "Pay at hospital",
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFF7043), Color(0xFFFF5722)],
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text("Pay at Hospital"),
                        ],
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: "Pay online",
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF2E7D5E), Color(0xFF1B5E20)],
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text("Pay Online"),
                        ],
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    paymentMethod = value;
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildEmailSection() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1976D2).withOpacity(0.1),
                          const Color(0xFF1976D2).withOpacity(0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.email_outlined,
                      color: Color(0xFF1976D2),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Email Confirmation",
                    style: TextStyle(
                      color: Color(0xFF1976D2),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF1976D2).withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF1976D2,
                    ).withOpacity(0.08 * _glowAnimation.value),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                  color: Color(0xFF263238),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: "Enter your email address",
                  hintStyle: const TextStyle(
                    color: Color(0xFF90A4AE),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1976D2).withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.alternate_email,
                      color: Color(0xFF1976D2),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildAppointmentSummary() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF546E7A).withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF546E7A).withOpacity(0.08),
                  blurRadius: 20,
                  spreadRadius: 3,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF546E7A).withOpacity(0.1),
                              const Color(0xFF546E7A).withOpacity(0.05),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.summarize_outlined,
                          color: Color(0xFF546E7A),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Appointment Summary",
                        style: TextStyle(
                          color: Color(0xFF546E7A),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildSummaryRow(
                  "Emergency Type",
                  widget.emergencyType,
                  Icons.medical_services_outlined,
                ),
                const SizedBox(height: 16),
                _buildSummaryRow(
                  "Date",
                  DateFormat('EEEE, MMM dd, yyyy').format(widget.selectedDate),
                  Icons.calendar_today_outlined,
                ),
                const SizedBox(height: 16),
                _buildSummaryRow(
                  "Time",
                  widget.selectedTime.format(context),
                  Icons.access_time_outlined,
                ),
                const SizedBox(height: 16),

                
                if (insuranceVerified) ...[
                  _buildSummaryRow(
                    "Original Cost",
                    "EGY ${widget.hospitalData['price']}",
                    Icons.payments_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    "Insurance Discount (${discountPercentage.toInt()}%)",
                    "-EGY ${(double.parse(widget.hospitalData['price'].toString()) * discountPercentage / 100).toInt()}",
                    Icons.discount_outlined,
                    isDiscount: true,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2E7D5E).withOpacity(0.1),
                          const Color(0xFF2E7D5E).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF2E7D5E).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D5E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.savings_outlined,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Final Cost: ",
                          style: TextStyle(
                            color: Color(0xFF546E7A),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "EGY ${finalPrice.toInt()}",
                          style: const TextStyle(
                            color: Color(0xFF2E7D5E),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else
                  _buildSummaryRow(
                    "Cost",
                    "EGY ${widget.hospitalData['price']}",
                    Icons.payments_outlined,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    IconData icon, {
    bool isDiscount = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFF8FFFE), const Color(0xFFF0F8FF)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDiscount
                  ? const Color(0xFF2E7D5E).withOpacity(0.2)
                  : const Color(0xFF546E7A).withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (isDiscount
                          ? const Color(0xFF2E7D5E)
                          : const Color(0xFF546E7A))
                      .withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color:
                  isDiscount
                      ? const Color(0xFF2E7D5E)
                      : const Color(0xFF546E7A),
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "$label: ",
            style: const TextStyle(
              color: Color(0xFF90A4AE),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color:
                    isDiscount
                        ? const Color(0xFF2E7D5E)
                        : const Color(0xFF263238),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildConfirmationButton() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final canProceed =
            paymentMethod != null && emailController.text.trim().isNotEmpty;

        return GestureDetector(
          onTap:
              canProceed && !isProcessing
                  ? () async {
                    setState(() => isProcessing = true);

                    try {
                      await EmailService.sendEmail(
                        toEmail: emailController.text.trim(),
                        subject: 'Hospital Appointment Confirmation',
                        content:
                            '''Your appointment at ${widget.hospitalData['name']} for ${widget.emergencyType} is confirmed on ${DateFormat('yyyy-MM-dd').format(widget.selectedDate)} at ${widget.selectedTime.format(context)}.\nPayment method: ${paymentMethod ?? 'N/A'}\n${insuranceVerified ? 'Insurance: $insuranceProvider (${discountPercentage.toInt()}% discount applied)\n' : ''}Final cost: EGY ${finalPrice.toInt()}\n\nThank you for using Tameny App.''',
                      );

                      
                      await FirebaseFirestore.instance
                          .collection('hospital_bookings')
                          .add({
                            'hospitalId': widget.hospitalId,
                            'hospitalName': widget.hospitalData['name'],
                            'appointmentDate': widget.selectedDate,
                            'appointmentTime': widget.selectedTime.format(
                              context,
                            ),
                            'emergencyType': widget.emergencyType,
                            'paymentMethod': paymentMethod ?? 'N/A',
                            'userEmail': emailController.text.trim(),
                            'originalPrice': double.parse(
                              widget.hospitalData['price'].toString(),
                            ),
                            'discountPercentage': discountPercentage,
                            'finalPrice': finalPrice,
                            'insuranceVerified': insuranceVerified,
                            'insuranceProvider': insuranceProvider,
                            'insuranceId':
                                insuranceVerified
                                    ? insuranceIdController.text
                                        .trim()
                                        .toUpperCase()
                                    : null,
                            'savingsAmount':
                                insuranceVerified
                                    ? (double.parse(
                                          widget.hospitalData['price']
                                              .toString(),
                                        ) *
                                        discountPercentage /
                                        100)
                                    : 0.0,
                            'bookingStatus': 'confirmed',
                            'timestamp': FieldValue.serverTimestamp(),
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                      
                      print('=== INSURANCE DEBUG ===');
                      print('Original Price: ${widget.hospitalData['price']}');
                      print('Discount Percentage: $discountPercentage');
                      print('Final Price: $finalPrice');
                      print('Insurance Verified: $insuranceVerified');
                      print('Insurance Provider: $insuranceProvider');
                      print('======================');

                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => HospitalSummaryScreen(
                                hospital: widget.hospitalData,
                                appointmentDate: widget.selectedDate,
                                appointmentTime: widget.selectedTime,
                                emergencyType: widget.emergencyType,
                                paymentMethod: paymentMethod ?? 'N/A',
                                email: emailController.text.trim(),
                                originalPrice: double.parse(
                                  widget.hospitalData['price'].toString(),
                                ),
                                discountPercentage: discountPercentage,
                                finalPrice: finalPrice,
                                insuranceVerified: insuranceVerified,
                                insuranceProvider: insuranceProvider,
                              ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Email sending failed: ${e.toString()}",
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } finally {
                      setState(() => isProcessing = false);
                    }
                  }
                  : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient:
                  canProceed
                      ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF2E7D5E),
                          const Color(0xFF1B5E20),
                          const Color(0xFF1B5E20),
                          const Color(0xFF0D3D1E),
                        ],
                      )
                      : LinearGradient(
                        colors: [
                          const Color(0xFFE0E0E0),
                          const Color(0xFFCFD8DC),
                        ],
                      ),
              boxShadow:
                  canProceed
                      ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: const Color(
                            0xFF2E7D5E,
                          ).withOpacity(0.3 * _glowAnimation.value),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                      : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
            ),
            child:
                isProcessing
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Processing...",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.send_outlined,
                          color:
                              canProceed
                                  ? Colors.white
                                  : const Color(0xFF90A4AE),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Confirm & Send",
                          style: TextStyle(
                            color:
                                canProceed
                                    ? Colors.white
                                    : const Color(0xFF90A4AE),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
          ),
        );
      },
    );
  }
}


class MedicalGridPainter extends CustomPainter {
  final double progress;

  MedicalGridPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF2E7D5E).withOpacity(0.02)
          ..strokeWidth = 0.3
          ..style = PaintingStyle.stroke;

    
    for (int i = 0; i < 30; i++) {
      final y = (i * size.height / 30) + (progress * 8) % 8;
      if (y < size.height) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
    }

    
    for (int i = 0; i < 25; i++) {
      final x = (i * size.width / 25) + (progress * 10) % 10;
      if (x < size.width) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
    }

    
    final nodePaint =
        Paint()
          ..color = const Color(0xFF1976D2).withOpacity(0.03)
          ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      canvas.drawCircle(
        Offset((i * 180 + 90) % size.width, (i * 250 + 125) % size.height),
        1,
        nodePaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}


