// lib/screens/products/new_product/services/new_product_image_service.dart
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class NewProductImageService {
  final String uid;
  final ImagePicker _picker = ImagePicker();

  NewProductImageService({required this.uid});

  Future<File?> pickAndCompress(BuildContext context) async {
    final source = await _showSourceSheet(context);
    if (source == null) return null;

    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked == null) return null;

      final ext = picked.path.split('.').last.toLowerCase();
      if (ext != 'png' && ext != 'jpg' && ext != 'jpeg') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Apenas fotos em PNG e JPG são aceitas.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
        return null;
      }

      final compressed = await _compressImage(File(picked.path));
      return compressed;
    } catch (_) {
      return null;
    }
  }

  Future<ImageSource?> _showSourceSheet(BuildContext context) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Escolher da galeria'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Tirar uma foto'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<File> _compressImage(File file) async {
    final filePath = file.absolute.path;

    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp|.png|.heic'));
    final outPath =
        '${filePath.substring(0, lastIndex)}_compressed${filePath.substring(lastIndex)}';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outPath,
      minWidth: 400,
      quality: 85,
    );

    if (result != null) return File(result.path);
    return file;
  }

  Future<String> upload(File image) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';

    final ref = FirebaseStorage.instance
        .ref()
        .child('users')
        .child(uid)
        .child('products')
        .child(fileName);

    final snapshot = await ref.putFile(image);
    return snapshot.ref.getDownloadURL();
  }
}
