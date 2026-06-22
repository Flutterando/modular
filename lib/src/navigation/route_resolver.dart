/// Resolves a possibly-relative route [reference] against the [current]
/// location, treating the current route as a DIRECTORY — Modular's relative
/// routes:
///
///  - absolute (`/products`)            → used as-is, [current] ignored;
///  - bare or dot (`dashboard`,         → appended UNDER [current]: from
///    `./dashboard`)                       `/home` both give `/home/dashboard`;
///  - parent (`../settings`)            → climbs one level: from `/home`
///                                          gives `/settings`.
///
/// Query and fragment on the [reference] are preserved (`item?ref=x`).
///
/// This improves on 6.x's raw `Uri.resolve`, which treats `/home` as a FILE and
/// so turns `dashboard` into `/dashboard` (dropping `home`) — surprising when
/// you only meant to go one level deeper. We append a trailing slash to
/// [current] first, so relative references resolve as "inside" it.
Uri resolveRoute(String reference, Uri current) {
  final ref = Uri.parse(reference);
  // Absolute path reference (`/x`): ignore where we are.
  if (ref.hasAbsolutePath) return ref;
  // Treat the current location as a directory, then RFC-resolve against it.
  final dir = current.path.endsWith('/') ? current.path : '${current.path}/';
  return Uri(path: dir).resolveUri(ref);
}
