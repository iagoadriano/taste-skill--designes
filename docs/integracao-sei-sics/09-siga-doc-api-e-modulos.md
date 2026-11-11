# 09. SIGA-Doc: levantamento da API e dos módulos

Levantamento feito por leitura do código-fonte do repositório `iagoadriano/sigaDOC`, que é uma cópia idêntica do `projeto-siga/siga` no commit `c65f287` (04/11/2025, versão 11.5, ramo `develop`). Nada foi instalado nem executado: o que está aqui vem dos arquivos de definição da API (`swagger.yaml`), do `pom.xml` e da estrutura de pastas. O comportamento real precisa ser confirmado numa instalação de teste.

## 1. O que é

Sistema de Gestão Administrativa criado pela Justiça Federal do Rio de Janeiro (TRF2), licença AGPL-3.0. O módulo principal, Siga-Doc, controla a tramitação de documentos e processos administrativos, com assinatura por certificado digital ou por login e senha. O README afirma que foi desenvolvido seguindo os requisitos do e-ARQ Brasil.

## 2. Módulos

| Módulo | Pasta | Função | Interessa ao SICS? |
|---|---|---|---|
| Siga-Doc | `sigaex`, `siga-ex` | Documentos, expedientes, processos, tramitação, assinatura, arquivamento | Sim, é o substituto do 1Doc |
| Siga-GI | `siga`, `siga-cp` | Identidade: órgãos, lotações (unidades), pessoas, cargos, funções, permissões | Sim, recebe o organograma |
| Siga-WF | `sigawf`, `siga-wf` | Fluxos de trabalho com tarefas e responsáveis | Opcional |
| Siga-GC | `sigagc` | Gestão de conhecimento | Não |
| Siga-SR | `sigasr` | Serviços e chamados | Não |
| Siga-TP | `sigatp` | Solicitação de transportes | Não |
| Armazenamento | `siga-arq` | Guarda de arquivos, com suporte a Amazon S3 | Infraestrutura |
| Apoio | `siga-jwt`, `siga-oidc`, `siga-ldap`, `siga-assinador`, `siga-autenticidade`, `siga-ws`, `siga-integracao` | Autenticação por token, login externo, LDAP, assinatura, conferência de autenticidade, serviços SOAP, integrações do governo de SP | Infraestrutura |

## 3. API REST

Seis definições Swagger 2.0, uma por módulo. As três que importam:

| API | Caminho base | Operações |
|---|---|---|
| Siga-Doc (`ExApiV1`) | `/sigaex/api/v1` | 83 |
| Identidade (`SigaApiV1`) | `/siga/api/v1` | 32 |
| Workflow (`WfApiV1`) | declarado como `/sigaex/api/v1` no arquivo (provável erro; a confirmar) | 33 |

**Autenticação:** `POST /siga/api/v1/autenticar` recebe login e senha (HTTP Basic) e devolve um token JWT, enviado nas demais chamadas no cabeçalho `Authorization`. Não há cadastro de "sistema" com chave, como no SEI: a integração usa um usuário do próprio SIGA, e quem administra a instalação cria esse usuário. Essa é a diferença prática em relação ao SEI: sendo a prefeitura a dona da instalação, não depende de terceiro para liberar a API.

### 3.1 O que a API do Siga-Doc cobre

| Necessidade do SICS | Operação |
|---|---|
| Criar documento ou processo | `POST /documentos` (por id ou nome do modelo) |
| Listar modelos e espécies disponíveis | `GET /modelos`, `GET /especies`, `GET /modelos/{id}` |
| Anexar arquivo | `POST /documentos/{sigla}/anexar` |
| Finalizar a elaboração | `POST /documentos/{sigla}/finalizar` |
| Assinar com senha | `POST /documentos/{sigla}/assinar-com-senha` |
| Incluir cossignatário | `POST /documentos/{sigla}/incluir-cossignatario` |
| Tramitar | `POST /documentos/{sigla}/tramitar`, `tramitar-em-paralelo`, `notificar` |
| Receber e concluir trâmite | `POST /documentos/{sigla}/receber`, `concluir` |
| Juntar, apensar, vincular, desentranhar | `POST /documentos/{sigla}/juntar`, `apensar`, `vincular`, `desentranhar` |
| Arquivar, sobrestar, tornar sem efeito | `arquivar-corrente`, `sobrestar`, `tornar-sem-efeito` e os inversos |
| Definir nível de acesso | `POST /documentos/{sigla}/definir-acesso` |
| Consultar documento e histórico | `GET /documentos/{sigla}`, `GET /documentos/{sigla}/dossie` |
| **Pesquisar e listar documentos** | `GET /documentos`, `GET /lista`, `GET /mesa`, `GET /quadro`, `GET /documentos/localizar/mais-recente` |
| Baixar PDF completo | `GET /documentos/{sigla}/pdf-completo`, `GET /documentos/{sigla}/arquivo` |
| Protocolo para o cidadão acompanhar | `POST /documentos/{sigla}/gerar-protocolo`, `GET .../consultar-protocolo` |
| Link público | `POST /documentos/{sigla}/gerar-link-publico` |
| Verificar assinatura | `GET /documentos/{id}/verificar-assinatura` |
| Numeração | `POST /numeracao-expediente`, `POST /numeracao-generica` |
| Classificação documental | `GET /classificacoes`, `POST /documentos/{sigla}/reclassificar` |

