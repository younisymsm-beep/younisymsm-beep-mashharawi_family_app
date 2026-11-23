import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final TextEditingController _postController = TextEditingController();
  String _selectedCategory = 'أخبار عامة';
  final List<String> _categories = ['أخبار عامة', 'تهنئة ومناسبات', 'اجتماع عائلي', 'تعزية'];

  Future<void> _createPost() async {
    if (_postController.text.trim().isEmpty) return;
    final user = FirebaseAuth.instance.currentUser!;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    await FirebaseFirestore.instance.collection('posts').add({
      'authorId': user.uid,
      'authorName': userDoc.data()?['fullName'] ?? 'عضو من العائلة',
      'category': _selectedCategory,
      'content': _postController.text.trim(),
      'likes': [],
      'commentsCount': 0,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _postController.clear();
    if (mounted) Navigator.pop(context);
  }

  void _showAddPostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          top: 20, left: 20, right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('إضافة منشور جديد للعائلة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
              decoration: const InputDecoration(labelText: 'تصنيف المنشور', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _postController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'شارك أخبارك أو مناسباتك مع عائلة المشهراوي...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              onPressed: _createPost,
              child: const Text('نشر'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleLike(String postId, List likes) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    if (likes.contains(uid)) {
      await postRef.update({'likes': FieldValue.arrayRemove([uid])});
    } else {
      await postRef.update({'likes': FieldValue.arrayUnion([uid])});
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('أخبار عائلة المشهراوي'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _showAddPostSheet,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final posts = snapshot.data!.docs;

          if (posts.isEmpty) {
            return const Center(child: Text('لا توجد منشورات بعد. كن أول من يشارك!'));
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final data = post.data() as Map<String, dynamic>;
              final List likes = data['likes'] ?? [];
              final bool isLiked = likes.contains(currentUid);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.person, color: Colors.white)),
                              const SizedBox(width: 10),
                              Text(data['authorName'] ?? 'عضو', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          Chip(
                            label: Text(data['category'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.teal)),
                            backgroundColor: Colors.teal.withOpacity(0.1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(data['content'] ?? '', style: const TextStyle(fontSize: 15, height: 1.4)),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton.icon(
                            onPressed: () => _toggleLike(post.id, likes),
                            icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.grey),
                            label: Text('${likes.length} إعجاب'),
                          ),
                          TextButton.icon(
                            onPressed: () => _openCommentsDialog(post.id),
                            icon: const Icon(Icons.comment_outlined, color: Colors.grey),
                            label: Text('${data['commentsCount'] ?? 0} تعليق'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openCommentsDialog(String postId) {
    final commentCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('التعليقات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postId)
                    .collection('comments')
                    .orderBy('timestamp')
                    .snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  return ListView(
                    children: snap.data!.docs.map((doc) {
                      final cData = doc.data() as Map<String, dynamic>;
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(cData['userName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(cData['text'] ?? ''),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 10, right: 10, top: 5),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentCtrl,
                      decoration: const InputDecoration(hintText: 'اكتب تعليقاً...', border: OutlineInputBorder()),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.teal),
                    onPressed: () async {
                      if (commentCtrl.text.trim().isEmpty) return;
                      final user = FirebaseAuth.instance.currentUser!;
                      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
                      await FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').add({
                        'userId': user.uid,
                        'userName': userDoc.data()?['fullName'] ?? 'عضو',
                        'text': commentCtrl.text.trim(),
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
                        'commentsCount': FieldValue.increment(1),
                      });
                      commentCtrl.clear();
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
