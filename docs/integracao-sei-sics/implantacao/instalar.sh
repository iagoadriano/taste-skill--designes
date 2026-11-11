#!/usr/bin/env bash
# Instala o SIGA-Doc de homologacao em uma maquina Linux com Docker.
# Uso: ./instalar.sh [dominio]   Exemplo: ./instalar.sh siga-teste.exemplo.gov.br
set -euo pipefail
cd "$(dirname "$0")"
command -v docker >/dev/null || { echo "Instale o Docker antes: https://docs.docker.com/engine/install/"; exit 1; }
docker compose version >/dev/null 2>&1 || { echo "Instale o plugin Docker Compose."; exit 1; }
DOCKER_COMMIT=$(sed -n 's/^ARG DOCKER_COMMIT=//p' Dockerfile)
[ -f mysql-init.sql ] || curl -fsSL -o mysql-init.sql "https://raw.githubusercontent.com/projeto-siga/siga-docker/${DOCKER_COMMIT}/mysql-init.sql"
if [ ! -f .env ]; then
  segredo() { openssl rand -hex 24; }
  umask 077
  cat > .env <<ENV
SIGA_JWT_SECRET=$(segredo)
SIGA_SINC_SENHA=$(segredo)
REDIS_SENHA=$(segredo)
MYSQL_SENHA=$(segredo)
SIGA_DOMINIO=${1:-:80}
SIGA_CARIMBO_URL=
SIGA_TITULO=Secretaria Municipal de Saúde
SIGA_MODELO_TITULO=PREFEITURA MUNICIPAL
SIGA_MODELO_SUBTITULO=SECRETARIA MUNICIPAL DE SAÚDE
ENV
  echo "Arquivo .env criado com senhas novas. Guarde uma copia em local seguro."
fi
echo "Compilando e subindo o SIGA-Doc. A primeira vez leva de 10 a 20 minutos."
docker compose up -d --build
echo "Aguardando o servidor iniciar..."
for _ in $(seq 1 60); do
  if docker compose logs appserver 2>/dev/null | grep -q WFLYSRV0025; then break; fi
  sleep 10
done
docker compose ps
cat <<'FIM'

SIGA-Doc no ar. Acesse /siga no endereco da maquina (ou no dominio informado).
Usuario de teste: ZZ99999   Senha: Password1
ATENCAO: essa senha e publica. Troque-a no primeiro acesso e mantenha o
firewall da maquina restrito aos enderecos de quem vai testar.
FIM
