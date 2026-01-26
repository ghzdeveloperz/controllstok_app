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
**Status:** Concluido ✅  

### Melhorias:
- Navega certo quando clica em botão do google e email no `Cadastro`
- Navega certo quando clica em botão do google e email no `Login`
- Quando navegar, carregue primeiramente tudo do usuário com loading antes de entrar (Modal de Loading `blocking_loader` para pré-carregar informações)


### Obejtivo:
- Navega certo quando clica em botão do google e email no `Cadastro`
- Navega certo quando clica em botão do google e email no `Login`
- Quando navegar, carregue primeiramente tudo do usuário com loading antes de entrar (Modal de Loading `blocking_loader` para pré-carregar informações)

## [Milestone 02] Internacionalização automática (i18n)

**Status:** Concluído ✅

### Melhorias
- Implementado sistema oficial de **internacionalização (i18n)** do Flutter
- Tradução automática baseada no **idioma do sistema**, sem solicitar permissão de localização
- Suporte a múltiplos idiomas:
  - 🇧🇷 Português (Brasil)
  - 🇵🇹 Português (Portugal)
  - 🇺🇸 Inglês
  - 🇪🇸 Espanhol
- Estrutura de traduções centralizada via arquivos `.arb` (`lib/l10n`)
- Geração automática de strings tipadas com `flutter gen-l10n`
- Fallback automático para inglês quando o idioma do sistema não é suportado

### Objetivo
- Garantir que o app seja exibido automaticamente no idioma do usuário
- Eliminar dependência de permissões de localização
- Preparar a base do app para expansão internacional
- Padronizar textos e remover strings hardcoded da UI
- 
## 🔹 [Milestone 13] Sistema de Idioma Dinâmico (Auto + Manual Persistido)
**Status:** Concluído ✅

### O que foi implementado
- Sistema de **internacionalização (i18n)** usando o padrão oficial do Flutter (`gen-l10n`)
- Tradução **automática baseada no idioma do sistema**, sem solicitar permissão de localização
- Opção de **idioma manual** acessível em *Configurações*
- Persistência do idioma escolhido via `SharedPreferences`
- Aplicação **imediata do idioma** sem necessidade de reiniciar o app
- Suporte inicial aos idiomas:
  - Português (Brasil)
  - Português (Portugal)
  - Inglês
  - Espanhol
- Fallback seguro para evitar crashes caso alguma key ainda não exista nos ARBs
- Arquitetura preparada para expansão futura de idiomas

### Objetivo
- Garantir que o app se adapte automaticamente ao idioma do usuário
- Permitir override manual com persistência entre sessões
- Manter estabilidade e previsibilidade mesmo durante evolução dos arquivos de tradução

### Próximo passo (próximo commit)
- **Organização estrutural completa** do que foi implementado:
  - Padronizar nomes de keys nos ARBs
  - Consolidar lógica de idioma (`LocaleController`, `LocaleStore`)
  - Revisar imports e remover código legado
  - Documentar a arquitetura de i18n no projeto


## [Milestone 14] Organização da Estrutura + Idioma Suíço (de-CH)
**Status:** Concluído ✅

### Melhorias:
- Estrutura de tradução **refatorada e organizada** (Traducer modular, arquivos separados por responsabilidade)
- Tela de idiomas com **UI premium**, busca e seleção persistida
- Implementado novo idioma: **Alemão (Suíça) — `de_CH`**
- Criado fallback obrigatório **`de`** para suportar corretamente o `de_CH` (exigência do `flutter gen-l10n`)
- Ajustado padrão de arquivos para evitar conflito entre `@@locale` e nome do `.arb`
- Comentários em JSONS ARBS de cada linguagem

### Objetivo:
- Manter a base de i18n escalável e fácil de evoluir
- Garantir que idiomas com país (ex: `de_CH`) funcionem com fallback correto (`de`)
- Preparar o projeto para adicionar novos idiomas sem quebrar o `gen-l10n`

> Próximo commit: organizar estruturalmente todo o restante do que foi implementado (padronização de pastas/nomes/imports).

## [Milestone 15] Tela Novo Produto + i18n Completo (Campos, Validações e Correções)
**Status:** Concluído ✅

