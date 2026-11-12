#!/usr/bin/env bash
# Prova que a copia de seguranca restaura: carrega a copia num MySQL descartavel
# (nao toca no banco de producao) e conta documentos e pessoas.
# Uso: producao/restaurar-teste.sh [arquivo.sql.gz]   (padrao: a copia mais recente)
set -euo pipefail
cd "$(dirname "$0")/.."
set -a; . ./.env; set +a
ARQ=${1:-$(ls -1t "${BACKUP_DIR:-/var/backups/sigadoc}"/sigadoc-*.sql.gz | head -1)}
NOME=sigadoc-restauro-$$; SENHA=$(openssl rand -hex 12)
docker run -d --rm --name "$NOME" -e MYSQL_ROOT_PASSWORD="$SENHA" mysql:8.0.21 >/dev/null
trap 'docker rm -f "$NOME" >/dev/null 2>&1' EXIT
for _ in $(seq 1 60); do docker exec "$NOME" mysqladmin ping -uroot -p"$SENHA" --silent 2>/dev/null && break; sleep 3; done
echo "Restaurando $ARQ ..."
gzip -dc "$ARQ" | docker exec -i "$NOME" mysql -uroot -p"$SENHA" --default-character-set=utf8mb4 2>/dev/null
docker exec "$NOME" mysql -uroot -p"$SENHA" -N -e "
  SELECT 'documentos', COUNT(*) FROM siga.ex_documento;
  SELECT 'movimentacoes', COUNT(*) FROM siga.ex_movimentacao;
  SELECT 'pessoas ativas', COUNT(*) FROM corporativo.dp_pessoa WHERE DATA_FIM_PESSOA IS NULL;
  SELECT 'unidades ativas', COUNT(*) FROM corporativo.dp_lotacao WHERE DATA_FIM_LOT IS NULL;" 2>/dev/null
echo "Restauracao OK. Compare os numeros com a producao."
