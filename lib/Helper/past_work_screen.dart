import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:yhoc/globals.dart' as globals;

class PastWorkScreen extends StatelessWidget {
  const PastWorkScreen({Key? key}) : super(key: key);

  // Fetch only completed bookings assigned to the current maid
  Stream<List<Map<String, dynamic>>> fetchCompletedBookings() {
    return FirebaseFirestore.instance
        .collection('booking maid')
        .where('status', isEqualTo: 'Completed') // Fetch only completed bookings
        .where('maidPhone', isEqualTo: globals.helper_no) // Filter by maid's phone number
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      var data = doc.data();
      data['id'] = doc.id; // Store document ID for future reference
      return data;
    }).toList());
  }

  // Format date to dd-MM-yy
  String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat("dd-MM-yy").format(date);
    } catch (e) {
      return "Invalid Date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Past Work Done", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF6C63FF),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: fetchCompletedBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text("No past work history", style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey)),
            );
          }

          final pastWork = snapshot.data!;

          return ListView.builder(
            itemCount: pastWork.length,
            itemBuilder: (context, index) {
              final work = pastWork[index];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('user detail').doc(work['id']).get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: ListTile(
                        leading: const Icon(Icons.check_circle, color: Colors.green, size: 30),
                        title: Text("Loading...", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    );
                  }

                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return SizedBox.shrink(); // Hide entry if user data doesn't exist
                  }

                  var user = userSnapshot.data!.data() as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green, size: 30),
                      title: Text(
                        user["full_name"] ?? "Unknown User",
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Contact: ${user['contact_number'] ?? 'Not Available'}",
                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54)),
                          Text("Address: ${user['address'] ?? 'Not Available'}",
                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54)),
                          Text("City: ${user['city'] ?? 'Unknown'}",
                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54)),
                          Text("Service: ${work["serviceType"] ?? 'Unknown Service'}",
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                          Text("Date: ${formatDate(work["selectedDate"] ?? '')}",
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
