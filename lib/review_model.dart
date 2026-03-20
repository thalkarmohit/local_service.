import 'package:hive/hive.dart';

part 'review_model.g.dart';

@HiveType(typeId: 2)
class ReviewModel extends HiveObject {
  @HiveField(0)
  String providerId;

  @HiveField(1)
  String reviewerName;

  @HiveField(2)
  String comment;

  @HiveField(3)
  int rating;

  @HiveField(4)
  DateTime date;

  ReviewModel({
    required this.providerId,
    required this.reviewerName,
    required this.comment,
    required this.rating,
    required this.date,
  });
}