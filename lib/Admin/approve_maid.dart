import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yhoc/Admin/admin_module.dart';

class ApproveMaidScreen extends StatelessWidget {
  final String maidId;

  ApproveMaidScreen({required this.maidId});

  Future<Map<String, dynamic>> fetchMaidDetails() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('temp_maid').doc(maidId).get();

    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    } else {
      throw Exception("Maid not found");
    }
  }

  void showFullImage(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          children: [
            AppBar(
              title: Text(title),
              backgroundColor: Color(0xFF6C63FF),
              automaticallyImplyLeading: false,
            ),
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


  void showConfirmationDialog(BuildContext context, String action)
  {
    TextEditingController maidIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$action Maid"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Are you sure you want to $action this maid?"),
            if (action == "Approve") // Only ask for Maid ID when approving
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextField(
                  controller: maidIdController,
                  decoration: InputDecoration(
                    labelText: "Enter Maid ID",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (action == "Approve") {
                String newMaidId = maidIdController.text.trim();
                if (newMaidId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Maid ID cannot be empty")),
                  );
                  return;
                }

                try {
                  // Fetch maid details
                  DocumentSnapshot snapshot = await FirebaseFirestore.instance
                      .collection('temp_maid')
                      .doc(maidId)
                      .get();

                  if (!snapshot.exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Maid not found")),
                    );
                    return;
                  }

                  Map<String, dynamic> maidData = snapshot.data() as Map<String, dynamic>;

                  // Add "status" field as "Approved"
                  maidData["status"] = "Approved";
                  maidData["available"] = true;
                  // Store in the "All Maid" collection using entered Maid ID as document ID
                  await FirebaseFirestore.instance
                      .collection('All Maid')
                      .doc(newMaidId) // Use user-entered Maid ID as document ID
                      .set(maidData);

                  // Delete from temp_maid
                  await FirebaseFirestore.instance
                      .collection('temp_maid')
                      .doc(maidId)
                      .delete();
                Navigator.pop(context,MaterialPageRoute(builder: (context)=>AdminModule()),);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Maid Approved Successfully")),

                  );

                  Navigator.pop(context); // Close the screen
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              } else if (action == "Reject") {
                // Simply delete from temp_maid on rejection
                await FirebaseFirestore.instance
                    .collection('temp_maid')
                    .doc(maidId)
                    .delete();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Maid Rejected")),
                );

                Navigator.pop(context); // Close the dialog after rejection
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: action == "Approve" ? Colors.green : Colors.red,
            ),
            child: Text(action),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Approve Maid"),
        backgroundColor: Color(0xFF6C63FF),
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: fetchMaidDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData) {
              return Center(child: Text("No details found"));
            }

            final maid = snapshot.data!;
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
                          buildDetailRow(Icons.person, Colors.purple, "Name", maid["name"]),
                          buildDetailRow(Icons.badge, Colors.blue, "Maid ID", maid["id"] ?? maidId),
                          buildDetailRow(Icons.location_on, Colors.red, "Address", maid["address"]),
                          buildDetailRow(Icons.work, Colors.green, "Experience", maid["experience"]),
                          buildDetailRow(Icons.phone_android, Colors.blue, "Contact", maid["mobile"]),
                          buildDetailRow(Icons.language, Colors.purple, "Language", maid["languages"]),
                          buildDetailRow(Icons.email, Colors.green, "Email", maid["email"]),
                          buildDetailRow(Icons.work, Colors.red, "Work Capabilities", maid["workCapabilities"]),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  Text("Maid Documents", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),

                  // Document Section
                  buildDocumentTile(context, "Aadhar Card", maid["aadharCard"]),
                  buildDocumentTile(context, "Police Verification", maid["policeVerification"]),
                  buildDocumentTile(context, "Marksheet", maid["marksheet"]),

                  SizedBox(height: 30),

                  // Verification Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => showConfirmationDialog(context, "Approve"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        icon: Icon(Icons.check_circle, color: Colors.white),
                        label: Text("Approve"),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => showConfirmationDialog(context, "Reject"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        icon: Icon(Icons.cancel, color: Colors.white),
                        label: Text("Reject"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
}


Widget buildDetailRow(IconData icon, Color color, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "$label: ${value ?? ""}",
              style: TextStyle(fontSize: 16),
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }


  Widget buildDocumentTile(BuildContext context, String title, String? imageUrl) {
    return SingleChildScrollView(
      child:SafeArea(child:
      Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.insert_drive_file, color: Colors.blue),
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        trailing: IconButton(
          icon: Icon(Icons.visibility, color: Colors.green),
          onPressed: () {
            if (imageUrl != null && imageUrl.isNotEmpty) {
              showFullImage(context, imageUrl, title);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("No $title image available")),
              );
            }
          },
        ),
      ),
    )
      )
    );
  }
}
