# Pixel 8 Emulator runbook

## Назначение

Alex 2026-07-09 разрешил Android Emulator как повседневную Flutter-мишень для
сравнения с iPhone 17 Pro Max Simulator. Финальные density/font-scale,
performance, thermal и длительные gesture-проверки всё равно выполняются на
физическом Pixel 8 `44171FDJH003R5`.

## Канонический AVD

- имя: `margarita_pixel_8_api36`;
- профиль: Pixel 8, `1080 x 2400`, `420 dpi`;
- system image: `system-images;android-36;google_apis;arm64-v8a`;
- Android 16/API 36, ARM64;
- обычный serial при единственном запущенном эмуляторе: `emulator-5554`.

Image уже был установлен локально. Не создавать дубликат AVD и не скачивать
новый многогигабайтный image без отдельного основания.

## Запуск

```bash
emulator -list-avds
emulator @margarita_pixel_8_api36 -no-snapshot-load -no-boot-anim
adb devices -l
adb -s emulator-5554 shell getprop sys.boot_completed
```

Если из-за нагрузки рантайм перешёл на software OpenGL, его можно использовать
для layout/navigation QA, но нельзя считать FPS такого запуска эталонным.

## Установка только на Emulator

Перед сборкой выполнить disk guard. Все `adb`-команды обязательно адресовать
через `-s emulator-5554`, чтобы не затронуть физический Pixel.

```bash
~/.codex/tools/disk_guard.sh --force
flutter build apk --debug
adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk
adb -s emulator-5554 shell am force-stop com.alex.margaritaville.flutter.beta
adb -s emulator-5554 shell am start -W \
  -n com.alex.margaritaville.flutter.beta/.MainActivity
```

## Скриншот

```bash
adb -s emulator-5554 shell screencap -p /sdcard/margaritaville.png
adb -s emulator-5554 pull /sdcard/margaritaville.png build/qa/
```

AVD занимает примерно 1.6 GiB. После тяжёлых сборок повторять disk guard и
удалять только заведомо временные артефакты текущей migration-сессии.
