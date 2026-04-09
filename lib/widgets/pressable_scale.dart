import 'package:flutter/material.dart';

class PressableScale extends StatefulWidget {
  const PressableScale({super.key, required this.child, required this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.95 : 1,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            boxShadow: _down
                ? [const BoxShadow(color: Color(0x14000000), blurRadius: 2, offset: Offset(0, 1))]
                : [const BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
