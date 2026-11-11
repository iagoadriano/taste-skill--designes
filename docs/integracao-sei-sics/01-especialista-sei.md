# 01. Especialista em SEI: mapa de integração do SEI

Base de confirmação: manual oficial "SEI Web Services, Versão 4.0" (lido na íntegra, 55 p.), READMEs do GitHub `pengovbr` e guia do pacote `rsei` (terceiro, não oficial). O manual de Web Services 5.0 não foi localizado; o que depende dele está marcado "a confirmar na versão instalada". Nada aqui pressupõe características do SICS.

## 1. APIs disponíveis

| API | Para que serve | Lê / escreve | Quando usar |
|---|---|---|---|
| **SOAP nativo (SeiWS)** | Interface oficial do núcleo. WSDL em `http://[servidor]/sei/controlador_ws.php?servico=sei` | Ambos | Padrão para integração sistema a sistema |
| **mod-wssei (REST)** | Módulo adicional que expõe endpoints REST; nasceu para o aplicativo SEI, mas a documentação diz servir a "integradores" | Ambos (inferido do fluxo "logar, cadastrar processo, incluir documento") | Só se o órgão já o tiver instalado; autenticação é por login de usuário e token (detalhes a confirmar no Swagger da instalação) |
| **mod-sei-pen / Tramita GOV.BR** | Trâmite de processos e documentos **entre órgãos** aderentes ao PEN | Ambos, entre instituições | Não é API para sistema de negócio; só faz sentido se o SICS for um sistema de processo eletrônico aderente ao Tramita |
| **REST nativa do núcleo** | Nenhuma evidência encontrada | n/d | A confirmar na versão instalada |

Operações SOAP confirmadas no manual 4.0:

- **Leitura:** `consultarProcedimento`, `consultarProcedimentoIndividual`, `consultarDocumento`, `consultarBloco`, `consultarPublicacao`, `listarAndamentos`, `listarAndamentosMarcadores`, `listarUnidades`, `listarSeries`, `listarTiposProcedimento`, `listarHipotesesLegais`, `listarUsuarios`, `listarContatos`, `listarExtensoesPermitidas`, `listarMarcadoresUnidade`, entre outras listagens.
- **Escrita:** `gerarProcedimento`, `incluirDocumento`, `adicionarArquivo`, `adicionarConteudoArquivo`, `enviarProcesso`, `concluirProcesso`, `reabrirProcesso`, `atribuirProcesso`, `anexarProcesso`, `relacionarProcesso`, `sobrestarProcesso`, `bloquearProcesso`, `lancarAndamento`, `cancelarDocumento`, `excluirDocumento`, `excluirProcesso`, `definirMarcador`, `enviarEmail`, e as de bloco (`gerarBloco`, `incluirDocumentoBloco`, `incluirProcessoBloco`, `disponibilizarBloco`, `excluirBloco`).

**Não existe operação para listar ou pesquisar processos** (por unidade, período ou data de alteração). Toda consulta parte de um protocolo já conhecido.

## 2. Autenticação e habilitação

- Em Administração > Sistemas, o administrador cadastra o **Sistema** (a sigla vira `SiglaSistema`), depois um **Serviço** (ícone Serviços) e as **Operações** permitidas (ícone Operações).
- As operações podem ser restringidas por **unidade, tipo de processo e tipo de documento**.
- O serviço tem dois modos de autenticação:
  - **Chave de Acesso:** gerada no ícone "Gerar Chave de Acesso", exibida uma única vez e guardada criptografada. Vai no parâmetro `IdentificacaoServico`.
  - **Endereço:** valida o IP ou nome do chamador contra o campo "Servidores" (aceita um curinga `*`). O manual avisa que **será removido em versão futura**.
- A opção "Gerar Links de Acesso Externos" faz o `LinkAcesso` retornado abrir como Acesso Externo, para usuários sem permissão no SEI.
- Quase toda chamada exige `IdUnidade`; o manual sugere guardar esses ids em tabela auxiliar no sistema cliente.
- Liberação de firewall costuma ser um pedido separado à equipe de rede (fonte: `rsei`).

## 3. Modelo de dados

- **Processo:** `IdProcedimento` (interno) e `ProcedimentoFormatado` / `ProtocoloProcedimento` (número visível), mais tipo, assuntos, interessados e unidades onde está aberto.
- **Documento:** `IdDocumento` e `DocumentoFormatado`; gerado (interno, HTML do editor) ou recebido (externo, com `NomeArquivo`); `Serie` é o tipo de documento.
- **Nível de acesso:** 0 público, 1 restrito, 2 sigiloso. `NivelAcessoLocal` é o do item; `NivelAcessoGlobal` é o efetivo do processo. `IdHipoteseLegal` acompanha; se `NivelAcesso` for nulo, herda o sugerido pelo tipo de processo.
- **Andamento:** `IdAndamento`, `IdTarefa`, `Descricao`, `DataHora`, `Unidade`, `Usuario`, `Atributos`.
- **Assinatura:** nome, cargo/função, data/hora e usuário, retornados por `consultarDocumento` com `SinRetornarAssinaturas=S`. **Não há operação de assinar** no manual 4.0.
- **Bloco:** `consultarBloco` retorna unidades de disponibilização e protocolos.

