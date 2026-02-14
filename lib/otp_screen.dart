import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;
import 'User/home.dart';
import 'User/user_detail_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationid;
  final String n;

  OTPVerificationScreen({required this.phoneNumber, required this.verificationid, required this.n});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> controllers = List.generate(6, (index) => TextEditingController());

  String otp = '';
  bool isLoading = false;

  // 🔹 Save phone number persistently
  Future<void> saveUserNumber(String phoneNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_number', phoneNumber);
    globals.no = phoneNumber;
  }

  // 🔹 Verify OTP
  void verifyotp() async {
    setState(() {
      isLoading = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationid,
        smsCode: otp,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        final userRef = FirebaseFirestore.instance.collection('user detail');

        // 🔹 Use widget.n instead of globals.no (because it's not set yet)
        final docSnapshot = await userRef.doc(widget.n).get();

        await saveUserNumber(widget.n); // Save phone number persistently

        if (docSnapshot.exists) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserDetailsScreen()));
        }
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong. Please try again.')),
      );
    }
  }

  // 🔹 Build OTP field widget
  Widget _buildOTPField(int index) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade400, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (value) {
          otp = controllers.map((c) => c.text).join(); // Collect the OTP

          if (value.isNotEmpty && index < focusNodes.length - 1) {
            FocusScope.of(context).requestFocus(focusNodes[index + 1]);
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(focusNodes[index - 1]);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'OTP Verification',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Text(
                  'Verification Code',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Enter the 6-digit code sent to ${widget.phoneNumber}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 30),

                // 🔹 OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) => _buildOTPField(index)),
                ),

                SizedBox(height: 30),

                // 🔹 Verify Button or Loading Spinner
                isLoading
                    ? CircularProgressIndicator(
                  color: Colors.white,
                  backgroundColor: Color(0xFF4A47A3),
                )
                    : ElevatedButton(
                  onPressed: () {
                    if (otp.length == 6) {
                      verifyotp();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please enter the full OTP.")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4A47A3),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size(double.infinity, 55),
                    elevation: 4,
                  ),
                  child: Text(
                    'Verify',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
