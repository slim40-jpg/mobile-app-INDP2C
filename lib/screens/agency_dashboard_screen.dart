// screens/agency_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/trip.dart';
import '../models/user.dart';
import 'publish_trip_screen.dart';
import 'trip_details_screen.dart';

class AgencyDashboardScreen extends StatefulWidget {
  @override
  _AgencyDashboardScreenState createState() => _AgencyDashboardScreenState();
}

class _AgencyDashboardScreenState extends State<AgencyDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    // Check if user is agency
    if (auth.currentUser == null || !auth.isAgency) {
      return _buildUnauthorizedScreen(auth);
    }

    final agency = auth.currentUser as Agency;
    final database = Provider.of<DatabaseService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Agency Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PublishTripScreen()),
              );
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? DashboardTab(agency: agency)
          : _selectedIndex == 1
          ? TripsTab(agency: agency, database: database)
          : _selectedIndex == 2
          ? ReviewsTab()
          : ProfileTab(agency: agency, auth: auth),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trip_origin),
            label: 'Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.reviews),
            label: 'Reviews',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildUnauthorizedScreen(AuthService auth) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Agency Access Only',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Please login as an agency to access this page'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                auth.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  final Agency agency;

  DashboardTab({required this.agency});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<DatabaseService>(context);

    return StreamBuilder<List<Trip>>(
      stream: database.getTripsByAgency(agency.agencyId),
      builder: (context, snapshot) {
        List<Trip> trips = [];
        if (snapshot.hasData) {
          trips = snapshot.data!;
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: agency.profileImage != null
                            ? AssetImage(agency.profileImage!)
                            : AssetImage('assets/images/default_avatar.jpg'),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              agency.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              agency.bio,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.email, size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(agency.email),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Stats Grid
              Text(
                'Business Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard(
                    title: 'Total Trips',
                    value: trips.length.toString(),
                    icon: Icons.trip_origin,
                    color: Colors.blue,
                  ),
                  _buildStatCard(
                    title: 'Approved',
                    value: trips.where((trip) => trip.status == TripStatus.Approved).length.toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                  _buildStatCard(
                    title: 'Pending',
                    value: trips.where((trip) => trip.status == TripStatus.Pending).length.toString(),
                    icon: Icons.pending,
                    color: Colors.orange,
                  ),
                  _buildStatCard(
                    title: 'Revenue',
                    value: '\$${(trips.length * 500.0).toStringAsFixed(2)}',
                    icon: Icons.attach_money,
                    color: Colors.purple,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class TripsTab extends StatelessWidget {
  final Agency agency;
  final DatabaseService database;

  TripsTab({required this.agency, required this.database});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Trip>>(
      stream: database.getTripsByAgency(agency.agencyId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading trips'));
        }

        final trips = snapshot.data ?? [];

        if (trips.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.trip_origin, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No trips published yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PublishTripScreen()),
                    );
                  },
                  child: Text('Publish Your First Trip'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: trips.length,
          itemBuilder: (context, index) {
            final trip = trips[index];
            return _buildTripCard(context, trip);
          },
        );
      },
    );
  }

  Widget _buildTripCard(BuildContext context, Trip trip) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TripDetailsScreen(trip: trip),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                    label: Text(
                      trip.status.toString().split('.').last,
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                    backgroundColor: _getStatusColor(trip.status),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(trip.category),
                  Spacer(),
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text('${trip.startDate.day}/${trip.startDate.month}/${trip.startDate.year}'),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.attach_money, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text('\$${trip.price.toStringAsFixed(2)}'),
                  Spacer(),
                  Icon(Icons.access_time, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text('${trip.endDate.difference(trip.startDate).inDays + 1} days'),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      _editTrip(context, trip);
                    },
                    child: Text('Edit'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _viewDetails(context, trip);
                    },
                    child: Text('View'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(TripStatus status) {
    switch (status) {
      case TripStatus.Draft:
        return Colors.grey;
      case TripStatus.Pending:
        return Colors.orange;
      case TripStatus.Approved:
        return Colors.green;
      case TripStatus.Rejected:
        return Colors.red;
    }
  }

  void _editTrip(BuildContext context, Trip trip) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit functionality coming soon!'),
      ),
    );
  }

  void _viewDetails(BuildContext context, Trip trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripDetailsScreen(trip: trip),
      ),
    );
  }
}

class ReviewsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildReviewCard(
          userName: 'John Doe',
          tripName: 'Tunis Medina Tour',
          rating: 5,
          date: '2024-01-15',
          comment: 'Excellent tour! The guide was very knowledgeable.',
        ),
        _buildReviewCard(
          userName: 'Jane Smith',
          tripName: 'Sahara Adventure',
          rating: 4,
          date: '2024-01-10',
          comment: 'Amazing experience, well organized.',
        ),
      ],
    );
  }

  Widget _buildReviewCard({
    required String userName,
    required String tripName,
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
                  child: Text(userName[0]),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        tripName,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
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
            SizedBox(height: 12),
            Text(comment),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  date,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  final Agency agency;
  final AuthService auth;

  ProfileTab({required this.agency, required this.auth});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: agency.profileImage != null
                    ? AssetImage(agency.profileImage!)
                    : AssetImage('assets/images/default_avatar.jpg'),
              ),
              SizedBox(height: 16),
              Text(
                agency.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                agency.email,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),

        SizedBox(height: 32),

        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agency Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                _buildProfileItem(
                  icon: Icons.business,
                  label: 'Agency ID',
                  value: agency.agencyId,
                ),
                _buildProfileItem(
                  icon: Icons.description,
                  label: 'Bio',
                  value: agency.bio,
                ),
                _buildProfileItem(
                  icon: Icons.phone,
                  label: 'Contact',
                  value: agency.contactInfo,
                ),
                _buildProfileItem(
                  icon: Icons.email,
                  label: 'Email',
                  value: agency.email,
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 16),

        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                _buildProfileAction(
                  icon: Icons.edit,
                  label: 'Edit Profile',
                  onTap: () {},
                ),
                _buildProfileAction(
                  icon: Icons.settings,
                  label: 'Settings',
                  onTap: () {},
                ),
                _buildProfileAction(
                  icon: Icons.logout,
                  label: 'Logout',
                  color: Colors.red,
                  onTap: () {
                    auth.logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAction({
    required IconData icon,
    required String label,
    Color color = Colors.blue,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color),
            SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(fontSize: 16),
            ),
            Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}