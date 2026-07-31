/// Abstraction for redeeming a referral code, implemented by the
/// subscription feature's repository. Keeps auth services free of a
/// compile-time dependency on the subscription feature (FL4).
abstract class ReferralRedemptionService {
  Future<void> redeemReferralCode(String code);
}
