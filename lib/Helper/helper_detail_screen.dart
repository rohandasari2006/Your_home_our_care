import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'terms_and_conditions.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Helper Details',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HelperDetailScreen(),
    );
  }
}

class HelperDetailScreen extends StatefulWidget {
  @override
  _HelperDetailScreenState createState() => _HelperDetailScreenState();
}

class _HelperDetailScreenState extends State<HelperDetailScreen> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();

  List<String> workCapabilities = ["Cleaning", "Cooking", "Child Care", "Elderly Care", "Laundry"];
  List<String> selectedWorkCapabilities = [];

  List<String> languages = ["English", "Hindi", "Marathi", "Telugu", "Kannada"];
  List<String> selectedLanguages = [];

  String? selectedGender;
  List<String> genders = ["Male", "Female", "Other"];

  File? _aadharCard, _marksheet, _policeVerification, _livePhoto;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source, String type) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        switch (type) {
          case "Aadhar":
            _aadharCard = File(pickedFile.path);
            break;
          case "Marksheet":
            _marksheet = File(pickedFile.path);
            break;
          case "Police":
            _policeVerification = File(pickedFile.path);
            break;
          case "LivePhoto":
            _livePhoto = File(pickedFile.path);
            break;
        }
      });
    }
  }

  void _saveToFirestore() async {
    if (_formKey.currentState!.validate() &&
        selectedWorkCapabilities.isNotEmpty &&
        selectedLanguages.isNotEmpty &&
        selectedGender != null) {
      setState(() {
        isLoading = true;
      });
      try {
        String documentId = _mobileController.text.trim();

        // Upload images to Cloudinary and get URLs
        final CloudinaryService cloudinaryService = CloudinaryService();
        final String? aadharUrl = _aadharCard != null ? await cloudinaryService.uploadImage(_aadharCard!) : null;
        final String? marksheetUrl = _marksheet != null ? await cloudinaryService.uploadImage(_marksheet!) : null;
        final String? policeVerificationUrl = _policeVerification != null ? await cloudinaryService.uploadImage(_policeVerification!) : null;
        final String? livePhotoUrl = _livePhoto != null ? await cloudinaryService.uploadImage(_livePhoto!) : null;

        Map<String, dynamic> helperDetails = {
          "name": _nameController.text.trim(),
          "address": _addressController.text.trim(),
          "mobile": documentId,
          "email": _emailController.text.trim(),
          "education": _educationController.text.trim(),
          "age": _ageController.text.trim(),
          "experience": _experienceController.text.trim(),
          "gender": selectedGender,
          "workCapabilities": selectedWorkCapabilities.join(', '),
          "languages": selectedLanguages.join(', '),
          "aadharCard": aadharUrl ?? "",
          "marksheet": marksheetUrl ?? "",
          "policeVerification": policeVerificationUrl ?? "",
          "livePhoto": livePhotoUrl ?? "",
          "status": "Pending"
        };

        await FirebaseFirestore.instance.collection('temp_maid').doc(documentId).set(helperDetails);

        print("Data successfully saved!");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TermsAndConditionsScreen()),
        );
      } catch (e) {
        print("Failed to save details: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save details: $e"),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all required fields!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Helper Details", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Color(0xFF6C63FF),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle("Personal Info"),
              _buildLabel("Full Name"),
              _buildInputField("Enter full name", Icons.person, _nameController, false, _validateFullName),

              _buildLabel("Address"),
              _buildInputField("Enter your address", Icons.home, _addressController, false, _validateAddress),

              _buildLabel("Mobile No."),
              _buildInputField("Enter mobile number", Icons.phone, _mobileController, true, _validatePhoneNumber),

              _buildLabel("Email"),
              _buildInputField("Enter your email (optional)", Icons.email, _emailController, false, _validateEmail),

              _buildLabel("Education"),
              _buildInputField("Enter your highest education", Icons.school, _educationController, false, _validateEducation),

              _buildLabel("Age"),
              _buildInputField("Enter your age", Icons.calendar_today, _ageController, true, _validateAge),

              _buildLabel("Past Work Experience"),
              _buildInputField("Enter past experience details", Icons.work, _experienceController, false, _validateExperience),

              _buildLabel("Gender"),
              DropdownButtonFormField<String>(
                value: selectedGender,
                hint: Text(
                  "Select the gender",
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600),
                ),
                items: genders
                    .map((gender) => DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender, style: GoogleFonts.poppins(fontSize: 16)),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
                validator: (value) => value == null ? "Please select a gender" : null,
              ),

              SizedBox(height: 20),
              _buildTitle("Select Work Capabilities"),
              _buildCheckboxList(workCapabilities, selectedWorkCapabilities),

              SizedBox(height: 20),
              _buildTitle("Languages Known"),
              _buildCheckboxList(languages, selectedLanguages),

              SizedBox(height: 20),
              _buildTitle("Upload Documents"),
              _buildImageUploadSection("Upload Aadhar Card", _aadharCard, "Aadhar"),
              _buildImageUploadSection("Upload Marksheet (if available)", _marksheet, "Marksheet"),
              _buildImageUploadSection("Upload Police Verification Certificate", _policeVerification, "Police"),
              _buildImageUploadSection("Capture Live Photo", _livePhoto, "LivePhoto"),

              SizedBox(height: 30),
              isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6C63FF),
                ),
              )
                  : ElevatedButton(
                onPressed: _saveToFirestore,
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

  Widget _buildTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF6C63FF))),
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

  Widget _buildCheckboxList(List<String> items, List<String> selectedItems) {
    return Column(
      children: items.map((item) {
        return CheckboxListTile(
          title: Text(item, style: GoogleFonts.poppins(fontSize: 16)),
          value: selectedItems.contains(item),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                selectedItems.add(item);
              } else {
                selectedItems.remove(item);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildImageUploadSection(String label, File? imageFile, String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera, type),
              icon: Icon(Icons.camera_alt),
              label: Text("Capture", style: GoogleFonts.poppins(fontSize: 14)),
            ),
            SizedBox(width: 10),
            imageFile != null
                ? Image.file(imageFile, height: 60, width: 60, fit: BoxFit.cover)
                : Text("No image selected", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  String? _validateFullName(String? value) => value!.isEmpty ? "Enter full name" : null;
  String? _validateAddress(String? value) => value!.isEmpty ? "Enter address" : null;
  String? _validatePhoneNumber(String? value) => value!.length != 10 ? "Enter valid 10-digit phone number" : null;
  String? _validateEmail(String? value) =>
      (value != null && value.isNotEmpty && !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value))
          ? "Enter a valid email"
          : null;
  String? _validateEducation(String? value) => value!.isEmpty ? "Enter education details" : null;
  String? _validateAge(String? value) => int.tryParse(value!) == null || int.parse(value) < 18 ? "Enter valid age (18+)" : null;
  String? _validateExperience(String? value) => value!.isEmpty ? "Enter past experience details" : null;
}

class CloudinaryService {
  final String cloudName = "dvy9kerpq";
  final String apiKey = "444885385856863";
  final String apiSecret = "N2jXmuuw25v51X9fyJHMRASS03U";

  Future<String?> uploadImage(File imageFile) async {
    try {
      final String uploadUrl = "https://api.cloudinary.com/v1_1/$cloudName/image/upload";
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
        ..fields['upload_preset'] = 'Images'
        ..fields['api_key'] = apiKey
        ..fields['folder'] = 'Images'
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['secure_url'];
      } else {
        print('Cloudinary upload error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }
}
