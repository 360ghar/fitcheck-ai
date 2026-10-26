import '../../core/i18n/l10n.dart';
import 'models/photoshoot_models.dart';

/// Localized names for the photoshoot presets.
///
/// The enums keep their English `label`/`description` getters: the API still
/// receives `linkedin` and `portrait`, and a prompt builder that runs without a
/// `BuildContext` still needs an English name to send. Everything a person reads
/// goes through these extensions instead.
extension LocalizedPhotoshootUseCase on PhotoshootUseCase {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    PhotoshootUseCase.linkedin => l10n.photoshootUseLinkedin,
    PhotoshootUseCase.datingApp => l10n.photoshootUseDating,
    PhotoshootUseCase.modelPortfolio => l10n.photoshootUsePortfolio,
    PhotoshootUseCase.instagram => l10n.photoshootUseInstagram,
    PhotoshootUseCase.aesthetic => l10n.photoshootUseAesthetic,
    PhotoshootUseCase.custom => l10n.photoshootUseCustom,
  };

  String localizedDescription(AppLocalizations l10n) => switch (this) {
    PhotoshootUseCase.linkedin => l10n.photoshootDescLinkedin,
    PhotoshootUseCase.datingApp => l10n.photoshootDescDating,
    PhotoshootUseCase.modelPortfolio => l10n.photoshootDescPortfolio,
    PhotoshootUseCase.instagram => l10n.photoshootDescInstagram,
    PhotoshootUseCase.aesthetic => l10n.photoshootDescAesthetic,
    PhotoshootUseCase.custom => l10n.photoshootDescCustom,
  };
}

extension LocalizedPhotoshootAspectRatio on PhotoshootAspectRatio {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    PhotoshootAspectRatio.square => l10n.aspectSquare,
    PhotoshootAspectRatio.portrait => l10n.aspectPortrait,
    PhotoshootAspectRatio.landscape => l10n.aspectLandscape,
    PhotoshootAspectRatio.portrait34 => l10n.aspectTall,
    PhotoshootAspectRatio.landscape43 => l10n.aspectWide,
  };
}

/// Localized name of a photoshoot step, in track order.
List<String> photoshootStepNames(AppLocalizations l10n) => [
  l10n.photoshootStepPhotos,
  l10n.photoshootStepSetup,
  l10n.photoshootStepCreating,
  l10n.photoshootStepResults,
];