### Melhorias:
- Ajustada a tela **Novo Produto** para suportar i18n corretamente em todos os pontos de UI:
  - Adição de imagem (placeholder)
  - Código de barras (label, hint e validação)
  - Categoria (label, hint, loading e validação)
  - Botão de salvar
- Criadas novas chaves de tradução nos arquivos `.arb` para padronizar a experiência:
  - `newProductImageAdd`
  - `newProductBarcodeLabel`
  - `newProductBarcodeHint`
  - `newProductCategoryLabel`
  - `newProductCategoryLoading`
  - `newProductCategoryHint`
  - `newProductCategoryValidator`
  - `newProductSaveButton`
- Corrigidos erros do Dart Analyzer relacionados a **null-safety** (`unchecked_use_of_nullable_value`) ao acessar `AppLocalizations.of(context)`:
  - Uso consistente de `l10n?.chave ?? fallback` nos pontos que acessavam `l10n.chave` diretamente
- Corrigido erro de parâmetro inexistente (`undefined_named_parameter: text`) no `NPSaveButton`:
  - Removido uso de `text:` na tela, alinhando com a assinatura real do widget
  - Preparada a base para tornar o botão traduzível por `label` (l10n-ready)
- Widgets do módulo Novo Produto ficaram **l10n-ready** e consistentes:
  - `NPImagePicker`, `NPBarcodeField`, `NPCategoryDropdown`, `NPTextField`, `NPProductNameField`

### Objetivo:
- Garantir que a tela **Novo Produto** seja 100% traduzível, sem strings hardcoded na UI
- Eliminar falhas de null-safety e reduzir ruído do analyzer
- Preparar o módulo para evoluir com novas validações/fluxos mantendo consistência de idioma

## [Milestone 16] Tela de Login + i18n Completo (UI, Fluxos e Mensagens)
**Status:** Concluído ✅

### Melhorias:
- Refatorada a **tela de Login** para suportar **i18n completo**, eliminando todas as strings hardcoded:
  - Campos de email e senha (labels, hints e ações)
  - Botão de login
  - Links auxiliares (esqueci a senha, criar conta)
  - Separadores e textos de apoio
  - Botões de login social (Google e Apple)
- Internacionalizado todo o **fluxo de autenticação**, incluindo:
  - Mensagens de erro e validação (campos vazios, usuário inexistente, erro inesperado)
  - Estados de conta desativada (título, mensagem e ação)
  - Feedback de redefinição de senha
- Loader e mensagens de progresso traduzidas no login social:
  - Login com Google
  - Preparação / warmup da conta após autenticação
- Ajustado o **LoginController** para trabalhar corretamente com traduções:
  - Uso explícito de `BuildContext` para resolução de textos via `AppLocalizations`
  - Centralização das mensagens de erro traduzidas
  - Manutenção do controller desacoplado da UI
- Corrigidos problemas de i18n e analyzer:
  - Removido uso incorreto de `S.of(context)`
  - Padronizado import real: `import '../../../l10n/app_localizations.dart';`
  - Garantida compatibilidade total com `flutter gen-l10n`
- Criadas e padronizadas novas chaves de tradução nos arquivos `.arb`, cobrindo:
  - Validações de login
  - Erros de autenticação
  - Estados de conta desativada
  - Fluxo de redefinição de senha
  - Mensagens de carregamento e progresso
- Widgets do módulo de Login ficaram **l10n-ready e reutilizáveis**:
  - `LoginForm`
  - `LoginHeader`
  - `LoginFooter`
  - `LoginError`
  - `SocialLoginButtons`

### Objetivo:
- Garantir que a tela de **Login** seja 100% traduzível em todos os fluxos (UI + lógica)
- Eliminar strings fixas e inconsistências de idioma
- Consolidar um padrão sólido de i18n para telas críticas de autenticação
- Preparar a base para evolução futura (novos provedores de login, mensagens e validações) mantendo consistência linguística

## [Milestone 17] Registro de Usuário + i18n Completo (UI, Fluxos e Mensagens)
**Status:** Concluído ✅

