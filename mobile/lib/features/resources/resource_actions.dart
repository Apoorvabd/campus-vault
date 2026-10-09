import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/data/resources_repository.dart';
import '../../core/models/resource.dart';

/// Opens a resource's file/link in the browser or a viewer app, then tells
/// the backend (fire-and-forget) so the download count goes up.
Future<void> openResource(
  BuildContext context,
  ResourcesRepository repository,
  Resource resource,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final url = resource.fileUrl;
  if (url == null) {
    messenger.showSnackBar(const SnackBar(content: Text('No file attached')));
    return;
  }
  try {
    final ok = await openLinkInApp(url);
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open file')),
      );
      return;
    }
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not open file')),
    );
    return;
  }
  // Counting the view is best effort, so errors are ignored
  repository.recordDownload(resource.id).then((_) {}, onError: (_) {});
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
