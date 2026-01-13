## Estruturação do módulo de Login

Este repositório contém a reestruturação completa da tela de Login, com foco em organização de código, manutenibilidade e experiência do usuário.

### Alterações realizadas

- Refatoração da Login Screen, separando responsabilidades em arquivos e widgets distintos.
- Implementação de gerenciamento de estado utilizando Provider.
- Adição de autenticação via Google e Apple.
- Ajustes na interface para um visual mais limpo e moderno.
- Tradução e tratamento das mensagens de erro retornadas pelo Firebase para português.

### Objetivo das melhorias

- Facilitar a manutenção e evolução do código.
- Melhorar a legibilidade e a organização do projeto.
- Oferecer uma experiência de login mais clara e amigável para o usuário final.

---

## Estruturação do módulo de Registro

Este repositório contém a reestruturação completa da tela de Registro, com foco em organização de código, manutenibilidade e experiência do usuário.

### Alterações realizadas

- Refatoração da Register Screen, separando responsabilidades em widgets distintos:
  - `RegisterHeader`
  - `RegisterForm`
  - `RegisterAlert`
  - `RegisterFooter`
- Implementação de gerenciamento de estado com `ChangeNotifier` no `RegisterController`.
- Adição de placeholders para integração futura de registro via Google e Apple.
- Criação de alerta animado (`RegisterAlert`) com entrada e saída suaves.
- Ajustes visuais para manter consistência com a tela de Login (tipografia, cores, espaçamento e alinhamento).
- Padronização e tradução das mensagens de erro para português.

### Objetivo das melhorias

- Facilitar a manutenção e evolução do código.
- Melhorar a legibilidade e a organização do projeto.
- Oferecer uma experiência de registro clara, amigável e consistente com o fluxo de Login.

---

## Estruturação do módulo de Escolha de Autenticação (`AuthChoiceScreen`)

Este módulo centraliza a escolha do usuário entre Login e Registro, oferecendo uma interface moderna e responsiva com banners e rodapé premium.

### Alterações realizadas

- Criação da `AuthChoiceScreen` com **PageView de banners** rotativos e indicadores animados.
- Implementação de **rodapé transparente e com efeito blur**, inspirado no estilo Apple, contendo os botões de Login e Registro.
- Animação suave de entrada do rodapé e interação animada nos botões (`AnimatedButton`).
- Ajuste de espaçamentos, paddings e dimensões do header, banners e botões para reduzir espaço excessivo e melhorar a visualização.
- Uso de **tipografia moderna** via Google Fonts (`Inter`) e gradientes sutis nos botões.
- Preparação para futuras integrações com autenticação via redes sociais.
- ajuste de saida em perfilscrren

### Objetivo das melhorias

- Oferecer uma **tela inicial elegante e intuitiva**, destacando banners promocionais ou informativos.
- Garantir **consistência visual e experiência premium**, alinhada com Login e Registro.
- Facilitar manutenção e evolução da tela central de escolha de autenticação.
