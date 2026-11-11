# 06. Gestão e implantação

**Premissas (nada confirmado):** API, ambiente de homologação e volumetria do SICS são desconhecidos; tamanho da equipe é desconhecido (o cronograma supõe uma equipe pequena dedicada); o órgão tem SEI de homologação e concede credencial de sistema por rito administrativo próprio; versão do SEI e serviços disponíveis a confirmar na Fase 0.

## 1. Fases

| Fase | Objetivo | Entregas | Critério de saída |
|---|---|---|---|
| 0 Descoberta | Levantar fatos sobre SEI, SICS, volumes e restrições | Inventário de tipos de processo/documento, versão do SEI, capacidades do SICS, lista de premissas validadas, forma de descoberta de processos definida | Escopo do MVP aprovado; incógnitas críticas respondidas ou registradas como risco |
| 1 Desenho | Definir arquitetura, modelo canônico e controles | Arquitetura, mapeamento SEI→canônico→SICS, parecer de segurança/LGPD, estratégia de testes | Desenho aprovado pelo Governador e pelo dono do produto |
| 2 Habilitação no SEI | Obter acesso de sistema | Sistema e serviço cadastrados, credencial de homologação, unidades e operações liberadas | Chamada autenticada bem-sucedida em homologação |
| 3 Construção do MVP | Leitura SEI→SICS | Adaptadores, fila, idempotência, reprocessamento, logs, feature flag | Fluxo ponta a ponta em homologação com dados de teste |
| 4 Testes e homologação | Provar correção e robustez | Relatórios funcional, carga, falha/retomada, segurança, reconciliação | Zero defeito crítico; aceite do dono do produto |
| 5 Piloto | Validar em produção com escopo restrito | Credencial de produção, piloto ativo, relatório de reconciliação | Metas do piloto atingidas pelo período acordado |
| 6 Rollout | Expandir por ondas | Ondas ativadas, comunicação às unidades | Todas as unidades/tipos do escopo ativos e estáveis |
| 7 Operação assistida | Transferir operação | Runbooks, painéis, alertas, treinamento | Equipe operadora assume; período sem incidente grave |
| 8 Retorno SICS→SEI (opcional) | Escrever no SEI | Novo desenho, permissões de escrita, testes próprios | Novo ciclo completo de go/no-go |

## 2. Cronograma (estimativa, dependente de premissas)

| Fase | Semanas | Duração |
|---|---|---|
| 0 | 1 a 2 | 2 |
| 1 | 3 a 5 | 3 |
| 2 | 2 a 7 (paralela) | 2 a 6 |
| 3 | 6 a 11 | 6 |
| 4 | 12 a 14 | 3 |
| 5 | 15 a 17 | 3 |
| 6 | 18 a 21 | 4 |
| 7 | 22 a 25 | 4 |
| 8 | após 7 | 6 a 10 |

Total sem a Fase 8: cerca de 25 semanas. Premissas que mais alteram o prazo:

- **Prazo do órgão para liberar credencial do SEI** (homologação e produção): principal fator; iniciar o pedido na semana 2.
- **Forma de descoberta de processos:** se exigir módulo customizado no SEI ou rotina de exportação pelo administrador, a Fase 2 e a Fase 3 crescem.
- **Maturidade da interface do SICS:** se não houver API de ingestão, a Fase 3 cresce.
- **Tamanho e dedicação da equipe.**
- **Parecer LGPD e tratamento de processos restritos.**
- **Disponibilidade da infraestrutura** (ambientes, rede, liberações de firewall).

## 3. Marcos e pontos de decisão

| Marco | Momento | Decisão |
|---|---|---|
| M0 Escopo fechado | fim da Fase 0 | Go/no-go: viabilidade técnica e escopo do MVP |
| M1 Desenho aprovado | fim da Fase 1 | Go/no-go: arquitetura, mapeamento, parecer LGPD |
| M2 Credencial de homologação | Fase 2 | Sem ela, a Fase 3 segue apenas com simulador |
| M3 MVP ponta a ponta | fim da Fase 3 | Entrada em testes |
| M4 Homologação aceita | fim da Fase 4 | Go/no-go para produção |
| M5 Piloto avaliado | fim da Fase 5 | Go/no-go para rollout; ajustar ou reverter |
| M6 Rollout concluído | fim da Fase 6 | Início da operação assistida |
| M7 Encerramento | fim da Fase 7 | Decisão sobre a Fase 8 |

## 4. Matriz RACI

R = responsável, A = aprova, C = consultado, I = informado. Gov = Governador; ESEI = Especialista SEI; Arq, Dad, Seg, QA, Ges = agentes; PO = dono do produto SICS; AdmSEI = administrador do SEI; DPO = encarregado LGPD; Infra = infraestrutura.

