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

## 2026-07-10 — Решение Alex: максимум аппаратной частоты кадров

- Для Flutter и Swift закреплён общий жёсткий инвариант: никаких app-side
  ограничений 30/60 FPS. Все анимации и эффекты должны динамически работать на
  максимальной частоте, которую ОС реально предоставляет устройству —
  60/90/120 Гц и будущих значениях.
- Допустимо только системное снижение cadence из-за Low Power Mode, thermal
  state, background/inactive lifecycle или планировщика ОС. Adaptive LOD должен
  уменьшать стоимость кадра, а не искусственно ограничивать общий vsync clock.
- Единственный process-wide visual runtime/frame clock остаётся обязательным;
  per-cell/per-effect ticker, controller, periodic timer и fixed-frame throttle
  запрещены. Указанный выше 30 FPS budget Checkpoint 4/6 теперь считается
  историческим состоянием и подлежит устранению.
- Performance/parity-гейт проводится на физических iPhone и Pixel; simulator и
  emulator не принимаются как доказательство фактических 90/120 FPS.

## 2026-07-10 — Checkpoint 7: точная Summary-геометрия, native EDR jelly и feedback foundation

- Alex подтвердил на физическом iPhone 17 Pro Max, что нативный EDR/HDR-всплеск
  Flutter по реальной яркости полностью совпал со Swift build 37. Это
  подтверждение относится только к iOS; Android HDR-паритет не заявлен.
- Источник расхождения шрифтов найден измерением, а не подбором размера. Donor
  базово использует `44 pt` для номера и `16 pt` для времени; эти значения в
  Flutter сохранены. Удалено ошибочное глобальное масштабирование высоты,
  padding, gap и radius на ширинах меньше 424 pt: теперь фиксированы donor
  `98 / 4 / 10 / 6 / 8 / 14 / 16`, меняется только ширина четырёх колонок.
- Имя уборщицы получило точный `minimumScaleFactor 0.62`, compressible layout и
  центрированный `1.5 pt` stroke без перекрытия последней буквы. Переполнение
  после minimum scale теперь клипуется, а не рисуется поверх соседнего UI.
- Screenshot-измерение iOS build 9 против donor показало одинаковые
  нормализованные ink-bounds: номер `0.315` против `0.308` высоты ячейки,
  timestamp `0.1208` против `0.1203`. Базовые `44/16` запрещено менять без
  нового измерительного доказательства.
- Исчезновение VIP-кляксы при native EDR устранено правильной двухслойной
  композицией: внешний native tile владеет одноразовым status rubber pulse,
  внутренний контейнер — EDR base/vip/pulse, build-37 jelly mask и transform.
  Flutter-текст и native fill используют одну формулу и Unix wall clock.
- Нативная jelly-маска работает через Core Animation animatable property и
  compositor-driven keyframes, без `CADisplayLink`, Timer и кадровых Pigeon
  сообщений. XCTest закрепляет детерминированный room-101 vector; два
  simulator-кадра дали `18 617` изменившихся silhouette pixels при сохранённом
  EDR-слое.
- По `shared-app-foundation` создан локальный reusable Flutter plugin
  `packages/interaction_foundation`: типизированный Pigeon API, независимые
  Swift/Kotlin adapters, audio context и best-effort degradation без влияния на
  domain mutation. App-specific room/status routing остаётся в Margaritaville.
- Перенесены 13 CC0/public-domain donor sounds вместе с лицензиями. Первый
  feedback slice повторяет три donor bucket: общий UI — rollover tick, обычная
  ячейка/action menu — confirm glass, зелёная ячейка — front desk bell.
  Нативный coalescer использует окно 45 ms, priority 20...80 и last-wins при
  равном приоритете.
- iOS adapter повторяет UIKit V2 cue/intensity, режим
  `AVAudioSession .ambient + mixWithOthers`, four-player pools,
  stop-before-play и custom volume `0.30`.
  Android adapter использует `SoundPool` sonification/maxStreams 1 и
  API-aware system haptics с fallback; его физическая калибровка остаётся
  обязательной на Pixel 8.
- Android profile APK build 9 собран и установлен на Pixel 8 Emulator; plugin
  стартует без fatal exception, sound assets присутствуют в обоих bundles.
  Физический Pixel сейчас отсутствует в `adb devices`/mDNS, поэтому установка и
  perceptual проверка Android отложены до его подключения.
- Первый физический smoke build 9 выявил двойной дефект Flutter 3.41.9 native
  assets. `objective_c.framework` после `embed_and_thin` сначала оставался с
  ad-hoc подписью, а после исправления подписи в device bundle попал Mach-O для
  `IOSSIMULATOR`. Команды install/launch это пропустили; ошибка проявилась при
  первом вызове локального хранилища уже внутри работающего приложения.
- Build 10 получил два принудительных барьера: pre-build сверяет `vtool`
  platform, удаляет конфликтующий `build/native_assets/ios` и инвалидирует iOS
  `install_code_assets.stamp`; post-embed снова проверяет каждый framework и
  только затем подписывает отсутствующий Team ID. В физическом bundle проверены
  `App`, `Flutter`, feedback, `objective_c`, preferences и `sqlite3`: все имеют
  `platform IOS`, deep codesign валиден, приложение установлено и запущено.
- Полный gate зелёный после модульного разбиения oversized room tile: format,
  analyze, 66 tests, 300-line size guard, architecture guard, native EDR
  XCTest, iOS device build и Android profile build. Физическое подтверждение
  новых VIP jelly, звука и haptics build 10 остаётся открытым пользовательским
  гейтом; подтверждённым пока является EDR build 8.

## 2026-07-10 — Checkpoint 8: iOS runtime guard, elastic scroll и sound assignments

- Alex подтвердил на физическом iPhone, что build 10 после замены ошибочного
  simulator framework снова открывает локальную смену. Успех восстановлен не
  очисткой всего проекта, а воспроизводимым pre/post native-assets guard.
- Регрессия «жёсткого» вертикального скролла сведена к конкретной разнице
  Flutter widgets: прежний вертикальный `ListView` сам добавлял
  `AlwaysScrollableScrollPhysics`, а новый общий EDR `SingleChildScrollView` —
  нет. При короткой смене контент не превышал viewport, поэтому стандартный iOS
  `BouncingScrollPhysics` не мог выйти за границу и дать резиновый отскок.
- Summary теперь явно использует на iOS
  `BouncingScrollPhysics(decelerationRate: normal)` поверх
  `AlwaysScrollableScrollPhysics`. Для Android функция возвращает `null`, то
  есть сохраняет его нативную platform physics без искусственной iOS-пружины.
  Widget-тест закрепляет обе ветки и отдельно короткий iPhone viewport.
- Swift build 37 показывает ровно три пользовательских назначения звука:
  «Все остальные действия», «Ячейка», «Зелёная ячейка». Flutter получил те же
  заголовки, пояснения, порядок, 14 пунктов palette включая «Без звука», preview
  и немедленное применение к уже работающему feedback runtime.
- Каждое назначение хранится отдельной namespaced строкой через repository и
  serial AsyncNotifier; JSON blob не используется. Общий typed preferences
  adapter вынесен из settings feature в `shared/persistence`.
- Отдельный haptics toggle намеренно не придуман: Swift build 37 передаёт
  `hapticsV2: true` жёстко на app root. Flutter повторяет этот контракт, а
  звуковое отключение не выключает тактильную отдачу.
- Physical iOS build `0.1.0 (11)` прошёл проверку шести embedded frameworks как
  `platform IOS`, deep codesign и установку на iPhone 17 Pro Max. Автозапуск был
  отклонён заблокированным экраном, поэтому perceptual scroll-гейт остаётся за
  ручным открытием build 11. Полный software gate зелёный: analyze, 71 test,
  format, file-size и architecture guards.

## 2026-07-10 — Checkpoint 9: cropped EDR composition для плавного скролла

- После восстановления `AlwaysScrollable`-пружины Alex подтвердил,
  что само прокручивание всё ещё ощущается грубо. Физика сверена с
  donor: Swift build 37 использует обычный `ScrollView` без кастомной
  deceleration/spring, что совпадает с Flutter `BouncingScrollPhysics.normal`.
- Найден рендерный источник грубости: единый iOS `UiKitView` для HDR
  всегда занимал всю высоту Summary, даже когда не было ни одной
  активной EDR-ячейки. При скролле iOS композировала этот нативный
  слой и Flutter-overlay поверх почти всей ленты.
- Overlay теперь монтируется только при активном VIP HDR или status
  pulse. Его bounds вычисляются как union реальных layout bounds только
  активных ячеек плюс точный worst-case bleed `11 pt` по X и `24 pt` по Y
  для 1.7x rubber, jelly transform и волнистой маски.
- Widget-тесты закрепляют отсутствие platform surface без EDR, bounds
  `Rect(9, 6, 127, 152)` для ячейки `96x98` в `(20, 30)` и нативную локальную
  координату ячейки `(11, 24)`, поэтому обрезка не сдвигает HDR.
