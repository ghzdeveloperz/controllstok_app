import 'package:flutter/material.dart';

class BlockingLoader {
  static Future<T> run<T>({
    required BuildContext context,
    required Future<T> Function() action,
    String message = 'Carregando...',
  }) async {
    // ✅ pega o nav antes do await (não usa context depois)
    final nav = Navigator.of(context, rootNavigator: true);

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => _BlockingLoaderDialog(message: message),
    );

    try {
      final result = await action();
      return result;
    } finally {
      if (nav.canPop()) {
        nav.pop();
      }
    }
  }
}

class _BlockingLoaderDialog extends StatelessWidget {
  final String message;
  const _BlockingLoaderDialog({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 290,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.6),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
