#!/usr/bin/env bash
# Copia de seguranca diaria do SIGA-Doc. Os documentos e PDFs ficam no banco
# (armazenamento TABELA), entao a copia do banco cobre tudo.
# Uso: producao/backup.sh   (agendado pelo cron; ver README)
# Variaveis opcionais no .env: BACKUP_DIR (padrao /var/backups/sigadoc),
#   BACKUP_DIAS (padrao 30), BACKUP_REMOTO (destino do rclone, ex.: oci:sigadoc-backup)
set -euo pipefail
cd "$(dirname "$0")/.."
set -a; . ./.env; set +a
DIR=${BACKUP_DIR:-/var/backups/sigadoc}; DIAS=${BACKUP_DIAS:-30}
mkdir -p "$DIR"; chmod 700 "$DIR"
ARQ="$DIR/sigadoc-$(date +%Y%m%d-%H%M).sql.gz"
docker compose exec -T mysqlserver sh -c 'exec mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" --single-transaction --routines --triggers --events --default-character-set=utf8mb4 --databases corporativo siga sigawf sigasr sigagc sigatp 2>/dev/null' | gzip -9 > "$ARQ.parcial"
# Copia vazia ou truncada nao conta como copia.
[ "$(gzip -dc "$ARQ.parcial" | tail -c 200 | grep -c 'Dump completed')" = 1 ] || { rm -f "$ARQ.parcial"; echo "FALHA: copia incompleta" >&2; exit 1; }
mv "$ARQ.parcial" "$ARQ"
cp .env "$DIR/env-copia"; chmod 600 "$DIR"/*
find "$DIR" -name 'sigadoc-*.sql.gz' -mtime +"$DIAS" -delete
if [ -n "${BACKUP_REMOTO:-}" ]; then rclone copy "$ARQ" "$BACKUP_REMOTO/" && echo "copiado para $BACKUP_REMOTO"; fi
echo "ok $ARQ $(du -h "$ARQ" | cut -f1)"
