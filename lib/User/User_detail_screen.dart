import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home.dart';

class UserDetailsScreen extends StatefulWidget {
  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  String? _selectedGender;
  bool isLoading = false; // To control loader visibility

  Future<void> _saveUserDetails() async {
    if (!_formKey.currentState!.validate() || _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields correctly & select gender!"), backgroundColor: Colors.red),
      );
      return;
    }

    String contactNumber = _numberController.text.trim();
    Map<String, dynamic> userDetails = {
      "full_name": _nameController.text.trim(),
      "address": _addressController.text.trim(),
      "city": _cityController.text.trim(),
      "pincode": _pincodeController.text.trim(),
      "email": _emailController.text.trim().isEmpty ? "" : _emailController.text.trim(),
      "contact_number": contactNumber,
      "gender": _selectedGender,
      "timestamp": FieldValue.serverTimestamp(), // Stores the time of entry
    };

    setState(() {
      isLoading = true; // Show loader when saving user details
    });

    try {
      await FirebaseFirestore.instance.collection("user detail").doc(contactNumber).set(userDetails);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User details saved successfully!"), backgroundColor: Colors.green),
      );

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } catch (e) {
      setState(() {
        isLoading = false; // Stop loader if there's an error
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save data: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Details", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Color(0xFF6C63FF),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Personal Info",
                  style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF6C63FF))),
              SizedBox(height: 20),

              _buildLabel("Full Name"),
              _buildInputField("Enter your full name (First Middle Last)", Icons.person, _nameController, false, _validateFullName),

              _buildLabel("Address"),
              _buildInputField("Enter your address", Icons.home, _addressController, false, _validateAddress),

              _buildLabel("City"),
              _buildInputField("Enter your city", Icons.location_city, _cityController, false, _validateCity),

              _buildLabel("Pincode"),
              _buildInputField("Enter your pincode", Icons.pin_drop, _pincodeController, true, _validatePincode),

              _buildLabel("Email"),
              _buildInputField("Enter your email (optional)", Icons.email, _emailController, false, _validateEmail),

              _buildLabel("Contact Number"),
              _buildInputField("Enter alternate number", Icons.phone, _numberController, true, _validatePhoneNumber),

              SizedBox(height: 20),

              Text("Gender", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
              Row(children: [_buildRadioButton("Male"), _buildRadioButton("Female"), _buildRadioButton("Other")]),

              SizedBox(height: 30),

              isLoading
                  ? Center(child: CircularProgressIndicator()) // Show loader while saving user details
                  : ElevatedButton(
                onPressed: _saveUserDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: Size(double.infinity, 55),
                  elevation: 4,
                ),
                child: Text('Save & Proceed', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 4.0),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
    );
  }

  Widget _buildInputField(String hint, IconData icon, TextEditingController controller, bool isNumeric, String? Function(String?) validator) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500),
        prefixIcon: Icon(icon, color: Colors.blueGrey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFF6C63FF), width: 2)),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }

  Widget _buildRadioButton(String label) {
    return Row(
      children: [
        Radio<String>(
          value: label,
          groupValue: _selectedGender,
          onChanged: (value) => setState(() => _selectedGender = value),
          activeColor: Color(0xFF6C63FF),
        ),
        Text(label, style: GoogleFonts.poppins(fontSize: 16)),
      ],
    );
  }

  // Validation Functions
  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) return "Full name is required";
    List<String> names = value.trim().split(" ");
    if (names.length < 3) return "Enter full name (First Middle Last)";
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().length < 10) return "Enter a valid address (min 10 chars)";
    return null;
  }

  String? _validateCity(String? value) {
    if (value == null || value.trim().length < 3) return "Enter a valid city name (min 3 chars)";
    return null;
  }

  String? _validatePincode(String? value) {
    if (value == null || value.length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) {
      return "Enter a valid 6-digit pincode";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Allow empty input
    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value.trim())) {
      return "Enter a valid email";

    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.length != 10 || !RegExp(r'^\d{10}$').hasMatch(value)) {
      return "Enter a valid 10-digit phone number";
    }
    return null;
  }
}
