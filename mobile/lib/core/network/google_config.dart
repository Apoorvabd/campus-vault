/// The Web client ID from Google Cloud (not the Android one).
///
/// Google makes the sign-in ID token for this client and the backend only
/// accepts tokens made for it, so it must be the same ID as the backend's
/// GOOGLE_CLIENT_ID. It is a public identifier, not a secret.
///
/// Paste it below, or override it with
/// `--dart-define=GOOGLE_SERVER_CLIENT_ID=your-id`
const String googleServerClientId = String.fromEnvironment(
  'GOOGLE_SERVER_CLIENT_ID',
  defaultValue: '426798021123-bkjlup0bpb3hgo5bk0tjtu3pvba7jsto.apps.googleusercontent.com',
);

bool get isGoogleSignInConfigured =>
    !googleServerClientId.startsWith('PASTE_');
