/// Item condition enum
enum Condition {
  clean,
  dirty,
  laundry,
  repair,
  donate;

  String get displayName {
    switch (this) {
      case Condition.clean:
        return 'Clean';
      case Condition.dirty:
        return 'Dirty';
      case Condition.laundry:
        return 'In Laundry';
      case Condition.repair:
        return 'Needs Repair';
      case Condition.donate:
        return 'To Donate';
    }
  }

  String get value => name;

  static Condition fromString(String value) {
    return Condition.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Condition.clean,
    );
  }

  static List<String> get allNames => Condition.values.map((e) => e.displayName).toList();
}
