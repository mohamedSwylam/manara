// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dua_category_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DuaCategoryModelAdapter extends TypeAdapter<DuaCategoryModel> {
  @override
  final int typeId = 4;

  @override
  DuaCategoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DuaCategoryModel(
      id: fields[0] as String,
      categoryArabic: fields[1] as String,
      categoryEnglish: fields[2] as String,
      categoryTurkish: fields[3] as String,
      categoryUrdu: fields[4] as String,
      categoryBangla: fields[5] as String,
      categoryHindi: fields[6] as String,
      categoryFrench: fields[7] as String,
      timestamp: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DuaCategoryModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.categoryArabic)
      ..writeByte(2)
      ..write(obj.categoryEnglish)
      ..writeByte(3)
      ..write(obj.categoryTurkish)
      ..writeByte(4)
      ..write(obj.categoryUrdu)
      ..writeByte(5)
      ..write(obj.categoryBangla)
      ..writeByte(6)
      ..write(obj.categoryHindi)
      ..writeByte(7)
      ..write(obj.categoryFrench)
      ..writeByte(8)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DuaCategoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
