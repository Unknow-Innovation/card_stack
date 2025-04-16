import 'package:card_stack/config/enums.dart';
import 'package:flutter/material.dart';

class CustomGestureHandler extends StatefulWidget {
  final Widget child;
  final Function(Direction) onSwipe;
  final double threshold;
  final double rotationFactor;
  final double scaleFactor;
  final Duration animationDuration;

  const CustomGestureHandler({
    super.key,
    required this.child,
    required this.onSwipe,
    this.threshold = 100.0,
    this.rotationFactor = 0.1,
    this.scaleFactor = 0.9,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<CustomGestureHandler> createState() => _CustomGestureHandlerState();
}

class _CustomGestureHandlerState extends State<CustomGestureHandler>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  Offset _dragStart = Offset.zero;
  Offset _dragPosition = Offset.zero;
  bool _isDragging = false;
  double _rotation = 0.0;
  double _scale = 1.0;
  bool _isSwiping = false;
  bool _shouldSwipe = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _dragStart = details.globalPosition;
    _isDragging = true;
    _isSwiping = false;
    _shouldSwipe = false;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    setState(() {
      _dragPosition = details.globalPosition - _dragStart;

      // Calculate rotation based on horizontal drag
      _rotation = (_dragPosition.dx / widget.threshold) * widget.rotationFactor;

      // Calculate scale based on vertical drag
      _scale = 1.0 -
          (_dragPosition.dy.abs() / (widget.threshold * 2)) *
              (1 - widget.scaleFactor);

      // Check if we've reached the threshold
      if (_dragPosition.distance > widget.threshold) {
        _shouldSwipe = true;
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDragging) return;

    final velocity = details.velocity.pixelsPerSecond;
    // final dragDistance = _dragPosition.distance;

    if (_shouldSwipe || velocity.distance > 500) {
      _startSwipeAnimation();
    } else {
      _resetCard();
    }
  }

  void _startSwipeAnimation() {
    final screenSize = MediaQuery.sizeOf(context);
    final direction = _calculateSwipeDirection();
    final endOffset = _calculateEndOffset(direction, screenSize);

    _animation = Tween<Offset>(
      begin: _dragPosition,
      end: endOffset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: _rotation,
      end: direction == Direction.right ? 0.5 : -0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: _scale,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    setState(() {
      _isSwiping = true;
    });

    _controller.forward().then((_) {
      widget.onSwipe(direction);
      _resetCard();
    });
  }

  Direction _calculateSwipeDirection() {
    final isHorizontalSwipe = _dragPosition.dx.abs() > _dragPosition.dy.abs();

    if (isHorizontalSwipe) {
      return _dragPosition.dx > 0 ? Direction.right : Direction.left;
    } else {
      return _dragPosition.dy < 0 ? Direction.up : Direction.down;
    }
  }

  Offset _calculateEndOffset(Direction direction, Size screenSize) {
    switch (direction) {
      case Direction.right:
        return Offset(screenSize.width * 2, _dragPosition.dy);
      case Direction.left:
        return Offset(-screenSize.width * 2, _dragPosition.dy);
      case Direction.up:
        return Offset(_dragPosition.dx, -screenSize.height * 2);
      case Direction.down:
        return Offset(_dragPosition.dx, screenSize.height * 2);
    }
  }

  void _resetCard() {
    setState(() {
      _dragPosition = Offset.zero;
      _rotation = 0.0;
      _scale = 1.0;
      _isDragging = false;
      _isSwiping = false;
      _shouldSwipe = false;
    });
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final offset = _isSwiping ? _animation.value : _dragPosition;
          final rotation = _isSwiping ? _rotationAnimation.value : _rotation;
          final scale = _isSwiping ? _scaleAnimation.value : _scale;

          return Transform(
            transform: Matrix4.identity()
              ..translate(offset.dx, offset.dy)
              ..rotateZ(rotation)
              ..scale(scale),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
