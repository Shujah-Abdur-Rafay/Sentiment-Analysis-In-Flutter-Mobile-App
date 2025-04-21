import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocal_emotion/utils/animations.dart';
import 'package:vocal_emotion/utils/colors.dart';

/// Glassmorphic card with blur effect
class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsets padding;
  final double blur;
  final Color borderColor;
  final double borderWidth;
  final Gradient? gradient;

  const GlassmorphicCard({
    Key? key,
    required this.child,
    this.width = double.infinity,
    this.height = 100,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.blur = 10,
    this.borderColor = Colors.white30,
    this.borderWidth = 1.5,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
            gradient: gradient,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Neon button with glow effect
class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color glowColor;
  final Color textColor;
  final double width;
  final double height;
  final double borderRadius;
  final bool isPulsing;

  const NeonButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.glowColor = AppColors.primary,
    this.textColor = Colors.white,
    this.width = 200,
    this.height = 50,
    this.borderRadius = 12,
    this.isPulsing = true,
  }) : super(key: key);

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final buttonChild = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color: widget.glowColor.withOpacity(0.2),
        border: Border.all(
          color: widget.glowColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.glowColor.withOpacity(_isPressed ? 0.7 : 0.4),
            blurRadius: _isPressed ? 15 : 8,
            spreadRadius: _isPressed ? 1 : 0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.text,
          style: TextStyle(
            color: widget.textColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            shadows: [
              Shadow(
                color: widget.glowColor.withOpacity(0.7),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: widget.isPulsing
          ? PulseAnimation(
              minScale: 0.98,
              maxScale: 1.02,
              duration: const Duration(milliseconds: 1800),
              child: buttonChild,
            )
          : buttonChild,
    );
  }
}

/// Elegant text field with animated underline
class FuturisticTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final bool obscureText;
  final IconData? prefixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool isPassword;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const FuturisticTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.obscureText = false,
    this.prefixIcon,
    this.onSuffixIconPressed,
    this.isPassword = false,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.validator,
  }) : super(key: key);

  @override
  State<FuturisticTextField> createState() => _FuturisticTextFieldState();
}

class _FuturisticTextFieldState extends State<FuturisticTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  bool _obscureText = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _widthAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    widget.focusNode?.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (widget.focusNode!.hasFocus) {
      setState(() => _isFocused = true);
      _animationController.forward();
    } else {
      setState(() => _isFocused = false);
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_handleFocusChange);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: TextStyle(
            color: _isFocused ? primaryColor : AppColors.textSecondary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isFocused
                  ? primaryColor
                  : AppColors.textHint.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.textHint.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: _obscureText,
            focusNode: widget.focusNode,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16.sp,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: AppColors.textHint,
                fontSize: 16.sp,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused ? primaryColor : AppColors.textHint,
                      size: 20.sp,
                    )
                  : null,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: _isFocused ? primaryColor : AppColors.textHint,
                        size: 20.sp,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                        if (widget.onSuffixIconPressed != null) {
                          widget.onSuffixIconPressed!();
                        }
                      },
                    )
                  : null,
            ),
            cursorColor: primaryColor,
            cursorWidth: 1.5,
          ),
        ),
        SizedBox(height: 4.h),
        AnimatedBuilder(
          animation: _widthAnimation,
          builder: (context, _) {
            return Container(
              height: 2.h,
              width: MediaQuery.of(context).size.width * _widthAnimation.value,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(1),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Avatar with animated border
class AnimatedBorderAvatar extends StatefulWidget {
  final String imageUrl;
  final double size;
  final bool showBorder;
  final List<Color> borderColors;
  final double borderWidth;
  final Widget? placeholderWidget;

  const AnimatedBorderAvatar({
    Key? key,
    required this.imageUrl,
    this.size = 50,
    this.showBorder = true,
    this.borderColors = const [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.primary,
    ],
    this.borderWidth = 3.0,
    this.placeholderWidget,
  }) : super(key: key);

  @override
  State<AnimatedBorderAvatar> createState() => _AnimatedBorderAvatarState();
}

class _AnimatedBorderAvatarState extends State<AnimatedBorderAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    if (widget.showBorder) {
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: widget.showBorder
                ? SweepGradient(
                    colors: widget.borderColors,
                    startAngle: 0,
                    endAngle: 3.14 * 2,
                    transform: GradientRotation(_controller.value * 3.14 * 2),
                  )
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.all(widget.borderWidth),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.size),
              child: widget.imageUrl.isNotEmpty
                  ? Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return widget.placeholderWidget ??
                            Container(
                              color: AppColors.surfaceLight,
                              child: Icon(
                                Icons.person,
                                size: widget.size * 0.5,
                                color: AppColors.textSecondary,
                              ),
                            );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return widget.placeholderWidget ??
                            Container(
                              color: AppColors.surfaceLight,
                              child: Icon(
                                Icons.error_outline,
                                size: widget.size * 0.5,
                                color: AppColors.error,
                              ),
                            );
                      },
                    )
                  : widget.placeholderWidget ??
                      Container(
                        color: AppColors.surfaceLight,
                        child: Icon(
                          Icons.person,
                          size: widget.size * 0.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
            ),
          ),
        );
      },
    );
  }
}

