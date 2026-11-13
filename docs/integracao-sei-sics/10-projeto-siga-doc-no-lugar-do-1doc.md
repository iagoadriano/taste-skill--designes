# 10. Projeto: SIGA-Doc no lugar do 1Doc

**Decisão do usuário:** o SIGA-Doc substitui o 1Doc na SEMUS. O SEI fica de lado por enquanto; os arquivos 01 a 06 e 08 ficam como referência, sem execução prevista. Do arquivo 08 aproveitam-se as fases de integração com o SICS-GOV, trocando SEI por SIGA.

**Base deste projeto:** leitura do código do SIGA 11.5 (arquivo 09), leitura parcial do SICS-GOV (arquivo 08) e o organograma do 1Doc (arquivo 07). Nada foi instalado ou testado ainda. Os prazos são estimativas.

## 1. Como vai funcionar depois de pronto

1. O servidor abre o SIGA-Doc, cria o documento a partir de um modelo (ofício, memorando, despacho, processo), assina e tramita para outra unidade. A unidade de destino recebe na sua mesa virtual, dá ciência, responde ou junta ao processo.
2. O SIGA-Doc guarda o documento, o histórico de tramitação, as assinaturas e a classificação documental. Ele passa a ser o sistema oficial de documentos e processos.
3. O SICS-GOV continua sendo o sistema de trabalho das contratações. Pela API do SIGA, ele registra o número do processo, mostra a situação e o andamento, e envia ao SIGA os documentos que já gera (DFD, ETP, atas, ofícios), sem digitação repetida.
4. O 1Doc fica em modo de consulta durante a transição e é desligado depois de decidido o destino do histórico.

## 2. Frentes de trabalho

### Frente A. Instalação e infraestrutura

| Item | Situação |
|---|---|
| Servidor de aplicação | Java 8 e JBoss EAP, conforme o `pom.xml`; versão exata a conferir no `siga-docker` |
| Banco de dados | MySQL (há scripts de migração em todos os módulos) ou Oracle |
| Arquivos | Local ou Amazon S3 (`siga.armazenamento.arquivo.*`) |
| Configuração mínima | `siga.base.url`, `siga.jwt.secret`, servidor de e-mail, armazenamento |
| Endereço | Domínio com HTTPS; precisa ser alcançável pela internet para o SICS-GOV (Base44) chamar a API |
| Operação | Cópia de segurança diária do banco e dos arquivos, monitoramento, atualização de versão |

Pergunta que define esta frente: quem hospeda (TI da prefeitura, nuvem contratada) e quem mantém.

### Frente B. Estrutura organizacional e usuários

1. Cadastrar o órgão SEMUS e as lotações a partir do arquivo 07. Antes: dar sigla única às 24 farmácias (`SEMUS-DAF-FARM`) e às 5 unidades da COPEC, ligar a Secretaria Executiva direto à SEMUS, e decidir o destino das 9 unidades sem usuário e das entidades externas (ISAC, Instituto Olhar, YANO, Instituto de Prevenção).
2. Cadastrar as pessoas com cargo, função e lotação. A lista de usuários do 1Doc precisa ser exportada; o organograma só traz a quantidade por unidade.
3. A carga pode ser feita pela API de identidade (`POST /lotacoes`, `POST /pessoas`) ou pela tela de administração.
4. Entidades externas: o SIGA tem o conceito de usuário externo (visto no código, não testado). Avaliar se ISAC, Olhar e YANO entram assim, em vez de lotações internas.

### Frente C. Modelos de documento e classificação

1. Levantar os tipos de documento mais usados no 1Doc pela SEMUS (ofício, memorando, despacho, parecer, requisição, processo de compra, processo de pagamento).
2. Criar os modelos equivalentes no SIGA, com cabeçalho, brasão e numeração da SEMUS.
3. Definir a tabela de classificação documental e temporalidade, com o arquivo público municipal, se houver.
4. Definir os níveis de acesso que serão usados.

### Frente D. Integração com o SICS-GOV

