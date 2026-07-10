# Canonical work-session schema v2

Дата фиксации: 2026-07-09.

## Зачем нужна v2

Swift-эталон build 37 вычисляет зелёный simple-cycle статус через заполнение
скрытых S/L/B tasks и сохраняет snapshot schema v1. Flutter не копирует эту
форму хранения. Canonical v2 вводит явную фазу комнаты и отдельные field
timestamps, чтобы persistence, merge и будущий cutover имели один смысл.

## Room contract

Underlying phase:

- `pending` — жёлтый;
- `open` — красный;
- `ready` — зелёный и terminal для обычного advance.

`scheduledFor` — отдельный pink overlay, а не underlying phase. Due schedule:

- над `pending` снимает schedule и переводит комнату в `open`;
- над `open` или `ready` только снимает overlay;
- manual advance scheduled-комнаты также снимает overlay.

Explicit reset возвращает phase в `pending`, но сохраняет первые milestone facts
`openedAt` и `completedAt`. VIP независим от phase и имеет `vipUpdatedAt`.

## Назначения и смена

- `Housekeeper.id` — стабильный ID; display name и palette изменяемы.
- `WorkAssignment.id` — work-block ID; `cartNumber` является скрытым внутренним
  ключом.
- Активный room number уникален внутри session.
- Выбор того же номера другим work block возвращает `blocked` без мутации.
- Снятие выбора оставляет `deletedAt` tombstone.
- Lock разрешён только при наличии хотя бы одного активного номера и блокирует
  setup-мутации.

## Drift schema

Основной нормализованный граф:

- `work_session_records`;
- `housekeeper_records`;
- `work_assignment_records`;
- `room_state_records` с primary key `(session_id, room_number)`.

Заранее зафиксированы sync/cutover границы:

- `history_event_records` с `commandId` и `eventVersion`;
- `sync_outbox_records`;
- `sync_inbox_records` для идемпотентной доставки;
- `media_manifest_records` с origin device, SHA-256, updated/deleted timestamps.

Все `DateTime` колонки хранятся как ISO-8601 text. Это сохраняет UTC и
sub-second precision, необходимую для field-level ordering. Полный work-session
JSON в SharedPreferences не используется.

## Первая транзакционная вертикаль

`DriftWorkSessionRepository.replaceSession` записывает нормализованный session
graph внутри одной SQLite transaction. Foreign keys и cascade включены. Ошибка
любой вставки откатывает прежний подтверждённый graph.

Schema v2 является первой поддерживаемой beta-схемой этого нового приложения;
production v1 базы не существует. Поэтому неизвестный pre-v2 store отклоняется,
а не «мигрируется» через угадывание. Все следующие изменения обязаны получить
инкрементальный migration step и migration test до повышения `schemaVersion`.

## Golden contract

`test/fixtures/canonical_work_session_v2.json` — первый Swift-to-Dart contract
fixture. Он проверяет hotel/session, housekeeper assignments, explicit phases,
VIP, scheduled overlay и timestamp round-trip без SwiftData или Swift v1
storage assumptions.
