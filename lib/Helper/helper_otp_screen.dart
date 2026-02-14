import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yhoc/Helper/Approvel_screen.dart';
import 'package:yhoc/Helper/helper_detail_screen.dart';
import 'package:yhoc/Helper/helper_home_screen.dart';
import 'package:yhoc/globals.dart' as globals;

class HelperOtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationid;

  HelperOtpScreen({required this.phoneNumber, required this.verificationid});

  @override
  State<HelperOtpScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<HelperOtpScreen> {
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> controllers =
      List.generate(6, (index) => TextEditingController());

  String otp = '';
  bool isLoading = false;

  Future<void> verifyotp() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Verify OTP using Firebase Authentication
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationid,
        smsCode: otp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Firestore reference
      final firestore = FirebaseFirestore.instance;

      // Check if phone number exists in "All Maid" collection
      final maidQuery = await firestore
          .collection('All Maid')
          .where('mobile', isEqualTo: globals.helper_no)
          .get();

      if (maidQuery.docs.isNotEmpty) {
        // Phone number exists in "All Maid", navigate to HelperHomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HelperHomeScreen()),
        );
        return;
      }

      // Check if phone number exists in "temp_detail" collection
      final tempQuery = await firestore
          .collection('temp_detail')
          .where('mobile', isEqualTo: globals.helper_no)
          .get();

      if (tempQuery.docs.isNotEmpty) {
        final status = tempQuery.docs.first.data()['status'] ?? '';
        if (status == 'Approved') {
          // Status is "Approved", navigate to HelperHomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HelperHomeScreen()),
          );
        } else {
          // Status is not "Approved", navigate to ApprovalScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ApprovalScreen()),
          );
        }
        return;
      }

      // If phone number is not in either collection, navigate to HelperDetailScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HelperDetailScreen()),
      );
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying OTP. Please try again.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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
          otp = controllers.map((c) => c.text).join();

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) => _buildOTPField(index)),
                ),
                SizedBox(height: 30),
                isLoading
                    ? CircularProgressIndicator(
                    color: Colors.white,
                    backgroundColor:Color(0xFF4A47A3))
                    : ElevatedButton(
                        onPressed: () {
                          if (otp.length == 6) {
                            verifyotp();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("Please enter the full OTP.")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4A47A3),
                          padding: EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: Size(double.infinity, 55),
                        ),
                        child: Text(
                          'Verify',
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