| Etapa | O que entra no SICS | Operações da API do SIGA |
|---|---|---|
| D1 | Tipo de referência `siga` no dossiê, ao lado de `1doc`; busca pelo número | nenhuma |
| D2 | Função `sigaProxy` (autentica e guarda o token) e aba "SIGA" no dossiê com situação, histórico e PDF | `POST /autenticar`, `GET /documentos/{sigla}`, `GET /documentos/{sigla}/dossie`, `GET /documentos/{sigla}/pdf-completo` |
| D3 | Acompanhamento agendado gravando novidades na linha do tempo (`ProcessEvent`) | `GET /documentos/{sigla}`, `GET /lista` |
| D4 | Criar processo ou documento a partir do dossiê, anexar os PDFs gerados pelo SICS e tramitar | `POST /documentos`, `POST /documentos/{sigla}/anexar`, `POST /documentos/{sigla}/tramitar` |
| D5 | Regras que hoje exigem "protocolo no 1Doc" (credenciamento, requisição de ata, documentos SEPLAN) passam a aceitar SIGA | `POST /documentos/{sigla}/gerar-protocolo` |

Campos já conferidos no código: `POST /documentos` aceita `modelo`, `subscritor`, `titular`, `classificacao`, `lotadestinatario`, `pessoadestinatario`, `descricaodocumento`, `nivelacesso`, `entrevista` e `arquivo`; `tramitar` aceita `lotacao`, `matricula`, `orgao`, `observacao` e `dataDevolucao`.

Ponto de atenção na D4: a API autentica como um usuário. É preciso decidir se o SICS age com um usuário de serviço (mais simples, mas todo documento aparece como criado por ele) ou em nome de cada servidor (mais correto, exige ligar cada conta do SICS a uma conta do SIGA). A assinatura deve continuar sendo feita pela pessoa.

### Frente E. Jurídico e normativo

1. Ato municipal instituindo o SIGA-Doc como sistema oficial de documentos e processos da SEMUS, com as formas de assinatura aceitas (login e senha ou certificado digital).
2. Parecer do encarregado de dados sobre hospedagem e acesso.
3. Decisão sobre o histórico do 1Doc: exportar e guardar, migrar para o SIGA, ou manter acesso de consulta. Depende do contrato com o fornecedor do 1Doc, que não foi levantado.
4. Licença AGPL-3.0: usar sem alterar não gera obrigação; alterações no código do SIGA oferecido em rede precisam ser publicadas.

### Frente F. Implantação e treinamento

1. Piloto na Diretoria de Compras (`SEMUS-DCOMP` e subordinadas), que já usa o SICS.
2. Expansão por superintendência: SUPADM, depois SUPAE, depois SUPAP (a maior, com farmácias e UBS).
3. Treinamento por perfil: quem só recebe e dá ciência, quem elabora e assina, quem administra.
4. Período de convivência: documento novo nasce no SIGA; o que está em andamento no 1Doc termina lá.

## 3. Fases e estimativa

| Fase | Entrega | Critério de saída | Estimativa |
|---|---|---|---|
| 0. Prova de conceito | SIGA 11.5 instalado em ambiente de teste; um documento criado, assinado e tramitado pela tela e pela API | API responde como descrito no arquivo 09; decisão de seguir ou não | 2 a 3 semanas |
| 1. Preparação | Organograma corrigido, lista de usuários, modelos de documento, minuta do ato municipal, definição de hospedagem | Dados prontos para carga; ato encaminhado | 3 a 4 semanas |
| 2. Produção | Ambiente de produção com HTTPS, cópia de segurança e monitoramento; lotações e pessoas carregadas | Ambiente aceito pela TI | 2 a 4 semanas |
| 3. Piloto | Diretoria de Compras usando o SIGA; etapas D1 e D2 no SICS | Um mês sem pendência grave | 4 a 6 semanas |
| 4. Integração completa | Etapas D3, D4 e D5 no SICS | Documentos do SICS chegando ao SIGA sem digitação repetida | 4 a 6 semanas |
| 5. Expansão | Demais superintendências, com treinamento | Todas as unidades ativas | 6 a 10 semanas |
| 6. Encerramento do 1Doc | Histórico tratado, acesso de consulta definido, contrato encerrado | Decisão formal registrada | a definir |

As fases 3 e 4 podem correr em paralelo. O que mais mexe no prazo: a definição de quem hospeda, a publicação do ato municipal e a data de fim do contrato do 1Doc.

## 4. Riscos principais

