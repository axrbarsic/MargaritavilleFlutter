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

## 2026-07-09 — Checkpoint 2: donor Summary contract и Pixel 8 Emulator

- Репозиторий опубликован как public backup:
  `https://github.com/axrbarsic/MargaritavilleFlutter`; `origin` настроен,
  `main` и рабочая ветка `codex/flutter-migration-foundation` отправлены.
- По прямому разрешению Alex создан AVD `margarita_pixel_8_api36` без скачивания
  нового image: Pixel 8, Android 16/API 36 ARM64, 1080 x 2400, 420 dpi. Flutter
  beta установлена только на `emulator-5554`; физический Pixel не затронут.
- Зафиксированы тестами и реализованы первые Swift build 37 visual tokens:
  почти чёрный фон, status palette, housekeeper palette, компактный header,
  progress counts, status filters, puzzle unlock, 4-column grid, tile 98 pt,
  radius 16, rounded black typography и timestamp на каждом номере.
- Чтобы Swift `.rounded` не заменялся разным системным шрифтом на iOS/Android,
  дизайн-система получила единый variable Nunito Sans из официального
  `google/fonts`; лицензия OFL 1.1 сохранена рядом с font asset.
- Generic Material AppBar, большие отдельные count cards, instruction block,
  outer section card, inline reset icon и ложные borders/shadows удалены с
  основного Summary. Сброс сохранён в right-swipe action sheet.
- Status chips реально фильтруют секции; puzzle требует завершённого жеста
  справа налево и возвращает в выбор комнат. Контракт закреплён отдельными
  geometry/color/type/interaction widget tests.
- На Pixel 8 Emulator создан рабочий fixture из 20 комнат и сделан screenshot
  baseline `build/qa/pixel8-emulator-summary-20.png`; Swift donor fixture из
  27 комнат повторно снят как `build/qa/swift-donor-current-27.png`.
- Emulator перешёл на software OpenGL из-за текущего давления на RAM, поэтому
  его FPS не считается baseline. После сборок disk guard показывает warning:
  свободно 23 GiB; до следующих тяжёлых артефактов нужна безопасная уборка.

Открытые части Summary parity: настоящий settings flow, полный room action
menu (VIP/schedule/media), Matrix background/общий visual runtime, HDR/EDR и
haptics. Физический Pixel сейчас заблокирован, поэтому финальный visual/gesture
прогон этого checkpoint накоплен как отдельный гейт после разблокировки; ADB,
сборки и автоматические проверки от блокировки не зависят.

## 2026-07-10 — Checkpoint 3: room actions, VIP и schedule

- Read-only аудит Swift build 37 подтвердил активный compact action contract:
  свайп комнаты идёт вправо, порог `clamp(width * 0.72, 58, 84)`, быстрый бросок
  учитывает predicted finish; меню должно открываться даже на pending-комнате.
- Hardcode 48 pt и условие «меню только когда доступен reset» удалены. Typed
  action sheet теперь всегда содержит `Голос/медиа`, `VIP включить/выключить`,
  `Назначить время` и условный `Вернуть в жёлтый` в donor-порядке.
- Добавлены versioned commands и единый controller/repository path для VIP,
  установки/очистки schedule и пакетного due-transition. Pure-Dart домен
  сохраняет `vipUpdatedAt` и timestamp очистки schedule независимо от phase.
- Controller command queue теперь сериализует конкурентные gesture/timer/sheet
  мутации. Tests-first сценарий сначала воспроизвёл потерю второго перехода
  (`pending -> open` вместо `pending -> open -> ready`), затем закрепил fix.
- Schedule sheet повторяет donor contract: часы 8–4, минуты 00/15/30/45,
  AM/PM, следующая четверть часа, `Очистить` и `Установить`. Due-время
  проверяется при входе/foreground и одним timer каждые 15 секунд.
- Введён `RoomScheduleNotificationClient` и стабильный notification ID.
  Reset, clear и due-transition покрыты тестом обязательной отмены. Пока
  подключён честный no-op; platform adapters iOS/Android остаются следующим
  отдельным блоком.
