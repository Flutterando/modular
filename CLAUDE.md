# CLAUDE.md — flutter_modular

Guia rápido para trabalhar neste repositório. Explicações simples + o que fazer
e o que **não** fazer. Leia antes de mexer no código ou na documentação.

## O que é este projeto

`flutter_modular` é um pacote Flutter de **injeção de dependência + gerência de
rotas**, com **estado escopo-de-página** (page-scoped). A versão atual é a **v7**,
uma reescrita do zero (branch `v7`).

> Era um monorepo (melos). Agora é **um único pacote** na raiz. `modular_core` foi
> achatado para dentro de `flutter_modular`, e `shelf_modular` está sendo
> descontinuado.

## Estrutura do repositório

```
lib/                 # o pacote flutter_modular v7 (código publicado)
  flutter_modular.dart   # exports públicos
  src/{app,module,navigation,route,state}/
test/                # testes do pacote (flutter test)
example/             # app de demonstração (rotas aninhadas, guards, DI, etc.)
doc/                 # site de documentação (Docusaurus 3.10) — NÃO é o pacote
  docs/                  # markdown das docs (fonte da verdade do conteúdo)
tool/docs_mcp/       # servidor MCP em Dart que SERVE as docs (pacote pub.dev separado)
art/                 # identidade visual (logo Modular)
```

## API v7 (use estes idiomas — não os da v6)

```dart
// Módulo = DI + rotas, declarado de forma funcional:
final appModule = createModule(register: (c) {
  c
    ..addSingleton<Counter>(Counter.new)
    ..route('/', child: (ctx, state) => const HomePage())
    ..route('/details/:id', child: (ctx, state) => DetailsPage(id: state.params['id']!))
    ..module('/admin', module: adminModule);
});

// Bootstrap (ModularApp acima do MaterialApp):
ModularApp(module: appModule, child: AppRoot());
MaterialApp.router(routerConfig: ModularApp.routerConfigOf(context));

// Navegação:
context.pushNamed('/details/42'); // empilha página (push NÃO entra na URL)
context.navigate('/');            // troca a stack (dona da URL, reseta histórico)
context.pop(result);              // volta entregando resultado ao pushNamed

// Estado page-scoped (criado e descartado junto com a rota):
c.route('/counter',
  provide: (s) => s.addChangeNotifier<CounterVM>(CounterVM.new),
  child: (ctx, state) => const CounterPage());
final vm = context.watch<CounterVM>(); // rebuild quando notifica
```

Modelo de rotas v7: a **URL representa a base da stack** (push não aparece na
URL); rotas são **relativas** (semântica de diretório); deep-link entra via
`defaultRouteName`; `navigatorKey`/`observers` ficam no `ModularApp`.

## Comandos comuns

```sh
# Pacote (raiz):
flutter test                 # roda os testes
flutter analyze              # lint (usa flutterando_analysis)

# Exemplo:
cd example && flutter run

# Site de docs (Docusaurus):
cd doc && yarn install && yarn start   # dev em http://localhost:3000
cd doc && yarn build                   # build de produção

# Servidor MCP de docs:
cd tool/docs_mcp && dart test          # testes do servidor
```

## ✅ Faça (DO)

- Use a **API v7** (acima). Confira `README.md`, `lib/` e `example/` como fonte
  da verdade da API.
- Rode `flutter test` e `flutter analyze` antes de concluir uma mudança no pacote.
- Siga **Conventional Commits** (`feat:`, `fix:`, `docs:`, `chore:` …) — veja
  `CONTRIBUTING.md`.
- Mantenha o pacote raiz enxuto: só `lib/` (mais os metadados) vai para o pub.dev.
- Para o fluxo de release do MCP, siga o passo a passo em
  [`tool/docs_mcp/CLAUDE.md`](tool/docs_mcp/CLAUDE.md).

## ❌ Não faça (DON'T)

- **Não** use a API da v6 (`extends Module`, `Modular.get`, `Modular.to.push`).
  É a v7 agora.
- **Não** conserte os testes do `shelf_modular` — ele está sendo descontinuado.
- **Não** confie nas docs em `doc/docs/flutter_modular/**` para a API: o prosa
  ainda descreve a **v6** e contradiz o README v7. Ao escrever docs novas, use a
  API v7.
- **Não** edite `tool/docs_mcp/lib/src/generated/docs_data.g.dart` à mão — é
  gerado (veja lembrete abaixo).
- **Não** faça blanket-exclude de `tool/` no `.pubignore` da raiz (veja gotcha).

## ⚠️ Lembretes importantes (tipo)

**Mexeu na documentação → rebuilde o MCP e republique.** As docs ficam
**embutidas em build time** dentro do servidor MCP. Editar `doc/docs` **não muda
nada** até regenerar o índice. Sempre que adicionar/alterar conteúdo em
`doc/docs`:

1. Regenere o índice embutido:
   ```sh
   cd tool/docs_mcp && dart run bin/build_index.dart
   ```
   (varre `doc/docs`: `intro.md`, `platforms.md`, `flutter_modular/**`; ignora
   `legacy*/` e `shelf_modular/`). Isso reescreve `lib/src/generated/docs_data.g.dart`.
2. Verifique: `dart analyze` e `dart test` (ambos limpos).
3. **Bump de versão em DOIS lugares** (precisam bater): `pubspec.yaml` → `version:`
   e `lib/src/server.dart` → `const String serverVersion`; adicione entrada no
   `CHANGELOG.md`.
4. Commit (o `dart pub publish` só envia arquivos versionados no git).
5. `dart pub publish --dry-run` → depois `dart pub publish`.
6. Recompile o binário local para o Claude Code pegar o conteúdo novo:
   ```sh
   dart compile exe bin/server.dart -o ~/.local/bin/flutter_modular_docs_mcp
   ```
   (MCP carrega no início da sessão — abra uma sessão nova do Claude Code.)

Passo a passo completo: [`tool/docs_mcp/CLAUDE.md`](tool/docs_mcp/CLAUDE.md).

**Gotcha do `.pubignore`.** `dart pub publish` aplica o `.pubignore` da **raiz**
também aos pacotes aninhados (`tool/docs_mcp`). Se a raiz fizer blanket-exclude de
`tool/`, o publish do `flutter_modular_docs_mcp` sai com o archive **vazio**
("the pubspec is hidden", "LICENSE missing", "bin/server.dart does not exist").
Exclua apenas artefatos de build sob `tool/` (`tool/**/.dart_tool/`,
`tool/**/build/`), não a pasta inteira.

**Os docs estão atrasados (v6).** A reescrita da prosa de `doc/docs` para a API
v7 é trabalho em aberto. Até lá, o MCP serve conteúdo v6 — regenerar só re-embute
o que estiver em `doc/docs`.
