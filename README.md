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

Este módulo implementa um fluxo de cadastro em duas etapas, projetado para garantir integridade dos dados, segurança de autenticação e uma experiência de uso clara e guiada.

### Alterações realizadas

- Refatoração completa da tela de registro, separando responsabilidades em widgets especializados:
  - `RegisterHeader`
  - `RegisterForm`
  - `RegisterAlert`
  - `RegisterFooter`

- Implementação de gerenciamento de estado via `ChangeNotifier` no `RegisterController`, garantindo atualização reativa da interface.

- Criação de um fluxo de cadastro em duas etapas:
  - Envio de e-mail de verificação com criação de uma conta temporária no Firebase.
  - Liberação dos campos de senha apenas após o e-mail ser confirmado.

- Persistência automática do cadastro pendente:
  - O e-mail e a senha temporária são armazenados localmente (`SharedPreferences`).
  - Ao reabrir o app, o fluxo é restaurado sem perda de contexto.

- Bloqueio automático do campo de e-mail após o envio da verificação, impedindo alterações que poderiam invalidar o processo.

- Indicador de status inline abaixo do campo de e-mail:
  - “Aguardando verificação do usuário...” com reticências animadas.
  - “E-mail verificado.” assim que o Firebase confirma a validação.

- Proteção contra abuso no reenvio de verificação:
  - Temporizador regressivo visível.
  - Botão de reenviar automaticamente desativado até o tempo expirar.

- Ação **“Não é esse e-mail?”**:
  - Exclui a conta temporária no Firebase.
  - Limpa os dados persistidos.
  - Libera a edição do e-mail e reinicia o fluxo.

- Ação **“Excluir cadastro”** após o e-mail ser verificado:
  - Remove completamente a conta temporária.
  - Retorna o usuário à tela `AuthChoiceScreen`.

- Ocultação contextual de elementos da interface:
  - Botões Google e Apple são ocultados enquanto o usuário aguarda a verificação.
  - O `RegisterFooter` não aparece durante a verificação nem após a confirmação do e-mail.

- Habilitação em tempo real do botão **Criar conta** somente quando:
  - O e-mail está verificado.
  - A senha e a confirmação são iguais.
  - A senha atinge nível **forte** de segurança.

- Sistema de feedback visual (`RegisterAlert`) com animações para erros e estados relevantes.

- Padronização e tradução das mensagens do Firebase para português.

### Objetivo das melhorias

- Evitar contas inválidas ou e-mails incorretos.
- Garantir que apenas usuários com e-mail confirmado concluam o cadastro.
- Tornar o fluxo resiliente a fechamento do app ou reinício do sistema.
- Oferecer uma experiência clara, segura e profissional.
- Facilitar manutenção, auditoria e evolução do módulo.

---

## Estruturação do módulo de Escolha de Autenticação (`AuthChoiceScreen`)

Este módulo centraliza a escolha do usuário entre Login e Registro, oferecendo uma interface moderna, clara e alinhada com o restante do aplicativo.

### Alterações realizadas

- Criação da `AuthChoiceScreen` com **PageView de banners** rotativos e indicadores animados.
- Implementação de **rodapé transparente com efeito blur**, inspirado no estilo Apple, contendo os botões de Login e Registro.
- Animação suave de entrada do rodapé e interação animada nos botões (`AnimatedButton`).
- Ajustes finos de espaçamentos, paddings e dimensões de header, banners e botões.
- Uso de **tipografia moderna** via Google Fonts (`Inter`) e gradientes sutis.
- Preparação da arquitetura para futuras integrações de autenticação social.
- Ajustes no fluxo de retorno ao `ProfileScreen`.

### Objetivo das melhorias

- Oferecer uma tela inicial elegante e intuitiva.
- Garantir consistência visual e sensação de produto premium.
- Centralizar e simplificar o fluxo de autenticação.
- Facilitar a manutenção e expansão do sistema de login e cadastro.
