/// Copyright © 2025 Unknow-Innovation
/// This file is part of the proprietary CardStack library.
/// Unauthorized use or distribution is strictly prohibited.

import 'dart:math';

import 'package:card_stack/controllers/card_swipe_controller.dart';
import 'package:card_stack/widgets/custom_gesture_handler.dart';
import 'package:flutter/material.dart';
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
  Widget _buildCard(T item, bool isTopCard, int visualIndex) {
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
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(visibleItems.length, (i) {
          final item = visibleItems[i];
          final isTop = i == visibleItems.length - 1;
          final visualIndex = visibleItems.length - 1 - i;

          if (isTop) widget.controller.setItem = item;

          return Positioned(
            top: 0,
            child: _buildCard(item, isTop, visualIndex),
          );
        }),
      ),
    );
  }
}
