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
  final Widget? likeCompleteIndicater;
  final Widget? dislikeCompleteIndicater;
  final Widget? superLikeCompleteIndicater;

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
    this.likeCompleteIndicater,
    this.dislikeCompleteIndicater,
    this.superLikeCompleteIndicater,
  });

  @override
  State<CardStack<T>> createState() => _CardStackState<T>();
}

class _CardStackState<T> extends State<CardStack<T>> {
  bool _showCompleteIndicator = false;
  Direction? _completedDirection;

  @override
  void initState() {
    super.initState();
    widget.controller.onSwipeCompleted = _handleSwipeComplete;
  }

  void _handleSwipeComplete() {
    print("Profile Liked");
    setState(() {
      _completedDirection = widget.controller.dragDirection;
      _showCompleteIndicator = true;
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _showCompleteIndicator = false;
          _completedDirection = null;
        });
      }
    });
  }

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
                      showCompleteIndicator: _showCompleteIndicator,
                    ),
                  if (widget.dislikePositionIndicater != null)
                    _buildAnimatedSticker(
                      controller: controller,
                      size: widget.screenSize,
                      direction: Direction.left,
                      offset: offset,
                      sticker: widget.dislikePositionIndicater,
                      showCompleteIndicator: _showCompleteIndicator,
                    ),
                  if (widget.superLikePositionIndicater != null)
                    _buildAnimatedSticker(
                      controller: controller,
                      size: widget.screenSize,
                      direction: Direction.up,
                      offset: offset,
                      sticker: widget.superLikePositionIndicater,
                      showCompleteIndicator: _showCompleteIndicator,
                    ),

                  if (_showCompleteIndicator && _completedDirection != null)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Center(
                          child:
                              _getCompleteIndicatorWidget(_completedDirection!),
                        ),
                      ),
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

  Widget _getCompleteIndicatorWidget(Direction direction) {
    switch (direction) {
      case Direction.right:
        return widget.likeCompleteIndicater ?? const SizedBox.shrink();
      case Direction.left:
        return widget.dislikeCompleteIndicater ?? const SizedBox.shrink();
      case Direction.up:
        return widget.superLikeCompleteIndicater ?? const SizedBox.shrink();
      case Direction.down:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAnimatedSticker({
    required Direction direction,
    required Offset offset,
    required Size size,
    required Widget? sticker,
    required CardSwipeController controller,
    required bool showCompleteIndicator,
  }) {
    // final controller = widget.controller!;
    final drag = controller.dragPosition;

    // Determine if this sticker should be visible
    final show = controller.dragDirection == direction;
    final opacity = show && !showCompleteIndicator
        ? ((drag.distance) / (controller.threshold + 50)).clamp(0.0, 1.0)
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
        translation = Offset(
            0, (size.height * 0.4) + (offset.dy) / 4.7); // Enter from bottom
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
