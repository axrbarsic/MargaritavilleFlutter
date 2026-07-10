# Архитектура Margaritaville Flutter

## Граница приложения

`MargaritavilleFlutter` — самостоятельное приложение с beta bundle ID
`com.alex.margaritaville.flutter.beta`. Оно не импортирует и не открывает
хранилища `MargaritavilleSwift`, `OceanKeySwift` или `OceanKeyFlutterRun`.

Android shell использует тот же изолированный beta application ID. Android
platform adapter не должен ослаблять iPhone-first EDR/media архитектуру; для
Apple-only возможностей вводятся явные Android fallback policies.

По классификации `shared-app-foundation` hotel profile, simple-cycle, смена,
назначения уборщиц, скрытые cart/work-block IDs и локальная база являются
`app-specific` и принадлежат именно Margaritaville. Visual runtime разделён
явно:

- `shared/visual_runtime` — `shared-foundation`: один frame clock, жизненный
  цикл, frame budget и пауза в background/reduced-motion/TickerMode;
- `SummaryVisualPolicy` и адаптация общего clock к ячейкам —
  `shared-parameterized`: Flutter-механизм общий, но скорость, амплитуда,
  палитра и LOD задаются профилем приложения;
- соответствие room status, момент доменной мутации, VIP/schedule settings и
  persistence — `app-specific`.

Ни один из этих слоёв не импортирует код или storage соседнего приложения.

## Направление зависимостей

```text
presentation (Flutter + Riverpod)
  -> application (versioned commands + handlers)
  -> domain (pure Dart immutable values + repository contracts)
  <- data (Drift implementation)
```

- `domain` не импортирует Flutter, Riverpod или Drift.
- `application` не знает о виджетах и SQL.
- `data` реализует domain repository contracts.
- `presentation` вызывает только controller/application API.
- iOS-specific EDR, audio, Speech, haptics и media появятся за отдельным
  типизированным bridge, а не внутри domain или виджетов.

## Feature-first модули checkpoint 1

- `features/work_session/domain` — canonical schema v2 values и инварианты.
- `features/work_session/application` — versioned commands и persistence handler.
- `features/work_session/data` — нормализованный Drift store.
- `features/work_session/presentation` — Riverpod controller и root shell.
- `features/work_setup` — выбор номеров по уборщице и зоне.
- `features/summary` — рабочая четырёхколоночная summary-сетка.
- `shared/presentation` — локальные нейтральные UI-примитивы приложения.

## Runtime-инварианты

- Состояние подтверждается SQLite-транзакцией до публикации нового UI state.
- Все application commands сериализуются одним controller queue: timer,
  gesture и sheet callback не могут одновременно прочитать старый state и
  затереть изменения друг друга.
- Один активный номер может принадлежать только одному work block.
- Cart number хранится как внутренний persistence key и не является primary UI
  label.
- Рабочие мутации требуют long press; быстрые фильтры/навигация смогут оставаться
  обычным tap.
- Эффекты не получают отдельный ticker на ячейку. Один
  `VisualRuntimeScope` владеет единственным `AnimationController`, публикует
  общий clock с frame budget 30 FPS и полностью останавливается, когда в
  активной смене нет VIP/one-shot pulse, приложение ушло в background,
  отключены анимации или предок выключил `TickerMode`.
- VIP jelly и status pulse — чистая функция общего времени и stable room seed;
  rebuild/recycling не перезапускают завершённое событие. One-shot события
  живут отдельно от persisted room state и удаляются по generation-aware
  cleanup после 2.73 s.
- Android и обычный iOS Simulator используют честный same-color SDR glow.
  Настоящий iPhone HDR/EDR остаётся узким platform-adapter checkpoint и не
  подменяется завышенной яркостью всего Flutter-дерева.
- VIP и schedule меняются отдельными versioned commands и сохраняют собственные
  field timestamps; они не кодируются внутри room status.
- Проверка due schedule выполняется одним 15-second coordinator на Summary и
  при возврате приложения в foreground, а не отдельным timer на каждую ячейку.
- Локальные уведомления проходят только через
  `RoomScheduleNotificationClient`. Reset, clear и due-transition обязаны
  отменять прежний notification ID `margaritaville.room.schedule.<room>`.
  Сейчас подключён явный no-op adapter; нативные iOS/Android adapters являются
  следующим platform-services checkpoint и не маскируются как готовые.
