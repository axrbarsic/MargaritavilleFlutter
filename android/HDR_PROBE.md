# Android HDR probe

## Назначение

Debug-only стенд проверяет реальный HDR headroom Android-композитора отдельно от
Flutter/Dart UI. Он не меняет production manifest и не подключён к Dart call
sites. Одинаковые базовые плашки рисуются как обычный SDR bitmap и как bitmap с
Android `Gainmap`; доказательством служит не разница цвета на скриншоте, а
`Display.hdrSdrRatio > 1.02` после показа gainmap-контента.

## Контракт

- UI-toolkit HDR запрашивается только на API 34+ и только если `Display.isHdr`.
- На API 35+ запрашивается `Window.setDesiredHdrHeadroom(2f)`.
- Максимальная частота выбирается динамически среди режимов текущего разрешения
  и передаётся через `preferredRefreshRate`; это hint, который ОС вправе
  отклонить из-за Battery Saver, thermal state, пользовательской политики или
  конкурирующих surface.
- На API ниже 34 стенд остаётся SDR. `SurfaceView`/`SurfaceControl` имеют
  отдельный HDR-контракт и этим стендом не покрываются.

## Запуск

```sh
JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home \
  ./gradlew :app:assembleDebug
adb -s 44171FDJH003R5 install -r \
  ../build/app/outputs/apk/debug/app-debug.apk
adb -s 44171FDJH003R5 shell am start -n \
  com.alex.margaritaville.flutter.beta/.hdr.HdrProbeActivity
adb -s 44171FDJH003R5 logcat -d -s MargaritaHdrProbe:I AndroidRuntime:E '*:S'
```

## Проверенный baseline — 2026-07-10

Физический Pixel 8 `44171FDJH003R5` (`shiba`), Android 17 / API 37:

- HDR: HDR10, HLG, HDR10+; wide color gamut: true;
- заявленная яркость HDR-пути: 1000 nit max / 1000 nit average;
- режимы панели: 60 и 120 Гц;
- фактически во время стенда: 120.00001 Гц;
- `hdrSdrRatio`: поднялся с 1.0 до 1.9999715;
- Battery Saver: false; thermal status: 0.

Это доказывает, что Android UI-toolkit window + gainmap путь получает настоящий
headroom примерно 2× на данном устройстве и не является имитацией SDR-glow.

## Первичные источники

- Pixel 8 display/HDR specs: https://support.google.com/pixelphone/answer/7158570
- `ActivityInfo.COLOR_MODE_HDR`: https://developer.android.com/reference/android/content/pm/ActivityInfo#COLOR_MODE_HDR
- `Window.setDesiredHdrHeadroom`: https://developer.android.com/reference/android/view/Window#setDesiredHdrHeadroom(float)
- `Display.getHdrSdrRatio`: https://developer.android.com/reference/android/view/Display#getHdrSdrRatio()
- `Gainmap`: https://developer.android.com/reference/android/graphics/Gainmap
- Android frame-rate guidance: https://developer.android.com/media/optimize/performance/frame-rate
- AOSP CTS HDR headroom test: https://android.googlesource.com/platform/cts/+/refs/heads/main/tests/surfacecontrol/src/android/view/surfacecontrol/cts/SurfaceControlTest.java
