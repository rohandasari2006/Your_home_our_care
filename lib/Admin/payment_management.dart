import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentManagementScreen extends StatefulWidget {
  @override
  _PaymentManagementScreenState createState() => _PaymentManagementScreenState();
}

class _PaymentManagementScreenState extends State<PaymentManagementScreen> {
  final CollectionReference paymentsCollection =
  FirebaseFirestore.instance.collection('upi'); // Adjust collection name as needed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment Management"),
        backgroundColor: Color(0xFF6C63FF),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Manage Payments",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: paymentsCollection.get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No payment data available.'));
                  }

                  final payments = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      final payment = payments[index];
                      final data = payment.data() as Map<String, dynamic>;

                      final bookingId = payment.id; // Document ID
                      final upiId = data.containsKey('upiId') ? data['upiId'] : 'N/A';
                      final paymentStatus = data.containsKey('paymentStatus') ? data['paymentStatus'] : 'N/A';
                      final amount = data.containsKey('totalPrice') ? data['totalPrice'].toString() : '0.00';

                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SelectableText("Booking ID: $bookingId",
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              SelectableText("UPI ID: $upiId"),
                              SelectableText("Payment Status: $paymentStatus"),
                              SelectableText("Amount: ₹$amount"),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
