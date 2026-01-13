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

Este módulo contém a reestruturação completa do fluxo de cadastro de usuários, com foco em segurança, clareza de uso e arquitetura bem definida.

### Alterações realizadas

- Refatoração da Register Screen, separando responsabilidades em widgets distintos:
  - `RegisterHeader`
  - `RegisterForm`
  - `RegisterAlert`
  - `RegisterFooter`
- Implementação de gerenciamento de estado com `ChangeNotifier` no `RegisterController`, garantindo atualização em tempo real da interface.
- Criação de um fluxo de registro em duas etapas:
  - Envio de e-mail de verificação.
  - Liberação dos campos de senha somente após o e-mail ser confirmado.
- Bloqueio automático do campo de e-mail após o primeiro envio de verificação para evitar inconsistências.
- Indicador inline abaixo do campo de e-mail:
  - “Aguardando verificação do usuário...” com reticências animadas.
  - “E-mail verificado.” após confirmação.
- Implementação de proteção contra spam no botão de reenviar verificação:
  - Temporizador regressivo.
  - Botão desativado até o tempo de espera finalizar.
- Ação **“Não é esse e-mail?”**:
  - Remove a conta temporária criada no Firebase.
  - Libera a edição do e-mail e reinicia o fluxo de verificação.
- Ocultação inteligente de elementos durante o fluxo:
  - Botões Google e Apple são ocultados enquanto o usuário aguarda a verificação de e-mail.
  - O `RegisterFooter` é ocultado durante a verificação e também após o e-mail ser validado.
- Habilitação em tempo real do botão **Criar conta** quando:
  - A senha e a confirmação são iguais.
  - A senha é classificada como forte.
  - O e-mail já está verificado.
- Criação de alerta animado (`RegisterAlert`) para feedback de erros e estados importantes.
- Padronização e tradução das mensagens de erro retornadas pelo Firebase para português.

### Objetivo das melhorias

- Reduzir erros e fraudes no processo de cadastro.
- Garantir um fluxo de registro mais seguro e orientado.
- Melhorar a clareza da interface e a experiência do usuário.
- Facilitar manutenção e evolução do módulo.

---

## Estruturação do módulo de Escolha de Autenticação (`AuthChoiceScreen`)

Este módulo centraliza a escolha do usuário entre Login e Registro, oferecendo uma interface moderna e alinhada com o restante do aplicativo.

### Alterações realizadas

- Criação da `AuthChoiceScreen` com **PageView de banners** rotativos e indicadores animados.
- Implementação de **rodapé transparente com efeito blur**, inspirado no estilo Apple, contendo os botões de Login e Registro.
- Animação suave de entrada do rodapé e interação animada nos botões (`AnimatedButton`).
- Ajustes finos de espaçamentos, paddings e dimensões do header, banners e botões.
- Uso de **tipografia moderna** via Google Fonts (`Inter`) e gradientes sutis nos botões.
- Preparação da arquitetura para futuras integrações com autenticação via redes sociais.
- Ajustes no fluxo de saída e retorno ao `ProfileScreen`.

### Objetivo das melhorias

- Oferecer uma tela inicial elegante, clara e intuitiva.
- Garantir consistência visual e sensação de produto premium.
- Facilitar a manutenção e evolução do fluxo de autenticação.
