class DashboardStats {
  final int totalItems;
  final int totalOutfits;
  final int itemsAddedThisMonth;
  final int outfitsCreatedThisMonth;
  final int favoriteItemsCount;
  final int favoriteOutfitsCount;
  final MostWornItem? mostWornItem;

  const DashboardStats({
    required this.totalItems,
    required this.totalOutfits,
    required this.itemsAddedThisMonth,
    required this.outfitsCreatedThisMonth,
    required this.favoriteItemsCount,
    required this.favoriteOutfitsCount,
    this.mostWornItem,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalItems: _toInt(json['total_items']),
      totalOutfits: _toInt(json['total_outfits']),
      itemsAddedThisMonth: _toInt(json['items_added_this_month']),
      outfitsCreatedThisMonth: _toInt(json['outfits_created_this_month']),
      favoriteItemsCount: _toInt(json['favorite_items_count']),
      favoriteOutfitsCount: _toInt(json['favorite_outfits_count']),
      mostWornItem: json['most_worn_item'] is Map<String, dynamic>
          ? MostWornItem.fromJson(
              json['most_worn_item'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class MostWornItem {
  final String name;
  final int timesWorn;

  const MostWornItem({
    required this.name,
    required this.timesWorn,
  });

  factory MostWornItem.fromJson(Map<String, dynamic> json) {
    return MostWornItem(
      name: (json['name'] ?? '').toString(),
      timesWorn: DashboardStats._toInt(json['times_worn']),
    );
  }
}

class DashboardActivity {
  final String type;
  final String description;
  final DateTime? timestamp;

  const DashboardActivity({
    required this.type,
    required this.description,
    required this.timestamp,
  });

  factory DashboardActivity.fromJson(Map<String, dynamic> json) {
    final timestampRaw = json['timestamp']?.toString();
    return DashboardActivity(
      type: (json['type'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      timestamp: timestampRaw != null ? DateTime.tryParse(timestampRaw) : null,
    );
  }
}

class DashboardWeatherSuggestion {
  final double? temperature;
  final String? recommendation;

  const DashboardWeatherSuggestion({
    required this.temperature,
    required this.recommendation,
  });

  factory DashboardWeatherSuggestion.fromJson(Map<String, dynamic> json) {
    return DashboardWeatherSuggestion(
      temperature: _toDouble(json['temperature']),
      recommendation: json['recommendation']?.toString(),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}

class DashboardOutfitOfTheDay {
  final String? id;
  final String? name;
  final String? imageUrl;

  const DashboardOutfitOfTheDay({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory DashboardOutfitOfTheDay.fromJson(Map<String, dynamic> json) {
    return DashboardOutfitOfTheDay(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      imageUrl: json['image_url']?.toString(),
    );
  }
}

class DashboardSuggestions {
  final DashboardWeatherSuggestion? weatherBased;
  final DashboardOutfitOfTheDay? outfitOfTheDay;

  const DashboardSuggestions({
    required this.weatherBased,
    required this.outfitOfTheDay,
  });

  factory DashboardSuggestions.fromJson(Map<String, dynamic> json) {
    return DashboardSuggestions(
      weatherBased: json['weather_based'] is Map<String, dynamic>
          ? DashboardWeatherSuggestion.fromJson(
              json['weather_based'] as Map<String, dynamic>,
            )
          : null,
      outfitOfTheDay: json['outfit_of_the_day'] is Map<String, dynamic>
          ? DashboardOutfitOfTheDay.fromJson(
              json['outfit_of_the_day'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class DashboardData {
  final DashboardStats statistics;
  final List<DashboardActivity> recentActivity;
  final DashboardSuggestions suggestions;

  const DashboardData({
    required this.statistics,
    required this.recentActivity,
    required this.suggestions,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final statsJson = json['statistics'];
    final activityJson = json['recent_activity'];
    final suggestionsJson = json['suggestions'];

    return DashboardData(
      statistics: statsJson is Map<String, dynamic>
          ? DashboardStats.fromJson(statsJson)
          : DashboardStats.fromJson(const <String, dynamic>{}),
      recentActivity: activityJson is List
          ? activityJson
              .whereType<Map<String, dynamic>>()
              .map(DashboardActivity.fromJson)
              .toList()
          : <DashboardActivity>[],
      suggestions: suggestionsJson is Map<String, dynamic>
          ? DashboardSuggestions.fromJson(suggestionsJson)
          : const DashboardSuggestions(
              weatherBased: null,
              outfitOfTheDay: null,
            ),
    );
  }
}

class StreakMilestone {
  final int days;
  final String name;
  final String badge;

  const StreakMilestone({
    required this.days,
    required this.name,
    required this.badge,
  });

  factory StreakMilestone.fromJson(Map<String, dynamic> json) {
    return StreakMilestone(
      days: DashboardStats._toInt(json['days']),
      name: (json['name'] ?? '').toString(),
      badge: (json['badge'] ?? '').toString(),
    );
  }
}

class StreakData {
  final int currentStreak;
  final int longestStreak;
  final int streakFreezesRemaining;
  final int streakSkipsRemaining;
  final StreakMilestone? nextMilestone;

  const StreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.streakFreezesRemaining,
    required this.streakSkipsRemaining,
    required this.nextMilestone,
  });

  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      currentStreak: DashboardStats._toInt(json['current_streak']),
      longestStreak: DashboardStats._toInt(json['longest_streak']),
      streakFreezesRemaining:
          DashboardStats._toInt(json['streak_freezes_remaining']),
      streakSkipsRemaining:
          DashboardStats._toInt(json['streak_skips_remaining']),
      nextMilestone: json['next_milestone'] is Map<String, dynamic>
          ? StreakMilestone.fromJson(
              json['next_milestone'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}
