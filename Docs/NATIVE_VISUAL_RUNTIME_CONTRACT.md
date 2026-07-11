# Контракт нативного visual runtime

## Зачем он существует

Flutter остаётся общей машиной продукта: домен, состояние смены, настройки,
layout и жесты. Реальный расширенный динамический диапазон рисуется нативно,
потому что iOS и Android предоставляют принципиально разные compositor API.

Этот документ — обязательный ABI и regression contract. Его нельзя обходить
ради локального визуального патча. Если контракт нужно изменить, сначала
меняются tests/guards и только затем обе платформенные реализации.

## Общая граница

```text
Flutter domain + layout
        |
        | Pigeon: versioned scene + geometry
        v
window-level native adapter
        |
        +-- iOS: SharedAppFoundation EDR renderer
        |
        +-- Android 34+: HDR window + Gainmap renderer
```

Flutter передаёт только:

- стабильный ID, тексты, цвет и точную геометрию ячейки;
- VIP HDR/jelly параметры;
- одноразовое pulse-событие с generation и абсолютным timestamp;
- viewport и scroll offset;
- lifecycle/ownership revisions.

Временная кривая, деформация, high-range paint и кадры живут нативно. Ни одного
platform-channel сообщения на каждый animation frame.

## Lease и revisions

Владение поверхностью задаётся тройкой:

`(surfaceSessionId, activationId, contentRevision)`.

- `surfaceSessionId` принадлежит одному Flutter controller.
- `activationId` монотонно возрастает при каждом новом показе поверхности и
  не позволяет старому экрану вытеснить новый.
- `contentRevision` относится к атомарному набору native-owned tiles.
- `layoutGeneration` меняется только при перестройке измеренной геометрии.
- `geometryRevision` — независимый монотонный поток viewport/scroll offset.

Stale configure, geometry, clear и ready не меняют состояние. Scroll при
неизменном membership отправляет только geometry; он не создаёт новые tiles,
Gainmap/Metal resources, content readiness или краткий сброс ownership.

## Двухфазное владение

1. Flutter остаётся полностью видимым.
2. Native adapter принимает точную activation/content revision и создаёт кадр.
3. Платформа подтверждает frame commit этого кадра.
4. `windowReady(session, activation, content)` возвращается через Pigeon.
5. Только после точного совпадения тройки Flutter скрывает fallback.

При выходе ID из native membership Flutter fallback возвращается немедленно.
Готовность другого экрана, старой activation или старой content revision
игнорируется.

## iOS

- Один window overlay из `SharedAppFoundation`, закреплённый точным SPM revision.
- Один общий `CADisplayLink`, без timer/ticker на ячейку.
- Metal/CoreGraphics high-range path: FP16/extended-linear color и EDR-capable
  layer/window contract.
- Viewport маска всегда обрезает native paint границей Flutter scroll viewport.
- Максимальная частота следует диапазону, который реально выдаёт iOS; app-side
  cap 30/60 FPS запрещён.

## Android

- API 34+ и HDR-capable Display: один полноэкранный прозрачный View поверх
  Flutter, `Gainmap` и системный window HDR headroom.
- Production window request остаётся automatic `0f`; телефон/OEM решает реально
  доступный headroom. `window.screenBrightness` запрещён: он меняет весь экран.
- Один `Choreographer.FrameCallback` независимо от числа ячеек.
- Canvas обязательно `clipRect` точным `scene.viewportPx` до рисования ячеек;
  intersect-culling не заменяет clip и иначе ячейки пролетают поверх header.
- Readiness отправляется после `registerFrameCommitCallback`, а не после одного
  выполнения `onDraw`.
- API ниже 34 и дисплей без HDR получают честный Flutter fallback, не SDR glow,
  названный HDR.

## Инварианты качества

- Одна native surface и один OS-vsync clock на платформу.
- Никаких `UiKitView`, `AndroidView` или PlatformView на ячейку.
- Никаких raw MethodChannel/BasicMessageChannel: только generated Pigeon.
- Никаких hardcode 60/90/120 по модели устройства.
- Jelly, HDR и pulse используют один native frame timestamp.
- Background/inactive/offscreen гасит continuous work; thermal/power policy
  может понизить LOD, но не разрывает static ownership.
- Геометрия переносится из измеренных координат Flutter математически; никаких
  визуальных компенсационных коэффициентов.

## Обязательная проверка изменения

```sh
tool/verify_pigeon_generated.sh
flutter test test/shared/edr
(
  cd android
  ./gradlew :app:testDebugUnitTest
)
tool/verify_architecture.sh
tool/quality_gate.sh
```

Финальный гейт — физические устройства:

- iPhone 17 Pro Max: EDR brightness, 120 Hz cadence, scroll/bounce, массовый VIP;
- Pixel 8: compositor `hdrSdrRatio`, maximum current refresh, scroll clip,
  jelly/pulse и отсутствие пустых native-owned tiles.

Обычный PNG или screen recording годится для геометрии и пропавших ячеек, но не
доказывает HDR luminance. HDR подтверждается глазами на панели плюс системными
diagnostics/device logs.
