import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

// On web, `compute()` doesn't spawn a real isolate — it just runs the
// callback on the main thread after a microtask (see Flutter's
// `_isolates_web.dart`). Decoding/resizing a multi-megapixel phone photo
// with the pure-Dart `image` package there freezes the tab for the whole
// duration. The browser's own canvas/image pipeline does the same work
// natively (hardware-accelerated, off the Dart event loop), so we use that
// instead on web.
const int _maxUploadDimension = 1600;
const num _uploadJpegQuality = 0.82;

Future<Uint8List> compressImageBytes(Uint8List bytes) async {
  final objectUrl = html.Url.createObjectUrlFromBlob(html.Blob([bytes]));
  try {
    final image = html.ImageElement(src: objectUrl);
    final loaded = Completer<void>();
    image.onLoad.listen((_) => loaded.complete());
    image.onError.listen((_) => loaded.completeError('Impossible de décoder l\'image'));
    await loaded.future;

    var width = image.naturalWidth;
    var height = image.naturalHeight;
    if (width > _maxUploadDimension || height > _maxUploadDimension) {
      if (width >= height) {
        height = (height * _maxUploadDimension / width).round();
        width = _maxUploadDimension;
      } else {
        width = (width * _maxUploadDimension / height).round();
        height = _maxUploadDimension;
      }
    }

    final canvas = html.CanvasElement(width: width, height: height);
    canvas.context2D.drawImageScaled(image, 0, 0, width, height);

    final blob = await canvas.toBlob('image/jpeg', _uploadJpegQuality);

    final reader = html.FileReader();
    final read = Completer<Uint8List>();
    reader.onLoadEnd.listen((_) {
      final result = reader.result;
      read.complete(
        result is Uint8List ? result : (result as ByteBuffer).asUint8List(),
      );
    });
    reader.onError.listen((_) => read.completeError('Échec de la lecture de l\'image compressée'));
    reader.readAsArrayBuffer(blob);

    return await read.future;
  } finally {
    html.Url.revokeObjectUrl(objectUrl);
  }
}
