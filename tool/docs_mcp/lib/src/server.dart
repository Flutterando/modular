// The MCP server that serves the flutter_modular documentation.
//
// It exposes every doc page as an MCP *resource* (`modular-docs:///<path>`) and
// two *tools*: `search_docs` (keyword search over heading-delimited sections)
// and `read_doc` (fetch a full page by path or resource URI). Clients such as
// Claude Code or Cursor connect over stdio (see `bin/server.dart`).

import 'dart:async';

import 'package:dart_mcp/server.dart';

import 'doc_chunk.dart';
import 'generated/docs_data.g.dart';
import 'search_index.dart';

/// Version reported to clients in the MCP `initialize` handshake.
const String serverVersion = '0.2.2';

/// URI scheme/prefix under which each doc page is exposed as a resource.
const String _uriPrefix = 'modular-docs:///';

/// An MCP server over the embedded flutter_modular documentation.
base class ModularDocsServer extends MCPServer
    with ToolsSupport, ResourcesSupport {
  ModularDocsServer(
    super.channel, {
    List<DocPage>? pages,
    List<DocChunk>? chunks,
  }) : _pages = pages ?? docPages,
       _index = SearchIndex(chunks ?? docChunks),
       super.fromStreamChannel(
         implementation: Implementation(
           name: 'flutter_modular_docs',
           version: serverVersion,
         ),
         instructions:
             'Documentation for the flutter_modular Flutter package '
             '(dependency injection + route management). Use `search_docs` to '
             'find relevant sections by keyword, then `read_doc` (or read the '
             'returned `modular-docs://` resource) for the full page. Always '
             'ground answers about flutter_modular in these docs.',
       ) {
    for (final page in _pages) {
      _pageByPath[page.path] = page;
      addResource(
        Resource(
          uri: _uriFor(page.path),
          name: page.title,
          description: 'flutter_modular docs: ${page.path}',
          mimeType: 'text/markdown',
        ),
        _readResource,
      );
    }

    registerTool(_searchTool, _handleSearch);
    registerTool(_readDocTool, _handleReadDoc);
  }

  final List<DocPage> _pages;
  final SearchIndex _index;
  final Map<String, DocPage> _pageByPath = {};

  static String _uriFor(String path) => '$_uriPrefix$path';

  /// Accepts either a full `modular-docs:///<path>` URI or a bare page path.
  static String _pathFor(String uriOrPath) => uriOrPath.startsWith(_uriPrefix)
      ? uriOrPath.substring(_uriPrefix.length)
      : uriOrPath;

  // --- Resources -----------------------------------------------------------

  FutureOr<ReadResourceResult> _readResource(ReadResourceRequest request) {
    final page = _pageByPath[_pathFor(request.uri)];
    return ReadResourceResult(
      contents: [
        TextResourceContents(
          uri: request.uri,
          text: page?.markdown ?? 'Resource not found: ${request.uri}',
          mimeType: 'text/markdown',
        ),
      ],
    );
  }

  // --- Tools ---------------------------------------------------------------

  final Tool _searchTool = Tool(
    name: 'search_docs',
    description:
        'Search the flutter_modular documentation by keyword. Returns the '
        'most relevant doc sections with their page, heading, resource URI and '
        'a snippet.',
    inputSchema: Schema.object(
      properties: {
        'query': Schema.string(
          description: 'Keywords to search for, e.g. "route guard" or '
              '"page-scoped state".',
        ),
        'limit': Schema.int(
          description: 'Maximum number of results (default 5, max 20).',
        ),
      },
      required: ['query'],
    ),
  );

  FutureOr<CallToolResult> _handleSearch(CallToolRequest request) {
    final args = request.arguments ?? const {};
    final query = (args['query'] as String?)?.trim() ?? '';
    if (query.isEmpty) {
      return CallToolResult(
        content: [TextContent(text: 'Provide a non-empty "query".')],
        isError: true,
      );
    }
    final limit = switch (args['limit']) {
      final int n => n.clamp(1, 20),
      _ => 5,
    };

    final hits = _index.search(query, limit: limit);
    if (hits.isEmpty) {
      return CallToolResult(
        content: [
          TextContent(text: 'No documentation matched "$query".'),
        ],
      );
    }

    final buffer = StringBuffer('Top ${hits.length} result(s) for "$query":\n');
    for (final hit in hits) {
      final heading = hit.chunk.heading.isEmpty
          ? hit.chunk.pageTitle
          : '${hit.chunk.pageTitle} › ${hit.chunk.heading}';
      buffer
        ..writeln()
        ..writeln('## $heading')
        ..writeln('resource: ${_uriFor(hit.chunk.pagePath)}')
        ..writeln('path: ${hit.chunk.pagePath}')
        ..writeln()
        ..writeln(hit.snippet);
    }

    return CallToolResult(content: [TextContent(text: buffer.toString())]);
  }

  final Tool _readDocTool = Tool(
    name: 'read_doc',
    description:
        'Return the full markdown of a flutter_modular documentation page, by '
        'its path (e.g. "flutter_modular/start.md") or its modular-docs:// '
        'resource URI.',
    inputSchema: Schema.object(
      properties: {
        'path': Schema.string(
          description: 'Doc page path or modular-docs:// resource URI.',
        ),
      },
      required: ['path'],
    ),
  );

  FutureOr<CallToolResult> _handleReadDoc(CallToolRequest request) {
    final args = request.arguments ?? const {};
    final path = _pathFor((args['path'] as String?)?.trim() ?? '');
    final page = _pageByPath[path];
    if (page == null) {
      final known = _pages.map((p) => p.path).join('\n- ');
      return CallToolResult(
        content: [
          TextContent(text: 'Unknown doc "$path". Available pages:\n- $known'),
        ],
        isError: true,
      );
    }
    return CallToolResult(content: [TextContent(text: page.markdown)]);
  }
}
