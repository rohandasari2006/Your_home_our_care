import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'maid_booking_calendar.dart';

class MaidDetailsScreen extends StatefulWidget {
  final String serviceType;
  const MaidDetailsScreen({Key? key, required this.serviceType}) : super(key: key);  @override
  _MaidDetailsScreenState createState() => _MaidDetailsScreenState();
}
class _MaidDetailsScreenState extends State<MaidDetailsScreen> {
  String searchQuery = '';

  Stream<QuerySnapshot> getMaidStream() {
    return FirebaseFirestore.instance.collection("All Maid").snapshots();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Available Maids',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Color(0xFF6C63FF),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search maids...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Firestore StreamBuilder
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getMaidStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error fetching maids"));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No maids available"));
                }

                List<QueryDocumentSnapshot> maids = snapshot.data!.docs;

                // Filter maids based on search query
                var filteredMaids = maids.where((maid) {
                  var maidData = maid.data() as Map<String, dynamic>? ?? {}; // Ensures null safety
                  String name = maidData["name"]?.toString() ?? "";
                  return name.toLowerCase().contains(searchQuery.toLowerCase());
                }).toList();

                // Sorting by Experience (Descending)
                filteredMaids.sort((a, b) {
                  var maidDataA = a.data() as Map<String, dynamic>? ?? {};
                  var maidDataB = b.data() as Map<String, dynamic>? ?? {};

                  int expA = int.tryParse(maidDataA["experience"].toString()) ?? 0;
                  int expB = int.tryParse(maidDataB["experience"].toString()) ?? 0;

                  return expB.compareTo(expA);
                });


                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredMaids.length,
                  itemBuilder: (context, index) {
                    var maid = filteredMaids[index];
                    var maidData = maid.data() as Map<String, dynamic>? ?? {};

                    String name = maidData["name"] ?? "Unknown";
                    String status = maidData["status"] ?? "N/A";
                    int experience = int.tryParse(maidData["experience"].toString()) ?? 0;
                    String? profileImage = maidData["livePhoto"];

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: profileImage != null
                              ? NetworkImage(profileImage)
                              : AssetImage("assets/default_avatar.png") as ImageProvider,
                          radius: 30,
                        ),
                        title: Text(
                          name,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Experience: $experience years',
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                            Text(
                              'Status: $status',
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MaidBookingScreen(maidId: maid.id,serviceType: widget.serviceType),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MaidBookingScreen extends StatelessWidget {
  final String maidId;
  final String serviceType;
  MaidBookingScreen({required this.maidId,required this.serviceType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maid Details', style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Color(0xFF6C63FF),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection("All Maid").doc(maidId).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error loading details"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Maid not found"));
          }

          var maidData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          String id = snapshot.data!.id;
          // Ensure all values are safely extracted
          String name = maidData["name"] ?? "Unknown";
          int experience = int.tryParse(maidData["experience"].toString()) ?? 0;
          String mobileNo = maidData["mobile"] ?? "N/A";
          String address = maidData["address"] ?? "N/A";
          String status = maidData["status"] ?? "N/A";
          String? profileImage = maidData["livePhoto"];
          String lang=maidData["languages"];
          String gender=maidData['gender'];

          // ✅ Convert Firestore Array (List) to String



          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    backgroundImage: profileImage != null
                        ? NetworkImage(profileImage)
                        : AssetImage("assets/default_avatar.png") as ImageProvider,
                    radius: 60,
                  ),
                ),
                SizedBox(height: 16),
                Text(name, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                Text('Experience: $experience years', style: GoogleFonts.poppins(fontSize: 18)),
                Text('Maid ID: $id', style: GoogleFonts.poppins(fontSize: 18)),
                Text('Mobile No: $mobileNo', style: GoogleFonts.poppins(fontSize: 16)),
                Text('Address: $address', style: GoogleFonts.poppins(fontSize: 16)),
                Text('Status: $status', style: GoogleFonts.poppins(fontSize: 16)),
                Text('Gender:$gender',style: GoogleFonts.poppins(fontSize: 16),),
                // ✅ Displaying Languages as a comma-separated string
                Text('Languages: $lang', style: GoogleFonts.poppins(fontSize: 16)),

                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MaidBookingCalendarScreen(maid: maidData,serviceType: serviceType,maidId:id),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text(
                    'Book Now',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
