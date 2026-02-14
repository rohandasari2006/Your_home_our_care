import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yhoc/globals.dart' as globals;
import 'helper_profile.dart';
import 'requests_screen.dart';
import 'past_work_screen.dart';

class HelperHomeScreen extends StatelessWidget {
  const HelperHomeScreen({Key? key}) : super(key: key);

  // Fetch helper's profile image from Firestore
  Future<String?> fetchProfileImage() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('All Maid')
          .where('mobile', isEqualTo: globals.helper_no)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first["livePhoto"]; // Assuming 'livePhoto' contains the URL
      }
    } catch (e) {
      print("Error fetching profile image: $e");
    }
    return null; // Return null if no image found
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        exit(0);
      },
      child: Scaffold(
        backgroundColor: Colors.grey[200], // Light background for a modern look
        appBar: AppBar(
          title: Text(
            "Helper Dashboard",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF6C63FF),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // Fetch and Display Profile Image
                FutureBuilder<String?>(
                  future: fetchProfileImage(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    String? imageUrl = snapshot.data;
                    return GestureDetector(
                      onTap: () {
                        // Action when tapped (e.g., open a profile screen)
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HelperProfileScreen()),
                        );
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: imageUrl != null
                            ? NetworkImage(imageUrl)
                            : const AssetImage("assets/default_avatar.png") as ImageProvider,
                      ),
                    );
                  },
                ),


                const SizedBox(height: 15),

                // Welcome Text
                Text(
                  "Welcome to Your Dashboard!",
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  "Manage your job requests and track completed work easily from here.",
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                // Requests Came Button
                _buildActionButton(
                  context,
                  "Requests Came",
                  Icons.notifications_active,
                  "View new service requests from users.",
                      () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RequestsScreen()));
                  },
                ),

                const SizedBox(height: 20),

                // Past Work Done Button
                _buildActionButton(
                  context,
                  "Past Work Done",
                  Icons.history,
                  "Check your completed work history.",
                      () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PastWorkScreen()));
                  },
                ),

                const SizedBox(height: 30),

                // Footer Information
                Text(
                  "Keep up the great work! Helping others makes a difference.",
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Button Widget
  Widget _buildActionButton(BuildContext context, String title, IconData icon, String subtitle, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 6,
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.white),
            const SizedBox(height: 6),
            Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(subtitle, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
