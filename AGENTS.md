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

## Scope По Умолчанию

- Любое пожелание Alex без явного ограничения относится одновременно к iOS,
  Android и Web. Scope сужается только прямой формулировкой `только iOS`,
  `только Android/Pixel`, `только Web` или эквивалентом.
- Web получает тот же функциональный смысл, когда browser API это позволяют.
  При невозможности честного паритета заранее назвать точное ограничение и
  реализовать явно маркированный fallback; не выдавать имитацию за native parity.

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

## Неприкосновенный HDR/EDR Фундамент

- Перед любым изменением HDR/EDR, VIP jelly, status pulse, scroll geometry или
  native ownership полностью читать `Docs/NATIVE_VISUAL_RUNTIME_CONTRACT.md`.
- Flutter владеет доменным состоянием, layout и typed scene description, но не
  имитирует HDR. Реальный high-range paint остаётся платформенным: iOS —
  SharedAppFoundation/Metal/CoreGraphics EDR, Android API 34+ — Gainmap и
  системный HDR headroom. Яркость всего окна не менять.
- Pigeon lease `(surfaceSessionId, activationId, contentRevision)` и независимый
  geometry stream являются публичным внутренним ABI. Stale configure, geometry,
  clear и ready обязаны быть no-op на обеих платформах.
- Flutter fallback скрывается только после frame commit точной activation и
  revision. Удалённая из native membership ячейка немедленно возвращает fallback.
- Один window overlay и один OS-vsync clock на платформу. Запрещены per-cell
  ticker/animator/timer, PlatformView на ячейку и передача анимации по channel
  каждый кадр.
- Любая правка этого контура обязана пройти Pigeon-generation check, Flutter EDR
  tests, Android JVM tests, architecture guard и физический smoke на iPhone 17
  Pro Max и Pixel 8. PNG/screenshot не доказывает HDR-яркость.

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

## Универсальная Тактильная Отдача

- Каждое дискретное подтверждённое действие пользователя во всём приложении
  по умолчанию обязано иметь семантический haptic cue: navigation, selection,
  toggle, confirm, warning, destructive action и status change. Отсутствие cue
  допускается только как явное документированное исключение с тестом.
- Новые экраны и controls наследуют этот контракт автоматически. Нельзя
  откладывать haptics как декоративную доработку после реализации функции.
- Flutter/UI вызывает только единый typed `InteractionFoundation` boundary.
  Прямые `HapticFeedback`, `UIFeedbackGenerator`, `Vibrator` и platform-channel
  обходы вне foundation запрещены и должны ломать architecture guard.
- Быстрые повторные tap должны получать мгновенный cue без ожидания Drift,
  сети, HDR frame commit или звука. Cue привязывается к принятому локальному
  действию/пороговому событию, а durable command выполняется следом.
- Не вибрировать на каждый кадр drag/scroll/animation и не дублировать haptics
  системной клавиатуры. Для непрерывного жеста cue допустим только на дискретных
  detent/commit/cancel порогах.
- Звук, haptic и HDR/visual pulse координируются одной interaction policy, но
  отказ звука или native HDR не должен задерживать тактильную отдачу.

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
- Физический Pixel 5 `redfin` (`09111FDD4000L7`, Android 14, 90 Гц) —
  дополнительный low-end regression/performance device. Build 20 запускается,
  но cold start показал Choreographer bursts `Skipped 50/74 frames`; не
  объявлять его startup performance зелёным без отдельного profile gate.
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
- Profile-сборку на физический iPhone устанавливать через
  `tool/install_ios_profile.sh`. Скрипт обязан завершить старый процесс до
  замены bundle и запускать новый с `--terminate-existing`: живой процесс из
  предыдущего devicectl-install может удерживать SQLite во время schema upgrade
  и оставлять startup recovery на экране «Проверяю локальные медиа...».
- Успех `devicectl install/launch` не считать runtime smoke-тестом: проверить
  хотя бы первое обращение к локальному хранилищу внутри открытого приложения.
- После каждого блока: format, analyze, tests, физическая сборка, commit и push,
  если remote настроен.
- Не коммить секреты, `.dart_tool`, `build`, DerivedData и чужие изменения.

## Работа При Заблокированном Mac

- Блокировка экрана не является блокером разработки: продолжать все доступные
  headless/CLI-задачи — чтение и правку кода, тесты, анализ, сборки, генерацию,
  работу с Git, `adb`, `xcrun` и доступные проверки без GUI.
- Не пытаться обходить системную блокировку или автоматически вводить пароль.
  Действия, которым действительно нужен видимый интерфейс Chrome, Simulator,
  Emulator или защищённого приложения, складывать в короткую очередь и
  выполнять после ручной разблокировки, не останавливая независимый critical
  path.
- Видеофайлы и изображения анализировать напрямую с диска; публичный web-share
  использовать только как fallback, чтобы visual QA не зависел от состояния
  рабочего стола.

## Старт

- Новую migration-сессию начинать с `MIGRATION_START.md`.
- Не останавливаться на плане: после ориентации реализовать первый проверяемый
  checkpoint и продолжать critical path до реального блокера.
- Для каждого крупного checkpoint держать отдельного read-only sub-agent
  `Architecture Overview/Challenger`: до реализации он проверяет выбранную
  границу, а перед commit снова смотрит на проект сверху, ищет зацикливание на
  симптомах, локальный optimum и более правильную замену подхода. Этот агент не
  пишет тот же код и не дублирует обычный review; его обязанность — иметь право
  предложить refactor или полную смену архитектуры ради общей миграционной цели.
