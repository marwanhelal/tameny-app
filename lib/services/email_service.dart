import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailService {
  static const String _apiKey =
      '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';
  static const String _apiUrl = 'https://api.sendgrid.com/v3/mail/send';
  static const String _fromEmail =
      'tamenyapp1@gmail.com'; // Must be verified in SendGrid

  /// Generic email sending function
  static Future<void> sendEmail({
    required String toEmail,
    required String subject,
    required String content,
    String fromName = 'Tameny App',
  }) async {
    final Map<String, dynamic> emailData = {
      'personalizations': [
        {
          'to': [
            {'email': toEmail},
          ],
          'subject': subject,
        },
      ],
      'from': {'email': _fromEmail, 'name': fromName},
      'content': [
        {'type': 'text/plain', 'value': content},
      ],
    };

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode(emailData),
    );

    if (response.statusCode == 202) {
      print('✅ Email sent successfully to $toEmail');
    } else {
      print('❌ Failed to send email to $toEmail');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  }

  /// Sends a formatted confirmation email after successful booking
  static Future<void> sendConfirmationEmail({
    required String toEmail,
    required String hospitalName,
    required String appointmentDate,
    required String appointmentTime,
    required String emergencyType,
    required String paymentMethod,
  }) async {
    final uri = Uri.parse(
      'https://your-backend-api/send-email',
    ); // OR Firebase Function endpoint

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: '''{
        "to": "$toEmail",
        "subject": "Hospital Appointment Confirmation",
        "body": "Your appointment at $hospitalName for $emergencyType is confirmed on $appointmentDate at $appointmentTime. Payment: $paymentMethod."
      }''',
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send confirmation email');
    }
  }

  static Future<void> sendLabConfirmationEmail({
    required String toEmail,
    required String labName,
    required String labType,
    required DateTime appointmentDate,
    required String appointmentTime,
    required String paymentMethod,
    required int price,
  }) async {
    final subject = 'Your Lab Appointment is Confirmed!';
    final content = '''
Dear Patient,

Your appointment at $labName ($labType) has been successfully confirmed.

📅 Date: ${appointmentDate.toLocal().toString().split(' ')[0]}
🕒 Time: $appointmentTime
💳 Payment Method: $paymentMethod
💰 Total: EGY $price

Thank you for using the Tameny App.

Stay healthy,  
Tameny Team
''';

    await sendEmail(toEmail: toEmail, subject: subject, content: content);
  }
}
