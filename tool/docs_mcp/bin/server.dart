// Entry point: runs the flutter_modular docs MCP server over stdio.
//
//   dart run bin/server.dart
//
// Add it to an MCP client (Claude Code, Cursor, ...) — see README.md.

import 'dart:io' as io;

import 'package:dart_mcp/stdio.dart';
import 'package:flutter_modular_docs_mcp/src/server.dart';

void main() {
  ModularDocsServer(stdioChannel(input: io.stdin, output: io.stdout));
}
