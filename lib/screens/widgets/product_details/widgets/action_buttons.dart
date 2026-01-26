import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const ActionButtons._({
    required this.label,
    required this.onPressed,
    required this.loading,
  });

  factory ActionButtons.save({
    required String label,
    required bool saving,
    required VoidCallback? onPressed,
  }) {
    return ActionButtons._(label: label, onPressed: onPressed, loading: saving);
  }

  factory ActionButtons.delete({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ActionButtons._(label: label, onPressed: onPressed, loading: false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: Colors.black.withValues(alpha: 0.3),
            ),
            onPressed: onPressed,
            child: loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
