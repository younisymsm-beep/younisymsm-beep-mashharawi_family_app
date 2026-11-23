import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _branchController = TextEditingController();

  Future<void> _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({
          'uid': userCred.user!.uid,
          'fullName': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'branch': _branchController.text.trim(),
          'email': _emailController.text.trim(),
          'photoUrl': '',
          'bio': 'فرد من عائلة المشهراوي',
          'isApproved': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'حدث خطأ أثناء المصادقة'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.family_restroom, size: 70, color: Colors.teal),
                    const SizedBox(height: 10),
                    const Text(
                      'ملتقى عائلة المشهراوي',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                    const SizedBox(height: 20),
                    if (!isLogin) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'الاسم الرباعي', border: OutlineInputBorder()),
                        validator: (val) => val!.isEmpty ? 'يرجى إدخال الاسم' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _branchController,
                        decoration: const InputDecoration(labelText: 'الفرع / الجد', border: OutlineInputBorder()),
                        validator: (val) => val!.isEmpty ? 'يرجى تحديد الفرع' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'رقم الجوال', border: OutlineInputBorder()),
                        validator: (val) => val!.isEmpty ? 'يرجى إدخال رقم الجوال' : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'البريد الإلكتروني', border: OutlineInputBorder()),
                      validator: (val) => !val!.contains('@') ? 'بريد إلكتروني غير صحيح' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'كلمة المرور', border: OutlineInputBorder()),
                      validator: (val) => val!.length < 6 ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل' : null,
                    ),
                    const SizedBox(height: 20),
                    if (isLoading)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _submitAuthForm,
                        child: Text(isLogin ? 'تسجيل الدخول' : 'إنشاء حساب جديد', style: const TextStyle(fontSize: 16)),
                      ),
                    TextButton(
                      onPressed: () => setState(() => isLogin = !isLogin),
                      child: Text(isLogin ? 'ليس لديك حساب؟ انضم للعائلة الآن' : 'لديك حساب بالفعل؟ سجل دخولك'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
