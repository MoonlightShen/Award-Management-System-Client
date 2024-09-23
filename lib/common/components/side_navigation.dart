import 'package:flutter/material.dart';

class NavigationItem {
  final String? content;
  final IconData defaultIcon;
  final IconData selectedIcon;
  final Color? defaultTextColor;
  final Color? defaultBackgroundColor;
  final Color? selectedTextColor;
  final Color? selectedBackgroundColor;

  NavigationItem({
    this.content,
    required this.defaultIcon,
    required this.selectedIcon,
    this.defaultTextColor = const Color.fromARGB(255, 32, 34, 36),
    this.defaultBackgroundColor = Colors.white,
    this.selectedTextColor = Colors.white,
    this.selectedBackgroundColor = const Color.fromARGB(255, 123, 198, 243),
  });
}

class NavigationBox {
  final String title;
  final List<NavigationItem> contents;
  final Color? defaultTitleColor;

  NavigationBox({
    required this.title,
    required this.contents,
    this.defaultTitleColor = const Color.fromARGB(255, 162, 162, 162),
  });
}

class SideNavigationRail extends StatefulWidget {
  final List<NavigationBox> boxes;
  final Function(int, int) onItemSelected;
  final Color? backgroundColor;

  const SideNavigationRail({
    super.key,
    required this.boxes,
    required this.onItemSelected,
    this.backgroundColor = Colors.white,
  });

  @override
  State<StatefulWidget> createState() => _SideNavigationRailState();
}

class _SideNavigationRailState extends State<SideNavigationRail> {
  int _selectedBoxIndex = 0;
  int _selectedItemIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 245,
        color: widget.backgroundColor,
        child: ListView(
          children: List.generate(
              widget.boxes.length,
              (boxIndex) => Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 1,
                        color: const Color.fromARGB(255, 224, 224, 224),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(21, 21, 21, 0),
                        child: Text(
                          widget.boxes[boxIndex].title,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'AliMaMaShuHei',
                            color: widget.boxes[boxIndex].defaultTitleColor,
                            fontSize: 21,
                          ),
                        ),
                      ),
                      Column(
                        children: List.generate(
                            widget.boxes[boxIndex].contents.length,
                            (itemIndex) {
                          NavigationItem item =
                              widget.boxes[boxIndex].contents[itemIndex];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedBoxIndex = boxIndex;
                                _selectedItemIndex = itemIndex;
                              });
                              widget.onItemSelected(boxIndex, itemIndex);
                            },
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(21, 13, 21, 0),
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(26)),
                                color: _selectedBoxIndex == boxIndex &&
                                        _selectedItemIndex == itemIndex
                                    ? item.selectedBackgroundColor
                                    : item.defaultBackgroundColor,
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(13, 11, 13, 11),
                                child: Row(
                                  children: [
                                    Icon(item.defaultIcon),
                                    const SizedBox(width: 11),
                                    if (item.content != null)
                                      Text(
                                        item.content!,
                                        style: TextStyle(
                                          fontFamily: 'ALiMaMaShuHei',
                                          color:
                                              _selectedBoxIndex == boxIndex &&
                                                      _selectedItemIndex ==
                                                          itemIndex
                                                  ? item.selectedTextColor
                                                  : item.defaultTextColor,
                                          fontSize: 18,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16,)
                    ],
                  )),
        ));
  }
}
