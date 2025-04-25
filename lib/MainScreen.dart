import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loginScreen.dart'; // Import the login screen for redirection

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // You can perform additional initialization here if needed
  }

  // Logout function
  void logout() async {
    if (user != null) {
      try {
        // Delete user document from Firestore (if any)
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).delete();
      } catch (e) {
        debugPrint("Failed to delete user document: $e");
      }

      // Sign out from Google if the user logged in with Google
      final providerData = user!.providerData;
      for (final provider in providerData) {
        if (provider.providerId == 'google.com') {
          await GoogleSignIn().signOut();
          break;
        }
      }

      // Sign out from Firebase Authentication
      await FirebaseAuth.instance.signOut();
    }

    if (!mounted) return;

    // Navigate to login screen after logging out
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) =>  loginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen'),
      ),
      body: Center(
        child: Container(
          color: Colors.green,
          child: const Center(
            child: Text(
              'Main Screen Content',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
        ),
      ),
      // Floating action button to log out
      floatingActionButton: FloatingActionButton(
        onPressed: logout, // Call logout on button press
        backgroundColor: Colors.red,
        child: const Icon(Icons.logout),
      ),
    );
  }
}
