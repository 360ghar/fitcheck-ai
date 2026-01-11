/// Season enum
enum Season {
  spring,
  summer,
  fall,
  winter,
  allSeason;

  String get displayName {
    switch (this) {
      case Season.spring:
        return 'Spring';
      case Season.summer:
        return 'Summer';
      case Season.fall:
        return 'Fall';
      case Season.winter:
        return 'Winter';
      case Season.allSeason:
        return 'All Season';
    }
  }

  String get value => name;

  static Season fromString(String value) {
    return Season.values.firstWhere(
      (e) => e.value == value || (value == 'all-season' && e == Season.allSeason),
      orElse: () => Season.allSeason,
    );
  }

  static List<String> get allNames => Season.values.map((e) => e.displayName).toList();
}
