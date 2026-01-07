// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/auth_login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/trip_details_screen.dart';
import 'screens/publish_trip_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/agency_dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/my_trips_screen.dart';
import 'screens/bookings_screen.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'models/user.dart';
import 'models/trip.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(TourismApp());
}

class TourismApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<AppUser?>(
          create: (_) => AuthService().userStream,
          initialData: null,
          catchError: (_, err) => null,
        ),
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<DatabaseService>(
          create: (_) => DatabaseService(),
        ),
      ],
      child: MaterialApp(
        title: 'TuniVoyage',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 1,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => AuthWrapper(),
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/home': (context) => HomeScreen(),
          '/trip-details': (context) => TripDetailsScreen(
            trip: ModalRoute.of(context)!.settings.arguments as Trip,
          ),
          '/publish-trip': (context) => PublishTripScreen(),
          '/admin-dashboard': (context) => AdminDashboardScreen(),
          '/agency-dashboard': (context) => AgencyDashboardScreen(),
          '/profile': (context) => ProfileScreen(),
          '/my-trips': (context) => MyTripsScreen(),
          '/bookings': (context) => BookingsScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = Provider.of<AppUser?>(context);

    if (user == null) {
      return LoginScreen();
    }



    switch (user.role) {
      case UserRole.Tourist:
        return HomeScreen();
      case UserRole.Agency:
        return AgencyDashboardScreen();
      case UserRole.Admin:
        return AdminDashboardScreen();
    }
  }
}