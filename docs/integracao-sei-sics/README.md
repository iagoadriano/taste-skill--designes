# Plano de projeto: integração SEI → SICS

Estado: plano inicial, anterior à fase de descoberta. Nada foi testado contra um ambiente SEI real e nada se sabe ainda sobre o SICS além de ser o sistema de destino. Os fatos sobre o SEI vêm do manual oficial "SEI Web Services, Versão 4.0" e de repositórios públicos do PEN; o que depende da versão instalada está marcado "a confirmar".

## 0. Decisão vigente: SIGA-Doc no lugar do 1Doc

**O usuário decidiu adotar o SIGA-Doc para substituir o 1Doc e deixar o SEI de lado por enquanto.** O projeto em vigor é o [10-projeto-siga-doc-no-lugar-do-1doc.md](10-projeto-siga-doc-no-lugar-do-1doc.md), apoiado nos arquivos 07 (organograma) e 09 (API e módulos do SIGA). Tudo o que trata do SEI (seções 1 a 9 abaixo e arquivos 01 a 06 e 08) fica como referência.

### Histórico: como se chegou aqui

Depois da primeira versão deste plano, o usuário informou que o interesse é **substituir o 1Doc** e enviou o organograma da Secretaria Municipal de Saúde (SEMUS) cadastrado nele. Isso muda o enquadramento:

- O plano abaixo foi escrito como uma integração contínua SEI → SICS. Substituir o 1Doc é um projeto de **migração** (unidades, usuários, processos e documentos em andamento, histórico), com a integração como parte dele.
- O SICS foi identificado: é o aplicativo SICS-GOV no Base44, sistema de contratações da SEMUS que hoje guarda o 1Doc como referência digitada. O plano concreto para agregar o SEI a ele está em [08-plano-sei-no-sics-gov.md](08-plano-sei-no-sics-gov.md) e prevalece sobre as suposições das seções 1 a 9 onde houver diferença (em especial: não há serviço intermediário separado, e a lista de processos a acompanhar vem do próprio SICS).
- O organograma transcrito e os problemas que ele traz para a migração (siglas repetidas, raiz pendurada na comissão do 1Doc, entidades externas como unidades) estão em [07-organograma-semus-1doc.md](07-organograma-semus-1doc.md).
- Nada foi levantado ainda sobre como extrair dados do 1Doc (API, exportação, contrato). Esse é o primeiro item de descoberta do novo escopo.

## 1. Objetivo

Levar ao SICS, de forma automática, confiável e auditável, os processos e documentos do SEI que interessam ao negócio, preservando nível de acesso e hipótese legal, sem acoplar o SICS ao SOAP nem às versões do SEI.

## 2. Escopo

**Dentro (MVP):**

- Leitura SEI → SICS de metadados de processos, documentos, andamentos e tabelas de domínio (unidades, tipos de processo, tipos de documento, hipóteses legais).
- Processos públicos completos em metadados e link de acesso; processos restritos apenas com metadados mínimos.
- Carga inicial, sincronização incremental por polling, reconciliação periódica, trilha de auditoria e monitoramento.

**Fora do MVP:**

- Processos sigilosos (rejeitados e registrados).
- Cópia do binário dos documentos (depende de confirmação na Fase 0).
- Retorno SICS → SEI (Fase 8, opcional, com novo ciclo de aprovação).
- Trâmite entre órgãos pelo Tramita GOV.BR (não é API para sistema de negócio).
- Acesso direto ao banco de dados do SEI.

## 3. Como vai funcionar

