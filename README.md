# Anime Flutter

Flutter Anime Stream app allows users to watch and access anime streams directly through an imaginative interface.

## Development Tools

- Flutter 3.27.1
- Tools • Dart 3.6.0 • DevTools 2.40.2

## Run Program

- `git clone https://github.com/fitri-hy/anime_flutter.git`
- `cd anime_flutter`
- `flutter pub get`
- `flutter run`

## Generates Keystore

```
keytool -genkeypair -v -keystore anime-key.keystore -keyalg RSA -keysize 2048 -validity 10000 -storepass 123456 -keypass 123456 -alias anime
```

## Build & Release

```
flutter build apk --release
flutter build appbundle
```

<div style="display: flex; flex-wrap: wrap;">
  <img src="./assets/production/ss.png" alt="ss1" width="200"/>
</div>
