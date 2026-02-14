import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthScreen extends StatefulWidget {
  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String phoneNumber = "";
  String verificationId = "";
  String otp = "";
  bool codeSent = false;

  void verifyPhoneNumber() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        print("Phone number automatically verified and signed in!");
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Verification failed: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          this.verificationId = verificationId;
          codeSent = true;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        this.verificationId = verificationId;
      },
    );
  }

  void signInWithOTP() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: otp);
    await _auth.signInWithCredential(credential);
    print("User signed in successfully!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Phone Auth")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!codeSent)
              TextField(
                decoration: InputDecoration(hintText: "Enter phone number"),
                onChanged: (value) {
                  phoneNumber = value;
                },
              )
            else
              TextField(
                decoration: InputDecoration(hintText: "Enter OTP"),
                onChanged: (value) {
                  otp = value;
                },
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: codeSent ? signInWithOTP : verifyPhoneNumber,
              child: Text(codeSent ? "Verify OTP" : "Send OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
