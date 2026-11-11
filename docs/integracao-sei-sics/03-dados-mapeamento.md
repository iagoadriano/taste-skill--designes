# 03. Dados e mapeamento SEI → SICS

Premissas: nomes de campos do SEI seguem o SeiWS e devem ser confirmados no WSDL da versão instalada. Nada foi verificado contra um ambiente real. O modelo do SICS é desconhecido, então todo destino está como "a definir".

## 1. Modelo canônico

| Entidade | Atributos principais |
|---|---|
| Processo | id_sei, nup, nup_normalizado, especificacao, tipo_processo, nivel_acesso, hipotese_legal, data_autuacao, data_conclusao, situacao, unidades_abertas[], interessados[], assuntos[], relacionados[], anexados[], hash_conteudo, dt_ultima_sinc |
| Documento | id_sei, numero_formatado, processo, tipo_documento, numero, data, unidade_elaboradora, nivel_acesso, hipotese_legal, assinaturas[], link_acesso, hash_binario, mime, tamanho, situacao |
| Unidade | id_sei, sigla, descricao, ativa |
| Andamento | id_sei, processo, data_hora, unidade, usuario, tarefa, descricao |
| Interessado | sigla, nome, id_contato (se disponível) |
| Tipo de processo | id_sei, nome |
| Tipo de documento (Série) | id_sei, nome, aplicabilidade (interno/externo) |

## 2. Mapeamento SEI → canônico → SICS

| SEI | Canônico | Tipo | Obrig. | Transformação | SICS |
|---|---|---|---|---|---|
| IdProcedimento | processo.id_sei | string | S | sem alteração; tratar como opaco | a definir |
| ProcedimentoFormatado | processo.nup / nup_normalizado | string | S | guardar formatado e só dígitos; validar DV | a definir |
| Especificacao | processo.especificacao | texto | N | trim; decodificar ISO-8859-1 → UTF-8 | a definir |
| TipoProcedimento | processo.tipo_processo | ref | S | de-para | a definir |
| Interessados | processo.interessados[] | lista | N | deduplicar por sigla+nome | a definir |
| Assuntos | processo.assuntos[] | lista | N | código + descrição | a definir |
| UnidadesProcedimentoAberto | processo.unidades_abertas[] | lista ref | N | vazio ⇒ situação "concluído" | a definir |
| AndamentoGeracao | processo.data_autuacao | datetime | S | dd/mm/aaaa hh:mm:ss → ISO 8601, no fuso do servidor SEI (a confirmar; America/Sao_Paulo é suposição) | a definir |
| AndamentoConclusao | processo.data_conclusao | datetime | N | idem | a definir |
| UltimoAndamento | andamento (último) | objeto | N | upsert por id do andamento | a definir |
| ProcedimentosRelacionados / Anexados | relacionados[] / anexados[] | lista ref | N | resolver por IdProcedimento; pendência se alvo ainda não carregado | a definir |
| IdDocumento | documento.id_sei | string | S | opaco | a definir |
| DocumentoFormatado | documento.numero_formatado | string | S | número SEI visível ao usuário | a definir |
| Serie | documento.tipo_documento | ref | S | de-para | a definir |
| Numero | documento.numero | string | N | preservar como texto | a definir |
| Data | documento.data | date | S | dd/mm/aaaa → ISO | a definir |
| UnidadeElaboradora | documento.unidade_elaboradora | ref | S | de-para | a definir |
| Assinaturas | documento.assinaturas[] | lista | N | nome, cargo, data/hora | a definir |
| NivelAcessoLocal / NivelAcessoGlobal | nivel_acesso | enum | S | de-para; usar o mais restritivo; nunca rebaixar restrição | a definir |
| IdHipoteseLegal | hipotese_legal | ref | N (S se restrito) | de-para via listarHipotesesLegais | a definir |
| LinkAcesso | documento.link_acesso | URL | N | guardar como veio; exige sessão no SEI, salvo se "Gerar Links de Acesso Externos" estiver ativo | a definir |

## 3. Correlação e idempotência

