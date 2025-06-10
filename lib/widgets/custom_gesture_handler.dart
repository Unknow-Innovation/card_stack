/// Copyright © 2025 Unknow-Innovation
/// This file is part of the proprietary CardStack library.
/// Unauthorized use or distribution is strictly prohibited.

import 'package:card_stack/config/enums.dart';
import 'package:card_stack/controllers/card_swipe_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomGestureHandler<T> extends StatefulWidget {
  final Widget child;
  final T item;
  final Widget? likePositionIndicater;
  final Widget? dislikePositionIndicater;
  final Widget? superLikePositionIndicater;

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
    this.likePositionIndicater,
    this.dislikePositionIndicater,
    this.superLikePositionIndicater,
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

                return Stack(
                  children: [
                    Transform(
                      transform: Matrix4.identity()
                        ..translate(offset.dx, offset.dy)
                        ..rotateZ(-rotation)
                        ..scale(scale),
                      child: RepaintBoundary(child: child),
                    ),

                    // Directional Stickers
                    if (widget.likePositionIndicater != null)
                      _buildAnimatedSticker(
                        direction: Direction.right,
                        offset: offset,
                        sticker: widget.likePositionIndicater,
                      ),
                    if (widget.dislikePositionIndicater != null)
                      _buildAnimatedSticker(
                        direction: Direction.left,
                        offset: offset,
                        sticker: widget.dislikePositionIndicater,
                      ),
                    if (widget.superLikePositionIndicater != null)
                      _buildAnimatedSticker(
                        direction: Direction.up,
                        offset: offset,
                        sticker: widget.superLikePositionIndicater,
                      ),
                  ],
                );
              },
              child: widget.child,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedSticker({
    required Direction direction,
    required Offset offset,
    required Widget? sticker,
  }) {
    final controller = widget.controller!;
    final drag = controller.dragPosition;

    // Determine if this sticker should be visible
    final show = controller.dragDirection == direction;
    final opacity = show
        ? (drag.distance / (controller.threshold + 120)).clamp(0.0, 1.0)
        : 0.0;

    // Entrance animation: sticker slides in from opposite direction
    Offset translation = Offset.zero;
    final size = MediaQuery.sizeOf(context);
    switch (direction) {
      case Direction.right:
        translation =
            Offset(-(size.width * 0.5) + offset.dx / 2, 0); // Enter from left
        break;
      case Direction.left:
        translation =
            Offset(size.width * 0.5 + offset.dx / 2, 0); // Enter from right
        break;
      case Direction.up:
        translation =
            Offset(0, (size.height * 0.4) + offset.dy / 2); // Enter from bottom
        break;
      case Direction.down:
        // translation =
        //     Offset(0, -50 + offset.dy / 4); // Optional: enter from top
        break;
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 100),
          opacity: opacity,
          child: Transform.translate(
            offset: translation,
            child: Center(
              child: sticker,
            ),
          ),
        ),
      ),
    );
  }
}
