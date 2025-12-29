import 'dart:ui';
import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 2)
class Habit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String categoryId;

  @HiveField(3)
  int colorValue;

  @HiveField(4)
  bool completed;

  // Основной конструктор (для Hive)
  Habit({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.colorValue,
    this.completed = false,
  });

  // Удобный фабричный (для UI)
  factory Habit.create({
    required String id,
    required String title,
    required String categoryId,
    required Color color,
    bool completed = false,
  }) {
    return Habit(
      id: id,
      title: title,
      categoryId: categoryId,
      colorValue: color.value,
      completed: completed,
    );
  }

  // Для UI
  Color get color => Color(colorValue);

  // JSON (если где-то ещё используется)
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'categoryId': categoryId,
    'color': colorValue,
    'completed': completed,
  };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
    id: json['id'],
    title: json['title'],
    categoryId: json['categoryId'] ?? json['category'],
    colorValue: json['color'],
    completed: json['completed'] ?? false,
  );

  // copyWith
  Habit copyWith({bool? completed}) {
    return Habit(
      id: id,
      title: title,
      categoryId: categoryId,
      colorValue: colorValue,
      completed: completed ?? this.completed,
    );
  }
}
