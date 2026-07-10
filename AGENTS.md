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

## Максимальная Частота Кадров

- Никаких app-side ограничений 30/60 FPS: все анимации и эффекты должны
  динамически использовать максимальную частоту обновления, которую ОС реально
  предоставляет текущему устройству — 60/90/120 Гц и будущие значения, без
  hardcode по модели телефона.
- Уважать только системное снижение частоты из-за Low Power Mode, thermal state,
  background/inactive lifecycle или планировщика ОС; не пытаться обходить эти
  ограничения. Adaptive LOD может упрощать визуальную работу, но не должен сам
  снижать частоту общего frame clock ниже предоставленного ОС vsync.
- Все непрерывные эффекты обязаны работать от одного process-wide,
  vsync-driven visual runtime/frame clock. Запрещены per-cell/per-effect ticker,
  controller, periodic timer и fixed-frame throttle.
- Фактическую cadence/FPS проверять на физических iPhone и Pixel; simulator и
  emulator подходят для функционального QA, но не являются performance-гейтом.

## Проверка

- Основная iOS parity/performance-проверка — физический iPhone 17 Pro Max:
  `00008150-001418301E68C01C`.
- Визуальный паритет никогда не подбирать на глаз и не исправлять выдуманными
  коэффициентами. Сначала извлечь точную формулу и метрики из актуального
  Swift build 37, затем закодировать их как проверяемый контракт.
- Для геометрии проверять отдельно layout bounds и фактически окрашенные paint
  bounds на снимке физического устройства. Допуск к Swift-эталону — не более
  1 pt; checkpoint нельзя считать готовым только по widget/semantics bounds.
- Android-track явно открыт Alex 2026-07-09. Проверять на физическом Pixel 8:
  `44171FDJH003R5`.
- Alex 2026-07-09 разрешил Pixel 8 Emulator для ежедневного visual/navigation
  QA: AVD `margarita_pixel_8_api36`, Android 16/API 36, обычно
  `emulator-5554`. Он не заменяет физический Pixel для density/font-scale,
  performance, thermal и длительных interaction-проверок.
- Для ежедневного чтения Swift-донора Alex явно разрешил iPhone 17 Pro Max
  Simulator `BE4AB2BD-CD2A-4D0F-A73C-B31E8E2D6C0B`. Он подходит для
  экранов/жестов/screenshot baseline, но не заменяет физический iPhone для
  EDR/HDR, haptics, media/Speech и performance.
- Flutter iOS Simulator не использовать без отдельного прямого разрешения.
- Перед тяжёлыми сборками запускать `~/.codex/tools/disk_guard.sh --force`.
- После iOS device build обязательно запускать
  `tool/verify_ios_app_bundle.sh`: все embedded frameworks должны иметь
  `platform IOS`, а не `IOSSIMULATOR`, и проходить deep codesign.
- Успех `devicectl install/launch` не считать runtime smoke-тестом: проверить
  хотя бы первое обращение к локальному хранилищу внутри открытого приложения.
- После каждого блока: format, analyze, tests, физическая сборка, commit и push,
  если remote настроен.
- Не коммить секреты, `.dart_tool`, `build`, DerivedData и чужие изменения.

## Старт

- Новую migration-сессию начинать с `MIGRATION_START.md`.
- Не останавливаться на плане: после ориентации реализовать первый проверяемый
  checkpoint и продолжать critical path до реального блокера.
