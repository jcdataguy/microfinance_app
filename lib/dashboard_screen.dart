import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loan Applications Dashboard'),
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
            return Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(child: Text('No loan applications found.'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final amount = data['amount'];
              final purpose = data['purpose'];
              final term = data['repaymentTerm'];
              final submittedAtTimestamp = data['submittedAt'];
              DateTime submittedAt = submittedAtTimestamp != null
                  ? (submittedAtTimestamp as Timestamp).toDate()
                  : DateTime.now();
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text("Amount: DOP $amount"),
                  subtitle: Text(
                    "Purpose: $purpose\nTerm: $term\nSubmitted: ${submittedAt.toLocal()}",
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
