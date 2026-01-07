// screens/signup_screen.dart - UPDATED
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  UserRole _selectedRole = UserRole.Tourist;
  bool _isLoading = false;
  String _errorMessage = '';

  // Additional fields for Agency
  final _bioController = TextEditingController();
  final _contactInfoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Join TuniVoyage to explore Tunisia',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 32),

              // Error Message
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),

              // Role Selection
              Text(
                'I want to join as:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Text('Tourist'),
                      selected: _selectedRole == UserRole.Tourist,
                      onSelected: (selected) {
                        setState(() {
                          _selectedRole = UserRole.Tourist;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: Text('Travel Agency'),
                      selected: _selectedRole == UserRole.Agency,
                      onSelected: (selected) {
                        setState(() {
                          _selectedRole = UserRole.Agency;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Basic Information
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Additional fields for Agency
              if (_selectedRole == UserRole.Agency) ...[
                TextFormField(
                  controller: _bioController,
                  decoration: InputDecoration(
                    labelText: 'Agency Bio',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter agency bio';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                TextFormField(
                  controller: _contactInfoController,
                  decoration: InputDecoration(
                    labelText: 'Contact Information',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter contact information';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
              ],

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _signup,
                  child: Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
              ),

              SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text('Already have an account? Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        final auth = Provider.of<AuthService>(context, listen: false);

        Map<String, dynamic> additionalData = {};

        if (_selectedRole == UserRole.Agency) {
          additionalData = {
            'bio': _bioController.text,
            'contactInfo': _contactInfoController.text,
          };
        } else if (_selectedRole == UserRole.Tourist) {
          additionalData = {
            'preferences': [], // Empty preferences by default
          };
        }

        final user = await auth.signup(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          role: _selectedRole,
          additionalData: additionalData,
        );

        if (user != null) {
          // Success - AuthWrapper will handle navigation
          print('Signup successful! User ID: ${user.userId}');
        }
      } catch (e) {
        setState(() {
          _errorMessage = _getErrorMessage(e);
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString();
    if (errorStr.contains('email-already-in-use')) {
      return 'This email is already registered';
    } else if (errorStr.contains('weak-password')) {
      return 'Password is too weak';
    } else if (errorStr.contains('network-request-failed')) {
      return 'Network error. Check your connection';
    } else {
      return 'Signup failed. Please try again';
    }
  }
}