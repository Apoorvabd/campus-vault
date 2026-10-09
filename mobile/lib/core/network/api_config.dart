/// Where the backend lives. Default: http://localhost:5000, which every
/// device reaches the same way:
///   - Android phone / emulator: `adb reverse tcp:5000 tcp:5000` maps the
///     phone's localhost:5000 to this Mac's port 5000 (scripts/dev.sh does it
///     for you before `flutter run`, so the Mac's changing Wi-Fi IP no longer
///     matters)
///   - iOS simulator: localhost already is the Mac
/// Override for a one-off:  --dart-define=API_BASE_URL=http://<mac-ip>:5000/api/v1
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:5000/api/v1',
);
