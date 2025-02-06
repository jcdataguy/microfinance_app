import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoanPaymentScreen extends StatefulWidget {
  // The loan document ID and current remaining balance are passed in.
  final String loanId;
  final double currentRemainingBalance;

  const LoanPaymentScreen({
    Key? key,
    required this.loanId,
    required this.currentRemainingBalance,
  }) : super(key: key);

  @override
  _LoanPaymentScreenState createState() => _LoanPaymentScreenState();
}

class _LoanPaymentScreenState extends State<LoanPaymentScreen> {
  final TextEditingController _paymentController = TextEditingController();
  bool _isProcessing = false;

  Future<void> _submitPayment() async {
    // Validate payment amount.
    final double? paymentAmount =
        double.tryParse(_paymentController.text.trim());
    if (paymentAmount == null || paymentAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid payment amount.")),
      );
      return;
    }

    // Check if payment exceeds remaining balance.
    if (paymentAmount > widget.currentRemainingBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment exceeds the remaining balance.")),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Reference to the loan document.
      final DocumentReference loanRef =
          FirebaseFirestore.instance.collection('loans').doc(widget.loanId);

      // Run a transaction to update the loan and add the payment record.
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Retrieve the latest loan data.
        DocumentSnapshot loanSnapshot = await transaction.get(loanRef);
        if (!loanSnapshot.exists) {
          throw Exception("Loan not found!");
        }
        double currentBalance =
            (loanSnapshot.get('remainingBalance') ?? 0).toDouble();

        // Ensure payment does not exceed current balance.
        if (paymentAmount > currentBalance) {
          throw Exception("Payment exceeds the remaining balance.");
        }
        double newBalance = currentBalance - paymentAmount;

        // Update the loan's remaining balance.
        transaction.update(loanRef, {'remainingBalance': newBalance});

        // Add a new payment record to the 'payments' subcollection.
        final DocumentReference paymentRef =
            loanRef.collection('payments').doc();
        transaction.set(paymentRef, {
          'paymentAmount': paymentAmount,
          'paymentDate': FieldValue.serverTimestamp(),
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment processed successfully.")),
      );
      _paymentController.clear();
      // Optionally, update local state or navigate as needed.
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment failed: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Loan Payment"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display current remaining balance.
            Text(
              "Remaining Balance: DOP ${widget.currentRemainingBalance.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _paymentController,
              decoration: const InputDecoration(
                labelText: 'Payment Amount (DOP)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _isProcessing
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitPayment,
                      child: const Text("Submit Payment"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
