import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yhoc/Helper/helper_home_screen.dart';
import 'package:yhoc/User/home.dart';
import 'package:yhoc/Admin/admin_module.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Helper/helper_login_screen.dart';
import 'User/User_detail_screen.dart';
import 'otp_screen.dart'; // Import Admin Module
import 'globals.dart' as globals;


class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController no = TextEditingController();
  bool isLoading = false; // Add this variable to track the loading state

  // Function to send OTP to the phone number
  void Sendotp() async {
    String phone = no.text.trim();

    // Validate phone number length (10 digits)
    if (phone.length == 10) {
      globals.no = phone;
      String n=phone;
      phone = "+91" + phone; // Adding country code

      setState(() {
        isLoading = true; // Set loading to true when OTP is being sent
      });

      // Request OTP from Firebase Authentication
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Optionally, handle automatic verification completion here
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            isLoading = false; // Stop loading if verification fails
          });

          final msg = SnackBar(content: Text(e.code));
          ScaffoldMessenger.of(context).showSnackBar(msg);
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            isLoading = false; // Stop loading once the OTP is sent
          });

          // Navigate to OTP verification screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                phoneNumber: phone,
                n:n,
                verificationid: verificationId,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            isLoading = false; // Stop loading after timeout
          });
        },
      );
    } else {
      // Show error if phone number is invalid
      final msg = SnackBar(content: Text("Please enter a valid phone number"));
      ScaffoldMessenger.of(context).showSnackBar(msg);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "helper") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AuthCheckScreenHelper()),
                  );
                }
                if (value == "admin") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminModule()),
                  );
                }
              },
              icon: Icon(Icons.more_vert, color: Colors.black),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: "helper",
                  child: Text(
                    "Login as Helper",
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ),
                PopupMenuItem(
                  value: "admin",
                  child: Text(
                    "Admin",
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      body: SingleChildScrollView(
     child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // **App Branding**
                  Column(
                    children: [
                      SizedBox(height: 80),
                      Text(
                        'YourHome\nOurCare',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C63FF),
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Premium Home Services',
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Fast • Reliable • Trusted',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),

                  // **Phone Number Input**
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              Text(
                                '🇮🇳 +91',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_down, size: 18),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            maxLength: 10, // Limits input to 10 characters
                            controller: no,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly, // Ensures only numeric input
                            ],
                            decoration: InputDecoration(
                              hintText: "Enter Mobile Number",
                              hintStyle: GoogleFonts.roboto(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 8,
                              ),
                              counterText: "",
                            ),
                          ),

                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // **Get OTP Button**
                  ElevatedButton(
                    onPressed: isLoading ? null : () { // Disable the button when loading
                      Sendotp();
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
                    child: isLoading
                        ? CircularProgressIndicator(
                      color: Colors.white,
                      backgroundColor: Color(0xFF4A47A3),
                    )
                        : Text(
                      'Get Verification Code',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 40),

                  // **Skip Button**
                  TextButton(
                    onPressed: () async {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => HomeScreen()));
                    },
                    child: Text(
                      'Skip for now',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                ],
              ),

              // **Admin Button**
              // Positioned(
              //   bottom: 20,
              //   right: 20,
              //   child: GestureDetector(
              //     onTap: () {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(builder: (context) => AdminModule()),
              //       );
              //     },
              //     child: Container(
              //       padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              //       decoration: BoxDecoration(
              //         color: Color(0xFF373B44),
              //         borderRadius: BorderRadius.circular(10),
              //         boxShadow: [
              //           BoxShadow(
              //             color: Colors.grey.shade500,
              //             blurRadius: 4,
              //             offset: Offset(0, 2),
              //           ),
              //         ],
              //       ),
              //       child: Row(
              //         children: [
              //           Icon(Icons.admin_panel_settings, color: Colors.white, size: 18),
              //           SizedBox(width: 6),
              //           Text(
              //             "Admin",
              //             style: GoogleFonts.roboto(
              //               color: Colors.white,
              //               fontSize: 16,
              //               fontWeight: FontWeight.w500,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),

            ],
          ),
        ),
      ),
      )
    );
  }
}
class AuthCheckScreenHelper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Listen to auth state
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Show loader while checking
        }
        if (snapshot.hasData) {
          return HelperHomeScreen(); // Navigate to home if user is logged in
        } else {
          return HelperLoginScreen(); // Navigate to login
        }
      },
    );
  }
}
