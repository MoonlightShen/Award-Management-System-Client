import 'package:flutter/material.dart';

class GridBlockStyle {
  final Color backgroundColor;
  final double backgroundCornerRadius;

  const GridBlockStyle({
    this.backgroundColor = const Color.fromARGB(255, 231, 226, 192),
    this.backgroundCornerRadius = 8,
  });
}

class FixedCrossCountGridView<T> extends StatefulWidget {
  const FixedCrossCountGridView({
    super.key,
    required this.crossAxisCount,
    this.blockStyle = const GridBlockStyle(),
    required this.size, required this.getItem,
  });
  final int crossAxisCount;
  final int size;
  final GridBlockStyle blockStyle;
  final T Function(int index) getItem;

  @override
  State<FixedCrossCountGridView> createState() => _FixedCrossCountGridViewState();
}

class _FixedCrossCountGridViewState extends State<FixedCrossCountGridView> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          itemCount: widget.size,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1,
                 crossAxisCount: widget.crossAxisCount),
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
