import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ColumnItem {
  final String content;
  bool clicked;
  final double minWidth;
  final int weight;
  IconData? defaultIcon;
  IconData? clickedIcon;
  Function()? iconClickCallback;

  ColumnItem(
      {required this.content,
      required this.minWidth,
      this.weight = 1,
      this.clicked = false,
      this.defaultIcon,
      this.clickedIcon,
      this.iconClickCallback});
}

class CustomPaginatedDataTable<T> extends StatefulWidget {
  final String tableTitle;
  final List<ColumnItem> columns;
  final List<Widget> Function(T item) rowBuilder;
  final int dataNum;
  final List<T> dataList;
  final Future<List<T>> Function(int exceptedTotal) refreshData;

  final Function() refreshCallback;
  final Function() addCallback;
  final Function(Set<int> selectedIndexList) deleteCallback;
  final Function(Set<int> selectedIndexList) exportCallback;
  final bool refreshButton;
  final bool addButton;
  final bool deleteButton;
  final bool exportButton;
  final bool selectable;
  final Color backgroundColor = Colors.white;
  final Color headerColor = const Color.fromARGB(255, 242, 246, 252);

  const CustomPaginatedDataTable(
      {super.key,
      required this.dataNum,
      required this.tableTitle,
      required this.columns,
      required this.rowBuilder,
      required this.deleteCallback,
      required this.refreshCallback,
      required this.addCallback,
      required this.exportCallback,
      this.refreshButton = true,
      this.addButton = true,
      this.deleteButton = true,
      this.exportButton = true,
      this.selectable = true,
      required this.dataList,
      required this.refreshData});

  @override
  State<StatefulWidget> createState() => _CustomPaginatedTableState<T>();
}

class _CustomPaginatedTableState<T> extends State<CustomPaginatedDataTable<T>> {
  Future<List<T>> getCurrentPageData() async {
    if (currentPage * pageSize <= widget.dataList.length) {
      return widget.dataList
          .sublist(pageSize * currentPage, pageSize * (currentPage + 1));
    } else {
      List<T> newDataList = await widget.refreshData(currentPage * pageSize);
      widget.dataList.removeRange(0, widget.dataList.length);
      widget.dataList.addAll(newDataList);
      return widget.dataList
          .sublist(pageSize * currentPage, pageSize * (currentPage + 1));
    }
  }

  int pageSize = 10;
  int get currentPage => int.parse(currentPageController.text) - 1;
  int get pageNum => (widget.dataNum / pageSize).ceil();

  final TextEditingController currentPageController =
      TextEditingController(text: '1');
  bool selectedAll = false;
  final Set<int> selectedRows = <int>{};

  void selectAll(bool? value) {
    setState(() {
      selectedAll = value ?? false;
      if (selectedAll) {
        for (int i = currentPage * pageSize;
            i < widget.dataNum && i < (currentPage + 1) * pageSize;
            i++) {
          selectedRows.add(i);
        }
      } else {
        for (int i = currentPage * pageSize;
            i < widget.dataNum && i < (currentPage + 1) * pageSize;
            i++) {
          if (selectedRows.contains(i)) selectedRows.remove(i);
        }
      }
    });
  }

  void selectItem(int rowIndex) {
    setState(() {
      selectedRows.contains(currentPage * pageSize + rowIndex)
          ? selectedRows.remove(currentPage * pageSize + rowIndex)
          : selectedRows.add(currentPage * pageSize + rowIndex);
    });
  }

  bool isSelected(int index) {
    return selectedRows.contains(index);
  }

  void refreshSelectAll() async {
    selectedAll = false;
    bool flag = true;
    List<T> currentData = await getCurrentPageData();
    for (int i = currentPage * pageSize;
        flag && i < currentData.length && i < (currentPage + 1) * pageSize;
        i++) {
      if (!selectedRows.contains(i)) flag = false;
    }
    if (flag) {
      setState(() {
        selectedAll = true;
      });
    }
  }

