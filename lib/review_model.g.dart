// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

class ReviewModelAdapter extends TypeAdapter<ReviewModel> {
  @override
  final int typeId = 2;

  @override
  ReviewModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReviewModel(
      providerId: fields[0] as String,
      reviewerName: fields[1] as String,
      comment: fields[2] as String,
      rating: fields[3] as int,
      date: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ReviewModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.providerId)
      ..writeByte(1)
      ..write(obj.reviewerName)
      ..writeByte(2)
      ..write(obj.comment)
      ..writeByte(3)
      ..write(obj.rating)
      ..writeByte(4)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ReviewModelAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}