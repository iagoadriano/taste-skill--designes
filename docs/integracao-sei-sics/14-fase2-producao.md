# 14. Fase 2: ambiente de produção

Objetivo (arquivo 10, §3): SIGA-Doc em produção com HTTPS, cópia de segurança e monitoramento, e com unidades e pessoas carregadas. Critério de saída: ambiente aceito pela TI.

A máquina da Oracle usada até agora continua sendo a de **homologação**, onde se testa antes de mexer na produção. A produção é uma máquina nova e limpa: nada de dado fictício, nem de senha que já passou por chat.

## 1. O que precisa estar decidido (vem da Fase 1)

| Item | Por quê | Situação |
|---|---|---|
| Onde roda a produção e quem responde por ela | Sem responsável, o sistema oficial fica sem dono (risco nº 1 do arquivo 10) | pendente |
| Domínio da prefeitura, ex.: `sigadoc.araguaina.to.gov.br` | O HTTPS automático precisa do domínio apontado para a máquina | pendente |
| Conta de e-mail que envia as senhas (SMTP) | Em teste as mensagens ficam presas; em produção têm de chegar aos servidores | pendente |
| Planilha de servidores | Carga das pessoas | **adiada para o fim**, por decisão da SEMUS (12/11/2026); a produção sobe só com as unidades |

## 2. Máquina recomendada

- Oracle Cloud, região São Paulo, igual à de homologação: VM.Standard3.Flex com 2 OCPU e 16 GB ou mais, disco de 100 GB, Ubuntu 22.04. Também serve qualquer máquina da prefeitura com Docker.
- Portas abertas: 80 e 443 para todos, e 22 (SSH) só para o IP da TI.
- Um balde (bucket) no Object Storage para as cópias, de preferência noutra região.

## 3. Passo a passo da instalação

```bash
sudo git clone https://github.com/iagoadriano/taste-skill--designes /opt/sigadoc-repo
sudo ln -s /opt/sigadoc-repo/docs/integracao-sei-sics/implantacao /opt/sigadoc
cd /opt/sigadoc && sudo ./instalar.sh sigadoc.araguaina.to.gov.br
```

O instalador gera senhas novas no `.env`. Antes do primeiro uso, acrescente ao `.env` o e-mail real e o endereço público:

```
SMTP_HOST=smtp.seu-provedor
SMTP_USUARIO=sigadoc@araguaina.to.gov.br
SMTP_SENHA=...
SIGA_URL_PUBLICA=https://sigadoc.araguaina.to.gov.br
ALERTA_URL=...
BACKUP_REMOTO=...
```

e aplique com `sudo docker compose up -d`.

Depois, na ordem:

1. Cadastrar Araguaína (`estrutura/municipio-araguaina.sql`), liberar as permissões do administrador (`estrutura/perm3.js`) e carregar as 165 unidades (`estrutura/carregar_semus.js` sem o arquivo de pessoas). As pessoas entram no fim, com a planilha; o mesmo comando, rodado de novo com o `pessoas.json`, só acrescenta o que falta.
2. Criar dois usuários reais: o administrador da SEMUS (uma pessoa nomeada) e a **conta de integração do SICS** (pessoa "INTEGRACAO SICS" numa unidade de TI). Dar ao administrador as permissões de cadastro.
3. Liberar a anexação de PDFs para o órgão SEMUS (o carregador já faz isso).
4. `producao/desligar-contas-teste.sh`, primeiro sem e depois com `--aplicar`. Confirmar que ZZ99999 / Password1 não entra mais.
5. Agendar a cópia e o monitoramento (`producao/README.md`). Rodar `producao/backup.sh` e `producao/restaurar-teste.sh` uma vez e anotar os números.
6. Apontar o SICS para a produção, nos segredos do Base44: `SIGA_URL`, `SIGA_USUARIO` (a conta de integração nova), `SIGA_SENHA` e `SIGA_JWT_SECRET` (o valor de `SIGA_JWT_SECRET` no `.env` da produção). Quem digita é você, direto no Base44, não no chat.
7. Testar pelo SICS: criar memorando com PDF, assinar, tramitar para uma unidade e para uma pessoa, receber e abrir o PDF.

## 4. Lista de aceite da TI

- [ ] `https://` com cadeado válido; `http://` redireciona
- [ ] Contas ZZ… canceladas (decisão §7: mesma máquina); senhas do `.env` guardadas no cofre da TI
- [ ] E-mail de senha chega a um servidor de teste
- [ ] Cópia diária rodando; restauração testada com números conferidos; cópia também fora da máquina
- [ ] Alerta testado (parar o `appserver` por 10 minutos dispara o aviso)
- [ ] 165 unidades carregadas (pessoas: no fim, ver §6)
- [ ] Teste do item 7 aprovado pelo SICS
- [ ] Responsável e substituto nomeados

## 5. Mudanças no kit nesta fase

