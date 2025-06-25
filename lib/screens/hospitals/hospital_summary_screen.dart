import 'package:flutter/material.dart';
import 'hospital_confirmation_screen.dart';

class HospitalSummaryScreen extends StatefulWidget {
  final Map<String, dynamic> hospital;
  final DateTime appointmentDate;
  final TimeOfDay appointmentTime;
  final String emergencyType;
  final String paymentMethod;
  final String email;
  final double originalPrice;
  final double discountPercentage;
  final double finalPrice;
  final bool insuranceVerified;
  final String insuranceProvider;

  const HospitalSummaryScreen({
    super.key,
    required this.hospital,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.emergencyType,
    required this.paymentMethod,
    required this.email,
    this.originalPrice = 0.0,
    this.discountPercentage = 0.0,
    this.finalPrice = 0.0,
    this.insuranceVerified = false,
    this.insuranceProvider = '',
  });

  @override
  State<HospitalSummaryScreen> createState() => _HospitalSummaryScreenState();
}

class _HospitalSummaryScreenState extends State<HospitalSummaryScreen>
    with TickerProviderStateMixin {
  final cardNameController = TextEditingController();
  final cardNumberController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();

  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _glowController;
  late AnimationController _heartbeatController;
  late AnimationController _medicalController;
  late AnimationController _breatheController;
  late AnimationController _floatController;

  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _heartbeatAnimation;
  late Animation<double> _medicalAnimation;
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
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);

    _heartbeatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _medicalController = AnimationController(
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

    _pulseAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _heartbeatAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _heartbeatController, curve: Curves.easeInOut),
    );

    _medicalAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _medicalController, curve: Curves.linear),
    );

    _breatheAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<double>(begin: -3.0, end: 3.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _glowController.dispose();
    _heartbeatController.dispose();
    _medicalController.dispose();
    _breatheController.dispose();
    _floatController.dispose();
    cardNameController.dispose();
    cardNumberController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hospital = widget.hospital;
    final showCardFields = widget.paymentMethod == "Pay online";

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
            
            AnimatedBuilder(
              animation: _medicalController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height,
                  ),
                  painter: MedicalSummaryGridPainter(_medicalAnimation.value),
                );
              },
            ),

            
            ...List.generate(12, (index) => _buildMedicalParticle(index)),

            SafeArea(
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      
                      _buildProfessionalMedicalHeader(),

                      const SizedBox(height: 28),

                      
                      _buildMedicalTitlePanel(),

                      const SizedBox(height: 28),

                      
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              
                              buildProfessionalMedicalSummaryPanel(),

                              const SizedBox(height: 28),

                              
                              if (widget.insuranceVerified) ...[
                                buildInsuranceDiscountPanel(),
                                const SizedBox(height: 28),
                              ],

                              
                              if (showCardFields) ...[
                                buildProfessionalPaymentInterface(),
                                const SizedBox(height: 28),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      
                      buildProfessionalMedicalPaymentButton(),
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

  Widget _buildMedicalParticle(int index) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final colors = [
          const Color(0xFF1976D2), 
          const Color(0xFF2E7D5E), 
          const Color(0xFFE53935), 
          const Color(0xFF546E7A), 
        ];
        final color = colors[index % colors.length];

        return Positioned(
          left: (index * 140.0 + 70) % MediaQuery.of(context).size.width,
          top:
              (index * 180.0 + _floatAnimation.value + 90) %
              MediaQuery.of(context).size.height,
          child: Container(
            width: 2,
            height: 2,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [color.withOpacity(0.3), Colors.transparent],
              ),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfessionalMedicalHeader() {
    return Row(
      children: [
        
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: AnimatedBuilder(
            animation: _breatheController,
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
                      color: const Color(0xFF1976D2).withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1976D2).withOpacity(0.1),
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
                    color: Color(0xFF1976D2),
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ),
        const Spacer(),
        
        AnimatedBuilder(
          animation: _heartbeatController,
          builder: (context, child) {
            return Transform.scale(
              scale: _heartbeatAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF2E7D5E).withOpacity(0.3),
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
                            color: const Color(0xFF2E7D5E).withOpacity(0.4),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "TAMENY MEDICAL",
                      style: TextStyle(
                        color: Color(0xFF2E7D5E),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMedicalTitlePanel() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value * 0.1),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF1976D2).withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1976D2).withOpacity(0.08),
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
                            const Color(0xFF1976D2).withOpacity(0.1),
                            const Color(0xFF1976D2).withOpacity(0.05),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.assignment_turned_in_outlined,
                        color: Color(0xFF1976D2),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Medical Appointment",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1976D2),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Healthcare Booking Summary",
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF546E7A).withOpacity(0.8),
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
                        const Color(0xFF1976D2).withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Appointment Summary",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF263238),
                    letterSpacing: 0.3,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildProfessionalMedicalSummaryPanel() {
    return AnimatedBuilder(
      animation: _breatheController,
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
                color: const Color(0xFF2E7D5E).withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D5E).withOpacity(0.08),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
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
                        Icons.medical_information_outlined,
                        color: Color(0xFF2E7D5E),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Medical Details",
                            style: TextStyle(
                              color: Color(0xFF2E7D5E),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Healthcare Information",
                            style: TextStyle(
                              color: const Color(0xFF546E7A).withOpacity(0.8),
                              fontSize: 12,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                professionalMedicalSummaryRow(
                  "Medical Emergency",
                  widget.emergencyType,
                  Icons.medical_services_outlined,
                  const Color(0xFFE53935),
                ),
                const SizedBox(height: 16),
                professionalMedicalSummaryRow(
                  "Healthcare Facility",
                  widget.hospital['name'] ?? 'Hospital Name',
                  Icons.local_hospital_outlined,
                  const Color(0xFF1976D2),
                ),
                const SizedBox(height: 16),
                professionalMedicalSummaryRow(
                  "Appointment Date",
                  "${widget.appointmentDate.day}/${widget.appointmentDate.month}/${widget.appointmentDate.year}",
                  Icons.calendar_today_outlined,
                  const Color(0xFF2E7D5E),
                ),
                const SizedBox(height: 16),
                professionalMedicalSummaryRow(
                  "Appointment Time",
                  widget.appointmentTime.format(context),
                  Icons.access_time_outlined,
                  const Color(0xFFFF7043),
                ),
                const SizedBox(height: 16),
                professionalMedicalSummaryRow(
                  "Payment Method",
                  widget.paymentMethod,
                  Icons.payment_outlined,
                  const Color(0xFF7B1FA2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildInsuranceDiscountPanel() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF00BCD4).withOpacity(0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00BCD4).withOpacity(0.08),
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
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
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Insurance Benefits",
                          style: TextStyle(
                            color: Color(0xFF00BCD4),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Health Coverage Applied",
                          style: TextStyle(
                            color: const Color(0xFF546E7A).withOpacity(0.8),
                            fontSize: 12,
                            letterSpacing: 0.3,
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
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2E7D5E),
                          const Color(0xFF1B5E20),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${widget.discountPercentage.toInt()}% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFFF8F9FA), const Color(0xFFE8F4FD)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF00BCD4).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _buildCostRow(
                      "Insurance Provider",
                      widget.insuranceProvider,
                      Icons.verified_outlined,
                      const Color(0xFF00BCD4),
                    ),
                    const SizedBox(height: 12),
                    _buildCostRow(
                      "Original Medical Fee",
                      "EGP ${widget.originalPrice.toInt()}",
                      Icons.attach_money_outlined,
                      const Color(0xFF546E7A),
                    ),
                    const SizedBox(height: 12),
                    _buildCostRow(
                      "Insurance Discount (${widget.discountPercentage.toInt()}%)",
                      "-EGP ${(widget.originalPrice * widget.discountPercentage / 100).toInt()}",
                      Icons.discount_outlined,
                      const Color(0xFF2E7D5E),
                      isDiscount: true,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            const Color(0xFF00BCD4).withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCostRow(
                      "Final Amount",
                      "EGP ${widget.finalPrice.toInt()}",
                      Icons.savings_outlined,
                      const Color(0xFF2E7D5E),
                      isFinal: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCostRow(
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isDiscount = false,
    bool isFinal = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isFinal ? color : const Color(0xFF546E7A),
              fontSize: isFinal ? 16 : 14,
              fontWeight: isFinal ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: isFinal ? 18 : 15,
            fontWeight: isFinal ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget professionalMedicalSummaryRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFFF8F9FA), const Color(0xFFE8F4FD)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08 * _pulseAnimation.value),
                blurRadius: 12,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.2), width: 1),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Color(0xFF263238),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildProfessionalPaymentInterface() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF00ACC1).withOpacity(0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00ACC1).withOpacity(0.08),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00ACC1).withOpacity(0.1),
                          const Color(0xFF00ACC1).withOpacity(0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.credit_card_outlined,
                      color: Color(0xFF00ACC1),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Secure Payment",
                          style: TextStyle(
                            color: Color(0xFF00ACC1),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Medical Payment Processing",
                          style: TextStyle(
                            color: const Color(0xFF546E7A).withOpacity(0.8),
                            fontSize: 12,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              
              buildProfessionalMedicalCreditCard(),

              const SizedBox(height: 28),

              
              _buildProfessionalInputField(
                "Cardholder Name",
                cardNameController,
                Icons.person_outlined,
              ),
              const SizedBox(height: 20),

              _buildProfessionalInputField(
                "Card Number",
                cardNumberController,
                Icons.credit_card_outlined,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _buildProfessionalInputField(
                      "Expiry",
                      expiryController,
                      Icons.date_range_outlined,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildProfessionalInputField(
                      "CVV",
                      cvvController,
                      Icons.security_outlined,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfessionalInputField(
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
            color: Color(0xFF00ACC1),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFFF8F9FA), const Color(0xFFE8F4FD)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF00ACC1).withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(
              color: Color(0xFF263238),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
            decoration: InputDecoration(
              hintText: _getHintText(label),
              hintStyle: const TextStyle(
                color: Color(0xFF90A4AE),
                fontSize: 16,
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
                      const Color(0xFF00ACC1).withOpacity(0.1),
                      const Color(0xFF00ACC1).withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF00ACC1), size: 18),
              ),
            ),
            onChanged: (value) {
              setState(() {}); 
            },
          ),
        ),
      ],
    );
  }

  String _getHintText(String label) {
    switch (label) {
      case "Cardholder Name":
        return "Enter cardholder name";
      case "Card Number":
        return "0000 0000 0000 0000";
      case "Expiry":
        return "MM/YY";
      case "CVV":
        return "123";
      default:
        return "";
    }
  }

  Widget buildProfessionalMedicalCreditCard() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1976D2),
                const Color(0xFF1565C0),
                const Color(0xFF0D47A1),
                const Color(0xFF01579B),
              ],
            ),
            border: Border.all(
              color: const Color(0xFF1976D2).withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF1976D2,
                ).withOpacity(0.2 * _pulseAnimation.value),
                blurRadius: 20,
                spreadRadius: 3,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              
              Positioned.fill(
                child: CustomPaint(painter: ProfessionalCardPatternPainter()),
              ),

              
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            "TAMENY HEALTH",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "VISA",
                            style: TextStyle(
                              color: Color(0xFF1976D2),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    
                    Text(
                      cardNumberController.text.isEmpty
                          ? "0000 0000 0000 0000"
                          : cardNumberController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                      ),
                    ),

                    const SizedBox(height: 24),

                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "CARDHOLDER NAME",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cardNameController.text.isEmpty
                                  ? "CARDHOLDER NAME"
                                  : cardNameController.text.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "VALID THRU",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              expiryController.text.isEmpty
                                  ? "MM/YY"
                                  : expiryController.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2E7D5E),
                        const Color(0xFF1B5E20),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E7D5E).withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_hospital_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildProfessionalMedicalPaymentButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => HospitalConfirmationScreen(
                          hospital: widget.hospital,
                          appointmentDate: widget.appointmentDate,
                          appointmentTime: widget.appointmentTime,
                          emergencyType: widget.emergencyType,
                          paymentMethod: widget.paymentMethod,
                          email: widget.email,
                          price:
                              widget.finalPrice > 0
                                  ? widget.finalPrice.toInt()
                                  : (widget.hospital['price'] ?? 0) as int,
                          originalPrice: widget.originalPrice,
                          discountPercentage: widget.discountPercentage,
                          finalPrice: widget.finalPrice,
                          insuranceVerified: widget.insuranceVerified,
                          insuranceProvider: widget.insuranceProvider,
                        ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1976D2),
                      const Color(0xFF1565C0),
                      const Color(0xFF0D47A1),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: const Color(
                        0xFF1976D2,
                      ).withOpacity(0.3 * _glowAnimation.value),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.medical_services_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Complete Medical Payment",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


