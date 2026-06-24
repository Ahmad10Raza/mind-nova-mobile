// Web implementation — reads blob URLs using dart:html XHR
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<Uint8List> readFileBytes(String path) async {
  // On Web, `path` is a blob URL like "blob:http://localhost:xxxxx/uuid"
  // We fetch it using an XHR request
  final request = await html.HttpRequest.request(
    path,
    responseType: 'arraybuffer',
  );
  final buffer = request.response as dynamic;
  return Uint8List.view(buffer);
}
