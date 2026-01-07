// services/auth_service.dart - UPDATED TO SAVE TO FIRESTORE
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isTourist => _currentUser?.role == UserRole.Tourist;
  bool get isAgency => _currentUser?.role == UserRole.Agency;
  bool get isAdmin => _currentUser?.role == UserRole.Admin;

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Convert Firebase User to our AppUser model
  AppUser? _userFromFirebase(User? firebaseUser, Map<String, dynamic>? userData) {
    if (firebaseUser == null) return null;

    final roleString = userData?['role'] ?? 'Tourist';
    final UserRole role = UserRole.values.firstWhere(
          (e) => e.toString().split('.').last == roleString,
      orElse: () => UserRole.Tourist,
    );

    switch (role) {
      case UserRole.Tourist:
        return Tourist(
          userId: firebaseUser.uid,
          name: userData?['name'] ?? firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          password: '', // Don't store password locally
          preferences: List<String>.from(userData?['preferences'] ?? []),
          bookedTrips: [], // Will be loaded separately
          profileImage: userData?['profileImage'],
        );
      case UserRole.Agency:
        return Agency(
          userId: firebaseUser.uid,
          name: userData?['name'] ?? firebaseUser.displayName ?? 'Agency',
          email: firebaseUser.email ?? '',
          password: '',
          agencyId: userData?['agencyId'] ?? firebaseUser.uid,
          bio: userData?['bio'] ?? '',
          contactInfo: userData?['contactInfo'] ?? '',
          publishedTrips: [], // Will be loaded separately
          profileImage: userData?['profileImage'],
        );
      case UserRole.Admin:
        return Administrator(
          userId: firebaseUser.uid,
          name: userData?['name'] ?? 'Admin',
          email: firebaseUser.email ?? '',
          password: '',
          profileImage: userData?['profileImage'],
        );
    }
  }

  // Stream to listen to auth state changes
  Stream<AppUser?> get userStream {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        return null;
      }

      try {
        // Get additional user data from Firestore
        final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();

        if (!userDoc.exists) {
          // User exists in Auth but not in Firestore - create Firestore document
          await _createUserInFirestore(firebaseUser, 'Tourist');
          final newDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
          final userData = newDoc.data();
          _currentUser = _userFromFirebase(firebaseUser, userData);
        } else {
          final userData = userDoc.data();
          _currentUser = _userFromFirebase(firebaseUser, userData);
        }

        return _currentUser;
      } catch (e) {
        print('Error loading user from Firestore: $e');
        return null;
      }
    });
  }

  // Create user document in Firestore
  Future<void> _createUserInFirestore(User firebaseUser, String role, {Map<String, dynamic>? additionalData}) async {
    try {
      Map<String, dynamic> userData = {
        'userId': firebaseUser.uid,
        'name': firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'User',
        'email': firebaseUser.email ?? '',
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add role-specific data
      if (role == 'Agency' && additionalData != null) {
        userData.addAll({
          'agencyId': additionalData['agencyId'] ?? 'agency_${DateTime.now().millisecondsSinceEpoch}',
          'bio': additionalData['bio'] ?? '',
          'contactInfo': additionalData['contactInfo'] ?? '',
        });
      } else if (role == 'Tourist' && additionalData != null) {
        userData.addAll({
          'preferences': additionalData['preferences'] ?? [],
        });
      }

      // Save to Firestore
      await _firestore.collection('users').doc(firebaseUser.uid).set(userData);

      print('User created in Firestore: ${firebaseUser.uid}');
    } catch (e) {
      print('Error creating user in Firestore: $e');
      rethrow;
    }
  }

  // Login with email and password
  Future<AppUser?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user data from Firestore
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();

      if (!userDoc.exists) {
        // Create user in Firestore if doesn't exist
        await _createUserInFirestore(userCredential.user!, 'Tourist');
        final newDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
        final userData = newDoc.data();
        _currentUser = _userFromFirebase(userCredential.user, userData);
      } else {
        final userData = userDoc.data();
        _currentUser = _userFromFirebase(userCredential.user, userData);
      }

      return _currentUser;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // Signup new user
  Future<AppUser?> signup({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // 1. Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Update display name
      await userCredential.user!.updateDisplayName(name);

      // 3. Create user document in Firestore
      await _createUserInFirestore(
        userCredential.user!,
        role.toString().split('.').last,
        additionalData: additionalData,
      );

      // 4. Get the created user data
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      final userData = userDoc.data();

      _currentUser = _userFromFirebase(userCredential.user, userData);
      return _currentUser;
    } catch (e) {
      print('Signup error: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
  }

  // Get current user (for initialization)
  Future<void> initializeCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      _currentUser = _userFromFirebase(user, userData);
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Update user profile
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final user = _auth.currentUser;
    if (user != null) {
      // Update in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update locally
      if (_currentUser != null) {
        if (updates.containsKey('name') && _currentUser is Tourist) {
          (_currentUser as Tourist).name = updates['name'] as String;
        } else if (updates.containsKey('name') && _currentUser is Agency) {
          (_currentUser as Agency).name = updates['name'] as String;
        }
      }
    }
  }

  // Check if user document exists in Firestore
  Future<bool> userExistsInFirestore(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.exists;
  }
}