| Risco | Efeito | Como reduzir |
|---|---|---|
| Ninguém para manter um servidor Java com banco de dados | Sistema oficial fora do ar ou sem cópia de segurança | Definir o responsável antes da Fase 2; considerar hospedagem contratada |
| Instalação mais difícil que o esperado (o pacote Docker está sem atualização desde 2023) | Atraso já na Fase 0 | A Fase 0 existe para descobrir isso cedo, antes de qualquer compromisso |
| Recursos do 1Doc sem equivalente (atendimento ao cidadão, assinatura pelo Gov.br) | Perda de funcionalidade para quem usa hoje | Listar o que a SEMUS realmente usa no 1Doc e testar cada item na Fase 0 |
| Histórico preso no 1Doc | Perda de acesso a documentos antigos | Levantar o contrato e as formas de exportação antes de marcar o desligamento |
| Resistência dos usuários à troca | Uso paralelo e documentos em dois lugares | Piloto pequeno, treinamento por perfil, data clara de corte |
| SIGA inacessível pela internet | SICS não consegue chamar a API | Publicar o endereço com HTTPS ou um ponto de entrada restrito |

## 5. O que ainda não foi verificado

1. Se a versão 11.5 sobe e funciona com MySQL.
2. Se há login ou assinatura pelo Gov.br. Existe um módulo de login externo (`siga-oidc`), mas não confirmei compatibilidade.
3. Se o cidadão consegue abrir pedido. Vi no código consulta pública de processo, protocolo de acompanhamento e assinador externo, mas não abertura de pedido.
4. Quais recursos do 1Doc a SEMUS usa de fato além de memorando, ofício e processo.
5. Como exportar os dados do 1Doc.

## 6. Próximo passo

Executar a Fase 0. Para isso é preciso um lugar onde subir o ambiente de teste: uma máquina da prefeitura, uma máquina virtual em nuvem, ou o computador de quem vai conduzir o teste (com Docker).

## 7. Registro: aba de demonstração no SICS-GOV

Em 11/11/2026 foi incluída no SICS-GOV, sem publicar, uma aba "SIGA-Doc" de demonstração no dossiê de licitação, visível somente para usuários com papel `admin`. Ela mostra dados fictícios fixos e não chama nenhum serviço.

- Arquivo novo: `src/components/dossiers/SigaDocPreviewPanel.jsx`.
- Alterados: `src/pages/DossierDetail.jsx` (botão e conteúdo da aba, condicionados a `admin`) e `src/lib/dossiers/useDossierTab.js` (identificador `siga_doc` na lista de abas válidas).
- Pontos de restauração no Base44: "Antes da aba SIGA-Doc (demonstração para admin)" e "Aba SIGA-Doc de demonstração no dossiê (somente admin)".
- Verificação feita: lint sem erros, os 4 testes de `useDossierTab` passando e compilação concluída. A tela não foi vista renderizada com usuário logado.

## 8. Registro: Fase 0 concluída e hospedagem definida

- Fase 0 executada em 11/11/2026; resultado no arquivo 12.
- O usuário definiu que o ambiente de teste ficará em uma máquina virtual em nuvem. O kit de instalação está na pasta [implantacao](implantacao/README.md).
- Falta o usuário (ou a TI) criar a máquina e executar a instalação; a sessão que preparou o kit não tem conta de nuvem nem acesso remoto por terminal.

## 9. Registro: SIGA-Doc de homologação no ar

- Em 12/11/2026 o kit da pasta `implantacao` foi executado pelo usuário em uma máquina virtual da Oracle Cloud, região São Paulo (Ubuntu 22.04 Minimal, forma VM.Standard3.Flex com 4 OCPUs e 64 GB).
- Verificado de fora, pela web: a página `/siga` abre, o login da API funciona e a lista de modelos responde. Nenhum documento foi criado nesta verificação.
- HTTPS ainda não configurado: falta um nome de domínio apontando para a máquina.
- O endereço da máquina não é registrado aqui porque este repositório é público.

## 10. Registro: integração SICS-GOV ↔ SIGA-Doc, etapas D1 e D2 (leitura)

Decisão do usuário (12/11/2026): processos continuam sendo abertos pela tela do SIGA-Doc; a API é usada para memorandos, ofícios e despachos com os PDFs anexados (ver arquivo 12, seção 7).

Implementado no SICS-GOV, sem publicar e visível só para administradores:

