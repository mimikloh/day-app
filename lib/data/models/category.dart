import 'package:hive/hive.dart';
import 'dart:ui';

part 'category.g.dart';

@HiveType(typeId: 1)
class Category extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String iconPath;

  @HiveField(3)
  int colorValue;

  // Основной (для Hive)
  Category({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.colorValue,
  });

  // Удобный фабричный (для UI)
  factory Category.create({
    required String id,
    required String name,
    required String iconPath,
    required Color color,
  }) {
    return Category(
      id: id,
      name: name,
      iconPath: iconPath,
      colorValue: color.value,
    );
  }

  // Использование в UI
  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconPath': iconPath,
    'color': color.value,
  };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'],
    name: json['name'],
    iconPath: json['iconPath'],
    colorValue: json['color'],
  );
}