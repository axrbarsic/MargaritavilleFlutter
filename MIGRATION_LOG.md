# Хронология миграции

## 2026-07-09 — Checkpoint 1: canonical domain и SQLite-вертикаль

- Прочитаны `AGENTS.md`, `MIGRATION_START.md` и обязательные документы/актуальный
  код Swift-эталона на `967bb2c` (code baseline `d0344ba`, build 37).
- Подтверждены beta bundle ID `com.alex.margaritaville.flutter.beta`, iOS 17 и
  доступность физического iPhone 17 Pro Max `00008150-001418301E68C01C`.
- Зафиксирован canonical schema v2 с explicit `RoomPhase`, schedule overlay,
  milestone/field timestamps, VIP и selection tombstones.
- Добавлены versioned application commands, duplicate-room blocking, workday
  lock и terminal simple-cycle с explicit reset.
- Поднят Drift schema v2 и атомарный repository поверх нормализованных таблиц;
  даты хранятся как ISO-8601 text без потери миллисекунд.
- Counter scaffold заменён operational shell: выбор уборщицы/зоны/номеров,
  фиксация смены и реальная summary-сетка с long-press переходами.
- Добавлены golden fixture, domain/application/repository/widget tests,
  архитектурный guard и versioned pre-commit quality gate.
- Локально зелёные `format`, `analyze`, 16 tests и architecture/size guards.
- Собран unsigned physical-device artifact `Runner.app`: arm64, beta bundle ID,
  `0.1.0 (2)`, minimum iOS 17.0.
- Signed install/run заблокирован внешним provisioning state: Xcode сообщает
  `No Accounts` и не находит development profile для нового beta bundle ID.
  Действующий certificate и профили других приложений есть; identity не
  подменялась. Нужен вход Apple ID в Xcode и создание profile для beta ID.

Открытый следующий critical path: расширить setup до полного редактируемого
housekeeper/work-block workflow и history/event/outbox projection, затем
закрепить ранний EDR overlay spike до тяжёлых визуальных эффектов.

## 2026-07-09 — Signing blocker устранён

- Apple Account заново подключён в Xcode; для team `J6MW4855LU` создан
  Xcode-managed development profile именно для
  `com.alex.margaritaville.flutter.beta`.
- Beta identity не менялась и не подменялась bundle ID соседних приложений.
- Debug build успешно подписался и установился, но `flutter run` не смог
  подключиться к Dart VM из-за отсутствия Local Network permission у Terminal.
- Для независимой device-проверки собран подписанный profile build `0.1.0 (2)`.
- Profile app установлено через `devicectl`, запущено на физическом iPhone 17
  Pro Max и подтверждено живым процессом `/Runner.app/Runner`.

## 2026-07-09 — Android shell и физический Pixel 8

- По прямому решению Alex открыт Android-track; iPhone остаётся эталоном
  HDR/EDR и performance, Android получает отдельные adapters/SDR fallback.
- Добавлен штатный Flutter Android shell с изолированным application ID
  `com.alex.margaritaville.flutter.beta` и label `Margaritaville Beta`.
- Release-вариант намеренно не подписывается debug-ключом. Настоящая Android
  release signing identity будет отдельным осознанным checkpoint.
- Architecture guard проверяет Android beta identity и запрещает утечку
  сгенерированного default package.
- Подтверждён физический Pixel 8 `44171FDJH003R5`: Android 17/API 37 beta,
  arm64-v8a, 1080 x 2400, density override 500, font scale 1.15.
- Debug APK собран, установлен и запущен. Flutter использует Impeller/Vulkan;
  fatal exceptions и layout overflow в проверенном сценарии не обнаружены.
- На debug cold start зафиксировано `Skipped 78 frames`, fully drawn около
  2.342 s. Это performance-сигнал для будущего profile/warm-run гейта, а не
  основание считать debug startup финальной производительностью.
- На устройстве проверены setup/summary, защита обычного tap, long press
  `pending -> open -> ready`, обновление счётчиков и сохранение Drift после
  force-stop/relaunch.
- Зелёные `format`, `analyze`, 16 tests и architecture guard.

## 2026-07-09 — Живой visual baseline Swift-донора

- Через iPhone Mirroring снят живой основной экран установленного нативного
  `MargaritavilleSwift` build 37; donor data не изменялись.
- Подтверждён активный профиль `simpleCycle + squareGrid4`: Matrix-фон,
  компактная шапка, status filters, puzzle unlock, палитры уборщиц, четыре
  колонки, timestamps, VIP jelly и плотная группировка по уборщицам.
- Состояние со 100+ ячейками является намеренным stress fixture. Частично
  скрытые числа слева в шапке в этом состоянии не считать визуальным дефектом.
- Текущий Flutter UI признан честным operational shell, но не visual-parity
  реализацией: generic Material geometry/colors/header существенно расходятся
  с живым Swift-донором.
- Следующий parity checkpoint: детерминированный основной экран с одной
  уборщицей и восемью комнатами, доведённый вертикально от domain/Drift до
  точной геометрии, жестов и физического iPhone + Pixel QA. Детали и гейты — в
  `Docs/VisualParityPlan.md`.

## 2026-07-09 — Swift-донор на iPhone 17 Pro Max Simulator

- Alex явно разрешил Simulator для повседневного обхода экранов/жестов и
  screenshot baseline, чтобы физический iPhone оставался доступен ему.
- Подтверждён latest donor: `0.1.0 (37)`, branch
  `codex/restore-pre-xhotel-margaritaville`, HEAD `967bb2c`; рабочий HDR fix —
  `d0344ba`. `VIPHDREffects.swift` и `RoomStatusHDRPulseEvent.swift` входят в
  simulator target.
- Build 37 собран read-only из Swift-репозитория в отдельный Flutter
  `build/swift-donor-simulator-derived`, установлен и запущен на iPhone 17 Pro
  Max Simulator `BE4AB2BD-CD2A-4D0F-A73C-B31E8E2D6C0B` с iOS 26.3.
- Первая unsigned simulator-сборка с `CODE_SIGNING_ALLOWED=NO` падала SIGTRAP в
  CoreData/CloudKit: Swift-донор включает CloudKit preset-store на Simulator.
  Обычная Xcode ad-hoc simulator signing сохранила simulated entitlements и
  устранила crash без изменения Swift-кода.
- В отдельной simulator SwiftData-базе штатным setup оставлены 27 комнат —
  обычная рабочая нагрузка из диапазона Alex 18–30. Каталог и физический iPhone
  не менялись; kill/relaunch сохранил счётчик 27.
- Simulator проверяет layout, navigation, gestures, state и SDR fallback. EDR
  headroom, точные haptics, camera/mic/Speech, thermal и 120 Hz performance
  остаются обязательными гейтами физического iPhone.
