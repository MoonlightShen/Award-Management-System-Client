import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:get/get.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:material_table_view/shimmer_placeholder_shade.dart';

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

class CustomPaginatedTable<T> extends StatefulWidget {
  final String tableTitle;
  final List<ColumnItem> columns;
  final List<Widget> Function(T item) rowBuilder;
  final int dataNum;
  final double rowHeight;

  final Future<List<T>> Function(int page, int pageSize) getData;

  final Function() refreshCallback;
  final Function() addCallback;
  final Function(Set<int> selectedIndexList) deleteCallback;
  final Function(Set<int> selectedIndexList) exportCallback;
  final bool refreshButton;
  final bool addButton;
  final Function(T selectedItem)? editCallback;
  final bool editButton;
  final bool deleteButton;
  final bool exportButton;
  final bool selectable;
  final bool Function(T data, String searchContent)? searchCheck;
  final bool searchable;
  final int searchColumnIndex;
  final Color backgroundColor = Colors.white;
  final Color headerColor = const Color.fromARGB(255, 242, 246, 252);

  const CustomPaginatedTable(
      {super.key,
      required this.dataNum,
      required this.tableTitle,
      required this.columns,
      required this.rowBuilder,
      required this.deleteCallback,
      required this.refreshCallback,
      required this.addCallback,
      required this.exportCallback,
      this.editCallback,
      this.searchCheck,
      this.editButton = false,
      this.searchColumnIndex = -1,
      this.rowHeight = 68,
      this.refreshButton = true,
      this.addButton = true,
      this.deleteButton = true,
      this.exportButton = true,
      this.selectable = true,
      this.searchable = false,
      required this.getData});

  @override
  State<StatefulWidget> createState() => _CustomPaginatedTableState<T>();
}

class _CustomPaginatedTableState<T> extends State<CustomPaginatedTable<T>> {
  final Map<int, T> dataList = {};
  final List<T> filteredDataList = [];

  T? getData(int index) {
    if (filtered) {
      return index < filteredDataList.length ? filteredDataList[index] : null;
    }
    if (dataList[index] == null) {
      if (!hasRefreshedIndex.contains(index)) {
        for (int i = (index / pageSize).floor() * pageSize;
            i < ((index / pageSize).floor() + 1) * pageSize;
            i++) {
          hasRefreshedIndex.add(i);
        }
        refreshData((index / pageSize).floor() + 1, pageSize);
      }
    }
    return dataList[index];
  }

  Future<void> refreshData(int page, int pageSize) async {
    List<T> newData = await widget.getData(page, pageSize);
    setState(() {
      if (dataList.isEmpty) {
        pageNum = (widget.dataNum / pageSize).ceil();
      }
      int index = (page - 1) * pageSize;
      for (T data in newData) {
        dataList[index++] = data;
      }
    });
  }

  int pageSize = 10;
  int get currentPage => int.parse(currentPageController.text) - 1;
  int pageNum = 0;
  bool filtered = false;
  Set hasRefreshedIndex = {};

  final TextEditingController textSearchController = TextEditingController();
  final TextEditingController currentPageController =
      TextEditingController(text: '1');
  bool selectedAll = false;
  final Set<int> selectedRows = <int>{};

