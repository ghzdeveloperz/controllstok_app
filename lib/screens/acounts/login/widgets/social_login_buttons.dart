import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef AsyncVoidCallback = Future<void> Function();

class SocialLoginButtons extends StatelessWidget {
  final bool isDisabled;
  final AsyncVoidCallback onGoogleTap;
  final AsyncVoidCallback onAppleTap;

  const SocialLoginButtons({
    super.key,
    required this.isDisabled,
    required this.onGoogleTap,
    required this.onAppleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PressableButton(
            isDisabled: isDisabled,
            onTap: onGoogleTap,
            child: _GoogleContent(isDisabled: isDisabled),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PressableButton(
            isDisabled: isDisabled,
            onTap: onAppleTap,
            child: _AppleContent(isDisabled: isDisabled),
          ),
        ),
      ],
    );
  }
}

/// ✅ Wrapper genérico com animação de "press"
class _PressableButton extends StatefulWidget {
  final bool isDisabled;
  final AsyncVoidCallback onTap;
  final Widget child;

  const _PressableButton({
    required this.isDisabled,
    required this.onTap,
    required this.child,
  });

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  bool _pressed = false;
  bool _busy = false;

  void _down(_) {
    if (widget.isDisabled || _busy) return;
    setState(() => _pressed = true);
  }

  Future<void> _up(_) async {
    if (widget.isDisabled || _busy) return;

    setState(() {
      _pressed = false;
      _busy = true;
    });

    try {
      await widget.onTap();
    } finally {
      if (!mounted) return;
      setState(() => _busy = false);
    }
  }

  void _cancel() {
    if (widget.isDisabled || _busy) return;
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.isDisabled || _busy;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: disabled ? null : _down,
      onTapUp: disabled ? null : _up,
      onTapCancel: disabled ? null : _cancel,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        scale: (_pressed && !disabled) ? 0.97 : 1.0,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 120),
          opacity: disabled ? 0.65 : 1,
          child: widget.child,
        ),
      ),
    );
  }
}

class _AppleContent extends StatelessWidget {
  final bool isDisabled;
  const _AppleContent({required this.isDisabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.string(
            _appleSvg,
            height: 18,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            "Entre com Apple",
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleContent extends StatelessWidget {
  final bool isDisabled;
  const _GoogleContent({required this.isDisabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF747474), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.string(_googleSvg, height: 18),
          const SizedBox(width: 8),
          const Text(
            "Entre com Google",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

const String _appleSvg = '''
<svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
<path d="M747.4 535.7c-.4-68.2 30.5-119.6 92.9-157.5-34.9-50-87.7-77.5-157.3-82.8-65.9-5.2-138 38.4-164.4 38.4-27.9 0-91.7-36.6-141.9-36.6C273.1 298.8 163 379.8 163 544.6c0 48.7 8.9 99 26.7 150.8 23.8 68.2 109.6 235.3 199.1 232.6 46.8-1.1 79.9-33.2 140.8-33.2 59.1 0 89.7 33.2 141.9 33.2 90.3-1.3 167.9-153.2 190.5-221.6-121.1-57.1-114.6-167.2-114.6-170.7zm-105.1-305c50.7-60.2 46.1-115 44.6-134.7-44.8 2.6-96.6 30.5-126.1 64.8-32.5 36.8-51.6 82.3-47.5 133.6 48.4 3.7 92.6-21.2 129-63.7z"/>
</svg>
''';

const String _googleSvg = '''
<svg viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">
<path fill="#000000" d="M43.611,20.083H24v8h11.303c-1.649,4.657-6.08,8-11.303,8c-6.627,0-12-5.373-12-12c0-6.627,5.373-12,12-12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C12.955,4,4,12.955,4,24c0,11.045,8.955,20,20,20c11.045,0,20-8.955,20-20c0-1.341-0.138-2.65-0.389-3.917z"/>
</svg>
''';
