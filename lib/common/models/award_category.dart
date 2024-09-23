import 'dart:convert';
import 'dart:typed_data';

class AwardCategory {
  final int awardCategoryId;
  String awardCategoryName;
  bool hasAwardLevel;
  Uint8List? icon;

  AwardCategory(
      {required this.awardCategoryId, this.awardCategoryName = '', this.icon, this.hasAwardLevel = false});

  factory AwardCategory.fromJson(Map<String, dynamic> json) => AwardCategory(
        awardCategoryId: json['awardCategoryId'] != null
            ? json['awardCategoryId'] as int
            : -1,
        awardCategoryName: json['awardCategoryName'] != null
            ? json['awardCategoryName'] as String
            : '',
        icon:
            json['icon'] != null ? base64Decode(json['icon'] as String) : null,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AwardCategory &&
        other.awardCategoryId == awardCategoryId;
  }

  // 实现 hashCode 方法
  @override
  int get hashCode => awardCategoryId.hashCode;
}
