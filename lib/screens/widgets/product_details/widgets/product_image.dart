import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final bool loading;
  final bool error;
  final Widget? child;

  const ProductImage({
    super.key,
    required this.loading,
    required this.error,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: loading
              ? Container(
                  color: Colors.grey.shade100,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 3, color: Colors.grey),
                  ),
                )
              : error
                  ? Container(
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
                      ),
                    )
                  : child,
        ),
      ),
    );
  }
}