### Melhorias:
- Refatorado todo o **módulo de Registro** para suportar **i18n completo**, eliminando strings hardcoded em UI e lógica.
- Internacionalização aplicada nos widgets de registro:
  - `register_header.dart` — títulos e textos de apresentação
  - `register_form.dart` — labels, hints, botões e validações
  - `register_email_field.dart` — textos e mensagens de erro
  - `register_password_field.dart` — validações, feedback de força de senha
  - `register_footer.dart` — textos de navegação e CTA
  - `register_alert.dart` — mensagens de alerta e confirmação
  - `social_register_buttons.dart` — textos de registro social (Google / Apple)
- Ajustado o **RegisterController** para trabalhar corretamente com traduções:
  - Mensagens de erro e sucesso resolvidas via `AppLocalizations`
  - Nenhuma string fixa dentro da lógica de controle
- Padronização total do fluxo de validação:
  - Campos obrigatórios
  - Regras de senha
  - Erros de autenticação
  - Feedback visual consistente
- Arquivos de tradução (`.arb`) expandidos e organizados para cobrir:
  - Tela de registro
  - Validações
  - Alertas
  - Fluxo de criação de conta
- Garantida compatibilidade total com `flutter gen-l10n`:
  - Sem warnings de locale
  - Sem chaves duplicadas
  - Sem uso incorreto de helpers antigos

### Objetivo:
- Garantir que o **registro de usuário** seja 100% traduzível (UI + lógica)
- Manter consistência total com o padrão já aplicado na tela de Login
- Eliminar dependência de textos fixos em widgets e controllers
- Consolidar a base de i18n para autenticação e onboarding
- Preparar o módulo de Registro para expansão de idiomas sem retrabalho estrutural

## [Milestone 18] Onboarding da Empresa + i18n Completo (Company + Termos & Políticas)
**Status:** Concluído ✅

### Melhorias:
- Refatorado todo o **módulo de Onboarding da Empresa** para suportar **i18n completo**, eliminando strings hardcoded em UI e mensagens de validação.
- Internacionalização aplicada nos arquivos do fluxo de Company:
  - `company_screen.dart` — integração correta do `AppLocalizations` no fluxo de finalização
  - `company_controller.dart` — mensagens de erro e validações resolvidas via `AppLocalizations` (sem strings fixas)
  - `widgets/company_header.dart` — título, subtítulo e linha de conta (com fallback de e-mail) totalmente traduzíveis
  - `widgets/company_form.dart` — hints, perguntas (toggles), labels, modal de seleção e botão final traduzidos
- Padronização do comportamento de UI no onboarding:
  - Labels e placeholders consistentes em todos os idiomas
  - Toggle “Sim/Não” e textos auxiliares centralizados em chaves i18n
  - Modal de seleção de tipo de negócio com título traduzível
- Expandida a base de tradução para cobrir também o conteúdo legal do app:
  - `politic_privacity.dart` — Política de Privacidade refatorada para i18n (títulos + parágrafos)
  - `terms_used.dart` — Termos de Uso refatorados para i18n (títulos + parágrafos)
- Arquivos `.arb` atualizados para incluir:
  - Chaves do onboarding de empresa (UI + validações + tipos de negócio + textos legais)
  - Conteúdo legal completo (Política de Privacidade e Termos de Uso) em múltiplos idiomas
- Garantida compatibilidade total com `flutter gen-l10n`:
  - Sem warnings de locale
  - Sem quebras por `de_CH` (fallback `de` mantido)
  - Mesmas chaves entre idiomas para evitar inconsistências

### Objetivo:
- Garantir que o **onboarding da empresa** seja 100% traduzível (UI + lógica + validações)
- Consolidar o padrão de i18n do app (Login/Registro/Onboarding) com consistência total
- Incluir **Termos de Uso** e **Política de Privacidade** traduzíveis dentro do app (pronto para publicação)
- Preparar o módulo para expansão de idiomas sem retrabalho estrutural


## [Milestone 19] Tela de Relatórios (Dia) + i18n Completo + Datas Dinâmicas por Locale
**Status:** Concluído ✅