## 4. Limitações e armadilhas

- **Sem webhooks nem eventos:** o manual 4.0 não traz nenhum mecanismo de notificação de saída. Existência em 5.x: a confirmar.
- **Detectar novidades exige polling** por processo conhecido:
  - `consultarProcedimento` com `SinRetornarUltimoAndamento=S`; ou
  - `listarAndamentos`, que obriga a filtrar por `Andamentos`, `Tarefas` ou `TarefasModulos` (ids de tarefa estão em `TarefaRN.php`).
- **Descobrir processos novos não é possível por SOAP.** Alternativas: o SICS originar o processo via `gerarProcedimento`, um módulo SEI customizado, ou leitura de banco (não suportada oficialmente).
- **Sigilosos:** processos sigilosos e seus documentos **não são retornados** nas consultas; também não podem ser bloqueados.
- **Custo de consulta:** cada sinalizador `SinRetornar*` gera processamento extra; pedir só o necessário.
- **Arquivos:** `Conteudo` em Base64 ou `ConteudoMTOM` (só externos). Para arquivos grandes, `adicionarArquivo` (nome, tamanho, MD5) mais `adicionarConteudoArquivo` em partes, depois `IdArquivo` em `incluirDocumento`. Arquivos não associados são apagados após 24 h.
- **Limite de tamanho e extensões** são parâmetros da instalação: a confirmar (`listarExtensoesPermitidas`).
- **Codificação:** o exemplo oficial usa `ISO-8859-1`. A confirmar em 5.x.
- **Download do binário** de um documento: o manual mostra `LinkAcesso`, não retorno de conteúdo. A confirmar.

## 5. Diferenças por versão

- **3.x:** manuais v3.0 e v3.1 existem; autenticação por Endereço/IP. Mod-wssei a partir do SEI 3.0.6 (guia de implantação do aplicativo).
- **4.0:** manual documenta a Chave de Acesso e a depreciação do modo Endereço.
- **Mod-wssei por versão do SEI:** 4.0.x usa 2.0.x; 4.1.1 usa 2.2.0; 5.0.x usa 3.0.1.
- **5.0:** as fontes encontradas descrevem só mudanças de interface e editor. Mudanças em Web Services, remoção efetiva do modo Endereço e novas operações: **a confirmar na versão instalada**.
- **Matriz do mod-sei-pen:** não consta no README; a confirmar em `docs/INSTALL.md`.

## 6. Checklist para o administrador do SEI

1. Versão exata do SEI e módulos instalados (wssei, pen, outros).
2. URL do WSDL em homologação e produção, e o manual de Web Services da versão.
3. Cadastro do Sistema (sigla) e do Serviço com **Chave de Acesso**.
4. Lista de operações liberadas, pedindo o mínimo necessário.
5. Unidades, tipos de processo e tipos de documento autorizados, com os respectivos ids.
6. Liberação de IPs de saída no firewall.
7. Se "Gerar Links de Acesso Externos" será marcado.
8. Limite de tamanho de upload e extensões permitidas.
9. Hipóteses legais vigentes e política para restritos e sigilosos.
10. Usuário e unidade que figurarão nos andamentos gerados pela integração.
11. Limites de volume ou frequência de polling aceitáveis.
12. Possibilidade de módulo customizado ou visão de banco para descoberta de processos novos.

## Fontes

- Manual SEI Web Services v4.0: https://sei.goias.gov.br/manual/SEI-WebServices-v4.0.pdf
- Manual v3.1 (não lido, só localizado): https://softwarepublico.gov.br/social/articles/0005/4651/SEI-WebServices-v3.1.pdf
- mod-wssei: https://github.com/pengovbr/mod-wssei e https://github.com/pengovbr/mod-wssei/blob/master/docs/api.md
- mod-sei-pen: https://github.com/pengovbr/mod-sei-pen
- Guia `rsei` (terceiro): https://cran.r-universe.dev/rsei/doc/solicitando-acesso.html
- Guia de implantação do aplicativo SEI v8: https://softwarepublico.gov.br/social/articles/0005/1113/Guia_de_Implanta__o_do_Aplicativo_SEI_v8.pdf
- SEI 5.0 (notícia TJSC): https://www.tjsc.jus.br/web/imprensa/-/nova-versao-do-sei-ja-esta-disponivel-com-interface-renovada-e-novos-recursos
- Portal SEI/PEN: https://www.gov.br/gestao/pt-br/assuntos/sei
