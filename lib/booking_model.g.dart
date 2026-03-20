// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookingModelAdapter extends TypeAdapter<BookingModel> {
  @override
  final int typeId = 1;

  @override
  BookingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookingModel(
      providerName: fields[0] as String,
      service: fields[1] as String,
      phone: fields[2] as String,
      bookingDate: fields[3] as DateTime,
      status: fields[4] == null ? 'pending' : fields[4] as String,
      scheduledDate: fields[5] as DateTime?,
      scheduledTime: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BookingModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.providerName)
      ..writeByte(1)
      ..write(obj.service)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.bookingDate)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.scheduledDate)
      ..writeByte(6)
      ..write(obj.scheduledTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BookingModelAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}