sealed class CartDetailsCommand {
  const CartDetailsCommand({
    required this.commandId,
    required this.sessionId,
    required this.assignmentId,
    required this.issuedAt,
    this.commandVersion = 1,
  });

  final String commandId;
  final String sessionId;
  final String assignmentId;
  final DateTime issuedAt;
  final int commandVersion;
}

final class SaveCartNoteCommand extends CartDetailsCommand {
  const SaveCartNoteCommand({
    required super.commandId,
    required super.sessionId,
    required super.assignmentId,
    required super.issuedAt,
    required this.text,
  });

  final String text;
}

final class SetCartConsumableQuantityCommand extends CartDetailsCommand {
  const SetCartConsumableQuantityCommand({
    required super.commandId,
    required super.sessionId,
    required super.assignmentId,
    required super.issuedAt,
    required this.itemId,
    required this.title,
    required this.quantity,
  });

  final String itemId;
  final String title;
  final int quantity;
}

final class SetCartConsumableCompletionCommand extends CartDetailsCommand {
  const SetCartConsumableCompletionCommand({
    required super.commandId,
    required super.sessionId,
    required super.assignmentId,
    required super.issuedAt,
    required this.itemId,
    required this.title,
    required this.isCompleted,
  });

  final String itemId;
  final String title;
  final bool isCompleted;
}