### Melhorias:
- Refatorada toda a **Tela de Relatórios Diários (Visão Geral)** para suportar **i18n completo**, eliminando completamente strings hardcoded de UI, gráficos, tooltips e estados.
- Internacionalização aplicada em todo o fluxo de relatórios do dia:
  - `relatorios_days.dart` — widget principal organizado, com separação clara entre Widget e State
  - `relatorios_days_state.dart` — lógica, estados, filtros e labels resolvidos via `AppLocalizations`
  - `charts/line_chart_section.dart` — títulos, eixos, legendas e tooltips totalmente traduzíveis
  - `charts/pie_chart_section.dart` — título dinâmico conforme modo (Todos / Entradas / Saídas) integrado ao i18n
- Padronização completa da UI da tela de relatórios:
  - Títulos de seções (Relatórios, Produtos movimentados, Resumo executivo)
  - Labels de gráficos (Linha / Pizza)
  - Filtros percentuais (Todos / Entradas / Saídas)
  - Estados vazios e mensagens de orientação ao usuário
- Refatoração dos tooltips dos gráficos:
  - Tooltip do gráfico de linha padronizado via chave i18n (`relatoriosLineTooltip`)
  - Placeholders dinâmicos (label + valor), compatíveis com múltiplos idiomas
- **Correção estrutural de datas dependentes de idioma**:
  - `relatorios_days_date.dart` refatorado para **usar o locale ativo do app**
  - Removido uso fixo de `pt_BR` no `DateFormat`
  - Datas agora respeitam corretamente idioma e região (ex: EN / DE / ES / PT)
  - Exibição consistente de **dia, mês e ano conforme locale**
- Consolidação da base de traduções:
  - Chaves de relatórios organizadas e padronizadas nos arquivos `.arb`
  - Traduções completas adicionadas para:
    - EN (Inglês)
    - ES (Espanhol)
    - PT-PT (Português de Portugal)
    - DE (Alemão)
    - DE-CH (Alemão Suíço, com fallback em `de`)
- Compatibilidade total garantida com `flutter gen-l10n`:
  - `example` sempre como string
  - Placeholders corretamente tipados (`int`, `num`, `String`)
  - Nenhuma chave duplicada ou ausente entre idiomas
  - Sem warnings ou quebras de locale


### Objetivo:
- Garantir que a **Tela de Relatórios (Visão Geral do Dia)** esteja **100% traduzível**
- Corrigir definitivamente problemas de datas presas em `pt_BR`
- Consolidar o padrão arquitetural de **i18n profissional** no módulo de relatórios
- Preparar a base para:
  - Relatórios Mensais e Anuais
  - Internacionalização do Relatório por Produto
  - Evoluções futuras sem retrabalho estrutural


## [Milestone 20] Relatórios por Produto (Dia / Mês) + i18n + Refatoração Estrutural
**Status:** Concluído ✅

### Melhorias:
- Refatorado o **Relatório por Produto** para seguir o mesmo padrão arquitetural e de i18n da tela de relatórios gerais.
- Internacionalização aplicada em toda a tela `RelatoriosForProducts`:
  - AppBar, títulos, subtítulos e estados vazios resolvidos via `AppLocalizations`
  - Labels de gráficos, legendas e tooltips traduzíveis
  - Textos de resumo executivo e lista detalhada sem strings hardcoded
- Refatoração estrutural do código:
  - Separação clara entre:
    - Lógica de datas (`utils/relatorios_for_products_date.dart`)
    - UI principal
    - Estados e streams
  - Código reorganizado para facilitar manutenção e escalabilidade
- Padronização de datas por locale:
  - Datas agora respeitam **idioma e região do app**
  - Suporte correto a:
    - Relatório diário
    - Relatório mensal
  - Exibição consistente de **dia, mês e ano conforme locale ativo**
- Integração completa com `ReportPeriod`:
  - Diferenciação clara entre dia e mês
  - Preparação para períodos customizados futuros
- Consolidação das traduções:
  - Novas chaves adicionadas aos arquivos `.arb`
  - Traduções completas para:
    - EN (Inglês)
    - ES (Espanhol)
    - PT-PT (Português de Portugal)
    - DE (Alemão)
    - DE-CH (Alemão Suíço, com fallback em `de`)
- Compatibilidade total com `flutter gen-l10n`:
  - Placeholders padronizados
  - `example` sempre como string
  - Nenhuma quebra entre idiomas
  - Build estável e sem warnings

