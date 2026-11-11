# 05. Qualidade e testes

Premissa: nada é assumido sobre o SICS. Tudo o que depende dele (contrato, limites, ambiente de homologação, semântica de erro) está marcado como **[a levantar]**. Os nomes de operações do SeiWS e o comportamento de acesso a processos restritos/sigilosos devem ser confirmados no WSDL e na versão do SEI do órgão.

## 1. Estratégia de testes em camadas

| Camada | Escopo | Como |
|---|---|---|
| Unitário | Mapeamento SEI → canônico → SICS, normalização (datas, codificação, número de processo), chave de idempotência, cálculo da marca d'água | Testes puros, sem rede; fixtures XML; testes baseados em propriedades para campos opcionais/nulos |
| Contrato | WSDL do SEI: operações usadas, tipos, campos obrigatórios. SICS: contrato **[a levantar]** | Snapshot versionado do WSDL com diff automático no CI; validação de respostas gravadas contra o schema; contrato do SICS formalizado e testado com stub até existir ambiente |
| Integração | Adaptador SEI contra SEI de homologação; adaptador SICS contra ambiente de teste **[a levantar]** | Credencial de sistema própria de homologação; execução noturna e por release |
| Ponta a ponta | Processo criado/alterado no SEI aparece correto no SICS | Cenários automatizados com verificação no destino e na reconciliação |
| Carga/volume | Carga inicial, pico diário, anexos grandes | Medir vazão, atraso, consumo de fila e impacto no SEI (respeitar limite acordado com o gestor do SEI) |
| Resiliência | SEI fora do ar, timeout, SOAP Fault, XML malformado/truncado, duplicidade, reinício no meio do lote | Proxy de injeção de falhas entre serviço e SEI; matar o worker durante o processamento |
| Segurança | Processo restrito/sigiloso não vaza para destino, logs, fila ou dead-letter; credencial fora de código e log; TLS | Testes negativos automatizados + varredura de logs por conteúdo sentinela |
| Regressão em upgrade do SEI | Mudança de WSDL ou de comportamento entre versões | Suíte de contrato + integração executada na homologação atualizada antes da produção; diff do WSDL como gatilho |

## 2. Ambientes e dados de teste

- **Local/CI:** simulador do SeiWS (respostas gravadas e anonimizadas) e stub do SICS. Determinístico, sem rede externa.
- **Homologação:** SEI de homologação com unidade e credencial de sistema dedicadas; SICS de teste **[a levantar: existe? quem provisiona?]**.
- **Pré-produção:** mesma versão do SEI de produção, volumes representativos.
- **Massa sintética:** gerador próprio de processos, documentos e interessados fictícios. CPF/CNPJ sintéticos e marcados como teste; nomes obviamente fictícios; nenhuma cópia de produção. Se uma amostra real for inevitável para diagnóstico, exigir anonimização e aprovação do encarregado de dados (LGPD).
- **Cobertura da massa:** todos os níveis de acesso (público, restrito, sigiloso), tipos de processo em escopo, documentos internos e externos, anexos grandes, caracteres especiais e acentuação, campos opcionais vazios, processos relacionados/anexados, processo reaberto.
- **Sentinelas:** textos únicos inseridos em processos restritos/sigilosos para detectar vazamento por busca.
- Massa recriável por script, com identificadores registrados para limpeza.

## 3. Matriz de casos essenciais

| ID | Cenário | Resultado esperado |
|---|---|---|
| CT-01 | Processo público novo no SEI | Criado uma vez no SICS, campos conforme mapeamento |
| CT-02 | Processo já sincronizado é alterado (andamento/documento novo) | Atualização no SICS, sem novo registro |
| CT-03 | Mesmo item entregue duas vezes (reprocessamento) | Um único registro; segunda entrega é no-op |
| CT-04 | Processo restrito ou sigiloso | Restrito: só metadados mínimos; sigiloso: não enviado. Sentinela ausente no SICS, logs, fila e dead-letter |
| CT-05 | Processo muda de público para restrito após sincronizado | Conteúdo revogado ou expurgado no destino; evento auditado |
| CT-06 | SEI indisponível por período prolongado | Retentativas com backoff; marca d'água não avança; recuperação sem perda nem duplicata |
| CT-07 | Timeout no meio de um lote | Lote retomado do ponto consistente; nenhum item pulado |
| CT-08 | Resposta malformada ou SOAP Fault | Item vai para dead-letter com causa; demais itens seguem; alerta emitido |
| CT-09 | SICS indisponível ou rejeita o item | Item permanece em fila/retentativa; rejeição permanente vai para dead-letter |
| CT-10 | Worker reiniciado durante o processamento | Sem perda e sem duplicidade após retomada |
| CT-11 | Reconciliação com divergência injetada (item removido/alterado no destino) | Divergência detectada, reportada e corrigida ou sinalizada |
| CT-12 | Carga inicial com volume representativo | Conclui dentro da janela acordada, sem degradar o SEI |
| CT-13 | Campo obrigatório ausente, acentuação, anexo grande | Erro de validação explícito ou transformação correta; sem truncamento silencioso |
| CT-14 | WSDL da nova versão do SEI difere do snapshot | Pipeline falha no teste de contrato antes do deploy |
| CT-15 | Nível de acesso ausente ou desconhecido | Item bloqueado (fail-closed) e alerta emitido |

