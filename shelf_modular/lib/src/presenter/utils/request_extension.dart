import 'dart:async';

import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shelf/shelf.dart';

extension ReadMultipartRequestExtension on Request {
  bool get isMultipart => _extractMultipartBoundary() != null;

  /// Extracts the `boundary` paramete from the content-type header, if this is
  /// a multipart request.
  String? _extractMultipartBoundary() {
    if (!headers.containsKey('Content-Type')) return null;

    final contentType = MediaType.parse(headers['Content-Type']!);
    if (contentType.type != 'multipart') return null;

    return contentType.parameters['boundary'];
  }

  Stream<MimeMultipart> get parts {
    final boundary = _extractMultipartBoundary();
    if (boundary == null) {
      throw StateError('Not a multipart request.');
    }

    return MimeMultipartTransformer(boundary).bind(read()).map((part) => _CaseInsensitiveMultipart(part));
  }
}

class _CaseInsensitiveMultipart extends MimeMultipart {
  final MimeMultipart _inner;
  Map<String, String>? _normalizedHeaders;

  _CaseInsensitiveMultipart(this._inner);

  @override
  Map<String, String> get headers {
    return _normalizedHeaders ??= CaseInsensitiveMap.from(_inner.headers);
  }

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> data)? onData, {void Function()? onDone, Function? onError, bool? cancelOnError}) {
    return _inner.listen(onData, onDone: onDone, onError: onError, cancelOnError: cancelOnError);
  }
}
