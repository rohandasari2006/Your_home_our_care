import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestsScreen extends StatefulWidget {
  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetching approved requests from Firestore
  Stream<QuerySnapshot> getApprovedRequestsStream() {
    return _firestore
        .collection('booking maid') // Firestore collection for maid bookings
        .where('status', isEqualTo: 'Approved') // Only fetch approved requests
        .snapshots();
  }

  // Format date for display
  String formatDate(String dateString) {
    try {
      DateTime date = DateFormat("yyyy-MM-dd").parse(dateString);
      return DateFormat("dd/MM/yy").format(date);
    } catch (e) {
      return "Invalid Date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Requests Came", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Color(0xFF6C63FF),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: getApprovedRequestsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text("No approved requests", style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey)),
              );
            }

            var requests = snapshot.data!.docs;

            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                var request = requests[index].data() as Map<String, dynamic>;
                String bookingId = requests[index].id; // Booking document ID
                String service = request["serviceType"] ?? "Unknown Service";
                String maidPhone = request["maidPhone"] ?? "Not available";

                return FutureBuilder<DocumentSnapshot>(
                  future: _firestore.collection('user detail').doc(bookingId).get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: ListTile(
                          leading: Icon(Icons.person, color: Colors.blueGrey, size: 30),
                          title: Text("Loading...", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      );
                    }

                    if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                      return SizedBox.shrink();
                    }

                    var user = userSnapshot.data!.data() as Map<String, dynamic>;

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: ListTile(
                        leading: Icon(Icons.person, color: Colors.blueGrey, size: 30),
                        title: Text(
                          user["full_name"] ?? "Unknown User",
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Contact: ${user['contact_number'] ?? 'Not Available'}",
                                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54)),
                            Text("City: ${user['city'] ?? 'Unknown'}",
                                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54)),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            try {
                              await _firestore.collection('booking maid').doc(bookingId).update({
                                'status': 'Completed',
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Request marked as Completed!")),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Failed to update status: $e")),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text("Complete", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                        onTap: () {
                          _showRequestDetailsDialog(context, user, service, maidPhone, request, bookingId);
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Function to show details in a dialog
  void _showRequestDetailsDialog(
      BuildContext context,
      Map<String, dynamic> user,
      String service,
      String maidPhone,
      Map<String, dynamic> request,
      String bookingId) {
    String selectedDate = request["selectedDate"] ?? "Unknown Date";
    String selectedTimeSlot = request["selectedTimeSlot"] ?? "Unknown Time Slot";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Request Details", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Booking ID: $bookingId", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
                Text("Full Name: ${user['full_name'] ?? 'Unknown'}", style: GoogleFonts.poppins(fontSize: 16)),
                GestureDetector(
                  onTap: () async {
                    final contactNumber = user['contact_number'] ?? '';
                    if (contactNumber.isNotEmpty) {
                      final Uri phoneUri = Uri.parse('tel:$contactNumber');
                      if (await canLaunchUrl(phoneUri)) {
                        await launchUrl(phoneUri);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Unable to open dialer for $contactNumber")),
                        );
                      }
                    }
                  },
                  child: Text(
                    "Contact Number: ${user['contact_number'] ?? 'Unknown'}",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text("Service: $service", style: GoogleFonts.poppins(fontSize: 14)),
                GestureDetector(
                  onTap: () async {
                    if (maidPhone.isNotEmpty) {
                      final Uri phoneUri = Uri.parse('tel:$maidPhone');
                      if (await canLaunchUrl(phoneUri)) {
                        await launchUrl(phoneUri);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Unable to open dialer for $maidPhone")),
                        );
                      }
                    }
                  },
                  child: Text(
                    "Maid Phone: $maidPhone",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text("Date: ${formatDate(selectedDate)}"),
                Text("Time Slot: $selectedTimeSlot"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Close", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }
}
