// A small, dependency-free keyword search over [DocChunk]s using BM25 ranking
// with a boost for matches in the page title and section heading.

import 'dart:math' as math;

import 'doc_chunk.dart';

/// One ranked search result.
class SearchHit {
  const SearchHit({
    required this.chunk,
    required this.score,
    required this.snippet,
  });

  final DocChunk chunk;
  final double score;

  /// A short, whitespace-collapsed excerpt around the first matched term.
  final String snippet;
}

/// In-memory BM25 index over documentation chunks.
class SearchIndex {
  SearchIndex(List<DocChunk> chunks) : _chunks = List.unmodifiable(chunks) {
    _build();
  }

  final List<DocChunk> _chunks;

  /// term -> number of chunks containing it.
  final Map<String, int> _docFreq = {};

  /// per-chunk weighted term frequencies.
  final List<Map<String, double>> _termFreq = [];

  /// per-chunk weighted length.
  final List<double> _length = [];
  double _avgLength = 0;

  // Field weights: a hit in the heading/title counts for more than the body.
  static const double _bodyWeight = 1;
  static const double _headingWeight = 3;
  static const double _titleWeight = 2;

  // BM25 parameters.
  static const double _k1 = 1.5;
  static const double _b = 0.75;

  static final RegExp _wordRe = RegExp(r'[a-z0-9]+');

  /// Lowercases, splits on non-alphanumerics, drops 1-char tokens.
  static List<String> tokenize(String text) => _wordRe
      .allMatches(text.toLowerCase())
      .map((m) => m[0]!)
      .where((t) => t.length >= 2)
      .toList();

  void _build() {
    var total = 0.0;
    for (final chunk in _chunks) {
      final tf = <String, double>{};
      void absorb(String text, double weight) {
        for (final token in tokenize(text)) {
          tf[token] = (tf[token] ?? 0) + weight;
        }
      }

      absorb(chunk.text, _bodyWeight);
      absorb(chunk.heading, _headingWeight);
      absorb(chunk.pageTitle, _titleWeight);

      _termFreq.add(tf);
      final len = tf.values.fold<double>(0, (a, b) => a + b);
      _length.add(len);
      total += len;
      for (final term in tf.keys) {
        _docFreq[term] = (_docFreq[term] ?? 0) + 1;
      }
    }
    _avgLength = _chunks.isEmpty ? 1 : total / _chunks.length;
  }

  /// Returns up to [limit] chunks ranked by relevance to [query].
  List<SearchHit> search(String query, {int limit = 5}) {
    final terms = tokenize(query).toSet();
    if (terms.isEmpty || _chunks.isEmpty) return const [];

    final n = _chunks.length;
    final avg = _avgLength == 0 ? 1 : _avgLength;
    final scored = <int, double>{};

    for (var i = 0; i < n; i++) {
      final tf = _termFreq[i];
      var score = 0.0;
      for (final term in terms) {
        final f = tf[term];
        if (f == null) continue;
        final df = _docFreq[term] ?? 0;
        // BM25+ idf form, always positive.
        final idf = math.log(1 + (n - df + 0.5) / (df + 0.5));
        final denom = f + _k1 * (1 - _b + _b * (_length[i] / avg));
        score += idf * (f * (_k1 + 1)) / denom;
      }
      if (score > 0) scored[i] = score;
    }

    final ranked = scored.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return [
      for (final entry in ranked.take(limit))
        SearchHit(
          chunk: _chunks[entry.key],
          score: entry.value,
          snippet: _snippet(_chunks[entry.key], terms),
        ),
    ];
  }

  String _snippet(DocChunk chunk, Set<String> terms) {
    final text = chunk.text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.isEmpty) return '';
    final lower = text.toLowerCase();

    var pos = -1;
    for (final term in terms) {
      final p = lower.indexOf(term);
      if (p >= 0 && (pos < 0 || p < pos)) pos = p;
    }
    if (pos < 0) pos = 0;

    final start = math.max(0, pos - 80);
    final end = math.min(text.length, pos + 180);
    var snip = text.substring(start, end);
    if (start > 0) snip = '…$snip';
    if (end < text.length) snip = '$snip…';
    return snip;
  }
}
