// screens/home_screen.dart - UPDATED
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/trip.dart';
import '../models/user.dart';
import 'trip_details_screen.dart';
import 'profile_screen.dart';
import 'my_trips_screen.dart';
import 'bookings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, child) {
        // Check if user is logged in and is a tourist
        if (auth.currentUser == null || !auth.isTourist) {
          return _buildUnauthorizedScreen(auth);
        }

        final tourist = auth.currentUser as Tourist;
        final database = Provider.of<DatabaseService>(context);

        return Scaffold(
          appBar: AppBar(
            title: Text('Explore Tunisia'),
            actions: [
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  _showSearchDialog(context, database);
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  _handleMenuSelection(value, context, auth);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Profile'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'my_trips',
                    child: Row(
                      children: [
                        Icon(Icons.history, color: Colors.green),
                        SizedBox(width: 8),
                        Text('My Trips'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'bookings',
                    child: Row(
                      children: [
                        Icon(Icons.bookmark, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('My Bookings'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundImage: tourist.profileImage != null
                        ? AssetImage(tourist.profileImage!)
                        : AssetImage('assets/images/default_avatar.jpg'),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Welcome Section
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: tourist.profileImage != null
                          ? AssetImage(tourist.profileImage!)
                          : AssetImage('assets/images/default_avatar.jpg'),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            tourist.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: Colors.grey),
                              SizedBox(width: 4),
                              Text('Tunisia', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text('Tourist'),
                      backgroundColor: Colors.blue[100],
                    ),
                  ],
                ),
              ),

              // Categories Filter
              Container(
                height: 60,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryChip('All'),
                    _buildCategoryChip('Cultural'),
                    _buildCategoryChip('Adventure'),
                    _buildCategoryChip('Beach'),
                    _buildCategoryChip('Historical'),
                    _buildCategoryChip('Gastronomy'),
                    _buildCategoryChip('Nature'),
                  ],
                ),
              ),

              // Trip List Stream
              Expanded(
                child: _buildTripList(database),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUnauthorizedScreen(AuthService auth) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Access Restricted',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'This page is for tourists only',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                auth.logout();
                // Navigation is handled by AuthWrapper
              },
              child: Text('Switch Account'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: ChoiceChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
        backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
        selectedColor: Colors.blue,
      ),
    );
  }

  Widget _buildTripList(DatabaseService database) {
    return StreamBuilder<List<Trip>>(
      stream: _selectedCategory == 'All'
          ? database.getTrips()
          : database.getTripsByCategory(_selectedCategory),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Error loading trips',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.trip_origin, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No trips available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  _selectedCategory == 'All'
                      ? 'Check back later for new adventures'
                      : 'No ${
                      _selectedCategory.toLowerCase()} trips available',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final trips = snapshot.data!;

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: trips.length,
          itemBuilder: (context, index) {
            return _buildTripCard(trips[index], context);
          },
        );
      },
    );
  }

  Widget _buildTripCard(Trip trip, BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/trip-details',
            arguments: trip,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.asset(
                    trip.imageUrl ?? 'assets/images/default_trip.jpg',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          '4.5',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          trip.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Chip(
                        label: Text(trip.category),
                        backgroundColor: Colors.blue[50],
                        labelStyle: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    trip.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                '${trip.startDate.day}/${trip.startDate.month}/${trip.startDate.year}',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 16, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                '${trip.endDate.difference(trip.startDate).inDays + 1} days',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'From',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '\$${trip.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            'per person',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _bookTrip(trip, context);
                      },
                      child: Text('Book Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _bookTrip(Trip trip, BuildContext context) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final database = Provider.of<DatabaseService>(context, listen: false);
    final user = auth.currentUser;

    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to book "${trip.title}"?'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Price:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('\$${trip.price.toStringAsFixed(2)}'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dates:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${trip.startDate.day}/${trip.startDate.month} - ${trip.endDate.day}/${trip.endDate.month}'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Create booking in Firestore
                await database.createBooking(
                  userId: user.userId,
                  tripId: trip.tripId,
                  travelers: 1,
                  total: trip.price,
                );

                // Book locally
                if (user is Tourist) {
                  user.bookTrip(trip);
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Successfully booked "${trip.title}"!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Booking failed: ${e.toString()}'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Text('Confirm Booking'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context, DatabaseService database) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Search Trips'),
          content: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Enter trip title or description',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _searchController.clear();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_searchController.text.isNotEmpty) {
                  Navigator.pop(context);
                  _showSearchResults(context, database);
                }
              },
              child: Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _showSearchResults(BuildContext context, DatabaseService database) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StreamBuilder<List<Trip>>(
          stream: database.searchTrips(_searchController.text),
          builder: (context, snapshot) {
            List<Widget> children;

            if (snapshot.connectionState == ConnectionState.waiting) {
              children = [
                Center(child: CircularProgressIndicator()),
              ];
            } else if (snapshot.hasError) {
              children = [
                Center(
                  child: Text('Error: ${snapshot.error}'),
                ),
              ];
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              children = [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No results found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ];
            } else {
              final results = snapshot.data!;
              children = [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Search Results (${results.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final trip = results[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(
                            trip.imageUrl ?? 'assets/images/default_trip.jpg',
                          ),
                        ),
                        title: Text(trip.title),
                        subtitle: Text(trip.category),
                        trailing: Text('\$${trip.price.toStringAsFixed(2)}'),
                        onTap: () {
                          Navigator.pop(context); // Close search
                          Navigator.pushNamed(
                            context,
                            '/trip-details',
                            arguments: trip,
                          );
                        },
                      );
                    },
                  ),
                ),
              ];
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                children: children,
              ),
            );
          },
        );
      },
    );
  }

  void _handleMenuSelection(String value, BuildContext context, AuthService auth) {
    switch (value) {
      case 'profile':
        Navigator.pushNamed(context, '/profile');
        break;
      case 'my_trips':
        Navigator.pushNamed(context, '/my-trips');
        break;
      case 'bookings':
        Navigator.pushNamed(context, '/bookings');
        break;
      case 'logout':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Logout'),
            content: Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await auth.logout();
                  Navigator.pop(context);
                  // Navigation is handled by AuthWrapper
                },
                child: Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        );
        break;
    }
  }
}