Duas operações estão marcadas no próprio arquivo como "SEM IMPLEMENTACAO PRONTA! NAO USAR!": `GET /documentos/{sigla}/pdf` e `GET /documentos/{sigla}/mov/{id}/pdf`. Para PDF, usar `pdf-completo` ou `arquivo`.

### 3.2 API de identidade

`GET` e `POST` de `/pessoas` e `/lotacoes`; consulta de `/orgaos`, `/cargos`, `/funcoes`, `/localidades`; `/pin` para o PIN de assinatura; `/usuario/substituir` para substituição. O organograma do arquivo 07 pode ser carregado por `POST /lotacoes`, depois de resolvidas as siglas repetidas.

### 3.3 Serviço SOAP legado

`siga-ws` expõe `ExService` com operações como `criarDocumento`, `transferir`, `juntar`, `arquivarCorrente`, `isAssinado`, `toJSON`, `obterMetadadosDocumento`. Não é necessário: a API REST cobre o mesmo e mais.

## 4. Comparação com o SEI para o que o SICS precisa

| Ponto | SEI (SeiWS 4.0) | SIGA-Doc (API v1) |
|---|---|---|
| Protocolo | SOAP, ISO-8859-1 | REST com JSON |
| Quem libera o acesso | Administrador do SEI do órgão | A própria prefeitura, dona da instalação |
| Listar ou pesquisar processos | Não existe | Existe (`/documentos`, `/lista`, `/mesa`) |
| Assinar pela API | Não existe | Existe, com senha ou PIN |
| Baixar o PDF | A confirmar | Existe (`pdf-completo`) |
| Aviso de mudança (webhook) | Não existe | Não encontrei no código; acompanhamento por consulta periódica |
| Integração com outros órgãos (Tramita GOV.BR) | Módulo oficial | Não encontrei |

## 5. Requisitos de instalação observados

- Java 8 e servidor de aplicação JBoss EAP (o `pom.xml` referencia o EAP e há um arquivo `eap72-cp.patch`; a versão exata a usar deve ser conferida no `siga-docker`).
- Banco de dados: há scripts de migração para MySQL em todos os módulos e configurações de Oracle. Não encontrei suporte a PostgreSQL.
- Armazenamento de arquivos com opção de Amazon S3 (`siga-arq`).
- Existe o repositório `projeto-siga/siga-docker` para subir um ambiente de teste, mas sem atualização desde junho de 2023; pode não acompanhar a versão 11.5.

Consequência: diferente do SICS no Base44, o SIGA exige servidor próprio (ou nuvem contratada), banco de dados, cópias de segurança e alguém que saiba manter uma aplicação Java. Esse é o custo real da opção "gratuita".

## 6. Como ficaria SICS + SIGA-Doc

1. O SIGA-Doc é instalado e passa a ser o sistema oficial de documentos e tramitação, no lugar do 1Doc.
2. O organograma (arquivo 07) é carregado em lotações; os usuários, em pessoas.
3. No SICS-GOV entra uma função `sigaProxy`, no molde do `pncpProxy`, que autentica e chama a API REST. As fases do arquivo 08 valem quase sem mudança, trocando SEI por SIGA: referência, leitura, acompanhamento, escrita.
4. Ganhos em relação ao plano com o SEI: o SICS pode pesquisar processos, baixar o PDF e criar, assinar e tramitar documentos pela API, tudo com acesso controlado pela própria prefeitura.

## 7. O que falta verificar antes de decidir

1. Subir uma instalação de teste e confirmar que a versão 11.5 funciona com MySQL e que a API responde como descrito.
2. Conferir os campos exatos de `POST /documentos` e de `tramitar` (não extraí os parâmetros).
3. Modelos de documento: o SIGA usa modelos próprios; os documentos da SEMUS (ofício, memorando, despacho) precisam ser criados neles.
4. Assinatura: a API oferece assinatura com senha e certificado; não verifiquei se há integração com a assinatura do Gov.br.
5. Portal do cidadão: há protocolo de acompanhamento e link público, mas não verifiquei se existe abertura de pedido pelo cidadão, como no 1Doc.
6. Quem na prefeitura hospedaria e manteria o sistema.
7. Validação jurídica da AGPL-3.0 caso o código do SIGA seja alterado.
