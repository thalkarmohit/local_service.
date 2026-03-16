import 'package:hive/hive.dart';

part 'provider_model.g.dart';

@HiveType(typeId: 0)
class ProviderModel extends HiveObject {

  @HiveField(0)
  String name;

  @HiveField(1)
  String service;

  @HiveField(2)
  String exp;

  @HiveField(3)
  String phone;

  @HiveField(4)
  double totalRating;

  @HiveField(5)
  int ratingCount;

  ProviderModel({
    required this.name,
    required this.service,
    required this.exp,
    required this.phone,
    this.totalRating = 0,
    this.ratingCount = 0,
  });

  double get averageRating {
    if (ratingCount == 0) return 0;
    return totalRating / ratingCount;
  }
}