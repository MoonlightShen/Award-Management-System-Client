import 'package:flutter/material.dart';

class VisibilitySwitchWidget extends StatefulWidget {
  final Widget visibleWidget;
  final Widget invisibleWidget;
  bool visibility;

  VisibilitySwitchWidget(
      {super.key,
      required this.visibleWidget,
      required this.invisibleWidget,
      this.visibility = false,});

  @override
  State<StatefulWidget> createState() => _VisibilitySwitchWidgetState();
}

class _VisibilitySwitchWidgetState extends State<VisibilitySwitchWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        widget.visibility ? widget.visibleWidget : widget.invisibleWidget,
        const SizedBox(
          width: 2,
        ),
        IconButton(
            onPressed: () => setState(() {
                  widget.visibility = !widget.visibility;
                }),
            icon: Icon(
                widget.visibility ? Icons.visibility : Icons.visibility_off))
      ],
    );
  }
}