- Chave técnica: `IdProcedimento` e `IdDocumento`, por instância do SEI (incluir `id_instancia_sei` se houver mais de um órgão).
- Chave de negócio: NUP normalizado. Não usar como chave única sem validar, porque processos anexados ou migrados podem gerar ambiguidade.
- Tabela de vínculo `vinculo_sei_sics`: tipo_entidade, id_instancia_sei, id_sei, nup, id_sics, hash_conteudo, versao, status (pendente/sincronizado/erro/ignorado), dt_criacao, dt_ultima_sinc, id_execucao, msg_erro. Unicidade em (tipo_entidade, id_instancia_sei, id_sei).
- Gravação sempre por upsert via vínculo. Se o hash do payload canônico não mudou, não há escrita, o que torna o reprocessamento seguro.

## 4. Domínios e de-para

| Domínio | Origem | Observações |
|---|---|---|
| Unidades | listarUnidades | versionar; unidades desativadas permanecem para o histórico |
| Tipos de processo | listarTiposProcedimento | relação N:1 possível |
| Séries | listarSeries | idem |
| Hipóteses legais | listarHipotesesLegais | necessárias para propagar a restrição |
| Nível de acesso | 0 público, 1 restrito, 2 sigiloso | valor ausente ou desconhecido bloqueia o item (fail-closed) |

Estrutura comum: codigo_sei, descricao_sei, codigo_sics (a definir), vigencia_inicio/fim, ativo. Valor sem de-para vai para fila de pendência com alerta; não usar valor padrão silencioso.

## 5. Cargas e binários

- **Inicial:** o SeiWS não tem listagem geral de processos. É preciso uma lista de NUPs fornecida de fora: relatório do SEI, recorte por unidade/tipo/período entregue pelo administrador, ou lista vinda do SICS. Executar em lotes com checkpoint, fora do horário de pico e respeitando o limite do serviço.
- **Incremental:** o SeiWS não oferece captura de alterações nativa. Polling dos processos conhecidos comparando UltimoAndamento e hash, ou `listarAndamentos` por processo. Manter marca d'água por processo e janela de sobreposição.

| Binário | Prós | Contras |
|---|---|---|
| Cópia no SICS | disponível sem o SEI; permite busca e indexação; integridade por hash | volume e custo; replica dado restrito (LGPD, controle de acesso); risco de cópia desatualizada ou de documento cancelado; obtenção do binário via Web Service a confirmar |
| Só link/referência | leve; SEI segue como fonte única; permissões ficam no SEI | depende de disponibilidade e sessão no SEI; sem busca no conteúdo |

Recomendação (decisão D5 do Governador, README): no MVP, só metadados + `LinkAcesso` + hash do payload canônico. A cópia de binário fica fora do MVP, porque o manual 4.0 não mostra retorno de conteúdo por Web Service (a confirmar na Fase 0). Se confirmada a forma de obtenção, a cópia se limita a documentos públicos que o negócio exigir; restritos dependem de RIPD (arquivo 04) e sigilosos nunca são copiados. O hash de binário só existe quando há cópia.

## 6. Reconciliação e qualidade

- Contagens por execução e por período: processos e documentos na origem, no canônico e no SICS, por tipo e unidade.
- Checksums: SHA-256 do payload canônico ordenado e do binário, quando copiado.
- Órfãos: documento sem processo, relacionamento com alvo ausente, vínculo sem registro no SICS e o inverso.
- Regras: NUP com DV válido, datas coerentes (conclusão ≥ autuação), obrigatórios preenchidos, de-para resolvido, codificação correta.
- Rejeitados vão para quarentena com motivo e reprocessamento. Relatório diário de divergências e amostragem manual na carga inicial.

## 7. Perguntas em aberto sobre o SICS

1. Quais entidades e campos existem para processo, documento e unidade? Quais são as chaves, os campos obrigatórios e os tamanhos?
2. A interface de escrita é API, banco ou arquivo? Aceita upsert e chave externa (id_sei)?
3. O SICS já tem registros com NUP? Será preciso casar com dados existentes?
4. Possui tabelas próprias de unidades e tipos? Quem mantém o de-para?
5. Armazena arquivos? Quais os limites de tamanho e formato, e qual o modelo de permissão para restritos?
6. O fluxo é só SEI → SICS, ou o SICS grava de volta no SEI?
7. Qual o escopo (unidades, tipos, período histórico) e qual a latência aceitável?
8. Precisa do histórico completo de andamentos ou só da situação atual?
9. Como tratar exclusões, cancelamentos, anexações e reaberturas?
10. Quais os requisitos de auditoria, retenção e LGPD?
