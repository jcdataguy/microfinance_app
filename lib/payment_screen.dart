import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  // For simulation, we'll pass the amount to be paid.
  final int loanAmount;

  const PaymentScreen({Key? key, required this.loanAmount}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isProcessing = false;
  String paymentStatus = '';

  // This function simulates a payment process.
  void _simulatePayment() async {
    setState(() {
      isProcessing = true;
      paymentStatus = '';
    });

    // Simulate network delay / payment processing time.
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      isProcessing = false;
      paymentStatus = 'Payment Successful for DOP ${widget.loanAmount}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make a Payment'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Loan Amount: DOP ${widget.loanAmount}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              isProcessing
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _simulatePayment,
                      child: Text('Pay Now'),
                    ),
              SizedBox(height: 20),
              Text(
                paymentStatus,
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
