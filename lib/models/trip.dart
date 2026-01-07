// models/trip.dart
enum TripStatus { Draft, Pending, Approved, Rejected }

class Trip {
  String tripId;
  String title;
  String description;
  String category;
  DateTime startDate;
  DateTime endDate;
  double price;
  TripStatus status;
  String agencyId;
  String? imageUrl;
  List<TripStop> stops;
  Roadmap? roadmap;
  List<Review> reviews;

  Trip({
    required this.tripId,
    required this.title,
    required this.description,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.price,
    this.status = TripStatus.Draft,
    required this.agencyId,
    this.imageUrl,
    this.stops = const [],
    this.roadmap,
    this.reviews = const [],
  });

  void filterByCategory(String category) {
    print('Filtering trips by category: $category');
  }

  void viewDetails() {
    print('Viewing details for trip: $title');
  }

  double getAverageRating() {
    if (reviews.isEmpty) return 0;
    final sum = reviews.fold(0, (prev, review) => prev + review.rating);
    return sum / reviews.length;
  }
}

// models/trip_stop.dart
class TripStop {
  final String stopId;
  String stopName;
  String description;
  int order;
  String location;
  double? latitude;
  double? longitude;

  TripStop({
    required this.stopId,
    required this.stopName,
    required this.description,
    required this.order,
    required this.location,
    this.latitude,
    this.longitude,
  });
}

// models/roadmap.dart
class Roadmap {
  final String roadmapId;
  String mapData;
  List<Map<String, dynamic>> coordinates;

  Roadmap({
    required this.roadmapId,
    required this.mapData,
    this.coordinates = const [],
  });

  void viewRoadmap() {
    print('Viewing roadmap $roadmapId');
  }
}

// models/review.dart
class Review {
  final String reviewId;
  final String touristId;
  final String tripId;
  int rating;
  String comment;
  DateTime date;

  Review({
    required this.reviewId,
    required this.touristId,
    required this.tripId,
    required this.rating,
    required this.comment,
    required this.date,
  });
}