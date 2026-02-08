// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserStatsAdapter extends TypeAdapter<UserStats> {
  @override
  final int typeId = 1;

  @override
  UserStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserStats(
      xp: (fields[0] as int?) ?? 0,
      level: (fields[1] as int?) ?? 1,
      totalHabitsCompleted: (fields[2] as int?) ?? 0,
      currentStreak: (fields[3] as int?) ?? 0,
      lastCompletionDate: fields[4] as DateTime?,
      unlockedBadgeIds: (fields[5] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserStats obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.xp)
      ..writeByte(1)
      ..write(obj.level)
      ..writeByte(2)
      ..write(obj.totalHabitsCompleted)
      ..writeByte(3)
      ..write(obj.currentStreak)
      ..writeByte(4)
      ..write(obj.lastCompletionDate)
      ..writeByte(5)
      ..write(obj.unlockedBadgeIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
