import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/data/resources_repository.dart';
import '../../core/models/resource.dart';
import '../../core/network/api_exception.dart';

/// Opens a resource's file/link in the browser or a viewer app. The link is
/// asked from the backend at this moment (which also counts the view), because
/// resources do not carry their link.
Future<void> openResource(
  BuildContext context,
  ResourcesRepository repository,
  Resource resource,
) async {
  final messenger = ScaffoldMessenger.of(context);
  void say(String message) => messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  if (!resource.hasFile) {
    say('No file attached');
    return;
  }
  try {
    final link = await repository.openLink(resource.id);
    if (!await openLinkInApp(link.url)) say('Could not open file');
  } on ApiException catch (e) {
    say(e.message);
  } catch (_) {
    say('Could not open file');
  }
}

/// Opens a link in an in-app browser tab (the user stays inside the app and
/// Back returns to it). Falls back to the external browser / viewer when the
/// device has no in-app browser.
Future<bool> openLinkInApp(String url) async {
  final uri = Uri.parse(url);
  try {
    if (await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) return true;
  } catch (_) {
    // fall through to the external app below
  }
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
