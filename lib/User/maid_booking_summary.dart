import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'payment.dart';  // Importing the Payment screen

class MaidBookingSummaryScreen extends StatelessWidget {
  final String maidName;
  final DateTime selectedDate;
  final String selectedTimeSlot;
  final List<String> selectedTasks;
  final double totalPrice;

  MaidBookingSummaryScreen({
    required this.maidName,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.selectedTasks,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Light background for premium feel
      appBar: AppBar(
        title: Text(
          'Booking Summary',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Color(0xFF6C63FF),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Booking Summary Card
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade300, blurRadius: 6, spreadRadius: 2)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _summaryRow("Maid Name", maidName),
                  _summaryRow("Date", "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
                  _summaryRow("Time Slot", selectedTimeSlot),
                  Divider(thickness: 1, color: Colors.grey.shade400),
                  _taskSection(),
                  Divider(thickness: 1, color: Colors.grey.shade400),
                  // Displaying the total price
                  _summaryRow("Total Price", "\$${totalPrice.toStringAsFixed(2)}"), // Format price to 2 decimal places
                ],
              ),
            ),

            SizedBox(height: 30),

            // Proceed to Payment Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      maidName: maidName,
                      selectedDate: selectedDate,
                      selectedTimeSlot: selectedTimeSlot,
                      selectedTasks: selectedTasks,
                      totalPrice: totalPrice,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Proceed to Payment',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function for booking summary rows
  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // Task list section
  Widget _taskSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Selected Tasks",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 6),
        ...selectedTasks.map((task) => Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 4),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 18),
              SizedBox(width: 6),
              Text(
                task,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