| Peça | Arquivo no SICS-GOV | Função |
|---|---|---|
| Cliente do SIGA | `base44/shared/sigaDocClient.ts` | Autentica com a conta de integração (token reaproveitado até expirar), consulta documento com histórico e dossiê, gera o PDF completo. Valida a sigla e trata "número inexistente" |
| Função de backend | `base44/functions/sigaDoc/entry.ts` | Ações `status`, `consultar` e `pdf`. Exige usuário administrador. Nunca devolve credenciais |
| Segredos | `SIGA_URL`, `SIGA_USUARIO`, `SIGA_SENHA` | Credenciais da conta de integração, só no backend |
| Referência no dossiê | `references.js` e `processReferences.ts` | Novo tipo `siga` ("SIGA-Doc"); fica fora do seletor geral de referências |
| Aba SIGA-Doc | `src/components/dossiers/SigaDocPreviewPanel.jsx` | Vincula um número do SIGA ao dossiê (confere se existe antes de gravar), mostra situação, onde está, dossiê, tramitação e PDF completo, e permite desvincular |
| Testes | `src/lib/dossiers/sigaDocClient.test.js` | 4 testes do cliente com respostas simuladas |

Verificado: cliente executado contra o SIGA da Oracle (status, consulta, tramitação, dossiê, PDF, número inexistente); 53 testes passando nos arquivos afetados; lint sem erros; compilação concluída; função publicada recusa chamada sem login. Não verificado: a aba aberta no navegador com um administrador logado.

Atenção: o SIGA de teste ainda responde só por HTTP, então a senha da conta de integração trafega sem criptografia entre o Base44 e a Oracle. Antes de dados reais, é obrigatório um domínio com HTTPS.

Próximas etapas: D3 (acompanhamento agendado gravando na linha do tempo do dossiê) e D4 (criar memorando/despacho, anexar PDFs gerados pelo SICS e tramitar).

## 11. Registro: etapa D4, envio pelo SICS (12/11/2026)

Implementado no SICS-GOV, sem publicar e visível só para administradores, na mesma aba SIGA-Doc do dossiê:

- **Enviar ao SIGA-Doc:** o usuário escreve assunto e texto, escolhe a unidade de destino (busca nas unidades do SIGA) e anexa até 5 PDFs de até 9 MB. Uma tela de confirmação resume o envio. O SICS cria o memorando, finaliza (recebe número oficial), anexa os PDFs e vincula o número ao dossiê.
- **Assinar (homologação):** assina com a conta de integração, depois de confirmação explícita. Serve só para testar o fluxo; em produção cada documento precisa ser assinado pela pessoa responsável, com conta própria no SIGA.
- **Tramitar:** escolhe a unidade de destino, com observação opcional e confirmação. O botão só fica ativo depois da assinatura, porque o SIGA não tramita documento pendente de assinatura.
- **Histórico:** criação, assinatura e tramitação ficam registradas na linha do tempo do dossiê, com o e-mail de quem fez.

Escolhas e limites:

- Só **memorando** pela API. Despacho e processos dão erro de gravação na API do SIGA 11.5 (arquivo 12, seção 7); ofício depende de uma macro que não foi testada.
- O texto digitado entra como texto simples e é convertido em parágrafos; nenhum HTML do usuário vai cru para o SIGA.
- Todos os PDFs são validados antes de qualquer criação no SIGA, para não deixar memorando pela metade por causa de arquivo inválido. Se um anexo falhar depois, o memorando continua criado e a tela mostra qual arquivo falhou.
- A escrita exige que o usuário consiga abrir o dossiê de onde está enviando.

Verificado: fluxo completo executado contra o SIGA da Oracle (memorando ZZ-MEM-2026/00005 criado com PDF, assinado, tramitado e visto na caixa de entrada da unidade de destino); 7 testes do cliente passando; lint sem erros; compilação concluída. Não verificado: a tela aberta por um administrador no navegador.

## 12. Registro: item de menu "Tramitação SIGA-Doc"

A pedido do usuário, a integração ganhou um item próprio no menu lateral (somente administradores), logo abaixo de Protocolos. A página `SigaDoc` mostra a mesa virtual da conta de integração no SIGA-Doc, agrupada como no SIGA (Alertas, Pendente de Assinatura, Caixa de Entrada...), com filtro por texto e, para cada documento, o dossiê do SICS ao qual ele está vinculado (link direto para a aba SIGA-Doc do dossiê) e o link para abri-lo no SIGA. Criar, assinar e tramitar continuam dentro do dossiê, para que todo envio parta de um processo do SICS.

