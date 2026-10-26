import '../../core/i18n/l10n.dart';

/// Localized name for a try-on option.
///
/// The option lists are plain API strings (`studio white`, `standing front`)
/// rather than an enum, because they are passed straight to the backend. Only
/// the display name is translated; an unknown value is title-cased and shown as
/// stored so a value added on the server still renders.
String tryOnOptionLabel(AppLocalizations l10n, String value) {
  switch (value.trim().toLowerCase()) {
    case 'casual':
      return l10n.styleCasual;
    case 'formal':
      return l10n.styleFormal;
    case 'business':
      return l10n.styleBusiness;
    case 'sporty':
      return l10n.styleSporty;
    case 'streetwear':
      return l10n.styleStreetwear;
    case 'elegant':
      return l10n.styleElegant;

    case 'studio white':
      return l10n.tryOnBackgroundStudioWhite;
    case 'studio gray':
    case 'studio grey':
      return l10n.tryOnBackgroundStudioGrey;
    case 'urban street':
      return l10n.tryOnBackgroundUrban;
    case 'nature':
      return l10n.tryOnBackgroundNature;
    case 'minimal':
      return l10n.tryOnBackgroundMinimal;

    case 'standing front':
      return l10n.tryOnPoseFront;
    case 'standing side':
      return l10n.tryOnPoseSide;
    case 'walking':
      return l10n.tryOnPoseWalking;
  }
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}
