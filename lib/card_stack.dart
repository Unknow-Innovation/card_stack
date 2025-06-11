/// Copyright © 2025 Unknow-Innovation
/// This file is part of the proprietary CardStack library.
/// Unauthorized use or distribution is strictly prohibited.

import 'dart:math';

import 'package:card_stack/config/enums.dart';
import 'package:card_stack/controllers/card_swipe_controller.dart';
import 'package:card_stack/widgets/custom_gesture_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
export 'package:card_stack/config/enums.dart';
export 'package:card_stack/card_stack.dart';
export 'package:card_stack/controllers/card_swipe_controller.dart';
export 'package:provider/provider.dart';

class CardStack<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(T item) cardBuilder;
  final double cardWidth;
  final double cardHeight;
  final double scaleFactor;
  final double rotationFactor;
  final double threshold;
  final Size screenSize;
  final Decoration? decoration;
  final Duration animationDuration;
  final int backgroundCardCount;
  final bool isLoading;
  final CardSwipeController controller;
  final Widget emptyWidget;
  final Widget loadingWidget;
  final Widget? likePositionIndicater;
  final Widget? dislikePositionIndicater;
  final Widget? superLikePositionIndicater;

  const CardStack({
    super.key,
    required this.items,
    required this.cardBuilder,
    required this.emptyWidget,
    required this.loadingWidget,
    required this.isLoading,
    required this.controller,
    required this.screenSize,
    this.decoration,
    this.likePositionIndicater,
    this.dislikePositionIndicater,
    this.superLikePositionIndicater,
    this.cardWidth = 300,
    this.cardHeight = 400,
    this.scaleFactor = 0.9,
    this.rotationFactor = 0.7,
    this.threshold = 150.0,
    this.animationDuration = const Duration(milliseconds: 600),
    this.backgroundCardCount = 2,
  });

  @override
  State<CardStack<T>> createState() => _CardStackState<T>();
}

class _CardStackState<T> extends State<CardStack<T>> {
  Widget _buildCard(T item, bool isTopCard, int visualIndex, Size screenSize) {
    final card = Container(
      width: widget.cardWidth,
      height: widget.cardHeight,
      decoration: widget.decoration ??
          BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: Offset(6, 6)),
            ],
          ),
      child: widget.cardBuilder(item),
    );

    return isTopCard
        ? CustomGestureHandler<T>(
            item: item,
            controller: widget.controller,
            screenSize: screenSize,
            threshold: widget.threshold,
            rotationFactor: widget.rotationFactor,
            scaleFactor: widget.scaleFactor,
            animationDuration: widget.animationDuration,
            dislikePositionIndicater: widget.dislikePositionIndicater,
            likePositionIndicater: widget.likePositionIndicater,
            superLikePositionIndicater: widget.superLikePositionIndicater,
            child: card,
          )
        : RepaintBoundary(child: card);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Center(child: widget.loadingWidget);
    }
    if (widget.items.isEmpty) {
      return Center(child: widget.emptyWidget);
    }

    final visibleCount =
        min(widget.items.length, widget.backgroundCardCount + 1);
    final visibleItems = widget.items
        .sublist(widget.items.length - visibleCount, widget.items.length)
        .toList();

    return Center(
      child: ChangeNotifierProvider.value(
        value: widget.controller,
        child: Consumer<CardSwipeController>(
          builder: (context, controller, child) {
            return AnimatedBuilder(
              animation: controller.animationController,
              builder: (context, child) {
                final offset = controller.isSwiping
                    ? controller.animation.value
                    : controller.dragPosition;
                return Stack(alignment: Alignment.center, children: [
                  child!,
                  // Directional Stickers
                  if (widget.likePositionIndicater != null)
                    _buildAnimatedSticker(
                      controller: controller,
                      size: widget.screenSize,
                      direction: Direction.right,
                      offset: offset,
                      sticker: widget.likePositionIndicater,
                    ),
                  if (widget.dislikePositionIndicater != null)
                    _buildAnimatedSticker(
                      controller: controller,
                      size: widget.screenSize,
                      direction: Direction.left,
                      offset: offset,
                      sticker: widget.dislikePositionIndicater,
                    ),
                  if (widget.superLikePositionIndicater != null)
                    _buildAnimatedSticker(
                      controller: controller,
                      size: widget.screenSize,
                      direction: Direction.up,
                      offset: offset,
                      sticker: widget.superLikePositionIndicater,
                    ),
                ]);
              },
              child: Stack(
                children: List.generate(visibleItems.length, (i) {
                  final item = visibleItems[i];
                  final isTop = i == visibleItems.length - 1;
                  final visualIndex = visibleItems.length - 1 - i;

                  if (isTop) widget.controller.setItem = item;

                  return Positioned(
                    top: 0,
                    child: _buildCard(
                      item,
                      isTop,
                      visualIndex,
                      widget.screenSize,
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedSticker({
    required Direction direction,
    required Offset offset,
    required Size size,
    required Widget? sticker,
    required CardSwipeController controller,
  }) {
    // final controller = widget.controller!;
    final drag = controller.dragPosition;

    // Determine if this sticker should be visible
    final show = controller.dragDirection == direction;
    final opacity = show
        ? (drag.distance / (controller.threshold + 120)).clamp(0.0, 1.0)
        : 0.0;

    // Entrance animation: sticker slides in from opposite direction
    Offset translation = Offset.zero;

    switch (direction) {
      case Direction.right:
        translation =
            Offset(-(size.width * 0.5) + offset.dx / 4, 0); // Enter from left
        break;
      case Direction.left:
        translation =
            Offset(size.width * 0.5 + offset.dx / 4, 0); // Enter from right
        break;
      case Direction.up:
        translation =
            Offset(0, (size.height * 0.4) + offset.dy / 4); // Enter from bottom
        break;
      case Direction.down:
        // translation =
        //     Offset(0, -50 + offset.dy / 4); // Optional: enter from top
        break;
    }

    return Positioned.fill(
      child: RepaintBoundary(
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
      ),
    );
  }
}
