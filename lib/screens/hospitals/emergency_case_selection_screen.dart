import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class EmergencyCaseSelectionScreen extends StatefulWidget {
  const EmergencyCaseSelectionScreen({super.key});

  @override
  State<EmergencyCaseSelectionScreen> createState() =>
      _EmergencyCaseSelectionScreenState();
}

class _EmergencyCaseSelectionScreenState
    extends State<EmergencyCaseSelectionScreen>
    with TickerProviderStateMixin {
  String? selectedEmergency;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _glowController;
  late AnimationController _breatheController;
  late AnimationController _floatController;
  late AnimationController _rotateController;

  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _breatheAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotateAnimation;

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

    _breatheController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _floatController = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
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

    _breatheAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _rotateController, curve: Curves.linear));

    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _glowController.dispose();
    _breatheController.dispose();
    _floatController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
            
            ...List.generate(15, (index) => _buildMedicalParticle(index)),

            
            AnimatedBuilder(
              animation: _breatheController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height,
                  ),
                  painter: MedicalEmergencyGridPainter(_breatheAnimation.value),
                );
              },
            ),

            SafeArea(
              child: Column(
                children: [
                  
                  _buildMedicalHeader(),

                  Expanded(
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),

                            
                            _buildMedicalEmergencyCenter(),

                            const SizedBox(height: 32),

                            
                            _buildMedicalTitle(),

                            const SizedBox(height: 32),

                            
                            _buildMedicalCasePanel(),

                            const SizedBox(height: 40),

                            
                            _buildContinueButton(),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
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

  Widget _buildMedicalHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Row(
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
                      "TAMENY HEALTH",
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
    );
  }

  Widget _buildMedicalEmergencyCenter() {
    return AnimatedBuilder(
      animation: _breatheController,
      builder: (context, child) {
        return Transform.scale(
          scale: _breatheAnimation.value,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white,
                  const Color(0xFFF8F9FA),
                  const Color(0xFFE8F4FD),
                ],
              ),
              border: Border.all(
                color: const Color(0xFFE53935).withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFFE53935,
                  ).withOpacity(0.1 * _breatheAnimation.value),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                
                AnimatedBuilder(
                  animation: _rotateController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotateAnimation.value * 2 * math.pi,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE53935).withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFE53935).withOpacity(0.1),
                        const Color(0xFFE53935).withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFFE53935).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                ),
                
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFE53935),
                        const Color(0xFFD32F2F),
                        const Color(0xFFB71C1C),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE53935).withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_hospital_rounded,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMedicalTitle() {
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
                        Icons.medical_services_outlined,
                        color: Color(0xFF1976D2),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Emergency Classification",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1976D2),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "2050 Medical AI Assistant",
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
                  "Select Your Medical ",
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

  Widget _buildMedicalCasePanel() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('emergency_cases').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF1976D2).withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF1976D2,
                      ).withOpacity(0.08 * _glowAnimation.value),
                      blurRadius: 25,
                      spreadRadius: 3,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 30,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF1976D2),
                        ),
                        strokeWidth: 2.5,
                        backgroundColor: const Color(
                          0xFF1976D2,
                        ).withOpacity(0.1),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Loading medical database...",
                      style: TextStyle(
                        color: Color(0xFF546E7A),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }

        final docs = snapshot.data?.docs ?? [];

        return AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF2E7D5E).withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF2E7D5E,
                    ).withOpacity(0.08 * _glowAnimation.value),
                    blurRadius: 25,
                    spreadRadius: 3,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
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
                            Icons.assignment_outlined,
                            color: Color(0xFF2E7D5E),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          "specializations Types",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D5E),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF8F9FA),
                            const Color(0xFFE8F4FD),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF2E7D5E).withOpacity(0.2),
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
                            vertical: 18,
                          ),
                          hintStyle: const TextStyle(
                            color: Color(0xFF90A4AE),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFE53935).withOpacity(0.1),
                                  const Color(0xFFE53935).withOpacity(0.05),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.medical_services_rounded,
                              color: Color(0xFFE53935),
                              size: 18,
                            ),
                          ),
                        ),
                        value: selectedEmergency,
                        hint: const Text(
                          "specializations",
                          style: TextStyle(
                            color: Color(0xFF90A4AE),
                            fontSize: 16,
                          ),
                        ),
                        dropdownColor: Colors.white,
                        style: const TextStyle(
                          color: Color(0xFF263238),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        iconEnabledColor: const Color(0xFF2E7D5E),
                        iconSize: 26,
                        isExpanded: true,
                        menuMaxHeight: 280,
                        items:
                            docs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return DropdownMenuItem<String>(
                                value: data['name'] as String,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFE53935),
                                              Color(0xFFD32F2F),
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                0xFFE53935,
                                              ).withOpacity(0.3),
                                              blurRadius: 4,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          data['name'] as String,
                                          style: const TextStyle(
                                            color: Color(0xFF263238),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedEmergency = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContinueButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final canProceed = selectedEmergency != null;

        return Transform.scale(
          scale: canProceed ? _pulseAnimation.value : 1.0,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 320),
            child: GestureDetector(
              onTap:
                  canProceed
                      ? () {
                        Navigator.pushNamed(
                          context,
                          '/hospitalList',
                          arguments: selectedEmergency,
                        );
                      }
                      : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient:
                      canProceed
                          ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF1976D2),
                              const Color(0xFF1565C0),
                              const Color(0xFF0D47A1),
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
                                0xFF1976D2,
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
                      child: Icon(
                        Icons.search_rounded,
                        color:
                            canProceed ? Colors.white : const Color(0xFF90A4AE),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Find Medical Facilities",
                      style: TextStyle(
                        color:
                            canProceed ? Colors.white : const Color(0xFF90A4AE),
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


class MedicalEmergencyGridPainter extends CustomPainter {
  final double animation;

  MedicalEmergencyGridPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF1976D2).withOpacity(0.02 * animation)
          ..strokeWidth = 0.3
          ..style = PaintingStyle.stroke;

    
    for (int i = 0; i < 20; i++) {
      final y = i * size.height / 20;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (int i = 0; i < 15; i++) {
      final x = i * size.width / 15;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    
    final crossPaint =
        Paint()
          ..color = const Color(0xFFE53935).withOpacity(0.03 * animation)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    for (int i = 0; i < 6; i++) {
      final centerX = (i * 200 + 100) % size.width;
      final centerY = (i * 250 + 125) % size.height;

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


