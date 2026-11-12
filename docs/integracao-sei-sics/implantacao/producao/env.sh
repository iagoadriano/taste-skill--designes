# Carrega o .env sem executa-lo como script: aceita valores com espacos,
# com ou sem aspas (instalacoes antigas gravaram sem aspas).
while IFS= read -r linha || [ -n "$linha" ]; do
  case "$linha" in ''|'#'*) continue ;; esac
  chave=${linha%%=*}; valor=${linha#*=}
  [[ "$chave" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || continue
  if [[ "$valor" == \"*\" || "$valor" == \'*\' ]]; then valor=${valor:1:${#valor}-2}; fi
  export "$chave=$valor"
done < .env
