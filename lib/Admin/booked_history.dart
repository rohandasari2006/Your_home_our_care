import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import date formatter

class BookedHistory extends StatefulWidget {
  @override
  _BookingRequestsScreenState createState() => _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends State<BookedHistory> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch bookings where status is either "Rejected" or "Completed"
  Stream<QuerySnapshot> getBookingsStream() {
    return _firestore
        .collection('booking maid')
        .where('status', whereIn: ['Rejected', 'Completed']) // Filter for Rejected and Completed
        .snapshots();
  }

  // Fetch user details from Firestore
  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    try {
      DocumentSnapshot userDoc =
      await _firestore.collection('user detail').doc(userId).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching user details: $e");
      return null;
    }
  }

  // Format date to "dd/MM/yy"
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
        title: Text("Booking History"),
        backgroundColor: Color(0xFF6C63FF),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getBookingsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No booking history found"));
          }

          var bookings = snapshot.data!.docs;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              var booking = bookings[index].data() as Map<String, dynamic>;
              String userId = bookings[index].id ?? "Unknown User";
              List<dynamic> tasks = booking["selectedTasks"] ?? [];

              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Booking ID: ${bookings[index].id}",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      FutureBuilder<Map<String, dynamic>?>(
                        future: getUserDetails(userId),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }

                          if (userSnapshot.hasData && userSnapshot.data != null) {
                            var userDetails = userSnapshot.data!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8),
                                Text(
                                  "User Details:",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text("Name: ${userDetails['full_name']}"),
                                Text("Address: ${userDetails['address']}"),
                                Text("Phone: ${userDetails['contact_number']}"),
                              ],
                            );
                          } else {
                            return Text("User details not found");
                          }
                        },
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Maid Details:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("Maid Name: ${booking["maidName"]}"),
                      Text("Date: ${formatDate(booking["selectedDate"])}"),
                      Text("Time Slot: ${booking["selectedTimeSlot"] ?? 'Unknown Time'}"),
                      Text("Total Price: ${booking['totalPrice']}",style: TextStyle(fontWeight: FontWeight.bold),),
                      SizedBox(height: 8),
                      Text(
                        "Selected Tasks:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: tasks.isNotEmpty
                            ? tasks.map((task) => Text("• $task")).toList()
                            : [Text("No tasks selected")],
                      ),
                      SizedBox(height: 8),
                      Chip(
                        label: Text(booking["status"]),
                        backgroundColor: booking["status"] == "Completed"
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