### Objetivo:
- Tornar o **Relatório por Produto** totalmente traduzível e profissional
- Alinhar o padrão de datas, UI e arquitetura com o restante do módulo de relatórios
- Garantir escalabilidade para:
  - Relatórios mensais e anuais por produto
  - Comparações futuras
  - Expansão de idiomas sem refatorações pesadas


## [Milestone 21] Tela de Alertas de Estoque + i18n Completo
**Status:** Concluído ✅

### Melhorias:
- Refatorada a **Tela de Alertas de Estoque** para suportar **i18n completo**, eliminando strings hardcoded de UI, filtros e estados vazios.
- Internacionalização aplicada em todo o fluxo da tela de alertas:
  - `alertas_screen.dart` — título da tela, busca, filtros e seções totalmente resolvidos via `AppLocalizations`
  - Estados visuais (carregamento e vazio) com textos traduzíveis
- Padronização da experiência de alertas:
  - Barra de busca com hint traduzível
  - Filtros de estoque (**Todos / Zerado / Crítico**) centralizados em chaves i18n
  - Títulos de seção (**Estoque Zerado / Estoque Crítico**) padronizados
- Refatoração dos cards de alerta:
  - Labels de quantidade com placeholder dinâmico (`alertasQuantityWithValue`)
  - Botões de ação traduzíveis (**Pedir Agora / Notificar**)
- Estados vazios profissionais:
  - Mensagem principal e subtítulo totalmente internacionalizados
  - Comunicação clara quando não há alertas ativos
- Consolidação da base de traduções:
  - Chaves de alertas organizadas nos arquivos `.arb`
  - Traduções completas adicionadas para:
    - EN (Inglês)
    - ES (Espanhol)
    - PT-PT (Português de Portugal)
    - PT (Português do Brasil)
    - DE (Alemão)
    - DE-CH (Alemão Suíço, com fallback em `de`)
- Compatibilidade total com `flutter gen-l10n`:
  - `example` sempre definido como string
  - Placeholders corretamente tipados
  - Nenhuma chave duplicada ou ausente entre idiomas
  - Sem warnings de locale

### Objetivo:
- Garantir que a **Tela de Alertas de Estoque** seja **100% traduzível**
- Manter o padrão arquitetural de i18n profissional no app
- Preparar a tela para futuras evoluções:
  - Ações automatizadas de reposição
  - Notificações inteligentes
  - Regras de alerta personalizáveis

## [Milestone 22] Product Details Modal + Estrutura Escalável (Product Card) + i18n Completo
**Status:** Concluído ✅

### Melhorias:
- Refatorado o **Product Details Modal (Card de Detalhes do Produto)** para uma arquitetura **modular e escalável**, eliminando um arquivo monolítico difícil de manter.
- Separação estrutural em múltiplos arquivos, seguindo padrão de responsabilidade única:
  - `product_details_modal.dart` — composição principal do modal (UI + fluxo)
  - `confirmation_pass_modal.dart` — confirmação de senha para exclusão (reauth)
  - `widgets/sheet_handle.dart` — handle/drag do bottom sheet
  - `widgets/product_image.dart` — exibição premium da imagem (loading/error/placeholder)
  - `widgets/editable_field_row.dart` — linha editável reutilizável (nome/estoque mínimo)
  - `widgets/category_dropdown.dart` — dropdown de categorias via stream (mantível)
  - `widgets/info_card.dart` — cards informativos (quantidade, custo médio, preço unitário etc.)
  - `widgets/barcode_section.dart` — seção de código de barras organizada
  - `widgets/action_buttons.dart` — botões de ação (salvar/excluir) padronizados
- Implementado **i18n completo** em todos os textos do modal:
  - Labels (Nome do produto, Categoria, Estoque mínimo etc.)
  - Botões (Salvar alterações, Excluir produto, Confirmar, Cancelar)
  - Mensagens e validações (senha vazia, senha incorreta, erro ao verificar)
  - Snackbars e feedbacks (exclusão bem-sucedida, erro de estoque mínimo inválido)
- Aplicada formatação de moeda **por locale** (sem hardcode `R$`):
  - `NumberFormat.simpleCurrency(locale: ...)` usando `Localizations.localeOf(context).toLanguageTag()`
