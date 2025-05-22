/// Copyright © 2025 Unknow-Innovation
/// This file is part of the proprietary CardStack library.
/// Unauthorized use or distribution is strictly prohibited.

import 'package:card_stack/controllers/card_swipe_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomGestureHandler<T> extends StatefulWidget {
  final Widget child;
  final T item;

  final double threshold;
  final double rotationFactor;
  final double scaleFactor;
  final Duration animationDuration;
  final CardSwipeController? controller;

  const CustomGestureHandler({
    super.key,
    required this.child,
    required this.item,
    this.controller,
    this.threshold = 150.0,
    this.rotationFactor = 0.1,
    this.scaleFactor = 0.9,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<CustomGestureHandler> createState() => _CustomGestureHandlerState();
}

class _CustomGestureHandlerState extends State<CustomGestureHandler>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.controller,
      child: Consumer<CardSwipeController>(
        builder: (context, controller, child) {
          return GestureDetector(
            onPanStart: controller.onPanStart,
            onPanUpdate: controller.onPanUpdate,
            onPanEnd: controller.onPanEnd,
            child: AnimatedBuilder(
              animation: controller.animationController,
              builder: (context, child) {
                final offset = controller.isSwiping
                    ? controller.animation.value
                    : controller.dragPosition;
                final rotation = controller.isSwiping
                    ? controller.rotationAnimation.value
                    : controller.rotation;
                final scale = controller.isSwiping
                    ? controller.scaleAnimation.value
                    : controller.scale;

                return Transform(
                  transform: Matrix4.identity()
                    ..translate(offset.dx, offset.dy)
                    ..rotateZ(-rotation)
                    ..scale(scale),
                  child: RepaintBoundary(child: child),
                );
              },
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
