import Flutter
import StoreKit

/// Introductory-offer eligibility for the paywall.
///
/// The Flutter side cannot answer this on its own. `in_app_purchase` exposes
/// products and purchases but not `Product.SubscriptionInfo
/// .isEligibleForIntroOffer`, which only exists in StoreKit 2 and only in
/// Swift. Without it the paywall would either advertise a free month to a user
/// who already used one (refund requests and one-star reviews) or hide the
/// offer from every new user (no trial at all).
///
/// The channel answers with **three** states:
///   `true`  – eligible now, so the paywall may promise the free month
///   `false` – not eligible (already used, or not a new subscriber)
///   `null`  – unknown: no StoreKit, no product, or a store error
///
/// `null` must never be treated as `false`. A transient App Store failure that
/// read as "ineligible" would silently withdraw the offer from every user
/// during the outage.
enum TrialEligibilityChannel {
  static let name = "fitcheck.ai/trial_eligibility"

  /// Registers the channel on the given registry. Called from AppDelegate once
  /// the Flutter engine exists.
  static func register(with registry: FlutterPluginRegistry) {
    guard let registrar = registry.registrar(forPlugin: "TrialEligibilityChannel") else {
      return
    }
    let channel = FlutterMethodChannel(
      name: name,
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "isEligibleForIntroOffer" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard
        let arguments = call.arguments as? [String: Any],
        let productId = arguments["productId"] as? String,
        !productId.isEmpty
      else {
        result(
          FlutterError(
            code: "bad_arguments",
            message: "isEligibleForIntroOffer requires a non-empty productId",
            details: nil
          )
        )
        return
      }
      if #available(iOS 15.0, *) {
        Task {
          // Hop back to the main actor: FlutterResult must be called there.
          let eligible = await eligibility(for: productId)
          await MainActor.run { result(eligible) }
        }
      } else {
        // StoreKit 2 is iOS 15+. Older targets get "unknown", so the paywall
        // falls back to the honest non-trial copy.
        result(nil)
      }
    }
  }

  /// `nil` whenever the answer is not a confident boolean.
  @available(iOS 15.0, *)
  private static func eligibility(for productId: String) async -> Bool? {
    do {
      let products = try await Product.products(for: [productId])
      guard let product = products.first, let subscription = product.subscription else {
        // The product is not resolvable right now (not published, wrong
        // environment, or offline). Unknown, not ineligible.
        return nil
      }
      return await subscription.isEligibleForIntroOffer
    } catch {
      return nil
    }
  }
}
