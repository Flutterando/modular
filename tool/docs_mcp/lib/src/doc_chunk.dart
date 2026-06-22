// Data models for the indexed flutter_modular documentation.
//
// A [DocPage] is a whole documentation file (exposed as an MCP resource and by
// the `read_doc` tool). A [DocChunk] is one heading-delimited section of a page
// (the unit the search index ranks over). Both are `const`-constructible so the
// generated index (`generated/docs_data.g.dart`) can embed them directly.

/// A whole documentation page.
class DocPage {
  const DocPage({
    required this.path,
    required this.title,
    required this.markdown,
  });

  /// Repo-relative POSIX path under `doc/docs`, e.g. `flutter_modular/start.md`.
  final String path;

  /// Human title (the page's first `#` heading), e.g. `Start`.
  final String title;

  /// Full page markdown (front matter stripped).
  final String markdown;
}

/// One heading-delimited section of a [DocPage] — the search unit.
class DocChunk {
  const DocChunk({
    required this.pagePath,
    required this.pageTitle,
    required this.heading,
    required this.anchor,
    required this.text,
  });

  /// Path of the owning page (matches a [DocPage.path]).
  final String pagePath;

  /// Title of the owning page.
  final String pageTitle;

  /// The `##`/`###` heading of this section, or `''` for the lead section.
  final String heading;

  /// Slugified [heading] (a `#anchor` into the page), or `''` for the lead.
  final String anchor;

  /// The section's markdown (includes its heading line).
  final String text;
}
