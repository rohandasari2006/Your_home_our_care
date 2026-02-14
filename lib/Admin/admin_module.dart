import 'package:flutter/material.dart';
import 'package:yhoc/Admin/booked_history.dart';
import 'package:yhoc/Admin/payment_management.dart';
import 'approve_maid.dart'; // Import ApproveMaidScreen
import 'user_feedback.dart'; // Import UserFeedbackScreen
import 'booking_requests.dart'; // Import BookingRequestsScreen
import 'maid_requests.dart'; // Import MaidRequestsScreen
import 'overall_maids.dart'; // Import OverallMaidsScreen
import 'booked_history.dart';
class AdminModule extends StatefulWidget {
  @override
  _AdminModuleState createState() => _AdminModuleState();
}

class _AdminModuleState extends State<AdminModule> {
  void navigateToMaidRequests() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MaidRequestsScreen()),
    );
  }

  void navigateToOverallMaids() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OverallMaidsScreen()),
    );
  }

  void navigateToUserFeedback() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserFeedbackScreen()),
    );
  }

  void navigateToBookingRequests() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookingRequestsScreen()),
    );
  }
  void navigateToBookingHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookedHistory()),
    );
  }
  void navigateToPaymentManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentManagementScreen()),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Panel"),
        backgroundColor: Color(0xFF6C63FF),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Maid Management Section
            Text("Maid Management",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            // Maid Requests Tile
            Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(Icons.person_add, color: Colors.purple),
                title: Text("Maid Requests"),
                onTap: navigateToMaidRequests,
              ),
            ),

            // Overall Maids Tile
            Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(Icons.people, color: Colors.teal),
                title: Text("Overall Maids"),
                onTap: navigateToOverallMaids,
              ),
            ),

            Divider(height: 30, thickness: 2),

            // User Management Section
            Text("User Management",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(Icons.feedback, color: Colors.blue),
                title: Text("User Feedback"),
                onTap: navigateToUserFeedback,
              ),
            ),
            Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(Icons.history, color: Colors.green),
                title: Text("User Booking History"),
                onTap: navigateToBookingHistory,
              ),
            ),
            Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(Icons.request_page, color: Colors.red),
                title: Text("Booking Requests"),
                onTap: navigateToBookingRequests,
              ),
            ),
            Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(Icons.payment, color: Colors.yellow),
                title: Text("Payment Management"),
                onTap: navigateToPaymentManagement,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
