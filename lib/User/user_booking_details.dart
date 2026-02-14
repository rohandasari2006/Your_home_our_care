import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yhoc/globals.dart' as globals;

class UserBookingDetails extends StatefulWidget {
  @override
  _UserBookingDetailsState createState() => _UserBookingDetailsState();
}

class _UserBookingDetailsState extends State<UserBookingDetails> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getBookingsStream() {
    return FirebaseFirestore.instance
        .collection("booking maid")
        .where(FieldPath.documentId, isEqualTo: globals.no)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Bookings", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Color(0xFF6C63FF),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: getBookingsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error loading bookings"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No bookings found"));
          }

          List<QueryDocumentSnapshot<Map<String, dynamic>>> bookings = snapshot.data!.docs;

          List<QueryDocumentSnapshot<Map<String, dynamic>>> ongoingBookings = bookings.where((doc) {
            var data = doc.data() as Map<String, dynamic>? ?? {};
            return data["status"] == "Confirmed" || data["status"] == "In Progress";
          }).toList();

          List<QueryDocumentSnapshot<Map<String, dynamic>>> pastBookings = bookings.where((doc) {
            var data = doc.data() as Map<String, dynamic>? ?? {};
            return data["status"] == "Completed" || data["status"] == "Canceled";
          }).toList();

          return Column(
            children: [
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Color(0xFF6C63FF),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Color(0xFF6C63FF),
                  labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  tabs: [
                    Tab(text: "Ongoing"),
                    Tab(text: "Past"),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingList(ongoingBookings, true),
                    _buildBookingList(pastBookings, false),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingList(List<QueryDocumentSnapshot<Map<String, dynamic>>> bookings, bool isOngoing) {
    if (bookings.isEmpty) {
      return Center(
        child: Text(isOngoing ? "No Ongoing Bookings" : "No Past Bookings", style: GoogleFonts.poppins(fontSize: 16)),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        var booking = bookings[index];
        var data = booking.data() as Map<String, dynamic>? ?? {};
        String? dateString = data["selectedDate"];
        DateTime? dateTime = dateString != null ? DateTime.parse(dateString) : null;

        return _buildBookingCard(
          maidId: data["maidId"] ?? "Unknown ID",
          maidName: data["maidName"] ?? "Unknown Maid",
          serviceType: data["serviceType"] ?? "Maid Service",
          dateTime: dateTime ?? DateTime.now(),
          timeSlot: data["selectedTimeSlot"] ?? "Unknown Time",
          status: data["status"] ?? "Unknown",
          imageUrl: data["livePhoto"] ?? "assets/default_avatar.png",
          price:(data["totalPrice"] ?? 0).toInt(),
          bookingId: booking.id,
          isOngoing: isOngoing,
        );
      },
    );
  }
}

Widget _buildBookingCard({
  required String maidId,
  required String maidName,
  required DateTime dateTime,
  required String serviceType,
  required String timeSlot,
  required String status,
  required String imageUrl,
  required int price,
  required bool isOngoing, required bookingId,
}) {
  return Card(
    margin: EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 4,
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                serviceType,
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                backgroundImage: imageUrl.startsWith("http") ? NetworkImage(imageUrl) : AssetImage(imageUrl) as ImageProvider,
                radius: 25,
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    maidName,
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "${dateTime.day}/${dateTime.month}/${dateTime.year}",
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Time Slot: $timeSlot",
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                "Price: ₹$price",
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (isOngoing) _buildBookingActions(maidId:  maidId),
        ],
      ),
    ),
  );
}

Widget _buildBookingActions({
  required maidId,
}) {
  return Row(
    children: [
      TextButton.icon(
        onPressed: () async{


        },
        icon: Icon(Icons.edit_calendar_rounded, color: Color(0xFF6C63FF)),
        label: Text("Reschedule", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
      ),
      TextButton.icon(
        onPressed: () async{
          // Implement Cancel Function
          try {
            // Update the status to "Canceled" in Firestore
            print(maidId);
            await FirebaseFirestore.instance
                .collection("booking maid")
                .doc(globals.no) // Use the booking document ID
                .update({"status": "Canceled"});

            // Notify the user of success
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(content: Text("Booking canceled successfully")),
            // );
          } catch (e) {
            // Handle errors gracefully
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(content: Text("Failed to cancel booking: $e")),
            // );
          }
        },
        icon: Icon(Icons.cancel_rounded, color: Colors.red),
        label: Text("Cancel", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red)),
      ),
    ],
  );
}

Color _getStatusColor(String status) {
  switch (status) {
    case "Confirmed":
      return Colors.green;
    case "In Progress":
      return Colors.orange;
    case "Completed":
      return Colors.blue;
    case "Canceled":
      return Colors.red;
    default:
      return Colors.grey;
  }
}