- Два donor-дефекта сознательно не перенесены: reset scheduled-room не оставляет
  старое уведомление и не стирает timestamp факта очистки, поэтому старое
  расписание не должно воскреснуть при будущем merge.
- На Pixel 8 Emulator комната 105 стала scheduled/pink на 1:30 AM, затем
  автоматически перешла в open после due; VIP комнаты 106 сохранился после
  force-stop/cold relaunch. Скриншоты action menu, schedule sheet и scheduled
  grid лежат в ignored `build/qa`.
- `Голос/медиа` пока явно сообщает о следующем platform-services блоке и не
  выдаётся за готовую media parity-функцию. VIP persistence готов, его
  jelly/HDR/SDR presentation относится к следующему visual-runtime checkpoint.

## 2026-07-10 — Checkpoint 4: общий visual runtime, VIP jelly и status pulse

- По `shared-app-foundation` общий clock/lifecycle выделен как
  `shared-foundation`, Summary visual policy — как `shared-parameterized`, а
  room workflow/status mapping и persistence оставлены `app-specific`.
- Добавлен один `VisualRuntimeScope` с единственным `AnimationController` на
  весь Summary. Ячейки подписываются на общий throttled clock и не создают
  собственные ticker/controller/timer; это закреплено architecture guard.
- Runtime работает только при активном VIP или transient pulse, имеет balanced
  budget 30 FPS и гаснет в background, reduced-motion и выключенном
  `TickerMode`. Тяжёлого `BackdropFilter` поверх анимации нет.
- VIP-ячейка получила детерминированные build 37 scale/offset формулы со stable
  room seed и same-color SDR glow. Это перенос визуального контракта, а не
  SwiftUI-кода; полный волнистый shape mask и настоящий iPhone EDR остаются
  отдельными измеряемыми ступенями.
- Status pulse повторяет donor timeline: 420 ms rise, пик до 580 ms, 2 s
  cooling tail, cleanup 2.73 s, brightness multiplier 2 и rubber amplitude
  1.7. События generation-aware и не записываются в Drift, поэтому старый pulse
  не проигрывается после rebuild/relaunch.
- На Pixel 8 Emulator подтверждены два разных живых VIP-кадра комнаты 106 и
  полный status transition комнаты 109 `pending -> open`: доменный статус и
  header counters изменились, immediate/tail screenshots показали расширение,
  same-color flash и охлаждение без fatal exception/layout overflow.

## 2026-07-10 — Checkpoint 5: persisted visual Settings и живой VIP-контур

- Read-only аудит Swift build 37 зафиксировал точный active contract категории
  `Разработчик -> Экспериментальное`: labels, subtitles, ranges, reset values,
  defaults и влияние каждого параметра на `squareGrid4`.
- Tests-first добавлены pure-Dart `AppearanceSettings`, repository contract и
  typed `SharedPreferencesAsync` adapter. Шесть значений сохраняются отдельно;
  JSON blob и framework imports в settings domain запрещены architecture guard.
- Donor-defaults совпадают: live cells выкл, spring intensity 72%, VIP jelly
  вкл/0.75x, VIP HDR выкл, status HDR pulse выкл. Исторические Swift keys не
  читаются: Flutter beta остаётся отдельным sandbox с namespaced keys.
- Настройки открываются настоящим экраном из кнопки Summary, применяются через
  app-level visual policy adapter и сохраняются до публикации нового UI state.
  Reset возвращает только visual effects и не затрагивает рабочую смену.
- Live cells дают rubber envelope без ложного HDR; status HDR имеет приоритет и
  добавляет same-color flash; VIP HDR отвечает за отдельный статичный SDR light
  fallback. Ранее смешанный пульсирующий glow удалён как расхождение с donor.
- VIP jelly теперь действительно двигает контур через общий-clock
  `CustomClipper<Path>` с stable seed, а не только масштабирует прямоугольник.
  Два последовательных Pixel-кадра комнаты 106 показали разные живые края.
