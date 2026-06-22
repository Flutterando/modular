# CLAUDE.md — flutter_modular_docs_mcp

Maintainer guide for this package: an MCP **server** that serves the
flutter_modular documentation (published to pub.dev as
`flutter_modular_docs_mcp`). User-facing usage lives in `README.md`; this file
is the **release workflow**.

## How the docs get in (read this first)

The docs are **embedded at build time**, not read from disk at run time:

1. `bin/build_index.dart` walks the repo's `doc/docs` (`intro.md`,
   `platforms.md`, `flutter_modular/**`; excludes `legacy/` and
   `shelf_modular/`), chunks each page by heading, and generates
   `lib/src/generated/docs_data.g.dart`.
2. `lib/src/server.dart` imports those `const docPages` / `docChunks`. No
   filesystem access at run time — so the published package and compiled exe are
   self-contained.

**Consequence:** editing `doc/docs` changes nothing until you regenerate. The
generated file is committed and shipped, so consumers never run the generator.

## Smoke-test the server locally (stdio)

The protocol is newline-delimited JSON over stdio. Pipe a handshake + a tool
call in and confirm **every stdout line is valid JSON** (no stray logs):

```sh
printf '%s\n' \
'{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"smoke","version":"0.0.1"}}}' \
'{"jsonrpc":"2.0","method":"notifications/initialized"}' \
'{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"search_docs","arguments":{"query":"router outlet","limit":1}}}' \
| dart run bin/server.dart 2>/dev/null
```

Expect three JSON lines back: `serverInfo` (`flutter_modular_docs`), the tools
list ack, and a `search_docs` result containing a `modular-docs:///` URI.
`2>/dev/null` drops stderr; **stdout must be JSON-only** — any other text means
the stdio stream is polluted and MCP clients will fail to parse it.

## Install locally and wire into Claude Code

```sh
# 1. Compile a clean, self-contained binary to a stable spot on PATH.
#    (Embeds the docs, so it runs from anywhere and needs no `dart`/resolution.)
dart compile exe bin/server.dart -o ~/.local/bin/flutter_modular_docs_mcp

# 2. Register it (stdio; `-s user` => available in every project).
claude mcp add -s user flutter_modular_docs -- ~/.local/bin/flutter_modular_docs_mcp

# 3. Verify the client can connect.
claude mcp get flutter_modular_docs        # Status: ✔ Connected
```

MCP servers load at **session start**, so open a NEW Claude Code session, then
run `/mcp` (or just ask a flutter_modular question) to use `search_docs` /
`read_doc`.

- **Update after a docs change:** regenerate the index (`dart run
  bin/build_index.dart`), then recompile step 1 (the binary snapshots the docs).
- **Remove:** `claude mcp remove flutter_modular_docs -s user`.
- **Do NOT** register `dart pub global activate --source path` for this. Its
  wrapper runs `dart pub global run`, which prints `Resolving dependencies...`
  to **stdout** and corrupts the MCP stream. Use the compiled exe (above), or —
  once published — the hosted `dart pub global activate flutter_modular_docs_mcp`
  (a hosted activation locks resolution at install time, so stdout stays clean).

## Release a new version

Run everything from this directory (`tool/docs_mcp`).

1. **Update the docs** under `../../doc/docs` (the real source of truth).

2. **Regenerate the embedded index:**
   ```sh
   dart run bin/build_index.dart
   ```
   This rewrites `lib/src/generated/docs_data.g.dart`. Expect a diff only when
   the docs actually changed.

3. **Verify:**
   ```sh
   dart analyze       # must be clean
   dart test          # search ranking + in-memory client↔server round-trip
   ```

4. **Bump the version in BOTH places** (they must match — the second is what the
   MCP `initialize` handshake reports as `serverInfo.version`):
   - `pubspec.yaml` → `version:`
   - `lib/src/server.dart` → `const String serverVersion`
   - add a `CHANGELOG.md` entry for the new version.

5. **Commit.** `dart pub publish` refuses a dirty tree and only ships
   git-tracked files, so the package must be committed first:
   ```sh
   git add tool/docs_mcp && git commit -m "chore(docs-mcp): release vX.Y.Z"
   ```

6. **Dry-run** (validates, does NOT publish):
   ```sh
   dart pub publish --dry-run
   ```
   Expect a clean archive (~35 KB) containing `bin/`, `lib/` (incl.
   `generated/docs_data.g.dart`), `LICENSE`, `README.md`, `CHANGELOG.md`,
   `pubspec.yaml`. `test/` is intentionally excluded.

7. **Publish** (irreversible — pub.dev versions are permanent, only retractable):
   ```sh
   dart pub publish
   ```

8. **Consumers update** by re-activating (global-activate snapshots at install
   time; it does not auto-update):
   ```sh
   dart pub global activate flutter_modular_docs_mcp
   ```

## Gotchas

- **Root `.pubignore` must NOT blanket-exclude `tool/`.** `dart pub publish`
  applies the repo-root `.pubignore` to this nested package too; a `tool/` rule
  silently strips every file and the archive comes out empty
  ("the pubspec is hidden…", "LICENSE missing", "bin/server.dart does not
  exist"). The root `.pubignore` only excludes build artifacts under `tool/`.
- **pub.dev is a poor fit for frequently-changing content.** Each doc edit that
  ships is a new immutable version. If churn becomes a problem, reconsider
  git-activate (`--source git ... --git-path tool/docs_mcp`) or a remote HTTP
  MCP instead.
- **The docs currently describe the v6 API, not v7.** `doc/docs/flutter_modular`
  still uses `extends Module` / `Modular.get`, while the v7 README uses
  `createModule` / `context.pushNamed`. Until the docs are rewritten, this
  server serves v6 content. Regenerating only re-embeds whatever is in
  `doc/docs`.

## Layout

```
bin/server.dart          # stdio entry point (the published executable)
bin/build_index.dart     # docs -> generated index
lib/src/server.dart      # ModularDocsServer: search_docs, read_doc, resources
lib/src/search_index.dart# BM25 keyword index
lib/src/doc_chunk.dart   # DocPage / DocChunk models
lib/src/generated/docs_data.g.dart  # GENERATED, committed, shipped
test/                    # not shipped (excluded from the pub archive)
```
