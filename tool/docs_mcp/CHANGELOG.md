# Changelog

## 0.1.0

- Initial release.
- MCP server serving the flutter_modular documentation over stdio.
- `search_docs` tool: BM25 keyword search over heading-delimited doc sections.
- `read_doc` tool: fetch a full page by path or `modular-docs://` resource URI.
- One MCP resource per documentation page.
- Documentation embedded at build time via `bin/build_index.dart`.
