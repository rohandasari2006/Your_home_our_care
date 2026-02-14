import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yhoc/globals.dart' as globals;

class HelperProfileScreen extends StatelessWidget {
  const HelperProfileScreen({Key? key}) : super(key: key);

  Future<Map<String, dynamic>?> fetchHelperData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('All Maid')
          .where('mobile', isEqualTo: globals.helper_no)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID manually
        return data;
      }
    } catch (e) {
      print("Error fetching helper data: $e");
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Helper Profile",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[200],
      body: FutureBuilder<Map<String, dynamic>?> (
        future: fetchHelperData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No data available"));
          }

          var helperData = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: helperData['livePhoto'] != null
                      ? NetworkImage(helperData['livePhoto'])
                      : const AssetImage("assets/default_avatar.png") as ImageProvider,
                ),
                const SizedBox(height: 15),
                Text(
                  helperData['name'] ?? 'No Name',
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  helperData['mobile'] ?? 'No Mobile',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),
                _buildProfileDetail("Maid ID", helperData['id']??""),
                _buildProfileDetail("Work Capabilities", helperData['workCapabilities'] ?? 'N/A'),
                _buildProfileDetail("Gender", helperData['gender'] ?? 'N/A'),
                _buildProfileDetail("Age", helperData['age'] ?? 'N/A'),
                _buildProfileDetail("Address", helperData['address'] ?? 'N/A'),
                _buildProfileDetail("Education", helperData['education'] ?? 'N/A'),
                _buildProfileDetail("Experience", helperData['experience'] ?? 'N/A'),
                _buildProfileDetail("Languages", helperData['languages'] ?? 'N/A'),
                _buildProfileDetail("Email", helperData['email'] ?? 'N/A'),
                _buildProfileDetail("Availability", helperData['available'] == true ? 'Available' : 'Not Available'),
                _buildProfileDetail("Status", helperData['status'] ?? 'N/A'),
                _buildProfileImage("Police Verification", helperData['policeVerification']),
                _buildProfileImage("Aadhar Card", helperData['aadharCard']),
                _buildProfileImage("Marksheet", helperData['marksheet']),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileDetail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(String title, String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
        ),
        Container(
          height: 200,
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(imageUrl, fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }
}