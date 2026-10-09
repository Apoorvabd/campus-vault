import 'package:dio/dio.dart';
import 'api_exception.dart';

/// Runs [request] and converts any DioException into our ApiException,
/// so every repository method needs no try/catch of its own.
Future<T> guardApi<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (e) {
    throw ApiException.fromDio(e);
  }
}

/// The server only accepts PDF, JPG and PNG uploads, and decides by the
/// content type we send, so it has to be set explicitly.
DioMediaType mediaTypeForPath(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.pdf')) return DioMediaType.parse('application/pdf');
  if (lower.endsWith('.png')) return DioMediaType.parse('image/png');
  return DioMediaType.parse('image/jpeg');
}

Future<MultipartFile> multipartFromPath(String path, {String? filename}) {
  return MultipartFile.fromFile(
    path,
    filename: filename ?? path.split('/').last,
    contentType: mediaTypeForPath(path),
  );
}