1. O administrador do SEI cadastra um Sistema e um Serviço dedicados em Administração > Sistemas, com autenticação por Chave de Acesso, somente operações de consulta e escopo limitado a unidades, tipos de processo e tipos de documento necessários.
2. Um serviço de integração intermediário guarda a chave em cofre de segredos e fala com o SEI pelo SOAP nativo (SeiWS), por meio de um Adaptador SEI.
3. O integrador obtém a lista de processos a acompanhar. O SeiWS não lista nem pesquisa processos, então a lista vem de uma fonte definida na Fase 0 (ver decisão D1).
4. Para cada processo conhecido, o poller chama `consultarProcedimento` e `listarAndamentos` em intervalos regulares e compara com a marca d'água (último andamento processado e hash).
5. Havendo novidade, o adaptador consulta os documentos (`consultarDocumento`) e converte tudo para o modelo canônico, resolvendo os de-para de domínio.
6. O filtro de nível de acesso é aplicado: público segue; restrito segue só com metadados mínimos; sigiloso, ausente ou desconhecido é bloqueado (fail-closed).
7. O evento canônico é gravado em outbox e publicado em fila. Um worker entrega ao SICS pelo Adaptador SICS, com upsert idempotente pela tabela de vínculo (`id_sei` ↔ `id_sics`).
8. Falhas transitórias são retentadas com backoff; falhas permanentes vão para a dead-letter com motivo e reprocessamento manual.
9. Um job de reconciliação compara periodicamente SEI e SICS e reemite divergências, incluindo reclassificações de nível de acesso.
10. Toda operação gera registro de auditoria sem conteúdo nem dados pessoais, e alimenta métricas e alertas.

Detalhes e diagramas em [02-arquitetura.md](02-arquitetura.md).

## 4. Estrutura de governança

| Papel | Responsabilidade | Entrega |
|---|---|---|
| **Governador** | Coordena os agentes, consolida, arbitra contradições, mantém premissas, riscos e log de decisões, conduz os go/no-go | Este README e as decisões da seção 5 |
| **Especialista em SEI** | Dizer o que o SEI permite e o que não permite; parecer sobre restrições do SEI | [01-especialista-sei.md](01-especialista-sei.md) |
| **Arquiteto de Integração** | Arquitetura alvo, padrão de sincronização, confiabilidade | [02-arquitetura.md](02-arquitetura.md) |
| **Dados e Mapeamento** | Modelo canônico, mapeamento de campos, correlação, cargas, reconciliação | [03-dados-mapeamento.md](03-dados-mapeamento.md) |
| **Segurança e Conformidade** | LGPD, níveis de acesso, credenciais, auditoria, segregação | [04-seguranca-conformidade.md](04-seguranca-conformidade.md) |
| **Qualidade e Testes** | Estratégia de testes, critérios de aceite, observabilidade | [05-qualidade-testes.md](05-qualidade-testes.md) |
| **Gestão e Implantação** | Fases, cronograma, RACI, riscos, rollout e rollback | [06-gestao-implantacao.md](06-gestao-implantacao.md) |

Ordem de precedência em conflitos: (1) conformidade legal e segurança, (2) integridade dos dados, (3) estabilidade do SEI, (4) prazo e custo. Decisões que mudem escopo, prazo ou risco aceito sobem ao dono do produto SICS; as que envolvam dados pessoais, ao encarregado (DPO). O rito completo está no arquivo 06, seção 7.

**Nota sobre esta execução:** o Governador não dispunha da ferramenta de invocação de subagentes. Os seis subagentes foram invocados pela sessão principal em nome do Governador, que depois leu os seis relatórios, corrigiu os desalinhamentos e escreveu este README. O conteúdo dos arquivos 01 a 06 é dos subagentes, com as edições pontuais descritas abaixo.

## 5. Decisões do Governador sobre contradições

| # | Contradição | Decisão |
|---|---|---|
| **D1** | O SeiWS não lista nem pesquisa processos, e a ADR 2 proíbe acesso ao banco do SEI, mas três arquivos sugeriam "visão de banco" como saída. | O integrador não lê o banco do SEI nem visões dele. A descoberta de processos novos usa, em ordem de preferência: (1) lista de interesse do SICS ou processos gerados pela própria integração; (2) listagem via mod-wssei, se instalado e se a capacidade for confirmada; (3) lista periódica de protocolos gerada e entregue pelo administrador do SEI; (4) módulo SEI customizado, como último recurso. A escolha é fechada no marco M0 e é condição de go/no-go. É o risco central do projeto. |
| **D2** | O manual 4.0 diz que sigilosos não são retornados pelo Web Service; o arquivo 04 pede filtro no intermediário. | As duas coisas valem. O filtro fail-closed no intermediário é mantido como defesa em profundidade, porque o comportamento não foi confirmado na versão instalada. O teste CT-04 cobre os dois casos, usando resposta simulada para o caso em que o SEI retornaria o item. |
| **D3** | Modo de autenticação "Endereço/IP" em depreciação versus controles por IP. | Autenticação do serviço somente por Chave de Acesso. O controle por IP permanece, mas como regra de firewall de rede para o IP de saída do integrador, não como modo de autenticação do SEI. |
| **D4** | Numeração de fases diferente entre os arquivos 05 e 06. | Vale a numeração do arquivo 06 (fases 0 a 8). O arquivo 05 foi alinhado e ganhou a definição de pronto da Fase 2. |
| **D5** | Cópia de binário no SICS versus link, com o download por Web Service "a confirmar". | MVP com metadados, `LinkAcesso` e hash do payload canônico. Cópia de binário fica fora do MVP até a Fase 0 confirmar a forma de obtenção; se confirmada, limita-se a documentos públicos que o negócio exigir. Hash de binário só existe quando há cópia. Os arquivos 03, 04 e 06 foram ajustados. |

