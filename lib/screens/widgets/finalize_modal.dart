  // lib/screens/widgets/finalize_modal.dart
  import 'package:flutter/material.dart';
  import 'package:intl/intl.dart';

  class FinalizeModalResult {
    final DateTime selectedDate;

    FinalizeModalResult({required this.selectedDate});
  }

  class FinalizeModal extends StatefulWidget {
    const FinalizeModal({super.key});

    @override
    State<FinalizeModal> createState() => _FinalizeModalState();
  }

  class _FinalizeModalState extends State<FinalizeModal> with TickerProviderStateMixin {
    DateTime _selectedDate = DateTime.now();
    late AnimationController _animationController;
    late Animation<double> _fadeAnimation;
    late Animation<Offset> _slideAnimation;
    late Animation<double> _scaleAnimation;
    late AnimationController _staggerController;
    late List<Animation<double>> _staggerAnimations;

    @override
    void initState() {
      super.initState();
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );
      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      );
      _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      );
      _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
      );

      _staggerController = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
      _staggerAnimations = List.generate(4, (index) {
        return Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(index * 0.15, 1.0, curve: Curves.easeOut),
          ),
        );
      });

      _animationController.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        _staggerController.forward();
      });
    }

    @override
    void dispose() {
      _animationController.dispose();
      _staggerController.dispose();
      super.dispose();
    }

    Future<void> _pickDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData(
              colorScheme: const ColorScheme.light(
                primary: Colors.black,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
              dialogTheme: const DialogThemeData(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(28)),
                ),
              ),
              textTheme: const TextTheme(
                headlineSmall: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.black,
                ),
                bodyLarge: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        setState(() {
          _selectedDate = picked;
        });
      }
    }

    @override
    Widget build(BuildContext context) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(36),
              ),
              backgroundColor: Colors.white,
              elevation: 20,
              shadowColor: Colors.black.withValues(alpha: 0.25),
              child: Container(
                padding: const EdgeInsets.all(32),
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ultra-premium title with staggered animation
                    FadeTransition(
                      opacity: _staggerAnimations[0],
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(_staggerAnimations[0]),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.verified_outlined,
                              size: 32,
                              color: Colors.black.withValues(alpha: 0.85),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Finalizar Movimentação',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                color: Colors.black,
                                letterSpacing: 0.6,
                                height: 1.0,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Elegant animated divider
                    FadeTransition(
                      opacity: _staggerAnimations[1],
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.0),
                              Colors.black.withValues(alpha: 0.2),
                              Colors.black.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Data label with staggered animation
                    FadeTransition(
                      opacity: _staggerAnimations[2],
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(-0.1, 0), end: Offset.zero).animate(_staggerAnimations[2]),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Selecionar Data',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Colors.black.withValues(alpha: 0.95),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Ultra-premium date picker field with staggered animation
                    FadeTransition(
                      opacity: _staggerAnimations[3],
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(_staggerAnimations[3]),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(28),
                            splashColor: Colors.black.withValues(alpha: 0.08),
                            highlightColor: Colors.black.withValues(alpha: 0.05),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 22,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: Colors.black.withValues(alpha: 0.25), width: 2.5),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 40,
                                    offset: const Offset(0, 16),
                                  ),
                                ],
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.black.withValues(alpha: 0.01),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_view_day_rounded,
                                          size: 26,
                                          color: Colors.black.withValues(alpha: 0.85),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            DateFormat('EEEE, dd/MM/yyyy', 'pt_BR').format(_selectedDate),
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                              letterSpacing: 0.4,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.expand_more,
                                    size: 26,
                                    color: Colors.black.withValues(alpha: 0.7),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    // Ultra-premium action buttons with staggered animation
                    FadeTransition(
                      opacity: _staggerAnimations[3],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(null),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black.withValues(alpha: 0.75),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                letterSpacing: 0.4,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              overlayColor: Colors.black.withValues(alpha: 0.08),
                            ),
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () {
                              // Retorna o resultado correto para o scanner_screen
                              Navigator.of(context).pop(
                                FinalizeModalResult(selectedDate: _selectedDate),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: 0.4,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              overlayColor: Colors.white.withValues(alpha: 0.15),
                            ).copyWith(
                              backgroundColor: WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.pressed)) {
                                    return Colors.black.withValues(alpha: 0.85);
                                  }
                                  return Colors.black;
                                },
                              ),
                              shadowColor: WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.hovered)) {
                                    return Colors.black.withValues(alpha: 0.2);
                                  }
                                  return Colors.transparent;
                                },
                              ),
                            ),
                            child: const Text('Confirmar'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }