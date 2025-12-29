import 'dart:ui';
import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String time;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String categoryId;

  @HiveField(5)
  String iconPath;

  @HiveField(6)
  int colorValue;

  // Основной конструктор (для Hive)
  Task({
    required this.id,
    required this.title,
    required this.time,
    required this.date,
    required this.categoryId,
    required this.iconPath,
    required this.colorValue,
  });

  // Удобный фабричный (для UI)
  factory Task.create({
    required String id,
    required String title,
    required String time,
    required DateTime date,
    required String categoryId,
    required String iconPath,
    required Color color,
  }) {
    return Task(
      id: id,
      title: title,
      time: time,
      date: date,
      categoryId: categoryId,
      iconPath: iconPath,
      colorValue: color.value,
    );
  }

  // Для UI
  Color get color => Color(colorValue);

  Task copyWith({
    String? id,
    String? title,
    String? time,
    DateTime? date,
    String? categoryId,
    String? iconPath,
    Color? color,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      iconPath: iconPath ?? this.iconPath,
      colorValue: color?.value ?? colorValue,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'time': time,
    'date': date.toIso8601String(),
    'categoryId': categoryId,
    'iconPath': iconPath,
    'color': colorValue,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    time: json['time'],
    date: DateTime.parse(json['date']),
    categoryId: json['categoryId'],
    iconPath: json['iconPath'],
    colorValue: json['color'] ?? 0xFF1565C0,
  );
}
