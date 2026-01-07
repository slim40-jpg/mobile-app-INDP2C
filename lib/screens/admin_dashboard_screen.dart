// screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/trip.dart';
import '../models/user.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    // Check if user is admin
    if (auth.currentUser == null || !auth.isAdmin) {
      return _buildUnauthorizedScreen(auth);
    }

    final admin = auth.currentUser as Administrator;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin Dashboard'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
              Tab(icon: Icon(Icons.pending), text: 'Pending Trips'),
              Tab(icon: Icon(Icons.business), text: 'Agencies'),
              Tab(icon: Icon(Icons.people), text: 'Users'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OverviewTab(admin: admin),
            PendingTripsTab(),
            AgenciesTab(),
            UsersTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildUnauthorizedScreen(AuthService auth) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Admin Access Only',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Only administrators can access this page'),
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

class OverviewTab extends StatelessWidget {
  final Administrator admin;

  OverviewTab({required this.admin});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<DatabaseService>(context);

    return StreamBuilder<List<Trip>>(
      stream: database.getPendingTrips(),
      builder: (context, pendingSnapshot) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard(
                    title: 'Pending Trips',
                    value: pendingSnapshot.hasData ? pendingSnapshot.data!.length.toString() : '0',
                    icon: Icons.pending,
                    color: Colors.orange,
                  ),
                  _buildStatCard(
                    title: 'Total Admins',
                    value: '1',
                    icon: Icons.admin_panel_settings,
                    color: Colors.purple,
                  ),
                  _buildStatCard(
                    title: 'System Status',
                    value: 'Active',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                  _buildStatCard(
                    title: 'Reports',
                    value: '12',
                    icon: Icons.analytics,
                    color: Colors.blue,
                  ),
                ],
              ),

              SizedBox(height: 32),

              // Recent Activity
              Text(
                'Recent Activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildActivityItem(
                        'New agency registered',
                        '10 minutes ago',
                        Icons.business,
                        Colors.green,
                      ),
                      Divider(),
                      _buildActivityItem(
                        'Trip approved',
                        '1 hour ago',
                        Icons.check_circle,
                        Colors.blue,
                      ),
                      Divider(),
                      _buildActivityItem(
                        'User reported',
                        '2 hours ago',
                        Icons.warning,
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
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

  Widget _buildActivityItem(
      String title,
      String time,
      IconData icon,
      Color color,
      ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: color),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(time, style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}

class PendingTripsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<DatabaseService>(context);
    final auth = Provider.of<AuthService>(context);

    return StreamBuilder<List<Trip>>(
      stream: database.getPendingTrips(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading pending trips'));
        }

        final pendingTrips = snapshot.data ?? [];

        if (pendingTrips.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 64, color: Colors.green),
                SizedBox(height: 16),
                Text(
                  'No pending trips',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: pendingTrips.length,
          itemBuilder: (context, index) {
            final trip = pendingTrips[index];
            return _buildPendingTripCard(context, trip, database, auth);
          },
        );
      },
    );
  }

  Widget _buildPendingTripCard(
      BuildContext context,
      Trip trip,
      DatabaseService database,
      AuthService auth,
      ) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
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
                  ),
                ),
                Chip(
                  label: Text('Pending'),
                  backgroundColor: Colors.orange,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              trip.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.category, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(trip.category),
                Spacer(),
                Icon(Icons.attach_money, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text('\$${trip.price.toStringAsFixed(2)}'),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    _rejectTrip(context, trip, database, auth);
                  },
                  child: Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    _approveTrip(context, trip, database, auth);
                  },
                  child: Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _approveTrip(
      BuildContext context,
      Trip trip,
      DatabaseService database,
      AuthService auth,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Approve Trip'),
        content: Text('Are you sure you want to approve "${trip.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await database.updateTripStatus(trip.tripId, TripStatus.Approved);
                if (auth.currentUser is Administrator) {
                  (auth.currentUser as Administrator).approveRejectTrip(trip, true);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Trip approved successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _rejectTrip(
      BuildContext context,
      Trip trip,
      DatabaseService database,
      AuthService auth,
      ) {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reject Trip'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject "${trip.title}"?'),
            SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Reason for rejection',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
                await database.updateTripStatus(trip.tripId, TripStatus.Rejected);
                if (auth.currentUser is Administrator) {
                  (auth.currentUser as Administrator).approveRejectTrip(trip, false, reason: reasonController.text);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Trip rejected. Agency notified.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Reject'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class AgenciesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<DatabaseService>(context);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: database.getAgencies(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading agencies'));
        }

        final agencies = snapshot.data ?? [];

        if (agencies.isEmpty) {
          return Center(
            child: Text(
              'No agencies registered',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: agencies.length,
          itemBuilder: (context, index) {
            final agency = agencies[index];
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(agency['name'][0]),
                ),
                title: Text(agency['name']),
                subtitle: Text(agency['email']),
                trailing: IconButton(
                  icon: Icon(Icons.remove_red_eye, color: Colors.blue),
                  onPressed: () {
                    _viewAgencyDetails(context, agency);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _viewAgencyDetails(BuildContext context, Map<String, dynamic> agency) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agency Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Name:', agency['name']),
              _buildDetailRow('Email:', agency['email']),
              _buildDetailRow('Agency ID:', agency['agencyId'] ?? 'N/A'),
              _buildDetailRow('Bio:', agency['bio'] ?? 'No bio'),
              _buildDetailRow('Contact:', agency['contactInfo'] ?? 'No contact info'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class UsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'User Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 16),
          Text(
            'User list and management features\nwill be available in the next update',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}