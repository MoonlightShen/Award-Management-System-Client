import 'dart:convert';
import 'dart:typed_data';

import 'package:award_management_system/common/models/award_category.dart';
import 'package:award_management_system/common/models/enumeration/award_level.dart';
import 'package:award_management_system/common/models/enumeration/race_level.dart';

class Award{
  final int awardId;
  AwardCategory? awardCategory;
  RaceLevel raceLevel;
  String awardName;
  AwardLevel awardLevel;
  int? ranking;
  int acquisitionTime;

  Award({required this.awardId, this.awardCategory, this.awardName='', this.raceLevel=RaceLevel.unknown, this.awardLevel=AwardLevel.unknown, 
  this.ranking, this.acquisitionTime=0});
  
  factory Award.fromJson(Map<String, dynamic> json) => Award(
        awardId: json['awardId']!=null?json['awardId'] as int:-1,
        awardCategory: json['awardCategory']!=null?AwardCategory.fromJson(json['awardCategory']):null,
        awardName: json['awardName']!=null?json['awardName'] as String:'',
        ranking: json['ranking']!=null?json['ranking'] as int:null,
        acquisitionTime: json['acquisitionTime']!=null?json['acquisitionTime'] as int:0,
        raceLevel: json['raceLevel']!=null?RaceLevel.get(json['raceLevel'] as int):RaceLevel.unknown,
        awardLevel: json['awardLevel']!=null?AwardLevel.get(json['awardLevel'] as int):AwardLevel.unknown
      );
}