class MedicalSummaryGridPainter extends CustomPainter {
  final double progress;

  MedicalSummaryGridPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF1976D2).withOpacity(0.02)
          ..strokeWidth = 0.3
          ..style = PaintingStyle.stroke;

    
    for (int i = 0; i < 20; i++) {
      final y = (i * size.height / 20) + (progress * 8) % 8;
      if (y < size.height) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
    }

    for (int i = 0; i < 15; i++) {
      final x = (i * size.width / 15) + (progress * 10) % 10;
      if (x < size.width) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
    }

    
    final crossPaint =
        Paint()
          ..color = const Color(0xFF2E7D5E).withOpacity(0.03)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      final centerX = (i * 180 + 90) % size.width;
      final centerY = (i * 220 + 110) % size.height;

      canvas.drawLine(
        Offset(centerX - 4, centerY),
        Offset(centerX + 4, centerY),
        crossPaint,
      );
      canvas.drawLine(
        Offset(centerX, centerY - 4),
        Offset(centerX, centerY + 4),
        crossPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}


class ProfessionalCardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..strokeWidth = 0.5
          ..style = PaintingStyle.stroke;

    
    for (int i = 0; i < 8; i++) {
      canvas.drawLine(
        Offset(0, i * size.height / 8),
        Offset(size.width, i * size.height / 8),
        paint,
      );
    }

    
    final diagonalPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.03)
          ..strokeWidth = 0.3
          ..style = PaintingStyle.stroke;

    for (int i = 0; i < 20; i++) {
      canvas.drawLine(
        Offset(i * 20.0, 0),
        Offset(i * 20.0 + size.height * 0.3, size.height),
        diagonalPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


