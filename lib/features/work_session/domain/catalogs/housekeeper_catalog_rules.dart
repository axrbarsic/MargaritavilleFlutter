import '../models/housekeeper.dart';

final class HousekeeperCatalogRules {
  const HousekeeperCatalogRules();

  static const paletteKeys = <String>[
    'aqua',
    'amber',
    'coral',
    'orchid',
    'sky',
    'mint',
    'ruby',
    'violet',
    'lime',
    'slate',
  ];

  Housekeeper? makeHousekeeper({
    required String displayName,
    required List<Housekeeper> existing,
    required DateTime changedAt,
  }) {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) return null;
    final duplicateKey = _printedSheetDuplicateKey(trimmed);
    if (existing.any(
      (value) => _printedSheetDuplicateKey(value.displayName) == duplicateKey,
    )) {
      return null;
    }
    final usedIds = existing.map((value) => value.id).toSet();
    final preferredId = stableId(trimmed);
    var id = preferredId;
    for (var suffix = 2; usedIds.contains(id); suffix++) {
      id = '$preferredId-$suffix';
    }
    return Housekeeper(
      id: id,
      displayName: _canonicalDisplayName(trimmed),
      paletteKey: paletteKeys[existing.length % paletteKeys.length],
      updatedAt: changedAt,
    );
  }

  String stableId(String displayName) {
    final folded = _fold(displayName);
    final parts = folded.split(RegExp(r'[^a-z0-9]+'))
      ..removeWhere((value) => value.isEmpty);
    return parts.isEmpty ? 'housekeeper' : parts.join('-');
  }

  static const _canonicalByDuplicateKey = <String, String>{
    'ana|anazine|anazline': 'Ana',
    'bebita|bebitha': 'Bebita',
    'gurlene|gurline': 'Gurlene',
    'kerlande|kerlange': 'Kerlange',
    'milodene|omelenepm': 'Omelene PM',
    'rosaire|rosalie|rosario': 'Rosaire',
  };

  static String _canonicalDisplayName(String displayName) {
    return _canonicalByDuplicateKey[_printedSheetDuplicateKey(displayName)] ??
        displayName;
  }

  static String _printedSheetDuplicateKey(String displayName) {
    final token = _normalizedToken(displayName);
    final candidates = <String>{
      token,
      if (token.endsWith('pm')) token.substring(0, token.length - 2),
    }..remove('');
    for (final key in _canonicalByDuplicateKey.keys) {
      if (candidates.any(key.split('|').contains)) return key;
    }
    return candidates.isEmpty ? token : (candidates.toList()..sort()).first;
  }

  static String _normalizedToken(String value) {
    return _fold(value).replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  static String _fold(String value) {
    var result = value.toLowerCase();
    const replacements = <String, String>{
      'àáâãäåāăąǎǟǡǻ': 'a',
      'çćĉċč': 'c',
      'ďđ': 'd',
      'èéêëēĕėęě': 'e',
      'ĝğġģ': 'g',
      'ĥħ': 'h',
      'ìíîïĩīĭįıǐ': 'i',
      'ĵ': 'j',
      'ķ': 'k',
      'ĺļľŀł': 'l',
      'ñńņňŉŋ': 'n',
      'òóôõöøōŏőǒǿ': 'o',
      'ŕŗř': 'r',
      'śŝşš': 's',
      'ţťŧ': 't',
      'ùúûüũūŭůűųǔ': 'u',
      'ŵ': 'w',
      'ýÿŷ': 'y',
      'źżž': 'z',
    };
    for (final entry in replacements.entries) {
      for (final scalar in entry.key.runes) {
        result = result.replaceAll(String.fromCharCode(scalar), entry.value);
      }
    }
    return result
        .replaceAll('æ', 'ae')
        .replaceAll('œ', 'oe')
        .replaceAll('ß', 'ss');
  }
}
