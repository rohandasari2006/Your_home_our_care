import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookingRequestsScreen extends StatefulWidget {
  @override
  _BookingRequestsScreenState createState() => _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends State<BookingRequestsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, Map<String, dynamic>> maidDetailsCache = {};
  Map<String, Map<String, dynamic>> userDetailsCache = {};

  Stream<QuerySnapshot> getBookingsStream() {
    return _firestore.collection('booking maid')
        .where('status' ,isEqualTo: 'In Progress')
    .snapshots();
  }

  String formatDate(String dateString) {
    try {
      DateTime date = DateFormat("yyyy-MM-dd").parse(dateString);
      return DateFormat("dd/MM/yy").format(date);
    } catch (e) {
      return "Invalid Date";
    }
  }

  Future<Map<String, dynamic>?> getMaidDetails(String maidName) async {
    if (maidDetailsCache.containsKey(maidName)) {
      return maidDetailsCache[maidName];
    }

    try {
      QuerySnapshot query = await _firestore
          .collection('booking maid') // Assuming 'maids' collection for maid details
          .where('maidName', isEqualTo: maidName)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        Map<String, dynamic> maidDetails = query.docs.first.data() as Map<String, dynamic>;
        maidDetailsCache[maidName] = maidDetails;
        return maidDetails;
      }
    } catch (e) {
      print("Error fetching maid details: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    if (userDetailsCache.containsKey(userId)) {
      return userDetailsCache[userId];
    }

    try {
      DocumentSnapshot userDoc = await _firestore.collection('user detail').doc(userId).get();

      if (userDoc.exists) {
        Map<String, dynamic> userDetails = userDoc.data() as Map<String, dynamic>;
        userDetailsCache[userId] = userDetails;
        return userDetails;
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
    return null;
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore.collection('booking maid').doc(bookingId).update({'status': status});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking status updated to $status')),
      );
    } catch (e) {
      print("Error updating booking status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update booking status')),
      );
    }
  }

  Future<void> showApproveDialog(String bookingId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Approve Booking"),
          content: Text("Are you sure you want to approve this booking?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(
              onPressed: () async {
                await updateBookingStatus(bookingId, "Approved");
                Navigator.pop(context);
              },
              child: Text("Approve"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Booking Requests"),
        backgroundColor: Color(0xFF6C63FF),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getBookingsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No booking requests found"));
          }

          var bookings = snapshot.data!.docs;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              var booking = bookings[index].data() as Map<String, dynamic>;
              String bookingId = bookings[index].id;
              String maidName = booking["maidName"] ?? 'Unknown Maid';
              String userId = bookings[index].id ?? 'Unknown User';
              List<dynamic> tasks = booking["selectedTasks"] ?? [];

              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Booking ID: $bookingId", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      FutureBuilder<Map<String, dynamic>?>(future: getMaidDetails(maidName), builder: (context, maidSnapshot) {
                        if (maidSnapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (maidSnapshot.hasData && maidSnapshot.data != null) {
                          var maidDetails = maidSnapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8),
                              Text(
                                "Maid Details:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text("Maid Name: ${maidDetails['maidName']}"),
                              Text("Phone: ${maidDetails['maidPhone']}"),
                              Text("Maid ID: ${maidDetails['maidId']}"),
                              Text("Total Price: ${booking['totalPrice']}",style: TextStyle(fontWeight: FontWeight.bold),),

                            ],
                          );
                        } else {
                          return Text("Maid details not found");
                        }
                      }),
                      FutureBuilder<Map<String, dynamic>?>(future: getUserDetails(userId), builder: (context, userSnapshot) {
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
                              Text("Phone: ${userDetails['contact_number']}"),
                              Text("Address: ${userDetails['address']}"),
                            ],
                          );
                        } else {
                          return Text("User details not found");
                        }
                      }),
                      SizedBox(height: 8),
                      Text("Date: ${formatDate(booking["selectedDate"] ?? '')}"),
                      Text("Time Slot: ${booking["selectedTimeSlot"] ?? 'Unknown Time'}"),
                      SizedBox(height: 8),
                      Text("Selected Tasks:",style: TextStyle(fontWeight: FontWeight.bold),),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: tasks.isNotEmpty
                            ? tasks.map((task) => Text("• $task")).toList()
                            : [Text("No tasks selected")],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            label: Text(booking["status"] ?? "Unknown Status"),
                            backgroundColor: booking["status"] == "Pending"
                                ? Colors.orange.withOpacity(0.2)
                                : Colors.green.withOpacity(0.2),
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () => showApproveDialog(bookingId),
                            child: Text("Approve"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          ),
                          ElevatedButton(
                            onPressed: () => updateBookingStatus(bookingId, "Rejected"),
                            child: Text("Reject"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          ),
                        ],
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
