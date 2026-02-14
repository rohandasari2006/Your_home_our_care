import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class GiveFeedbackScreen extends StatefulWidget {
  @override
  _GiveFeedbackScreenState createState() => _GiveFeedbackScreenState();
}

class _GiveFeedbackScreenState extends State<GiveFeedbackScreen> {
  String _selectedFeedbackType = "Service Quality";
  final TextEditingController _feedbackController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "Give Feedback",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Feedback Type", style: _sectionTitleStyle()),
            _buildDropdown(),

            SizedBox(height: 10),
            Text("Write Your Feedback", style: _sectionTitleStyle()),
            _buildFeedbackField(),

            SizedBox(height: 20),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  TextStyle _sectionTitleStyle() {
    return GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold);
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedFeedbackType,
      items: ["Service Quality", "App Experience", "Payment Issues", "Other"]
          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedFeedbackType = value!;
        });
      },
      decoration: InputDecoration(border: OutlineInputBorder()),
    );
  }

  Widget _buildFeedbackField() {
    return TextField(
      controller: _feedbackController,
      maxLines: 4,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: "Write your feedback here...",
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _submitFeedback,
        child: Text("Submit Feedback", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }

  void _submitFeedback() async {
    String feedbackText = _feedbackController.text.trim();

    if (feedbackText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter feedback before submitting")),
      );
      return;
    }

    try {
      await _firestore
          .collection('feedback')
          .doc(_selectedFeedbackType) // Use feedback type as document ID
          .collection('responses') // Store responses under this document
          .add({
        'feedback': feedbackText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Feedback submitted successfully")),
      );

      _feedbackController.clear(); // Clear input field after submission
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting feedback: $e")),
      );
    }
  }
}
