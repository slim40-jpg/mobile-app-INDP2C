import "trip.dart";
enum UserRole { Tourist, Agency, Admin }

class AppUser {
  final String userId;
  String name;
  final String email;
  final String password;
  final UserRole role;
  String? profileImage;

  AppUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.profileImage,
  });

  // Common methods for all users
  void login() {
    print('$name logged in');
  }

  void viewProfile() {
    print('Viewing profile of $name');
  }

  void updateProfile(Map<String, dynamic> updates) {
    print('Updating profile with: $updates');
  }
}

class Tourist extends AppUser {
  List<String> preferences;
  List<Trip> bookedTrips;

  Tourist({
    required String userId,
    required String name,
    required String email,
    required String password,
    this.preferences = const [],
    this.bookedTrips = const [],
    String? profileImage,
  }) : super(
    userId: userId,
    name: name,
    email: email,
    password: password,
    role: UserRole.Tourist,
    profileImage: profileImage,
  );

  void viewTripHistory() {
    print('Viewing trip history for $name');
  }

  void writeReview(Trip trip, int rating, String comment) {
    print('$name wrote a review for ${trip.title}');
  }

  void bookTrip(Trip trip) {
    bookedTrips.add(trip);
    print('$name booked trip: ${trip.title}');
  }
}

class Agency extends AppUser {
  final String agencyId;
  String bio;
  String contactInfo;
  List<Trip> publishedTrips;

  Agency({
    required String userId,
    required String name,
    required String email,
    required String password,
    required this.agencyId,
    this.bio = '',
    this.contactInfo = '',
    this.publishedTrips = const [],
    String? profileImage,
  }) : super(
    userId: userId,
    name: name,
    email: email,
    password: password,
    role: UserRole.Agency,
    profileImage: profileImage,
  );

  void publishTrip(Trip trip) {
    trip.status = TripStatus.Pending;
    publishedTrips.add(trip);
    print('$name published trip: ${trip.title}');
  }

  void editTrip(Trip trip, Map<String, dynamic> updates) {
    print('Editing trip ${trip.title} with: $updates');
  }

  void managePastTrips() {
    print('Managing past trips for $name');
  }

  void viewReviews() {
    print('Viewing reviews for agency $name');
  }
}

class Administrator extends AppUser {
  List<AppUser> managedUsers;
  List<Agency> managedAgencies;

  Administrator({
    required String userId,
    required String name,
    required String email,
    required String password,
    this.managedUsers = const [],
    this.managedAgencies = const [],
    String? profileImage,
  }) : super(
    userId: userId,
    name: name,
    email: email,
    password: password,
    role: UserRole.Admin,
    profileImage: profileImage,
  );

  void manageUsers() {
    print('Managing users');
  }

  void manageAgencies() {
    print('Managing agencies');
  }

  void approveRejectTrip(Trip trip, bool approve, {String? reason}) {
    if (approve) {
      trip.status = TripStatus.Approved;
      print('Trip ${trip.title} approved');
    } else {
      trip.status = TripStatus.Rejected;
      print('Trip ${trip.title} rejected. Reason: $reason');
    }
  }
}