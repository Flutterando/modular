class AppState {
  static int mainStateId = 0;

  get stateId => mainStateId;

  AppState() {
    mainStateId++;
  }
}
