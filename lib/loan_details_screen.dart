import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoanDetailsScreen extends StatelessWidget {
  final String loanId;

  const LoanDetailsScreen({Key? key, required this.loanId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DocumentReference loanRef =
        FirebaseFirestore.instance.collection('loans').doc(loanId);

    return Scaffold(
      appBar: AppBar(title: const Text("Loan Details")),
      body: FutureBuilder<DocumentSnapshot>(
        future: loanRef.get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final double remainingBalance =
              (data['remainingBalance'] ?? 0).toDouble();
          final double loanAmount = (data['loanAmount'] ?? 0).toDouble();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title:
                    Text('Loan Amount: DOP ${loanAmount.toStringAsFixed(2)}'),
                subtitle: Text(
                    'Remaining Balance: DOP ${remainingBalance.toStringAsFixed(2)}'),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Payments:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: loanRef
                      .collection('payments')
                      .orderBy('paymentDate', descending: true)
                      .snapshots(),
                  builder: (context, paymentSnapshot) {
                    if (paymentSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${paymentSnapshot.error}'));
                    }
                    if (!paymentSnapshot.hasData ||
                        paymentSnapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No payments found.'));
                    }
                    final payments = paymentSnapshot.data!.docs;
                    return ListView.builder(
                      itemCount: payments.length,
                      itemBuilder: (context, index) {
                        final paymentData =
                            payments[index].data() as Map<String, dynamic>;
                        final amount = paymentData['paymentAmount'] ?? 0;
                        final Timestamp? timestamp = paymentData['paymentDate'];
                        final paymentDate = timestamp != null
                            ? timestamp.toDate().toLocal().toString()
                            : 'Pending';
                        return ListTile(
                          title: Text('Paid: DOP $amount'),
                          subtitle: Text('Date: $paymentDate'),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
