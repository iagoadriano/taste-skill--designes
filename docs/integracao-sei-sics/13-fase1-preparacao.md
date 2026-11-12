# 13. Fase 1: preparação para produção

A Fase 0 terminou e deu certo. O SIGA 11.5 roda na Oracle, e o SICS cria, assina, recebe e tramita documentos nele, cada usuário em seu próprio nome. A Fase 1 prepara os dados e as decisões que a produção exige (arquivo 10, §3). Quase tudo aqui depende da SEMUS. Cada item diz quem faz.

Critério de saída: dados prontos para carga e ato municipal encaminhado.

## 1. Lista de tarefas

| # | Tarefa | Quem | Como entregar | Situação |
|---|---|---|---|---|
| 1 | Reiniciar o SIGA para ele reconhecer o órgão SEMUS (destino por pessoa) | TI / você | `sudo docker compose restart appserver` na máquina | pendente |
| 2 | Conferir o organograma: unidades que não existem mais, nomes, chefias | Gabinete + RH | Marcar na planilha `fase1/unidades-referencia.csv` | pendente |
| 3 | Lista de servidores que vão usar o sistema | RH | Planilha no modelo `fase1/modelo-servidores.csv` | adiada para o fim (decisão de 12/11/2026) |
| 4 | Modelos de documento usados hoje no 1Doc (memorando, ofício, despacho, circular, requerimento) | Cada superintendência | 1 exemplo real de cada, em PDF | pendente |
| 5 | Lista do que a SEMUS usa no 1Doc (atendimento ao cidadão, assinatura Gov.br, protocolos externos) | Comissão 1Doc (CSDOC) | Lista simples | pendente |
| 6 | Ato municipal que torna o SIGA-Doc o sistema oficial | Jurídico | Minuta da §3 | pendente |
| 7 | Hospedagem de produção: onde roda, quem mantém, cópia de segurança | Secretaria + TI | Decisão registrada | pendente |
| 8 | Domínio oficial (ex.: `sigadoc.araguaina.to.gov.br`) apontando para o servidor | TI da prefeitura | Registro DNS | pendente |
| 9 | Data de fim do contrato do 1Doc | Administrativo | Data | pendente |

Os itens 3, 6, 7 e 9 são os que mais mexem no prazo.

## 2. Cadastro das pessoas (item 3)

1. O RH preenche `fase1/modelo-servidores.csv` com `nome;cpf;email;unidade`. Pode abrir e salvar no Excel como CSV. A unidade pode ser a sigla do 1Doc (`SEMUS-GLICIT`), consultada em `fase1/unidades-referencia.csv`.
2. Confira a planilha:

   ```bash
   python3 fase1/preparar_pessoas.py servidores.csv pessoas.json
   ```

   O script não envia nada. Ele aponta CPF inválido ou repetido, e-mail inválido e unidade inexistente, linha por linha.
3. Com zero problemas, carregue (o mesmo carregador da estrutura, que não duplica):

   ```bash
   node implantacao/estrutura/carregar_semus.js https://ENDERECO ARQ_SENHA_ADMIN implantacao/estrutura/estrutura_semus.json pessoas.json
   ```

4. Cada pessoa recebe a senha do SIGA por e-mail. Para usar pelo SICS, basta o e-mail do SICS ser o mesmo do SIGA. Senão, o administrador liga as contas em "Contas do SIGA".

A planilha tem CPF e e-mail: dado pessoal (LGPD). Ela não vai para o repositório nem por chat. Fica com o RH e com quem roda a carga, e é apagada depois.

## 3. Minuta do ato municipal (item 6)

Texto-base para o jurídico adaptar. Não é parecer jurídico.

> **PORTARIA SEMUS Nº ___/____**
>
> Institui o SIGA-Doc como sistema oficial de documentos e processos administrativos eletrônicos da Secretaria Municipal de Saúde de Araguaína.
>
> **Art. 1º** Fica instituído o SIGA-Doc como sistema oficial de produção, assinatura, tramitação e guarda de documentos e processos administrativos eletrônicos no âmbito da Secretaria Municipal de Saúde.
>
> **Art. 2º** Os documentos produzidos e assinados no SIGA-Doc, com identificação do servidor por usuário e senha pessoais e intransferíveis, têm validade para todos os fins administrativos, nos termos da Lei nº 14.063/2020 e da Lei nº 14.129/2021.
>
> **Art. 3º** O Sistema Integrado de Compras da Saúde (SICS-GOV) poderá criar, assinar e tramitar documentos no SIGA-Doc em nome do servidor autenticado, e os registros dessas ações integram o processo.
>
> **Art. 4º** A partir de __/__/____, novos documentos e processos serão abertos exclusivamente no SIGA-Doc. Os processos em andamento no 1Doc serão concluídos nele ou migrados conforme orientação da comissão designada.
>
> **Art. 5º** Cabe à [unidade responsável] a administração do sistema, o cadastro de unidades e usuários, a cópia de segurança e o suporte aos servidores.
>
> **Art. 6º** O acervo do 1Doc permanecerá disponível para consulta pelo prazo de guarda previsto na tabela de temporalidade aplicável.
>
> **Art. 7º** Esta Portaria entra em vigor na data de sua publicação.

Pontos para o jurídico decidir: se o ato é portaria da Secretaria ou decreto do Prefeito; se a assinatura com login e senha basta para todos os tipos de documento, ou se alguns exigirão assinatura qualificada (certificado ICP-Brasil); e o prazo de transição.

## 4. Hospedagem de produção (item 7)

A máquina atual da Oracle serve para teste, não para produção. Ela tem dados fictícios, a senha padrão em contas de teste e o endereço sslip.io. Para produção, a recomendação é uma máquina nova e limpa, com:

- domínio da prefeitura e HTTPS (o Caddy do kit já faz isso; basta `SIGA_DOMINIO`);
- cópia diária do banco, guardada fora da máquina, com teste de restauração antes do piloto;
- contas de teste (ZZ…) desligadas e senhas novas para administrador e integração;
- um responsável nomeado (é o primeiro risco do arquivo 10, §4).

## 5. Já pronto para a Fase 2

- Kit de instalação (`implantacao/`), estrutura das 165 unidades, município e carregador.
- Integração SICS: mesa virtual, envio com PDFs, assinatura, recebimento e tramitação para unidade ou pessoa, cada usuário em seu nome.
