# VIP HDR runtime — Android integration contract

## Статус и граница

`shared-parameterized`: runtime не знает hotel/room domain, Flutter widgets,
storage, bundle ID или навигацию. Android app shell создаёт один host, а
app-specific Pigeon adapter передаёт ему уже рассчитанную сцену видимых
VIP-ячеек и текстовые подписи.

Production-код находится в
`android/app/src/main/kotlin/com/alex/margaritaville/flutter/beta/hdr/runtime`.
Debug activity использует этот же runtime, а не отдельную тестовую реализацию.
Android Pigeon adapter находится в соседнем package `edr` и регистрируется из
`MainActivity` после создания Flutter content root и до первого `onResume`.

## Архитектура

```text
Dart/Pigeon adapter
          │ one typed scene per geometry/state revision
          ▼
VipHdrOverlayHost ── lifecycle + Display HDR/headroom monitor
          │
          ▼
VipHdrRuntime ────── one state machine, offscreen culling, LOD pause
          │                         ▲
          │                         │ one injected process clock
          ▼                         │
VipHdrOverlaySurface ◄── AndroidVsyncFrameClock / Choreographer
   one transparent View
   one window surface
   all visible VIP cells
```

- Никаких `Ticker`, `Animator`, `Timer` или `Choreographer.FrameCallback` на
  ячейку.
- `AndroidVsyncFrameClock` должен создаваться один раз в app composition root и
  инжектиться в единственный `VipHdrOverlayHost`.
- `VipHdrRuntime` технически запрещает подключить второй render surface.
- Статическая сцена рисуется один раз и не держит frame callback.
- Анимированная сцена подписывается на общий clock только при одновременно
  выполненных условиях: Activity resumed, surface attached/visible, feature
  visible, HDR поддержан, есть видимая пульсирующая ячейка.
- Pause, route/offscreen state, пустой viewport, уничтожение Activity снимают
  подписку и очищают overlay.
- Battery Saver или thermal status `SEVERE+` сохраняют статический HDR-кадр, но
  запрещают непрерывную анимацию.

## Типизированная внутренняя API

`VipHdrOverlayApi`:

```kotlin
val snapshot: VipHdrRuntimeSnapshot
fun submit(scene: VipHdrScene?)
fun setFeatureVisible(visible: Boolean)
fun close()
```

`VipHdrScene` содержит:

- монотонный `revision` геометрии/состояния;
- `viewportPx`;
- уникальные `VipHdrCellVisual.id`;
- форму `RoundedRect` или произвольный `Polygon`;
- базовый ARGB, opacity, desired headroom;
- необязательный pulse contract. Пульс вычисляется от единого frame timestamp.

Все координаты — **физические Android pixels относительно
`android.R.id.content`**, не screen coordinates и не Flutter logical pixels.
Pigeon принимает Flutter logical coordinates; Android adapter умножает их на
актуальную density и вычитает экранный origin `android.R.id.content`.

На один scroll/layout revision нужен один `submit(scene)`, а не поток команд по
ячейкам. Исчезнувшие из сцены IDs удаляются атомарно вместе с revision.

## HDR contract

- Android UI-toolkit HDR разрешается только на API 34+ и при `Display.isHdr`.
- API 35+ получает автоматический `Window.setDesiredHdrHeadroom(0f)`; конкретный
  headroom остаётся решением системы/OEM.
- Ячейки рисуются как Android `Gainmap` bitmap в одном hardware-accelerated
  прозрачном View. Максимальный сигнал ограничен host-level headroom.
- `Display.hdrSdrRatio` мониторится live и входит в runtime snapshot/diagnostics.
- Максимальная частота текущего разрешения передаётся ОС как
  `preferredRefreshRate`; это hint, а не обход Battery Saver/thermal/user policy.
- Production window request — automatic `0f`; Gainmap signal budget — `5f`.
  Выбор основан на измерении физического Pixel 8 при неизменной системной
  автояркости. Runtime никогда не пишет `window.screenBrightness` и не меняет
  системный brightness.

Отдельный `SurfaceView` сознательно не используется: window color mode и
`Window.setDesiredHdrHeadroom` на него не действуют. Независимый SurfaceControl
HDR потребовал бы отдельного FP16/HLG/PQ buffer + dataspace pipeline и не нужен
для overlay поверх Flutter-ячеек.

## Resource budget

- один прозрачный `View` на экран;
- один общий vsync callback независимо от числа ячеек;
- максимум 32 кэшированных bitmap размером 1×1 для сочетаний color/headroom;
- Path cache пересобирается только при новом scene revision;
- рисуются только shapes, пересекающие viewport;
- touch/accessibility overlay отключены, события остаются у Flutter UI.

## Pigeon-подключение

Android bridge остаётся тонким adapter без собственного clock:

