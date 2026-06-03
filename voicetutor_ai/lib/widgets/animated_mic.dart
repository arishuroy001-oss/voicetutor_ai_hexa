import 'package:flutter/material.dart';

class AnimatedMic extends StatefulWidget {
  final bool isListening;
  final bool isSpeaking;
  final bool isGenerating;
  final bool isEvaluating;

  const AnimatedMic({
    super.key,
    this.isListening = false,
    this.isSpeaking = false,
    this.isGenerating = false,
    this.isEvaluating = false,
  });

  @override
  State<AnimatedMic> createState() => _AnimatedMicState();
}

class _AnimatedMicState extends State<AnimatedMic>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _pulseAnim;
  late Animation<double> _rippleAnim;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rippleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  bool get _isActive =>
      widget.isListening ||
      widget.isSpeaking ||
      widget.isGenerating ||
      widget.isEvaluating;

  Color get _primaryColor {
    if (widget.isListening) return const Color(0xFF10B981);
    if (widget.isSpeaking) return const Color(0xFF6366F1);
    if (widget.isGenerating || widget.isEvaluating) return Colors.orange;
    return const Color(0xFF9CA3AF); // Idle grey
  }

  IconData get _icon {
    if (widget.isSpeaking) return Icons.volume_up_rounded;
    if (widget.isGenerating) return Icons.auto_awesome_rounded;
    if (widget.isEvaluating) return Icons.psychology_rounded;
    return Icons.mic_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final color = _primaryColor;

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnim, _rippleAnim]),
      builder: (_, __) {
        return SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ripple ring (only when active)
              if (_isActive && widget.isListening)
                Opacity(
                  opacity: (1 - _rippleAnim.value).clamp(0.0, 1.0),
                  child: Container(
                    width: 180 + (_rippleAnim.value * 60),
                    height: 180 + (_rippleAnim.value * 60),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                  ),
                ),

              // Outer glow circle
              Transform.scale(
                scale: _isActive ? _pulseAnim.value : 1.0,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.12),
                  ),
                ),
              ),

              // Inner circle
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: _isActive
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 24,
                            spreadRadius: 4,
                          )
                        ]
                      : [],
                ),
                child: Icon(
                  _icon,
                  size: 52,
                  color: Colors.white,
                ),
              ),

              // Generating spinner ring
              if (widget.isGenerating || widget.isEvaluating)
                SizedBox(
                  width: 148,
                  height: 148,
                  child: CircularProgressIndicator(
                    color: color.withOpacity(0.6),
                    strokeWidth: 3,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
