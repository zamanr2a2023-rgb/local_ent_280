import 'dart:async';
import 'dart:convert';
import 'dart:io';

class FakeImageHttpClient implements HttpClient {
  bool _autoUncompress = true;

  @override
  bool get autoUncompress => _autoUncompress;

  @override
  set autoUncompress(bool value) {
    _autoUncompress = value;
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => FakeImageHttpRequest();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeImageHttpRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => FakeImageHttpResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeImageHttpResponse extends Stream<List<int>>
    implements HttpClientResponse {
  static final List<int> _imageBytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9sotWZkAAAAASUVORK5CYII=',
  );

  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => _imageBytes.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  bool get isRedirect => false;

  @override
  X509Certificate? get certificate => null;

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  List<Cookie> get cookies => const <Cookie>[];

  @override
  bool get persistentConnection => false;

  @override
  String get reasonPhrase => 'OK';

  @override
  List<RedirectInfo> get redirects => const <RedirectInfo>[];

  @override
  HttpHeaders get headers => FakeImageHttpHeaders();

  @override
  Future<Socket> detachSocket() {
    throw UnimplementedError();
  }

  @override
  Future<HttpClientResponse> redirect([
    String? method,
    Uri? url,
    bool? followLoops,
  ]) {
    throw UnimplementedError();
  }

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> data)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_imageBytes).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

class FakeImageHttpHeaders implements HttpHeaders {
  @override
  List<String>? operator [](String name) {
    if (name.toLowerCase() == HttpHeaders.contentTypeHeader) {
      return const <String>['image/png'];
    }
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
