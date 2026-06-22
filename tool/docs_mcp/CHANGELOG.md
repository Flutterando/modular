# Changelog

## 0.2.0

- Re-embed the documentation rewritten for flutter_modular v7 (the served
  content now matches the v7 API instead of v6).
- Add the new `mcp-server.md` page to the index.
- Exclude the archived `legacy-6/` v6 pages from the index (the scope filter
  only excluded `legacy/` before, so v6 content was leaking into search).

## 0.1.0

- Initial release.
- MCP server serving the flutter_modular documentation over stdio.
- `search_docs` tool: BM25 keyword search over heading-delimited doc sections.
- `read_doc` tool: fetch a full page by path or `modular-docs://` resource URI.
- One MCP resource per documentation page.
- Documentation embedded at build time via `bin/build_index.dart`.
