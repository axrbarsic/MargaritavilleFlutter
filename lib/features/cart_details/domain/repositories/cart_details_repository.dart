import '../../application/commands/cart_details_command.dart';
import '../models/cart_details_snapshot.dart';

enum CartDetailsCommitStatus { applied, duplicate, ignored }

abstract interface class CartDetailsRepository {
  Future<CartDetailsSnapshot> load({
    required String sessionId,
    required String assignmentId,
  });

  Future<CartDetailsCommitStatus> commit(CartDetailsCommand command);
}