/// Futuristic Tab indicator
class FuturisticTabIndicator extends Decoration {
  final Color color;
  final double height;
  final double radius;
  final EdgeInsetsGeometry insets;
  final List<Color> gradient;

  const FuturisticTabIndicator({
    this.color = AppColors.primary,
    this.height = 4,
    this.radius = 4,
    this.insets = const EdgeInsets.symmetric(horizontal: 16),
    this.gradient = const [AppColors.primary, AppColors.secondary],
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _FuturisticIndicatorPainter(
      color: color,
      height: height,
      radius: radius,
      insets: insets,
      gradient: gradient,
    );
  }
}

class _FuturisticIndicatorPainter extends BoxPainter {
  final Paint _paint;
  final double height;
  final double radius;
  final EdgeInsetsGeometry insets;
  final List<Color> gradient;

  _FuturisticIndicatorPainter({
    required Color color,
    required this.height,
    required this.radius,
    required this.insets,
    required this.gradient,
  }) : _paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    final Rect rect = offset & configuration.size!;
    final TextDirection? textDirection = configuration.textDirection;
    final insetRect = insets.resolve(textDirection).deflateRect(rect);
    final width = insetRect.width;
    final left = insetRect.left;
    final Rect tabRect = Rect.fromLTWH(
      left,
      insetRect.bottom - height,
      width,
      height,
    );

    final RRect rRect = RRect.fromRectAndRadius(
      tabRect,
      Radius.circular(radius),
    );

    // Create gradient shader
    final shader = LinearGradient(
      colors: gradient,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(tabRect);

    final paint = Paint()
      ..shader = shader
      ..style = PaintingStyle.fill;

    canvas.drawRRect(rRect, paint);

    // Add a glow effect
    final shadowPaint = Paint()
      ..color = gradient.first.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawRRect(rRect, shadowPaint);
  }
}

/// Audio visualization card
class AudioVisualizationCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback? onDelete;

