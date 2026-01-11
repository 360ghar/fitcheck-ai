/// Outfit style enum
enum Style {
  casual,
  formal,
  business,
  sporty,
  bohemian,
  streetwear,
  vintage,
  minimalist,
  romantic,
  edgy,
  preppy,
  artsy,
  other;

  String get displayName {
    switch (this) {
      case Style.casual:
        return 'Casual';
      case Style.formal:
        return 'Formal';
      case Style.business:
        return 'Business';
      case Style.sporty:
        return 'Sporty';
      case Style.bohemian:
        return 'Bohemian';
      case Style.streetwear:
        return 'Streetwear';
      case Style.vintage:
        return 'Vintage';
      case Style.minimalist:
        return 'Minimalist';
      case Style.romantic:
        return 'Romantic';
      case Style.edgy:
        return 'Edgy';
      case Style.preppy:
        return 'Preppy';
      case Style.artsy:
        return 'Artsy';
      case Style.other:
        return 'Other';
    }
  }

  String get value => name;

  static Style fromString(String value) {
    return Style.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Style.casual,
    );
  }

  static List<String> get allNames => Style.values.map((e) => e.displayName).toList();
}
