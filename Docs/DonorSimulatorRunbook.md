# Swift-донор на iPhone 17 Pro Max Simulator

## Назначение

Simulator освобождает физический iPhone и используется для повседневного обхода
экранов, жестов, deterministic fixtures и screenshot baseline.

- Simulator: iPhone 17 Pro Max, iOS 26.3.
- UDID: `BE4AB2BD-CD2A-4D0F-A73C-B31E8E2D6C0B`.
- Donor: `/Users/alex/Developer/MargaritavilleSwift`.
- Bundle ID: `com.alex.margaritaville.swift`.
- Проверенный build: `0.1.0 (37)`.
- Текущая отдельная simulator-база: 27 назначенных комнат.

Simulator не является эталоном EDR/HDR headroom, точных haptics,
camera/mic/Speech, thermal/battery и 120 Hz performance. Эти проверки остаются
на физическом iPhone 17 Pro Max.

## Сборка И Запуск

DerivedData хранится внутри игнорируемого Flutter `build/`, чтобы read-only
сборка не добавляла мусор в dirty Swift worktree.

```sh
udid=BE4AB2BD-CD2A-4D0F-A73C-B31E8E2D6C0B
derived=/Users/alex/Developer/MargaritavilleFlutter/build/swift-donor-simulator-derived
app="$derived/Build/Products/Debug-iphonesimulator/MargaritavilleSwift.app"

xcrun simctl boot "$udid" 2>/dev/null || true
open -a Simulator --args -CurrentDeviceUDID "$udid"
xcrun simctl bootstatus "$udid" -b

xcodebuild \
  -project /Users/alex/Developer/MargaritavilleSwift/MargaritavilleSwift.xcodeproj \
  -scheme MargaritavilleSwift \
  -configuration Debug \
  -destination "platform=iOS Simulator,id=$udid" \
  -derivedDataPath "$derived" \
  build

xcrun simctl install "$udid" "$app"
xcrun simctl launch --terminate-running-process \
  "$udid" com.alex.margaritaville.swift
```

Не добавлять `CODE_SIGNING_ALLOWED=NO`. На Simulator donor включает CloudKit
preset-store; без simulated entitlements CoreData/CloudKit завершает процесс
SIGTRAP. Штатная `Sign to Run Locally` работает без provisioning profile.

## Снимок И Проверка Версии

```sh
xcrun simctl io "$udid" screenshot /tmp/margaritaville-swift.png
/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$app/Info.plist"
```

Fixture должен переживать `simctl launch --terminate-running-process`. Данные
Simulator изолированы от SwiftData на физическом iPhone.
