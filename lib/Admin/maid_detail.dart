import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaidDetail extends StatelessWidget {
  final String id;

  MaidDetail({required this.id});

  void showFullImage(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(title: Text(title), backgroundColor: Color(0xFF6C63FF)),
            Expanded(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Maid Details"),
        backgroundColor: Color(0xFF6C63FF),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('All Maid').doc(id).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Maid details not found"));
          }

          var maid = snapshot.data!.data() as Map<String, dynamic>;

          // Split workCapabilities string into a list



          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(maid["livePhoto"] ?? ""),
                  ),
                ),
                SizedBox(height: 15),

                // Maid Details
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        detailRow(Icons.person, "Name: ${maid["name"]}"),
                        detailRow(Icons.badge, "Maid ID: $id"),
                        detailRow(Icons.email, "Email: ${maid["email"] ?? "N/A"}"),
                        detailRow(Icons.phone, "Contact: ${maid["mobile"] ?? "N/A"}"),
                        detailRow(Icons.location_on, "Address: ${maid["address"] ?? "N/A"}"),
                        detailRow(Icons.work, "Experience: ${maid["experience"] ?? "N/A"} years"),
                        detailRow(Icons.school, "Education: ${maid["education"] ?? "N/A"}"),
                        detailRow(Icons.language, "Languages: ${maid["languages"] ?? "N/A"}"),
                        detailRow(Icons.work, "Work Capabilities: ${ maid["workCapabilities"]??"N/A"}"),

                      ],
                    ),
                  ),
                ),

                               SizedBox(height: 20),
                Text("Maid Documents", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),

                // Document Section
                buildDocumentTile(context, "Aadhar Card", maid["aadharCard"] ?? ""),
                buildDocumentTile(context, "Police Verification", maid["policeVerification"] ?? ""),
                buildDocumentTile(context, "Marksheet", maid["marksheet"] ?? ""),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(width: 10),
          Expanded(  // Wrap with Expanded for proper text wrap
            child: Text(
              text,
              style: TextStyle(fontSize: 16),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }


  Widget workCapabilityTile(String capability) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(Icons.check_circle, color: Colors.green),
        title: Text(capability, style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget buildDocumentTile(BuildContext context, String title, String imageUrl) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.insert_drive_file, color: Colors.blue),
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        trailing: IconButton(
          icon: Icon(Icons.visibility, color: Colors.green),
          onPressed: () => showFullImage(context, imageUrl, title),
        ),
      ),
    );
  }
}
