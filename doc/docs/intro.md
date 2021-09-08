---
sidebar_position: 1
---

# Welcome to Modular

Vamos descobrir como implementar uma estrutura Modular em seu projeto.

## O que é o Modular?

O Modular se propõem a resolver dois problemas:
- Rotas modularizadas.
- Injeção de Dependências modularizadas.

Em um cenário monolítico, onde temos toda a nossa aplicação como um único módulo, concebemos nosso software de forma rápida e
elegante aproveitando todos os incríveis recursos do Flutter💙. Porém, produzir um app com um porte maior de forma "monolítica"
pode gerar débito técnicos tanto na parte de manutenção quanto na escalabilidade. Pensando nisso, os desenvolvedores adotaram estratégias arquiteturais para dividir melhor o código, minimizando os impactos negativos na manutenabilidade e escalabilidade do projeto.

Ao dividir melhor o escopo das features ganhamos:

- Melhora no entendimento das features.
- Menos break changes (Modificações que quebram outras partes do código).
- Adicionar novas features não conflitantes.
- Menos pontos cegos na regra de negócio principal do projeto
- Melhor rotatividade de desenvolvedores.

Com o código mais legível, prolongamos a vida do projeto. Veja o exemplo de um MVC padrão com 3 features(Auth, Home, Product):

### A typical MVC

    .
    ├── models                                  # All models      
    │   ├── auth_model.dart                     
    │   ├── home_model.dart                     
    │   └── product_model.dart         
    ├── controller                              # All controllers
    │   ├── auth_controller.dart                     
    │   ├── home_controller.dart                     
    │   └── product_controller.dart             
    ├── views                                   # All views
    │   ├── auth_page.dart                     
    │   ├── home_page.dart                     
    │   └── product_page.dart                   
    ├── core                                    # Tools and utilities
    ├── app_widget.dart                         # Main Widget containing MaterialApp 
    └── main.dart                               # runApp 


Aqui temos uma estrutura padrão usando MVC. Isso é incrivelmente útil em quase todas as aplicações.

Vejamos como fica a estrutura quando dividimos por escopo: 


### Structure divided by scope

    .                  
    ├── features                                # All features or Modules 
    ├─── auth                                  # Auth's MVC       
    │     ├── auth_model.dart   
    │     ├── auth_controller.dart  
    │     └── auth_page.dart                      
    ├──── home                                  # Home's MVC       
    │     ├── home_model.dart   
    │     ├── home_controller.dart  
    │     └── home_page.dart                        
    ├──── product                               # Product's MVC     
    │     ├── product_model.dart   
    │     ├── product_controller.dart
    │     └── product_page.dart                    
    ├── core                                    # Tools and utilities
    ├── app_widget.dart                         # Main Widget containing MaterialApp 
    └── main.dart                               # runApp 



O que fizemos nessa estrutura foi continuar usando o MVC, mas dessa vez de forma escopada. Isso significa que
cada feature tem seu próprio MVC, e essa simples abordagem resolve muitos problemas de escalabilidade e manutenabilidade.
Chamamos essa abordagem de "Estrutura Inteligente". Ainda existiam duas coisas que ficavam Globais e isso destoava da estrutura em sí e então criamos o Modular para resolver esse impasse.

Resumindo: O Modular é uma solução para modularizar o sistema de injeção de dependências e rotas, fazendo com que cada escopo tenha
suas proprias rotas e injeções independente de qualquer outro fator da estrutura.
Criamos um objeto para agrupar as Rotas e Injeções e chamamos de **Módulos**.



## Pronto para começar?

Modular não é só engenhoso por fazer algo incrível como componentizar Rotas e Injeções de Dependências, ele é incrível
por conseguir fazer tudo isso de forma simples!

Siga para o próximo tópico e inicie sua jornada rumo a uma estrutura inteligente.

## Perguntas frequentes

- O Modular trabalha com qualquer abordage de gerência de estado?
    - Sim, o sistema de injeção de dependências é agnóstico a qualquer tipo de classe
    inclusive das reatividades que compõem as gerência de estado.

- Posso usar rotas dinâmicas ou Wildcards?
    - Sim! Toda a árvore de rotas responde como na Web. Portando, você pode usar parametros dinâmicos,
    query, fragments ou simplesmente incluir um coringa como wildcard para possibilitar um redirecionamento
    para uma página 404 por exemplo.

- Preciso criar um Módulo para todas as features?
    - Não. Você pode criar um módulo apenas quando achar necessário ou quando a feature não fizer mais parte
    do escopo em que está sendo trabalhado.


