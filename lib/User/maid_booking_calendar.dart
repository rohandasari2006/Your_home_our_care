import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'maid_booking_summary.dart';
import 'package:yhoc/globals.dart' as globals;

class MaidBookingCalendarScreen extends StatefulWidget {
  final Map<String, dynamic> maid;
  final String serviceType;
  final String maidId;

  MaidBookingCalendarScreen({
    required this.maid,
    required this.serviceType,
    required this.maidId,
  });

  @override
  _MaidBookingCalendarScreenState createState() =>
      _MaidBookingCalendarScreenState();
}

class _MaidBookingCalendarScreenState extends State<MaidBookingCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  double totalPrice = 0.0;
  bool isFullDaySelected = false;
  bool isLoading = false;
  List<DateTime> bookedDates = [];
  List<Map<String, dynamic>> bookingsArray = [];
  String? selectedTimeSlot;
  List<String> tasksToBeDone = ['Cleaning', 'Laundry', 'Cooking', 'Grocery Shopping'];
  Map<String, double> taskPrice = {
    'Cleaning': 250,
    'Laundry': 150,
    'Cooking': 130,
    'Grocery Shopping': 100,
  };
  Map<String, bool> taskSelection = {};
  double fullDayPrice = 300.0;

  @override
  void initState() {
    super.initState();
    for (var task in tasksToBeDone) {
      taskSelection[task] = false;
    }
    fetchBookedDates();
  }

  /// Fetches the booked dates from Firestore
  Future<void> fetchBookedDates() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('booking maid')
          .where('maidId', isEqualTo: widget.maidId)
          .get();

      setState(() {
        bookedDates = snapshot.docs.map((doc) {
          final data = doc.data();
          return DateTime.parse(data['selectedDate']);
        }).toList();
      });
    } catch (e) {
      print('Error fetching booked dates: $e');
    }
  }

  /// Checks if a given date is already booked
  bool _isDateBooked(DateTime date) {
    return bookedDates.any((bookedDate) =>
    date.year == bookedDate.year &&
        date.month == bookedDate.month &&
        date.day == bookedDate.day);
  }

  /// Updates the total price based on selected tasks and options
  void _updateTotalPrice() {
    double newTotal = 0.0;

    if (isFullDaySelected) {
      newTotal += fullDayPrice;
    }

    taskSelection.forEach((task, selected) {
      if (selected) {
        newTotal += taskPrice[task]!;
      }
    });

    setState(() {
      totalPrice = newTotal;
    });
  }

  /// Handles the booking of maid services
  Future<void> _bookMaidService() async {
    if (_selectedDay == null || selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date and time slot.')),
      );
      return;
    }

    if (_isDateBooked(_selectedDay!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected date is already booked.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      Map<String, dynamic> bookingData = {
        'maidId': widget.maidId,
        'maidName': widget.maid['name'],
        'maidPhone': widget.maid['mobile'],
        'selectedDate': _selectedDay!.toIso8601String(),
        'selectedTimeSlot': selectedTimeSlot!,
        'serviceType': widget.serviceType,
        'selectedTasks': taskSelection.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList(),
        'status': 'In Progress',
        'totalPrice': totalPrice,
      };

      await firestore.collection('booking maid').doc(globals.no).set(bookingData);

      setState(() {
        bookingsArray.add(bookingData);
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MaidBookingSummaryScreen(
            maidName: widget.maid['name'],
            selectedDate: _selectedDay!,
            selectedTimeSlot: selectedTimeSlot!,
            selectedTasks: bookingData['selectedTasks'],
            totalPrice: totalPrice,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error booking service. Please try again.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Builds a checkbox list tile for each task
  Widget buildTaskCheckbox(String task) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: CheckboxListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text(task, style: GoogleFonts.poppins(fontSize: 16)),
        value: taskSelection[task],
        activeColor: Color(0xFF6C63FF),
        onChanged: (value) {
          setState(() {
            taskSelection[task] = value ?? false;
            _updateTotalPrice();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Book ${widget.maid['name']}',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color(0xFF6C63FF),
        elevation: 4,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCalendar(),
                SizedBox(height: 20),
                _buildTimeSlotSelector(),
                SizedBox(height: 20),
                _buildTasksList(),
                SizedBox(height: 30),
                _buildConfirmButton(),
              ],
            ),
          ),
          if (isLoading) _buildLoadingIndicator(),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TableCalendar(
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
              if (_isDateBooked(day)) {
                return Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotSelector() {
    List<String> timeSlots = [
      '9 AM - 12 PM',
      '12 PM - 3 PM',
      '3 PM - 6 PM',
      '6 PM - 9 PM',
      'Full day',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Time Slot:',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: timeSlots.map((slot) {
            return ChoiceChip(
              label: Text(slot,
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              selected: selectedTimeSlot == slot,
              selectedColor: Color(0xFF6C63FF),
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(
                  color: selectedTimeSlot == slot
                      ? Colors.white
                      : Colors.black),
              onSelected: (selected) {
                setState(() {
                  selectedTimeSlot = selected ? slot : null;
                  isFullDaySelected = selected && slot == 'Full day';

                  if (isFullDaySelected) {
                    taskSelection.updateAll((key, value) => false);
                  }

                  _updateTotalPrice();
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTasksList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tasks to be Done:',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        SizedBox(height: 10),
        ...tasksToBeDone.map(buildTaskCheckbox).toList(),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return Center(
      child: ElevatedButton(
        onPressed: isLoading ? null : _bookMaidService,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 5,
        ),
        child: Text(
          'Confirm Booking',
          style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
