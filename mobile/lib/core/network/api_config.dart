/// Where the backend lives.
///
/// - Release builds (the APK you share): the deployed backend on Render.
/// - Debug builds (`flutter run`): http://localhost:5000, which every device
///   reaches the same way:
///     - Android phone / emulator: `adb reverse tcp:5000 tcp:5000` maps the
///       phone's localhost:5000 to this Mac's port 5000 (scripts/dev.sh does it
///       for you before `flutter run`, so the Mac's changing Wi-Fi IP no longer
///       matters)
///     - iOS simulator: localhost already is the Mac
///
/// Override either one with --dart-define=API_BASE_URL=http://<host>:5000/api/v1
const String _deployedBackend = 'https://semester-forge.onrender.com/api/v1';
const String _localBackend = 'http://localhost:5000/api/v1';

const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: bool.fromEnvironment('dart.vm.product')
      ? _deployedBackend
      : _localBackend,
);
