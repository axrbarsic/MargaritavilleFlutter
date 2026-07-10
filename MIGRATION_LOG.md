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
