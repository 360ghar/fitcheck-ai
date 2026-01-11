/// Item categories enum
enum Category {
  tops,
  bottoms,
  shoes,
  accessories,
  outerwear,
  swimwear,
  activewear,
  other;

  String get displayName {
    switch (this) {
      case Category.tops:
        return 'Tops';
      case Category.bottoms:
        return 'Bottoms';
      case Category.shoes:
        return 'Shoes';
      case Category.accessories:
        return 'Accessories';
      case Category.outerwear:
        return 'Outerwear';
      case Category.swimwear:
        return 'Swimwear';
      case Category.activewear:
        return 'Activewear';
      case Category.other:
        return 'Other';
    }
  }

  String get value => name;

  static Category fromString(String value) {
    return Category.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Category.other,
    );
  }

  static List<String> get allNames => Category.values.map((e) => e.displayName).toList();
}
