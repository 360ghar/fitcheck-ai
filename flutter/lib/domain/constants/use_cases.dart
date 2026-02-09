class UseCases {
  static const List<String> defaults = [
    'formal',
    'informal',
    'party',
    'date',
    'dinner',
    'lunch',
  ];

  static String normalize(String value) {
    return value.trim().toLowerCase();
  }

  static List<String> normalizeList(Iterable<String>? values) {
    if (values == null) return const [];

    final seen = <String>{};
    final normalized = <String>[];

    for (final value in values) {
      final tag = normalize(value);
      if (tag.isEmpty || seen.contains(tag)) continue;
      seen.add(tag);
      normalized.add(tag);
    }

    return normalized;
  }

  static String displayLabel(String value) {
    final normalized = normalize(value);
    if (normalized.isEmpty) return '';
    return '${normalized[0].toUpperCase()}${normalized.substring(1)}';
  }
}
