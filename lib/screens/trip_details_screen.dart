// screens/trip_details_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/auth_service.dart';
import '../models/trip.dart';
import '../models/user.dart';
import 'package:provider/provider.dart';

class TripDetailsScreen extends StatefulWidget {
  final Trip trip;

  TripDetailsScreen({required this.trip});

  @override
  _TripDetailsScreenState createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  late Tourist _tourist;
  List<TripStop> _tripStops = [];
  Roadmap? _roadmap;
  bool _isBooking = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTripDetails();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the user from Provider in didChangeDependencies
    final auth = Provider.of<AuthService>(context, listen: false);
    if (auth.currentUser != null && auth.currentUser is Tourist) {
      _tourist = auth.currentUser as Tourist;
      setState(() {
        _isLoading = false;
      });
    } else {
      // Handle case where user is not a tourist or not logged in
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  void _loadTripDetails() {
    // Mock data - replace with API call
    setState(() {
      _tripStops = [
        TripStop(
          stopId: '1',
          stopName: 'Meeting Point',
          description: 'Meet your guide at the main entrance',
          order: 1,
          location: 'Tunis City Center',
          latitude: 36.8008,
          longitude: 10.1800,
        ),
        TripStop(
          stopId: '2',
          stopName: 'Historical Sites',
          description: 'Visit ancient monuments and museums',
          order: 2,
          location: 'Carthage',
          latitude: 36.8528,
          longitude: 10.3233,
        ),
        TripStop(
          stopId: '3',
          stopName: 'Traditional Lunch',
          description: 'Enjoy authentic Tunisian cuisine',
          order: 3,
          location: 'Local Restaurant',
          latitude: 36.7970,
          longitude: 10.1717,
        ),
        TripStop(
          stopId: '4',
          stopName: 'Market Visit',
          description: 'Explore traditional markets',
          order: 4,
          location: 'Medina Souks',
          latitude: 36.7985,
          longitude: 10.1655,
        ),
      ];

      _roadmap = Roadmap(
        roadmapId: widget.trip.tripId,
        mapData: '{}',
        coordinates: [
          {'lat': 36.8008, 'lng': 10.1800},
          {'lat': 36.8528, 'lng': 10.3233},
          {'lat': 36.7970, 'lng': 10.1717},
          {'lat': 36.7985, 'lng': 10.1655},
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareTrip,
          ),
        ],
      ),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            // Trip Header
            _buildTripHeader(),

            TabBar(
              tabs: [
                Tab(icon: Icon(Icons.info), text: 'Overview'),
                Tab(icon: Icon(Icons.route), text: 'Itinerary'),
                Tab(icon: Icon(Icons.map), text: 'Map'),
                Tab(icon: Icon(Icons.reviews), text: 'Reviews'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildOverviewTab(),
                  _buildItineraryTab(),
                  _buildMapTab(),
                  _buildReviewsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBookingBar(),
    );
  }

  Widget _buildTripHeader() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(widget.trip.imageUrl ?? 'assets/images/default_trip.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.trip.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Tunisia',
                    style: TextStyle(color: Colors.white),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          '4.8',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            widget.trip.description,
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          SizedBox(height: 24),

          _buildInfoSection(
            'Highlights',
            [
              'Guided tour with local expert',
              'Small group (max 15 people)',
              'Traditional lunch included',
              'Hotel pickup available',
              'Entrance fees included',
            ],
          ),

          SizedBox(height: 24),

          _buildInfoSection(
            "What's Included",
            [
              'Professional guide',
              'All entrance fees',
              'Traditional lunch',
              'Transportation during tour',
              'Hotel pickup & drop-off',
            ],
          ),

          SizedBox(height: 24),

          _buildInfoSection(
            "What to Bring",
            [
              'Comfortable walking shoes',
              'Sun protection',
              'Camera',
              'Water bottle',
              'Local currency for souvenirs',
            ],
          ),

          SizedBox(height: 24),

          _buildInfoSection(
            'Cancellation Policy',
            [
              'Free cancellation up to 24 hours before',
              'Full refund if cancelled within 24 hours',
              'Weather-dependent refunds',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _tripStops.length,
      itemBuilder: (context, index) {
        final stop = _tripStops[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      '${stop.order}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stop.stopName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        stop.description,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              stop.location,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapTab() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(36.8065, 10.1815),
        zoom: 11,
      ),
      markers: _tripStops.map((stop) {
        if (stop.latitude != null && stop.longitude != null) {
          return Marker(
            markerId: MarkerId(stop.stopId),
            position: LatLng(stop.latitude!, stop.longitude!),
            infoWindow: InfoWindow(
              title: stop.stopName,
              snippet: stop.description,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          );
        }
        return Marker(markerId: MarkerId(''));
      }).where((marker) => marker.markerId != MarkerId('')).toSet(),
      polylines: {
        Polyline(
          polylineId: PolylineId('route'),
          points: _tripStops
              .where((stop) => stop.latitude != null && stop.longitude != null)
              .map((stop) => LatLng(stop.latitude!, stop.longitude!))
              .toList(),
          color: Colors.blue,
          width: 3,
        ),
      },
    );
  }

  Widget _buildReviewsTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildReviewCard(
          name: 'Sarah Johnson',
          rating: 5,
          date: '2024-01-15',
          comment: 'Amazing experience! The guide was very knowledgeable.',
        ),
        _buildReviewCard(
          name: 'Michael Chen',
          rating: 4,
          date: '2024-01-10',
          comment: 'Great tour, well organized. Lunch was delicious!',
        ),
        _buildReviewCard(
          name: 'Emma Wilson',
          rating: 5,
          date: '2024-01-05',
          comment: 'Best cultural tour in Tunisia! Highly recommended.',
        ),
      ],
    );
  }

  Widget _buildBookingBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Price per person',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  '\$${widget.trip.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  '${widget.trip.endDate.difference(widget.trip.startDate).inDays + 1} days',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          _isBooking
              ? CircularProgressIndicator()
              : ElevatedButton(
            onPressed: _bookTrip,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              child: Text(
                'Book Now',
                style: TextStyle(fontSize: 16),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text(item)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildReviewCard({
    required String name,
    required int rating,
    required String date,
    required String comment,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(name[0]),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(comment),
          ],
        ),
      ),
    );
  }

  void _bookTrip() async {
    setState(() {
      _isBooking = true;
    });

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isBooking = false;
    });

    _tourist.bookTrip(widget.trip);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking Confirmed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text('You have successfully booked "${widget.trip.title}"'),
            SizedBox(height: 8),
            Text(
              'Check your email for confirmation details',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('View My Trips'),
          ),
        ],
      ),
    );
  }

  void _shareTrip() {
    // Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share functionality coming soon!'),
      ),
    );
  }
}