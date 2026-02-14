import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserFeedbackScreen extends StatefulWidget {
  @override
  _UserFeedbackScreenState createState() => _UserFeedbackScreenState();
}

class _UserFeedbackScreenState extends State<UserFeedbackScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> feedbackCategories = [
    "Service Quality",
    "App Experience",
    "Payment Issues",
    "Other"
  ]; // Define known categories

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("User Feedback"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: feedbackCategories.length,
        itemBuilder: (context, index) {
          String category = feedbackCategories[index];

          return StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('feedback')
                .doc(category)
                .collection('responses')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, responseSnapshot) {
              if (responseSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!responseSnapshot.hasData || responseSnapshot.data!.docs.isEmpty) {
                return SizedBox.shrink(); // Hide empty categories
              }

              var responseDocs = responseSnapshot.data!.docs;

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                margin: EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    category,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                  children: responseDocs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final feedback = data['feedback'] ?? "No feedback provided.";
                    final timestamp = data['timestamp'] != null
                        ? DateFormat('MMM d, y hh:mm a').format((data['timestamp'] as Timestamp).toDate())
                        : "Unknown time";

                    return _buildFeedbackCard(feedback, timestamp);
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFeedbackCard(String feedback, String timestamp) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4, spreadRadius: 2)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.person, color: Colors.white),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(feedback, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(height: 5),
                Text(timestamp, style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
