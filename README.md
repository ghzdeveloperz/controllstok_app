## Estruturação do módulo de Login

Este módulo concentra toda a lógica de autenticação de usuários já cadastrados, com foco em robustez, clareza de código e experiência consistente em diferentes estados da aplicação.

### Alterações realizadas

- Refatoração da Login Screen, separando responsabilidades em widgets e controllers independentes.
- Implementação de gerenciamento de estado para controle de loading, erros e validações.
- Integração com Firebase Authentication para login por e-mail e senha.
- Suporte a autenticação via Google e Apple.
- Tradução e padronização das mensagens de erro retornadas pelo Firebase.
- Tratamento visual e funcional de estados como:
  - Tentativas inválidas
  - Erros de conexão
  - Credenciais incorretas

### Objetivo das melhorias

- Garantir uma experiência de login previsível e segura.
- Reduzir falhas de autenticação causadas por erros de entrada.
- Facilitar manutenção e evolução do módulo.
- Padronizar o comportamento de autenticação em todo o app.

---

## Estruturação do módulo de Registro

Este módulo implementa um fluxo de cadastro em múltiplas etapas, projetado para garantir integridade dos dados, verificação real de e-mail e continuidade do processo mesmo em casos de fechamento do aplicativo.

### Alterações realizadas

- Reestruturação completa da Register Screen, com separação em widgets especializados:
  - `RegisterHeader`
  - `RegisterForm`
  - `RegisterAlert`
  - `RegisterFooter`

- Implementação de gerenciamento de estado via `RegisterController` e `RegisterState`.

- Criação de um fluxo de registro em duas etapas:
  - Criação de uma conta temporária no Firebase e envio de e-mail de verificação.
  - Definição da senha definitiva somente após a confirmação do e-mail.

- Persistência automática do cadastro em andamento:
  - O e-mail e a senha temporária são salvos em `SharedPreferences`.
  - Ao reabrir o app, o usuário retorna exatamente ao ponto em que parou.

- Bloqueio automático do campo de e-mail após o envio da verificação.

- Indicadores visuais de status:
  - “Aguardando verificação do usuário…” com animação.
  - “E-mail verificado” após confirmação no Firebase.

- Proteção contra abuso no botão de reenviar verificação:
  - Temporizador regressivo.
  - Botão desabilitado até o tempo mínimo ser atingido.

- Ação **“Não é esse e-mail?”**
  - Remove a conta temporária do Firebase.
  - Limpa os dados persistidos.
  - Reinicia o fluxo de cadastro.

- Ação **“Excluir cadastro”** após o e-mail ser validado:
  - Remove completamente a conta temporária.
  - Retorna o usuário à tela `AuthChoiceScreen`.

- Habilitação do botão **Criar conta** apenas quando:
  - O e-mail está confirmado.
  - A senha e a confirmação coincidem.
  - A senha atende ao nível mínimo de segurança.

- Sistema de alerta animado (`RegisterAlert`) para feedbacks de erro e estado.

- Tradução e padronização de todas as mensagens do Firebase.

### Objetivo das melhorias

- Garantir que apenas usuários com e-mail real concluam o cadastro.
- Evitar contas inválidas, abandonadas ou malformadas.
- Permitir retomada segura do cadastro após fechamento do app.
- Tornar o fluxo previsível, auditável e profissional.
- Preparar o sistema para expansão futura (planos, permissões, perfis, etc).

---

## Estruturação do módulo de Onboarding da Empresa (`Company`)

Este módulo representa a **segunda etapa obrigatória** após o cadastro do usuário.  
Nenhum usuário pode acessar o aplicativo enquanto não concluir o cadastro da empresa.

### Alterações realizadas

- Criação de um fluxo dedicado de onboarding após o registro.
- Implementação de `CompanyController` e `CompanyState` para gerenciamento de estado.
- Persistência do status de onboarding no Firestore via campo:
  - `onboardingCompleted`

- Campos estruturados para dados reais de negócio:
  - Razão social (obrigatório)
  - Nome fantasia (controlado por pergunta Sim/Não)
  - Responsável (controlado por pergunta Sim/Não)
  - Telefone / WhatsApp (controlado por pergunta Sim/Não)
  - Tipo de negócio (seleção obrigatória ou texto customizado)

- Sistema de perguntas para campos opcionais:
  - O campo só aparece se o usuário optar por informar.
  - Quando ativado, torna-se obrigatório.

- Tipo de negócio com seleção obrigatória:
  - Nenhum valor é pré-selecionado.
  - Se escolher “Outro”, o usuário informa um tipo customizado.

- Campo “Outro” com regras:
  - Limite de até 20 caracteres.
  - Normalização automática de espaços.

- Inclusão de aceite obrigatório de documentos legais antes de finalizar:
  - Checkbox de **Termos de uso**
  - Checkbox de **Política de privacidade**
  - Abertura dos documentos em **modal interno** (sem sair do onboarding)

- Validações de consistência antes de permitir finalizar:
  - Botão só habilita com campos válidos + tipo de negócio selecionado + aceite legal confirmado.

- Salvamento dos dados no Firestore com `merge`, garantindo compatibilidade futura.

### Objetivo das melhorias

- Garantir que toda conta tenha contexto de negócio.
- Preparar o sistema para relatórios, permissões e planos.
- Evitar usuários “vazios” dentro da base.
- Reforçar conformidade e credibilidade com aceite de termos e privacidade.
- Tornar o app utilizável apenas após configuração mínima válida.

---

## Estruturação do AuthGate (orquestração do fluxo)

O `AuthGate` é o cérebro do fluxo de autenticação e onboarding.

Ele decide, em tempo real, qual tela o usuário deve ver.

### Regras de navegação implementadas

1. Se não estiver logado → `AuthChoiceScreen`
2. Se existir registro pendente (`SharedPreferences`) → `RegisterScreen`
3. Se estiver logado, mas `onboardingCompleted == false` → `CompanyScreen`
4. Se tudo estiver completo → `HomeScreen`

Essas regras são reavaliadas a cada mudança de autenticação ou Firestore.

### Objetivo

- Impedir acessos fora de ordem.
- Garantir continuidade do fluxo.
- Evitar estados quebrados ou inconsistentes.
- Manter o app resiliente a fechamento forçado, crash ou perda de conexão.

## arquivo dart buttons svgs
- Goole
- Apple

## Objetivo das melhorias
- estilização dos buttons

## [Milestone 01] Navegação do usuário para home
**Status:** em andamento...  

### Melhorias:
- Navega certo quando clica em botão do google e email no `Cadastro`

### Obejtivo:
- Navega certo quando clica em botão do google e email no `Cadastro`
- Navega certo quando clica em botão do google e email no `Login`
- Quando navegar, quero que carregue primeiramente tudo do usuário com loading antes de entrar