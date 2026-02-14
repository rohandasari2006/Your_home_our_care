import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yhoc/login_screen.dart';
import '../Helper/helper_detail_screen.dart';
import '../theme_provider.dart';
import 'privacy_security.dart';
import 'customer_support.dart';
import 'give_feedback.dart';
import 'user_booking_details.dart';
import 'user_detail_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yhoc/globals.dart' as globals;
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  String? profilePic; // Variable to store the profile image URL
  String? userName;
  String? userEmail;
  final ImagePicker _picker = ImagePicker();
  final String? userId = globals.no; // Example user ID

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// Fetch all user data from Firestore
  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('user detail')
          .doc(userId)
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
        setState(() {
          profilePic = userData['profileImage'];
          userName = userData['full_name'] ?? 'Unknown User';
          userEmail = userData['email'] ?? 'No Email';
        });
      } else {
        print("No user data found for userId: $userId");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  /// Pick image, upload to Cloudinary, and update Firestore
  Future<void> _pickImage(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.blue),
                title: Text("Take Photo"),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? pickedFile = await _picker.pickImage(
                      source: ImageSource.camera);
                  if (pickedFile != null) {
                    await _uploadAndSetImage(File(pickedFile.path));
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.green),
                title: Text("Choose from Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? pickedFile = await _picker.pickImage(
                      source: ImageSource.gallery);
                  if (pickedFile != null) {
                    await _uploadAndSetImage(File(pickedFile.path));
                  }
                },
              ),
              if (profilePic != null)
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text("Remove Profile Picture"),
                  onTap: () async {
                    Navigator.pop(context);
                    await _removeProfilePicture();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// Upload image to Cloudinary and update Firestore
  Future<void> _uploadAndSetImage(File imageFile) async {
    String? uploadedImageUrl = await CloudinaryService().uploadImage(imageFile);
    if (uploadedImageUrl != null) {
      await FirebaseFirestore.instance.collection('user detail')
          .doc(userId)
          .update({
        'profileImage': uploadedImageUrl,
      });
      setState(() {
        _fetchUserData();
      });
    }
  }

  /// Remove profile picture
  Future<void> _removeProfilePicture() async {
    await FirebaseFirestore.instance.collection('user detail')
        .doc(userId)
        .update({
      'profileImage': null,
    });
    setState(() {
      profilePic = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        elevation: 1,
        title: Text(
          "Profile",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
            color: isDarkMode ? Colors.white : Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context, isDarkMode),
            _buildSectionTitle("Bookings", isDarkMode),
            _buildListTile(Icons.history, "Booking History", Colors.blue, () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => UserBookingDetails()));
            }, isDarkMode),
            _buildListTile(
                Icons.receipt_long, "Invoices & Bills", Colors.green, () {},
                isDarkMode),
            _buildSectionTitle("Settings", isDarkMode),
            _buildListTile(Icons.lock, "Privacy & Security", Colors.orange, () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => PrivacySecurityScreen()));
            }, isDarkMode),
            _buildSectionTitle("Help & Support", isDarkMode),
            _buildListTile(
                Icons.support_agent, "Customer Service", Colors.red, () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => CustomerSupportScreen()));
            }, isDarkMode),
            _buildListTile(Icons.feedback, "Give Feedback", Colors.teal, () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => GiveFeedbackScreen()));
            }, isDarkMode),
            _buildLogoutButton(isDarkMode, context),
          ],
        ),
      ),
    );
  }

  /// Profile Header
  Widget _buildProfileHeader(BuildContext context, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _pickImage(context),
            child: CircleAvatar(
              radius: 40,
              backgroundImage: profilePic != null
                  ? NetworkImage(profilePic!)
                  : AssetImage("assets/profile_pic.png") as ImageProvider,
              child: profilePic == null
                  ? Icon(Icons.camera_alt, color: Colors.white, size: 30)
                  : null,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName ?? "User Name",
                  style: GoogleFonts.poppins(fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black),
                ),
                Text(
                  userEmail ?? "user@example.com",
                  style: GoogleFonts.poppins(fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UserDetailsScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Text(title, style: GoogleFonts.poppins(fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.white : Colors.black87)),
    );
  }

  Widget _buildListTile(IconData icon, String title, Color color,
      VoidCallback onTap, bool isDarkMode) {
    return Card(
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: GoogleFonts.poppins(fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(bool isDarkMode, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: ListTile(
        tileColor: isDarkMode ? Colors.grey[900] : Colors.white,
        leading: Icon(Icons.logout, color: Colors.red),
        title: Text("Logout", style: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
        onTap: () {
          signOut(context);
        },
      ),
    );
  }

  Future<void> clearUserNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_number');
    globals.no = ''; // Clear global variable
  }

  void signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      await clearUserNumber(); // Clear stored user data
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } catch (e) {
      print("Error signing out: $e");
    }
  }


}
  class CloudinaryService {
  final String cloudName = "dvy9kerpq";
  final String apiKey = "444885385856863";
  final String apiSecret = "N2jXmuuw25v51X9fyJHMRASS03U";

  Future<String?> uploadImage(File imageFile) async {
    try {
      final String uploadUrl = "https://api.cloudinary.com/v1_1/$cloudName/image/upload";
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
        ..fields['upload_preset'] = 'Images'
        ..fields['api_key'] = apiKey
        ..fields['folder'] = 'Images'
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['secure_url'];
      } else {
        print('Cloudinary upload error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }
}