Observação do teste: o SIGA marca os PDFs anexados como "Anexo Pendente de Assinatura". Os anexos também precisam ser assinados (ou conferidos) para o alerta sair; isso ainda não é feito pelo SICS.

## 13. Registro: funções do Base44 não alcançam endereço IP

No primeiro uso pela tela, a função `sigaDoc` recebeu `HTTP 403: error code: 1003`. É a resposta do Cloudflare para "acesso direto por IP não permitido": as funções do Base44 saem para a internet passando pelo Cloudflare, que recusa chamadas a um endereço numérico. Testes feitos fora do Base44 não mostravam o problema.

Correção: o segredo `SIGA_URL` passou a usar um nome em vez do IP, pelo serviço gratuito sslip.io (o nome `<ip-com-hifens>.sslip.io` resolve para o próprio IP). Isso também abre caminho para o HTTPS: o kit da pasta `implantacao` emite o certificado sozinho quando `SIGA_DOMINIO` recebe um nome. Para produção, o recomendado é um domínio próprio da prefeitura.

HTTPS ativado em 12/11/2026: `SIGA_DOMINIO=147-15-111-52.sslip.io` no `.env` da máquina; o Caddy emitiu o certificado e passou a redirecionar HTTP para HTTPS. O segredo `SIGA_URL` do SICS-GOV foi trocado para `https://`. A conta de integração deixa de trafegar sem criptografia.

## 14. Registro: Mesa Virtual do SIGA-Doc dentro do SICS

A pedido do usuário ("quero poder fazer tudo dentro do SICS"), a página do menu virou a **Mesa Virtual SIGA-Doc**, no mesmo formato da mesa do SIGA:

- alternância **Usuário / Lotação**, filtro por texto, atualização e horário da última consulta;
- grupos do SIGA (Caixa de Entrada, Aguardando Andamento, Pendente de Assinatura, Alertas...), recolhíveis, com contagem;
- por documento: tempo, número, origem, descrição, marcas, dossiê do SICS vinculado e botões **Receber** (quando está "A Receber") e **Abrir**;
- **Abrir** mostra o documento completo (situação, documentos anexados, tramitação) com as ações Receber, Assinar (homologação), Tramitar, PDF completo e Abrir no SIGA;
- **Criar documento**: memorando com PDFs, sem precisar de dossiê;
- **Pesquisar**: abre um documento pelo número (a API do SIGA não pesquisa por texto da descrição).

O detalhe do documento passou a ser um componente único (`SigaDocumentoDetalhe`), usado na mesa e na aba do dossiê.

Limite principal: a mesa mostrada é a da **conta de integração** (ZZ99998 / LTEST2), não a de cada pessoa. Para cada usuário do SICS ver a própria mesa, há duas opções: (1) cada pessoa informar a própria senha do SIGA, o que exige guardar senhas; (2) o SICS emitir os tokens do SIGA em nome de cada pessoa usando a chave secreta da instalação (`siga.jwt.secret`), ligando o e-mail do SICS ao cadastro da pessoa no SIGA. A opção 2 é a recomendada, mas dá ao SICS o poder de agir como qualquer usuário do SIGA e precisa de decisão formal.

Verificado: mesa por usuário e por lotação, criação, assinatura, tramitação e recebimento executados contra o SIGA da Oracle; 180 testes passando nos módulos afetados; compilação concluída. Não verificado: a página aberta no navegador.

## 15. Registro: cada usuário age no SIGA em seu próprio nome (caminho 2)

Decisão do usuário (12/11/2026): o SICS age no SIGA-Doc em nome de cada pessoa, sem guardar senhas.

Como funciona:

