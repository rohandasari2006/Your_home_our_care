import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yhoc/User/home.dart';
import 'package:yhoc/globals.dart' as globals;

class PaymentScreen extends StatefulWidget {
  final String maidName;
  final DateTime selectedDate;
  final String selectedTimeSlot;
  final List<String> selectedTasks;
  final double totalPrice;

  PaymentScreen({
    required this.maidName,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.selectedTasks,
    required this.totalPrice,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  TextEditingController _upiController = TextEditingController();
  bool _agreementAccepted = false;

  // Regular expression to validate UPI ID
  final RegExp _upiIdRegex = RegExp(r'^[\w.-]+@[\w]+$');

  @override
  void initState() {
    super.initState();
    _fetchUpiIdFromFirestore();
  }

  // Fetch existing UPI ID from Firestore for a specific document ID
  Future<void> _fetchUpiIdFromFirestore() async {
    try {
      CollectionReference bookings = FirebaseFirestore.instance.collection('upi');

      // Fetch document by specific document ID
      DocumentSnapshot docSnapshot = await bookings.doc(globals.no).get();

      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;
        String? upiId = data?['upiId'];

        if (upiId != null && upiId.isNotEmpty) {
          setState(() {
            _upiController.text = upiId; // Populate TextField with UPI ID
          });
        }
      } else {
        print("No document found for ID: ${globals.no}");
      }
    } catch (e) {
      print("Error fetching UPI ID: $e");
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  // Validate and proceed
  void _validateAndProceed() async {
    if (_upiController.text.isEmpty) {
      _showErrorDialog("Please enter your UPI ID.");
      return;
    }

    if (!_upiIdRegex.hasMatch(_upiController.text)) {
      _showErrorDialog("Please enter a valid UPI ID.");
      return;
    }

    await _saveUpiIdToFirestore();
    _showConfirmationDialog();
  }

  // Save UPI ID to Firestore
  Future<void> _saveUpiIdToFirestore() async {
    try {
      CollectionReference bookings = FirebaseFirestore.instance.collection('upi');

      await bookings.doc(globals.no).set({
        'upiId': _upiController.text,
        'paymentStatus': 'Pending',
        'totalPrice': widget.totalPrice,
      });

      print("UPI ID stored successfully!");
    } catch (e) {
      print("Error storing UPI ID: $e");
      _showErrorDialog("Failed to save UPI ID.");
    }
  }

  // Show confirmation dialog
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Payment Confirmed"),
        content: Text("Your booking has been successfully processed!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Payment Invoice',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Color(0xFF6C63FF),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "YOUR HOME OUR CARE",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 5,
                          spreadRadius: 2)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _invoiceRow("Maid Name", widget.maidName),
                      _invoiceRow(
                          "Date",
                          "${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}"),
                      _invoiceRow("Time Slot", widget.selectedTimeSlot),
                      Divider(thickness: 1, color: Colors.grey.shade400),
                      _invoiceRow("Amount to Pay",
                          "₹${widget.totalPrice.toStringAsFixed(2)}",
                          isBold: true),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 5,
                          spreadRadius: 2)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Enter Your UPI ID",
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 5),
                      TextField(
                        controller: _upiController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "example@upi",
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _validateAndProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Proceed to Pay',
                    style: GoogleFonts.poppins(
                        fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _invoiceRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.black : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
