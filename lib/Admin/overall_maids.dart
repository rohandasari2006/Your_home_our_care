import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'maid_detail.dart';

class OverallMaidsScreen extends StatefulWidget {
  @override
  _OverallMaidsScreenState createState() => _OverallMaidsScreenState();
}

class _OverallMaidsScreenState extends State<OverallMaidsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Overall Maids"),
        backgroundColor: Color(0xFF6C63FF),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('All Maid').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No maids found"));
          }

          var maids = snapshot.data!.docs;

          return ListView.builder(
            itemCount: maids.length,
            itemBuilder: (context, index) {
              var maid = maids[index];
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(maid["livePhoto"] ?? ""),
                  ),
                  title: Text(maid["name"] ?? ""),
                  subtitle: Text("Status: ${maid["status"]}"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MaidDetail(
                          id: maid.id,

                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