- O SIGA aceita tokens de acesso assinados (HS256) com a chave da instalação (`siga.jwt.secret`, que no kit é o `SIGA_JWT_SECRET` do `.env`). O formato foi lido no código (`AutenticadorJwtCookie`, `SigaJwtProvider`, biblioteca `com.auth0:java-jwt` 2.3.0, que usa a chave como texto puro) e conferido decodificando um token real: `{sub, nbf, mod:null, auth:"auth", iss:"sigaidp", exp, iat}`.
- A função `sigaDoc` gera esse token para a sigla da pessoa ligada ao usuário do SICS, válido por 10 minutos. Mesa, consultas, criação (com a pessoa como subscritora), recebimento, assinatura e tramitação passam a ser feitos em nome dela.
- Ligação usuário ↔ pessoa: primeiro a tabela `SigaVinculoUsuario` (definida por administrador em **Contas do SIGA**, conferindo a sigla no SIGA); se não houver, a pessoa do SIGA com o mesmo e-mail (só quando há resultado único). Sem nenhum dos dois, o SICS recusa a ação e pede o vínculo.
- Sem o segredo `SIGA_JWT_SECRET` configurado no SICS, tudo continua com a conta de integração, e a tela avisa.
- Histórico do dossiê e log da função registram o e-mail do SICS e a sigla em nome de quem a ação foi feita.

Verificado: token gerado em TypeScript aceito pela cópia local do SIGA (entrou como ZZ99994) e token com chave errada recusado ("signature verification failed"); 9 testes do cliente e 182 nos módulos afetados passando; compilação concluída. Vínculo inicial criado: `is3602530@gmail.com` → `ZZ99999`.

Pendente: copiar o `SIGA_JWT_SECRET` da máquina da Oracle para os segredos do SICS. Quem tem essa chave consegue entrar no SIGA como qualquer pessoa: ela deve ficar só no `.env` da máquina e nos segredos do SICS.

## 16. Registro: estrutura da SEMUS cadastrada no SIGA da Oracle (12/11/2026)

- Município Araguaína/TO incluído pelo usuário (`estrutura/municipio-araguaina.sql`).
- Permissões de cadastro (órgão, unidade, cargo, pessoa) liberadas para `ZZ99999` pela tela de permissões do SIGA.
- Carga pela pasta `implantacao/estrutura`: órgão `SEMUS`, cargo `SERVIDOR`, 165 unidades criadas sem falha, com a hierarquia do organograma (ex.: `SEMUSGLICIT` → `SEMUSDCOMP` → `SEMUSSUPADM` → `SEMUSEXEC` → `SEMUSGAB`).
- Pessoa de teste: Daniel Marques da Silva, `SEMUS10010`, lotado em `SEMUSGLICIT`, com o e-mail dele (CPF fictício `000.000.002-72`). A busca por e-mail no SIGA o encontra, então o SICS liga a conta dele sem vínculo manual.
- Anexação de PDFs liberada para todo o órgão SEMUS.
- O mesmo fluxo foi testado antes na cópia local: o Daniel criou, assinou e tramitou um memorando da GLICIT para a DCOMP.

Pendente: lista de servidores (nome, e-mail, CPF, unidade) para cadastrar as demais pessoas.

## 17. Registro: destino por pessoa e início da Fase 1 (12/11/2026)

- O SICS agora envia e tramita direto para uma pessoa: botão Unidade/Pessoa, busca por nome ou matrícula. O SIGA usa `pessoadestinatario` no memorando e `matricula` na tramitação. Falta reiniciar o SIGA para ele reconhecer as matrículas do órgão SEMUS, criado depois da subida.
- Fase 0 encerrada. A Fase 1 começa, com lista de tarefas, planilha de servidores, conferência automática e minuta do ato no arquivo 13.

## 18. Registro: kit de produção (Fase 2), 12/11/2026

E-mail real configurável, scripts de cópia de segurança com verificação, restauração de teste, monitoramento com alerta e cancelamento das contas de teste. Roteiro e lista de aceite no arquivo 14. A produção depende de máquina, domínio, SMTP e planilha da Fase 1.

## 19. Registro: Fase 4 (D3 e D5), 13/11/2026

- D3 (acompanhamento agendado): função `sigaAcompanhar` + workflow "Acompanhamento SIGA-Doc" (4x/dia). Lê as movimentações dos documentos do SIGA vinculados aos dossiês e grava na linha do tempo. Execução de teste concluída com sucesso. Detalhes no arquivo 16.
- D5: o tipo de referência `siga` passou a ser registrável no bloco geral de referências do dossiê, valendo como protocolo oficial onde antes se exigia o 1Doc.
- D4 já estava pronto (§11). Com isso, a Fase 4 está implementada no SICS; falta o uso real do piloto confirmar.