- Добавлен profile integration benchmark с 36 комнатами, Matrix, jelly и
  одним VIP HDR. На iPhone 17 Pro Max Simulator после warm-up он зафиксировал
  `p95 build 3.271 ms`, `p95 raster 5.807 ms` при 60 Hz. Это зелёный
  функциональный и симуляторный бюджет-гейт, но не доказательство 120 Hz:
  жёсткий performance-гейт остаётся на физическом iPhone после разблокировки.
- Physical iOS profile build `0.1.0 (12)` прошёл bundle guard: все семь
  embedded frameworks имеют `platform IOS`, deep codesign валиден. Build 12
  установлен на iPhone 17 Pro Max; автозапуск отклонён только из-за
  заблокированного экрана.

## 2026-07-10 — Checkpoint 10: Summary header gesture state machines

- Активный Swift build 37, commit `967bb2c`, повторно прочитан как
  единственный источник timing/gesture-контракта. Цифры внесены сначала в
  красные tests, а не подобраны по ощущению.
- Settings теперь открываются только hold-жестом: полные
  `holdStart` в `140 ms`, `holdWarning` в `330 ms`, `holdCommit` и activation
  в `460 ms`; движение дальше `8 pt` отменяет все оставшиеся фазы.
  Короткий tap ничего не открывает. После commit идёт sound-only
  `settingsOpen` перед navigation callback.
- Selection puzzle получил exact pointer-translation без Flutter drag slop:
  start feedback после `2 pt`, warning при пересечении `82%`, commit при
  `100%`, подтверждение только на release и reset ровно через `160 ms`.
  Как и в текущем donor-коде, успешный release даёт два generic `confirm`,
  затем sound-only `selectionOpen` и только потом unlock callback.
- Внешний puzzle progress гасит Settings icon по exact-формуле
  `1 - clamp(progress * 1.65, 0, 1)`. Track fade, socket `34 pt`, piece
  `33 pt`, stroke alpha и тени сверены с активным SwiftUI-кодом.
- Status filters перед изменением фильтра вызывают ровно один
  `feedback.tap()`. Feedback controller получил тонкие full-hold и navigation
  methods; shared Pigeon/runtime не изменялся.
- Tests фиксируют exact timing boundaries, cue order/priorities, short tap,
  movement cancellation, puzzle thresholds, double-confirm, icon opacity и delayed reset.
  Полный software gate зелёный: format, analyze, `79 tests`, file-size и
  architecture guards.
- Android profile build `0.1.0 (13)` установлен на Pixel 8 Emulator. Живой
  smoke подтвердил: short tap игнорируется; `520 ms` hold открывает
  Settings; смещение больше `8 pt` отменяет; полный puzzle открывает
  Work Setup; filter применяется и отменяется; вертикальный scroll через
  ячейку не изменил counts/status. Тестовая смена после smoke снова
  заблокирована; fatal exception/overflow в logcat нет.
- Swift donor build 37 повторно запущен на разрешённом iPhone 17 Pro Max
  Simulator; bundle version `37` и Summary header подтверждены снимком.
- Physical iOS profile build `0.1.0 (13)` прошёл deep codesign и bundle guard
  семи `platform IOS` frameworks, затем установлен на iPhone 17 Pro Max.
  Экран iPhone остаётся заблокирован, поэтому реальные haptics/audio,
  120 Hz и runtime smoke ещё не заявлены. Физический Pixel 8 также не виден в
  ADB/mDNS; эмулятор не заменяет его haptics/audio/90 Hz gate.

## 2026-07-10 — Checkpoint 11: возврат ListView и безопасный отказ от production EDR

- Красными widget-тестами доказано, что обычный `GestureDetector` ячейки
  нарушал donor-контракт сразу в пяти местах: long press срабатывал в `500 ms`
  вместо `460 ms`, не отменялся после `8 pt`, диагональный вертикальный жест
  выигрывала ячейка вместо списка, invalid diagonal открывал action menu, а
  прямой прыжок за threshold ошибочно воспроизводил warning.
- Ячейка переведена на отдельный gesture-arena target: long press
  `460 ms / 8 pt`, horizontal recognition от `28 pt`, правый intent от
  `38 pt`, update dominance `2.8`, finish dominance `2.5` и точный порядок
  haptic thresholds. Вертикальный/диагональный scroll, левый swipe и все
  границы закреплены восемью widget-тестами.
- Build 14 доказал исправление gesture arena, но Alex подтвердил, что приятный
  iOS-отскок всё ещё отсутствует. Build 15 вернул implicit platform physics
  до изменения `d8c0aef`, но пользовательский perceptual gate снова был
  красным.
- Git-аудит нашёл настоящий структурный регресс в `b02899f`: ради нативного
  EDR прежний `ListView.separated` был заменён на
  `SingleChildScrollView + Column`. Build 16 вернул исходный ListView; Alex
  сразу подтвердил, что нормальный скролл и отскок вернулись.
- Попытка сохранять EDR через снятие/повторное монтирование `UiKitView` на
  ScrollStart/ScrollEnd дала мерцание, скачки яркости VIP и остановки около
  подсветки. Alex отклонил этот вариант и выбрал стабильный baseline до
  настоящего HDR/EDR.
- В production Summary полностью удалены `EdrOverlayScope`,
  `EdrOverlaySurface` и регистрация ячеек. `EdrOverlayPlugin` больше не
  регистрируется в `AppDelegate`. Нативный прототип остаётся в исходниках
  только для будущего изолированного исследования; архитектурный guard падает,
  если platform-view снова попадёт в Summary или будет зарегистрирован.
- Build 17 сохраняет старый `ListView.separated`, Flutter jelly/rubber,
  SDR-подсветку, точные шрифты, звуки/haptics и новые жесты, но намеренно не
  включает настоящий EDR. Он прошёл iOS bundle guard семи `platform IOS`
  frameworks и установлен на iPhone; автозапуск отклонён только заблокированным
  экраном. Android profile build 17 установлен на Pixel 8 Emulator без
  fatal/exception/overflow.
- Полный software gate зелёный: format, analyze, `82 tests`, file-size и
  architecture guards. Дополнительный test-support вынесен отдельно, чтобы
  gesture suite оставался ниже лимита `300` строк.
- Profile integration harness также возвращён с устаревшего finder
  `SingleChildScrollView` на `ListView`. На Pixel 8 Emulator сценарий с
  36 комнатами прошёл с `280` measured frames при `60 Hz`, p95 build
  `3.585 ms` и p95 raster `17.507 ms`. Функциональный non-strict gate зелёный;
  raster пока на `0.841 ms` выше 60-Hz бюджета, поэтому это не принимается как
  физическое доказательство 90/120 Hz и остаётся performance debt.
