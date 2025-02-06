import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageClientsScreen extends StatefulWidget {
  const ManageClientsScreen({Key? key}) : super(key: key);

  @override
  _ManageClientsScreenState createState() => _ManageClientsScreenState();
}

class _ManageClientsScreenState extends State<ManageClientsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  // Promotes or demotes a user by updating the 'role' field in their Firestore doc
  Future<void> _updateUserRole(String userId, String newRole) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated user role to "$newRole"')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user role: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Optional: you might navigate to a detailed profile view
  // Future<void> _viewClientProfile(String userId) async {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => ClientProfileViewScreen(userId: userId),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Clients'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final usersDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: usersDocs.length,
            itemBuilder: (context, index) {
              final userDoc = usersDocs[index];
              final data = userDoc.data() as Map<String, dynamic>;
              final userId = userDoc.id;
              final name = data['name'] ?? 'No Name';
              final email = data['email'] ?? 'No Email';
              final role = data['role'] ?? 'client';

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  title: Text('$name  (Role: $role)'),
                  subtitle: Text(email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // If user is client, show a button to promote
                      if (role == 'client')
                        TextButton(
                          onPressed: () =>
                              _updateUserRole(userId, 'admin'),
                          child: const Text('Promote to Admin'),
                        ),
                      // If user is admin, show a button to revert to client
                      if (role == 'admin')
                        TextButton(
                          onPressed: () =>
                              _updateUserRole(userId, 'client'),
                          child: const Text(
                            'Revert to Client',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    // Example: view client details
                    // _viewClientProfile(userId);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
