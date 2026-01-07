// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Please login to view profile'),
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: ListView(
        children: [
          // Profile Header
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue, Colors.lightBlueAccent],
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: user.profileImage != null
                      ? AssetImage(user.profileImage!)
                      : AssetImage('assets/images/default_avatar.jpg'),
                ),
                SizedBox(height: 16),
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Chip(
                  label: Text(
                    user.role.toString().split('.').last,
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ],
            ),
          ),

          // Profile Information
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildProfileItem('Name', user.name),
                  _buildProfileItem('Email', user.email),
                  _buildProfileItem('User ID', user.userId),
                  _buildProfileItem('Role', user.role.toString().split('.').last),

                  if (user is Tourist) ...[
                    SizedBox(height: 16),
                    Text(
                      'Preferences',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: (user as Tourist).preferences
                          .map((preference) => Chip(
                        label: Text(preference),
                        backgroundColor: Colors.blue[50],
                      ))
                          .toList(),
                    ),
                  ],

                  if (user is Agency) ...[
                    SizedBox(height: 16),
                    _buildProfileItem('Agency ID', (user as Agency).agencyId),
                    _buildProfileItem('Bio', (user as Agency).bio),
                    _buildProfileItem('Contact', (user as Agency).contactInfo),
                  ],
                ],
              ),
            ),
          ),

          // Account Settings
          Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Account Settings'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to settings
                  },
                ),
                Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('Notifications'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to notifications
                  },
                ),
                Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.security),
                  title: Text('Privacy & Security'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to privacy
                  },
                ),
              ],
            ),
          ),

          // Logout Button
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                auth.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}