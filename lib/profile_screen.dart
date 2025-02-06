import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();

  // The referral field is handled with a dropdown.
  // We'll keep the default in case Firestore has no saved value.
  String _referral = 'Social Media';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  // Fetch current user data from Firestore
  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        _nameController.text = data['name'] ?? '';
        _addressController.text = data['address'] ?? '';
        _dobController.text = data['dob'] ?? '';
        _cedulaController.text = data['cedula'] ?? '';
        if (data['referral'] != null) {
          _referral = data['referral'] as String;
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Update user data in Firestore
  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'dob': _dobController.text.trim(),
        'cedula': _cedulaController.text.trim(),
        'referral': _referral,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
        _dobController.text = pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Address
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // DOB with date picker
            TextField(
              controller: _dobController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _selectDate,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Cedula
            TextField(
              controller: _cedulaController,
              decoration: const InputDecoration(
                labelText: 'Cedula',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Referral
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
            const SizedBox(height: 24),
            // Update Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateProfile,
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