## 4. Critérios de aceite e go/no-go

Números são **metas sugeridas, a calibrar** com volume real, capacidade do SEI e requisitos do negócio.

| Critério | Meta sugerida |
|---|---|
| Casos críticos (CT-01 a CT-11 e CT-15) | 100% aprovados |
| Vazamento de conteúdo restrito/sigiloso | Zero (bloqueante, sem exceção) |
| Duplicidades no destino | Zero nos testes de idempotência |
| Atraso de sincronização (p95) | ≤ 2 intervalos de polling |
| Taxa de erro permanente | < 0,5% dos itens |
| Divergências na reconciliação | < 0,1% e todas explicadas |
| Recuperação após queda do SEI | Fila normalizada em até 1 h após o retorno |
| Cobertura unitária do mapeamento | ≥ 85% de linhas, 100% dos campos mapeados |
| Defeitos abertos | Zero críticos/altos |

**No-go automático:** qualquer vazamento, perda de dados não detectada pela reconciliação, contrato do SICS não validado em ambiente real, ausência de plano de rollback testado.

## 5. Observabilidade

- **Métricas:** atraso de sincronização (agora menos a data do último item processado), idade da marca d'água, itens processados por ciclo, taxa de erro por tipo (transitório/permanente) e por adaptador, latência das chamadas SEI e SICS, tamanho e idade do item mais antigo da fila, itens em dead-letter, retentativas, divergências de reconciliação por tipo, itens filtrados por nível de acesso.
- **Logs estruturados (JSON):** id de correlação por item, número do processo, operação, tentativa, resultado, duração. **Nunca** registrar conteúdo de documento, dados pessoais ou credenciais; payloads apenas como hash/tamanho.
- **Alertas:** atraso acima do limite; polling sem execução bem-sucedida por N ciclos; dead-letter > 0 (aviso) e crescente (crítico); pico de taxa de erro; fila crescendo continuamente; divergência acima do limite; falha de autenticação no SEI; mudança de WSDL detectada.
- **Painel:** saúde geral (atraso, último ciclo OK), vazão, erros por causa, fila e dead-letter, resultado da última reconciliação, latência dos dois lados.
- Os próprios alertas são testados nos cenários de resiliência (CT-06, CT-08).

## 6. Definição de pronto por fase

As fases seguem a numeração do arquivo 06.

| Fase | Pronto quando |
|---|---|
| 0 Descoberta e 1 Desenho | Operações do SeiWS confirmadas no WSDL; contrato do SICS documentado; regra para restrito/sigiloso aprovada por negócio e segurança; mapeamento de campos assinado |
| 3 Construção do MVP | Unitários e contrato verdes no CI; simulador do SEI e stub do SICS disponíveis; logs e métricas implementados |
| 4 Testes e homologação | Casos críticos aprovados em homologação; dead-letter e reprocessamento operáveis; carga e resiliência executadas; metas da seção 4 calibradas e atingidas; alertas validados; runbook e rollback testados |
| 5 Piloto e 6 Rollout | Checklist go/no-go assinado; carga inicial reconciliada; monitoramento assistido definido |
| 7 Operação assistida | Reconciliação periódica ativa; suíte de regressão amarrada ao processo de upgrade do SEI; revisão das metas após o primeiro mês |

## Pendências que bloqueiam o plano

1. Contrato, ambiente de teste e semântica de erro/idempotência do SICS.
2. Confirmação, pelo negócio e pelo encarregado, da regra padrão para processos restritos/sigilosos e para mudança de nível de acesso.
3. Versão do SEI, operações liberadas à credencial de sistema e limite de requisições aceito pelo gestor do SEI.
4. Volumes reais (carga inicial e diário) para calibrar as metas.
