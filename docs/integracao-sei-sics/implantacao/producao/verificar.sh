#!/usr/bin/env bash
# Monitoramento simples: SIGA respondendo, disco, e idade da ultima copia.
# Uso: producao/verificar.sh   (cron a cada 5 min). Sai com codigo 1 se algo falhar.
# ALERTA_URL opcional no .env: recebe um POST com o texto do problema
# (ex.: webhook do Google Chat/Teams/Slack, ou ntfy.sh/<topico-secreto>).
set -uo pipefail
cd "$(dirname "$0")/.."
set -a; . ./.env; set +a
problemas=()
URL=${SIGA_URL_PUBLICA:-http://localhost}
codigo=$(curl -s -o /dev/null -w '%{http_code}' --max-time 20 "$URL/siga/public/app/login") || codigo=000
[ "$codigo" = 200 ] || problemas+=("SIGA nao responde ($URL, HTTP $codigo)")
for s in appserver mysqlserver redisserver entrada; do
  [ "$(docker compose ps -q "$s" | xargs -r docker inspect -f '{{.State.Running}}' 2>/dev/null)" = true ] || problemas+=("servico $s parado")
done
uso=$(df --output=pcent / | tail -1 | tr -dc 0-9); [ "$uso" -lt 85 ] || problemas+=("disco em ${uso}%")
ult=$(ls -1t "${BACKUP_DIR:-/var/backups/sigadoc}"/sigadoc-*.sql.gz 2>/dev/null | head -1)
if [ -z "$ult" ] || [ $(( $(date +%s) - $(stat -c %Y "$ult") )) -gt 108000 ]; then problemas+=("sem copia de seguranca nas ultimas 30h"); fi
if [ ${#problemas[@]} -eq 0 ]; then echo "ok $(date '+%F %T')"; exit 0; fi
msg="SIGA-Doc SEMUS: $(IFS='; '; echo "${problemas[*]}")"
echo "$msg" >&2
[ -n "${ALERTA_URL:-}" ] && curl -s -m 15 -d "$msg" "$ALERTA_URL" >/dev/null
exit 1
