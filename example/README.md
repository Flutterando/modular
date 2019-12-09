# Modular

Estrutura de projeto inteligente e organizada.

## Aviso

** ESTE PROJETO ESTÁ EM DESENVOLVIMENTO E NÃO RECOMENDAMOS O USO EM PRODUÇÃO. ACOMPANHE OS LANÇAMENTOS E AJUDE A CONTRIBUIR COM O PROJETO;


## O que é o Modular?

Quando um projeto vai ficando grande e complexo, acabamos juntando muitos arquivos em um só lugar, isso dificulta a manutenção do código e também o reaproveitamento.
O Modular nós trás várias soluções adaptadas para o Flutter como Injeção de Dependências, Controle de Rotas e o Sistema de "Singleton Disposáveis" que é quando o provedor do código se encarrega de "chamar" o dispose automaticamente e limpar a injeção (prática muito comum no package bloc_pattern).
O Modular vem preparado para adaptar qualquer gerência de estado ao seu sistema de Injeção de Dependências inteligente, gerenciando a memória do seu aplicativo.

## Qual a diferença entre o Modular e o bloc_pattern;

Aprendemos muito com o bloc_pattern, e entendemos que a comunidade tem diversas preferências com relação a Gerência de Estado, então, até mesmo por uma questão de nomeclatura, decidimos tratar o Modular como uma evolução natural do bloc_pattern, a partir dai implementar o sistema de Rotas Dinâmicas que ficará muito popular graças ao Flutter Web. Rotas nomeadas são o futuro do Flutter, e estamos preparando para isso.

## O bloc_pattern será depreciado?

Não! Continuaremos a dar suporte e melhora-lo. Apesar que a migração para o Modular será muito simples também.

## Estrutura Modular

O Modular nos tras uma estrutura que nos permite gerenciar a injeção de dependencia e as rotas em apenas um arquivo por módulo, com isso podemos organizar nossos arquivos pensando nisso. Quando todos as paginas, controllers, blocs (e etc..) estiverem em uma pasta e reconhecido por esse arquivo principal, a isso damos o nome de módulo, pois nos propocionará fácil manutenabilidade e principalmente o desacoplamento TOTAL do código para reaproveitamento em outros projetos.

## Pilares do Modular

Aqui estão nossos focos principais com o package.

- Gerência Automática de Memória.
- Injeção de Dependência.
- Controle de Rotas Dinâmicas.
- Modularização de Código.


# Começando com o Modular

## Instalação

Abra o pubspec.yaml do seu Projeto e digite:

```
dependencies:
    modular:
```
ou instale diretamente pelo Git para testar as novas funcionalidades e correções:

```
dependencies:
    modular:
        git:
            url: https://github.com/Flutterando/modular
```

## Usando em um novo projeto

Você precisa fazer algumas configurações iniciais.

- Crie um arquivo para ser seu módulo principal:

```dart




```

