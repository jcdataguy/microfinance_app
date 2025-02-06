import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Client Screens
import 'loan_application_screen.dart';
import 'loan_payment_screen.dart';
import 'loan_details_screen.dart';
import 'profile_screen.dart'; // Placeholder for client profile updates

// Admin Screens
import 'dashboard_screen.dart';    // Might show outstanding loans or loan requests
import 'manage_clients_screen.dart'; // Placeholder for admin to manage clients

import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
   HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _role;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!doc.exists || !doc.data()!.containsKey('role')) {
        // Default to client if role is missing
        _role = 'client';
      } else {
        _role = doc.data()!['role'] as String;
      }
    } catch (e) {
      // If there's an error, default to client or handle appropriately
      _role = 'client';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) =>  LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_role == 'admin') {
      return _buildAdminHome(context);
    } else {
      return _buildClientHome(context);
    }
  }

  // =========================
  // Client Home Layout
  // =========================
  Widget _buildClientHome(BuildContext context) {
    // Example loan info used for demonstration
     String loanId = 'abc123';
     double currentRemainingBalance = 30000.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Request a Loan
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  LoanApplicationScreen(),
                    ),
                  );
                },
                child: const Text('Request a Loan'),
              ),
              const SizedBox(height: 16),

              // View Loan Details
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoanDetailsScreen(loanId: loanId),
                    ),
                  );
                },
                child: const Text('View Loan Details'),
              ),
              const SizedBox(height: 16),

              // Make a Payment
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoanPaymentScreen(
                        loanId: loanId,
                        currentRemainingBalance: currentRemainingBalance,
                      ),
                    ),
                  );
                },
                child: const Text('Make a Payment'),
              ),
              const SizedBox(height: 16),

              // Update Client Profile
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  ProfileScreen()),
                  );
                },
                child: const Text('Update Profile'),

              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // Admin Home Layout
  // =========================
  Widget _buildAdminHome(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // View Loan Dashboard (e.g., outstanding loans, loan requests)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  DashboardScreen()),
                  );
                },
                child: const Text('View Loan Dashboard'),
              ),
              const SizedBox(height: 16),

              // Manage Clients (placeholder for admin to manage client data, roles, etc.)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  ManageClientsScreen()),
                  );
                },
                child: const Text('Manage Clients'),
              ),
              const SizedBox(height: 16),

              // Additional Admin Functionality:
              // e.g., loan analytics, system settings, etc.
              ElevatedButton(
                onPressed: () {
                  // Placeholder for an analytics screen or advanced settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Admin analytics/settings coming soon')),
                  );
                },
                child: const Text('Analytics / Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
