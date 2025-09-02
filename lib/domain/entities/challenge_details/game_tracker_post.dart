import 'package:flutter/foundation.dart';

class GameTrackerPost {
  final String id;
  final String? announcement;
  final String? image;
  final String? desc;
  final int timestep;

  GameTrackerPost({
    required this.id,
    this.announcement,
    this.image,
    this.desc,
    required this.timestep,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameTrackerPost &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          announcement == other.announcement &&
          image == other.image &&
          desc == other.desc &&
          timestep == other.timestep;

  @override
  int get hashCode =>
      id.hashCode ^
      announcement.hashCode ^
      image.hashCode ^
      desc.hashCode ^
      timestep.hashCode;

  @override
  String toString() {
    return 'GameTrackerPost{id: $id, announcement: $announcement, image: $image, desc: $desc, timestep: $timestep}';
  }
} 