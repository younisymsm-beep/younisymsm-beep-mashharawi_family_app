import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FamilyChatScreen extends StatefulWidget {
  const FamilyChatScreen({super.key});

  @override
  State<FamilyChatScreen> createState() => _FamilyChatScreenState();
}

class _FamilyChatScreenState extends State<FamilyChatScreen> {
  final _msgController = TextEditingController();

  Future<void> _sendMessage() async {
    if (_msgController.text.trim().isEmpty) return;
    final user = FirebaseAuth.instance.currentUser!;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    await FirebaseFirestore.instance.collection('family_chat').add({
      'senderId': user.uid,
      'senderName': userDoc.data()?['fullName'] ?? 'عضو',
      'text': _msgController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });
    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('ديوانية عائلة المشهراوي'), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('family_chat').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final msgs = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: msgs.length,
                  itemBuilder: (context, index) {
                    final data = msgs[index].data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == myUid;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.teal : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Text(data['senderName'] ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal)),
                            Text(data['text'] ?? '', style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: const InputDecoration(hintText: 'اكتب رسالتك في الديوانية...', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: IconButton(icon: const Icon(Icons.send, color: Colors.white), onPressed: _sendMessage),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
