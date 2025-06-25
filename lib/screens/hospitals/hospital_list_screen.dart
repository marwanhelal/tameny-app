import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HospitalListScreen extends StatefulWidget {
  final String emergencyType;

  const HospitalListScreen({super.key, required this.emergencyType});

  @override
  State<HospitalListScreen> createState() => _HospitalListScreenState();
}

class _HospitalListScreenState extends State<HospitalListScreen>
    with TickerProviderStateMixin {
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
      duration: const Duration(milliseconds: 1500),
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

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scanController, curve: Curves.linear));

    _breatheAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<double>(begin: -4, end: 4).animate(
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        (index * 160.0 + 80) %
                        MediaQuery.of(context).size.width,
                    top:
                        (index * 220.0 + 100 + _floatAnimation.value) %
                        MediaQuery.of(context).size.height,
                    child: Container(
                      width: 2,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            index % 3 == 0
                                ? const Color(0xFF1976D2).withOpacity(
                                  0.3,
                                ) 
                                : index % 3 == 1
                                ? const Color(0xFF2E7D5E).withOpacity(
                                  0.2,
                                ) 
                                : const Color(
                                  0xFF546E7A,
                                ).withOpacity(0.15), 
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
                  painter: MedicalNetworkGridPainter(_scanAnimation.value),
                );
              },
            ),

            SafeArea(
              child: Column(
                children: [
                  
                  Container(
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
                                            0xFF1976D2,
                                          ).withOpacity(0.2),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF1976D2,
                                            ).withOpacity(0.1),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
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
                                      color: const Color(
                                        0xFF2E7D5E,
                                      ).withOpacity(0.3),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF2E7D5E,
                                        ).withOpacity(
                                          0.1 * _glowAnimation.value,
                                        ),
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
                                        "NETWORK",
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

                        const SizedBox(height: 28),

                        
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                            Icons.local_hospital_outlined,
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
                                              "Medical Facility Directory",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1976D2),
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "2050 Healthcare Network",
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(
                                              0xFFFF7043,
                                            ).withOpacity(0.1),
                                            const Color(
                                              0xFFFF7043,
                                            ).withOpacity(0.05),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(
                                            0xFFFF7043,
                                          ).withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  const Color(
                                                    0xFFFF7043,
                                                  ).withOpacity(0.2),
                                                  Colors.transparent,
                                                ],
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.medical_services_outlined,
                                              color: Color(0xFFFF7043),
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Flexible(
                                            child: Text(
                                              "Emergency: ${widget.emergencyType}",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFFFF7043),
                                                letterSpacing: 0.3,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  
                  Expanded(
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('hospitals')
                                .where(
                                  'emergencyServices',
                                  arrayContains: widget.emergencyType,
                                )
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: AnimatedBuilder(
                                animation: _glowAnimation,
                                builder: (context, child) {
                                  return Container(
                                    padding: const EdgeInsets.all(40),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF1976D2,
                                        ).withOpacity(0.2),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF1976D2,
                                          ).withOpacity(
                                            0.1 * _glowAnimation.value,
                                          ),
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
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            SizedBox(
                                              width: 60,
                                              height: 60,
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(const Color(0xFF1976D2)),
                                                strokeWidth: 3,
                                                backgroundColor: const Color(
                                                  0xFF1976D2,
                                                ).withOpacity(0.1),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    const Color(
                                                      0xFF1976D2,
                                                    ).withOpacity(0.1),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.wifi_find_outlined,
                                                color: Color(0xFF1976D2),
                                                size: 28,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        const Text(
                                          "Scanning Medical Network",
                                          style: TextStyle(
                                            color: Color(0xFF1976D2),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Locating available facilities...",
                                          style: TextStyle(
                                            color: const Color(
                                              0xFF546E7A,
                                            ).withOpacity(0.8),
                                            fontSize: 13,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          }

                          final hospitals = snapshot.data?.docs ?? [];

                          if (hospitals.isEmpty) {
                            return Center(
                              child: Container(
                                padding: const EdgeInsets.all(32),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFFF7043,
                                    ).withOpacity(0.2),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFFF7043,
                                      ).withOpacity(0.08),
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
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(
                                              0xFFFF7043,
                                            ).withOpacity(0.1),
                                            Colors.transparent,
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.search_off_outlined,
                                        color: Color(0xFFFF7043),
                                        size: 48,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      "No Medical Facilities Found",
                                      style: TextStyle(
                                        color: Color(0xFF263238),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "No hospitals available for ${widget.emergencyType} in your network.",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Color(0xFF90A4AE),
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            itemCount: hospitals.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final doc = hospitals[index];
                              final data = doc.data() as Map<String, dynamic>;

                              return AnimatedBuilder(
                                animation: _glowAnimation,
                                builder: (context, child) {
                                  return TweenAnimationBuilder<double>(
                                    duration: Duration(
                                      milliseconds: 600 + (index * 100),
                                    ),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    builder: (context, animValue, child) {
                                      return Transform.translate(
                                        offset: Offset(0, 30 * (1 - animValue)),
                                        child: Opacity(
                                          opacity: animValue,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
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
                                                  ).withOpacity(
                                                    0.08 * _glowAnimation.value,
                                                  ),
                                                  blurRadius: 20,
                                                  spreadRadius: 2,
                                                  offset: const Offset(0, 6),
                                                ),
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.04),
                                                  blurRadius: 25,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: Row(
                                                children: [
                                                  
                                                  AnimatedBuilder(
                                                    animation: _pulseAnimation,
                                                    builder: (context, child) {
                                                      return Transform.scale(
                                                        scale:
                                                            _pulseAnimation
                                                                .value,
                                                        child: Container(
                                                          width: 70,
                                                          height: 70,
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  16,
                                                                ),
                                                            border: Border.all(
                                                              color:
                                                                  const Color(
                                                                    0xFF1976D2,
                                                                  ).withOpacity(
                                                                    0.2,
                                                                  ),
                                                              width: 2,
                                                            ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: const Color(
                                                                  0xFF1976D2,
                                                                ).withOpacity(
                                                                  0.1,
                                                                ),
                                                                blurRadius: 12,
                                                                spreadRadius: 1,
                                                              ),
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                      0.05,
                                                                    ),
                                                                blurRadius: 15,
                                                                offset:
                                                                    const Offset(
                                                                      0,
                                                                      3,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  14,
                                                                ),
                                                            child: Image.asset(
                                                              data['logo'],
                                                              fit: BoxFit.cover,
                                                              errorBuilder:
                                                                  (
                                                                    _,
                                                                    __,
                                                                    ___,
                                                                  ) => Container(
                                                                    decoration: BoxDecoration(
                                                                      gradient: LinearGradient(
                                                                        colors: [
                                                                          const Color(
                                                                            0xFFE53935,
                                                                          ),
                                                                          const Color(
                                                                            0xFFC62828,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            14,
                                                                          ),
                                                                    ),
                                                                    child: const Icon(
                                                                      Icons
                                                                          .local_hospital_outlined,
                                                                      color:
                                                                          Colors
                                                                              .white,
                                                                      size: 32,
                                                                    ),
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),

                                                  const SizedBox(width: 16),

                                                  
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          data['name'] ??
                                                              'Hospital Name',
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize: 16,
                                                                color: Color(
                                                                  0xFF263238,
                                                                ),
                                                                height: 1.2,
                                                              ),
                                                          maxLines: 2,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    4,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                gradient: LinearGradient(
                                                                  colors: [
                                                                    const Color(
                                                                      0xFF1976D2,
                                                                    ).withOpacity(
                                                                      0.1,
                                                                    ),
                                                                    Colors
                                                                        .transparent,
                                                                  ],
                                                                ),
                                                                shape:
                                                                    BoxShape
                                                                        .circle,
                                                              ),
                                                              child: const Icon(
                                                                Icons
                                                                    .location_on_outlined,
                                                                color: Color(
                                                                  0xFF1976D2,
                                                                ),
                                                                size: 14,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                data['address'] ??
                                                                    'Hospital Address',
                                                                style: const TextStyle(
                                                                  color: Color(
                                                                    0xFF90A4AE,
                                                                  ),
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  height: 1.3,
                                                                ),
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 12,
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 12,
                                                                vertical: 6,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            gradient: LinearGradient(
                                                              colors: [
                                                                const Color(
                                                                  0xFF2E7D5E,
                                                                ).withOpacity(
                                                                  0.1,
                                                                ),
                                                                const Color(
                                                                  0xFF2E7D5E,
                                                                ).withOpacity(
                                                                  0.05,
                                                                ),
                                                              ],
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                            border: Border.all(
                                                              color:
                                                                  const Color(
                                                                    0xFF2E7D5E,
                                                                  ).withOpacity(
                                                                    0.2,
                                                                  ),
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Container(
                                                                width: 6,
                                                                height: 6,
                                                                decoration: const BoxDecoration(
                                                                  color: Color(
                                                                    0xFF2E7D5E,
                                                                  ),
                                                                  shape:
                                                                      BoxShape
                                                                          .circle,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              Text(
                                                                "EGY ${data['price'] ?? '0'}",
                                                                style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 12,
                                                                  color: Color(
                                                                    0xFF2E7D5E,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  const SizedBox(width: 12),

                                                  
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.pushNamed(
                                                        context,
                                                        '/hospitalProfile',
                                                        arguments: {
                                                          'hospitalId': doc.id,
                                                          'hospitalData': data,
                                                          'emergencyType':
                                                              widget
                                                                  .emergencyType,
                                                        },
                                                      );
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 16,
                                                            vertical: 12,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          begin:
                                                              Alignment.topLeft,
                                                          end:
                                                              Alignment
                                                                  .bottomRight,
                                                          colors: [
                                                            const Color(
                                                              0xFF1976D2,
                                                            ),
                                                            const Color(
                                                              0xFF1565C0,
                                                            ),
                                                          ],
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              14,
                                                            ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                  0.1,
                                                                ),
                                                            blurRadius: 8,
                                                            offset:
                                                                const Offset(
                                                                  0,
                                                                  3,
                                                                ),
                                                          ),
                                                          BoxShadow(
                                                            color: const Color(
                                                              0xFF1976D2,
                                                            ).withOpacity(0.3),
                                                            blurRadius: 12,
                                                            spreadRadius: 1,
                                                          ),
                                                        ],
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  4,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                              gradient: RadialGradient(
                                                                colors: [
                                                                  Colors.white
                                                                      .withOpacity(
                                                                        0.2,
                                                                      ),
                                                                  Colors
                                                                      .transparent,
                                                                ],
                                                              ),
                                                            ),
                                                            child: const Icon(
                                                              Icons
                                                                  .info_outline_rounded,
                                                              color:
                                                                  Colors.white,
                                                              size: 16,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 6,
                                                          ),
                                                          const Text(
                                                            "VIEW",
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors.white,
                                                              letterSpacing:
                                                                  0.5,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
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
                                },
                              );
                            },
                          );
                        },
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
}


class MedicalNetworkGridPainter extends CustomPainter {
  final double progress;

  MedicalNetworkGridPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF1976D2).withOpacity(0.02)
          ..strokeWidth = 0.3
          ..style = PaintingStyle.stroke;

    
    for (int i = 0; i < 25; i++) {
      final y = (i * size.height / 25) + (progress * 8) % 8;
      if (y < size.height) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
    }

    
    for (int i = 0; i < 20; i++) {
      final x = (i * size.width / 20) + (progress * 10) % 10;
      if (x < size.width) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
    }

    
    final nodePaint =
        Paint()
          ..color = const Color(0xFF2E7D5E).withOpacity(0.03)
          ..style = PaintingStyle.fill;

    for (int i = 0; i < 10; i++) {
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


