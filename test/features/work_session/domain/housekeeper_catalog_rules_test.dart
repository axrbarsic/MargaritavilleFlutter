import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/work_session/domain/catalogs/housekeeper_catalog_rules.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/housekeeper.dart';

void main() {
  const rules = HousekeeperCatalogRules();
  final now = DateTime.utc(2027, 2, 10, 12);

  test('palette order exactly matches Swift build 37', () {
    expect(HousekeeperCatalogRules.paletteKeys, [
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
    ]);
  });

  test('add trims, folds diacritics, appends and cycles palette', () {
    final existing = _existing(now, count: 11);
    final added = rules.makeHousekeeper(
      displayName: '  Zoë Marie  ',
      existing: existing,
      changedAt: now,
    );

    expect(added?.id, 'zoe-marie');
    expect(added?.displayName, 'Zoë Marie');
    expect(added?.paletteKey, 'amber');
  });

  test('stable IDs use suffixes and punctuation fallback', () {
    final existing = [
      Housekeeper(
        id: 'zoe',
        displayName: 'Alice',
        paletteKey: 'aqua',
        updatedAt: now,
      ),
      Housekeeper(
        id: 'zoe-2',
        displayName: 'Bob',
        paletteKey: 'amber',
        updatedAt: now,
      ),
    ];

    expect(
      rules
          .makeHousekeeper(
            displayName: 'Zóe',
            existing: existing,
            changedAt: now,
          )
          ?.id,
      'zoe-3',
    );
    expect(
      rules
          .makeHousekeeper(
            displayName: '!!!',
            existing: const [],
            changedAt: now,
          )
          ?.id,
      'housekeeper',
    );
  });

  test('blank and printed-sheet duplicates are rejected honestly', () {
    final existing = [
      Housekeeper(
        id: 'anazline',
        displayName: 'Ana',
        paletteKey: 'aqua',
        updatedAt: now,
      ),
    ];

    expect(
      rules.makeHousekeeper(
        displayName: '   ',
        existing: existing,
        changedAt: now,
      ),
      isNull,
    );
    expect(
      rules.makeHousekeeper(
        displayName: 'Anazine',
        existing: existing,
        changedAt: now,
      ),
      isNull,
    );
  });
}

List<Housekeeper> _existing(DateTime now, {required int count}) => [
  for (var index = 0; index < count; index++)
    Housekeeper(
      id: 'person-$index',
      displayName: 'Person $index',
      paletteKey: HousekeeperCatalogRules
          .paletteKeys[index % HousekeeperCatalogRules.paletteKeys.length],
      updatedAt: now,
    ),
];
