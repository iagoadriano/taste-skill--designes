# 14. Fase 2: ambiente de produção

Objetivo (arquivo 10, §3): SIGA-Doc em produção com HTTPS, cópia de segurança e monitoramento, e com unidades e pessoas carregadas. Critério de saída: ambiente aceito pela TI.

A máquina da Oracle usada até agora continua sendo a de **homologação**, onde se testa antes de mexer na produção. A produção é uma máquina nova e limpa: nada de dado fictício, nem de senha que já passou por chat.

## 1. O que precisa estar decidido (vem da Fase 1)

| Item | Por quê | Situação |
|---|---|---|
| Onde roda a produção e quem responde por ela | Sem responsável, o sistema oficial fica sem dono (risco nº 1 do arquivo 10) | pendente |
| Domínio da prefeitura, ex.: `sigadoc.araguaina.to.gov.br` | O HTTPS automático precisa do domínio apontado para a máquina | pendente |
| Conta de e-mail que envia as senhas (SMTP) | Em teste as mensagens ficam presas; em produção têm de chegar aos servidores | pendente |
| Planilha de servidores conferida | Carga das pessoas | pendente |

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

1. Cadastrar Araguaína (`estrutura/municipio-araguaina.sql`), liberar as permissões do administrador (`estrutura/perm3.js`) e carregar as 165 unidades e as pessoas (`estrutura/carregar_semus.js` com o `pessoas.json` da Fase 1).
2. Criar dois usuários reais: o administrador da SEMUS (uma pessoa nomeada) e a **conta de integração do SICS** (pessoa "INTEGRACAO SICS" numa unidade de TI). Dar ao administrador as permissões de cadastro.
3. Liberar a anexação de PDFs para o órgão SEMUS (o carregador já faz isso).
4. `producao/desligar-contas-teste.sh`, primeiro sem e depois com `--aplicar`. Confirmar que ZZ99999 / Password1 não entra mais.
5. Agendar a cópia e o monitoramento (`producao/README.md`). Rodar `producao/backup.sh` e `producao/restaurar-teste.sh` uma vez e anotar os números.
6. Apontar o SICS para a produção, nos segredos do Base44: `SIGA_URL`, `SIGA_USUARIO` (a conta de integração nova), `SIGA_SENHA` e `SIGA_JWT_SECRET` (o valor de `SIGA_JWT_SECRET` no `.env` da produção). Quem digita é você, direto no Base44, não no chat.
7. Testar pelo SICS: criar memorando com PDF, assinar, tramitar para uma unidade e para uma pessoa, receber e abrir o PDF.

## 4. Lista de aceite da TI

- [ ] `https://` com cadeado válido; `http://` redireciona
- [ ] Contas ZZ… canceladas; senhas do `.env` guardadas no cofre da TI
- [ ] E-mail de senha chega a um servidor de teste
- [ ] Cópia diária rodando; restauração testada com números conferidos; cópia também fora da máquina
- [ ] Alerta testado (parar o `appserver` por 10 minutos dispara o aviso)
- [ ] 165 unidades e as pessoas da planilha carregadas
- [ ] Teste do item 7 aprovado pelo SICS
- [ ] Responsável e substituto nomeados

## 5. Mudanças no kit nesta fase

- `iniciar.sh` e `docker-compose.yml` aceitam e-mail real (`SMTP_*`). Sem essas variáveis, tudo continua como em teste. Testado contra o `standalone.xml` real do SIGA.
- Pasta `producao/` com cópia de segurança, restauração de teste, monitoramento e cancelamento das contas de teste. O endereço usado pelo monitoramento (`/siga/public/app/login`) foi conferido na homologação.
