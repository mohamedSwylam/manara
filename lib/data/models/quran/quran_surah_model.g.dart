// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_surah_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuranSurahModelAdapter extends TypeAdapter<QuranSurahModel> {
  @override
  final int typeId = 0;

  @override
  QuranSurahModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuranSurahModel(
      number: fields[0] as int,
      name: fields[1] as String,
      arabicName: fields[2] as String,
      englishName: fields[3] as String,
      revelationType: fields[4] as String,
      numberOfAyahs: fields[5] as int,
      juz: fields[6] as int,
      page: fields[7] as int,
      translation: fields[8] as String?,
      transliteration: fields[9] as String?,
      lastUpdated: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, QuranSurahModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.number)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.arabicName)
      ..writeByte(3)
      ..write(obj.englishName)
      ..writeByte(4)
      ..write(obj.revelationType)
      ..writeByte(5)
      ..write(obj.numberOfAyahs)
      ..writeByte(6)
      ..write(obj.juz)
      ..writeByte(7)
      ..write(obj.page)
      ..writeByte(8)
      ..write(obj.translation)
      ..writeByte(9)
      ..write(obj.transliteration)
      ..writeByte(10)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuranSurahModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