- Онлайн-аудит подтвердил выбранное направление. [Официальная документация
  Flutter по iOS Platform Views](https://docs.flutter.dev/platform-integration/ios/platform-views)
  предупреждает о performance trade-offs и советует placeholder texture на
  время Dart-анимаций. [Apple Explore EDR on
  iOS](https://developer.apple.com/videos/play/wwdc2022/10113/) требует для
  настоящего EDR отдельный `CAMetalLayer`,
  `wantsExtendedDynamicRangeContent`, FP16/10-bit формат и extended color
  space. Следующий HDR spike не должен возвращать прокручиваемый `UiKitView`:
  исследовать root-level native Metal layer либо
  [FlutterTextureRegistry](https://api.flutter.dev/ios-embedder/protocol_flutter_texture_registry-p.html)
  отдельным экспериментом с обязательным физическим scroll/HDR gate до
  подключения к Summary.

## 2026-07-10 — Checkpoint 12: настоящий EDR с исходным ListView

- Alex физически подтвердил build 17 как стабильную точку: нативный отскок
  вернулся, но настоящего EDR в ожидаемо отключённом baseline не было. Коммит
  `5a49e66` отправлен в GitHub до нового эксперимента.
- Аудит Swift build 37 подтвердил точный z-order ячейки: UIKit EDR fill лежит в
  `.background` под Flutter/SwiftUI-текстом, а jelly mask и pulse-transform
  применяются ко всей композиции. Поэтому root UIView поверх Flutter и stock
  `FlutterTexture` не сохраняют контракт.
- Build 18 реализовал один постоянный `EdrViewportSurface` как sibling перед
  неизменённым `ListView.separated`. Platform View больше не находится внутри
  scroll content, не монтируется заново на ScrollStart/ScrollEnd, не участвует
  в hit testing и клипуется строго viewport списка.
- Native viewport берёт ownership всех видимых background ячеек при включённом
  EDR, даже если конкретная комната не VIP и pulse сейчас не активен. Flutter
  делает заливку прозрачной только после native acknowledgment; текст, жесты и
  semantics остаются Flutter. Это убирает переключение ownership в момент VIP
  или status pulse.
- Alex проверил build 18 на физическом iPhone 17 Pro Max: настоящий EDR,
  VIP-клякса и нормальный scroll/отскок одновременно заработали. Он заметил
  возможные микропросадки и отдельную паузу jelly примерно на полсекунды при
  первом входе.
- Найдена детерминированная причина стартовой паузы: каждый начальный
  `layoutSubviews` принудительно перезапускал `EdrJellyMaskLayer` и четыре
  Core Animation wave. Build 19 больше не resynchronize'ит неизменившуюся
  конфигурацию; размер входит в `JellyConfiguration`, поэтому реальный resize
  всё ещё корректно создаёт новую фазу. Нативный XCTest фиксирует один запуск
  на повторных layout и новый запуск только после resize.
- Для устранения вероятных микропросадок Pigeon-контракт разделён на редкий
  `configureViewport` и частый `updateScrollOffset`. Полный batch видимых
  `EdrTileSnapshot` отправляется только при layout/recycling/filter/state
  change; на каждом scroll tick передаётся один `double`. Native контейнер
  двигает все EDR tiles одним отключённым от implicit animation transform.
  Revision и sequence защищают от устаревших сообщений разных каналов.
- Stress fixture теперь использует полный каталог Margaritaville: 184 комнаты
  в шести территориях, и по умолчанию все 184 являются VIP. Это намеренно
  тяжелее рабочего диапазона 18–45 комнат и должно выявить потолок EDR/jelly
  runtime.
- Build 19 прошёл profile device-компиляцию, iOS bundle guard семи
  `platform IOS` frameworks и установлен на физический iPhone. Полный software
  gate зелёный: format, analyze, 85 tests, file-size и architecture guards.
- Физический numeric performance run пока не получен: Flutter видит iPhone
  только как wireless и не может открыть mDNS из-за macOS Local Network
  permission (`No route to host`, UDP 5353). `devicectl` install работает, но
  автозапуск build 19 сейчас отклонён заблокированным iPhone. После
  разблокировки нужны два гейта: отсутствие стартовой jelly-паузы и profile
  scroll полного 184-VIP каталога при реальном 120-Hz бюджете `8.33 ms`.
- После подключения кабелем standalone profile probe обошёл mDNS: приложение
  само прокручивает Summary, пишет `FrameTiming` в app tmp, а результат
  извлекается через `devicectl`. Это даёт воспроизводимый физический gate без
  камеры, mirroring и зависимости от `flutter drive` discovery.
- Первая матрица A/B на iPhone 17 Pro Max строго разделила стоимость эффектов:
  без EDR/jelly — `119.93 FPS`; EDR без jelly — `117.99 FPS`; Flutter jelly без
  EDR — `105.49 FPS`; прежняя двойная EDR+jelly-композиция — только
  `64.60 FPS`, p95 raster `15.30 ms`. Значит, fixed Platform View и настоящий
  EDR сами по себе не являются bottleneck; проблема была в двух одновременно
  вычисляемых контурах и старой native маске.
- `EdrJellyMaskLayer` больше не пересчитывает сложный `UIBezierPath` через
  `CALayer.draw(in:)` на каждом кадре каждой видимой VIP-ячейки. Он стал
  `CAShapeLayer`; 12-секундные `path` keyframes рассчитываются один раз и
  интерполируются Core Animation. Число samples выводится из максимальной
  временной частоты формулы с коэффициентом `0.729`, Nyquist x2 и safety x1.5:
  при штатной скорости `0.75` получается `20`, а не произвольные `48`.
- Наборы путей кешируются по точным bit-pattern `rect/speed/seed/radius`, cache
  ограничен 256 entries и 32 MiB. Повторный проход вверх больше не строит те же
  пути заново. `resynchronizeEffects()` после app activation теперь
  перезапускает только pulse, но не jelly; XCTest закрепляет неизменный
  synchronization count после повторного layout и resync.
- Flutter продолжает двигать текст/foreground по donor transform, но при
  нативном EDR не строит второй невидимый `PhysicalShape`: animated edge
  contour имеет одного владельца, native tile. Итоговый самый тяжёлый прогон
  всех `184` комнат как VIP с EDR+jelly дал `117.40 FPS`, p95 build/raster
  `2.89/2.80 ms`, p99 `6.27/3.22 ms` и только `5` over-budget frames за
  34 секунды. Это улучшение относительно исходных `64.60 FPS` без снижения
  refresh rate, отключения EDR или визуального движения foreground.
- Рабочий probe на 45 комнатах подтвердил не нагрузочный, а variable-refresh
  режим: p99 build/raster `3.23/3.87 ms`, `0` кадров тяжелее `8.33 ms`, но
  средняя cadence callbacks `114.66`. В Flutter 3.41.9 локально проверен
  `vsync_waiter_ios.mm`: при нашем
  `CADisableMinimumFrameDurationOnPhone=true` engine выставляет iPhone
  `CAFrameRateRange(60, 120, preferred: 120)`. Apple прямо документирует, что
  ProMotion нельзя принудить к конкретной частоте: Core Animation учитывает
  thermal/power/system policy. Поэтому физический performance gate — hardware
  budget `8.33 ms`, p95/p99 и over-budget frames, а не требование ровно 120
  callbacks каждую секунду. Второй app-side `CADisplayLink` запрещён: он
  нарушил бы единый frame clock и снова создал конкурирующие часы.
- Переход на общий Metal renderer пока отложен по измеримому критерию: fixed
  UIKit EDR viewport с keyframed `CAShapeLayer` уже укладывает p99 существенно
  ниже 120-Hz бюджета даже при 184 VIP. Metal остаётся следующим уровнем только
  если будущий реальный сценарий даст over-budget frames, а не из-за системной
  variable-refresh cadence.
- Полный software gate checkpoint зелёный после codegen: format, analyze,
  `89 tests`, file-size `300` и architecture guards. Обычный physical iOS
  profile build `0.1.0 (20)` прошёл проверку 7 embedded frameworks как
  `platform IOS`, deep codesign, установлен и запущен на iPhone 17 Pro Max;
  после stress harness на телефоне снова находится production entrypoint.
- Параллельный physical smoke выполнен на старом Pixel 5 `redfin`, Android 14,
  90-Hz display: profile build 20 установлен адресно, cold launch успешен за
  `1815 ms`, Activity resumed, crash/ANR/Flutter/Platform exceptions нет.
  Android Choreographer на холодном старте сообщил два bursts `Skipped 50` и
  `Skipped 74 frames`; это зафиксировано как отдельный startup performance debt
  Pixel 5 и не смешивается с iOS steady-state EDR/jelly результатом.
- Physical build 20 выявил отдельную recycling race: после быстрого возврата к
  верхнему краю несколько VIP backgrounds появлялись примерно через полсекунды,
  а одна ячейка могла остаться визуально пустой. Flutter foreground фактически
  оставался, но чёрный текст становился невидимым, потому что stale native
  acknowledgement прежнего widget-generation уже сделал его фон прозрачным.
- Build 21 хранит native ownership не только по `roomId`, а по паре
  `roomId + GlobalKey` конкретного поколения. Поздний `dispose` удаляет запись
  только при совпадении ключа; любой entry/geometry change увеличивает content
  revision; ответ старой revision не может включить прозрачность и немедленно
  запускает следующий snapshot. Детерминированный deferred-bridge test
  воспроизводит замену виджета во время незавершённого configure и закрепляет
  fallback до acknowledgement нового поколения.
- Build 21 прошёл analyze, `90 tests`, file-size/architecture guards, physical
  iOS bundle guard 7 frameworks и установлен на iPhone. Финальный perceptual
  gate быстрого scroll/rebound после пользовательского screenshot пока открыт;
  checkpoint нельзя отправлять в GitHub до его подтверждения.
- Пользовательская 19.12-секундная HEVC screen recording build 21 дала более
  сильное доказательство, чем одиночный screenshot. При 60 FPS action sheet
  открывается как «Комната 111», то есть Flutter widget/gesture существует, но
  его чёрный foreground невидим без native background. Во время свайпов EDR
  fills отделяются от ячеек и видны полосами у верхнего края, затем после
  остановки возвращаются. Значит, оставшийся дефект — geometry/scroll anchor,
  а не потеря domain room, jelly path или ListView recycling.
- Build 22 добавляет controller-owned `ScrollController` и передаёт в EDR
  controller живой `ScrollPosition.pixels`. Полный snapshot теперь считывает
  этот offset в том же post-frame, где измеряет `RenderBox` global coordinates,
  очищает более старый pending offset и только затем создаёт layout revision.
  Это исключает повторное применение scroll delta к уже экранным coordinates.
- Собственный controller первоначально снял implicit primary-scroll
  `AlwaysScrollableScrollPhysics`; существующий donor-contract test это сразу
  поймал. Build 22 задаёт physics явно, поэтому anchor fix не откатывает
  подтверждённый нативный bounce. Targeted controller/header tests и analyze
  зелёные; physical iOS profile build 22 прошёл 7-framework bundle guard,
  установлен и запущен. Повторный пользовательский video/perceptual gate открыт.
- Пользовательская 9.82-секундная запись build 22 при фактических `59.99 FPS`
  доказала, что offset reanchor уменьшил, но не устранил дефект: во время
  инерционного scroll нативные EDR-fills всё ещё на несколько кадров оставались
  в прежних координатах, образовывали цветные полосы у верхней границы и
  оставляли чёрный Flutter foreground без фона. Причина архитектурная: fixed
  UIKit viewport и Flutter ListView двигались двумя асинхронными clocks через
  Pigeon, поэтому никакая очередная поправка offset не могла дать frame-exact
  композицию.
- Build 23 переносит единственный нативный EDR background layer внутрь того же
  scroll-content `Stack`, где находятся Flutter labels и gestures. Теперь UIKit
  fills и Flutter foreground получают один compositor transform от исходного
  `ListView`; per-frame Pigeon scroll API, native pending-scroll queue и второй
  affine scroll transform удалены полностью. `AlwaysScrollableScrollPhysics`
  сохранён, поэтому подтверждённый bounce остаётся владельцем Flutter, а
  настоящее EDR и jelly по-прежнему рисуются нативными Core Animation layers.
- Полный software gate build 23 зелёный: Pigeon/codegen, format, analyze,
  `91 tests`, file-size `300` и architecture guards. Physical iOS profile
  artifact `0.1.0 (23)` прошёл deep codesign и guard семи embedded frameworks
  как `platform IOS`, затем установлен на iPhone 17 Pro Max. Автозапуск был
  отклонён исключительно состоянием `Locked`; финальный быстрый scroll/bounce
  perceptual gate остаётся за разблокированным физическим устройством.
- Пользовательская 12.55-секундная physical screen recording build 23 при
  `59.99 FPS` подтвердила frame-exact совместное движение native fills и Flutter
  labels: прежнего независимого geometry lag больше нет. Но cold launch открыл
  следующий bottleneck: VIP-ячейки оставались чёрными примерно `1.5 s`, пока
  main thread последовательно строил `20` сложных path-keyframes для каждой
  уникальной jelly mask. При полной VIP-нагрузке это воспроизводит прежнюю
  activation freeze даже без scroll-channel.
- Build 24 переводит построение donor jelly paths с `UIBezierPath` на чистый
  `CGMutablePath` и выполняет cache misses в ограниченной двухпоточной
  `OperationQueue`. На main thread каждая VIP-ячейка немедленно получает
  округлый EDR fallback path, поэтому фон никогда не исчезает; готовая точная
  wave-анимация атомарно заменяет fallback только при совпадении generation.
  Старый async-result не может примениться после resize/recycle/disable.
- Physical all-184-VIP probe build 24 подтвердил, что Flutter pipeline сам по
  себе быстрый: p99 build/raster `3.42/3.56 ms`, `0` over-budget frames. Но
  постановка jelly-path jobs сразу для всех 184 комнат дала лишь `87.30 FPS`
  и `510` больших vsync gaps. Контрольный EDR-without-jelly прогон на той же
  scroll-content архитектуре дал `114.18 FPS`, p99 `2.00/4.22 ms` и только
  `61` gap. Значит, cadence терялась не из-за большого PlatformView или Flutter
  layout, а из-за бессмысленного cold-cache расчёта 184 offscreen масок.
- Build 25 добавляет отдельный fixed viewport key и держит в native EDR runtime
  только реально видимые tiles плюс точный вертикальный preload `240 pt`.
  PlatformView всё ещё находится в том же scroll-content и поэтому не теряет
  frame-exact геометрию; scroll notifications лишь коалесцируют membership
  snapshots, не двигают слой через channel. Если buffered room-set и content
  revision не изменились, bridge-вызов полностью пропускается. Offscreen cells
  остаются с Flutter fallback, поэтому recycling и быстрый fling не создают
  чёрных дыр, а cold queue больше не строит 184 jelly timelines одновременно.
- Physical probe build 25 показал, что один global `InheritedNotifier`
  перестраивал все 184 room widgets при каждом изменении buffered ownership:
  p99 build вырос до `13.65 ms`, `146` кадров вышли за бюджет. Build 26 заменил
  глобальное уведомление на tile-local `ValueNotifier`; это убрало rebuild
  fan-out, но выявило второй bottleneck: offscreen Flutter fallbacks всё ещё
  клиповали 184 jelly contours на общем frame clock.
- Build 27 делает iOS fallback намеренно статическим до native acknowledgement
  и полностью снимает offscreen tiles с visual clock; на Android Flutter jelly
  остаётся полноценным. Только принятые нативным viewport ячейки анимируют
  синхронный foreground, поэтому быстрый fling не создаёт ни чёрных holes, ни
  скрытой работы вне экрана.
- Финальный physical all-184-VIP probe build 27 при `120 Hz` дал `113.16 FPS`,
  p99 build/raster `3.43/3.77 ms`, max `5.44/6.77 ms`, `0` over-budget frames и
  `108` больших vsync gaps. Это практически совпадает с контрольным EDR без
  jelly (`114.18 FPS`) и радикально лучше промежуточного build 26 (`69.48 FPS`,
  `57` over-budget, `813` gaps). Перфоманс checkpoint по Flutter pipeline зелён;
  остаётся короткий physical perceptual gate cold launch + fast rebound.
- Build 28 восстановил точный двухслойный donor pulse внутри одной нативной
  `RGBA16Float / extendedLinearDisplayP3` поверхности: отдельный SDR
  `plusLighter` boost и отдельный EDR fill, а также donor transform
  `scaleCoefficient=0.09`, `verticalOffset=7`. Однако fixed content overlay всё
  ещё зависел от асинхронного ownership при recycling, поэтому физический
  perceptual gate остался красным.
- Build 29 перенёс native EDR surface непосредственно в каждый виртуализированный
  room slot. Это окончательно устранило пропадающие VIP-фоны при запуске и
  быстром возврате к началу, но создало две новые измеренные регрессии:
  прямоугольный Flutter fallback просвечивал под прозрачными краями jelly mask,
  а пользовательская HEVC-запись показала фактические `41.99 FPS`. Причина —
  hybrid-composition `UiKitView` на каждую видимую ячейку, а не Flutter layout.
- Build 30 ввёл узкий `CAMetalLayer` runtime с `rgba16Float`,
  `extendedLinearDisplayP3`, `wantsExtendedDynamicRangeContent`, аппаратным EDR
  headroom и единым `CADisplayLink` только на время transient pulse. Runtime
  успешно поднялся на физическом iPhone (`MARGARITAVILLE_EDR_METAL_RUNTIME_READY`),
  но per-cell platform-view topology всё ещё не могла вернуть 120-Hz scroll.
- Build 31 группирует четыре комнаты в один виртуализированный native row view.
  Flutter держит непрозрачный безопасный fallback до подтверждения первого
  завершённого Metal-кадра всех ячеек строки, затем атомарно снимает его: поэтому
  нет ни чёрной дыры до готовности GPU, ни цветного прямоугольника под рваными
  краями после готовности. Foreground/gestures остаются Flutter и получают тот
  же scroll transform, а Metal-ячейки внутри строки используют общий runtime.
- Контрактный тест полного каталога закрепляет, что `184` rooms не создают `46`
  platform views сразу: существуют только строки в sliver viewport. Physical
  all-184-VIP probe build 31 с EDR+jelly при `120 Hz` дал `119.99 FPS`, p95
  build/raster `1.72/2.69 ms`, p99 `1.84/3.88 ms`, max `2.27/5.26 ms`,
  `0` over-budget frames и `0` больших vsync gaps. После probe обычный profile
  build 31 прошёл guard семи embedded iOS frameworks, установлен и запущен на
  iPhone 17 Pro Max. Открыт только финальный пользовательский perceptual gate:
  отсутствие подложки и идентичность EDR/jelly донору на физическом дисплее.
- Пользовательский physical gate build 31 немедленно опроверг synthetic
  Flutter FrameTiming: при реальном fling native row backgrounds отрывались от
  Flutter foreground, обрезались верхней границей и оставляли чёрные номера без
  фона. В 15.58-секундной HEVC-записи видно несколько кадров, где цветные дуги
  от rows находятся над заголовком следующей секции. Значит, `119.99 FPS`
  измеряли только Flutter pipeline и не доказывали корректность UIKit hybrid
  composition.
- Upstream-аудит подтвердил этот класс дефектов: Flutter iOS использует только
  Hybrid Composition, `SliverList` уничтожает offscreen state, а открытые
  flutter/flutter `#176473`, `#119485` и `#142801` воспроизводят неправильную
  позицию и вспышки `UiKitView` у верхней границы scroll/sliver. Поэтому
  per-cell/per-row PlatformView признан архитектурным тупиком, а не кандидатом
  на очередной offset/keep-alive patch.
- Build 32 полностью удаляет production topology `UiKitView` на ячейку/строку,
  оба Dart surface, standalone Swift factory и лишние Pigeon host methods. Один
  стабильный content-sized EDR PlatformView живёт внутри единственного child
  обычного `ListView`; Flutter content и native surface получают один compositor
  transform, что уже было физически подтверждено build 23, но теперь fill
  рисуется Metal вместо CoreGraphics.
- Flutter fallback каждой комнаты остаётся непрозрачным до callback первого
  завершённого Metal command buffer всех активных ячеек текущей revision.
  Только затем tile-local notifier делает Flutter background прозрачным.
  Stale GPU acknowledgement не может получить ownership новой generation.
  Старый CoreGraphics fallback и новый Metal runtime используют ровно один
  общий transient `EdrPulseFrameClock`; архитектурный guard закрепляет единственный
  native `CADisplayLink` вместо конкурирующих clocks.
- Software gate build 32 зелёный: codegen, format, analyze, `90 tests`, file-size
  и architecture guards. Physical profile artifact прошёл deep codesign и guard
  семи embedded iOS frameworks, установлен и запущен на iPhone 17 Pro Max.
  Финальный fast-scroll/rebound perceptual gate build 32 остаётся открытым.

## 2026-07-10 — Checkpoint 6: оконный VisualRuntime вместо PlatformView

- Physical build 32 опроверг гипотезу, что один большой content-sized
  PlatformView достаточно стабилен: all-184 probe дал лишь `13.56 FPS`, p95
  build/raster `10.51/6.14 ms`, p99 `21.86/7.18 ms`. Build 33 разбил его на
  section-sized views, но cold launch не завершил warm-up даже за 45 секунд.
  После per-cell, per-row, content-sized и per-section вариантов весь
  `UiKitView/FlutterPlatformView` путь признан запрещённым для EDR Summary.
- Upstream-сверка дала прямое архитектурное объяснение: iOS Platform Views
  работают через Hybrid Composition, а открытые Flutter issues `#176473`,
  `#119485`, `#142801` и performance issue `#107486` описывают те же scroll,
  top-edge, mask и moving-view дефекты. Новая защита CI падает при возвращении
  PlatformView в EDR adapter.
- Общий `shared-parameterized` runtime выделен в соседний Swift Package
  `SharedAppFoundation/VisualRuntime`. В нём нет Flutter, Pigeon, bundle ID или
  гостиничного домена: только `VisualTileDescriptor`, labels, jelly, pulse,
  LOD, readiness и оконный renderer. Runner остаётся тонким typed Pigeon
  adapter и закрепляет публичный package точной remote revision
  `ceba87f54ce550a24def006b1a1638c5d23ed90a`, поэтому отдельный clone/CI не
  зависит от соседней папки на Mac.
- Runtime устанавливает один прозрачный неинтерактивный sibling в `UIWindow`,
  за пределами Flutter PlatformView compositor. Он получает одним snapshot
  только видимые VIP/pulse bounds, ограничивается точной маской Summary
  viewport и подтверждает ownership лишь после первого завершённого GPU-кадра.
  До acknowledgement Flutter продолжает рисовать полный безопасный fallback;
  stale revision не может скрыть новое поколение комнаты.
- Primary path использует `CAMetalLayer` с `rgba16Float`, extended-linear
  Display P3, high dynamic range/headroom и одним process-wide max-vsync
  `CADisplayLink`. Если Metal/drawable недоступен, включается не SDR-заглушка,
  а CoreGraphics EDR leaf с `RGBA16Float`, `setEDRTargetHeadroom`, тем же radial
  lift и двухслойным donor pulse. Оба leaf находятся под одной jelly-mask;
  прямоугольной цветной подложки под волнистыми краями нет.
- Native слой теперь рисует и фон, и donor labels (`SF Rounded Black`, room
  `44 pt`, time `16 pt`, tabular digits, insets `4/10`, gap `6`), поэтому один
  оконный sibling не разделяет cell foreground/background между двумя
  compositor clocks. Flutter сохраняет gestures, semantics и domain state.
- Build 34 проходит generic physical-iOS Swift 6 build общего package, точный
  Metal shader compile, Pigeon codegen, Dart analyze и targeted widget/controller
  tests. Подписанная обычная build 34 установлена и запущена на физическом
  iPhone 17 Pro Max.
- Новый all-184-VIP physical profile с Matrix + EDR + jelly дал при `120 Hz`:
  p95 build/raster `2.06/2.28 ms`, p99 `4.21/3.14 ms`, max `4.65/6.92 ms` и
  `0` кадров тяжелее бюджета `8.33 ms`. Callback cadence составила `85.34 Hz`
  при `204` больших vsync gaps; поэтому frame-time gate зелёный, но cadence и
  финальный fast-scroll perceptual gate пока открыты. `flutter drive` через
  mDNS отдельно заблокирован локальным сетевым разрешением macOS; standalone
  probe и `devicectl` продолжают работать без этого разрешения.
- Системный iPhone Mirroring дал независимый end-to-end gate обычной profile
  build 34: сохранённые `42` комнаты/`2` назначения открылись из Drift, все
  видимые VIP backgrounds и native labels появились без чёрных дыр. При
  открытии action sheet runtime атомарно очистился, Flutter fallback корректно
  оказался под модалью; после закрытия новая revision вернула EDR/jelly без
  stale ownership. Общая route/TickerMode visibility закреплена controller
  test и применяется ко всем modal/push, а не только к меню комнаты.
- После первого cadence probe найден остаточный native main-thread расход:
  точный jelly `CGPath` пересчитывался каждой видимой VIP на каждом display
  tick. В общем package добавлены ограниченная двухпоточная подготовка,
  generation-safe cache `256/32 MiB` и `CAKeyframeAnimation` для path, scale и
  offset. Первый точный волнистый path ставится синхронно, затем Core Animation
  интерполирует build-37 keyframes; process-wide `CADisplayLink` теперь активен
  только до first-frame readiness и во время transient pulse, а не постоянно
  ради jelly.
- Pure Swift package получил постоянный XCTest target с golden-векторами pulse,
  jelly transform, sample counts `12/20/66` и ARGB contract. Generic physical
  iOS `build-for-testing` проходит в Swift 6 без предупреждений нового runtime.
  Повторный all-184 cadence probe подготовлен, но запуск был отклонён внешним
  состоянием `Locked`; тестовый harness сразу заменён на обычную подписанную
  profile build 34, которая установлена на iPhone и не требует Flutter tooling.

## 2026-07-10 — Checkpoint 7: geometry-only reuse и физический A/B

- Первый повтор CA-keyframe build 34 был намеренно признан недействительным:
  скопированный probe имел timestamp предыдущего запуска. Явный `devicectl`
  launch подтвердил внешний `Locked`, поэтому старые байты не были выданы за
  новый результат.
- После разблокировки свежий исходный повтор подтвердил регрессию: Flutter
  build/raster оставались быстрыми (`p99 2.66/3.59 ms`, max `3.30/5.38 ms`,
  `0` over-budget), но cadence составляла только `36.08 FPS` при `846` gaps.
  Причина находилась вне измеряемых build/raster фаз.
- SharedAppFoundation revision
  `af78f15f3424c5b1f13284cd47d3eca84f83fcb7` разделяет geometry и visual
  content внутри tile. Scroll-origin больше не запрашивает новый Metal drawable,
  не перезапускает jelly и не сбрасывает readiness уже готового содержимого.
  Нативный ownership также полностью освобождает невидимый Flutter visual-clock;
  Swift уже рисует и фон, и labels, поэтому прозрачный второй animator не нужен.
- Тем же контрактным блоком native label приведён к donor ink `#050505`, static
  native tile возвращён к radius `16 pt`, а transform keyframes сокращены
  `240 -> 32` с доказанной максимальной ошибкой линейной интерполяции `<0.006 pt`.
  Animated jelly radius `min(16, h*0.46, w*0.12)` сохранён без изменения.
- Свежий physical all-184 VIP build 35 с Matrix + EDR + jelly при `120 Hz` дал:
  `115.16 FPS`, p95 build/raster `1.95/2.95 ms`, p99 `2.23/3.44 ms`,
  max `2.72/7.36 ms`, `0` over-budget и `112` gaps. Это устраняет падение до
  `36.08 FPS` и возвращает pipeline вблизи максимального дисплейного cadence.
- Контрольный A/B той же build 35 с EDR, но без jelly дал `117.13 FPS`,
  p99 `2.49/3.84 ms`, max `2.84/6.47 ms`, `0` over-budget и `52` gaps.
  Следовательно, полная jelly-нагрузка стоит `1.97 FPS` и проходит выбранный
  delta-gate `<=3 Hz`; оставшиеся микропровалы в основном принадлежат полному
  geometry/Pigeon snapshot на каждом scroll-кадре, а не формулам кляксы.
- Следующий фундаментальный срез: content-coordinate snapshot только при
  membership/content change и отдельный geometry call с одним `scrollOffset`.
  Swift должен двигать общий tile-container одним transform без измерения и
  сериализации всех видимых tile descriptors на каждом vsync.

## 2026-07-10 — Checkpoint 8: независимые content/layout/geometry streams

- Build 36 разделяет пять идентификаторов: `surfaceSessionId` конкретного
  Summary, монотонный `activationId` каждого появления route,
  `layoutGeneration` стабильных content bounds, `contentRevision`
  цветов/labels/effects/membership и `geometryRevision` viewport/scroll.
  Повторно открытый Summary получает новую lease; поздняя команда скрытого
  экрана больше не может перехватить process-wide overlay.
- Tile bounds измеряются через `localToGlobal` только при перестройке layout
  cache. ScrollController listener немедленно отправляет дробный offset,
  включая отрицательный bounce, до следующего Flutter paint; post-frame проход
  только проверяет membership. При стабильном наборе Pigeon не создаёт
  measured/snapshot/map для каждой из 184 комнат и отправляет лишь geometry.
- SharedAppFoundation revision
  `375e63aed9a8c14d09e692b936d278c83afeca37` держит tiles в content
  coordinates и двигает один `tileContainer` одним Core Animation transform.
  Geometry update не вызывает `tile.apply`, Metal encode, jelly restart или
  first-frame ownership. Readiness теперь атомарно запрещён внутри reconciliation
  и требует точного полного ID-набора: уже готовая старая tile больше не может
  скрыть Flutter fallback до создания и первого Metal-кадра новой VIP tile.
- Детерминированные tests закрепляют stable membership, immediate geometry,
  negative bounce, немедленный возврат Flutter fallback для вышедшей native
  tile, ожидание readiness для новой tile, recycled render key и раздельные
  callbacks двух sessions. Architecture guard запрещает снова смешивать full
  content snapshot со scroll geometry и разрешает tile-level `localToGlobal`
  только внутри rebuild cache.
- Android получил production UI-toolkit HDR runtime: один window overlay,
  один Vsync clock, lifecycle/offscreen pause, power/thermal degradation,
  typed Pigeon adapter, activation lease, first-draw readiness и native Nunito
  labels. На физическом Pixel 8 `shiba`, Android 17/API 37 подтверждены
  HDR10/HLG/HDR10+, WCG, thermal `0`, Battery Saver off и `120.00001 Hz`.
  При неизменной auto-brightness запросы `2x` и `4x` дали соответственно
  `1.9999417` и `3.99981`, а automatic window headroom с signal `5x/8x` получил
  `4.999748`. Production использует automatic window request и signal `5x`:
  это локальный настоящий Gainmap HDR, а не изменение яркости всего окна.
- Физический Android scroll выявил, что `ScrollMetricsNotification` зря
  инвалидировал layout cache на каждом pixels change: при неизменном exact
  room-ID наборе уходили десятки full configure/readiness. После фикса повтор
  `0 -> 199.24` дал только geometry revisions `3...87`, `0` configure и `0`
  readiness на стабильном membership; пустых контрольных кадров нет.
- Свежий physical all-184 build 36 с Matrix + EDR + jelly на iPhone 17 Pro Max
  при `120 Hz` дал `116.39 FPS`, p95 build/raster `2.40/3.34 ms`, p99
  `3.36/4.16 ms`, max `4.44/6.17 ms`, `0` over-budget и `67` gaps. Против
  build 35 это `+1.23 FPS` и `-45` gaps; timestamp probe проверен как свежий.
  После замера stress harness заменён обычной подписанной profile build 36,
  которая установлена и запущена на физическом iPhone.

## 2026-07-10 — Checkpoint 9: закреплённый cross-platform HDR ABI

- Рабочий контур вынесен в обязательный
  `Docs/NATIVE_VISUAL_RUNTIME_CONTRACT.md` и короткие неприкосновенные правила
  `AGENTS.md`. Зафиксированы platform split, lease/revision ordering,
  двухфазный ownership, frame-commit readiness, один OS-vsync clock, запрет
  whole-window brightness и обязательные physical gates. Та же выжимка записана
  в глобальную Codex memory для новых сессий.
- Обратный Pigeon callback теперь несёт полную тройку
  `(surfaceSessionId, activationId, contentRevision)`. Stale readiness старой
  activation той же Summary surface не удаляет pending актуальной activation и
  не может скрыть Flutter fallback. Тест сначала воспроизвёл именно такую потерю
  pending ownership, затем прошёл после исправления.
- iOS adapter получил monotonic layout/content rejection и защищённый stale
  clear; Android readiness перенесён с простого `onDraw + post` на hardware
  `registerFrameCommitCallback`. Generated Dart/Swift/Kotlin Pigeon outputs
  теперь проверяются воспроизводимым guard-скриптом.
- Android VIP jelly и status-change pulse перенесены на точные donor formulas:
  stable FNV seed, segment/radius/transform contract, rise `0.42 s`, peak
  `0.58 s`, cooling `2.0 s`, rubber multiplier `1.7` и один общий Vsync clock.
  Нативный label renderer выделен отдельно; каждый Kotlin runtime file снова
  меньше 300 строк.
- Видео `IMG_0573.MOV` покадрово выявило отдельный Android defect: fullscreen
  HDR View cull'ил по viewport intersection, но не clip'ил Canvas, поэтому
  частично видимая VIP-ячейка целиком вылетала поверх header. Добавлен точный
  `canvas.clipRect(scene.viewportPx)` без коэффициентов. Повторная физическая
  4.96-секундная запись Pixel 8 шла `118.96 FPS`; во всех 10 контрольных кадрах
  native paint остаётся ниже границы header.
- Pixel 8 подключён штатной Android Wireless Debugging парой `alex@Mac`;
  контрольный APK успешно установлен через network serial
  `192.168.2.29:35089`, а не USB. Pairing сохраняется, хотя порт может меняться
  после reboot/Wi-Fi toggle.
- Android interaction feedback переведён на поддерживаемые Pixel 8 composition
  primitives с scale `1.0`; commit/long-press теперь использует заметную связку
  `CLICK + THUD`, start — `CLICK + QUICK_RISE`, warning —
  `QUICK_FALL + CLICK`. System settings уже стоят High; это максимум API,
  дальнейшее усиление может сделать только пользовательская настройка ОС/железо.
  Финальная связка установлена, но perceptual ручной gate Alex после жалобы о
  пропавшей отдаче остаётся обязательным перед объявлением parity.
- В Settings добавлен явный раздел `Тестирование` с подтверждаемой командой
  `Задействовать все номера отеля для теста`. Все 184 номера перемешиваются и
  распределяются ровно один раз между активными уборщицами через один
  application command и одну repository transaction; UI напрямую БД не меняет,
  cancel оставляет смену нетронутой.

## 2026-07-11 — Checkpoint 10: отзывчивые haptics и сетка 4/3 без EDR-расслоения

- Усиленная Android-композиция `CLICK + THUD/QUICK_RISE` из build 36 полностью
  отозвана отдельным коммитом `831eee2`: она запускала прямой максимальный
  `VibrationEffect` на критическом пути удержания и по физическому отзыву Pixel 8
  сдвигала status pulse/HDR относительно пальца. Возвращён прежний системный
  `performHapticFeedback` с лёгким fallback; визуальный runtime не менялся.
- В экспериментальных настройках добавлен typed-переключатель `4/3` ячейки в
  ряд. Четыре колонки сохраняют donor-контракт `96×98 pt` при section width
  `424 pt`; три колонки получают `130.67×98 pt`: ширина увеличивается, высота
  остаётся точной, поэтому ячейка становится прямоугольной, а не большим
  квадратом. Настройка общая для iOS и Android и сохраняется типизированно.
- Flutter paint, hitbox, жесты, VIP jelly, pulse и native HDR/EDR не повторяют
  формулу отдельно: один реальный `RenderBox` измеряется EDR geometry cache и
  передаётся iOS/Android runtime. Статический тест подтверждает совпадение
  Flutter surface и EDR snapshot `130.666…×98 pt`.
- Живое переключение `4→3→4` явно инвалидирует geometry после нового layout,
  даже если `maxScrollExtent` остаётся нулевым. Новый `layoutGeneration`
  немедленно возвращает Flutter fallback; старый `windowReady` игнорируется,
  native ownership возвращается только после frame acknowledgement точной новой
  revision. Это исключает старый размер, пустой кадр и отложенную VIP-ячейку.
- Android APK установлен по Wi-Fi на физический Pixel 8; accessibility bounds
  подтвердили три колонки одинаковой высоты. Подписанная iOS profile build
  прошла bundle guard (7 IOS frameworks), установлена и запущена на физическом
  iPhone 17 Pro Max. После сборок удалены только локальные `build/.dart_tool`,
  свободное место восстановлено примерно с `9` до `13 GiB`.

## 2026-07-11 — Checkpoint 11: точная платформенная форма сетки

- Физические Android-фото опровергли старый универсальный `height=98`: при
  четырёх колонках ячейки получались высокими прямоугольниками, а при трёх —
  почти квадратами. Контракт заменён точной формулой, а не визуальной поправкой:
  `w4=(W-2×8-3×8)/4`, `wC=(W-2×8-(C-1)×8)/C`.
- Android всегда использует `height=w4`. Поэтому при section width `329.6`
  четыре колонки дают настоящие `72.4×72.4`, а три — горизонтальные
  `99.2×72.4`. После физического iOS-сравнения стандартный режим возвращён к
  исходному donor-виду `96×98`; только режим трёх колонок использует
  `130.666…×73.5`.
- Единый `SummaryTileGeometryResolver` возвращает `Size`, scale вертикальных
  метрик и отдельную политику текста. На Android шрифт и отступы масштабируются
  вместе с компактной квадратной высотой. На iOS шрифт сохраняет исходные
  `44/16 pt`: в трёх колонках уменьшаются только padding/gap, а при нехватке
  места glyphs сжимаются только по вертикали без потери исходной ширины.
- SharedAppFoundation revision
  `da9d5edc9b0dc8ba331a2accd4b6dd69e1c9732a` добавляет общий height-aware
  UILabel layout: unscaled bounds сохраняют прежний размер шрифта и width-fit,
  а `scaleY` применяется вокруг центра выделенного slot. Flutter fallback
  повторяет тот же контракт; переход к нативному HDR не меняет ширину цифр.
- HDR/EDR snapshot, jelly и gesture target продолжают брать фактический
  `RenderBox`; Pigeon ABI и shape-формулы не дублируют layout. Изменение размера
  самого EDR surface теперь явно инвалидирует geometry даже при одной комнате и
  `maxScrollExtent=0`, поэтому width-only resize создаёт новый
  `layoutGeneration` и ждёт точного native frame acknowledgement.
- Тесты закрепляют четыре контрольных размера, полный paint bounds, широкий
  hit target, jelly contour на всех формах, `4→3→4`, width-only resize и
  Android logical-to-physical bounds. Финальный physical Pixel/iPhone gate
  выполняется отдельной свежей сборкой после software gate.

## 2026-07-11 — Checkpoint 12: Room Details route и schema v4 foundation

- Заглушка Snackbar для действия `Голос/медиа` удалена. Room action теперь
  открывает настоящий feature-first `RoomDetailsScreen` с правильными
  `sessionId/roomNumber` и возвратом в Summary. Неактивный donor text-mode
  намеренно не выставлен в UI.
- Flutter shell повторяет измеряемый build-37 контракт: внешний inset `18 pt`,
  back target `48×48`, room number `44 pt`, title `34 pt`, card radius/padding
  `18 pt`, photo/video actions `86 pt` и двухколоночный media grid. Метрики
  закреплены widget-тестом без визуальных коэффициентов «на глаз».
- Drift обновлён до schema v4 безопасной миграцией уже устанавливавшейся v3:
  отдельные command receipts получают атомарный claim и финальный
  `applied/ignored`; конкурентный дубль возвращает `duplicate` без второй
  мутации. v2 history backfill-ится в receipts при прямом обновлении v2→v4.
- Notes и media используют детерминированный LWW `(issuedAt, commandId)`.
  Старые update/delete не перетирают новую проекцию; immutable media identity
  запрещает перенос одного ID между владельцем, типом, local path и origin.
- Sync event payload стал allow-list envelope: private note, transcript и
  device-local `relativePath` остаются только локально и не достижимы через
  outbox. Session graph replacement сохраняет history/outbox/media/notes и
  receipts вместо каскадного удаления общей проекции.
- AppDatabase, generated schema, migration helpers и все общие projection
  tables физически вынесены из Work Session feature в shared persistence;
  architecture guard запрещает обратную зависимость `shared → feature`.
  Room Details получил собственные repository/controller/provider.
- Полный quality gate зелёный: воспроизводимые schema snapshots/migration
  helpers, format, analyze, `134` Flutter test, Android JVM, file-size и
  architecture guards. Подписанная iOS profile build `0.1.0 (37)` прошла guard
  семи IOS frameworks и установлена на физический iPhone 17 Pro Max;
  автоматический launch ожидает разблокировки телефона.

## 2026-07-11 — Checkpoint 13: локальная голосовая заметка и единый audio runtime

- Заглушка «Новая голосовая заметка» заменена настоящей вертикалью Room
  Details: typed Pigeon request получает versioned `operationId/mediaId`, а
  обратные события имеют монотонный sequence, typed phase/status и terminal
  result. Generated Dart/Swift/Kotlin воспроизводимы; Android пока честно
  сообщает typed `unsupported`, не запрашивая неиспользуемое разрешение.
- iOS записывает локальный MPEG-4 AAC через `AVAudioRecorder` с donor-контрактом
  `44,1 kHz`, mono и high quality. После stop используется только файловый
  `SFSpeechURLRecognitionRequest` с `ru-RU`; live `AVAudioEngine/installTap`
  запрещён guard-скриптом. Отказ Speech не блокирует само аудио: заметка
  сохраняется без transcript и показывает «Распознавание недоступно».
- Все `AVAudioSession.setCategory/setActive` вынесены в один
  `NativeAudioSessionCoordinator`, обслуживающий и SFX, и запись. Background,
  phone interruption и media-services reset маршрутизируются в voice runtime;
  interruption во время файловой transcription отменяет Speech и выдаёт один
  terminal interrupted-result вместо зависшей operation.
- Native temp не считается данными приложения. Flutter копирует его атомарно в
  Application Support `Media/<mediaId>.m4a`, сверяет длину, считает настоящий
  SHA-256, затем выполняет `AddRoomMediaCommand` в Drift и только после durable
  commit вызывает `releaseResult`. Crash-retry переиспользует идентичный файл;
  конфликт checksum запрещён; duplicate подтверждается чтением projection.
  Ошибка temp cleanup никогда не удаляет уже закоммиченный media-файл.
- Room Details показывает русские состояния permission/start/record/finish,
  stop affordance и сохранённые transcript bubbles. Screen-scoped Riverpod
  family использует auto-dispose; dispose/cancel дожидается незавершённого
  durable copy, затем корректно освобождает native ownership.
- Независимый architecture challenger дал GO после закрытия Speech-denied,
  finishing-interruption, duplicate/ignored/reuse и dispose/finalize races.
  Полный software gate включает Pigeon/Drift reproducibility, voice native
  contract, format/analyze, Flutter tests, Android JVM, file-size и architecture
  guards. Подписанная profile build `0.1.0 (37)` прошла deep codesign и guard
  семи IOS frameworks и установлена на физический iPhone 17 Pro Max. Runtime
  smoke (реальная фраза, denied Speech, звонок/background) остаётся открытым:
  автоматический запуск отклонён iOS только из-за заблокированного телефона.

## 2026-07-11 — Checkpoint 14: crash-safe фото и presentation fence для HDR-overlay

- Room Details получил настоящую photo-вертикаль на общем camera lifecycle:
  официальный CameraX/AVFoundation adapter работает с `ResolutionPreset.max`,
  без аудио, сериализует open/close/resume и не допускает повторного открытия до
  завершения dispose предыдущей сессии. Ориентация и `BoxFit.cover` считаются
  из реального raw aspect ratio; portrait `4:3` корректно становится `3:4` без
  подгоночных коэффициентов.
- Media storage теперь crash-safe by construction. До первого app-owned байта
  создаётся durable journal; копирование идёт в недоверенный `*.copying`, после
  flush и проверки SHA-256/length атомарно становится immutable `*.partial`, а
  затем final-файлом. Повтор идентичных байтов идемпотентен, конфликт checksum
  не перезаписывает verified artifact, tombstone коммитится до удаления файла.
- Drift schema v5 хранит byte length, dimensions, extension, orientation,
  color-space/HDR metadata и durable promotion records. Startup recovery
  изолирует каждый journal: retriable ошибка временно блокирует shell и даёт
  русскую кнопку повтора; terminal missing/conflict переводится в quarantine,
  не блокирует последующие записи и остаётся доступным для диагностики.
  Garbage collection выполняется даже после частичной ошибки восстановления.
- Скринкаст `ScreenRecording_07-11-2026 06-14-17_1.MP4` доказал отдельную
  системную причину артефакта: один native window overlay оставался физически
  выше Flutter route/modal barrier, а переходная `localToGlobal`-геометрия
  принималась за стабильную. ABI расширен `presentationRevision`; typed
  `suspendWindow` является stale-safe no-op по полной lease, а native paint
  прозрачен до frame commit точных content/presentation revisions.
- `EdrWindowSurface` наблюдает primary и secondary route animation, lifecycle и
  TickerMode, а после возврата требует два одинаковых consecutive geometry
  frames. Контролируемые settings, Room Details и bottom sheets сначала ставят
  presentation fence. Он учитывает и committed ownership, и configure между
  accept/frame-commit; fallback возвращается немедленно, а аварийный дедлайн
  `250 ms` не даёт умершему host навсегда заблокировать навигацию. Поздний ready
  скрытого presentation игнорируется.
- Все native-команды проходят через одну сериализованную lane. Geometry имеет
  только один latest-only pending slot: 100 быстрых scroll updates сохраняют не
  более одного вызова in-flight и отправляют конечный offset. Future/unknown
  geometry на iOS и Android отбрасывается, прежний `pendingGeometry` удалён.
- Полный gate зелёный: Pigeon/Drift/media/voice reproducibility guards,
  format/analyze, `199` Flutter tests, Android JVM, file-size и architecture
  guards. Android 17/API 37 emulator прошёл install/launch, settings, VIP action
  sheet, Room Details, permission, camera preview, capture и отображение
  локальной миниатюры. Profile iOS build прошла deep codesign и bundle guard
  восьми IOS frameworks, установлена и запущена на физическом iPhone 17 Pro
  Max; открытие Drift подтверждено существующим контейнерным
  `Documents/margaritaville-canonical-v2.sqlite` (`136 KB`). Диагностический
  rebuild после software gate повторно прошёл тот же guard и установлен; его
  автоматический запуск ожидает разблокировки iPhone. Финальный perceptual
  HDR/120 Hz и фото/voice smoke на физическом экране остаётся
  обязательным device gate и не подменяется screenshot/emulator.
- Первый повторный devicectl-install оставил одновременно живыми старый и новый
  процессы `Runner`; старый bundle удерживал SQLite, а новый оставался на
  «Проверяю локальные медиа...». После принудительного завершения обоих остался
  ровно один процесс из свежего bundle. Добавлен единый
  `tool/install_ios_profile.sh`: он проходит bundle guard, завершает процесс
  установленного bundle до обновления, устанавливает app и запускает с
  `--terminate-existing`. Architecture guard не позволяет убрать этот порядок;
  startup recovery пишет фактическую длительность и результат в device log.
  CoreDevice не связывает orphan-процесс со свежим bundle ID, поэтому скрипт
  явно завершает все старые `/Runner.app/Runner` на выделенном test device и
  после запуска требует ровно один такой процесс.
- После устранения двойного процесса physical database audit нашёл настоящий
  второй дефект: ранее установленная промежуточная v5-таблица journal не имела
  `transient_file_path/quarantined_at/failure_reason`, хотя `user_version` уже
  был равен `5`. Schema v6 ремонтирует только этот неполный вариант через
  canonical table migration, сохраняет journal row и verified final photo;
  полноценная v5 проходит как no-op. Тест воспроизводит снятую с iPhone форму
  таблицы и запрещает возвращение этой регрессии.
  Дополнительный recovery-test удаляет transient, подставляет точный v6 sentinel
  и доказывает публикацию уже verified final photo без quarantine. Profile v6
  прошла guard восьми IOS frameworks и установлена с сохранением data container;
  физический запуск ожидает только разблокировки iPhone.

## 2026-07-11 — Физический startup incident и начало Checkpoint 15

- На разблокированном iPhone 17 Pro Max старая сохранённая v6-копия снова
  оставалась на «Проверяю локальные медиа...». Снятый по Wi-Fi контейнер доказал:
  SQLite `integrity_check=ok`, `user_version=6`, один pending promotion, final
  JPEG существует, его размер `1 792 104` байта и SHA-256 точно совпадает с
  durable journal. Потери или повреждения байтов не было; зависал сам startup
  recovery/доступ к контейнеру. Диагностический снимок сохранён во временном
  `/tmp/margaritaville-device-live` и не является частью репозитория.
- Alex явно разрешил не сохранять данные этой тестовой iPhone-копии. Старое
  приложение вместе с data container удалено, свежая profile-сборка прошла
  deep codesign и bundle guard восьми IOS frameworks, установлена и запущена.
  Повторный physical audit: ровно один Runner, `integrity_check=ok`, schema v7,
  одна начальная смена, `pending_media=0`. Startup gate больше не висит.
- Чтобы аналогичный I/O/SQLite stall больше не оставлял бесконечный loading,
  startup recovery получил явные bounded deadlines: 8 секунд на promotion и
  4 секунды на garbage collection. Timeout переводит gate в существующее
  русское error/retry-состояние и не удаляет данные автоматически.
- Checkpoint 15 начат через общий фундамент Cart Details: runtime-валидируемый
  `ContentOwnerRef`, Drift v7 с assignment notes, шестью donor-расходниками и
  микросекундным LWW, XOR-owner constraints для manifest/promotion и общий
  transactional content ledger с command fingerprint. Независимый challenger
  запретил преждевременно переводить все work-session commands: destructive
  graph writer сначала должен быть заменён на diff/upsert, иначе assignment FK
  или каскады сотрут Cart Details при обычной мутации смены.

## 2026-07-11 — Work Setup build 37: каталог, тележки и физический v9

- После прямого повторного аудита Swift build 37 исправлена прежняя ложная
  модель «две заранее созданные уборщицы». Свежая смена теперь имеет ноль
  тележек, но показывает отдельный полный каталог из 20 уборщиц. Тап по имени
  создаёт первый свободный cart `1...100`, повторный тап удаляет work item и его
  комнаты. Предпочтительные зоны перенесены точно: `1→A1`, `2→B1`, `3→A2`,
  `4→B2`, `5→A3`, `6→B3`; зона хранится отдельно у каждой тележки, а её смена
  не удаляет комнаты прежней зоны.
- Drift v9 получил независимый `housekeeper_catalog_records`: точный порядок и
  внутренние ID всех 20 записей донора, soft delete и persistence
  переименования. Повторный default seed не перезаписывает пользовательское имя
  и не воскрешает удалённую запись. Hydration действующей смены разрешает имя и
  палитру через актуальный каталог, поэтому переименование отражается на уже
  назначенной тележке после reload.
- Выбор комнаты теперь является одной `ToggleRoomSelectionCommand`, решение
  add/remove принимается внутри общей serialized command lane. Тест двух быстрых
  тапов доказывает две последовательные инверсии без lost update. Номер другой
  тележки disabled в UI и дополнительно защищён доменным conflict guard.
- Тест «все номера» использует полный persistent-каталог даже при пустой смене,
  распределяет весь номерной фонд round-robin и выбирает начальную зону по
  первой отсортированной комнате, как donor. Существующие status, VIP, schedule
  и timestamps сохраняются. Legacy несколько carts одного housekeeper
  объединяются в одну Summary-секцию с общими rooms/territories.
- Миграционные тесты покрывают прямые v2/v3/v4/v5/v6/v7/v8→v9, physical
  intermediate v5, v7 assignment с `NULL territory_id` и fallback `cart 1→A1`,
  а также v8→v9 seed каталога. Код разрезан на отдельные setup-actions и
  migration helpers; file-size guard снова зелёный.
- Полный software gate зелёный: format, analyze, `235` Flutter tests,
  file-size, Drift reproducibility, architecture и Pigeon guards. Подписанная
  profile-сборка прошла deep codesign и bundle guard восьми IOS frameworks,
  установлена и запущена на физическом iPhone 17 Pro Max. Снятая с устройства
  база: `integrity_check=ok`, `user_version=9`, одна смена и ровно 20 активных
  catalog rows (`sort_order 0...19`) в точном порядке build 37. На устройстве
  работает ровно один `/Runner.app/Runner`.
- Открытые ограничения зафиксированы честно: редактор каталога add/rename/
  palette/remove, donor-canonicalization, compact reorder и восстановление
  defaults после удаления последней записи ещё не перенесены в Settings;
  удаление catalog entry пока не снимает активную тележку. Setup-команды ещё не
  переведены с destructive graph replace на общий durable
  receipt/history/outbox ledger. Поэтому Work Setup logic smoke доказан, но
  полный sync-ready parity пока не объявляется.

## 2026-07-11 — Физический Pixel 8: repair промежуточной v3

- Обновление profile build `0.1.0 (37)` поверх существующей Android beta
  воспроизвело пользовательский экран «Не удалось восстановить локальные
  медиа». Снятая через `run-as` база Pixel 8 была целой
  (`integrity_check=ok`), но имела `user_version=3` без физической таблицы
  `command_receipt_records`. Первая попытка v3→v9 доходила до добавления v7
  columns в несуществующую таблицу, транзакция откатывалась, а recovery
  показывал исходную SQLite-ошибку.
- `_addReceiptV7ColumnsIfMissing` теперь распознаёт эту точную pre-release форму:
  создаёт текущую receipt projection и неразрушающе восстанавливает уже
  применённые `(session_id, command_id)` из append-only history перед
  продолжением миграции. Отдельный migration test удаляет receipts из
  canonical v3, сохраняет session/history и доказывает backfill плюс успешный
  v3→v9 без потери смены.
- Исправленный profile APK установлен поверх той же проблемной базы на
  физический Pixel 8 `44171FDJH003R5`. Device log: startup recovery завершён за
  `304 ms`, `recovered=0`, `quarantined=0`, SQLite/FATAL ошибок нет. Повторно
  снятая база: `integrity_check=ok`, `user_version=9`, receipt table существует,
  20 активных catalog rows и одна сохранённая смена. Физический screenshot
  подтверждает главную матрицу вместо error/retry gate; видимы `Ana` и
  `Kerlange`.