- Мёртвый donor slider `Скорость пружины` не перенесён: Swift build 37 читает
  его в `squareGrid4`, но не использует. Flutter не выдаёт неработающий control
  за parity-функцию.
- На Pixel 8 Emulator настройки включены, изменён jelly speed до 1.35x и после
  force-stop/relaunch полностью восстановлены. Сильно деградировавший
  software-rendered AVD однажды дал system-starvation ANR (process start был
  задержан примерно на 14 s, focus event — на 7.3 s); после clean host-GPU boot
  тот же APK стабильно стартовал за 2.140 s и 1.936 s без ANR, fatal exception
  или overflow, idle process — 0% CPU.
- Debug host-GPU Emulator с одним активным волнистым VIP держал 16-21% guest
  process CPU. Это только ранний сигнал бюджета: profile/thermal/FPS gate на
  физическом Pixel и iPhone обязателен до повышения frame rate или массового
  VIP-сценария.
- После добавления typed preferences собран iOS Simulator target: beta bundle
  `com.alex.margaritaville.flutter.beta`, `0.1.0 (2)`, universal x86_64/arm64;
  `shared_preferences_foundation.framework` реально встроен. Физический iPhone
  и Swift donor data не затрагивались.

Открытые части Settings parity: остальные категории, общий reset confirmation,
нативный iPhone EDR bridge и физический performance gate.

## 2026-07-10 — Checkpoint 6: app-wide Matrix Rain и activity leases

- Read-only аудит Swift build 37 зафиксировал активный background contract:
  default `matrixRain`, speed `1.0` с диапазоном `0.08...3.0`, 80 колонок,
  Courier-like bold glyphs, диапазоны длины/скорости/opacity, четыре копии
  зелёной головы и тёмную vignette поверх `#020804`.
- По `shared-app-foundation` clock/renderer host оставлены
  `shared-foundation`, параметры Matrix — `shared-parameterized`, а выбранный
  режим и его persistence — `app-specific`. Swift/SpriteKit-код не копировался.
- Единственный `VisualRuntimeScope` поднят в app composition root под всем
  Navigator. Matrix теперь одинаково продолжается за Summary и Settings;
  вложенный Summary runtime удалён.
- Runtime получил reference-counted activity leases: один ticker работает для
  всех видимых эффектов и полностью засыпает после последнего клиента, а также
  в background, reduced-motion и выключенном `TickerMode`.
- Pure-Dart deterministic field заранее создаёт 80 колонок; styled glyph
  paragraphs кэшируются один раз. Кадр двигает только координаты с общим
  30 FPS clock; `BackdropFilter`, per-drop ticker/controller/timer и повторные
  renderer hosts запрещены architecture guard.
- Settings сохраняют mode и speed отдельными typed values. Реализованы только
  честно рабочие `Выкл` и `Matrix`; TV noise и локальное video не показаны как
  готовые режимы и остаются следующими renderer/adapters.
- На host-GPU Pixel 8 Emulator подтверждены Matrix за Summary и Settings,
  переключение на чёрный фон, persistence обоих режимов после force-stop/cold
  relaunch и отсутствие fatal exception, ANR и layout overflow. Финальная
  profile-сборка стартовала cold за 1.041 s.
- Profile-замер с одним VIP: чёрный фон держал примерно 14-16%, Matrix вместе
  с VIP — 32-35% одного guest CPU core. Эксперимент с per-column `Picture`
  caching не снизил CPU и добавил около 20-25 MB RSS, поэтому не вошёл в код.
  Это emulator-сигнал; финальные FPS/thermal/energy гейты остаются за
  физическими Pixel 8 и iPhone.
- Осознанно открытые части точного Matrix parity: случайная 3% замена glyphs,
  adaptive LOD/thermal governor и физический performance gate.
- Полный quality gate зелёный: format, analyze, 53 tests, architecture и
  300-line size guards. Дополнительно собран unsigned physical iOS profile
  artifact `0.1.0 (2)`: arm64 и beta bundle
  `com.alex.margaritaville.flutter.beta`.
