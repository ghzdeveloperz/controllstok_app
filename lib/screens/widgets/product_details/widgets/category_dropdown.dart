import 'package:flutter/material.dart';

import '../../../../firebase/firestore/categories_firestore.dart';
import '../../../models/category.dart';

class CategoryDropdown extends StatefulWidget {
  final String uid;
  final String initialCategory;
  final ValueChanged<String> onChanged;
  final String label;

  const CategoryDropdown({
    super.key,
    required this.uid,
    required this.initialCategory,
    required this.onChanged,
    required this.label,
  });

  @override
  State<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  String _selected = '';

  @override
  void initState() {
    super.initState();
    _selected = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Category>>(
      stream: CategoriesFirestore.streamCategories(widget.uid),
      builder: (context, snapshot) {
        final categories = snapshot.data?.map((c) => c.name).toList() ?? [];

        if (categories.isNotEmpty && !categories.contains(_selected)) {
          _selected = categories.first;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onChanged(_selected);
          });
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: categories.isEmpty ? null : _selected,
                  items: categories
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() => _selected = val);
                    widget.onChanged(val);
                  },
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: InputBorder.none,
                  ),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
