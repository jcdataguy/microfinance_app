import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // Controllers for basic info
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();

  // Controllers for authentication
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Referral information with default value
  String _referral = 'Social Media';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Date picker for date of birth
  Future<void> _selectDate() async {
    DateTime initialDate = DateTime(2000, 1, 1);
    DateTime firstDate = DateTime(1900);
    DateTime lastDate = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (pickedDate != null) {
      setState(() {
        // Format: YYYY-MM-DD
        _dobController.text = pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String name = _nameController.text.trim();
    final String address = _addressController.text.trim();
    final String dob = _dobController.text.trim();
    final String cedula = _cedulaController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      // Create the user in Firebase Authentication.
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final String userId = userCredential.user!.uid;

      // Create a user document in Firestore with default role "client"
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'name': name,
        'address': address,
        'dob': dob,
        'cedula': cedula,
        'referral': _referral,
        'email': email,
        'role': 'client', // default role for new registrations
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );
      Navigator.pop(context); // Return to the LoginScreen.
    } on FirebaseAuthException catch (e) {
      print('Registration Firestore error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Full Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your name'
                    : null,
              ),
              const SizedBox(height: 16),
              // Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your address'
                    : null,
              ),
              const SizedBox(height: 16),
              // Date of Birth with Date Picker
              TextFormField(
                controller: _dobController,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDate,
                  ),
                ),
                readOnly: true,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select your date of birth'
                    : null,
              ),
              const SizedBox(height: 16),
              // Cedula (ID)
              TextFormField(
                controller: _cedulaController,
                decoration: const InputDecoration(
                  labelText: 'Cedula (ID)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your Cedula'
                    : null,
              ),
              const SizedBox(height: 16),
              // Referral: How did you learn about us? (Dropdown)
              DropdownButtonFormField<String>(
                value: _referral,
                decoration: const InputDecoration(
                  labelText: 'How did you learn about us?',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'Social Media', child: Text('Social Media')),
                  DropdownMenuItem(
                      value: 'Friend/Family', child: Text('Friend/Family')),
                  DropdownMenuItem(
                      value: 'Advertisement', child: Text('Advertisement')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _referral = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your email'
                    : null,
              ),
              const SizedBox(height: 16),
              // Password
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your password'
                    : null,
              ),
              const SizedBox(height: 16),
              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please confirm your password'
                    : null,
              ),
              const SizedBox(height: 24),
              // Register Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _register,
                  child: const Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
