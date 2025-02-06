import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Future<void> _updateLoanStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('loanApplications')
          .doc(docId)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loan marked as $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('loanApplications')
            .orderBy('submittedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No applications found'));
          }

          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final docId = doc.id;
              final amount = data['amount'] ?? 0;
              final purpose = data['purpose'] ?? 'N/A';
              final status = data['status'] ?? 'pending';
              final term = data['repaymentTerm'] ?? '';
              final submittedAt = data['submittedAt'];
              final submissionDate = submittedAt != null
                  ? (submittedAt as Timestamp).toDate()
                  : null;

              return Card(
                margin: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: ListTile(
                  title: Text('Amount: DOP $amount  |  Status: $status'),
                  subtitle: Text(
                    'Purpose: $purpose\n'
                    'Term: $term\n'
                    'Submitted: ${submissionDate?.toLocal() ?? 'N/A'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (status == 'pending') ...[
                        TextButton(
                          onPressed: () => _updateLoanStatus(docId, 'approved'),
                          child: const Text('Approve'),
                        ),
                        TextButton(
                          onPressed: () => _updateLoanStatus(docId, 'rejected'),
                          child: const Text(
                            'Reject',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
