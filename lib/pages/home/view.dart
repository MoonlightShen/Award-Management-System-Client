import 'dart:math';

import 'package:award_management_system/common/models/award_category.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:award_management_system/common/models/award.dart';

import 'index.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      id: "home",
      builder: (_) {
        return Scaffold(
          backgroundColor: const Color.fromARGB(0, 0, 0, 0),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '最近获奖',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Container(
                    height: 230,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: FutureBuilder(
                      future: controller.getLatelyAwards(3),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              '加载失败',
                              textAlign: TextAlign.center,
                            ),
                          );
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: SizedBox(
                              width: 200,
                              height: 200,
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else if (snapshot.connectionState ==
                            ConnectionState.done) {
                          List<Award> awards = snapshot.data!;
                          return Padding(
                            padding: const EdgeInsets.all(24),
                            child: ListView.separated(
                                itemBuilder: (context, index) => Row(
                                      children: [
                                        // SizedBox(
                                        //   height: 50,
                                        //   width: 50,
                                        //   // child: awards[index].image != null
                                        //   //     ? Image.memory(
                                        //   //         awards[index].image!)
                                        //   //     : Container(),
                                        // ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${awards[index].awardCategory?.awardCategoryName} | ${awards[index].awardName}',
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            ),
                                            Text(
                                              DateFormat('yyyy年MM月dd日').format(
                                                  DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          awards[index]
                                                              .acquisitionTime)),
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Text(awards[index].awardLevel.name)
                                      ],
                                    ),
                                separatorBuilder: (context, index) => Container(
                                      height: 16,
                                    ),
                                itemCount: awards.length),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Expanded(
                      child: FutureBuilder(
                    future: controller.getAwardsFromRange(
                        DateTime(DateTime.now().year - 1, DateTime.now().month)
                            .millisecondsSinceEpoch,
                        DateTime(DateTime.now().year, DateTime.now().month+1).millisecondsSinceEpoch),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            '加载失败',
                            textAlign: TextAlign.center,
                          ),
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: SizedBox(
                            width: 200,
                            height: 200,
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.done) {
                        List<Award> awards = snapshot.data!;

                        Map<DateTime, int> monthlyAwardCount = {};
                        for (var award in awards) {
                          DateTime date = DateTime.fromMillisecondsSinceEpoch(
                              award.acquisitionTime);
                          DateTime key = DateTime(date.year, date.month);
                          monthlyAwardCount[key] =
                              (monthlyAwardCount[key] ?? 0) + 1;
                        }

                        int maxAwardNumber = 0;
                        for (var number in monthlyAwardCount.values) {
                          maxAwardNumber = max(maxAwardNumber, number);
                        }

                        List<DateTime> timeRange = [];
                        for (int i = 1; i <= 12; i++) {
                          timeRange.add(DateTime(DateTime.now().year - 1,
                              DateTime.now().month + i));
                        }

                        Map<AwardCategory, int> awardCategoryCount = {};
                        for (var award in awards) {
                          if (award.awardCategory != null) {
                            awardCategoryCount[award.awardCategory!] =
                                (awardCategoryCount[award.awardCategory!] ??
                                        0) +
                                    1;
                          }
                        }

                        Map<AwardCategory, double> awardCategoryDistribution =
                            {};
                        for (var count in awardCategoryCount.entries) {
                          awardCategoryDistribution[count.key] =
                              count.value.toDouble() /
                                  awards.length.toDouble() *
                                  100.0;
                        }

                        List<Color> defaultColors = [];
                        defaultColors.add(Colors.green);
                        defaultColors.add(Colors.blue);
                        defaultColors.add(Colors.pink);
                        defaultColors.add(Colors.purple);
                        defaultColors.add(Colors.brown);
                        defaultColors.add(Colors.lightGreen);
                        defaultColors.add(Colors.teal);
                        defaultColors.add(Colors.red);
                        defaultColors.add(Colors.orange);
                        defaultColors.add(Colors.yellow);

                        return Row(
                          children: [
                            Flexible(
                                flex: 2,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '获奖历史记录',
                                      style: TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    Expanded(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              36, 48, 48, 36),
                                          child: LineChart(LineChartData(
                                            gridData: FlGridData(
                                              show: true,
                                              drawVerticalLine: true,
                                              horizontalInterval: 1,
                                              verticalInterval: 1,
                                              getDrawingHorizontalLine:
                                                  (value) {
                                                return FlLine(
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                  strokeWidth: 1,
                                                );
                                              },
                                              getDrawingVerticalLine: (value) {
                                                return FlLine(
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                  strokeWidth: 1,
                                                );
                                              },
                                            ),
                                            titlesData: FlTitlesData(
                                              show: true,
                                              rightTitles: const AxisTitles(
                                                sideTitles: SideTitles(
                                                    showTitles: false),
                                              ),
                                              topTitles: const AxisTitles(
                                                sideTitles: SideTitles(
                                                    showTitles: false),
                                              ),
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize: 30,
                                                  interval: 1,
                                                  getTitlesWidget:
                                                      (value, meta) =>
                                                          SideTitleWidget(
                                                    axisSide: meta.axisSide,
                                                    child: Text(
                                                        DateFormat('yy/MM')
                                                            .format(timeRange[
                                                                value.toInt()]),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        )),
                                                  ),
                                                ),
                                              ),
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  interval: 10,
                                                  reservedSize: 30,
                                                  getTitlesWidget:
                                                      (value, meta) =>
                                                          SideTitleWidget(
                                                    axisSide: meta.axisSide,
                                                    child: Text(
                                                        value
                                                            .toInt()
                                                            .toString(),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        )),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            borderData: FlBorderData(
                                              show: true,
                                              border: Border.all(
                                                  color:
                                                      const Color(0xff37434d)),
                                            ),
                                            minX: 0,
                                            maxX: 11,
                                            minY: 0,
                                            maxY: (maxAwardNumber / 10).ceil() *
                                                10,
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: List.generate(
                                                    12,
                                                    (index) => FlSpot(
                                                        index.toDouble(),
                                                        (monthlyAwardCount[
                                                                    timeRange[
                                                                        index]] ??
                                                                0)
                                                            .toDouble())),
                                                isCurved: false,
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Colors.cyan,
                                                    Colors.blue,
                                                  ],
                                                ),
                                                barWidth: 5,
                                                isStrokeCapRound: true,
                                                dotData: const FlDotData(
                                                  show: false,
                                                ),
                                                belowBarData: BarAreaData(
                                                  show: true,
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.cyan,
                                                      Colors.blue,
                                                    ]
                                                        .map((color) => color
                                                            .withOpacity(0.3))
                                                        .toList(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )),
                                        ),
                                      ),
                                    )
                                  ],
                                )),
                            const SizedBox(
                              width: 24,
                            ),
                            Flexible(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '获奖类型统计',
                                      style: TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    Expanded(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Obx(
                                            () => Column(
                                              children: [
                                                Wrap(
                                                    children: List.generate(
                                                  awardCategoryCount.length,
                                                  (index) => Padding(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          width: 10,
                                                          height: 10,
                                                          color: controller
                                                                      .pieChartTouchedIndex
                                                                      .value ==
                                                                  index
                                                              ? defaultColors[
                                                                  index]
                                                              : defaultColors[
                                                                      index]
                                                                  .withOpacity(
                                                                      0.3),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Text(
                                                          awardCategoryCount
                                                              .entries
                                                              .toList()[index]
                                                              .key
                                                              .awardCategoryName,
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color: controller
                                                                          .pieChartTouchedIndex
                                                                          .value ==
                                                                      index
                                                                  ? defaultColors[
                                                                      index]
                                                                  : defaultColors[
                                                                          index]
                                                                      .withOpacity(
                                                                          0.3)),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )),
                                                Expanded(
                                                  child: PieChart(
                                                    PieChartData(
                                                      pieTouchData:
                                                          PieTouchData(
                                                        touchCallback:
                                                            (FlTouchEvent event,
                                                                pieTouchResponse) {
                                                          if (!event
                                                                  .isInterestedForInteractions ||
                                                              pieTouchResponse ==
                                                                  null ||
                                                              pieTouchResponse
                                                                      .touchedSection ==
                                                                  null) {
                                                            controller
                                                                .pieChartTouchedIndex
                                                                .value = -1;
                                                            return;
                                                          }
                                                          controller
                                                                  .pieChartTouchedIndex
                                                                  .value =
                                                              pieTouchResponse
                                                                  .touchedSection!
                                                                  .touchedSectionIndex;
                                                        },
                                                      ),
                                                      startDegreeOffset: 180,
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      sectionsSpace: 1,
                                                      centerSpaceRadius: 0,
                                                      sections: List.generate(
                                                          awardCategoryCount
                                                              .length, (i) {
                                                        final isTouched = i ==
                                                            controller
                                                                .pieChartTouchedIndex
                                                                .value;
                                                        return PieChartSectionData(
                                                          color: controller
                                                                      .pieChartTouchedIndex
                                                                      .value ==
                                                                  i
                                                              ? defaultColors[i]
                                                              : defaultColors[i]
                                                                  .withOpacity(
                                                                      0.3),
                                                          value: awardCategoryDistribution[
                                                              awardCategoryCount
                                                                  .entries
                                                                  .toList()[i]
                                                                  .key],
                                                          title:
                                                              '${awardCategoryDistribution[awardCategoryCount.entries.toList()[i].key]!.toStringAsFixed(1)}%',
                                                          radius: isTouched
                                                              ? 110.0
                                                              : 100.0,
                                                          titleStyle: TextStyle(
                                                            fontSize: isTouched
                                                                ? 20.0
                                                                : 16.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: const Color(
                                                                0xffffffff),
                                                            shadows: const [
                                                              Shadow(
                                                                  color: Colors
                                                                      .black,
                                                                  blurRadius: 2)
                                                            ],
                                                          ),
                                                          // badgeWidget: _Badge(
                                                          //   'assets/images/icon/example_icon_1.svg',
                                                          //   size: isTouched ? 55.0 : 40.0,
                                                          //   borderColor: Colors.black,
                                                          // ),
                                                          badgePositionPercentageOffset:
                                                              .98,
                                                        );
                                                      }),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ))
                          ],
                        );
                      }
                      return Container();
                    },
                  )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
