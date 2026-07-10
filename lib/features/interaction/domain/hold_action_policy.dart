final class HoldActionPolicy {
  const HoldActionPolicy({
    required this.holdStartDelay,
    required this.holdWarningDelay,
    required this.commitDelay,
    required this.maximumMovement,
  });

  static const donor = HoldActionPolicy(
    holdStartDelay: Duration(milliseconds: 140),
    holdWarningDelay: Duration(milliseconds: 330),
    commitDelay: Duration(milliseconds: 460),
    maximumMovement: 8,
  );

  final Duration holdStartDelay;
  final Duration holdWarningDelay;
  final Duration commitDelay;
  final double maximumMovement;
}
