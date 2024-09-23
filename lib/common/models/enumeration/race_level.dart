enum RaceLevel{
  unknown(name: '未知'),
  international(name:'国际级'),
  national(name:'国家级'),
  provincial(name: '省部级'),
  city(name: '市局级'),
  school(name: '校级'),
  institute(name: '院级'),;

  final String name;

  const RaceLevel({required this.name});

  static RaceLevel get(int index) {
    for (RaceLevel value in RaceLevel.values) {
      if (value.index == index) return value;
    }
    return RaceLevel.unknown;
  }

  static RaceLevel getByName(String name) {
    for (RaceLevel value in RaceLevel.values) {
      if (value.name == name) return value;
    }
    return RaceLevel.unknown;
  }
}