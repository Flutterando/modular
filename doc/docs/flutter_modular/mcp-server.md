---
sidebar_position: 9
---

# Docs MCP server

`flutter_modular_docs_mcp` is an [MCP](https://modelcontextprotocol.io) server that
serves the **most up‑to‑date flutter_modular documentation** to your AI coding
assistant. With it connected, your assistant searches and reads these real docs instead
of guessing — it exposes a `search_docs` tool (keyword search) and a `read_doc` tool
(fetch a full page).

## Install

You need the [Dart SDK](https://dart.dev/get-dart). Activate the server from pub.dev:

```bash
dart pub global activate flutter_modular_docs_mcp
```

Make sure `~/.pub-cache/bin` is on your `PATH` so the `flutter_modular_docs_mcp` command
resolves. Re‑run the same command anytime to update to the latest docs.

## Register it in your assistant

Every MCP client has its own configuration, so instead of documenting each one, **paste
the prompt below into your agentic IDE or harness** (Claude Code, Cursor, Windsurf, VS
Code, Zed, …) and let the agent install and register it for you:

```text
Install and register the flutter_modular docs MCP server for me.

1. Make sure the Dart SDK is available, then run:
     dart pub global activate flutter_modular_docs_mcp
   Ensure ~/.pub-cache/bin is on PATH so the `flutter_modular_docs_mcp` command resolves.

2. Register it as a stdio MCP server in whatever client you are running in
   (Claude Code, Cursor, Windsurf, VS Code, Zed, ...), with:
     name:    flutter_modular_docs
     command: flutter_modular_docs_mcp
     type:    stdio
   Use this client's own mechanism. For example, for Claude Code:
     claude mcp add -s user flutter_modular_docs -- flutter_modular_docs_mcp
   For other clients, edit their MCP config (e.g. mcp.json / settings) accordingly.

3. Start a new session if the client requires it, then verify the server connects
   and that the `search_docs` and `read_doc` tools are available.
```

Once connected, ask your assistant anything about flutter_modular and it will ground its
answers in this documentation.
