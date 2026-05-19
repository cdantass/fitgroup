import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

const List<Color> kGroupColors = [
  AppTheme.purple,
  AppTheme.amber,
  AppTheme.coral,
  AppTheme.teal,
  Color(0xFF3B82F6),
  Color(0xFFEC4899),
];

class Group {
  final String id;
  String name;
  String description;
  Color color;
  int members;
  bool isJoined;
  bool isOwner;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    this.members = 1,
    this.isJoined = false,
    this.isOwner = false,
  });
}