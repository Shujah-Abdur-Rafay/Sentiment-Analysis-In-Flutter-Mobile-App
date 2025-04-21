import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/colors.dart';

/// Elegant Card with subtle shadow and border
class ProfessionalCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsets padding;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final List<Color>? gradientColors;

  const ProfessionalCard({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFE1E5EE),
    this.borderWidth = 1.0,
    this.boxShadow,
    this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0, 2),
                blurRadius: 6,
                spreadRadius: 0,
              ),
            ],
      ),
      child: child,
    );
  }
}

/// Modern Button with subtle animation
class ModernButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color? primaryColor;
  final Color? labelColor;
  final double? width;
  final double height;
  final double borderRadius;
  final bool isOutlined;
  final bool isLoading;

  const ModernButton({
    Key? key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.primaryColor,
    this.labelColor,
    this.width,
    this.height = 48,
    this.borderRadius = 8,
    this.isOutlined = false,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor ?? AppColors.primary;
    final labelColor =
        widget.labelColor ?? (widget.isOutlined ? primaryColor : Colors.white);

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                color: widget.isOutlined ? Colors.transparent : primaryColor,
                border: widget.isOutlined
                    ? Border.all(color: primaryColor, width: 1.5)
                    : null,
                boxShadow: _isPressed || widget.isOutlined
                    ? []
                    : [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                      ],
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: widget.isOutlined ? primaryColor : labelColor,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color:
                                  widget.isOutlined ? primaryColor : labelColor,
                              size: 20,
                            ),
                            SizedBox(width: 8.w),
                          ],
                          Text(
                            widget.text,
                            style: TextStyle(
                              color:
                                  widget.isOutlined ? primaryColor : labelColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// High-quality input field with animated label
class ProfessionalTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final FocusNode? focusNode;
  final EdgeInsets contentPadding;

  const ProfessionalTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.focusNode,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
  }) : super(key: key);

  @override
  State<ProfessionalTextField> createState() => _ProfessionalTextFieldState();
}

class _ProfessionalTextFieldState extends State<ProfessionalTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    widget.focusNode?.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (widget.focusNode?.hasFocus == true) {
      setState(() => _isFocused = true);
      _controller.forward();
    } else {
      setState(() => _isFocused = false);
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_handleFocusChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;
    final labelColor = _isFocused
        ? AppColors.primary
        : hasText
            ? AppColors.textSecondary
            : AppColors.textHint;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Floating label
            if (hasText || _isFocused)
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 8),
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // Text field
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      _isFocused ? AppColors.primary : AppColors.surfaceLight,
                  width: 1.5,
                ),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                validator: widget.validator,
                onChanged: widget.onChanged,
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
                enabled: widget.enabled,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText:
                      !hasText && !_isFocused ? widget.label : widget.hint,
                  hintStyle: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 16,
                  ),
                  contentPadding: widget.contentPadding,
                  counterText: "",
                  border: InputBorder.none,
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: _isFocused
                              ? AppColors.primary
                              : AppColors.textHint,
                          size: 20,
                        )
                      : null,
                  suffixIcon: widget.suffixIcon != null
                      ? GestureDetector(
                          onTap: widget.onSuffixTap,
                          child: Icon(
                            widget.suffixIcon,
                            color: _isFocused
                                ? AppColors.primary
                                : AppColors.textHint,
                            size: 20,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Modern avatar with subtle animations
class ProfessionalAvatar extends StatefulWidget {
  final String imageUrl;
  final double size;
  final Color borderColor;
  final double borderWidth;
  final Widget? placeholderWidget;
  final VoidCallback? onTap;
  final bool showStatus;
  final bool isOnline;

  const ProfessionalAvatar({
    Key? key,
    required this.imageUrl,
    this.size = 48,
    this.borderColor = AppColors.primary,
    this.borderWidth = 2,
    this.placeholderWidget,
    this.onTap,
    this.showStatus = false,
    this.isOnline = false,
  }) : super(key: key);

  @override
  State<ProfessionalAvatar> createState() => _ProfessionalAvatarState();
}

class _ProfessionalAvatarState extends State<ProfessionalAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: widget.onTap != null ? (_) => _controller.forward() : null,
      onTapCancel: widget.onTap != null ? () => _controller.reverse() : null,
      onTapUp: widget.onTap != null ? (_) => _controller.reverse() : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              children: [
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.borderColor,
                      width: widget.borderWidth,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.borderColor.withOpacity(0.15),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
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
                                    color: AppColors.surface,
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
                                    color: AppColors.surface,
                                    child: Icon(
                                      Icons.person,
                                      size: widget.size * 0.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  );
                            },
                          )
                        : widget.placeholderWidget ??
                            Container(
                              color: AppColors.surface,
                              child: Icon(
                                Icons.person,
                                size: widget.size * 0.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                  ),
                ),

                // Status indicator
                if (widget.showStatus)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: widget.size * 0.25,
                      height: widget.size * 0.25,
                      decoration: BoxDecoration(
                        color: widget.isOnline
                            ? AppColors.success
                            : AppColors.textHint,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surface,
                          width: 2,
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

/// Professional tab indicator
class ProfessionalTabBar extends StatelessWidget {
  final List<String> tabs;
  final TabController? controller;
  final Function(int)? onTap;
  final double height;
  final double indicatorHeight;
  final Color indicatorColor;
  final Color backgroundColor;
  final Color labelColor;
  final Color unselectedLabelColor;

  const ProfessionalTabBar({
    Key? key,
    required this.tabs,
    this.controller,
    this.onTap,
    this.height = 48,
    this.indicatorHeight = 3,
    this.indicatorColor = AppColors.primary,
    this.backgroundColor = Colors.transparent,
    this.labelColor = AppColors.textPrimary,
    this.unselectedLabelColor = AppColors.textSecondary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: AppColors.surfaceLight,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: controller,
        onTap: onTap,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: indicatorColor,
              width: indicatorHeight,
            ),
          ),
        ),
        labelColor: labelColor,
        unselectedLabelColor: unselectedLabelColor,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }
}

/// Data visualization card with subtle animations
class DataCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final bool showIncreaseIndicator;
  final double changePercentage;
  final VoidCallback? onTap;
  final List<Color>? gradientColors;

  const DataCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor = AppColors.primary,
    this.showIncreaseIndicator = false,
    this.changePercentage = 0.0,
    this.onTap,
    this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPositive = changePercentage >= 0;
    final changeColor = isPositive ? AppColors.success : AppColors.error;

    return GestureDetector(
      onTap: onTap,
      child: ProfessionalCard(
        height: 120,
        gradientColors: gradientColors ??
            [
              AppColors.surface,
              Color.lerp(AppColors.surface, AppColors.surfaceLight, 0.5) ??
                  AppColors.surfaceLight,
            ],
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Value
            Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Change indicator
            if (showIncreaseIndicator) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    color: changeColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${isPositive ? '+' : ''}${changePercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: changeColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Subtle notification badge
class NotificationBadge extends StatelessWidget {
  final Widget child;
  final int count;
  final Color color;
  final double size;
  final bool showZero;

  const NotificationBadge({
    Key? key,
    required this.child,
    required this.count,
    this.color = AppColors.accent,
    this.size = 16,
    this.showZero = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final showBadge = count > 0 || showZero;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (showBadge)
          Positioned(
            top: -5,
            right: -5,
            child: Container(
              padding: EdgeInsets.all(size * 0.25),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.surface,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              constraints: BoxConstraints(
                minWidth: size,
                minHeight: size,
              ),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