- Consolidação das chaves nos arquivos `.arb` com tradução completa para:
  - EN (Inglês)
  - ES (Espanhol)
  - PT-PT (Português de Portugal)
  - PT (Português do Brasil)
  - DE (Alemão)
  - DE-CH (Alemão Suíço, mantendo fallback `de`)
- Garantida compatibilidade total com `flutter gen-l10n`:
  - Mesmas chaves em todos os idiomas
  - Sem strings hardcoded em UI/validação
  - Sem warnings de locale / placeholders inválidos

### Objetivo:
- Transformar o **Product Card (Detalhes do Produto)** em um módulo **profissional, sustentável e escalável**
- Garantir que o modal seja **100% traduzível**, pronto para publicação internacional
- Criar uma base sólida para expansão futura:
  - Reaproveitar widgets em outras telas (cadastro/edição/listagem)
  - Padronizar feedbacks e validações com i18n consistente

## [Milestone 23] Scanner de Código de Barras + Overlay de Resultado (i18n + Fix)
**Status:** Concluído ✅

### Melhorias:
- Corrigido o comportamento do **overlay de resultado** após escanear:
  - O título “Código escaneado / Sucesso” voltou a aparecer corretamente no card (evitando título vazio).
  - Padronizado para usar chave i18n já existente: `scannerResultSuccessTitle`.
- Aplicado **i18n no fluxo do scanner** (textos de instrução e resultado), eliminando strings hardcoded.
- Organização estrutural do módulo do scanner para manutenção e evolução:
  - Separação de responsabilidades entre **modal do scanner** e **card de resultado**
  - Fluxo de estado mais claro (`_showResult`, `_scannedCode`, `_isError`, dismiss/popup seguro)
- Ajustes de robustez:
  - Prevenção de múltiplos `pop` com flag de segurança
  - Controle de animação (pausa ao detectar código + retorno via dismiss)
  - Toggle de flash funcional com `MobileScannerController`

### Compatibilidade i18n:
- Mantida compatibilidade total com `flutter gen-l10n`
- Reutilizadas chaves já existentes entre idiomas (sem quebrar `.arb`)

### Fora de Escopo (Intencional):
- Não foi implementada busca automática de produto pelo código (somente leitura + retorno do valor).
- Não foi alterado o fluxo de cadastro/validação de produto após o scan (somente UI/UX + i18n do scanner).

### Objetivo:
- Garantir uma experiência de scanner **premium**, confiável e totalmente traduzível
- Consolidar padrão de i18n e estrutura escalável para:
  - Validação de códigos
  - Lookup automático de produtos
  - Tratamento de erros avançado e estados adicionais

## [Milestone 24] Categorias — AddCategoryDialog + i18n Completo + Service Layer
**Status:** Concluído ✅

### Melhorias:
- Refatorado o fluxo de **criação de categorias** para uma estrutura mais **profissional, modular e escalável**, separando responsabilidades entre UI e acesso ao Firestore.
- Implementado **i18n completo** no modal de adicionar categoria (sem strings hardcoded):
  - `add_category_dialog.dart` — UI premium com validações e mensagens via `AppLocalizations`
  - `services/categories_firestore_service.dart` — camada de serviço dedicada para operações de categoria no Firestore
- Padronização de UX no modal:
  - Autofocus no input ao abrir
  - Loading state consistente no botão de ação
  - Snackbars com mensagens traduzíveis e aparência premium
- Base de traduções expandida e consistente:
  - Novas chaves adicionadas:
    - `addCategoryTitle`
    - `addCategoryHint`
    - `addCategoryAction`
    - `addCategoryNameRequired`
    - `addCategoryError`
    - `commonCancel`
  - Traduções completas adicionadas para:
    - PT
    - EN
    - ES
    - PT-PT
    - DE
    - DE-CH (com fallback em `de`)

### Objetivo:
- Garantir que o fluxo de **Adicionar Categoria** esteja **100% traduzível** (UI + validações + erros).
- Criar base estrutural sólida com **Service Layer** para evoluções futuras:
  - Editar categoria
  - Excluir categoria
  - Regras de duplicidade/normalização de nomes
  - Reuso do serviço em múltiplas telas sem duplicação de código