1. app-scoped composition root создаёт один `AndroidVsyncFrameClock`;
2. Activity создаёт один `VipHdrOverlayHost` до первого `onResume`;
3. Pigeon DTO валидируется и преобразуется в `VipHdrScene`;
4. route visibility вызывает `setFeatureVisible`;
5. detach/engine teardown вызывает `submit(null)` и `close`;
6. runtime snapshot используется для diagnostics без polling каждый кадр.

Этот adapter теперь реализован:

- повторяет iOS activation lease: более высокий `activationId` вытесняет старый,
  одинаковый activation разрешён только той же session;
- отбрасывает stale layout/content/geometry revisions;
- geometry, пришедшая раньше configuration, сохраняется и выигрывает race по
  revision;
- geometry-only fast path переиспользует content descriptors и bitmap/font cache;
- Flutter logical global coordinates переводятся в physical pixels и из них
  вычитается фактический `android.R.id.content` origin on screen;
- `windowReady` отправляется через `EdrOverlayFlutterApi` только после первого
  hardware frame commit актуальной session/activation/content lease;
- на API ниже 34 host не создаётся и readiness не отправляется — Flutter fallback
  остаётся видимым.

Surface рисует полный native-owned tile: fill, room ID и time label. Используется
bundled `flutter_assets/assets/fonts/NunitoSans-Variable.ttf` с весом 900 и
Android width variations 117/110, размерами 44/16 logical px и теми же
minimum-scale limits 0.50/0.62, что Flutter fallback.

## Проверки

```sh
cd android
JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home \
  ./gradlew :app:testDebugUnitTest
JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home \
  ./gradlew :app:assembleDebug -Ptarget-platform=android-arm64
```

Physical gate: Pixel 8 `44171FDJH003R5`, затем запуск debug-only
`.hdr.HdrProbeActivity` и проверка tags `MargaritaVipHdr` и
`MargaritaHdrProbe`.

Проверенный production-runtime baseline 2026-07-10, build 36, Pixel 8
`shiba`, Android 17/API 37:

- `VipHdrRuntimeSnapshot.status = ACTIVE_ANIMATED`;
- `visibleCellCount = 2`, `clockSubscribed = true`;
- `hdrSdrRatio` поднялся с `1.0` до `1.9999732`;
- фактический display mode и render cadence: `120.00001 Hz`;
- Battery Saver `false`, thermal status `0`;
- debug screen визуально проверил одну SDR-плашку, одну polygon HDR-плашку и
  пульсирующий HDR-элемент, нарисованные production overlay surface.

Headroom sweep на том же Pixel без изменения brightness (`screen_brightness=17`,
auto mode, `screen_auto_brightness_adj=0.034485582`), один Gainmap signal:

| Window request | Signal | Granted `hdrSdrRatio` |
|---:|---:|---:|
| 2 | 4 | 1.9999417 |
| 4 | 4 | 3.99981 |
| automatic 0 | 4 | 4.999748 |
| automatic 0 | 8 | 4.999748 |

Automatic `0` честно оставляет итоговый budget системе/OEM и на этом состоянии
экрана получил максимум около 5×. Это compositor ratio, а не обещание абсолютных
нит или физического пика панели: ambient/slider/thermal могут его изменить.

Main-screen integration gate на том же Pixel 8:

- production `MainActivity` зарегистрировала Pigeon adapter до `onResume`;
- первый аппаратно нарисованный кадр подтвердил
  `windowReady session=1 content=2`;
- runtime получил `hdrSdrRatio=4.9997...` и режим панели `120.00001 Hz`;
- native surface отрисовал fill, room ID и time без пустых ячеек;
- scroll вниз и обратно сохранил совпадение bounds и подписи на контрольных
  кадрах, без `AndroidRuntime`/Flutter ошибок.
- Full-screen native surface всегда обрезается точным `scene.viewportPx` до
  per-cell jelly transform. Intersect-culling сохраняет частично видимую ячейку,
  а clip не даёт её paint выйти поверх фиксированного Flutter header.

Отдельный instrumented slow-scroll gate после исправления Flutter cache
invalidation подтвердил geometry-only path на физическом устройстве: при
неизменном membership лог содержал только `geometryRevision=3...87` и
`scrollOffsetY=1.17...199.24`; новых `configureWindow` и `windowReady` не было.

## Ограничения

- Jelly использует те же donor formulas, segment counts, radius clamp и stable
  seed, что iOS build 37; status pulse использует единый timeline
  `0.42 + 0.16 + 2.0 s` и тот же rubber multiplier `1.7`.
- Pixel 8 perceptual parity всё равно проверяется физически: Android Gainmap и
  iOS EDR имеют разные compositor/color-management реализации.
- Обычный PNG screenshot не является измерителем HDR яркости: доказательство —
  `Display.hdrSdrRatio`, display mode и device logs.
- API <34 получает прозрачный no-op overlay без имитации SDR glow.
