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
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    print('🔧 AuthWrapper: Starting database init');

    final db = Provider.of<DatabaseService>(
      context,
      listen: false,
    );

    await db.initializeDatabase();

    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
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

    final user = Provider.of<AppUser?>(context);

    if (user == null) {
      print('👤 AuthWrapper: No user, showing LoginScreen');
      return LoginScreen();
    }

    // DEBUG: Print user role
    print('👤 AuthWrapper: User logged in');
    print('   - User ID: ${user.userId}');
    print('   - User Role: ${user.role}');
    print('   - Role string: ${user.role.toString()}');
    print('   - Is Tourist: ${user.role == UserRole.Tourist}');
    print('   - Is Agency: ${user.role == UserRole.Agency}');
    print('   - Is Admin: ${user.role == UserRole.Admin}');

    switch (user.role) {
      case UserRole.Tourist:
        print('📍 Redirecting to Tourist HomeScreen');
        return HomeScreen();
      case UserRole.Agency:
        print('📍 Redirecting to AgencyDashboardScreen');
        return AgencyDashboardScreen();
      case UserRole.Admin:
        print('📍 Redirecting to AdminDashboardScreen');
        return AdminDashboardScreen();
      default:
        print('⚠️ Unknown role, defaulting to HomeScreen');
        return HomeScreen();
    }
  }
}