import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chatbot_screen.dart';
import 'maid_details.dart'; // Import the new file for Child Care Details

class ChildCareServiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Child Care Service Details',
          style: GoogleFonts.poppins(
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF6C63FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display a large image for the child care service
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage('assets/child.jpg'), // Change the image path as needed
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),
            // General information about the child care service
            Text(
              'Professional and Caring Child Care',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Our child care services are designed to give your child the best care and attention. We provide qualified care giver who are experienced and have undergone thorough background checks. Whether it\'s full-time care, part-time care, or emergency services, our care givers are ready to support your child\'s growth and development in a safe environment.',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            // General price information
            Text(
              'Price: Starting from ₹6000 per month',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.green, // Green for price
              ),
            ),
            SizedBox(height: 16),
            // Booking button
            ElevatedButton(
              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MaidDetailsScreen(serviceType: 'Child Care',)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Green for the button color
              ),
              child: Text(
                'Book Now',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 8),
            // Message button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatbotScreen()),
                );

                // Handle the message action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6C63FF), // Primary color for message button
              ),
              child: Text(
                'Enquiry',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
