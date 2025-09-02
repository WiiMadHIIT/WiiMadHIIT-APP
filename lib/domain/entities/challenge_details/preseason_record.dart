import 'package:flutter/foundation.dart';

class PreseasonRecord {
  final String id;
  final int index;
  final String name;
  final String rank;
  final int counts;

  PreseasonRecord({
    required this.id,
    required this.index,
    required this.name,
    required this.rank,
    required this.counts,
  });

  /// 检查是否为冠军
  bool get isChampion => rank.toLowerCase().contains('1st') || rank.toLowerCase().contains('1st');

  /// 检查是否为亚军
  bool get isRunnerUp => rank.toLowerCase().contains('2nd') || rank.toLowerCase().contains('2nd');

  /// 检查是否为季军
  bool get isThirdPlace => rank.toLowerCase().contains('3rd') || rank.toLowerCase().contains('3rd');

  /// 获取排名数字
  int? get rankNumber {
    final rankStr = rank.toLowerCase();
    if (rankStr.contains('1st')) return 1;
    if (rankStr.contains('2nd')) return 2;
    if (rankStr.contains('3rd')) return 3;
    if (rankStr.contains('4th')) return 4;
    if (rankStr.contains('5th')) return 5;
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreseasonRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          index == other.index &&
          name == other.name &&
          rank == other.rank &&
          counts == other.counts;

  @override
  int get hashCode =>
      id.hashCode ^
      index.hashCode ^
      name.hashCode ^
      rank.hashCode ^
      counts.hashCode;

  @override
  String toString() {
    return 'PreseasonRecord{id: $id, index: $index, name: $name, rank: $rank, counts: $counts}';
  }
} 