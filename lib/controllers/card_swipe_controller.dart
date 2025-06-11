/// Copyright © 2025 Unknow-Innovation
/// This file is part of the proprietary CardStack library.
/// Unauthorized use or distribution is strictly prohibited.

import 'package:card_stack/config/enums.dart';
import 'package:flutter/material.dart';

class CardSwipeController<T> extends ChangeNotifier {
  // Animation controller
  late AnimationController animationController;
  late Animation<Offset> animation;
  late Animation<double> rotationAnimation;
  late Animation<double> scaleAnimation;
  T? _item;

  set setItem(T item) {
    _item = item;
  }

  T? get item => _item;

  // State variables
  Offset _dragStart = Offset.zero;
  Offset _dragPosition = Offset.zero;
  bool _isDragging = false;
  double _rotation = 0.0;
  double _scale = 1.0;
  bool _isSwiping = false;
  bool _shouldSwipe = false;

  // Configuration
  final double threshold;
  final double rotationFactor;
  final double scaleFactor;
  final Duration animationDuration;
  final Size screenSize;
  final Function(Direction, T) onSwipe;

  // Getters
  Offset get dragPosition => _dragPosition;
  double get rotation => _rotation;
  double get scale => _scale;
  bool get isDragging => _isDragging;
  bool get isSwiping => _isSwiping;
  bool get shouldSwipe => _shouldSwipe;

  CardSwipeController({
    required TickerProvider vsync,
    required this.screenSize,
    required this.onSwipe,
    this.threshold = 150.0,
    this.rotationFactor = 0.15,
    this.scaleFactor = 0.9,
    this.animationDuration = const Duration(milliseconds: 300),
  }) {
    animationController = AnimationController(
      vsync: vsync,
      duration: animationDuration,
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void onPanStart(DragStartDetails details) {
    _dragStart = details.globalPosition;
    _isDragging = true;
    _isSwiping = false;
    _shouldSwipe = false;
    notifyListeners();
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    _dragPosition = details.globalPosition - _dragStart;

    // Calculate rotation based on horizontal drag
    _rotation = (_dragPosition.dx / 100) * rotationFactor;

    // Calculate scale based on vertical drag
    _scale = 1.0 - (_dragPosition.dy.abs() / (100 * 2)) * (1 - scaleFactor);

    _shouldSwipe = _dragPosition.distance > threshold;

    notifyListeners();
  }

  void onPanEnd(DragEndDetails details) {
    if (!_isDragging) return;

    final velocity = details.velocity.pixelsPerSecond;
    debugPrint(_dragPosition.distance.toString());

    if (_shouldSwipe || velocity.distance > 500) {
      _startSwipeAnimation(null);
    } else {
      _startResetAnimation();
    }
  }

  void _startSwipeAnimation(Direction? direction) {
    final calculatedDirection = _calculateSwipeDirection();

    final endOffset =
        _calculateEndOffset(direction ?? calculatedDirection, screenSize);

    animation = Tween<Offset>(
      begin: _dragPosition,
      end: endOffset,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));

    rotationAnimation = Tween<double>(
      begin: _rotation,
      end: (direction ?? calculatedDirection) == Direction.right ? 0.5 : -0.5,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));

    scaleAnimation = Tween<double>(
      begin: _scale,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));

    _isSwiping = true;
    notifyListeners();

    animationController.forward().then((_) {
      onSwipe(direction ?? calculatedDirection, _item as T);
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

  void animateToDirection(Direction direction) =>
      _startSwipeAnimation(direction);

  void _startResetAnimation() {
    final resetAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
    );

    animation = Tween<Offset>(
      begin: _dragPosition,
      end: Offset.zero,
    ).animate(resetAnimation);

    rotationAnimation = Tween<double>(
      begin: _rotation,
      end: 0.0,
    ).animate(resetAnimation);

    scaleAnimation = Tween<double>(
      begin: _scale,
      end: 1.0,
    ).animate(resetAnimation);

    _isSwiping = true;
    notifyListeners();

    animationController.forward(from: 0.0).then((_) {
      animationController.reset();
      _dragPosition = Offset.zero;
      _rotation = 0.0;
      _scale = 1.0;
      _isDragging = false;
      _isSwiping = false;
      _shouldSwipe = false;
      notifyListeners();
    });
  }

  void _resetCard() {
    _dragPosition = Offset.zero;
    _rotation = 0.0;
    _scale = 1.0;
    _isDragging = false;
    _isSwiping = false;
    _shouldSwipe = false;
    animationController.reset();
    notifyListeners();
  }

  void resetWithDirection({
    required Direction swipeDirection,
    required T data,
  }) {
    _item = data;

    final startOffset = _calculateEndOffset(swipeDirection, screenSize);

    print("Start Offset resetWithDirection $startOffset");

    animation = Tween<Offset>(
      begin: startOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
    ));

    rotationAnimation = Tween<double>(
      begin: swipeDirection == Direction.right ? 0.5 : -0.5,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
    ));

    scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
    ));

    _isSwiping = true;
    notifyListeners();

    animationController.forward(from: 0.0).then((_) {
      _resetCard();
    });
  }

  Direction? get dragDirection {
    if (_dragPosition == Offset.zero) return null;
    final isHorizontal = _dragPosition.dx.abs() > _dragPosition.dy.abs();
    if (isHorizontal) {
      return _dragPosition.dx > 0.1
          ? Direction.right
          : _dragPosition.dx < -0.1
              ? Direction.left
              : null;
    } else {
      return _dragPosition.dy < -0.1
          ? Direction.up
          : _dragPosition.dy > 0.1
              ? Direction.down
              : null;
    }
  }
}
