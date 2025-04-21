import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/colors.dart';

/// Glitch Text that simulates digital distortion
class GlitchText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final GlitchEffect effect;
  final Duration glitchInterval;
  final Duration glitchDuration;
  final bool autoStart;

  const GlitchText({
    Key? key,
    required this.text,
    this.style = const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    this.effect = GlitchEffect.mild,
    this.glitchInterval = const Duration(seconds: 5),
    this.glitchDuration = const Duration(milliseconds: 200),
    this.autoStart = true,
  }) : super(key: key);

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

enum GlitchEffect {
  mild,
  medium,
  strong,
  scramble,
}

class _GlitchTextState extends State<GlitchText> {
  late String _displayText;
  bool _isGlitching = false;
  Timer? _glitchTimer;
  Timer? _glitchEffectTimer;
  final Random _random = Random();
  static const String _glitchChars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@#\$%&*!?><';

  @override
  void initState() {
    super.initState();
    _displayText = widget.text;

    if (widget.autoStart) {
      _startGlitchTimer();
    }
  }

  @override
  void dispose() {
    _glitchTimer?.cancel();
    _glitchEffectTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(GlitchText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      setState(() {
        _displayText = widget.text;
      });
    }
  }

  void _startGlitchTimer() {
    _glitchTimer?.cancel();
    _glitchTimer = Timer.periodic(widget.glitchInterval, (_) {
      _triggerGlitch();
    });
  }

  void _triggerGlitch() {
    if (_isGlitching) return;

    setState(() {
      _isGlitching = true;
    });

    int iterations = widget.effect == GlitchEffect.strong
        ? 5
        : widget.effect == GlitchEffect.medium
            ? 3
            : 2;

    Duration singleGlitchDuration = Duration(
        milliseconds: widget.glitchDuration.inMilliseconds ~/ iterations);

    int currentIteration = 0;

    _glitchEffectTimer = Timer.periodic(singleGlitchDuration, (timer) {
      if (currentIteration >= iterations) {
        timer.cancel();
        setState(() {
          _displayText = widget.text;
          _isGlitching = false;
        });
        return;
      }

      setState(() {
        _displayText = _getGlitchedText();
      });

      currentIteration++;
    });
  }

  String _getGlitchedText() {
    String result = '';

    // Choose glitch strategy based on effect level
    switch (widget.effect) {
      case GlitchEffect.scramble:
        // Complete scramble
        for (int i = 0; i < widget.text.length; i++) {
          result += _glitchChars[_random.nextInt(_glitchChars.length)];
        }
        break;

      case GlitchEffect.strong:
        // Aggressive partial scramble (70% of characters)
        for (int i = 0; i < widget.text.length; i++) {
          if (_random.nextDouble() < 0.7) {
            result += _glitchChars[_random.nextInt(_glitchChars.length)];
          } else {
            result += widget.text[i];
          }
        }
        break;

      case GlitchEffect.medium:
        // Medium scramble (40% of characters)
        for (int i = 0; i < widget.text.length; i++) {
          if (_random.nextDouble() < 0.4) {
            result += _glitchChars[_random.nextInt(_glitchChars.length)];
          } else {
            result += widget.text[i];
          }
        }
        break;

      case GlitchEffect.mild:
      default:
        // Mild scramble (20% of characters)
        for (int i = 0; i < widget.text.length; i++) {
          if (_random.nextDouble() < 0.2) {
            result += _glitchChars[_random.nextInt(_glitchChars.length)];
          } else {
            result += widget.text[i];
          }
        }
        break;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _triggerGlitch,
      child: Text(
        _displayText,
        style: widget.style.copyWith(
          shadows: _isGlitching
              ? [
                  Shadow(
                    color: AppColors.accent.withOpacity(0.7),
                    blurRadius: 2,
                    offset: const Offset(2, 0),
                  ),
                  Shadow(
                    color: AppColors.primary.withOpacity(0.7),
                    blurRadius: 2,
                    offset: const Offset(-2, 0),
                  ),
                ]
              : widget.style.shadows,
        ),
      ),
    );
  }
}