| Atividade | Gov | ESEI | Arq | Dad | Seg | QA | Ges | PO | AdmSEI | DPO | Infra |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Escopo e priorização | R | C | C | C | C | C | C | A | C | I | I |
| Arquitetura | C | C | R | C | C | C | I | A | I | I | C |
| Mapeamento de dados | I | C | C | R | C | C | I | A | C | C | I |
| Credencial e permissões no SEI | I | R | C | I | C | I | C | I | A | I | I |
| Segurança e LGPD | C | C | C | C | R | I | I | C | C | A | C |
| Testes e homologação | I | C | C | C | C | R | C | A | C | I | C |
| Ambientes e implantação | I | I | C | I | C | C | R | I | I | I | A |
| Go/no-go de piloto e rollout | R | C | C | C | C | C | C | A | C | C | C |
| Operação assistida | I | C | C | I | C | C | R | A | I | I | R |

## 5. Registro de riscos

| # | Risco | Prob. | Impacto | Mitigação |
|---|---|---|---|---|
| 1 | Atraso na liberação da credencial do SEI | Alta | Alto | Pedir na semana 2; simulador do SEI para não parar a Fase 3 |
| 2 | SICS sem API adequada de ingestão | Média | Alto | Verificar na Fase 0; adaptador isolado; plano alternativo de carga |
| 3 | SeiWS não lista nem pesquisa processos, logo não há como descobrir processos novos só por SOAP | Alta | Alto | Definir na Fase 0 a fonte da lista de processos (SICS, mod-wssei, lista periódica do administrador ou, em último caso, módulo customizado; sem acesso do integrador ao banco do SEI); go/no-go no M0 |
| 4 | Exposição de processos restritos ou de dados pessoais | Média | Alto | Filtro por nível de acesso com fail-closed; mínimo privilégio; parecer do DPO antes do M1 |
| 5 | Mapeamento incompleto de tipos e metadados | Alta | Médio | Inventário na Fase 0; fila de rejeitados; reconciliação |
| 6 | Sobrecarga do SEI por volume de chamadas | Média | Alto | Limite de taxa, janelas acordadas com o AdmSEI, teste de carga |
| 7 | Duplicidade ou perda na sincronização | Média | Alto | Idempotência, dead-letter, reconciliação periódica |
| 8 | Atualização do SEI quebra o contrato | Baixa | Alto | Testes de contrato; acompanhamento do calendário de versões |
| 9 | Vazamento ou expiração de credencial | Baixa | Alto | Cofre de segredos, rotação, restrição de rede, alertas |
| 10 | Indisponibilidade das partes humanas para decisões | Média | Médio | Calendário de decisões; substitutos nomeados |
| 11 | Obtenção do binário por Web Service não confirmada; documentos volumosos ou formatos não suportados | Média | Médio | MVP só com metadados e link; confirmar na Fase 0; se houver cópia, limites definidos e transferência assíncrona |

## 6. Rollout, rollback e operação assistida

- **Piloto:** uma unidade e um ou dois tipos de processo de baixa sensibilidade, escolhidos pelo PO e pelo AdmSEI. Metas (valores a acordar no M4): taxa de sincronização correta, latência, zero incidente de acesso indevido.
- **Feature flag:** por unidade e por tipo de processo, com chave geral de desligamento. Ativação sem nova implantação.
- **Ondas:** (1) demais tipos na unidade piloto; (2) grupo de unidades; (3) restante. Cada onda exige reconciliação limpa da anterior.
- **Carga histórica:** separada do fluxo corrente, em janela de baixa demanda.
- **Rollback:** desligar a flag do escopo afetado; a fila retém mensagens pendentes; registros criados no SICS são marcados pela origem para permitir quarentena ou remoção. Como o MVP só lê, não há reversão a fazer no SEI. Gatilhos: acesso indevido, divergência acima do limite, degradação do SEI.
- **Operação assistida:** 4 semanas com acompanhamento diário, painel (fila, erros, latência, reconciliação), runbooks, canal de incidentes e passagem formal à equipe operadora.

## 7. Rito de governança

- **Cadência:** sincronização curta diária entre agentes; consolidação semanal pelo Governador com relatório ao PO; comitê de go/no-go em cada marco com as partes humanas; revisão quinzenal de riscos.
- **Conflitos entre agentes:** cada parte registra posição, evidência e impacto; o Governador decide seguindo a ordem de precedência (1) conformidade legal e segurança, (2) integridade dos dados, (3) estabilidade do SEI, (4) prazo e custo. Restrições do SEI são arbitradas com parecer do Especialista SEI. Decisões que alterem escopo, prazo ou risco aceito sobem ao PO; as que envolvam dados pessoais, ao DPO.
- **Registro de decisões:** log único e versionado, um registro por decisão (contexto, alternativas, decisão, responsável, data, condição de revisão). Premissas e riscos ficam no mesmo repositório, e nenhuma decisão vale sem registro.