  void goToPage(int pageNumber) {
    if (pageNumber == currentPage) return;
    setState(() {
      currentPageController.text = (pageNumber + 1).toString();
    });
    refreshSelectAll();
  }

  Widget getOptionTitle() {
    return selectedRows.isEmpty || !widget.selectable
        ? _getCustomOptionTitle()
        : _getSelectedOptionTitle();
  }

  Widget _getCustomOptionTitle() {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      height: 80,
      child: Row(
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.tableTitle,
                  style: const TextStyle(color: Colors.black, fontSize: 24),
                ),
              ]),
          const Spacer(),
          if (widget.refreshButton)
            MaterialButton(
              color: Colors.white,
              textColor: Colors.black,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              onPressed: widget.refreshCallback,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(4, 6, 4, 6),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.refresh),
                    ),
                    Text('刷新')
                  ],
                ),
              ),
            ),
          const SizedBox(
            width: 15,
          ),
          if (widget.addButton)
            MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              onPressed: widget.addCallback,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(4, 6, 4, 6),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.add),
                    ),
                    Text('添加')
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _getSelectedOptionTitle() {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      height: 80,
      child: Row(
        children: [
          Expanded(
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '已选择${selectedRows.length}项',
                    style: const TextStyle(color: Colors.black, fontSize: 24),
                  ))),
          if (widget.deleteButton)
            MaterialButton(
              color: const Color.fromARGB(255, 245, 108, 108),
              textColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(4, 6, 4, 6),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.delete),
                    ),
                    Text('删除')
                  ],
                ),
              ),
              onPressed: () {
                if (selectedRows.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('请先选择数据'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red,
                  ));
                } else {
                  widget.deleteCallback(selectedRows);
                }
              },
            ),
          const SizedBox(
            width: 15,
          ),
          if (widget.exportButton)
            MaterialButton(
              color: const Color.fromARGB(255, 125, 200, 30),
              textColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(4, 6, 4, 6),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.download),
                    ),
                    Text('导出')
                  ],
                ),
              ),
              onPressed: () {
                if (selectedRows.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('请先选择数据'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red,
                  ));
                } else {
                  widget.exportCallback(selectedRows);
                }
              },
            ),
        ],
      ),
    );
  }

  Widget getBody() {
    return LayoutBuilder(builder: (context, constraints) {
      int totalWeight = 0;
      for (ColumnItem column in widget.columns) {
        totalWeight += column.weight;
      }
      Map<int, TableColumnWidth>? columnWidths = (widget.selectable
              ? List.generate(widget.columns.length + 1, (index) {
                  if (index == 0) {
                    return 50.0;
                  } else {
                    return max(
                        widget.columns[index - 1].minWidth,
                        (constraints.maxWidth - 50.0) /
                            totalWeight *
                            widget.columns[index - 1].weight);
                  }
                })
              : List.generate(widget.columns.length, (index) {
                  return max(
                      widget.columns[index].minWidth,
                      (constraints.maxWidth - 50.0) /
                          totalWeight *
                          widget.columns[index].weight);
                }))
          .asMap()
          .map((i, width) {
        return MapEntry(i, FixedColumnWidth(width));
      });
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            Table(
              columnWidths: columnWidths,
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                    children: List.generate(
                        widget.columns.length + (widget.selectable ? 1 : 0),
                        (columnIndex) => widget.selectable && columnIndex == 0
                            ? Checkbox(
                                value: selectedAll,
                                onChanged: (value) => selectAll(value))
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        widget.columns[columnIndex - 1].content,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: Color.fromARGB(
                                                255, 144, 147, 153)),
                                      ),
                                    ),
                                    if (widget.columns[columnIndex - 1]
                                                .defaultIcon !=
                                            null &&
                                        widget.columns[columnIndex - 1]
                                                .clickedIcon !=
                                            null)
                                      const SizedBox(
                                        width: 10,
                                      ),
                                    if (widget.columns[columnIndex - 1]
                                                .defaultIcon !=
                                            null &&
                                        widget.columns[columnIndex]
                                                .clickedIcon !=
                                            null &&
                                        !widget
                                            .columns[columnIndex - 1].clicked)
                                      IconButton(
                                        icon: Icon(widget
                                            .columns[columnIndex - 1]
                                            .defaultIcon),
                                        onPressed: () {
                                          if (widget.columns[columnIndex - 1]
                                                  .iconClickCallback !=
                                              null) {
                                            widget.columns[columnIndex - 1]
                                                .iconClickCallback;
                                          }
                                        },
                                      ),
                                    if (widget.columns[columnIndex - 1]
                                                .defaultIcon !=
                                            null &&
                                        widget.columns[columnIndex - 1]
                                                .clickedIcon !=
                                            null &&
                                        widget.columns[columnIndex - 1].clicked)
                                      IconButton(
                                        icon: Icon(widget
                                            .columns[columnIndex - 1]
                                            .clickedIcon),
                                        onPressed: () {
                                          if (widget.columns[columnIndex - 1]
                                                  .iconClickCallback !=
                                              null) {
                                            widget.columns[columnIndex - 1]
                                                .iconClickCallback;
                                          }
                                        },
                                      ),
                                  ],
                                ),
                              )))
              ],
            ),
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: FutureBuilder(
                  future: getCurrentPageData(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          '加载失败',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20),
                        ),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: SizedBox(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator()));
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      List<T> data = snapshot.data!;
                      return Table(
                          columnWidths: columnWidths,
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: List.generate(min(data.length, pageSize),
                              (rowIndex) {
                            List<Widget> rowWidgets =
                                widget.rowBuilder(data[rowIndex]);
                            return TableRow(
                                children: List.generate(
                                    widget.columns.length +
                                        (widget.selectable ? 1 : 0),
                                    (columnIndex) => widget.selectable &&
                                            columnIndex == 0
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Checkbox(
                                                value: isSelected(rowIndex),
                                                onChanged: (value) =>
                                                    setState(() => (value ?? false)
                              ? selectedRows.add(rowIndex)
                              : selectedRows.remove(rowIndex))),
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: rowWidgets[columnIndex - 1],
                                          )));
                          }));
                    }
                    return Container();
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget getFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('共${widget.dataNum}条，每页'),
        const SizedBox(
          width: 8,
        ),
        DropdownMenu<String>(
          width: 80,
          dropdownMenuEntries: ['5', '10', '15', '20'].map((value) {
            return DropdownMenuEntry(value: value, label: value);
          }).toList(),
          initialSelection: '10',
          onSelected: (value) {
            setState(() {
              pageSize = int.parse(value!);
            });
            refreshSelectAll();
          },
        ),
        const SizedBox(
          width: 8,
        ),
        const Text('条'),
        const SizedBox(
          width: 80,
        ),
        const Spacer(),
        IconButton(
            onPressed: () =>
                {currentPage > 0 ? goToPage(currentPage - 1) : null},
            icon: const Icon(Icons.arrow_back_ios)),
        Container(
          width: 80,
          margin: const EdgeInsets.only(left: 10, right: 10),
          child: TextField(
            controller: currentPageController,
            onSubmitted: (value) {
              if (value.isEmpty) {
                Get.bottomSheet(const Text('页数不能为空'));
                return;
              }
              int index = int.parse(value);
              if (index < 1 || index > pageNum) {
                Get.bottomSheet(const Text('页数错误'));
              } else {
                goToPage(index - 1);
              }
            },
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(pageNum.toString().length)
            ],
          ),
        ),
        IconButton(
            onPressed: () =>
                currentPage < pageNum - 1 ? goToPage(currentPage + 1) : null,
            icon: const Icon(Icons.arrow_forward_ios)),
        const SizedBox(
          width: 20,
        ),
        Text('共$pageNum页'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        getOptionTitle(),
        const SizedBox(
          height: 8,
        ),
        Expanded(child: getBody()),
        const SizedBox(
          height: 26,
        ),
        getFooter(),
      ],
    );
  }
}
