// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CodeAdapter extends TypeAdapter<Code> {
  @override
  final int typeId = 2;

  @override
  Code read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Code(
      fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Code obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