## [Milestone 25] Home Refinado — Bottom Navigation Premium
**Status:** Concluído ✅

### Melhorias:
- Refatorado o **Bottom Navigation da Home** com foco em **compactação vertical**, mantendo visual premium
- Ajustada a **altura total do rodapé** para eliminar excesso de espaço e evitar overflow em telas menores
- Correção do **overflow inferior do botão Scanner** (3px), garantindo renderização perfeita sem quebrar layout
- Scanner central mantido em destaque, com:
  - Dimensões ajustadas
  - Elevação visual controlada
  - Sombras refinadas e proporcionais
- Reduzidos espaçamentos verticais internos (ícone, label e indicador ativo) para maior densidade visual
- Indicador ativo (barra inferior) refinado para não impactar altura total do componente
- Preservada a hierarquia visual entre tabs padrão e ação principal (Scanner)
- Layout validado sem alterações na largura, focando exclusivamente em **ajustes verticais**

### Objetivo:
- Tornar a Home mais elegante e profissional
- Eliminar inconsistências visuais em diferentes resoluções
- Garantir um Bottom Navigation estável, compacto e escalável
- Preparar a base para futuras evoluções da Home sem retrabalho de layout

## [Milestone 26] Product Card Profissional — Estrutura Escalável + i18n Completo
**Status:** Concluído ✅

### Melhorias:
- Refatorado o **ProductCard** para uma arquitetura **modular e altamente escalável**, separando responsabilidades em camadas:
  - `ProductCardViewModel`: regras de negócio do card (status, valores, campos derivados)
  - `ProductStockStatus`: enum centralizado para estados do estoque + extensão de cor
  - `ProductCardFormatters`: camada de formatação **i18n-first** (labels, placeholders, moeda)
  - `ProductCard` (UI): renderização limpa com widgets menores e reutilizáveis
- Eliminadas todas as **strings hardcoded**, migrando para `AppLocalizations` (Flutter l10n)
- Criadas chaves i18n para:
  - Status do produto (disponível / crítico / indisponível)
  - Texto com placeholder de estoque (`Stock: {value}` / `Estoque: {value}`)
  - Exibição de moeda via string localizada (`currencyValue`)
