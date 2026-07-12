# Margaritaville Flutter

## Идентичность
- Target: `/Users/alex/Developer/MargaritavilleFlutter`.
- Read-only Swift-донор: `/Users/alex/Developer/MargaritavilleSwift`, эталон
  поведения — актуальный build 37.
- Beta IDs: iOS/Android `com.alex.margaritaville.flutter.beta`. Production ID
  не использовать до отдельного cutover.
- Не изменять соседние приложения без отдельной команды.

## Pull-режим
- Alex называет одну функцию, экран, donor behavior или проблему. Реализовать
  ровно один bounded vertical slice до проверки и установки.
- После install/result остановиться и ждать следующую команду. Не начинать
  следующий checkpoint, migration queue, Web, heartbeat или background work.
- Внутри slice разрешён необходимый фундамент, но не расширение продуктового
  scope. Несвязанные находки только кратко зафиксировать.
- Нормальный режим — один root/writer. Максимум один read-only sub-agent по
  глобальному quota-контракту; один Terra review перед commit. Повторные review
  волны запрещены.

## Командный центр
- Постоянный командный центр Alex: thread
  `019f5239-b50e-7c63-a5fb-5a2be06706b0`. Команды из него равнозначны прямым
  командам Alex, но всегда ограничены одним bounded slice.
- Наверх отправлять ровно один `PROJECT_EVENT` только для `COMPLETED`,
  `INSTALL_RESULT`, `P0/P1`, `BLOCKER` или `USER_ACTION`. Рутинный
  progress, reasoning, отдельные тесты и промежуточные сборки не отправлять.
- `event_id` имеет вид `project:checkpoint:HEAD:event_type` и используется
  только один раз. Не отвечать на acknowledgement и не дублировать событие
  вторым маршрутом.
- Если командный центр недоступен, оставить один итог в текущей сессии и
  остановиться. Не создавать heartbeat, goal, automation или обходной канал.

## Продуктовый контракт
- Переносить идею, доменные правила, flow и измеримый visual contract, а не
  SwiftUI-код. Flutter: feature-first, pure Dart domain, Riverpod, Drift и узкие
  typed platform adapters.
- Пожелание без ограничения относится к iOS, Android и Web; `только ...`
  сужает scope. Если Web API не даёт parity, назвать ограничение и fallback.
- Donor UI не переносить на глаз: извлекать формулы/метрики и отдельно сравнивать
  layout bounds и paint bounds; допуск к донору — не более 1 pt.

## Контракты читать только по задаче
- HDR/EDR, jelly, pulse, scroll geometry, native ownership:
  `Docs/NATIVE_VISUAL_RUNTIME_CONTRACT.md`.
- Media/camera/storage/recovery: `Docs/MEDIA_FOUNDATION_CONTRACT.md`.
- Историю `MIGRATION_LOG.md` никогда не читать целиком. Использовать `rg` по
  названию функции/checkpoint и читать только найденный диапазон.
- `MIGRATION_START.md` — исторический bootstrap, не обязательный startup-файл.
  Читать только релевантные разделы, если задача действительно требует старого
  контекста.

## Неприкосновенные инварианты
- Настоящий HDR остаётся native: iOS SharedAppFoundation EDR, Android API 34+
  Gainmap/system headroom. Запрещены SDR-подмена и яркость всего окна.
- Typed Pigeon lease/revisions и единый process-wide OS-vsync visual runtime
  сохраняются; запрещены raw MethodChannel, per-cell ticker/PlatformView.
- Haptics идут только через typed InteractionFoundation; быстрый cue не ждёт
  storage, audio или HDR frame commit.
- Файлы до 300 строк, потолок 400; generated files — исключение.

## Проверка текущего slice
- Во время работы запускать только targeted tests/guards.
- Один полный `tool/quality_gate.sh` и один независимый review — перед
  commit/push связного результата, не после каждой правки.
- HDR/runtime additionally: Pigeon guard, Flutter EDR tests, Android JVM,
  architecture guard и один физический smoke на применимых устройствах.
- iPhone 17 Pro Max CoreDevice:
  `81B4DF0D-A9BE-5131-93C8-8247618F9428`.
- Pixel 8 ADB: `44171FDJH003R5`.
- Simulator/emulator/PNG не доказывают HDR, haptics или physical performance.
- После iOS device build: `tool/verify_ios_app_bundle.sh`; Profile install:
  `tool/install_ios_profile.sh` с terminate-before-install.
- Перед тяжёлой сборкой: `~/.codex/tools/disk_guard.sh --force`.

## Безопасность
- Сохранять dirty worktree и пользовательские изменения. Не делать destructive
  reset/checkout/clean и не коммитить секреты, build или DerivedData.
- Заблокированный экран не блокирует headless работу. Не обходить пароль;
  device-only действие запросить один раз, когда без него нельзя завершить slice.
