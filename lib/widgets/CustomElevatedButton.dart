import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocal_emotion/utils/colors.dart';

class CustomElevatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? primaryColor;
  final Color? textColor;
  final bool isAnimated;
  final double width;
  final double height;
  final double borderRadius;
  final IconData? icon;
  final bool isOutlined;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.primaryColor,
    this.textColor,
    this.isAnimated = false,
    this.width = 150,
    this.height = 48,
    this.borderRadius = 8,
    this.icon,
    this.isOutlined = false,
  });

  @override
  State<CustomElevatedButton> createState() => _CustomElevatedButtonState();
}

class _CustomElevatedButtonState extends State<CustomElevatedButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
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
    final textColor =
        widget.textColor ?? (widget.isOutlined ? primaryColor : Colors.white);

    Widget buttonChild() {
      return Container(
        width: widget.width.w,
        height: widget.height.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          color: widget.isOutlined ? Colors.transparent : primaryColor,
          border: widget.isOutlined
              ? Border.all(
                  color: primaryColor,
                  width: 1.5,
                )
              : null,
          boxShadow: !widget.isOutlined && !_isPressed
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon!,
                  color: textColor,
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
              ],
              Text(
                widget.text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          if (widget.isAnimated) _controller.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          if (widget.isAnimated) _controller.reverse();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          if (widget.isAnimated) _controller.reverse();
        },
        onTap: widget.onPressed,
        child: widget.isAnimated
            ? AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: buttonChild(),
                  );
                },
              )
            : buttonChild(),
      ),
    );
  }
}
