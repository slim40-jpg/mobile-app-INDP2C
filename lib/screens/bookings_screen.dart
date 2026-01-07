// screens/bookings_screen.dart
// screens/bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/trip.dart';
import '../models/user.dart';

class BookingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    if (auth.currentUser == null || !auth.isTourist) {
      return _buildUnauthorizedScreen(auth , context);
    }

    return Scaffold(
      appBar: AppBar(title: Text('My Bookings')),
      body: Consumer<DatabaseService>(
        builder: (context, database, child) {
          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: database.getUserBookings(auth.currentUser!.userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error loading bookings'));
              }

              final bookings = snapshot.data ?? [];

              if (bookings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No bookings yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        child: Text('Explore Trips'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return FutureBuilder<Trip?>(
                    future: database.getTripById(booking['tripId']),
                    builder: (context, tripSnapshot) {
                      if (tripSnapshot.connectionState == ConnectionState.waiting) {
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 150,
                                        height: 16,
                                        color: Colors.grey[200],
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        width: 100,
                                        height: 12,
                                        color: Colors.grey[200],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final trip = tripSnapshot.data;
                      if (trip == null) {
                        return SizedBox(); // Skip if trip not found
                      }

                      return _buildBookingCard(booking, trip, context);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildUnauthorizedScreen(AuthService auth , BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bookings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Tourist Access Only',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Only tourists can view bookings'),
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

  Widget _buildBookingCard(
      Map<String, dynamic> booking,
      Trip trip,
      BuildContext context,
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
                Text(
                  'Booking #${booking['id'].toString().substring(0, 8)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Chip(
                  label: Text(booking['status']),
                  backgroundColor: booking['status'] == 'Confirmed'
                      ? Colors.green
                      : Colors.orange,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: AssetImage(trip.imageUrl ?? 'assets/images/default_trip.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(trip.category),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.people, size: 14, color: Colors.grey),
                          SizedBox(width: 4),
                          Text('${booking['travelers'] ?? 1} travelers'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Date',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      '${DateTime.fromMillisecondsSinceEpoch(int.parse(booking['id'].toString().split('_')[0])).day}/'
                          '${DateTime.fromMillisecondsSinceEpoch(int.parse(booking['id'].toString().split('_')[0])).month}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      '\$${booking['total'].toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _viewBookingDetails(booking, trip, context);
                    },
                    child: Text('View Details'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _cancelBooking(booking, context);
                    },
                    child: Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: booking['status'] == 'Confirmed'
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _viewBookingDetails(
      Map<String, dynamic> booking,
      Trip trip,
      BuildContext context,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Booking ID:', booking['id'].toString().substring(0, 12)),
              _buildDetailRow('Trip:', trip.title),
              _buildDetailRow('Status:', booking['status']),
              _buildDetailRow('Travelers:', booking['travelers'].toString()),
              _buildDetailRow('Total:', '\$${booking['total'].toStringAsFixed(2)}'),
              _buildDetailRow('Booked on:', DateTime.now().toString().split(' ')[0]),
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

  void _cancelBooking(Map<String, dynamic> booking, BuildContext context) {
    if (booking['status'] == 'Confirmed') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Cancel Booking'),
          content: Text('Are you sure you want to cancel this booking?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Keep Booking'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement cancellation logic
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Booking cancellation requested'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              child: Text('Cancel Booking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      );
    }
  }
}