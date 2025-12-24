import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../firebase/firestore/categories_firestore.dart';
import '../models/category.dart';
import '../login_screen.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  late final String _uid;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Future.microtask(() {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
          );
        }
      });
      return;
    }

    _uid = user.uid;
  }

  // ================= ADD CATEGORY =================
  void _showAddCategoryDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nova Categoria'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nome da categoria',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              await CategoriesFirestore.addCategory(
                userLogin: _uid,
                name: name,
              );

              if (!mounted) return;
              Navigator.pop(dialogContext);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  // ================= ALERT =================
  void _showCategoryInUseAlert(String categoryName) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Não é possível excluir'),
        content: Text(
          'A categoria "$categoryName" não pode ser excluída porque existem produtos vinculados a ela.',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  // ================= DELETE =================
  void _confirmDelete({
    required String categoryId,
    required String categoryName,
  }) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir categoria'),
        content: Text(
          'Deseja excluir a categoria "$categoryName"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final deleted = await CategoriesFirestore.deleteCategory(
                userLogin: _uid,
                categoryId: categoryId,
                categoryName: categoryName,
              );

              if (!mounted) return;
              Navigator.pop(dialogContext, deleted);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    ).then((deleted) {
      if (!mounted) return;

      if (deleted == false) {
        _showCategoryInUseAlert(categoryName);
      }
    });
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Categorias'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: _showAddCategoryDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Category>>(
        stream: CategoriesFirestore.streamCategories(_uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data ?? [];

          if (categories.isEmpty) {
            return Center(
              child: Text(
                'Nenhuma categoria criada',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final category = categories[index];

              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                elevation: 3,
                shadowColor: Colors.black12,
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.category_outlined,
                      color: Colors.black87,
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.black54,
                    onPressed: () => _confirmDelete(
                      categoryId: category.id,
                      categoryName: category.name,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
