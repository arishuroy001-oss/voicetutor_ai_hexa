// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: flutter pub run build_runner build --delete-conflicting-outputs

part of 'user_progress.dart';

class UserProgressAdapter extends TypeAdapter<UserProgress> {
  @override
  final int typeId = 1;

  @override
  UserProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProgress(
      userId: fields[0] as String,
      totalAttempted: fields[1] as int,
      totalCorrect: fields[2] as int,
      currentStreak: fields[3] as int,
      longestStreak: fields[4] as int,
      lastPracticeDate: fields[5] as DateTime?,
      topicWiseScore: (fields[6] as Map?)?.map(
            (k, v) => MapEntry(k as String, (v as Map).map(
                  (k2, v2) => MapEntry(k2 as String, v2 as int),
                )),
          ) ??
          {},
    );
  }

  @override
  void write(BinaryWriter writer, UserProgress obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.totalAttempted)
      ..writeByte(2)
      ..write(obj.totalCorrect)
      ..writeByte(3)
      ..write(obj.currentStreak)
      ..writeByte(4)
      ..write(obj.longestStreak)
      ..writeByte(5)
      ..write(obj.lastPracticeDate)
      ..writeByte(6)
      ..write(obj.topicWiseScore);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
