import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yhoc/User/Elders_care_screen.dart';
import 'package:yhoc/User/house_shifting_screen.dart';
import 'package:yhoc/User/water_supplier_screen.dart';
import 'bottom_nav_bar.dart';
import 'cooking_screen.dart';
import 'maid.dart';
import 'child_care_screen.dart';
import 'package:yhoc/globals.dart' as globals;
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? fullname;
  void initState() {
    super.initState();
    _loadUserNumber(); // Load stored number first
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _loadUserNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedNumber = prefs.getString('user_number'); // Retrieve the stored number
    if (storedNumber != null) {
      setState(() {
        globals.no = storedNumber; // Store it in globals.no
      });
    }
  }
  Future<Map<String, dynamic>> _fetchUserData() async {
    try {
      DocumentSnapshot userSnapshot =
      await _firestore.collection('user detail').doc(globals.no).get();

      if (userSnapshot.exists && userSnapshot.data() != null) {
        return userSnapshot.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }

    // Return default values if no user data found
    return {
      'full_name': 'User',
      'profileImage': 'assets/profile_pic.png', // Default image in assets
    };
  }

  final List<Map<String, dynamic>> services = [
    {
      "image": "assets/maid.jpg",
      "title": "Maid Service",
      "rating": 4.8,
      "description": "Expert cleaning services for your home.",
      "screen": MaidServiceScreen(),
    },
    {
      "image": "assets/child.jpg",
      "title": "Child Care",
      "rating": 4.5,
      "description": "Experienced nannies to care for your child.",
      "screen": ChildCareServiceScreen(),
    },
    {
      "image": "assets/elders.jpg",
      "title": "Elderly Care",
      "rating": 4.9,
      "description": "Compassionate care for elderly family members.",
      "screen": EldersCareScreen(),
    },
    {
      "image": "assets/watersupplier.jpg",
      "title": "Water Supply",
      "rating": 4.3,
      "description": "Reliable water supply services.",
      "screen": WaterSupplierScreen(),
    },
    {
      "image": "assets/cooking.jpg",
      "title": "Cooking",
      "rating": 4.3,
      "description": "Delicious homemade meals.",
      "screen": CookingScreen(),
    },
    {
      "image": "assets/house.jpg",
      "title": "House Shifting",
      "rating": 4.3,
      "description": "Smooth and safe house shifting.",
      "screen": HouseShiftingScreen(),
    },
    {
      "image": "assets/cleaning.jpg",
      "title": "Only for Cleaning",
      "rating": 4.3,
      "description": "Professional house cleaning service.",
      "screen": MaidServiceScreen(),
    },
    {
      "image": "assets/all.jpg",
      "title": "All Rounder",
      "rating": 4.3,
      "description": "Multi-skilled home care expert.",
      "screen": MaidServiceScreen(),
    },
  ];

  final List<Map<String, String>> featuredServices = [
    {"image": "assets/offerpic1.jpg", "title": "Special Offer"},
    {"image": "assets/1.jpg", "title": "Special Offer"},

    {"image": "assets/offerpic2.jpg", "title": "Special Offer"},
  ];

  final List<Map<String, String>> aboutAppSlides = [
    {
      "title": "About our app",
      "subtitle": "Book services easily and manage your bookings seamlessly.",
    },
    {
      "title": "Your Home, Our Care",
      "subtitle": "Bringing Professional Care Services Right To Your Doorstep.",
    },
    {
      "title": "Trusted & Verified",
      "subtitle": "All our staff are background checked and experienced.",
    },
    {
      "title": "Easy Booking",
      "subtitle": "Book services easily and manage your bookings seamlessly.",
    },
  ];

  final List<Map<String, String>> popularServices = [
    {"image": "assets/pop1.jpg", "name": "Most Booked Maid", "price": "₹1500"},
    {"image": "assets/maid.jpg", "name": "Top Babysitter", "price": "₹1800"},
    {"image": "assets/pop2.jpg", "name": "Best Elder Care", "price": "₹2000"},
  ];

  final List<Map<String, dynamic>> keyFeatures = [
    {"icon": Icons.verified, "text": "Trusted & Verified Workers"},
    {"icon": Icons.support_agent, "text": "24/7 Customer Support"},
    {"icon": Icons.payment, "text": "Secure Payment Options"},
    {"icon": Icons.schedule, "text": "Flexible Booking Schedule"},
    {"icon": Icons.star_rate, "text": "Highly Rated Professionals"},
    {"icon": Icons.local_offer, "text": "Exciting Discounts & Offers"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 8,
        backgroundColor: Colors.white,
        centerTitle: true,
        shadowColor: Colors.black45,
        automaticallyImplyLeading: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(35),
          ),
        ),
        title: Text(
          'Your Home Our Care',
          style: GoogleFonts.poppins(
            color: Color(0xFF6C63FF),
            fontWeight: FontWeight.w700,
            fontSize: 24,
            //letterSpacing: 1.5,
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.notifications, color: Color(0xFF6C63FF), size: 28),
        //     onPressed: () {},
        //   ),
        // ],
      ),

      body:  SafeArea(child:
      FutureBuilder<Map<String, dynamic>>(
          future: _fetchUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator()); // Show loading indicator while fetching data
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}')); // Handle any errors
            }

            if (!snapshot.hasData) {
              return Center(child: Text('No user data found'),); // Handle case if no data is found
            }

            var userData = snapshot.data!;
            String fullName = userData['full_name'] ?? 'User';
            String firstName = fullName.split(' ').first; // Extract the first name
            String profilePicUrl = userData['profileImage'] ?? 'null';
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              _buildHeader(context, profilePicUrl,firstName),
              SizedBox(height: 24),
              _buildAboutAppCarousel(),
              SizedBox(height: 24),
              _buildFeaturedServices(),
              SizedBox(height: 24),
              _buildPopularServicesScroll(),
              SizedBox(height: 24),
              _buildServiceGrid(context),
              SizedBox(height: 24),
              _buildKeyFeaturesCard(),
            ],
          ),
        ),
      );
          },
      ),
      ),
      bottomNavigationBar: BottomNavBar(),
      // Add the custom bottom navigation bar
    );

  }

  Widget _buildHeader(BuildContext context, String profilePicUrl,String firstName) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage:
         profilePicUrl.isNotEmpty
              ? NetworkImage(profilePicUrl)
              : AssetImage('assets/profile_pic.png') as ImageProvider, // Fallback to default image
        ),
        SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
            "Hello, $firstName",
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Color(0xFF6C63FF),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Welcome Here!',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutAppCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 160,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.95,
      ),
      items: aboutAppSlides.map((slide) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFFB39DDB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                spreadRadius: 2,
                offset: Offset(2, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                slide["title"]!,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                slide["subtitle"]!,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeaturedServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Special Offers',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        SizedBox(height: 16),
        CarouselSlider(
          options: CarouselOptions(
            height: 220,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.9,
          ),
          items: featuredServices.map((service) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Image.asset(
                    service["image"]!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  // Positioned(
                  //   bottom: 15,
                  //   left: 20,
                  //   // child: Text(
                  //   //   // service["title"]!,
                  //   //   style: GoogleFonts.poppins(
                  //   //     fontSize: 18,
                  //   //     color: Colors.white,
                  //   //     fontWeight: FontWeight.bold,
                  //   //     backgroundColor: Colors.black45,
                  //   //   ),
                  //   // ),
                  // ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPopularServicesScroll() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Rated Workers',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        SizedBox(height: 16),
        Container(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: popularServices.length,
            itemBuilder: (context, index) {
              var service = popularServices[index];
              return Container(
                width: 180,
                margin: EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      spreadRadius: 2,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.asset(
                        service["image"]!,
                        height: 90,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service["name"]!,
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          Text(service["price"]!,
                              style: GoogleFonts.poppins(
                                  fontSize: 14,  fontWeight: FontWeight.bold, color: Colors.green[900])),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Our Services',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: services.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            var service = services[index];
            return InkWell(
              onTap: () {
                if (service["screen"] != null) {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => service["screen"]));
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      spreadRadius: 2,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.asset(
                        service["image"],
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service["title"],
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text(service["description"],
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildKeyFeaturesCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Features',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                spreadRadius: 2,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            children: keyFeatures.map((feature) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(feature['icon'], color: Color(0xFF6C63FF), size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature['text'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
