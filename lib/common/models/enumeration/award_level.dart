enum AwardLevel{
  unknown(name: '未知'),
  first(name:'一等奖/金奖'),
  second(name:'二等奖/银奖'),
  third(name: '三等奖/铜奖'),
  participation(name: '优胜奖/参与奖'),;

  final String name;

  const AwardLevel({required this.name});

  static AwardLevel get(int index) {
    for (AwardLevel value in AwardLevel.values) {
      if (value.index == index) return value;
    }
    return AwardLevel.unknown;
  }
}