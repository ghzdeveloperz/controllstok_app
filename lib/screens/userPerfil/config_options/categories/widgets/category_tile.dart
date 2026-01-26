import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryTile extends StatelessWidget {
  final String name;
  final VoidCallback onDelete;

  const CategoryTile({
    super.key,
    required this.name,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.category_outlined,
            color: Colors.white,
            size: 28,
          ),
        ),
        title: Text(
          name,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 28),
          color: Colors.black.withValues(alpha: 0.7),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
