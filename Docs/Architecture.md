# Архитектура Margaritaville Flutter

## Граница приложения

`MargaritavilleFlutter` — самостоятельное приложение с beta bundle ID
`com.alex.margaritaville.flutter.beta`. Оно не импортирует и не открывает
хранилища `MargaritavilleSwift`, `OceanKeySwift` или `OceanKeyFlutterRun`.

Android shell использует тот же изолированный beta application ID. Android
platform adapter не должен ослаблять iPhone-first EDR/media архитектуру; для
Apple-only возможностей вводятся явные Android fallback policies.

По классификации `shared-app-foundation` текущая вертикаль является
`app-specific`: hotel profile, simple-cycle, смена, назначения уборщиц, скрытые
cart/work-block IDs и локальная база принадлежат именно Margaritaville.

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
- Эффекты не получают отдельный ticker на ячейку. Будущий visual runtime будет
  единой управляемой точкой.
- VIP и schedule меняются отдельными versioned commands и сохраняют собственные
  field timestamps; они не кодируются внутри room status.
- Проверка due schedule выполняется одним 15-second coordinator на Summary и
  при возврате приложения в foreground, а не отдельным timer на каждую ячейку.
- Локальные уведомления проходят только через
  `RoomScheduleNotificationClient`. Reset, clear и due-transition обязаны
  отменять прежний notification ID `margaritaville.room.schedule.<room>`.
  Сейчас подключён явный no-op adapter; нативные iOS/Android adapters являются
  следующим platform-services checkpoint и не маскируются как готовые.