/// Typing Text animation with a cyberpunk feel
class CyberpunkTypingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration typingSpeed;
  final Duration startDelay;
  final bool repeat;
  final bool cursorBlink;
  final String cursor;
  final VoidCallback? onTypingComplete;

  const CyberpunkTypingText({
    Key? key,
    required this.text,
    this.style = const TextStyle(
      color: Colors.white,
      fontSize: 18,
    ),
    this.typingSpeed = const Duration(milliseconds: 70),
    this.startDelay = Duration.zero,
    this.repeat = false,
    this.cursorBlink = true,
    this.cursor = '█',
    this.onTypingComplete,
  }) : super(key: key);

  @override
  State<CyberpunkTypingText> createState() => _CyberpunkTypingTextState();
}

class _CyberpunkTypingTextState extends State<CyberpunkTypingText>
    with SingleTickerProviderStateMixin {
  late String _displayText;
  late int _charIndex;
  Timer? _typeTimer;
  Timer? _blinkTimer;
  bool _showCursor = true;

  @override
  void initState() {
    super.initState();
    _displayText = '';
    _charIndex = 0;

    Future.delayed(widget.startDelay, () {
      _startTyping();
    });

    if (widget.cursorBlink) {
      _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
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
    _typeTimer?.cancel();
    _blinkTimer?.cancel();
    super.dispose();
  }

  void _startTyping() {
    _typeTimer = Timer.periodic(widget.typingSpeed, (timer) {
      if (_charIndex < widget.text.length) {
        setState(() {
          _displayText = widget.text.substring(0, _charIndex + 1);
          _charIndex++;
        });
      } else {
        timer.cancel();
        if (widget.onTypingComplete != null) {
          widget.onTypingComplete!();
        }

        if (widget.repeat) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _displayText = '';
                _charIndex = 0;
              });
              _startTyping();
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final finalText = _displayText + (_showCursor ? widget.cursor : '');

    return Text(
      finalText,
      style: widget.style,
    );
  }
}

/// Neon text effect with glow
class NeonText extends StatefulWidget {
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final bool flicker;
  final double glowIntensity;
  final Duration flickerInterval;

  const NeonText({
    Key? key,
    required this.text,
    this.color = AppColors.accent,
    this.fontSize = 24,
    this.fontWeight = FontWeight.bold,
    this.flicker = true,
    this.glowIntensity = 0.8,
    this.flickerInterval = const Duration(seconds: 8),
  }) : super(key: key);

  @override
  State<NeonText> createState() => _NeonTextState();
}

class _NeonTextState extends State<NeonText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  bool _isFlickering = false;
  Timer? _flickerTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _glowAnimation = Tween<double>(
      begin: 0.6,
      end: widget.glowIntensity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);

    if (widget.flicker) {
      _setupFlickerEffect();
    }
  }

  void _setupFlickerEffect() {
    // Random flicker interval
    Future.delayed(widget.flickerInterval * _random.nextDouble(), () {
      if (!mounted) return;

      setState(() {
        _isFlickering = true;
      });

      // Brief flicker
      _flickerTimer =
          Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (timer.tick > 3) {
          timer.cancel();
          if (mounted) {
            setState(() {
              _isFlickering = false;
            });
            _setupFlickerEffect();
          }
        } else {
          if (mounted) {
            setState(() {
              _isFlickering = !_isFlickering;
            });
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _flickerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Text(
          widget.text,
          style: TextStyle(
            color: widget.color,
            fontSize: widget.fontSize,
            fontWeight: widget.fontWeight,
            shadows: _isFlickering
                ? []
                : [
                    Shadow(
                      color:
                          widget.color.withOpacity(_glowAnimation.value * 0.4),
                      blurRadius: 15,
                    ),
                    Shadow(
                      color:
                          widget.color.withOpacity(_glowAnimation.value * 0.7),
                      blurRadius: 8,
                    ),
                    Shadow(
                      color: widget.color.withOpacity(_glowAnimation.value),
                      blurRadius: 3,
                    ),
                  ],
          ),
        );
      },
    );
  }
}

/// Digital Matrix-style loading text
class MatrixText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Color primaryColor;
  final Duration revealDelay;
  final Duration charAnimationDuration;
  final VoidCallback? onComplete;

  const MatrixText({
    Key? key,
    required this.text,
    this.style = const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
    this.primaryColor = AppColors.tertiary,
    this.revealDelay = const Duration(milliseconds: 50),
    this.charAnimationDuration = const Duration(milliseconds: 800),
    this.onComplete,
  }) : super(key: key);

  @override
  State<MatrixText> createState() => _MatrixTextState();
}

class _MatrixTextState extends State<MatrixText> {
  late List<String> _characters;
  late List<bool> _revealed;
  final Random _random = Random();
  int _totalRevealed = 0;
  Timer? _revealTimer;

  @override
  void initState() {
    super.initState();
    _characters = widget.text.split('');
    _revealed = List<bool>.filled(_characters.length, false);
    _startReveal();
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }

  void _startReveal() {
    _revealTimer = Timer.periodic(widget.revealDelay, (timer) {
      if (_totalRevealed >= _characters.length) {
        timer.cancel();
        if (widget.onComplete != null) {
          widget.onComplete!();
        }
        return;
      }

      // Find an unrevealed character
      List<int> unrevealed = [];
      for (int i = 0; i < _revealed.length; i++) {
        if (!_revealed[i]) {
          unrevealed.add(i);
        }
      }

      if (unrevealed.isNotEmpty) {
        int indexToReveal = unrevealed[_random.nextInt(unrevealed.length)];
        setState(() {
          _revealed[indexToReveal] = true;
          _totalRevealed++;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        _characters.length,
        (index) => _buildCharacter(index),
      ),
    );
  }

  Widget _buildCharacter(int index) {
    final char = _characters[index];
    final isRevealed = _revealed[index];

    if (isRevealed) {
      return Text(
        char,
        style: widget.style,
      );
    } else {
      return _MatrixCharacter(
        finalChar: char,
        style: widget.style,
        primaryColor: widget.primaryColor,
        duration: widget.charAnimationDuration,
      );
    }
  }
}

class _MatrixCharacter extends StatefulWidget {
  final String finalChar;
  final TextStyle style;
  final Color primaryColor;
  final Duration duration;

  const _MatrixCharacter({
    Key? key,
    required this.finalChar,
    required this.style,
    required this.primaryColor,
    required this.duration,
  }) : super(key: key);

  @override
  State<_MatrixCharacter> createState() => _MatrixCharacterState();
}

class _MatrixCharacterState extends State<_MatrixCharacter> {
  static const String _chars =
      'アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン0123456789';
  late String _currentChar;
  Timer? _animationTimer;
  final Random _random = Random();
  int _tickCount = 0;

  @override
  void initState() {
    super.initState();
    _currentChar = _getRandomChar();
    _startAnimation();
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  String _getRandomChar() {
    return _chars[_random.nextInt(_chars.length)];
  }

  void _startAnimation() {
    // Change characters rapidly
    final ticksNeeded = (widget.duration.inMilliseconds / 100).round();

    _animationTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;

      _tickCount++;

      // Gradually increase chances of showing the final character
      double finalCharProbability = _tickCount / ticksNeeded;

      if (_random.nextDouble() < finalCharProbability) {
        setState(() {
          _currentChar = widget.finalChar;
        });
        timer.cancel();
      } else {
        setState(() {
          _currentChar = _getRandomChar();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _currentChar,
      style: widget.style.copyWith(
        color: widget.primaryColor,
        shadows: [
          Shadow(
            color: widget.primaryColor.withOpacity(0.7),
            blurRadius: 3,
          ),
        ],
      ),
    );
  }
}
