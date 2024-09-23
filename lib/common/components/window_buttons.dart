import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

class WindowButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(),
        MaximizeWindowButton(),
        CloseWindowButton(),
      ],
    );
  }
}

class MinimizeWindowButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
      child: TextButton(
        onPressed: () {
          appWindow.minimize();
        },
        child: Icon(Icons.minimize, size: 16),
      ),
    );
  }
}

class MaximizeWindowButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
      child: TextButton(
        onPressed: () {
          appWindow.maximizeOrRestore();
        },
        child: Icon(Icons.crop_square, size: 16),
      ),
    );
  }
}

class CloseWindowButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
      child: TextButton(
        onPressed: () {
          appWindow.close();
        },
        child: Icon(Icons.close, size: 16),
      ),
    );
  }
}
