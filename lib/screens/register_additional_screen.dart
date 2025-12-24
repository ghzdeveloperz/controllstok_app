// lib/screens/register_additional_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class RegisterAdditionalScreen extends StatefulWidget {
  final User user;
  const RegisterAdditionalScreen({super.key, required this.user});

  @override
  State<RegisterAdditionalScreen> createState() =>
      _RegisterAdditionalScreenState();
}

class _RegisterAdditionalScreenState extends State<RegisterAdditionalScreen> {
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  bool isLoading = false;

  Future<void> handleFinish() async {
    if (_nameController.text.isEmpty || _companyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Aqui você pode salvar name + company no Firestore
    // Exemplo:
    // await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).set({
    //   'name': _nameController.text.trim(),
    //   'company': _companyController.text.trim(),
    // });

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dados adicionais")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: "Como podemos te chamar?",
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _companyController,
                decoration: const InputDecoration(
                  hintText: "Nome da empresa",
                  prefixIcon: Icon(Icons.business_outlined),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleFinish,
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text("Finalizar cadastro"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
