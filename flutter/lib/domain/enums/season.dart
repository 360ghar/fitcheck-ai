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

/// API-facing value for outbound filter payloads and writes.
///
/// backend/app/models/outfit.py VALID_SEASONS spells the all-season value
/// 'all-season' (the web app's spelling); the enum name is allSeason. Every
/// outbound season value must go through [seasonApiValue]: the backend list
/// filter is an exact string match (`q.in_("season", ...)`,
/// backend/app/api/v1/outfits.py), so emitting 'allseason' silently hid
/// web-created all-season outfits.
extension SeasonApiValue on Season {
  String get seasonApiValue =>
      this == Season.allSeason ? 'all-season' : name.toLowerCase();
}
