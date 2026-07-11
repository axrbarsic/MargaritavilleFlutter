# Контракт локального media foundation

## Граница системы

Flutter владеет сценарием комнаты, metadata, immutable media identity, Drift
manifest/history/outbox и экраном просмотра. Захват выполняет официальный
`camera` adapter из `shared/media/capture`; он не знает о комнате, смене и
`originDeviceId`. Application-слой присоединяет эти данные после захвата.

Фото переносится byte-for-byte. Decode/re-encode, вторичный camera engine и
полный JSON в SharedPreferences запрещены.

## Порядок публикации

```text
temporary capture
  -> prepare: length + SHA-256, без app-owned файла
  -> durable Drift promotion journal
  -> copy в недоверенный *.copying
  -> flush + length/SHA verification
  -> atomic rename *.copying -> verified *.partial
  -> atomic rename *.partial -> final Media/<id>.<ext>
  -> одна Drift transaction: manifest + history + outbox + delete journal
  -> best-effort cleanup temporary capture
```

Проверенный `.partial` immutable: другой checksum с тем же media ID — terminal
integrity conflict, а не повод перезаписать файл.

## Startup recovery

Рабочий UI не монтируется до первого recovery pass. Recovery обрабатывает все
journal-записи независимо; одна retriable ошибка не мешает восстановить
следующие. Garbage collection tombstoned media выполняется даже после promotion
error.

- успешная/duplicate операция публикуется и очищает transient;
- missing source без verified stage, checksum conflict и ignored projection
  получают durable quarantine с причиной и временем;
- quarantined запись исключается из следующего startup pass и не блокирует
  смену, но остаётся для диагностики;
- retriable storage/database failure показывает русский экран с `Повторить`.

## Camera lifecycle

- один официальный camera session;
- `ResolutionPreset.max`, `enableAudio: false`;
- open/close/resume идут последовательно, новый open ждёт dispose старого;
- preview cover вычисляется из orientation-aware aspect ratio без визуальных
  коэффициентов;
- физическое разрешение, цвет, permission и round-trip проверяются на реальных
  iPhone/Pixel. Simulator/emulator являются только временным functional gate.

## Обязательные гейты

```sh
tool/verify_media_foundation_contract.sh
tool/verify_drift_schema.sh
flutter test test/shared/media test/features/room_details test/app/room_media_recovery_gate_test.dart
tool/quality_gate.sh
```

Crash matrix: до journal, после journal, mid-copy, после verified stage, после
final rename и после manifest commit. Перед commit также обязательны bundle
platform/codesign guard и physical media/storage smoke при доступности устройств.
