import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yhoc/User/chatbot_screen.dart';
import 'maid_details.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yhoc/globals.dart' as globals;
class HouseShiftingScreen extends StatefulWidget {
  @override
  State<HouseShiftingScreen> createState() => _HouseShiftingScreenState();
}

class _HouseShiftingScreenState extends State<HouseShiftingScreen> {
  String? selectedWorkers;
  String? selectedVehicle;

  final Map<String, int> workersPricing = {
    '2 Workers': 2000,
    '4 Workers': 4000,
    '6 Workers': 6000,
    '8 Workers': 8000,
  };

  final Map<String, int> vehiclePricing = {
    'Mini Truck': 3000,
    'Medium Truck': 5000,
    'Large Truck': 7000,
    'Container': 10000,
  };

  int totalPrice = 0;

  void calculatePrice() {
    int workersPrice = selectedWorkers != null ? workersPricing[selectedWorkers]! : 0;
    int vehiclePrice = selectedVehicle != null ? vehiclePricing[selectedVehicle]! : 0;
    setState(() {
      totalPrice = workersPrice + vehiclePrice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(1)
            )
        ),
        backgroundColor: const Color(0xFF6C63FF),
        title: Text(
          'House Shifting Service',
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
            _imageSection(),
            const SizedBox(height: 20),
            _descriptionSection(),
            const SizedBox(height: 20),
            _checklistSection(),
            const SizedBox(height: 20),

            // Worker Selection
            Text(
              'Select Number of Workers:',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            ...workersPricing.keys.map((worker) => CheckboxListTile(
              value: selectedWorkers == worker,
              title: Text(worker, style: GoogleFonts.poppins(fontSize: 15)),
              activeColor: Colors.green,
              onChanged: (val) {
                setState(() {
                  selectedWorkers = worker;
                });
                calculatePrice();
              },
            )),
            const SizedBox(height: 20),

            // Vehicle Size Selection
            Text(
              'Select Vehicle Size:',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            ...vehiclePricing.keys.map((vehicle) => CheckboxListTile(
              value: selectedVehicle == vehicle,
              title: Text(vehicle, style: GoogleFonts.poppins(fontSize: 15)),
              activeColor: Colors.green,
              onChanged: (val) {
                setState(() {
                  selectedVehicle = vehicle;
                });
                calculatePrice();
              },
            )),
            const SizedBox(height: 20),

            _priceSection(),
            const SizedBox(height: 30),
            _bookNowButton(context),
            const SizedBox(height: 16),
            _enquiryButton(context),
          ],
        ),
      ),
    );
  }

  Widget _imageSection() {
    return Container(
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
          'assets/house.jpg',
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _descriptionSection() {
    return Text(
      'Our House Shifting service ensures a smooth and hassle-free relocation experience. '
          'We provide experienced packers and movers who handle your belongings with care. '
          'Choose the number of workers and vehicle size as per your need.',
      style: GoogleFonts.poppins(
        fontSize: 15,
        color: Colors.black87,
        height: 1.6,
      ),
    );
  }

  Widget _checklistSection() {
    List<String> features = [
      'Packing Materials (Boxes, Bubble Wrap)',
      'Loading & Unloading',
      'Transportation with Vehicle',
      'Furniture Dismantling & Assembling',
      'Unpacking & Setup',
      'Trained Packers & Movers',
      'Insurance Coverage (Optional)'
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features.map((item) => _buildChecklist(item)).toList(),
    );
  }

  Widget _buildChecklist(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: const Color(0xFF555555),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceSection() {
    return Row(
      children: [
        const Icon(Icons.currency_rupee, color: Colors.green, size: 28),
        const SizedBox(width: 8),
        Text(
          'Total Price: ₹$totalPrice',
          style: GoogleFonts.poppins(
            fontSize: 17,
            color: Colors.green,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _bookNowButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          if (selectedWorkers != null && selectedVehicle != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CalendarScreen(
                  serviceType: 'House Shifting',
                  selectedWorkers: selectedWorkers!,
                  selectedVehicle: selectedVehicle!,
                  totalPrice: totalPrice,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select workers and vehicle size')),
            );
          }
        },
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        label: Text(
          'Book Now',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 5,
        ),
      ),
    );
  }

  Widget _enquiryButton(BuildContext context) {
    return SizedBox(
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
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 5,
        ),
      ),
    );
  }
}



class CalendarScreen extends StatefulWidget {
  final String serviceType;
  final String selectedWorkers;
  final String selectedVehicle;
  final int totalPrice;

  const CalendarScreen({
    Key? key,
    required this.serviceType,
    required this.selectedWorkers,
    required this.selectedVehicle,
    required this.totalPrice,
  }) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<DateTime> bookedDates = [
    DateTime.now().add(Duration(days: 2)),
    DateTime.now().add(Duration(days: 5)),
  ]; // Example booked dates

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void booking() async {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date first')),
      );
      return;
    }

    try {
      await _firestore.collection('booking maid').doc(globals.no).set({
        'serviceType': widget.serviceType,
        'workers': widget.selectedWorkers,
        'vehicle': widget.selectedVehicle,
        'totalPrice': widget.totalPrice,
        'selectedDate': _selectedDay!.toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking confirmed successfully!')),
      );

      Navigator.pop(context); // Navigate back or to a success screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error confirming booking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Date - ${widget.serviceType}',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime(2025, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  if (bookedDates.contains(day)) {
                    return _buildDateCell(day, Colors.red[200]!, Colors.red);
                  }
                  return _buildDateCell(day, Colors.grey[200]!, Colors.black87);
                },
                selectedBuilder: (context, day, focusedDay) {
                  return _buildDateCell(day, Colors.green[200]!, Colors.green);
                },
                todayBuilder: (context, day, focusedDay) {
                  return _buildDateCell(day, Colors.blue[100]!, Colors.blue);
                },
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                headerPadding: EdgeInsets.all(8),
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (_selectedDay != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Selected Date: ${_selectedDay!.toLocal()}'.split(' ')[0],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            Spacer(),
            ElevatedButton(
              onPressed: booking,
              child: const Text(
                'Confirm Booking',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateCell(DateTime day, Color backgroundColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(6),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}


