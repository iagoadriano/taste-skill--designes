# Kit de instalação do SIGA-Doc (homologação)

Sobe o SIGA-Doc 11.5 completo em uma máquina virtual com um comando. É o mesmo arranjo validado na Fase 0 (arquivo 12), com três diferenças: senhas geradas na instalação, dados do banco preservados entre reinícios e uma porta de entrada com HTTPS.

**O que foi testado e o que não foi.** A etapa final da imagem, o `iniciar.sh`, o `docker-compose.yml` e o `instalar.sh` foram executados de ponta a ponta em ambiente de teste: o SIGA respondeu pela porta de entrada e um memorando foi criado, assinado e tramitado pela API. A etapa de compilação dentro do `Dockerfile` não foi executada como está escrita; o mesmo comando de compilação, na mesma imagem, foi executado em separado e funcionou, e o download do código pelo commit fixado foi conferido. O HTTPS automático com domínio não foi testado.

## 1. Máquina necessária

| Item | Mínimo | Observação |
|---|---|---|
| Processador | 4 vCPU, arquitetura x86-64 (AMD/Intel) | As imagens usadas não têm versão ARM |
| Memória | 8 GB | Em uso ocioso o SIGA ocupou cerca de 3 GB; a compilação pede mais |
| Disco | 60 GB | Código, imagens, banco e arquivos |
| Sistema | Ubuntu Server 22.04 ou 24.04 | Qualquer Linux com Docker serve |
| Rede | IP público fixo; portas 80 e 443 abertas | Restrinja a origem aos endereços de quem vai testar |
| Domínio (opcional) | Um nome apontando para o IP | Necessário para o HTTPS automático |

Qualquer provedor de nuvem atende. Não precisa de serviço gerenciado de banco: o MySQL roda na própria máquina.

## 2. Instalação

Na máquina, com um usuário que possa usar `sudo`:

```bash
curl -fsSL https://get.docker.com | sudo sh
```

```bash
git clone -b claude/compassionate-brahmagupta-9iebcb https://github.com/iagoadriano/taste-skill--designes.git
```

```bash
cd taste-skill--designes/docs/integracao-sei-sics/implantacao && sudo ./instalar.sh
```

Com domínio, troque o último comando por:

```bash
cd taste-skill--designes/docs/integracao-sei-sics/implantacao && sudo ./instalar.sh siga-teste.seudominio.gov.br
```

A primeira execução compila o SIGA e leva de 10 a 20 minutos. Ao final, acesse `/siga` no endereço da máquina com o usuário de teste `ZZ99999` e a senha `Password1`.

## 3. Logo depois de instalar

1. **Troque a senha do usuário de teste.** Ela é pública, está na documentação do SIGA.
2. **Guarde uma cópia do arquivo `.env`.** Ele contém as senhas geradas; sem ele não se recupera o acesso ao banco.
3. **Confirme o firewall.** Só as portas 80 e 443, e só para os endereços dos testadores. O banco e o servidor de aplicação não ficam expostos.

## 4. O que cada arquivo faz

| Arquivo | Função |
|---|---|
| `instalar.sh` | Confere o Docker, gera o `.env` com senhas novas, baixa o script inicial do banco, compila e sobe tudo |
| `Dockerfile` | Compila o SIGA no commit fixado da versão 11.5 e monta o servidor de aplicação (JBoss EAP 7.2.5, Java 8) |
| `iniciar.sh` | Na partida do servidor, aplica senhas e nome da instituição na configuração e desliga o carimbo de tempo externo se nenhuma URL for informada |
| `docker-compose.yml` | Define os serviços: SIGA, MySQL 8.0.21, Redis, e-mail de teste e a porta de entrada (Caddy) |
| `Caddyfile` | Encaminha o tráfego para o SIGA e, com domínio, obtém o certificado HTTPS |

## 5. Operação básica

```bash
sudo docker compose ps
```

```bash
sudo docker compose logs -f appserver
```

```bash
sudo docker compose restart appserver
```

Cópia de segurança do banco (gera um arquivo com todos os dados):

```bash
sudo docker compose exec -T mysqlserver sh -c 'mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" --all-databases' > siga-backup-$(date +%F).sql
```

## 6. Limites deste kit

- É para **homologação**. Para produção faltam: rotina automática de cópia de segurança fora da máquina, monitoramento, servidor de e-mail real, decisão sobre o carimbo de tempo e revisão de segurança.
- O e-mail é capturado por um servidor de teste e não sai da máquina.
- Só os módulos de identidade, documentos e workflow são implantados.
- A identidade visual dos modelos ainda traz o brasão padrão do SIGA; os textos de cabeçalho já saem como "Secretaria Municipal de Saúde" e podem ser alterados no `.env`.
