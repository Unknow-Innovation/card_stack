import 'package:card_stack/config/enums.dart';
import 'package:card_stack/controllers/card_swipe_controller.dart';
import 'package:card_stack/widgets/custom_gesture_handler.dart';
import 'package:flutter/material.dart';
export 'package:card_stack/config/enums.dart';
export 'package:card_stack/card_stack.dart';
export 'package:card_stack/controllers/card_swipe_controller.dart';

class CardStack<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(T item) cardBuilder;

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
  final CardSwipeController controller;

  const CardStack({
    super.key,
    required this.items,
    required this.cardBuilder,
    required this.emptyWidget,
    required this.loadingWidget,
    required this.isLoading,
    required this.controller,
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
  int _activeCardIndex = 0;

  // @override
  // void initState() {
  //   super.initState();
  //   _controller = widget.controller
  // }

  // @override
  // void dispose() {
  //   if (widget.controller == null) {
  //     _controller.dispose();
  //   }
  //   super.dispose();
  // }

  Widget _buildCard(T item, int index) {
    // Only apply gesture handling to the active card
    if (index != widget.items.length - 1) {
      return RepaintBoundary(
        child: Container(
          width: widget.cardWidth,
          height: widget.cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: widget.cardBuilder(item),
        ),
      );
    }
    widget.controller.setItem = item;
    return CustomGestureHandler<T>(
      item: item,
      controller: widget.controller,
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
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: widget.cardBuilder(item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(widget.items.length);
    if (widget.isLoading) {
      return Center(
        child: widget.loadingWidget,
      );
    }
    if (widget.items.isEmpty) {
      return Center(
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
              return Positioned(
                top: 0,
                child: _buildCard(widget.items[index], index),
              );
            },
          )
        ],
      ),
    );
  }

  // Method to programmatically swipe the active card
  void swipeCard(Direction direction) {
    if (_activeCardIndex < widget.items.length) {
      widget.controller.animateToDirection(direction);
    }
  }

  // Method to reset the stack
  void resetStack() {
    setState(() {
      _activeCardIndex = 0;
    });
  }
}