  const AudioVisualizationCard({
    Key? key,
    required this.title,
    this.subtitle,
    required this.isPlaying,
    required this.onPlayPause,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      height: 100.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.surfaceLight.withOpacity(0.5),
          AppColors.surfaceLight.withOpacity(0.2),
        ],
      ),
      child: Row(
        children: [
          // Play/Pause button
          GestureDetector(
            onTap: onPlayPause,
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppColors.primary,
                size: 24.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Title and visualization
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 8.h),
                WaveAnimation(
                  count: 15,
                  height: 25.h,
                  color: AppColors.primary,
                  spacing: 3,
                  isActive: isPlaying,
                ),
              ],
            ),
          ),
          // Delete button if needed
          if (onDelete != null) ...[
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Cyberpunk Card with holographic border effect
class CyberpunkCard extends StatefulWidget {
  final Widget child;
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsets padding;
  final bool showGlitch;
  final bool animateBorder;
  final List<Color> borderColors;

  const CyberpunkCard({
    Key? key,
    required this.child,
    this.width = double.infinity,
    this.height = 150,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.showGlitch = true,
    this.animateBorder = true,
    this.borderColors = const [
      AppColors.accent,
      AppColors.primary,
      AppColors.secondary,
      AppColors.tertiary,
    ],
  }) : super(key: key);

  @override
  State<CyberpunkCard> createState() => _CyberpunkCardState();
}

class _CyberpunkCardState extends State<CyberpunkCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _glitchActive = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    if (widget.animateBorder) {
      _controller.repeat();
    }

    if (widget.showGlitch) {
      _setupGlitchEffect();
    }
  }

  void _setupGlitchEffect() {
    Future.delayed(Duration(seconds: _random.nextInt(5) + 5), () {
      if (mounted) {
        setState(() {
          _glitchActive = true;
        });

        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              _glitchActive = false;
            });
            _setupGlitchEffect();
          }
        });
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Glitch effect
            if (_glitchActive)
              Positioned(
                left: _random.nextDouble() * 10 - 5,
                right: _random.nextDouble() * 10 - 5,
                top: _random.nextDouble() * 10 - 5,
                bottom: _random.nextDouble() * 10 - 5,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accent.withOpacity(0.5),
                        AppColors.primary.withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
              ),

            // Main card with holographic border
            Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: widget.borderColors[0].withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface.withOpacity(0.9),
                    AppColors.surfaceLight.withOpacity(0.7),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Border animation
                  if (widget.animateBorder)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: HolographicBorderPainter(
                          progress: _controller.value,
                          borderRadius: widget.borderRadius,
                          borderColors: widget.borderColors,
                        ),
                      ),
                    ),

                  // Content
                  Padding(
                    padding: widget.padding,
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class HolographicBorderPainter extends CustomPainter {
  final double progress;
  final double borderRadius;
  final List<Color> borderColors;

  HolographicBorderPainter({
    required this.progress,
    required this.borderRadius,
    required this.borderColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    final colors = List<Color>.from(borderColors);
    final rotatedColors = [
      ...colors.sublist(colors.length - (progress * colors.length).floor()),
      ...colors.sublist(0, (progress * colors.length).floor()),
    ];

    final shader = SweepGradient(
      colors: rotatedColors,
      startAngle: 0,
      endAngle: 3.14 * 2,
      transform: GradientRotation(progress * 3.14 * 2),
    ).createShader(rect);

    final paint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(HolographicBorderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Cyberpunk Button with distortion effect
class CyberpunkButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final List<Color> colors;
  final double width;
  final double height;
  final double borderWidth;
  final bool isGlitching;

  const CyberpunkButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.colors = const [
      AppColors.accent,
      AppColors.primary,
      AppColors.secondary
    ],
    this.width = 200,
    this.height = 50,
    this.borderWidth = 2.0,
    this.isGlitching = true,
  }) : super(key: key);

  @override
  State<CyberpunkButton> createState() => _CyberpunkButtonState();
}

class _CyberpunkButtonState extends State<CyberpunkButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;
  bool _isPressed = false;
  bool _isGlitching = false;
  final Random _random = Random();
  Offset _glitchOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    if (widget.isGlitching) {
      _setupGlitchEffect();
    }
  }

  void _setupGlitchEffect() {
    Future.delayed(Duration(seconds: _random.nextInt(5) + 3), () {
      if (mounted) {
        setState(() {
          _isGlitching = true;
          _glitchOffset = Offset(
            (_random.nextDouble() * 6) - 3,
            (_random.nextDouble() * 6) - 3,
          );
        });

        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              _isGlitching = false;
              _glitchOffset = Offset.zero;
            });
            _setupGlitchEffect();
          }
        });
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
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                // Glitch shadow
                if (_isGlitching)
                  Positioned(
                    left: _glitchOffset.dx,
                    top: _glitchOffset.dy,
                    child: Container(
                      width: widget.width,
                      height: widget.height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: widget.colors[0].withOpacity(0.5),
                      ),
                    ),
                  ),

                // Main button
                Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      width: widget.borderWidth,
                      color: Colors.transparent,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.surface,
                        AppColors.surfaceLight,
                      ],
                    ),
                    boxShadow: [
                      if (_isHovered || _isPressed)
                        BoxShadow(
                          color: widget.colors[0].withOpacity(0.7),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: CyberpunkBorderPainter(
                      progress: _controller.value,
                      borderWidth: widget.borderWidth,
                      colors: widget.colors,
                      isHovered: _isHovered,
                      isPressed: _isPressed,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          widget.text,
                          style: TextStyle(
                            color: _isHovered || _isPressed
                                ? widget.colors[1]
                                : AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            shadows: [
                              if (_isHovered || _isPressed)
                                Shadow(
                                  color: widget.colors[0].withOpacity(0.7),
                                  blurRadius: 10,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CyberpunkBorderPainter extends CustomPainter {
  final double progress;
  final double borderWidth;
  final List<Color> colors;
  final bool isHovered;
  final bool isPressed;

  CyberpunkBorderPainter({
    required this.progress,
    required this.borderWidth,
    required this.colors,
    required this.isHovered,
    required this.isPressed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(4),
    );

    // Draw corner accents
    final cornerSize = 10.0;
    final paint = Paint()
      ..color = (isHovered || isPressed)
          ? colors[0]
          : Color.lerp(colors[0], colors[1], progress) ?? colors[0]
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Top left corner
    canvas.drawLine(
      Offset(0, cornerSize),
      Offset(0, 0),
      paint,
    );
    canvas.drawLine(
      Offset(0, 0),
      Offset(cornerSize, 0),
      paint,
    );

    // Top right corner
    canvas.drawLine(
      Offset(size.width - cornerSize, 0),
      Offset(size.width, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerSize),
      paint,
    );

    // Bottom right corner
    canvas.drawLine(
      Offset(size.width, size.height - cornerSize),
      Offset(size.width, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - cornerSize, size.height),
      paint,
    );

    // Bottom left corner
    canvas.drawLine(
      Offset(cornerSize, size.height),
      Offset(0, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - cornerSize),
      paint,
    );

    // Draw highlight on hover
    if (isHovered || isPressed) {
      final highlightPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            colors[0].withOpacity(isPressed ? 0.8 : 0.5),
            colors[1].withOpacity(isPressed ? 0.4 : 0.2),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;

      canvas.drawRRect(rrect, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(CyberpunkBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isHovered != isHovered ||
        oldDelegate.isPressed != isPressed;
  }
}

/// Holographic 3D floating container
class HologramContainer extends StatefulWidget {
  final Widget child;
  final double width;
  final double height;
  final double depth;
  final List<Color> colors;
  final bool animate;

  const HologramContainer({
    Key? key,
    required this.child,
    this.width = 200,
    this.height = 200,
    this.depth = 20,
    this.colors = const [AppColors.primary, AppColors.secondary],
    this.animate = true,
  }) : super(key: key);

  @override
  State<HologramContainer> createState() => _HologramContainerState();
}

class _HologramContainerState extends State<HologramContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _rotationX = 0.0;
  double _rotationY = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

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
    return GestureDetector(
      onPanUpdate: (details) {
        if (!widget.animate) {
          setState(() {
            _rotationY += details.delta.dx * 0.01;
            _rotationX -= details.delta.dy * 0.01;
          });
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double rotX = widget.animate
              ? sin(_controller.value * 2 * pi) * 0.05
              : _rotationX;
          double rotY = widget.animate
              ? cos(_controller.value * 2 * pi) * 0.05
              : _rotationY;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(rotX)
              ..rotateY(rotY),
            alignment: Alignment.center,
            child: Stack(
              children: [
                // 3D shadow/depth effect
                Positioned(
                  left: 10,
                  top: 10,
                  child: Opacity(
                    opacity: 0.3,
                    child: Container(
                      width: widget.width,
                      height: widget.height,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: widget.colors[0].withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Main container
                Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Color.lerp(widget.colors[0], widget.colors[1],
                          widget.animate ? _controller.value : 0.5)!,
                      width: 1.5,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.surface.withOpacity(0.9),
                        AppColors.surfaceLight.withOpacity(0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.lerp(widget.colors[0], widget.colors[1],
                                widget.animate ? _controller.value : 0.5)!
                            .withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.white.withOpacity(0.05),
                        child: Stack(
                          children: [
                            // Holographic scanline effect
                            Positioned.fill(
                              child: Opacity(
                                opacity: 0.1,
                                child: CustomPaint(
                                  painter: ScanlinePainter(
                                    progress: widget.animate
                                        ? _controller.value
                                        : 0.5,
                                    color: widget.colors[0],
                                  ),
                                ),
                              ),
                            ),

                            // Content
                            Center(child: widget.child),

                            // Edge highlight
                            Positioned.fill(
                              child: CustomPaint(
                                painter: EdgeHighlightPainter(
                                  progress:
                                      widget.animate ? _controller.value : 0.5,
                                  colors: widget.colors,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ScanlinePainter extends CustomPainter {
  final double progress;
  final Color color;

  ScanlinePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw scanlines
    for (int i = 0; i < size.height; i += 4) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }

    // Draw vertical scanning effect
    final scanPos = size.height * progress;
    final scanPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0),
          color.withOpacity(0.5),
          color.withOpacity(0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, scanPos - 20, size.width, 40));

    canvas.drawRect(
      Rect.fromLTWH(0, scanPos - 20, size.width, 40),
      scanPaint,
    );
  }

  @override
  bool shouldRepaint(ScanlinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class EdgeHighlightPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  EdgeHighlightPainter({
    required this.progress,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(15),
    );

    final highlightColor = Color.lerp(colors[0], colors[1], progress)!;

    // Create a gradient shader for the edge highlight
    final shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        highlightColor.withOpacity(0.6),
        highlightColor.withOpacity(0.1),
      ],
    ).createShader(rect);

    final paint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(EdgeHighlightPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Professional settings option item with toggle or selection capability
class ProfessionalOption extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final bool isToggleable;
  final bool? value;
  final VoidCallback? onTap;
  final Function(bool)? onToggle;
  final Widget? trailing;

  const ProfessionalOption({
    Key? key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.isToggleable = false,
    this.value,
    this.onTap,
    this.onToggle,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primary;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Ink(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.surfaceDark,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20.sp,
                  ),
                ),

                SizedBox(width: 14.w),

                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.sp,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Toggle or custom trailing widget
                if (isToggleable && onToggle != null) ...[
                  SizedBox(width: 8.w),
                  _ProfessionalToggle(
                    value: value ?? false,
                    onChanged: onToggle!,
                    activeColor: color,
                  ),
                ] else if (trailing != null) ...[
                  SizedBox(width: 8.w),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom toggle switch with professional design
class _ProfessionalToggle extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;
  final Color activeColor;
  final double width;
  final double height;

  const _ProfessionalToggle({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.activeColor,
    this.width = 46,
    this.height = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: width.w,
        height: height.h,
        decoration: BoxDecoration(
          color: value ? activeColor : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              left: value ? width - height + 2 : 2,
              top: 2,
              child: Container(
                width: height - 4,
                height: height - 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      spreadRadius: 0,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
