import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ApprovalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Soft background color
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Illustration Image
              // Container(
              //   height: 250,
              //   width: double.infinity,
              //   decoration: BoxDecoration(
              //     image: DecorationImage(
              //       image: AssetImage("assets/approval_pending.png"), // Replace with your actual asset path
              //       fit: BoxFit.cover,
              //     ),
              //   ),
              // ),

              // SizedBox(height: 40),

              // Title Text
              Text(
                "Approval Pending",
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 12),

              // Subtitle Text
              Text(
                "Your profile is currently under review by the organization. We appreciate your patience while we process your approval.",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 30),

              // Card with More Information
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.hourglass_empty_rounded,
                      size: 48,
                      color: Color(0xFF6C63FF),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Expected Approval Time",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Approvals typically take 24–48 hours. We'll notify you as soon as it's done!",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Encouragement Text
              Text(
                "Meanwhile, feel free to explore the app or reach out to support for any urgent queries.",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 20),

              // Contact Support Button
              ElevatedButton(
                onPressed: () {
                  // Add your support contact action here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6C63FF),
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Contact Support",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
