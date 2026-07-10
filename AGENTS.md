# Margaritaville Flutter Agent Instructions

## Язык

- Всегда отвечать Alex только по-русски.
- Все видимые progress-заголовки и reasoning summaries писать по-русски.

## Идентичность И Изоляция

- Это самостоятельное Flutter-приложение в
  `/Users/alex/Developer/MargaritavilleFlutter`.
- Swift-эталон: `/Users/alex/Developer/MargaritavilleSwift`.
- Beta bundle ID: `com.alex.margaritaville.flutter.beta`.
- Android beta application ID: `com.alex.margaritaville.flutter.beta`.
- Не использовать production bundle ID до отдельного cutover.
- Не редактировать `MargaritavilleSwift`, `OceanKeyFlutterRun`, `OceanKeySwift`
  или другие соседние приложения без прямой необходимости и явного решения.
- `OceanKeyFlutterRun` является архивом и не нужен для этой миграции.

## Правило Переноса

- Переносить продуктовую идею, поведение, доменные правила и визуальный контракт,
  а не форму Swift/SwiftUI-кода.
- Flutter-код строить идиоматично: feature-first, pure Dart domain,
  application commands, repository contracts, Riverpod и Drift.
- Критичные данные не хранить полным JSON в SharedPreferences.
- SwiftData не открывать напрямую из Dart.
- Эффекты вести через единый visual runtime/frame clock, без ticker на ячейку.
- Настоящий iOS HDR/EDR, audio session, файловый Speech и точные haptics можно и
  нужно реализовывать узкими Swift-плагинами с типизированным Pigeon-контрактом.

## Проверка

- Основная iOS parity/performance-проверка — физический iPhone 17 Pro Max:
  `00008150-001418301E68C01C`.
- Android-track явно открыт Alex 2026-07-09. Проверять на физическом Pixel 8:
  `44171FDJH003R5`; Android Emulator не использовать без прямого разрешения.
- Для ежедневного чтения Swift-донора Alex явно разрешил iPhone 17 Pro Max
  Simulator `BE4AB2BD-CD2A-4D0F-A73C-B31E8E2D6C0B`. Он подходит для
  экранов/жестов/screenshot baseline, но не заменяет физический iPhone для
  EDR/HDR, haptics, media/Speech и performance.
- Flutter iOS Simulator не использовать без отдельного прямого разрешения.
- Перед тяжёлыми сборками запускать `~/.codex/tools/disk_guard.sh --force`.
- После каждого блока: format, analyze, tests, физическая сборка, commit и push,
  если remote настроен.
- Не коммить секреты, `.dart_tool`, `build`, DerivedData и чужие изменения.

## Старт

- Новую migration-сессию начинать с `MIGRATION_START.md`.
- Не останавливаться на плане: после ориентации реализовать первый проверяемый
  checkpoint и продолжать critical path до реального блокера.
