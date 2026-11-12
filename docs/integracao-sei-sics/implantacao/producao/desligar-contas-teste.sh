#!/usr/bin/env bash
# Cancela o acesso das contas de teste que vem com o SIGA (ZZ...), cuja senha e publica.
# Rode SO depois de existir um administrador real da SEMUS e a conta de integracao do SICS.
# Uso: producao/desligar-contas-teste.sh          (mostra o que seria cancelado)
#      producao/desligar-contas-teste.sh --aplicar (cancela)
set -euo pipefail
cd "$(dirname "$0")/.."
sql() { docker compose exec -T mysqlserver sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -N corporativo 2>/dev/null' <<<"$1"; }
FILTRO="LOGIN_IDENTIDADE LIKE 'ZZ%' AND DATA_CANCELAMENTO_IDENTIDADE IS NULL AND HIS_DT_FIM IS NULL"
echo "Contas de teste com acesso:"; sql "SELECT LOGIN_IDENTIDADE FROM cp_identidade WHERE $FILTRO ORDER BY 1;" | tr '\n' ' '; echo
outros=$(sql "SELECT COUNT(*) FROM cp_identidade WHERE LOGIN_IDENTIDADE NOT LIKE 'ZZ%' AND DATA_CANCELAMENTO_IDENTIDADE IS NULL AND HIS_DT_FIM IS NULL;")
echo "Outras contas com acesso: $outros"
[ "${1:-}" = --aplicar ] || { echo "Nada alterado. Para cancelar: $0 --aplicar"; exit 0; }
[ "$outros" -ge 2 ] || { echo "Recusado: crie antes o administrador real e a conta de integracao (precisa de pelo menos 2 outras contas)."; exit 1; }
sql "UPDATE cp_identidade SET DATA_CANCELAMENTO_IDENTIDADE = NOW() WHERE $FILTRO;"
echo "Cancelado. Confira: tentar entrar com ZZ99999 / Password1 deve falhar."
