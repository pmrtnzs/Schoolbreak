// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestionAdapter extends TypeAdapter<Question> {
  @override
  final int typeId = 1;

  @override
  Question read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Question(
      fields[0] as int,
      fields[1] as String,
      fields[2] as int,
      fields[3] as int,
      fields[4] as int,
      fields[5] as int,
      fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Question obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.iD)
      ..writeByte(1)
      ..write(obj.question)
      ..writeByte(2)
      ..write(obj.correct)
      ..writeByte(3)
      ..write(obj.opA)
      ..writeByte(4)
      ..write(obj.opB)
      ..writeByte(5)
      ..write(obj.opC)
      ..writeByte(6)
      ..write(obj.opD);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
