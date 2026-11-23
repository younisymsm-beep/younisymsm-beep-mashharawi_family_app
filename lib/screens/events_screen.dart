import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _locationController = TextEditingController();
  String _eventType = 'اجتماع عائلي';

  Future<void> _addEvent() async {
    if (_titleController.text.trim().isEmpty) return;
    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection('events').add({
      'title': _titleController.text.trim(),
      'date': _dateController.text.trim(),
      'location': _locationController.text.trim(),
      'type': _eventType,
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _titleController.clear();
    _dateController.clear();
    _locationController.clear();
    if (mounted) Navigator.pop(context);
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة مناسبة عائلية'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'عنوان المناسبة')),
              TextField(controller: _dateController, decoration: const InputDecoration(labelText: 'التاريخ والوقت')),
              TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'المكان / الديوان')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _eventType,
                items: ['اجتماع عائلي', 'فرح / زواج', 'عزاء', 'تهنئة'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _eventType = v!),
                decoration: const InputDecoration(labelText: 'نوع المناسبة'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(onPressed: _addEvent, child: const Text('حفظ')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مناسبات العائلة'), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _showAddEventDialog,
        child: const Icon(Icons.event_available, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final events = snapshot.data!.docs;
          if (events.isEmpty) return const Center(child: Text('لا توجد مناسبات مسجلة حالياً'));
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final data = events[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.calendar_today, color: Colors.white)),
                  title: Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('التاريخ: ${data['date'] ?? ''}\nالمكان: ${data['location'] ?? ''}'),
                  trailing: Chip(label: Text(data['type'] ?? '')),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
