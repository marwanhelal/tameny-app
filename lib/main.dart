import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/booking_doctor/online_doctor_screen.dart';
import 'screens/dashboards/patient_dashboard_screen.dart';
import 'screens/dashboards/doctor_dashboard_screen.dart';
import 'screens/dashboards/admin_dashboard_screen.dart';
import 'screens/authentication/welcome_screen.dart';
import 'screens/authentication/unified_signin_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/reservations_search_screen.dart';
import 'screens/orders_reservations_screen.dart';
import 'screens/labs/labs_and_scan_centre_screen.dart';
import 'screens/labs/labs_and_scan_selection_screen.dart';
import 'screens/hospitals/hospital_list_screen.dart';
import 'screens/hospitals/hospital_profile_screen.dart';
import 'screens/hospitals/hospital_payment_screen.dart';
import 'screens/hospitals/hospital_summary_screen.dart';
import 'screens/hospitals/hospital_confirmation_screen.dart';
import 'screens/hospitals/emergency_case_selection_screen.dart';
import 'screens/pharmacy/pharmacy_list_screen.dart';
import 'screens/pharmacy/pharmacy_profile_screen.dart';
import 'screens/pharmacy/cart_screen.dart';
import 'screens/pharmacy/order_summary_screen.dart';
import 'screens/pharmacy/order_history_screen.dart';
import 'screens/dashboards/patient_bookings_dashboard.dart';
import 'screens/search/search_screen.dart';
import 'screens/booking_doctor/doctor_options_screen.dart';
import 'screens/emergency_guide_screen.dart';
import 'screens/profile/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tameny',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'Poppins', // Set default font
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/signin': (context) => const UnifiedSignInScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
        '/labTypeSelection': (context) => const LabsAndScanSelectionScreen(),
        '/hospitalEmergency': (context) => const EmergencyCaseSelectionScreen(),
        '/patientDashboard': (context) => const PatientDashboardScreen(),
        '/patient_dashboard': (context) => const PatientDashboardScreen(),
        '/patientBookingsDashboard':
            (context) => const PatientBookingsDashboard(),
        '/onlineDoctors': (context) => const OnlineDoctorScreen(),
        '/doctor_dashboard': (context) => const DoctorDashboardScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
        '/reservations_search': (context) => const ReservationsSearchScreen(),
        '/orders_reservations': (context) => const OrdersReservationsScreen(),
        '/labs_scan_centre': (context) => const LabsAndScanCentreScreen(),
        '/search': (context) => const SearchScreen(),
        '/hospitalList': (context) {
          final emergencyType =
              ModalRoute.of(context)!.settings.arguments as String;
          return HospitalListScreen(emergencyType: emergencyType);
        },
        '/hospitalProfile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return HospitalProfileScreen(
            hospitalId: args['hospitalId'],
            hospitalData: args['hospitalData'],
            emergencyType: args['emergencyType'],
          );
        },
        '/hospitalReservation': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return HospitalPaymentScreen(
            hospitalId: args['hospitalId'],
            hospitalData: args['hospitalData'],
            emergencyType: args['emergencyType'],
            selectedDate: args['selectedDate'],
            selectedTime: args['selectedTime'],
          );
        },
        '/hospitalBookingSummary': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return HospitalSummaryScreen(
            hospital: args['hospital'],
            appointmentDate: args['appointmentDate'],
            appointmentTime: args['appointmentTime'],
            emergencyType: args['emergencyType'],
            paymentMethod: args['paymentMethod'],
            email: args['email'],
            originalPrice: args['originalPrice'] ?? 0.0,
            discountPercentage: args['discountPercentage'] ?? 0.0,
            finalPrice: args['finalPrice'] ?? 0.0,
            insuranceVerified: args['insuranceVerified'] ?? false,
            insuranceProvider: args['insuranceProvider'] ?? '',
          );
        },
        '/hospitalConfirmation': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return HospitalConfirmationScreen(
            hospital: args['hospital'],
            appointmentDate: args['appointmentDate'],
            appointmentTime: args['appointmentTime'],
            emergencyType: args['emergencyType'],
            paymentMethod: args['paymentMethod'],
            email: args['email'],
            price: args['price'],
            originalPrice: args['originalPrice'] ?? 0.0,
            discountPercentage: args['discountPercentage'] ?? 0.0,
            finalPrice: args['finalPrice'] ?? 0.0,
            insuranceVerified: args['insuranceVerified'] ?? false,
            insuranceProvider: args['insuranceProvider'] ?? '',
          );
        },
        '/pharmacyList': (context) => const PharmacyListScreen(),
        '/pharmacyProfile': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return PharmacyProfileScreen(
            pharmacyData: args['pharmacyData'],
            pharmacyId: args['pharmacyId'],
          );
        },
        '/cart': (context) => const CartScreen(),
        '/cartScreen': (context) => const CartScreen(),
        '/orderSummary':
            (context) =>
                const OrderSummaryScreen(pharmacyId: '', pharmacyName: ''),
        '/orderHistory': (context) => const OrderHistoryScreen(),
        '/doctorOptions': (context) => const DoctorOptionsScreen(),
        '/emergencyGuide': (context) => const EmergencyGuideScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
