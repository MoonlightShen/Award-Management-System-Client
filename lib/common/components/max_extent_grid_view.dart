import 'package:flutter/material.dart';

class GridBlockStyle {
  final Color backgroundColor;
  final double backgroundCornerRadius;

  const GridBlockStyle({
    this.backgroundColor = const Color.fromARGB(255, 231, 226, 192),
    this.backgroundCornerRadius = 8,
  });
}

class MaxExtentGridView<T> extends StatefulWidget {
  const MaxExtentGridView({
    super.key,
    required this.blockWidth,
    required this.blockHeight,
    this.blockStyle = const GridBlockStyle(),
    required this.size, required this.getItem,
  });
  final double blockWidth;
  final double blockHeight;
  final int size;
  final GridBlockStyle blockStyle;
  final T Function(int) getItem;

  @override
  State<MaxExtentGridView> createState() => _MaxExtentGridViewState();
}

class _MaxExtentGridViewState extends State<MaxExtentGridView> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          itemCount: widget.size,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1,
                maxCrossAxisExtent: widget.blockWidth),
            itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      widget.blockStyle.backgroundCornerRadius,
                    ),
                    color: widget.blockStyle.backgroundColor),
                child: Center(
                  child: widget.getItem(index),
                )));
      },
    );
  }
}
