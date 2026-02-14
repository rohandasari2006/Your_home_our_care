import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chatbot_screen.dart';
import 'maid_details.dart';

class EldersCareScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF6C63FF),
        title: Text(
          'Elders Care Service',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Maid Image with shadow and rounded corners
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    spreadRadius: 3,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/elders.jpg',
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              'Trusted & professional Care Givers ',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),

            const SizedBox(height: 12),

            // Description Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Our elders care services are designed to give your elders the best care and attention. We provide qualified care giver who are experienced and have undergone thorough background checks. Whether it\'s full-time care, part-time care, or emergency services, our care givers are ready to support your child\'s growth and development in a safe environment.',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Price Info
            Row(
              children: [
                const Icon(Icons.currency_rupee, color: Colors.green, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Starting from ₹4000 / month',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Book Now Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MaidDetailsScreen(serviceType: 'Elders Care',)),
                  );
                },
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: Text(
                  'Book Now',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white, // Colored Text
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 5,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Enquiry / Chat Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatbotScreen()),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                label: Text(
                  'Enquiry / Chat',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white, // Colored Text
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
