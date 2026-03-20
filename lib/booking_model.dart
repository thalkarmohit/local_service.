import 'package:hive/hive.dart';

part 'booking_model.g.dart';

@HiveType(typeId: 1)
class BookingModel extends HiveObject {
  @HiveField(0)
  String providerName;

  @HiveField(1)
  String service;

  @HiveField(2)
  String phone;

  @HiveField(3)
  DateTime bookingDate; // when the booking was created

  @HiveField(4)
  String status;

  @HiveField(5)
  DateTime? scheduledDate; // the date user picked

  @HiveField(6)
  String? scheduledTime; // the time slot user picked e.g. "10:00 AM"

  BookingModel({
    required this.providerName,
    required this.service,
    required this.phone,
    required this.bookingDate,
    this.status = 'pending',
    this.scheduledDate,
    this.scheduledTime,
  });
}