// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_bookmark_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuranBookmarkModelAdapter extends TypeAdapter<QuranBookmarkModel> {
  @override
  final int typeId = 1;

  @override
  QuranBookmarkModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuranBookmarkModel(
      id: fields[0] as String,
      surahId: fields[1] as String,
      surahName: fields[2] as String,
      pageNumber: fields[3] as int,
      juzNumber: fields[4] as int,
      createdAt: fields[5] as DateTime,
      note: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, QuranBookmarkModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.surahId)
      ..writeByte(2)
      ..write(obj.surahName)
      ..writeByte(3)
      ..write(obj.pageNumber)
      ..writeByte(4)
      ..write(obj.juzNumber)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuranBookmarkModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