  void search(String value) {
    filteredDataList.removeRange(
        0, filteredDataList.isEmpty ? 0 : filteredDataList.length);
    if (value.isNotEmpty) {
      for (T data in dataList.values) {
        if (widget.searchCheck!(data, value)) {
          filteredDataList.add(data);
        }
      }
    }
    setState(() {
      currentPageController.text = '1';
      filtered = value.isNotEmpty;
      pageNum = ((value.isNotEmpty ? filteredDataList.length : widget.dataNum) /
              pageSize)
          .ceil();
    });
  }

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
      selectedRows.contains(rowIndex)
          ? selectedRows.remove(rowIndex)
          : selectedRows.add(rowIndex);
    });
  }

  bool isSelected(int index) {
    return selectedRows.contains(index);
  }

  void refreshSelectAll() async {
    selectedAll = false;
    bool flag = currentPage * pageSize < dataList.length;
    for (int i = currentPage * pageSize;
        flag && i < dataList.length && i < (currentPage + 1) * pageSize;
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
      height: 50,
      margin: const EdgeInsets.only(left: 16),
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
          if (widget.searchable &&
              widget.searchColumnIndex != -1 &&
              widget.searchCheck != null)
            SizedBox(
              height: 50,
              width: 300,
              child: TextField(
                controller: textSearchController,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search_outlined),
                    hintText:
                        '根据${widget.columns[widget.searchColumnIndex].content}搜索'),
                onSubmitted: (value) => search(value),
              ),
            ),
          const SizedBox(
            width: 16,
          ),
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
      height: 50,
      margin: const EdgeInsets.only(left: 16),
      child: Row(
        children: [
          Expanded(
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '已选择${selectedRows.length}项',
                    style: const TextStyle(color: Colors.black, fontSize: 24),
                  ))),
          if (widget.editButton &&
              widget.editCallback != null &&
              selectedRows.length == 1)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: MaterialButton(
                color: Colors.purple,
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
                        child: Icon(Icons.edit),
                      ),
                      Text('编辑')
                    ],
                  ),
                ),
                onPressed: () {
                  if (selectedRows.isEmpty) {
                    IconSnackBar.show(Get.context!,
                        snackBarType: SnackBarType.fail, label: '请先选择数据');
                  } else if (selectedRows.length != 1) {
                    IconSnackBar.show(Get.context!,
                        snackBarType: SnackBarType.fail, label: '参数错误');
                  } else {
                    widget.editCallback!(
                        dataList[selectedRows.elementAt(0)] as T);
                  }
                },
              ),
            ),
          if (widget.deleteButton)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: MaterialButton(
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
                    IconSnackBar.show(Get.context!,
                        snackBarType: SnackBarType.fail, label: '请先选择数据');
                  } else {
                    widget.deleteCallback(selectedRows);
                  }
                },
              ),
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
                  IconSnackBar.show(Get.context!,
                      snackBarType: SnackBarType.fail, label: '请先选择数据');
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
      List<TableColumn> columns = [
        if (widget.selectable) const TableColumn(width: 50)
      ];
      for (int columnIndex = 0;
          columnIndex < widget.columns.length;
          columnIndex++) {
        columns.add(TableColumn(
            width: max(
                widget.columns[columnIndex].minWidth,
                (constraints.maxWidth - (widget.selectable ? 65 : 0)) /
                    totalWeight *
                    widget.columns[columnIndex].weight)));
      }
      return ShimmerPlaceholderShadeProvider(
        loopDuration: const Duration(seconds: 2),
        colors: const [
          Color(0x20808080),
          Color(0x40FFFFFF),
          Color(0x20808080),
          Color(0x40FFFFFF),
          Color(0x20808080),
        ],
        stops: const [.0, .45, .5, .95, 1],
        builder: (context, placeholderShade) => TableView.builder(
          columns: columns,
          style: const TableViewStyle(
            scrollbars: TableViewScrollbarsStyle.symmetric(
              TableViewScrollbarStyle(
                interactive: true,
                enabled: TableViewScrollbarEnabled.always,
                thumbVisibility: WidgetStatePropertyAll(true),
                trackVisibility: WidgetStatePropertyAll(true),
              ),
            ),
          ),
          rowHeight: widget.rowHeight,
          rowCount: min(
              pageSize,
              (filtered ? filteredDataList.length : widget.dataNum) -
                  currentPage * pageSize),
          rowBuilder: (context, row, contentBuilder) => filtered
              ? AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withAlpha(
                          isSelected(row + currentPage * pageSize) ? 0xFF : 0),
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: () => selectItem(row + currentPage * pageSize),
                      child: contentBuilder(
                        context,
                        (context, column) {
                          return widget.selectable && column == 0
                              ? Checkbox(
                                  value:
                                      isSelected(row + currentPage * pageSize),
                                  onChanged: (value) => setState(() =>
                                      (value ?? false)
                                          ? selectedRows
                                              .add(row + currentPage * pageSize)
                                          : selectedRows.remove(
                                              row + currentPage * pageSize)))
                              : Align(
                                  alignment: Alignment.center,
                                  child: widget.rowBuilder(filteredDataList[
                                          row + currentPage * pageSize])[
                                      column - (widget.selectable ? 1 : 0)],
                                );
                        },
                      ),
                    ),
                  ),
                )
              : getData(row + currentPage * pageSize) == null
                  ? null
                  : AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withAlpha(isSelected(row + currentPage * pageSize)
                              ? 0xFF
                              : 0),
                      child: Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          onTap: () => selectItem(row + currentPage * pageSize),
                          child: contentBuilder(
                            context,
                            (context, column) {
                              return widget.selectable && column == 0
                                  ? Checkbox(
                                      value: isSelected(
                                          row + currentPage * pageSize),
                                      onChanged: (value) => setState(() =>
                                          (value ?? false)
                                              ? selectedRows.add(
                                                  row + currentPage * pageSize)
                                              : selectedRows.remove(row +
                                                  currentPage * pageSize)))
                                  : Align(
                                      alignment: Alignment.center,
                                      child: widget.rowBuilder(
                                          dataList[row + currentPage * pageSize]
                                              as T)[column -
                                          (widget.selectable ? 1 : 0)],
                                    );
                            },
                          ),
                        ),
                      ),
                    ),
          placeholderRowBuilder: (context, row, contentBuilder) =>
              contentBuilder(
                  context,
                  (context, columnIndex) => widget.selectable &&
                          columnIndex == 0
                      ? Checkbox(
                          value: false,
                          onChanged: (value) {},
                        )
                      : const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: DecoratedBox(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16)))),
                        )),
          placeholderShade: placeholderShade,
          headerBuilder: (context, contentBuilder) => contentBuilder(
              context,
              (context, columnIndex) => widget.selectable && columnIndex == 0
                  ? Checkbox(
                      value: selectedAll,
                      onChanged: (value) => selectAll(value))
                  : Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                widget
                                    .columns[columnIndex -
                                        (widget.selectable ? 1 : 0)]
                                    .content,
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: Color.fromARGB(255, 144, 147, 153)),
                              ),
                            ),
                            if (widget
                                        .columns[columnIndex -
                                            (widget.selectable ? 1 : 0)]
                                        .defaultIcon !=
                                    null &&
                                widget
                                        .columns[columnIndex -
                                            (widget.selectable ? 1 : 0)]
                                        .clickedIcon !=
                                    null)
                              const SizedBox(
                                width: 10,
                              ),
                            if (widget
                                        .columns[columnIndex -
                                            (widget.selectable ? 1 : 0)]
                                        .defaultIcon !=
                                    null &&
                                widget.columns[columnIndex].clickedIcon !=
                                    null &&
                                !widget
                                    .columns[columnIndex -
                                        (widget.selectable ? 1 : 0)]
                                    .clicked)
                              IconButton(
                                icon: Icon(widget
                                    .columns[columnIndex -
                                        (widget.selectable ? 1 : 0)]
                                    .defaultIcon),
                                onPressed: () {
                                  if (widget
                                          .columns[columnIndex -
                                              (widget.selectable ? 1 : 0)]
                                          .iconClickCallback !=
                                      null) {
                                    widget
                                        .columns[columnIndex -
                                            (widget.selectable ? 1 : 0)]
                                        .iconClickCallback;
                                  }
                                },
                              ),
                            if (widget
                                        .columns[columnIndex -
                                            (widget.selectable ? 1 : 0)]
                                        .defaultIcon !=
                                    null &&
                                widget
                                        .columns[columnIndex -
                                            (widget.selectable ? 1 : 0)]
                                        .clickedIcon !=
                                    null &&
                                widget
                                    .columns[columnIndex -
                                        (widget.selectable ? 1 : 0)]
                                    .clicked)
                              IconButton(
                                icon: Icon(widget
                                    .columns[columnIndex -
                                        (widget.selectable ? 1 : 0)]
                                    .clickedIcon),
                                onPressed: () {
                                  if (widget
                                          .columns[columnIndex -
                                              (widget.selectable ? 1 : 0)]
                                          .iconClickCallback !=
                                      null) {
                                    widget
                                        .columns[columnIndex -
                                            (widget.selectable ? 1 : 0)]
                                        .iconClickCallback;
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                    )),
          bodyContainerBuilder: (context, bodyContainer) =>
              RefreshIndicator.adaptive(
            onRefresh: () => Future.delayed(const Duration(seconds: 2)),
            child: bodyContainer,
          ),
        ),
      );
    });
  }

  Widget getFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('共${widget.dataNum}条，已缓存${dataList.length}条，每页',
            style: const TextStyle(fontSize: 20)),
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
              pageNum = ((filtered ? filteredDataList.length : widget.dataNum) /
                      pageSize)
                  .ceil();
            });
            refreshSelectAll();
          },
        ),
        const SizedBox(
          width: 8,
        ),
        const Text('条', style: TextStyle(fontSize: 20)),
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
                IconSnackBar.show(Get.context!,
                    snackBarType: SnackBarType.fail, label: '页数不能为空');
                currentPageController.text = '1';
                return;
              }
              int index = int.parse(value);
              if (index < 1 || index > pageNum) {
                IconSnackBar.show(Get.context!,
                    snackBarType: SnackBarType.fail, label: '页数错误');
                currentPageController.text = '1';
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
        Text('共$pageNum页', style: const TextStyle(fontSize: 20)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 8,
        ),
        getOptionTitle(),
        const SizedBox(
          height: 8,
        ),
        Expanded(child: getBody()),
        const SizedBox(
          height: 24,
        ),
        getFooter(),
      ],
    );
  }
}
