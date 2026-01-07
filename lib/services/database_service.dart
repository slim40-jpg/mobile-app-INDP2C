// services/database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip.dart';
import '../models/user.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId;

  DatabaseService({this.userId});

  // Collections reference
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get tripsCollection => _firestore.collection('trips');
  CollectionReference get agenciesCollection => _firestore.collection('agencies');
  CollectionReference get reviewsCollection => _firestore.collection('reviews');
  CollectionReference get bookingsCollection => _firestore.collection('bookings');

  // Convert Firestore Document to Trip
  Trip _tripFromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Trip(
      tripId: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'Cultural',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      price: (data['price'] ?? 0).toDouble(),
      status: TripStatus.values.firstWhere(
            (e) => e.toString().split('.').last == data['status'],
        orElse: () => TripStatus.Draft,
      ),
      agencyId: data['agencyId'] ?? '',
      imageUrl: data['imageUrl'],
      stops: List<Map<String, dynamic>>.from(data['stops'] ?? [])
          .map((stopData) => TripStop(
        stopId: stopData['stopId'] ?? '',
        stopName: stopData['stopName'] ?? '',
        description: stopData['description'] ?? '',
        order: stopData['order'] ?? 0,
        location: stopData['location'] ?? '',
        latitude: stopData['latitude']?.toDouble(),
        longitude: stopData['longitude']?.toDouble(),
      ))
          .toList(),
      roadmap: data['roadmap'] != null
          ? Roadmap(
        roadmapId: data['roadmap']['roadmapId'] ?? '',
        mapData: data['roadmap']['mapData'] ?? '{}',
        coordinates: List<Map<String, dynamic>>.from(data['roadmap']['coordinates'] ?? []),
      )
          : null,
      reviews: [], // Will be loaded separately
    );
  }

  // Convert Trip to Firestore Map
  Map<String, dynamic> _tripToFirestore(Trip trip) {
    return {
      'title': trip.title,
      'description': trip.description,
      'category': trip.category,
      'startDate': Timestamp.fromDate(trip.startDate),
      'endDate': Timestamp.fromDate(trip.endDate),
      'price': trip.price,
      'status': trip.status.toString().split('.').last,
      'agencyId': trip.agencyId,
      'imageUrl': trip.imageUrl,
      'stops': trip.stops.map((stop) => {
        'stopId': stop.stopId,
        'stopName': stop.stopName,
        'description': stop.description,
        'order': stop.order,
        'location': stop.location,
        'latitude': stop.latitude,
        'longitude': stop.longitude,
      }).toList(),
      'roadmap': trip.roadmap != null ? {
        'roadmapId': trip.roadmap!.roadmapId,
        'mapData': trip.roadmap!.mapData,
        'coordinates': trip.roadmap!.coordinates,
      } : null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // TRIPS

  // Get all trips (for tourists)
  Stream<List<Trip>> getTrips() {
    return tripsCollection
        .where('status', isEqualTo: 'Approved')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_tripFromFirestore).toList());
  }

  // Get trips by category
  Stream<List<Trip>> getTripsByCategory(String category) {
    return tripsCollection
        .where('status', isEqualTo: 'Approved')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_tripFromFirestore).toList());
  }

  // Get trip by ID
  Future<Trip?> getTripById(String tripId) async {
    final doc = await tripsCollection.doc(tripId).get();
    if (doc.exists) {
      return _tripFromFirestore(doc);
    }
    return null;
  }

  // Get trips by agency
  Stream<List<Trip>> getTripsByAgency(String agencyId) {
    return tripsCollection
        .where('agencyId', isEqualTo: agencyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_tripFromFirestore).toList());
  }

  // Create new trip
  Future<void> createTrip(Trip trip) async {
    await tripsCollection.doc(trip.tripId).set(_tripToFirestore(trip));
  }

  // Update trip
  Future<void> updateTrip(Trip trip) async {
    await tripsCollection.doc(trip.tripId).update(_tripToFirestore(trip));
  }

  // Delete trip
  Future<void> deleteTrip(String tripId) async {
    await tripsCollection.doc(tripId).delete();
  }

  // Update trip status (for admin)
  Future<void> updateTripStatus(String tripId, TripStatus status) async {
    await tripsCollection.doc(tripId).update({
      'status': status.toString().split('.').last,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get pending trips (for admin)
  Stream<List<Trip>> getPendingTrips() {
    return tripsCollection
        .where('status', isEqualTo: 'Pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_tripFromFirestore).toList());
  }

  // USERS

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final doc = await usersCollection.doc(userId).get();
    return doc.data() as Map<String, dynamic>?;
  }

  // Update user preferences (for tourists)
  Future<void> updateUserPreferences(String userId, List<String> preferences) async {
    await usersCollection.doc(userId).update({
      'preferences': preferences,
    });
  }

  // BOOKINGS

  // Create booking
  Future<void> createBooking({
    required String userId,
    required String tripId,
    required int travelers,
    required double total,
  }) async {
    final bookingId = '${DateTime.now().millisecondsSinceEpoch}_$userId';

    await bookingsCollection.doc(bookingId).set({
      'userId': userId,
      'tripId': tripId,
      'travelers': travelers,
      'total': total,
      'status': 'Confirmed',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get user bookings
  Stream<List<Map<String, dynamic>>> getUserBookings(String userId) {
    return bookingsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        ...data,
      };
    }).toList());
  }

  // REVIEWS

  // Create review
  Future<void> createReview({
    required String userId,
    required String tripId,
    required int rating,
    required String comment,
  }) async {
    final reviewId = '${DateTime.now().millisecondsSinceEpoch}_$userId';

    await reviewsCollection.doc(reviewId).set({
      'userId': userId,
      'tripId': tripId,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get reviews for trip
  Stream<List<Map<String, dynamic>>> getTripReviews(String tripId) {
    return reviewsCollection
        .where('tripId', isEqualTo: tripId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        ...data,
      };
    }).toList());
  }

  // AGENCIES

  // Get all agencies
  Stream<List<Map<String, dynamic>>> getAgencies() {
    return usersCollection
        .where('role', isEqualTo: 'Agency')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        ...data,
      };
    }).toList());
  }

  // SEARCH

  // Search trips
  Stream<List<Trip>> searchTrips(String query) {
    return tripsCollection
        .where('status', isEqualTo: 'Approved')
        .orderBy('title')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_tripFromFirestore).toList());
  }
}