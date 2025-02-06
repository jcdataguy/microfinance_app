import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoanApplicationScreen extends StatefulWidget {
  @override
  _LoanApplicationScreenState createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the form fields
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();

  // We'll use a simple dropdown for repayment term
  String _selectedTerm = 'Weekly';

  // Example function to handle form submission
  void _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      String amountText = _amountController.text.trim();
      String purpose = _purposeController.text.trim();
      String term = _selectedTerm;

      // Convert the amount to an integer.
      final int? amount = int.tryParse(amountText);
      if (amount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid amount entered.')),
        );
        return;
      }

      // Prepare the data to save.
      final Map<String, dynamic> applicationData = {
        'amount': amount,
        'purpose': purpose,
        'repaymentTerm': term,
        'submittedAt': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser?.uid,
      };

      try {
        // Add the data to the 'loanApplications' collection.
        await FirebaseFirestore.instance
            .collection('loanApplications')
            .add(applicationData);

        // Provide feedback to the user.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Loan Application Submitted and Saved!')),
        );

        // Optionally, clear the form.
        _formKey.currentState!.reset();
        _amountController.clear();
        _purposeController.clear();
        setState(() {
          _selectedTerm = 'Weekly';
        });
      } catch (e) {
        print('Error submitting application: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting application')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apply for a Loan'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Loan Amount Field
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Loan Amount (DOP)',
                    hintText: 'Enter an amount between 10,000 and 50,000',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a loan amount';
                    }
                    // Optionally: validate that the amount is within the allowed range.
                    final amount = int.tryParse(value);
                    if (amount == null || amount < 10000 || amount > 50000) {
                      return 'Amount must be between 10,000 and 50,000';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Loan Purpose Field
                TextFormField(
                  controller: _purposeController,
                  decoration: InputDecoration(
                    labelText: 'Loan Purpose',
                    hintText: 'What is the loan for?',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a purpose for the loan';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Repayment Term Dropdown
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Repayment Term',
                    border: OutlineInputBorder(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedTerm,
                      items: <String>['Weekly', 'Biweekly', 'Monthly']
                          .map((String term) {
                        return DropdownMenuItem<String>(
                          value: term,
                          child: Text(term),
                        );
                      }).toList(),
                      onChanged: (String? newTerm) {
                        setState(() {
                          _selectedTerm = newTerm!;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 24),
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitApplication,
                    child: Text('Submit Application'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
