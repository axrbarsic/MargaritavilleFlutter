import 'package:flutter/foundation.dart';

final class VisualRuntimeActivityController {
  VisualRuntimeActivityController({required VoidCallback onActivityChanged})
    : _onActivityChanged = onActivityChanged;

  final VoidCallback _onActivityChanged;
  final Set<Object> _activeClients = <Object>{};

  int get activeClientCount => _activeClients.length;
  bool get hasActiveClients => _activeClients.isNotEmpty;

  void setActive(Object client, {required bool active}) {
    final changed = active
        ? _activeClients.add(client)
        : _activeClients.remove(client);
    if (changed) _onActivityChanged();
  }

  void remove(Object client) {
    if (_activeClients.remove(client)) _onActivityChanged();
  }
}
