///Function to print the resolver
void Function(String text)? printResolverFunc;
///Set the print resolver, receives the function and sets this function
///inside [printResolverFunc]
void setPrintResolver(void Function(String text) fn) {
  printResolverFunc = fn;
}
