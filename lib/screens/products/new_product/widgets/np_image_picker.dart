// lib/screens/products/new_product/widgets/np_image_picker.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NPImagePicker extends StatelessWidget {
  final File? image;
  final VoidCallback onTap;

  // ✅ l10n
  final String emptyText;

  const NPImagePicker({
    super.key,
    required this.image,
    required this.onTap,
    this.emptyText = 'Adicionar imagem',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            image: image != null
                ? DecorationImage(
                    image: FileImage(image!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: image == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 32,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      emptyText,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                )
              : null,
        ),
      ),
    );
  }
}
