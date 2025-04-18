import 'package:card_stack/config/enums.dart';
import 'package:card_stack/controllers/card_swipe_controller.dart';
import 'package:card_stack/widgets/custom_gesture_handler.dart';
import 'package:flutter/material.dart';
export 'package:card_stack/config/enums.dart';
export 'package:card_stack/card_stack.dart';
export 'package:card_stack/controllers/card_swipe_controller.dart';

class CardStack<T> extends StatelessWidget {
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
  final CardSwipeController? controller;

  const CardStack({
    super.key,
    required this.items,
    required this.cardBuilder,
    required this.onSwipe,
    required this.emptyWidget,
    required this.loadingWidget,
    required this.isLoading,
    this.controller,
    this.cardWidth = 300,
    this.cardHeight = 400,
    this.scaleFactor = 0.9,
    this.rotationFactor = 0.7,
    this.threshold = 150.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.backgroundCardCount = 2,
  });

  Widget _buildCard(T item) {
    return CustomGestureHandler(
      onSwipe: (direction) {
        onSwipe(item, direction);
      },
      threshold: threshold,
      rotationFactor: rotationFactor,
      scaleFactor: scaleFactor,
      animationDuration: animationDuration,
      child: Container(
        width: cardWidth,
        height: cardHeight,
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
        child: cardBuilder(item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: loadingWidget,
      );
    }
    if (items.isEmpty) {
      return Center(
        child: emptyWidget,
      );
    }
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...List.generate(
            items.length,
            (index) {
              return Positioned(
                top: 0,
                child: _buildCard((items[index])),
              );
            },
          )
        ],
      ),
    );
  }
}
