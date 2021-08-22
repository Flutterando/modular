void Function(dynamic bind)? disposeResolverFunc;

setDisposeResolver(void Function(dynamic bind) fn) {
  disposeResolverFunc = fn;
}

void Function(String text)? printResolverFunc;

setPrintResolver(void Function(String text) fn) {
  printResolverFunc = fn;
}
