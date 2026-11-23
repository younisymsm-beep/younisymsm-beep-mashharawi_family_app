import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
            tooltip: 'تسجيل الخروج',
          )
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const CircleAvatar(radius: 50, backgroundColor: Colors.teal, child: Icon(Icons.person, size: 50, color: Colors.white)),
                const SizedBox(height: 16),
                Text(data['fullName'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text('الفرع: ${data['branch'] ?? ''}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 20),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.phone, color: Colors.teal),
                    title: const Text('رقم الجوال'),
                    subtitle: Text(data['phone'] ?? ''),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.email, color: Colors.teal),
                    title: const Text('البريد الإلكتروني'),
                    subtitle: Text(data['email'] ?? ''),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
