// services/database_service.dart - FIXED VERSION
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/trip.dart';
import '../models/user.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String? userId;

  DatabaseService({this.userId});

  // Collections reference
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get tripsCollection => _firestore.collection('trips');
  CollectionReference get agenciesCollection => _firestore.collection('agencies');
  CollectionReference get reviewsCollection => _firestore.collection('reviews');
  CollectionReference get bookingsCollection => _firestore.collection('bookings');

  // Initialize database with sample data
  // Update initializeDatabase() in DatabaseService
  Future<void> initializeDatabase() async {
    print('🎯 initializeDatabase() CALLED at ${DateTime.now()}');

    try {
      print('🔍 Step 1: Checking trips collection...');

      // Use a try-catch for the query itself
      QuerySnapshot tripsSnapshot;
      try {
        tripsSnapshot = await tripsCollection.limit(1).get();
        print('✅ Query successful');
      } catch (e) {
        print('❌ Query failed: $e');
        print('❌ Query error details: ${e.toString()}');
        rethrow;
      }

      print('📊 Step 2: Found ${tripsSnapshot.docs.length} documents');

      if (tripsSnapshot.docs.isEmpty) {
        print('🔄 Step 3: Collection is empty, creating sample data...');

        try {
          await _createSampleTrips();
          print('✅ Sample trips created');
        } catch (e) {
          print('❌ Failed to create trips: $e');
        }

        try {
          await _createSampleUsers();
          print('✅ Sample users created');
        } catch (e) {
          print('❌ Failed to create users: $e');
        }

        print('🎉 Step 4: Database initialization COMPLETE');
      } else {
        print('⚠️ Step 3: Database already has data, skipping initialization');
      }

    } catch (e) {
      print('💥 CRITICAL ERROR in initializeDatabase: $e');
      print('💥 Stack trace: ${e.toString()}');
    }

    print('🏁 initializeDatabase() FINISHED');
  }


  // Create sample trips
  Future<void> _createSampleTrips() async {
    print('📝 _createSampleTrips() called');
    final List<Map<String, dynamic>> sampleTrips = [
      {
        'tripId': 'trip_001',
        'title': 'Tunis Medina Cultural Tour',
        'description': 'Explore the ancient Medina of Tunis with a local guide. Visit historical sites, traditional markets, and experience authentic Tunisian culture.',
        'category': 'Cultural',
        'startDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 10))),
        'endDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 11))),
        'price': 49.99,
        'status': 'Approved',
        'agencyId': 'agency_001',
        'imageUrl': 'assets/images/tunis_medina.jpg',
        'stops': [
          {
            'stopId': 'stop_001',
            'stopName': 'Bab Bhar',
            'description': 'Main entrance to the Medina',
            'order': 1,
            'location': 'Tunis Medina',
            'latitude': 36.7985,
            'longitude': 10.1655,
          },
          {
            'stopId': 'stop_002',
            'stopName': 'Zitouna Mosque',
            'description': 'Historic mosque in the heart of Medina',
            'order': 2,
            'location': 'Tunis Medina',
            'latitude': 36.7970,
            'longitude': 10.1717,
          },
        ],
        'roadmap': {
          'roadmapId': 'roadmap_001',
          'mapData': '{}',
          'coordinates': [
            {'lat': 36.7985, 'lng': 10.1655},
            {'lat': 36.7970, 'lng': 10.1717},
          ],
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'tripId': 'trip_002',
        'title': 'Sahara Desert Adventure',
        'description': '3-day desert camping experience with camel rides, traditional Berber dinner, and overnight stay in desert camp.',
        'category': 'Adventure',
        'startDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 15))),
        'endDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 18))),
        'price': 299.99,
        'status': 'Approved',
        'agencyId': 'agency_001',
        'imageUrl': 'assets/images/sahara.jpg',
        'stops': [
          {
            'stopId': 'stop_003',
            'stopName': 'Douz',
            'description': 'Gateway to the Sahara Desert',
            'order': 1,
            'location': 'Douz, Tunisia',
            'latitude': 33.4667,
            'longitude': 9.0167,
          },
          {
            'stopId': 'stop_004',
            'stopName': 'Desert Camp',
            'description': 'Traditional Berber camping site',
            'order': 2,
            'location': 'Sahara Desert',
            'latitude': 33.8000,
            'longitude': 9.3000,
          },
        ],
        'roadmap': {
          'roadmapId': 'roadmap_002',
          'mapData': '{}',
          'coordinates': [
            {'lat': 33.4667, 'lng': 9.0167},
            {'lat': 33.8000, 'lng': 9.3000},
          ],
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'tripId': 'trip_003',
        'title': 'Sidi Bou Said Blue Village',
        'description': 'Visit the iconic blue and white village overlooking the Mediterranean Sea. Experience beautiful architecture and stunning views.',
        'category': 'Cultural',
        'startDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 7))),
        'endDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 7))),
        'price': 39.99,
        'status': 'Approved',
        'agencyId': 'agency_002',
        'imageUrl': 'assets/images/sidi_bou_said.jpg',
        'stops': [
          {
            'stopId': 'stop_005',
            'stopName': 'Village Entrance',
            'description': 'Main entrance to Sidi Bou Said',
            'order': 1,
            'location': 'Sidi Bou Said',
            'latitude': 36.8687,
            'longitude': 10.3417,
          },
          {
            'stopId': 'stop_006',
            'stopName': 'Café des Nattes',
            'description': 'Traditional tea house with panoramic views',
            'order': 2,
            'location': 'Sidi Bou Said',
            'latitude': 36.8700,
            'longitude': 10.3420,
          },
        ],
        'roadmap': {
          'roadmapId': 'roadmap_003',
          'mapData': '{}',
          'coordinates': [
            {'lat': 36.8687, 'lng': 10.3417},
            {'lat': 36.8700, 'lng': 10.3420},
          ],
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'tripId': 'trip_004',
        'title': 'Djerba Island Beach Retreat',
        'description': 'Relax on beautiful beaches and explore the unique island culture of Djerba.',
        'category': 'Beach',
        'startDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 20))),
        'endDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 23))),
        'price': 199.99,
        'status': 'Pending',
        'agencyId': 'agency_002',
        'imageUrl': 'assets/images/djerba.jpg',
        'stops': [
          {
            'stopId': 'stop_007',
            'stopName': 'Houmt Souk',
            'description': 'Main town and market of Djerba',
            'order': 1,
            'location': 'Houmt Souk, Djerba',
            'latitude': 33.8750,
            'longitude': 10.8575,
          },
          {
            'stopId': 'stop_008',
            'stopName': 'Sidi Jmour Beach',
            'description': 'Beautiful sandy beach',
            'order': 2,
            'location': 'Djerba Coast',
            'latitude': 33.8800,
            'longitude': 10.8700,
          },
        ],
        'roadmap': {
          'roadmapId': 'roadmap_004',
          'mapData': '{}',
          'coordinates': [
            {'lat': 33.8750, 'lng': 10.8575},
            {'lat': 33.8800, 'lng': 10.8700},
          ],
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];
    print('➕ Creating ${sampleTrips.length} sample trips');


    for (var trip in sampleTrips) {
      final String tripId = trip['tripId'] as String; // Explicit cast to String
      await tripsCollection.doc(tripId).set(trip);
    }
  }

  // Create sample users
  Future<void> _createSampleUsers() async {
    final List<Map<String, dynamic>> sampleUsers = [
      {
        'userId': 'user_001',
        'name': 'John Tourist',
        'email': 'tourist@example.com',
        'role': 'Tourist',
        'preferences': ['Cultural', 'Adventure', 'Beach'],
        'profileImage': null,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'userId': 'user_002',
        'name': 'Tunis Travel Agency',
        'email': 'agency@example.com',
        'role': 'Agency',
        'agencyId': 'agency_001',
        'bio': 'Best travel agency in Tunisia with 10+ years experience',
        'contactInfo': '+216 12 345 678\ncontact@tunistravel.com',
        'profileImage': null,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'userId': 'user_003',
        'name': 'System Administrator',
        'email': 'admin@example.com',
        'role': 'Admin',
        'profileImage': null,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var user in sampleUsers) {
      final String userId = user['userId'] as String; // Explicit cast to String
      await usersCollection.doc(userId).set(user);
    }
  }

  // In _tripFromFirestore method - FIXED VERSION
  Trip _tripFromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // DEBUG: Print what status we're getting
    print('🔥 Parsing trip: ${data['title']}');
    print('🔥 Raw status from Firestore: ${data['status']}');

    // Fix the status parsing
    TripStatus parseStatus(String statusString) {
      try {
        // Remove any whitespace and capitalize first letter
        final formattedStatus = statusString.trim();
        print('🔥 Trying to parse status: $formattedStatus');

        // Find matching enum value
        for (final status in TripStatus.values) {
          if (status.toString().split('.').last.toLowerCase() ==
              formattedStatus.toLowerCase()) {
            print('✅ Matched status: $status');
            return status;
          }
        }

        print('❌ No match found for status: $formattedStatus');
        return TripStatus.Draft; // Default
      } catch (e) {
        print('❌ Error parsing status: $e');
        return TripStatus.Draft;
      }
    }

    return Trip(
      tripId: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'Cultural',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      price: (data['price'] ?? 0).toDouble(),
      status: parseStatus(data['status']?.toString() ?? 'Draft'), // FIXED
      agencyId: data['agencyId'] ?? '',
      imageUrl: data['imageUrl'],
      stops: List<Map<String, dynamic>>.from(data['stops'] ?? [])
          .map((stopData) => TripStop(
        stopId: stopData['stopId']?.toString() ?? '',
        stopName: stopData['stopName']?.toString() ?? '',
        description: stopData['description']?.toString() ?? '',
        order: (stopData['order'] as int?) ?? 0,
        location: stopData['location']?.toString() ?? '',
        latitude: (stopData['latitude'] as num?)?.toDouble(),
        longitude: (stopData['longitude'] as num?)?.toDouble(),
      ))
          .toList(),
      roadmap: data['roadmap'] != null
          ? Roadmap(
        roadmapId: data['roadmap']['roadmapId']?.toString() ?? '',
        mapData: data['roadmap']['mapData']?.toString() ?? '{}',
        coordinates: List<Map<String, dynamic>>.from(data['roadmap']['coordinates'] ?? []),
      )
          : null,
      reviews: [],
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
        .snapshots()  // Remove orderBy for now, or add a default field
        .map((snapshot) {
      try {
        return snapshot.docs.map(_tripFromFirestore).toList();
      } catch (e) {
        print('Error parsing trips: $e');
        return [];
      }
    });
  }
  // Get trips by category
  Stream<List<Trip>> getTripsByCategory(String category) {
    return tripsCollection
        .where('status', isEqualTo: 'Approved')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map(_tripFromFirestore).toList();
      } catch (e) {
        print('Error parsing trips by category: $e');
        return [];
      }
    });
  }

  // Get trip by ID
  Future<Trip?> getTripById(String tripId) async {
    try {
      final doc = await tripsCollection.doc(tripId).get();
      if (doc.exists) {
        return _tripFromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting trip by ID: $e');
      return null;
    }
  }

  // Get trips by agency
  // In DatabaseService - Update getTripsByAgency method
  Stream<List<Trip>> getTripsByAgency(String agencyId) {
    print('🏢 getTripsByAgency() called for agency: $agencyId');

    return tripsCollection
        .where('agencyId', isEqualTo: agencyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
      print('❌ Error in getTripsByAgency stream: $error');
      print('❌ Error details: ${error.toString()}');
      return Stream.value([]);
    })
        .map((snapshot) {
      print('📦 Received ${snapshot.docs.length} trips for agency: $agencyId');

      try {
        final trips = snapshot.docs.map(_tripFromFirestore).toList();
        print('✅ Successfully parsed ${trips.length} trips');

        // Debug each trip
        for (var trip in trips) {
          print('   📄 ${trip.title} - Status: ${trip.status}');
        }

        return trips;
      } catch (e) {
        print('❌ Error parsing trips in getTripsByAgency: $e');
        print('❌ Stack trace: ${e.toString()}');
        return [];
      }
    });
  }
  // Create new trip
  Future<void> createTrip(Trip trip) async {
    try {
      await tripsCollection.doc(trip.tripId).set(_tripToFirestore(trip));
    } catch (e) {
      print('Error creating trip: $e');
      rethrow;
    }
  }

  // Update trip
  Future<void> updateTrip(Trip trip) async {
    try {
      await tripsCollection.doc(trip.tripId).update(_tripToFirestore(trip));
    } catch (e) {
      print('Error updating trip: $e');
      rethrow;
    }
  }

  // Delete trip
  Future<void> deleteTrip(String tripId) async {
    try {
      await tripsCollection.doc(tripId).delete();
    } catch (e) {
      print('Error deleting trip: $e');
      rethrow;
    }
  }

  // Update trip status (for admin)
  Future<void> updateTripStatus(String tripId, TripStatus status) async {
    try {
      await tripsCollection.doc(tripId).update({
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating trip status: $e');
      rethrow;
    }
  }

  // Get pending trips (for admin)
  Stream<List<Trip>> getPendingTrips() {
    return tripsCollection
        .where('status', isEqualTo: 'Pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map(_tripFromFirestore).toList();
      } catch (e) {
        print('Error parsing pending trips: $e');
        return [];
      }
    });
  }

  // USERS

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await usersCollection.doc(userId).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user preferences (for tourists)
  Future<void> updateUserPreferences(String userId, List<String> preferences) async {
    try {
      await usersCollection.doc(userId).update({
        'preferences': preferences,
      });
    } catch (e) {
      print('Error updating user preferences: $e');
      rethrow;
    }
  }

  // BOOKINGS

  // Create booking
  Future<void> createBooking({
    required String userId,
    required String tripId,
    required int travelers,
    required double total,
  }) async {
    try {
      final bookingId = '${DateTime.now().millisecondsSinceEpoch}_$userId';

      await bookingsCollection.doc(bookingId).set({
        'bookingId': bookingId,
        'userId': userId,
        'tripId': tripId,
        'travelers': travelers,
        'total': total,
        'status': 'Confirmed',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating booking: $e');
      rethrow;
    }
  }

  // Get user bookings
  // In DatabaseService - Update getUserBookings method:
  Stream<List<Map<String, dynamic>>> getUserBookings(String userId) {
    print('📖 getUserBookings() called for user: $userId');

    return bookingsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
      print('❌ Error in getUserBookings stream: $error');
      print('❌ Error details: ${error.toString()}');
      return Stream.value([]);
    })
        .map((snapshot) {
      print('✅ Received ${snapshot.docs.length} bookings for user: $userId');

      try {
        final bookings = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          // Debug print each booking
          print('📄 Booking: ${doc.id} - Trip: ${data['tripId']}');

          return {
            'id': doc.id,
            ...data,
          };
        }).toList();

        return bookings;
      } catch (e) {
        print('❌ Error parsing bookings: $e');
        return [];
      }
    });
  }
  // Create review
  Future<void> createReview({
    required String userId,
    required String tripId,
    required int rating,
    required String comment,
  }) async {
    try {
      final reviewId = '${DateTime.now().millisecondsSinceEpoch}_$userId';

      await reviewsCollection.doc(reviewId).set({
        'reviewId': reviewId,
        'userId': userId,
        'tripId': tripId,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating review: $e');
      rethrow;
    }
  }

  // Get reviews for trip
  Stream<List<Map<String, dynamic>>> getTripReviews(String tripId) {
    return reviewsCollection
        .where('tripId', isEqualTo: tripId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
      } catch (e) {
        print('Error parsing reviews: $e');
        return [];
      }
    });
  }

  // AGENCIES

  // Get all agencies
  Stream<List<Map<String, dynamic>>> getAgencies() {
    return usersCollection
        .where('role', isEqualTo: 'Agency')
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
      } catch (e) {
        print('Error parsing agencies: $e');
        return [];
      }
    });
  }

  // SEARCH

  // Search trips
  Stream<List<Trip>> searchTrips(String query) {
    if (query.isEmpty) {
      return getTrips();
    }

    return tripsCollection
        .where('status', isEqualTo: 'Approved')
        .orderBy('title')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map(_tripFromFirestore).toList();
      } catch (e) {
        print('Error parsing search results: $e');
        return [];
      }
    });
  }
}