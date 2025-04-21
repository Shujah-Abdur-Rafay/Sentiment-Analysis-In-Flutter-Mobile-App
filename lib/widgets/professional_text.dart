import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/colors.dart';

/// Elegant title with optional underline accent
class ProfessionalTitle extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool showAccent;
  final Color accentColor;
  final double accentHeight;
  final double accentWidth;
  final MainAxisAlignment alignment;
  final double? fontSize;

  const ProfessionalTitle({
    Key? key,
    required this.text,
    this.style,
    this.showAccent = true,
    this.accentColor = AppColors.primary,
    this.accentHeight = 3,
    this.accentWidth = 40,
    this.alignment = MainAxisAlignment.start,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          fontSize: fontSize,
        );

    return Column(
      crossAxisAlignment: alignment == MainAxisAlignment.start
          ? CrossAxisAlignment.start
          : alignment == MainAxisAlignment.end
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: style ?? defaultStyle,
        ),
        if (showAccent) ...[
          const SizedBox(height: 8),
          Container(
            height: accentHeight,
            width: accentWidth,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(accentHeight / 2),
            ),
          ),
        ],
      ],
    );
  }
}

/// Animated gradient text that subtly transitions between colors
class GradientText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final List<Color> colors;
  final Alignment begin;
  final Alignment end;
  final Duration duration;
  final bool animate;

  const GradientText({
    Key? key,
    required this.text,
    this.style,
    this.colors = const [
      AppColors.primary,
      AppColors.secondary,
    ],
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.duration = const Duration(seconds: 3),
    this.animate = true,
  }) : super(key: key);

  @override
  State<GradientText> createState() => _GradientTextState();
}

class _GradientTextState extends State<GradientText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        );

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final colors =
            widget.animate ? List<Color>.from(widget.colors) : widget.colors;

        if (widget.animate) {
          // Subtle rotation of colors based on animation value
          final rotationIndex =
              (_animation.value * (colors.length - 1)).floor();
          if (rotationIndex > 0) {
            final rotatedColors = colors.sublist(rotationIndex)
              ..addAll(colors.sublist(0, rotationIndex));
            colors.clear();
            colors.addAll(rotatedColors);
          }
        }

        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: widget.begin,
            end: widget.end,
            colors: colors,
          ).createShader(bounds),
          child: Text(
            widget.text,
            style: (widget.style ?? defaultStyle)?.copyWith(
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

/// Gentle typing animation for professional presentations
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration typingSpeed;
  final Duration startDelay;
  final bool showCursor;
  final VoidCallback? onComplete;
  final TextAlign textAlign;

  const TypewriterText({
    Key? key,
    required this.text,
    this.style,
    this.typingSpeed = const Duration(milliseconds: 50),
    this.startDelay = const Duration(milliseconds: 500),
    this.showCursor = true,
    this.onComplete,
    this.textAlign = TextAlign.left,
  }) : super(key: key);

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late String _displayText;
  int _currentIndex = 0;
  Timer? _timer;
  Timer? _cursorTimer;
  bool _showCursor = true;

  @override
  void initState() {
    super.initState();
    _displayText = '';

    Future.delayed(widget.startDelay, () {
      _startTyping();
    });

    if (widget.showCursor) {
      _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        if (mounted) {
          setState(() {
            _showCursor = !_showCursor;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  void _startTyping() {
    _timer = Timer.periodic(widget.typingSpeed, (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayText = widget.text.substring(0, _currentIndex + 1);
          _currentIndex++;
        });
      } else {
        timer.cancel();
        if (widget.onComplete != null) {
          widget.onComplete!();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme.bodyLarge;
    final showCursor = widget.showCursor &&
        (_currentIndex < widget.text.length || _showCursor);

    return Text(
      _displayText + (showCursor ? '|' : ''),
      style: widget.style ?? defaultStyle,
      textAlign: widget.textAlign,
    );
  }
}

/// Subtle animated text that fades in and slides up
class FadeInText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final TextAlign textAlign;

  const FadeInText({
    Key? key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 800),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
    this.textAlign = TextAlign.left,
  }) : super(key: key);

  @override
  State<FadeInText> createState() => _FadeInTextState();
}

class _FadeInTextState extends State<FadeInText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme.bodyLarge;

    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Text(
          widget.text,
          style: widget.style ?? defaultStyle,
          textAlign: widget.textAlign,
        ),
      ),
    );
  }
}

/// Highlighted text with custom background and subtle animation
class HighlightedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final bool animate;
  final Duration animationDuration;

  const HighlightedText({
    Key? key,
    required this.text,
    this.style,
    this.backgroundColor = const Color(0xFFF0F4FF),
    this.textColor = AppColors.primary,
    this.borderRadius = 4,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    this.animate = true,
    this.animationDuration = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  State<HighlightedText> createState() => _HighlightedTextState();
}

class _HighlightedTextState extends State<HighlightedText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _brightnessAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _brightnessAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.1),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: 0.0),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: widget.textColor,
          fontWeight: FontWeight.w500,
        );

    return AnimatedBuilder(
      animation: _brightnessAnimation,
      builder: (context, child) {
        // Subtle brightness shift for animation
        final adjustedColor = widget.animate
            ? Color.lerp(
                widget.backgroundColor,
                Colors.white,
                _brightnessAnimation.value,
              )!
            : widget.backgroundColor;

        return Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: adjustedColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: Text(
            widget.text,
            style: widget.style ?? defaultStyle,
          ),
        );
      },
    );
  }
}

/// Professional statistic counter that animates from zero to target value
class AnimatedCounter extends StatefulWidget {
  final num end;
  final String prefix;
  final String suffix;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;
  final int decimalPlaces;
  final bool formatWithCommas;

  const AnimatedCounter({
    Key? key,
    required this.end,
    this.prefix = '',
    this.suffix = '',
    this.style,
    this.duration = const Duration(seconds: 1),
    this.curve = Curves.easeOutCubic,
    this.decimalPlaces = 0,
    this.formatWithCommas = false,
  }) : super(key: key);

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.end.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.end != widget.end) {
      // Update animation to new end value
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.end.toDouble(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ));

      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatNumber(double value) {
    // Format with specified decimal places
    String formatted = value.toStringAsFixed(widget.decimalPlaces);

    // Add commas for thousands if requested
    if (widget.formatWithCommas) {
      final parts = formatted.split('.');
      final integerPart = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );

      if (parts.length > 1) {
        formatted = '$integerPart.${parts[1]}';
      } else {
        formatted = integerPart;
      }
    }

    return '${widget.prefix}$formatted${widget.suffix}';
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        );

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Text(
        _formatNumber(_animation.value),
        style: widget.style ?? defaultStyle,
      ),
    );
  }
}
