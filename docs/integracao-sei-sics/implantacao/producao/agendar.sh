#!/usr/bin/env bash
# Agenda a copia diaria (2h) e o monitoramento (a cada 5 min) no cron do root.
# Pode rodar de novo: troca as linhas antigas do SIGA-Doc em vez de duplicar.
# Uso: sudo producao/agendar.sh
set -euo pipefail
[ "$(id -u)" = 0 ] || { echo "Rode com sudo."; exit 1; }
AQUI=$(cd "$(dirname "$0")" && pwd)
chmod +x "$AQUI"/*.sh
atual=$(crontab -l 2>/dev/null | grep -v '# sigadoc' || true)
{
  [ -n "$atual" ] && printf '%s\n' "$atual"
  echo "0 2 * * * $AQUI/backup.sh >> /var/log/sigadoc-backup.log 2>&1 # sigadoc"
  echo "*/5 * * * * $AQUI/verificar.sh >> /var/log/sigadoc-verificar.log 2>&1 # sigadoc"
} | crontab -
echo "Agendado:"; crontab -l | grep '# sigadoc'
echo; echo "Conferencia agora:"; "$AQUI/verificar.sh" || echo "(verificar.sh apontou o problema acima)"
