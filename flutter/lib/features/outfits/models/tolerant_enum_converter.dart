import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/enums/season.dart';
import '../../../domain/enums/style.dart';

/// Tolerant enum JSON converters for outfit `style`/`season`.
///
/// The backend does not validate `style`/`season` against VALID_STYLES /
/// VALID_SEASONS on write (length caps only), and rows are also written by
/// the web app and MCP with values the Flutter enums do not know (e.g.
/// style='Old Money'). The generated `$enumDecodeNullable` throws
/// ArgumentError on any unknown string, which used to fail the whole outfit
/// list and the public shared-outfit page off a single legacy row. These
/// converters decode unknown/null to null instead (both model fields are
/// nullable) while known values — including every stored spelling of
/// all-season — decode normally.
///
/// [SeasonApiConverter.toJson] is also the single outbound source of truth:
/// it emits the backend's canonical spelling ('all-season', see
/// backend/app/models/outfit.py VALID_SEASONS) so mobile-created rows and
/// filter payloads match the web's stored value. The backend list filter is
/// an exact string match (`q.in_("season", ...)`, backend/app/api/v1/outfits.py),
/// so 'allseason' silently hid web-created all-season outfits.
class TolerantStyleConverter implements JsonConverter<Style?, String?> {
  const TolerantStyleConverter();

  @override
  Style? fromJson(String? value) =>
      value == null ? null : _decodeStyle(value);

  @override
  String? toJson(Style? value) => value?.name;
}

class SeasonApiConverter implements JsonConverter<Season?, String?> {
  const SeasonApiConverter();

  @override
  Season? fromJson(String? value) =>
      value == null ? null : _decodeSeason(value);

  @override
  String? toJson(Season? value) => value?.seasonApiValue;
}

Style? _decodeStyle(String raw) {
  final value = raw.trim().toLowerCase();
  for (final style in Style.values) {
    if (style.name == value) {
      return style;
    }
  }
  return null;
}

Season? _decodeSeason(String raw) {
  final value = raw.trim().toLowerCase();
  // Every stored spelling of all-season: web 'all-season' (canonical),
  // snake_case 'all_season', legacy mobile 'allseason' (enum name
  // lower-cased).
  if (value == 'all-season' || value == 'all_season' || value == 'allseason') {
    return Season.allSeason;
  }
  for (final season in Season.values) {
    if (season.name == value) {
      return season;
    }
  }
  return null;
}
