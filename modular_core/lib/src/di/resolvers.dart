void Function(dynamic bind)? disposeResolverFunc;

setDisposeResolver(void Function(dynamic bind) fn) {
  disposeResolverFunc = fn;
}

void Function(String text)? printResolverFunc;

setPrintResolver(void Function(dynamic bind) fn) {
  printResolverFunc = fn;
}
