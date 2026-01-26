import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../acounts/login/login_screen.dart';
import '../../../models/category.dart';
import '../../../../firebase/firestore/categories_firestore.dart';

import 'dialogs/add_category_dialog.dart';
import 'dialogs/category_in_use_dialog.dart';
import 'dialogs/delete_category_dialog.dart';
import 'widgets/category_tile.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  String? _uid;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Future.microtask(() {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      });
      return;
    }

    _uid = user.uid;
  }

  Future<void> _openAddDialog() async {
    final uid = _uid;
    if (uid == null) return;

    final name = await showAddCategoryDialog(context);
    if (name == null) return;

    await CategoriesFirestore.addCategory(userLogin: uid, name: name);
  }

  Future<void> _confirmDelete({
    required String categoryId,
    required String categoryName,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    final confirmed = await showDeleteCategoryDialog(
      context,
      categoryName: categoryName,
    );

    if (confirmed != true) return;

    final deleted = await CategoriesFirestore.deleteCategory(
      userLogin: uid,
      categoryId: categoryId,
      categoryName: categoryName,
    );

    if (!mounted) return;

    if (deleted == false) {
      await showCategoryInUseDialog(context, categoryName: categoryName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final uid = _uid;

    // se uid não existe, só mostra loader “silencioso” enquanto redireciona
    if (uid == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Colors.black),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          l10n.categoriesTitle,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
        centerTitle: true,
        surfaceTintColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        elevation: 8,
        onPressed: _openAddDialog,
        tooltip: l10n.categoriesAddTooltip,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Category>>(
        stream: CategoriesFirestore.streamCategories(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }

          final categories = snapshot.data ?? [];

          if (categories.isEmpty) {
            return Center(
              child: Text(
                l10n.categoriesEmpty,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.black.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryTile(
                name: category.name,
                onDelete: () => _confirmDelete(
                  categoryId: category.id,
                  categoryName: category.name,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
