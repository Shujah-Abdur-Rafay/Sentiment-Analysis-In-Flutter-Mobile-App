import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:math';

/// FadeIn animation that can be used for any widget
class FadeInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const FadeInAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
  }) : super(key: key);

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
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
      curve: widget.curve,
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

/// SlideIn animation that can be used for any widget
class SlideInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final Offset beginOffset;

  const SlideInAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
    this.beginOffset = const Offset(0.0, 50.0),
  }) : super(key: key);

  @override
  State<SlideInAnimation> createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<SlideInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}

/// Animated Pulse effect
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final bool repeat;

  const PulseAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.minScale = 0.97,
    this.maxScale = 1.03,
    this.repeat = true,
  }) : super(key: key);

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
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
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.repeat) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Shimmer loading effect
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const ShimmerLoading({
    Key? key,
    required this.child,
    this.baseColor = const Color(0xFF2A2A2A),
    this.highlightColor = const Color(0xFF3D3D3D),
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
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
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Animated gradient background
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final List<List<Color>> colorSets;
  final Duration duration;

  const AnimatedGradientBackground({
    Key? key,
    required this.child,
    required this.colorSets,
    this.duration = const Duration(seconds: 10),
  })  : assert(colorSets.length >= 2, 'At least 2 color sets are required'),
        super(key: key);

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _currentSet;
  late int _nextSet;

  @override
  void initState() {
    super.initState();
    _currentSet = 0;
    _nextSet = 1;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _currentSet = _nextSet;
            _nextSet = (_nextSet + 1) % widget.colorSets.length;
            _controller.reset();
          });
          _controller.forward();
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: List.generate(
                widget.colorSets[_currentSet].length,
                (index) {
                  return Color.lerp(
                    widget.colorSets[_currentSet][index],
                    widget.colorSets[_nextSet][index],
                    _controller.value,
                  )!;
                },
              ),
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Glitch text effect for futuristic UI
class GlitchText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final bool isActive;
  final Duration duration;

  const GlitchText({
    Key? key,
    required this.text,
    required this.style,
    this.isActive = true,
    this.duration = const Duration(milliseconds: 2000),
  }) : super(key: key);

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<GlitchText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late String _displayText;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _displayText = widget.text;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    if (widget.isActive) {
      _controller.repeat();
    }

    _controller.addListener(() {
      if (_random.nextDouble() > 0.95) {
        _glitch();
      } else if (_random.nextDouble() > 0.9) {
        _reset();
      }
    });
  }

  void _glitch() {
    if (!mounted) return;
    setState(() {
      _displayText = widget.text.characters.map((char) {
        return _random.nextDouble() > 0.7 ? _randomChar() : char;
      }).join();
    });
  }

  void _reset() {
    if (!mounted) return;
    setState(() {
      _displayText = widget.text;
    });
  }

  String _randomChar() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()';
    return chars[_random.nextInt(chars.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayText,
      style: widget.style,
    );
  }
}

/// Animated wave effect (can be used for audio visualization)
class WaveAnimation extends StatefulWidget {
  final int count;
  final double height;
  final Color color;
  final double spacing;
  final bool isActive;

  const WaveAnimation({
    Key? key,
    this.count = 5,
    this.height = 30,
    this.color = Colors.white,
    this.spacing = 5,
    this.isActive = true,
  }) : super(key: key);

  @override
  State<WaveAnimation> createState() => _WaveAnimationState();
}

class _WaveAnimationState extends State<WaveAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.count,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 600 + (index * 100)),
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();

    if (widget.isActive) {
      for (var controller in _controllers) {
        controller.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.count, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
          child: AnimatedBuilder(
            animation: _animations[index],
            builder: (context, _) {
              return Container(
                width: 4,
                height: widget.height * _animations[index].value,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(5),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

/// Holographic flickering effect for futuristic UI elements
class HolographicFlicker extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final double flickerIntensity;
  final Duration duration;
  final double borderWidth;
  final BorderRadius borderRadius;

  const HolographicFlicker({
    Key? key,
    required this.child,
    this.colors = const [Colors.cyan, Colors.purple, Colors.blue],
    this.flickerIntensity = 0.3,
    this.duration = const Duration(seconds: 3),
    this.borderWidth = 1.5,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  }) : super(key: key);

  @override
  State<HolographicFlicker> createState() => _HolographicFlickerState();
}

class _HolographicFlickerState extends State<HolographicFlicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flickerAnimation;
  final Random _random = Random();
  double _randomFlickerOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _flickerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);

    // Add random flicker effect
    _controller.addListener(_randomFlicker);
  }

  void _randomFlicker() {
    if (_random.nextDouble() > 0.95) {
      setState(() {
        _randomFlickerOffset = _random.nextDouble() * widget.flickerIntensity;
      });
    } else if (_random.nextDouble() > 0.8) {
      setState(() {
        _randomFlickerOffset = 0.0;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_randomFlicker);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flickerAnimation,
      builder: (context, child) {
        // Calculate current color from the animation
        final int colorIndex1 =
            (_flickerAnimation.value * (widget.colors.length - 1)).floor();
        final int colorIndex2 = (colorIndex1 + 1) % widget.colors.length;
        final double colorPercent =
            (_flickerAnimation.value * (widget.colors.length - 1)) -
                colorIndex1;

        final Color currentColor = Color.lerp(
          widget.colors[colorIndex1],
          widget.colors[colorIndex2],
          colorPercent + _randomFlickerOffset,
        )!;

        return Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            border: Border.all(
              color: currentColor.withOpacity(0.5 + _randomFlickerOffset),
              width: widget.borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: currentColor
                    .withOpacity((0.2 + _randomFlickerOffset).clamp(0.0, 1.0)),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