Ajuste menor: o fuso horário das datas do SEI passou de afirmação para suposição a confirmar (arquivo 03).

## 6. Premissas a validar

1. O SICS é o destino e consome dados do SEI; não se sabe se também origina processos.
2. O SICS tem alguma interface de escrita (API, fila, arquivo ou banco) e aceita chave externa ou upsert.
3. SICS e SEI pertencem ao mesmo órgão controlador. Se não, há uso compartilhado de dados (LGPD, art. 26) e é preciso instrumento formal.
4. O órgão é da esfera federal. Se não for, parte dos decretos citados no arquivo 04 não se aplica diretamente.
5. Existe SEI de homologação e o órgão concede credencial de sistema por rito próprio.
6. A versão instalada do SEI se comporta como o manual 4.0 nos pontos usados (operações, sigilosos não retornados, ausência de eventos). Em 5.x isso não foi confirmado.
7. Há uma equipe pequena e dedicada; o cronograma de cerca de 25 semanas depende disso e do prazo de liberação da credencial.
8. O link de acesso do SEI é suficiente para o usuário do SICS abrir o documento (depende de o usuário ter acesso ao SEI ou de "Gerar Links de Acesso Externos" estar marcado).
9. O volume de processos permite polling por processo dentro dos limites aceitos pelo administrador do SEI.
10. O fuso horário do servidor SEI é o de Brasília.

## 7. Itens do SEI sem verificação

- Manual de Web Services da versão 5.x não localizado: novas operações, remoção efetiva do modo Endereço, existência de eventos ou webhooks.
- Obtenção do binário de documento por Web Service.
- Capacidade de listagem de processos do mod-wssei e sua forma de autenticação.
- Retorno de processos restritos pelo Web Service e em que condições.
- Limite de upload, extensões permitidas e codificação (ISO-8859-1 no exemplo do manual 4.0).
- Matriz de compatibilidade do mod-sei-pen.
- Limites de frequência de chamadas aceitos pela instalação.

## 8. Perguntas em aberto sobre o SICS (por prioridade)

1. O que é o SICS: qual sua finalidade, qual órgão é o dono e ele pertence ao mesmo controlador do SEI?
2. Quais processos do SEI interessam (unidades, tipos, período histórico) e como o SICS sabe que um processo novo é do seu interesse? O SICS já guarda NUPs ou pode originar o processo no SEI?
3. Como o SICS recebe dados: API REST/SOAP, fila, arquivo ou banco? Aceita upsert ou chave externa? Existe ambiente de homologação?
4. O SICS precisa do conteúdo dos documentos ou bastam metadados e link para o SEI? Os usuários do SICS têm acesso ao SEI?
5. O SICS pode receber processos restritos? Qual é o seu modelo de controle de acesso e ele consegue aplicar nível de acesso e hipótese legal?
6. O fluxo é só SEI → SICS ou o SICS precisa gravar no SEI (gerar processo, incluir documento, tramitar)?
7. Qual a latência aceitável entre o fato no SEI e sua aparição no SICS?
8. Qual o modelo de dados do SICS para processo, documento, unidade e andamento (chaves, campos obrigatórios, tabelas de domínio próprias)?
9. Qual o volume estimado (carga inicial e diário) e quais os limites de taxa e janelas de manutenção do SICS?
10. Qual a stack, a hospedagem e a topologia de rede do SICS, e quem são o dono do produto, a equipe e o encarregado (DPO)?

