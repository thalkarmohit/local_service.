import 'package:hive/hive.dart';

part 'booking_model.g.dart';

enum BookingStatus { pending, confirmed, cancelled }

@HiveType(typeId: 1)
class BookingModel extends HiveObject {
  @HiveField(0)
  String providerName;

  @HiveField(1)
  String service;

  @HiveField(2)
  String phone;

  @HiveField(3)
  DateTime bookingDate;

  @HiveField(4)
  String status; // 'pending', 'confirmed', 'cancelled'

  BookingModel({
    required this.providerName,
    required this.service,
    required this.phone,
    required this.bookingDate,
    this.status = 'pending',
  });
}