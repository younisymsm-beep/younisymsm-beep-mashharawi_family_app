import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دليل أفراد العائلة'), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').orderBy('fullName').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final users = snapshot.data!.docs;
          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final data = users[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.person, color: Colors.white)),
                title: Text(data['fullName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('الفرع: ${data['branch'] ?? 'غير محدد'} | جوال: ${data['phone'] ?? ''}'),
              );
            },
          );
        },
      ),
    );
  }
}
