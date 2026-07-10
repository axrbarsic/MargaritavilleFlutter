# Visual parity plan

## Источник Правды

Приоритет визуального и поведенческого эталона:

1. Живой `MargaritavilleSwift` build 37 на физическом iPhone 17 Pro Max.
2. Активный Swift-код профиля `simpleCycle + squareGrid4`.
3. Документы Swift-проекта, если они не расходятся с текущим кодом.

Старые и не подключённые к активной навигации SwiftUI-компоненты не являются
эталоном. Состояние со 100+ комнатами — stress fixture: частично скрытые числа
слева в шапке в нём ожидаемы и не входят в список дефектов.

Повседневный donor baseline работает на iPhone 17 Pro Max Simulator build 37 с
отдельной базой на 27 комнат. Физический iPhone используется для контрольных
снимков и аппаратных гейтов. Команды запуска — в `DonorSimulatorRunbook.md`.

## Подход

Backend и frontend не переносятся двумя изолированными фазами. Работа идёт
вертикальными срезами:

```text
детерминированный fixture
  -> pure Dart domain/command
  -> транзакционный Drift repository
  -> Flutter layout и interaction
  -> physical iPhone + Pixel visual/performance QA
```

Так каждый визуально точный экран остаётся рабочим, сохраняемым и тестируемым,
а не превращается в оторванный от продукта mockup.

## Первый Срез: Основной Экран — Одна Уборщица

Детерминированный fixture:

- одна уборщица и одна зона;
- восемь комнат в двух строках по четыре;
- pending, open, ready, scheduled и одна VIP-комната;
- фиксированные timestamps;
- фиксированные настройки;
- статический фон для screenshot diff, затем отдельная Matrix-проверка.

Порядок реализации:

1. Donor tokens: palette, typography, spacing, radii и `RoomCellGeometry`.
2. Компактная шапка со счётчиками, filters и puzzle handle.
3. Capsule уборщицы, territory label и точная сетка 4 x N.
4. Номер, timestamp, status/VIP/media presentation внутри ячейки.
5. Удержание `pending -> open -> ready` с arbitration против scroll.
6. Правый свайп и action menu, включая явный reset.
7. Kill/restart и одинаковый результат canonical fixture.
8. Matrix/VIP jelly через общий frame clock.
9. Ранний iOS EDR overlay spike; на Android — явный SDR fallback.

Setup остаётся функциональным на время первого среза. Его полный visual parity
идёт следующим блоком, после стабилизации главного рабочего экрана.

## Что Сейчас Не Совпадает

- Flutter использует generic Material theme вместо donor design system.
- Шапка занимает три большие карточки вместо компактной donor-панели.
- Цвета статусов, размеры, отступы и типографика отличаются.
- В Flutter нет donor timestamps, filters, puzzle unlock и room action swipe.
- Reset вынесен в зелёную ячейку, а в доноре находится в action menu.
- Нет Matrix, VIP jelly, общего interaction/visual runtime и EDR adapter.

## Definition Of Done

- геометрия контрольного состояния отличается не более чем на 1 pt;
- SDR-цвета имеют `Delta E <= 3`;
- данные, тексты, порядок, переносы и состояния совпадают;
- long press: 460 ms, допустимое смещение 8 pt;
- вертикальный scroll не вызывает ложное удержание или горизонтальный swipe;
- status command и kill/restart дают одинаковый canonical результат;
- HDR проверяется на физическом iPhone по EDR headroom, не screenshot diff;
- pulse не повторяется после recycling/прокрутки;
- после shader warm-up P95 frame time <= 8.33 ms на 120 Hz;
- обязательны физические iPhone 17 Pro Max и Pixel 8, без simulator/emulator.

Буквальное побитовое равенство SwiftUI и Flutter не требуется: растеризация
текста, blur и spring различаются между движками. Требуется измеримый
перцептивный и поведенческий паритет.
