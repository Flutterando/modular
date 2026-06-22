# flutter_modular docs MCP server

An [MCP](https://modelcontextprotocol.io) **server** that serves the
flutter_modular documentation to AI clients (Claude Code, Claude Desktop,
Cursor, …). Ask your assistant a question about flutter_modular and it can
search and read the docs instead of guessing.

It exposes:

- **Tool `search_docs`** — keyword search (BM25, with a title/heading boost)
  over heading-delimited doc sections. Returns the best matches with their page,
  heading, `modular-docs://` resource URI and a snippet.
- **Tool `read_doc`** — returns a full page's markdown by path
  (`flutter_modular/start.md`) or resource URI.
- **Resources** — one `modular-docs:///<path>` resource per doc page
  (`text/markdown`), so clients can list and read pages directly.

The documentation is **embedded** into the server at build time (see below), so
the binary is self-contained — no filesystem access at run time.

## Layout

```
tool/docs_mcp/
  bin/server.dart          # stdio entry point
  bin/build_index.dart     # regenerates the embedded docs index
  lib/src/server.dart      # ModularDocsServer (search_docs, read_doc, resources)
  lib/src/search_index.dart# BM25-lite keyword index
  lib/src/doc_chunk.dart   # DocPage / DocChunk models
  lib/src/generated/docs_data.g.dart  # GENERATED embedded docs
```

## Run

```sh
cd tool/docs_mcp
dart pub get
dart run bin/server.dart      # speaks MCP over stdio
```

## Regenerate the embedded docs

After editing anything under `doc/docs`, rebuild the index:

```sh
cd tool/docs_mcp
dart run bin/build_index.dart       # walks ../../doc/docs by default
```

Scope: `doc/docs/intro.md`, `doc/docs/platforms.md` and
`doc/docs/flutter_modular/**` (the v5/v6 `legacy/` pages and the deprecated
`shelf_modular/` section are excluded).

## Connect a client

The server talks MCP over stdio, so any MCP client launches it as a command.
Both options below embed the docs, so they work from any directory.

### Option A — install from pub.dev (recommended)

```sh
dart pub global activate flutter_modular_docs_mcp
```

Then (with `~/.pub-cache/bin` on your `PATH`):

```json
{
  "mcpServers": {
    "flutter_modular_docs": { "command": "flutter_modular_docs_mcp" }
  }
}
```

To work from a local checkout instead of pub.dev, use
`dart pub global activate --source path tool/docs_mcp`.

### Option B — compile a self-contained executable

```sh
cd tool/docs_mcp
dart compile exe bin/server.dart -o build/flutter_modular_docs_mcp
```

```json
{
  "mcpServers": {
    "flutter_modular_docs": {
      "command": "/absolute/path/to/tool/docs_mcp/build/flutter_modular_docs_mcp"
    }
  }
}
```

> `dart run bin/server.dart` also works, but only when the client launches it
> with its working directory set to `tool/docs_mcp` (not all clients allow
> that), so prefer Option A or B.

## Maintainers

Publishing a new version (update docs → regenerate → bump → publish) is
documented in [CLAUDE.md](CLAUDE.md).

## Test

```sh
cd tool/docs_mcp
dart test        # search ranking + an in-memory client↔server round-trip
```
