import 'package:card_stack/config/enums.dart';
import 'package:card_stack/widgets/custom_gesture_handler.dart';
import 'package:flutter/material.dart';

import 'dart:math' as math;

export 'package:card_stack/config/enums.dart';
export 'package:card_stack/card_stack.dart';

class CardStack<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(T item) cardBuilder;
  final Function(T item, Direction direction) onSwipe;
  final double cardWidth;
  final double cardHeight;
  final double scaleFactor;
  final double rotationFactor;
  final double threshold;
  final Duration animationDuration;
  final int backgroundCardCount;
  final Widget emptyWidget;
  final Widget loadingWidget;
  final bool isLoading;

  const CardStack({
    super.key,
    required this.items,
    required this.emptyWidget,
    required this.loadingWidget,
    required this.cardBuilder,
    required this.onSwipe,
    this.cardWidth = 300,
    this.cardHeight = 400,
    this.scaleFactor = 0.9,
    this.rotationFactor = 0.7,
    this.threshold = 100.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.backgroundCardCount = 2,
    this.isLoading = false,
  });

  @override
  State<CardStack<T>> createState() => _CardStackState<T>();
}

class _CardStackState<T> extends State<CardStack<T>> {
  int _currentIndex = 0;
  final List<Widget> _cards = [];

  @override
  void initState() {
    super.initState();
    _initializeCards();
  }

  void _initializeCards() {
    _cards.clear();

    // for (int i = 0; i < widget.items.length; i++) {
    //   final item = widget.items[i];
    //   final card = _buildCard(item);
    //   _cards.add(card);
    // }

    for (var item in widget.items) {
      final card = _buildCard(item);
      _cards.add(card);
    }
  }

  // Widget _buildCard(T item) {
  //   return 
  // }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Center(
        child: widget.loadingWidget,
      );
    }
    if (_currentIndex >= widget.items.length) {
      return const Center(
        child: widget.emptyWidget,
      );
    }

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...List.generate(
            widget.items.length,
            (index) {
              final cardIndex = index + 1;
              if (cardIndex >= widget.items.length)
                return const SizedBox.shrink();

              // final scale = 1.0 - (cardIndex) * (1.0 - widget.scaleFactor);
              // final offset = cardIndex * 10.0;

              return Positioned(
                top: 0,
                child: CustomGestureHandler(
      onSwipe: (direction) {
        widget.onSwipe(item, direction);
        setState(() {
          _currentIndex++;
          _initializeCards();
        });
      },
      threshold: widget.threshold,
      rotationFactor: widget.rotationFactor,
      scaleFactor: widget.scaleFactor,
      animationDuration: widget.animationDuration,
      child: Container(
        width: widget.cardWidth,
        height: widget.cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: widget.cardBuilder(item),
      ),
    ),
              );
            },
          ),
          // Current card
          _cards.first,
        ],
      ),
    );
  }
}