- Ajustado padrão dos placeholders para compatibilidade total com `flutter gen-l10n`:
  - `example` sempre como **string não vazia**
  - Correção de escape inválido em JSON/ARB (ex: **não** usar `\` antes de `$`)
- Mantido o visual premium do card (imagem 1:1, overlay, bloco inferior com efeito glass e hierarquia tipográfica)

### Objetivo:
- Garantir um **ProductCard global-ready** (multilíngue) e fácil de evoluir
- Reaproveitar regras e formatação em outras views (lista, grid, relatórios) sem duplicar lógica
- Preparar base para futuras melhorias (formatação de moeda por locale com `intl`, novos status e variações de layout)


## [Milestone 27] Tela de Perfil Refatorada + i18n Completo e Estrutura Escalável
**Status:** Concluído ✅

### Melhorias:
- Refatorada a **Tela de Perfil** com foco em **organização, legibilidade e escalabilidade**:
  - Separação clara entre **UI**, **estado** e **regras de negócio**
  - Controller isolado (`PerfilController`) com responsabilidades bem definidas
  - Estados explícitos para loading, erro, vazio e sucesso
- Padronização do gerenciamento de estado com **Riverpod**:
  - Uso de `StateNotifierProvider` com `autoDispose`
  - Ciclo de vida controlado e limpeza automática de estado
  - Preparação da tela para evolução futura sem acoplamento
- Internacionalização (**i18n**) aplicada de forma completa e consistente:
  - Todas as strings da tela de perfil removidas do código
  - Traduções centralizadas em arquivos `.arb`
  - Suporte a múltiplos idiomas:
    - 🇧🇷 Português (Brasil)
    - 🇺🇸 Inglês
    - 🇪🇸 Espanhol
    - 🇵🇹 Português (Portugal)
    - 🇩🇪 Alemão (fallback)
    - 🇨🇭 Alemão (Suíça — `de_CH`)
  - Placeholders e descrições documentadas para cada chave
- UI preparada para estados críticos e ações sensíveis:
  - Feedback visual para erro de carregamento
  - Confirmação e validação ao desativar conta
  - Snackbars padronizados para ações do usuário
- Base pronta para expansão:
  - Fácil adição de novos campos no perfil
  - Inclusão de novos idiomas sem risco de quebra
  - Manutenção simplificada e previsível

### Objetivo:
- Elevar a **Tela de Perfil** a um padrão de **código profissional e escalável**
- Garantir **consistência de idioma**, manutenibilidade e clareza arquitetural
- Preparar o app para crescimento, internacionalização e futuras evoluções

## [Milestone 28] Tela de Configurações Refatorada + Estrutura Escalável + i18n Completo
**Status:** Concluído ✅

### Melhorias:
- Refatorada a **Tela de Configurações** com foco em **arquitetura escalável e manutenção a longo prazo**:
  - Quebra do arquivo monolítico em **múltiplos arquivos com responsabilidades claras**
  - Separação entre:
    - Tela principal (`ConfigScreen`)
    - Definição de itens (`ConfigItems`)
    - Modelo de dados (`ConfigItem`)
    - Widgets reutilizáveis (cards, animações, AppBar)
    - Tema e paleta visual centralizada
- Organização preparada para crescimento:
  - Inclusão de novas opções de configuração sem alterar a tela principal
  - Reutilização de componentes visuais e lógicos
  - Código mais legível, previsível e testável
- Internacionalização (**i18n**) aplicada de forma completa:
  - Remoção total de strings hardcoded da tela
  - Todas as labels e subtítulos movidos para arquivos `.arb`
  - Chaves documentadas com `@description`
  - Suporte aos idiomas:
    - 🇧🇷 Português (Brasil)
    - 🇺🇸 Inglês
    - 🇪🇸 Espanhol
    - 🇵🇹 Português (Portugal)
    - 🇩🇪 Alemão (fallback)
    - 🇨🇭 Alemão (Suíça — `de_CH`)
- UI premium preservada:
  - Animações de entrada mantidas
  - Gradientes, sombras e blur intactos
  - Experiência visual consistente com o restante do app
- Fluxos sensíveis mantidos e isolados:
  - Logout encapsulado
  - Navegação desacoplada da UI
  - Pontos de extensão claros para futuras regras de negócio

### Objetivo:
- Elevar a **Tela de Configurações** ao padrão de **produto profissional**
- Garantir **escalabilidade real**, evitando refatorações custosas no futuro
- Consolidar a base de **i18n** e arquitetura para crescimento do MyStoreDay


## [Milestone 28] Tela de Categorias — Refatoração Estrutural + i18n Completo
**Status:** Concluído ✅

### Melhorias:
- Refatorada a **tela de Categorias** para uma estrutura **mais escalável e profissional**, separando responsabilidades:
  - Lógica de UI desacoplada de diálogos
  - Métodos de ação (add / delete / alertas) organizados
  - Preparação para evolução futura (edição, ordenação, permissões)
- Implementado **i18n completo** na tela de Categorias, eliminando todas as strings hardcoded:
  - Título da tela
  - Estados vazios
  - Diálogo de criação de categoria
  - Confirmação de exclusão
  - Alerta de categoria em uso
  - Botões de ação (Salvar, Cancelar, Excluir, OK)
- Criadas traduções consistentes para os idiomas:
  - 🇧🇷 Português (pt)
  - 🇵🇹 Português de Portugal (pt_PT)
  - 🇺🇸 Inglês (en)
  - 🇪🇸 Espanhol (es)
  - 🇩🇪 Alemão (fallback `de`)
  - 🇨🇭 Alemão Suíço (`de_CH`)
- Padronização de **keys semânticas** (`categories*`, `action*`) para facilitar manutenção e reutilização
- Mantido suporte total ao `flutter gen-l10n`, sem conflitos de locale ou fallback

### Objetivo:
- Garantir que a tela de Categorias esteja pronta para **crescer sem retrabalho**
- Facilitar adição de novas funcionalidades (editar categoria, permissões, analytics)
- Manter o app **100% internacionalizado**, profissional e preparado para distribuição global
