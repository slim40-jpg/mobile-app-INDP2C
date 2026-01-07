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
import 'screens/debug_screen.dart';
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
          '/debug': (context) => DebugScreen(),
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

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _databaseInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    // Wait for a moment to ensure providers are ready
    await Future.delayed(Duration(milliseconds: 100));

    try {
      print('🔧 Initializing database from AuthWrapper...');
      final databaseService = Provider.of<DatabaseService>(
        context,
        listen: false,
      );
      await databaseService.initializeDatabase();
      print('✅ Database initialization complete');
    } catch (e) {
      print('❌ Error initializing database: $e');
    }

    setState(() {
      _databaseInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_databaseInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Initializing app...'),
            ],
          ),
        ),
      );
    }

    final auth = Provider.of<AuthService>(context, listen: false);
    final user = Provider.of<AppUser?>(context);

    // After database is initialized, check authentication state
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