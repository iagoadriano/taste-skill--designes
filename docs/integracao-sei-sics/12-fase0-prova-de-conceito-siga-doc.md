# 12. Fase 0: prova de conceito do SIGA-Doc

Executada em 11/11/2026 num ambiente de nuvem temporário, com Docker. O ambiente é descartado ao fim da sessão: nada aqui fica no ar. O objetivo era responder se o SIGA 11.5 sobe com MySQL e se a API faz o que o projeto precisa.

**Resultado: sim para o essencial, com três pendências.** O sistema compilou, subiu e, pela API, foi possível autenticar, criar, finalizar, assinar, tramitar, receber e exportar em PDF um memorando.

## 1. O que foi montado

| Componente | Versão usada | Observação |
|---|---|---|
| Código do SIGA | `iagoadriano/sigaDOC`, ramo `develop`, versão 11.5 (commit `c65f287`) | Compilado com Maven e Java 8, sem os testes |
| Servidor de aplicação | JBoss EAP 7.2.5 (imagem `daggerok/jboss-eap-7.2:7.2.5-alpine`) | A mesma do `siga-docker` |
| Banco de dados | MySQL 8.0.21 | Esquema criado e migrado automaticamente pelo próprio SIGA na subida |
| Cache | Redis | Exigido pela configuração |
| E-mail | Servidor de teste (mailcatcher) | Só captura mensagens |
| Serviços auxiliares | `ckeditor.war`, `blucservice.war`, `vizservice.war` | Baixados das versões publicadas no GitHub |
| Módulos implantados | `siga` (identidade), `sigaex` (Siga-Doc), `sigawf` (workflow) | Os de chamados, conhecimento e transportes ficaram de fora |

Tempos e consumo observados: compilação em cerca de 8 minutos (4 processadores); subida do servidor em cerca de 20 segundos; memória de 2,3 GB no servidor de aplicação e 0,5 GB no MySQL, com o sistema ocioso e um único usuário.

O `siga-docker` (sem atualização desde 2023) funcionou com a versão 11.5 sem alteração de código. Foram necessários só dois ajustes de configuração, descritos na seção 3.

## 2. O que foi testado pela API

| Passo | Chamada | Resultado |
|---|---|---|
| Autenticar | `POST /siga/api/v1/autenticar` com usuário e senha | OK, devolve o token |
| Dados do usuário | `GET /siga/api/v1/usuario` | OK |
| Listar unidades | `GET /siga/api/v1/lotacoes?texto=` | OK |
| Listar pessoas | `GET /siga/api/v1/pessoas?texto=` | OK |
| Listar modelos | `GET /sigaex/api/v1/modelos` | OK, 11 modelos de exemplo (Memorando, Ofício, Despacho, Parecer, processos) |
| Classificação documental | `GET /sigaex/api/v1/classificacoes?texto=` | OK |
| Criar memorando | `POST /sigaex/api/v1/documentos` | OK, devolve o temporário `TMP-1` |
| Finalizar | `POST /documentos/{sigla}/finalizar` | OK, recebe o número `ZZ-MEM-2026/00001` |
| Assinar com senha | `POST /documentos/{sigla}/assinar-com-senha` | OK, depois do ajuste da seção 3 |
| Tramitar para outra unidade | `POST /documentos/{sigla}A/tramitar` | OK |
| Receber na unidade de destino | `POST /documentos/{sigla}A/receber`, com o usuário de destino | OK |
| Exportar PDF | `GET /documentos/{sigla}/arquivo/produzir?contenttype=application/pdf&completo=true` | OK, devolve o PDF direto (38 KB) |
| Gerar protocolo de acompanhamento | `POST /documentos/{sigla}/gerar-protocolo` | OK, devolve número e link público |
| Listar o dossiê | `GET /documentos/{sigla}A/dossie` | OK |

## 3. O que a prova revelou

