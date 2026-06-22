import 'package:flutter_modular_docs_mcp/src/doc_chunk.dart';
import 'package:flutter_modular_docs_mcp/src/generated/docs_data.g.dart';
import 'package:flutter_modular_docs_mcp/src/search_index.dart';
import 'package:test/test.dart';

const _guards = DocChunk(
  pagePath: 'flutter_modular/navegation.md',
  pageTitle: 'Navigation',
  heading: 'Route guards',
  anchor: 'route-guards',
  text: '## Route guards\nA guard protects a route and can redirect the user '
      'before the page is shown.',
);

const _install = DocChunk(
  pagePath: 'flutter_modular/start.md',
  pageTitle: 'Start',
  heading: 'Install',
  anchor: 'install',
  text: '## Install\nAdd the flutter_modular dependency to your pubspec file.',
);

const _outlet = DocChunk(
  pagePath: 'flutter_modular/widgets.md',
  pageTitle: 'Widgets',
  heading: 'RouterOutlet',
  anchor: 'routeroutlet',
  text: '## RouterOutlet\nRouterOutlet renders nested routes inside a '
      'persistent shell.',
);

// A chunk that mentions "guards" only in its body, not its heading — used to
// check the heading boost.
const _guardMention = DocChunk(
  pagePath: 'flutter_modular/module.md',
  pageTitle: 'Module',
  heading: 'Lifecycle',
  anchor: 'lifecycle',
  text: '## Lifecycle\nA module dies with its last page; guards are unrelated '
      'here.',
);

void main() {
  final index = SearchIndex(const [_guards, _install, _outlet, _guardMention]);

  test('ranks the most relevant section first', () {
    expect(index.search('route guard').first.chunk, same(_guards));
    expect(index.search('RouterOutlet').first.chunk, same(_outlet));
    expect(index.search('install dependency pubspec').first.chunk,
        same(_install));
  });

  test('boosts a match in the heading over a body-only match', () {
    // "guards" is in _guards' heading (boosted) but only in _guardMention's
    // body, so _guards must rank higher.
    final hits = index.search('guards');
    expect(hits.map((h) => h.chunk), containsAll(<DocChunk>[_guards, _guardMention]));
    expect(hits.first.chunk, same(_guards));
    final guardScore = hits.firstWhere((h) => h.chunk == _guards).score;
    final mentionScore = hits.firstWhere((h) => h.chunk == _guardMention).score;
    expect(guardScore, greaterThan(mentionScore));
  });

  test('returns a snippet around the matched term', () {
    final hit = index.search('redirect').first;
    expect(hit.snippet.toLowerCase(), contains('redirect'));
  });

  test('empty or unmatched queries return no hits', () {
    expect(index.search(''), isEmpty);
    expect(index.search('zzzznotapresentterm'), isEmpty);
  });

  test('respects the limit', () {
    // The query matches three chunks; the limit caps the result list.
    expect(index.search('route guards module page install', limit: 2).length, 2);
    expect(index.search('route guards module page install').length, 3);
  });

  test('the embedded index is populated and searchable', () {
    expect(docChunks, isNotEmpty);
    final embedded = SearchIndex(docChunks);
    expect(embedded.search('module').isNotEmpty, isTrue);
    expect(embedded.search('route').isNotEmpty, isTrue);
  });
}
