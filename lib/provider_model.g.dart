// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProviderModelAdapter extends TypeAdapter<ProviderModel> {
  @override
  final int typeId = 0;

  @override
  ProviderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProviderModel(
      name: fields[0] as String,
      service: fields[1] as String,
      exp: fields[2] as String,
      phone: fields[3] as String,
      totalRating: fields[4] as double,
      ratingCount: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ProviderModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.service)
      ..writeByte(2)
      ..write(obj.exp)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.totalRating)
      ..writeByte(5)
      ..write(obj.ratingCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