- `iniciar.sh` e `docker-compose.yml` aceitam e-mail real (`SMTP_*`). Sem essas variáveis, tudo continua como em teste. Testado contra o `standalone.xml` real do SIGA.
- Pasta `producao/` com cópia de segurança, restauração de teste, monitoramento e cancelamento das contas de teste. O endereço usado pelo monitoramento (`/siga/public/app/login`) foi conferido na homologação.

## 6. Pessoas: carga no fim

A SEMUS decidiu deixar a planilha de servidores para quando o resto estiver pronto. Até lá:

- a produção funciona com o administrador, a conta de integração e quem for cadastrado à mão pela tela do SIGA (Cadastros > Pessoa), uma pessoa por vez;
- o piloto (Fase 3) precisa só da equipe da Diretoria de Compras, umas poucas pessoas que dá para cadastrar assim;
- quando a planilha chegar, roda a conferência da Fase 1 e o carregador. Quem já foi cadastrado à mão é reconhecido pelo CPF e não duplica.

## 7. Decisão de 12/11/2026: a máquina de homologação vira a produção

A SEMUS decidiu usar a máquina da Oracle já instalada como produção e apagar os testes depois. Isso funciona sem bagunçar a numeração oficial:

- **Todos os documentos de teste são do órgão de teste** (siglas `ZZ-MEM-…`, `ZZ-OFI-…`, `ZZ-DES-…`), conferido na mesa da conta de integração. Os documentos reais da SEMUS saem como `SEMUS-MEM-2026/00001` em diante, numeração própria e limpa.
- "Apagar os testes" é cancelar as contas ZZ… (`producao/desligar-contas-teste.sh`). Os documentos de teste ficam no banco, mas ninguém da SEMUS os vê. O SIGA não apaga documento numerado, e apagar direto no banco arrisca o restante.

O que fazer, nesta ordem:

**Agora (na máquina, pelo Cloud Shell):**
1. `git pull` no repositório e `sudo docker compose up -d` em `implantacao/`. Isso também reinicia o SIGA, liberando o envio para pessoa.
2. No `.env`, acrescentar `SIGA_URL_PUBLICA=` com o endereço https atual e, assim que houver, o e-mail real (`SMTP_*`).
3. Agendar `producao/backup.sh` e `producao/verificar.sh` (ver `producao/README.md`). Rodar uma vez `backup.sh` e `restaurar-teste.sh`.

**Antes do primeiro documento real:**
4. Criar o administrador real da SEMUS e a pessoa "INTEGRACAO SICS" (cadastro à mão).
5. No Base44, trocar `SIGA_USUARIO`/`SIGA_SENHA` para a conta de integração nova. Em "Contas do SIGA", ligar cada e-mail do SICS à matrícula SEMUS da pessoa, no lugar de ZZ99999.
6. Rodar `producao/desligar-contas-teste.sh --aplicar`. Confirmar que ZZ99999 e ZZ99998 não entram mais. Isso também invalida as senhas de teste que passaram pelo chat.

**Depois (quando der):**
7. Trocar o endereço sslip.io por um domínio da prefeitura: `SIGA_DOMINIO` no `.env` e `SIGA_URL` no Base44.
8. Limitar o SSH (porta 22) ao IP da TI, na lista de segurança da Oracle.

Riscos aceitos: a máquina tem 4 OCPU e 64 GB, mais do que precisa (custo). Ela já teve senha de teste pública, e por isso o passo 6 é obrigatório antes do uso real.

## 8. Registro: conta de integração da SEMUS (12/11/2026)

- Criada a pessoa **INTEGRACAO SICS = SEMUS10011**, na DINF. O CPF é fictício (conta de sistema) e o e-mail não é entregável, de propósito.
- O SICS passa a emitir também o token da conta de integração com `SIGA_JWT_SECRET`, então essa conta não tem senha que precise ser guardada. Basta `SIGA_USUARIO=SEMUS10011` no Base44, e o segredo `SIGA_SENHA` pode ser apagado.
- O SICS na nuvem ainda usa ZZ99998 até alguém trocar `SIGA_USUARIO` no Base44.

## 9. Registro: administrador real (12/11/2026)

- Criado o administrador da SEMUS, **SEMUS10013**, na DINF. Ele recebeu as permissões de gestão de identidade e permissões, de cadastro (órgão, unidade, cargo, função, pessoa, feriado, marcador), de configurações, de modelos, do painel e de administração.
- O e-mail dele estava na conta de teste ZZ99999, porque foi usado no início da homologação. Voltou para o e-mail original da conta de teste. O SIGA não aceita o mesmo e-mail em dois CPFs.
- No SICS, "Contas do SIGA" agora liga o e-mail do administrador a SEMUS10013, no lugar de ZZ99999.
- A senha inicial foi para o servidor de e-mail de teste, porque o SMTP real ainda não está configurado. Ela é lida na própria máquina e nunca passa pelo chat.
