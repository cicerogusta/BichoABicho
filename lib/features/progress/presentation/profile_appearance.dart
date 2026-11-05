import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

Color profileColor(String animalId) => switch (animalId) {
  'dog' => AppColors.peach,
  'cat' => AppColors.lavender,
  'lion' => AppColors.sage,
  _ => AppColors.blue,
};
