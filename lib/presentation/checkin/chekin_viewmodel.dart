import 'package:flutter/material.dart';

class ProductCheckin {
  final String name;
  final String description;
  final String iconAsset;
  final bool checkedIn;

  ProductCheckin({
    required this.name,
    required this.description,
    required this.iconAsset,
    this.checkedIn = false,
  });
}

class CheckinViewModel extends ChangeNotifier {
  final List<ProductCheckin> _products = [
    ProductCheckin(
      name: "HIIT Pro",
      description: "High-Intensity Interval Training",
      iconAsset: "assets/icons/hiit.svg",
      checkedIn: false,
    ),
    ProductCheckin(
      name: "Yoga Flex",
      description: "Daily Yoga Flexibility",
      iconAsset: "assets/icons/yoga.svg",
      checkedIn: true,
    ),
    ProductCheckin(
      name: "Cardio Burn",
      description: "Cardio Fat Burn Training",
      iconAsset: "assets/icons/cardio.svg",
      checkedIn: false,
    ),
    ProductCheckin(
      name: "Strength",
      description: "Strength Training",
      iconAsset: "assets/icons/strength.svg",
      checkedIn: false,
    )
  ];

  List<ProductCheckin> get products => List.unmodifiable(_products);

  // 预留后续打卡逻辑
  void checkIn(int index) {
    if (!_products[index].checkedIn) {
      _products[index] = ProductCheckin(
        name: _products[index].name,
        description: _products[index].description,
        iconAsset: _products[index].iconAsset,
        checkedIn: true,
      );
      notifyListeners();
    }
  }
}
