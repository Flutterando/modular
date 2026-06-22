import 'dart:async';

import 'package:dart_mcp/client.dart';
import 'package:flutter_modular_docs_mcp/src/server.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:test/test.dart';

base class _TestClient extends MCPClient {
  _TestClient() : super(Implementation(name: 'test client', version: '0.1.0'));
}

String _text(CallToolResult result) {
  final content = result.content.single;
  expect(content.isText, isTrue);
  return (content as TextContent).text;
}

void main() {
  late _TestClient client;
  late ModularDocsServer server;
  late ServerConnection connection;

  setUp(() async {
    final clientController = StreamController<String>();
    final serverController = StreamController<String>();
    final clientChannel = StreamChannel<String>.withCloseGuarantee(
      serverController.stream,
      clientController.sink,
    );
    final serverChannel = StreamChannel<String>.withCloseGuarantee(
      clientController.stream,
      serverController.sink,
    );

    client = _TestClient();
    server = ModularDocsServer(serverChannel);
    connection = client.connectServer(clientChannel);

    await connection.initialize(
      InitializeRequest(
        protocolVersion: ProtocolVersion.latestSupported,
        capabilities: client.capabilities,
        clientInfo: client.implementation,
      ),
    );
    connection.notifyInitialized();
    await server.initialized;
  });

  tearDown(() async {
    await client.shutdown();
    await server.shutdown();
  });

  test('advertises the search_docs and read_doc tools', () async {
    final tools = await connection.listTools();
    expect(
      tools.tools.map((t) => t.name),
      containsAll(<String>['search_docs', 'read_doc']),
    );
  });

  test('search_docs returns relevant results with resource URIs', () async {
    final result = await connection.callTool(
      CallToolRequest(name: 'search_docs', arguments: {'query': 'module'}),
    );
    expect(result.isError ?? false, isFalse);
    final text = _text(result);
    expect(text, contains('modular-docs:///'));
    expect(text.toLowerCase(), contains('module'));
  });

  test('search_docs reports an empty query as an error', () async {
    final result = await connection.callTool(
      CallToolRequest(name: 'search_docs', arguments: {'query': '   '}),
    );
    expect(result.isError, isTrue);
  });

  test('lists one resource per page and reads its markdown', () async {
    final resources = await connection.listResources();
    expect(resources.resources, isNotEmpty);
    final resource = resources.resources.firstWhere(
      (r) => r.uri.endsWith('flutter_modular/start.md'),
    );
    expect(resource.mimeType, 'text/markdown');

    final read = await connection.readResource(
      ReadResourceRequest(uri: resource.uri),
    );
    final contents = read.contents.single;
    expect(contents.isText, isTrue);
    expect((contents as TextResourceContents).text, contains('#'));
  });

  test('read_doc returns the full page by path', () async {
    final result = await connection.callTool(
      CallToolRequest(
        name: 'read_doc',
        arguments: {'path': 'flutter_modular/start.md'},
      ),
    );
    expect(result.isError ?? false, isFalse);
    expect(_text(result), contains('#'));
  });

  test('read_doc errors on an unknown page', () async {
    final result = await connection.callTool(
      CallToolRequest(name: 'read_doc', arguments: {'path': 'nope.md'}),
    );
    expect(result.isError, isTrue);
  });
}
