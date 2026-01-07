import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/trip.dart';
import '../models/user.dart';
import 'trip_details_screen.dart';

class MyTripsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;

    if (user == null) {
      return _buildUnauthorizedScreen(context);
    }

    if (user is Tourist) {
      return _buildTouristTrips(context, user);
    } else if (user is Agency) {
      return _buildAgencyTrips(context, user);
    }

    return _buildUnauthorizedScreen(context);
  }

  Widget _buildUnauthorizedScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Trips')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Access Denied',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Please login to view your trips'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTouristTrips(BuildContext context, Tourist tourist) {
    final database = Provider.of<DatabaseService>(context);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: database.getUserBookings(tourist.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('My Booked Trips')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('My Booked Trips')),
            body: Center(child: Text('Error loading bookings')),
          );
        }

        final bookings = snapshot.data ?? [];

        if (bookings.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text('My Booked Trips')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.trip_origin, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No trips booked yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Explore and book amazing trips!',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: Text('Explore Trips'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text('My Booked Trips')),
          body: FutureBuilder<List<Trip>>(
            future: _getTripsFromBookings(bookings, database),
            builder: (context, tripSnapshot) {
              if (tripSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (tripSnapshot.hasError) {
                return Center(child: Text('Error loading trips'));
              }

              final trips = tripSnapshot.data ?? [];

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: trips.length,
                itemBuilder: (context, index) {
                  final trip = trips[index];
                  final booking = bookings.firstWhere(
                        (b) => b['tripId'] == trip.tripId,
                    orElse: () => {},
                  );

                  return _buildTripCard(trip, booking, context);
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<List<Trip>> _getTripsFromBookings(
      List<Map<String, dynamic>> bookings,
      DatabaseService database,
      ) async {
    List<Trip> trips = [];
    for (var booking in bookings) {
      final trip = await database.getTripById(booking['tripId']);
      if (trip != null) {
        trips.add(trip);
      }
    }
    return trips;
  }

  Widget _buildTripCard(Trip trip, Map<String, dynamic> booking, BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(trip.imageUrl ?? 'assets/images/default_trip.jpg'),
        ),
        title: Text(trip.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(trip.category),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 12),
                SizedBox(width: 4),
                Text('${trip.startDate.day}/${trip.startDate.month}'),
              ],
            ),
            SizedBox(height: 4),
            Chip(
              label: Text(
                booking['status'] ?? 'Booked',
                style: TextStyle(fontSize: 10),
              ),
              backgroundColor: booking['status'] == 'Confirmed'
                  ? Colors.green
                  : Colors.orange,
            ),
          ],
        ),
        trailing: Text('\$${trip.price.toStringAsFixed(2)}'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TripDetailsScreen(trip: trip),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAgencyTrips(BuildContext context, Agency agency) {
    final database = Provider.of<DatabaseService>(context);

    return StreamBuilder<List<Trip>>(
      stream: database.getTripsByAgency(agency.agencyId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('My Published Trips')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('My Published Trips')),
            body: Center(child: Text('Error loading trips')),
          );
        }

        final trips = snapshot.data ?? [];

        if (trips.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text('My Published Trips')),
            body: Center(
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
                      Navigator.pushNamed(context, '/publish-trip');
                    },
                    child: Text('Publish First Trip'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text('My Published Trips')),
          body: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(trip.status),
                    child: Icon(
                      _getStatusIcon(trip.status),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(trip.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trip.category),
                      Chip(
                        label: Text(
                          trip.status.toString().split('.').last,
                          style: TextStyle(fontSize: 10),
                        ),
                        backgroundColor: _getStatusColor(trip.status).withOpacity(0.2),
                      ),
                    ],
                  ),
                  trailing: Text('\$${trip.price.toStringAsFixed(2)}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TripDetailsScreen(trip: trip),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
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

  IconData _getStatusIcon(TripStatus status) {
    switch (status) {
      case TripStatus.Draft:
        return Icons.edit;
      case TripStatus.Pending:
        return Icons.pending;
      case TripStatus.Approved:
        return Icons.check;
      case TripStatus.Rejected:
        return Icons.close;
    }
  }
}