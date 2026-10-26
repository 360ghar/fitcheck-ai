import 'package:flutter/widgets.dart';

import '../../domain/enums/category.dart';
import '../../domain/enums/condition.dart';
import '../../domain/enums/season.dart';
import '../../domain/enums/style.dart';
import 'l10n.dart';

/// Localized display names for the app's fixed vocabularies.
///
/// The enums keep English `displayName` getters for their existing 40+ call
/// sites and for any context-free use (logs, tests, analytics labels). Anything
/// a person reads goes through these extensions instead.
///
/// The canonical value never changes: the API still receives `tops`, the
/// database still stores `all-season`, and analytics still count `casual`.
/// Only the label is translated, which is what lets a user switch language
/// without duplicating a single closet row.
extension LocalizedCategory on Category {
  String label(AppLocalizations l10n) => switch (this) {
    Category.tops => l10n.categoryTops,
    Category.bottoms => l10n.categoryBottoms,
    Category.shoes => l10n.categoryShoes,
    Category.accessories => l10n.categoryAccessories,
    Category.outerwear => l10n.categoryOuterwear,
    Category.swimwear => l10n.categorySwimwear,
    Category.activewear => l10n.categoryActivewear,
    Category.other => l10n.categoryOther,
  };
}

extension LocalizedCondition on Condition {
  String label(AppLocalizations l10n) => switch (this) {
    Condition.clean => l10n.conditionClean,
    Condition.dirty => l10n.conditionDirty,
    Condition.laundry => l10n.conditionLaundry,
    Condition.repair => l10n.conditionRepair,
    Condition.donate => l10n.conditionDonate,
  };
}

extension LocalizedSeason on Season {
  String label(AppLocalizations l10n) => switch (this) {
    Season.spring => l10n.seasonSpring,
    Season.summer => l10n.seasonSummer,
    Season.fall => l10n.seasonFall,
    Season.winter => l10n.seasonWinter,
    Season.allSeason => l10n.seasonAll,
  };
}

extension LocalizedStyle on Style {
  String label(AppLocalizations l10n) => switch (this) {
    Style.casual => l10n.styleCasual,
    Style.formal => l10n.styleFormal,
    Style.business => l10n.styleBusiness,
    Style.sporty => l10n.styleSporty,
    Style.bohemian => l10n.styleBohemian,
    Style.streetwear => l10n.styleStreetwear,
    Style.vintage => l10n.styleVintage,
    Style.minimalist => l10n.styleMinimalist,
    Style.romantic => l10n.styleRomantic,
    Style.edgy => l10n.styleEdgy,
    Style.preppy => l10n.stylePreppy,
    Style.artsy => l10n.styleArtsy,
    Style.other => l10n.styleOther,
  };
}

/// Localizes the fixed vocabularies that are stored as free strings rather than
/// enums: onboarding style and occasion choices, and the colour list.
///
/// A value that is not in the known set is returned unchanged. That is
/// deliberate: a user can type "Linen" as a colour and it must still render,
/// and an API value added before its translation lands must not disappear.
String localizedTaxonomy(AppLocalizations l10n, String value) {
  switch (value.trim().toLowerCase()) {
    case 'casual':
      return l10n.styleCasual;
    case 'formal':
      return l10n.styleFormal;
    case 'business':
      return l10n.styleBusiness;
    case 'sporty':
      return l10n.styleSporty;
    case 'bohemian':
      return l10n.styleBohemian;
    case 'streetwear':
      return l10n.styleStreetwear;
    case 'vintage':
      return l10n.styleVintage;
    case 'minimalist':
      return l10n.styleMinimalist;
    case 'romantic':
      return l10n.styleRomantic;
    case 'edgy':
      return l10n.styleEdgy;
    case 'preppy':
      return l10n.stylePreppy;
    case 'artsy':
      return l10n.styleArtsy;
    case 'classic':
      return l10n.styleClassic;
    case 'elegant':
      return l10n.styleElegant;
    case 'other':
      return l10n.styleOther;

    // `UseCases.defaults` uses a slightly different vocabulary from the
    // occasion taxonomy, so both sets are mapped here.
    case 'informal':
      return l10n.useCaseInformal;
    case 'date':
      return l10n.useCaseDate;
    case 'dinner':
      return l10n.useCaseDinner;
    case 'lunch':
      return l10n.useCaseLunch;

    case 'work':
      return l10n.occasionWork;
    case 'date night':
      return l10n.occasionDateNight;
    case 'travel':
      return l10n.occasionTravel;
    case 'wedding':
      return l10n.occasionWedding;
    case 'gym':
      return l10n.occasionGym;
    case 'weekend':
      return l10n.occasionWeekend;
    case 'party':
      return l10n.occasionParty;
    case 'interview':
      return l10n.occasionInterview;

    case 'black':
      return l10n.colorBlack;
    case 'white':
      return l10n.colorWhite;
    case 'grey':
    case 'gray':
      return l10n.colorGrey;
    case 'navy':
      return l10n.colorNavy;
    case 'brown':
      return l10n.colorBrown;
    case 'red':
      return l10n.colorRed;
    case 'blue':
      return l10n.colorBlue;
    case 'green':
      return l10n.colorGreen;
    case 'pink':
      return l10n.colorPink;
    case 'purple':
      return l10n.colorPurple;
    case 'yellow':
      return l10n.colorYellow;
    case 'orange':
      return l10n.colorOrange;
    case 'beige':
      return l10n.colorBeige;
  }
  return value;
}

/// Convenience for widgets: `context.categoryLabel(item.category)`.
extension TaxonomyContext on BuildContext {
  String categoryLabel(Category category) => category.label(l10n);
  String conditionLabel(Condition condition) => condition.label(l10n);
  String seasonLabel(Season season) => season.label(l10n);
  String styleLabel(Style style) => style.label(l10n);
  String taxonomyLabel(String value) => localizedTaxonomy(l10n, value);
}
