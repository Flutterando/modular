class AppState {
  static int mainStateId = 0;

  int get stateId => mainStateId;

  AppState() {
    mainStateId++;
  }
}