1. **Assinatura depende, por padrão, de um serviço externo de carimbo de tempo.** A configuração do `siga-docker` aponta `sigaex.carimbo.url` para `https://ittrufusion.appspot.com`, um serviço de terceiros. Sem acesso a ele, a assinatura com senha falha. Removendo essa propriedade, a assinatura funciona sem carimbo. Para produção é preciso decidir: sem carimbo, com o serviço de terceiros, ou com um serviço próprio. Isso tem peso jurídico e entra na Frente E do projeto.
2. **A classificação documental é obrigatória na criação** quando o modelo não tem classificação automática. O SICS precisará enviar a classificação ou os modelos da SEMUS devem trazer uma padrão.
3. **O formato dos parâmetros varia entre as chamadas.** `POST /documentos` aceita formulário com arquivo (multipart); `tramitar` só leu os campos enviados como formulário simples (urlencoded). Cada chamada usada pelo SICS precisa ser testada no formato certo.
4. **A sigla na URL vai sem traços e barras** (`ZZMEM202600001`), e a tramitação é feita sobre a via (`...A`), não sobre o documento.
5. **As permissões se aplicam à API.** Depois de tramitado, o remetente não conseguiu mais anexar nem consultar as movimentações; criar unidade exige a permissão `CAD_LOTACAO`. É o comportamento correto, e confirma que o usuário usado pelo SICS precisa de permissões pensadas.
6. **O arquivo de definição da API tem imprecisões.** `GET /documentos/{sigla}/pdf-completo` devolveu um token cujo download falhou; `arquivo/produzir` funcionou. A pesquisa `GET /documentos` exige o parâmetro `ordenacao`.
7. **A identidade visual padrão é da Justiça Federal** (títulos, brasão). Tudo isso é configurável por propriedades (`siga.cabecalho.titulo`, `sigaex.modelos.cabecalho.*`) e precisa ser trocado pela da SEMUS.

## 4. Pendências (não resolvidas nesta prova)

| Pendência | O que aconteceu | Por que importa |
|---|---|---|
| Anexar arquivo a um documento | `POST /documentos/{sigla}A/anexar` foi recusado: "não pode movimentar anexação por configuração" | É o caminho para o SICS enviar os PDFs que gera. Falta descobrir qual configuração libera |
| Criar documento externo já com o PDF | `POST /documentos` com o modelo "Documento Externo" e arquivo devolveu "Erro na gravação" (erro interno) | Alternativa ao item acima; pode faltar um campo obrigatório ou ser defeito |
| Pesquisa e mesa virtual | `GET /documentos` não achou o documento pela descrição; `GET /mesa` e `GET /quadro` voltaram vazios | O SICS precisa listar o que está em cada unidade. Não investiguei os filtros |

Também não foram testados: login pela tela no navegador, desempenho com vários usuários, cópia de segurança e restauração, envio de e-mail, e os módulos de workflow.

## 5. Como reproduzir

Em uma máquina com Docker, Git e 8 GB de memória livres:

1. Clonar `projeto-siga/siga-docker` e o código do SIGA (ramo `develop`).
2. Compilar o SIGA com Java 8: `mvn clean package -T 1C -DskipTests=true` (pode ser dentro da imagem `maven:3.8-openjdk-8`).
3. Baixar `ckeditor.war`, `blucservice.war` e `vizservice.war` das versões publicadas de `projeto-siga/siga-docker`, `assijus/blucservice` e `projeto-siga/vizservice`.
4. No `standalone.xml` do `siga-docker`: trocar os três valores `***REPLACE-WITH-RANDOM-GUID***` (segredo do token, senha de sincronização e senha do Redis) e remover `sigaex.carimbo.url` se não houver acesso ao serviço de carimbo.
5. Subir MySQL 8.0.21 (com o `mysql-init.sql`), Redis e o servidor de e-mail na mesma rede Docker, com os nomes `mysqlserver`, `redisserver` e `emailserver`.
6. Montar a imagem do servidor a partir de `daggerok/jboss-eap-7.2:7.2.5-alpine`, com o `modules.tar.gz`, os arquivos `.war` e o `standalone.xml`, e iniciá-la na porta 8080.
7. Acessar `http://localhost:8080/siga` com o usuário de teste `ZZ99999` e a senha `Password1`.

O caminho mais curto, `docker-compose up` dentro do `siga-docker`, faz os passos 2 a 6 sozinho, mas compila o ramo `master` e precisa de internet livre dentro do contêiner.

## 6. Conclusão e próximo passo

A Fase 0 cumpre o critério de saída no que é essencial: a versão 11.5 funciona com MySQL e a API cria, assina e tramita documentos. A recomendação é seguir para a Fase 1 (preparação), levando as três pendências da seção 4 como primeiras tarefas técnicas.

Para as próximas fases é preciso um ambiente que permaneça no ar. Sem isso, cada teste recomeça do zero.
