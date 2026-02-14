import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'approve_maid.dart'; // Import ApproveMaidScreen

class MaidRequestsScreen extends StatefulWidget {
  @override
  _MaidRequestsScreenState createState() => _MaidRequestsScreenState();
}

class _MaidRequestsScreenState extends State<MaidRequestsScreen> {
  List<Map<String, dynamic>> maids = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMaidRequests();
  }

  Future<void> fetchMaidRequests() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('temp_maid')
          .get();

      List<Map<String, dynamic>> fetchedMaids = snapshot.docs.map((doc) {
        return {
          "id": doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      setState(() {
        maids = fetchedMaids;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching maid requests: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToApproveMaid(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApproveMaidScreen(

          maidId: maids[index]["id"] ?? "",

        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Maid Requests"),
        backgroundColor: Color(0xFF6C63FF),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : maids.isEmpty
          ? Center(child: Text("No maid requests found"))
          : Padding(
        padding: EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: maids.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                      maids[index]["livePhoto"] ?? ""),
                ),
                title: Text(maids[index]["name"] ?? ""),
                subtitle: Text("Status: ${maids[index]["status"]}"),
                onTap: () => navigateToApproveMaid(index),
              ),
            );
          },
        ),
      ),
    );
  }
}
