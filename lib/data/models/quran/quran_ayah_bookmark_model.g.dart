// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_ayah_bookmark_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuranAyahBookmarkModelAdapter
    extends TypeAdapter<QuranAyahBookmarkModel> {
  @override
  final int typeId = 2;

  @override
  QuranAyahBookmarkModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuranAyahBookmarkModel(
      id: fields[0] as String,
      surahId: fields[1] as String,
      surahName: fields[2] as String,
      surahNumber: fields[3] as int,
      ayahNumber: fields[4] as int,
      ayahText: fields[5] as String,
      ayahTranslation: fields[6] as String,
      pageNumber: fields[7] as int,
      juzNumber: fields[8] as int,
      createdAt: fields[9] as DateTime,
      type: fields[10] as BookmarkType,
      note: fields[11] as String?,
      scrollPosition: fields[12] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, QuranAyahBookmarkModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.surahId)
      ..writeByte(2)
      ..write(obj.surahName)
      ..writeByte(3)
      ..write(obj.surahNumber)
      ..writeByte(4)
      ..write(obj.ayahNumber)
      ..writeByte(5)
      ..write(obj.ayahText)
      ..writeByte(6)
      ..write(obj.ayahTranslation)
      ..writeByte(7)
      ..write(obj.pageNumber)
      ..writeByte(8)
      ..write(obj.juzNumber)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.type)
      ..writeByte(11)
      ..write(obj.note)
      ..writeByte(12)
      ..write(obj.scrollPosition);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuranAyahBookmarkModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BookmarkTypeAdapter extends TypeAdapter<BookmarkType> {
  @override
  final int typeId = 3;

  @override
  BookmarkType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BookmarkType.page;
      case 1:
        return BookmarkType.ayah;
      default:
        return BookmarkType.page;
    }
  }

  @override
  void write(BinaryWriter writer, BookmarkType obj) {
    switch (obj) {
      case BookmarkType.page:
        writer.writeByte(0);
        break;
      case BookmarkType.ayah:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookmarkTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
