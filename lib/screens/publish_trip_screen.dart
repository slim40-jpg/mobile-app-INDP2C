// screens/publish_trip_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/models/user.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/trip.dart';
import '../models/roadmap.dart';

class PublishTripScreen extends StatefulWidget {
  @override
  _PublishTripScreenState createState() => _PublishTripScreenState();
}

class _PublishTripScreenState extends State<PublishTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedCategory = 'Cultural';
  DateTime? _startDate;
  DateTime? _endDate;

  List<Map<String, dynamic>> tripStops = [];
  final _stopNameController = TextEditingController();
  final _stopDescriptionController = TextEditingController();
  final _stopLocationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    // Check if user is agency
    if (auth.currentUser == null || !auth.isAgency) {
      return Scaffold(
        appBar: AppBar(title: Text('Publish Trip')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.business, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Agency Access Only',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Only agencies can publish trips'),
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

    final agency = auth.currentUser as Agency;

    return Scaffold(
      appBar: AppBar(
        title: Text('Publish New Trip'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              Text(
                'Trip Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              _buildTextField(
                controller: _titleController,
                label: 'Trip Title',
                hint: 'Enter trip title',
                icon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),

              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Enter trip description',
                icon: Icons.description,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  if (value.length < 50) {
                    return 'Description should be at least 50 characters';
                  }
                  return null;
                },
              ),

              // Category Selection
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: [
                  'Cultural',
                  'Adventure',
                  'Beach',
                  'Historical',
                  'Gastronomy',
                  'Nature',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              SizedBox(height: 16),

              // Date Selection
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Start Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                        hintText: 'Select start date',
                      ),
                      controller: TextEditingController(
                        text: _startDate == null
                            ? ''
                            : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                      ),
                      onTap: () => _selectDate(context, isStartDate: true),
                      validator: (value) {
                        if (_startDate == null) {
                          return 'Please select a start date';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'End Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                        hintText: 'Select end date',
                      ),
                      controller: TextEditingController(
                        text: _endDate == null
                            ? ''
                            : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                      ),
                      onTap: () => _selectDate(context, isStartDate: false),
                      validator: (value) {
                        if (_endDate == null) {
                          return 'Please select an end date';
                        }
                        if (_startDate != null && _endDate!.isBefore(_startDate!)) {
                          return 'End date must be after start date';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              _buildTextField(
                controller: _priceController,
                label: 'Price (USD)',
                hint: 'Enter price',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              SizedBox(height: 32),

              // Trip Stops Section
              _buildTripStopsSection(),

              SizedBox(height: 32),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: () => _submitTrip(context, agency),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    child: Text(
                      'Submit for Approval',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          prefixIcon: Icon(icon),
          hintText: hint,
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildTripStopsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trip Stops',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: Colors.blue),
              onPressed: _addTripStop,
            ),
          ],
        ),
        SizedBox(height: 8),

        if (tripStops.isEmpty)
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No stops added yet. Click + to add stops',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),

        ...tripStops.map((stop) {
          return Card(
            margin: EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${stop['order']}'),
              ),
              title: Text(stop['name']),
              subtitle: Text(stop['location']),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeTripStop(stop['id']),
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    print('📅 Date picker triggered for ${isStartDate ? 'start' : 'end'} date');

    // Get current date
    final now = DateTime.now();
    print('📅 Current date: $now');

    // Set proper date ranges
    DateTime initialDate;
    DateTime firstDate;
    DateTime lastDate;

    if (isStartDate) {
      // For start date: can start from today, up to 1 year from now
      initialDate = _startDate ?? now;
      firstDate = now;
      lastDate = DateTime(now.year + 1, 12, 31); // 1 year from now
    } else {
      // For end date: if start date is set, end date must be after start date
      // If no start date, end date can start from today
      if (_startDate != null) {
        initialDate = _endDate ?? _startDate!.add(Duration(days: 1));
        firstDate = _startDate!;
        lastDate = DateTime(_startDate!.year + 1, 12, 31);
      } else {
        initialDate = _endDate ?? now.add(Duration(days: 1));
        firstDate = now;
        lastDate = DateTime(now.year + 1, 12, 31);
      }
    }

    print('📅 Picker settings:');
    print('   - Initial: $initialDate');
    print('   - First: $firstDate');
    print('   - Last: $lastDate');

    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.blue,
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        print('✅ Date selected: ${picked.day}/${picked.month}/${picked.year}');

        setState(() {
          if (isStartDate) {
            _startDate = picked;
            // If end date exists and is before new start date, clear it
            if (_endDate != null && _endDate!.isBefore(picked)) {
              _endDate = null;
            }
          } else {
            _endDate = picked;
          }
        });
      } else {
        print('❌ Date selection cancelled');
      }
    } catch (e) {
      print('❌ Error in date picker: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting date: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  void _addTripStop() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Trip Stop'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _stopNameController,
                  decoration: InputDecoration(
                    labelText: 'Stop Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _stopDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _stopLocationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_stopNameController.text.isNotEmpty &&
                    _stopLocationController.text.isNotEmpty) {
                  setState(() {
                    tripStops.add({
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'name': _stopNameController.text,
                      'description': _stopDescriptionController.text,
                      'location': _stopLocationController.text,
                      'order': tripStops.length + 1,
                    });

                    _stopNameController.clear();
                    _stopDescriptionController.clear();
                    _stopLocationController.clear();
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeTripStop(String id) {
    setState(() {
      tripStops.removeWhere((stop) => stop['id'] == id);
      // Reorder remaining stops
      for (int i = 0; i < tripStops.length; i++) {
        tripStops[i]['order'] = i + 1;
      }
    });
  }

  void _submitTrip(BuildContext context, Agency agency) async {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select both start and end dates'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (tripStops.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please add at least one trip stop'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Submit for Approval'),
            content: Text(
              'Your trip will be submitted for admin approval. '
                  'You will be notified once it\'s reviewed.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final database = Provider.of<DatabaseService>(context, listen: false);

                    // Create the trip
                    final newTrip = Trip(
                      tripId: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: _titleController.text,
                      description: _descriptionController.text,
                      category: _selectedCategory,
                      startDate: _startDate!,
                      endDate: _endDate!,
                      price: double.parse(_priceController.text),
                      status: TripStatus.Pending,
                      agencyId: agency.agencyId,
                      stops: tripStops.map((stop) => TripStop(
                        stopId: stop['id'],
                        stopName: stop['name'],
                        description: stop['description'],
                        order: stop['order'],
                        location: stop['location'],
                      )).toList(),
                    );

                    // Save to Firestore
                    await database.createTrip(newTrip);

                    // Update local agency trips
                    agency.publishTrip(newTrip);

                    Navigator.pop(context); // Close confirmation dialog
                    Navigator.pop(context); // Go back to dashboard

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Trip submitted for approval!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error submitting trip: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text('Submit'),
              ),
            ],
          );
        },
      );
    }
  }
}