Perguntas equivalentes para o administrador do SEI estão no checklist do arquivo 01, seção 6.

## 9. Próximos passos

1. O usuário responde às perguntas da seção 8, ao menos as cinco primeiras.
2. Enviar o checklist do arquivo 01 ao administrador do SEI e pedir a credencial de homologação (é o maior fator de prazo).
3. Confirmar versão do SEI, módulos instalados e os itens da seção 7.
4. Fechar a forma de descoberta de processos (D1) e o escopo do MVP no marco M0.
5. Revisar os arquivos 02 a 06 com as respostas e substituir os "a definir" do mapeamento.
6. Submeter o tratamento de restritos e a base legal ao jurídico e ao encarregado.

## 10. Índice

| Arquivo | Conteúdo |
|---|---|
| [01-especialista-sei.md](01-especialista-sei.md) | APIs do SEI, autenticação, modelo de dados, limitações, versões, checklist para o administrador |
| [02-arquitetura.md](02-arquitetura.md) | Arquitetura alvo, sincronização, confiabilidade, diagramas Mermaid, ADRs |
| [03-dados-mapeamento.md](03-dados-mapeamento.md) | Modelo canônico, mapeamento de campos, correlação, cargas, reconciliação |
| [04-seguranca-conformidade.md](04-seguranca-conformidade.md) | Enquadramento legal, níveis de acesso, credenciais, auditoria, ameaças, checklist de go-live |
| [05-qualidade-testes.md](05-qualidade-testes.md) | Camadas de teste, casos essenciais, critérios de aceite, observabilidade |
| [06-gestao-implantacao.md](06-gestao-implantacao.md) | Fases, cronograma estimado, marcos, RACI, riscos, rollout e rollback, rito de governança |
| [07-organograma-semus-1doc.md](07-organograma-semus-1doc.md) | Organograma da SEMUS transcrito do 1Doc, achados para a migração e pontos a conferir |
| [08-plano-sei-no-sics-gov.md](08-plano-sei-no-sics-gov.md) | Plano concreto: como o SICS-GOV trata o 1Doc hoje, arquitetura do SEI dentro do SICS, fases, mapeamento, restrições e perguntas |
| [09-siga-doc-api-e-modulos.md](09-siga-doc-api-e-modulos.md) | SIGA-Doc como alternativa gratuita ao 1Doc: módulos, API REST, comparação com o SEI, requisitos e pendências |
| [10-projeto-siga-doc-no-lugar-do-1doc.md](10-projeto-siga-doc-no-lugar-do-1doc.md) | **Projeto em vigor:** frentes de trabalho, integração com o SICS-GOV, fases, riscos e pendências |
| [11-ilustracao-siga-doc-no-sics-gov.png](11-ilustracao-siga-doc-no-sics-gov.png) | Ilustração da aba SIGA-Doc no dossiê do SICS-GOV |
| [12-fase0-prova-de-conceito-siga-doc.md](12-fase0-prova-de-conceito-siga-doc.md) | Resultado da Fase 0: SIGA 11.5 instalado em teste, chamadas da API verificadas, achados e pendências |
| [13-fase1-preparacao.md](13-fase1-preparacao.md) | Fase 1: tarefas de preparação, planilha de servidores com conferência automática, minuta do ato municipal e requisitos de produção |
| [14-fase2-producao.md](14-fase2-producao.md) | Fase 2: máquina de produção, passo a passo, cópia de segurança, monitoramento, desligamento das contas de teste e lista de aceite da TI |
| [15-fase3-piloto.md](15-fase3-piloto.md) | Fase 3: piloto na Diretoria de Compras, módulo SIGA-Doc no SICS, roteiro e o que observar |
| [16-fase4-integracao-completa.md](16-fase4-integracao-completa.md) | Fase 4: acompanhamento agendado (D3), SIGA como protocolo oficial (D5) e situação de D4 |
| [17-fase5-expansao.md](17-fase5-expansao.md) | Fase 5: expansão por superintendência, lista de verificação e roteiro de treinamento |
| [manuais/](manuais/) | Manuais do servidor e do administrador para o uso do SIGA-Doc no SICS |
| [implantacao/](implantacao/README.md) | Kit de instalação do SIGA-Doc de homologação em máquina virtual |
