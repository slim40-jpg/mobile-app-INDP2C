import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';

class DebugScreen extends StatefulWidget {
  @override
  _DebugScreenState createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  String _log = '';

  void _addLog(String message) {
    setState(() {
      _log += '${DateTime.now().toIso8601String()}: $message\n';
    });
    print(message);
  }

  Future<void> _testDatabase() async {
    _addLog('=== STARTING DATABASE TEST ===');

    final db = Provider.of<DatabaseService>(context, listen: false);

    // Test 1: Check Firestore connection
    _addLog('Test 1: Checking Firestore connection...');
    try {
      final test = await db.tripsCollection.limit(1).get();
      _addLog('✅ Firestore connection OK');
    } catch (e) {
      _addLog('❌ Firestore connection FAILED: $e');
      return;
    }

    // Test 2: Initialize database
    _addLog('\nTest 2: Calling initializeDatabase()...');
    await db.initializeDatabase();

    // Test 3: Check results
    _addLog('\nTest 3: Verifying data...');
    final trips = await db.tripsCollection.get();
    _addLog('Total trips in database: ${trips.docs.length}');

    if (trips.docs.isNotEmpty) {
      for (var doc in trips.docs) {
        final data = doc.data() as Map<String, dynamic>;
        _addLog('📄 ${doc.id}: ${data['title']}');
      }
    } else {
      _addLog('❌ NO TRIPS FOUND!');
    }

    _addLog('\n=== TEST COMPLETE ===');
  }

  Future<void> _directWriteTest() async {
    _addLog('\n=== DIRECT WRITE TEST ===');

    final db = Provider.of<DatabaseService>(context, listen: false);

    try {
      _addLog('Writing simple document...');
      await db.tripsCollection.doc('direct_test').set({
        'title': 'Direct Test Trip',
        'status': 'Approved',
        'price': 99.99,

      });

      _addLog('✅ Write successful');

      // Read it back
      final doc = await db.tripsCollection.doc('direct_test').get();
      _addLog('Read back: ${doc.exists ? "EXISTS" : "MISSING"}');

      if (doc.exists) {
        _addLog('Data: ${doc.data()}');
      }

    } catch (e) {
      _addLog('❌ Direct write failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Database Debug')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: _testDatabase,
                  child: Text('Test Database'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _directWriteTest,
                  child: Text('Direct Write Test'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => setState(() => _log = ''),
                  child: Text('Clear Log'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _log,
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}