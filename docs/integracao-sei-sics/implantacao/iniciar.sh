#!/bin/sh
# Aplica os segredos e a identidade da instituicao na configuracao e inicia o servidor.
set -eu
CFG="${JBOSS_HOME}/standalone/configuration/standalone.xml"
cp "${CFG}.modelo" "${CFG}"
prop() { sed -i "s|<property name=\"$1\" value=\"[^\"]*\"/>|<property name=\"$1\" value=\"$2\"/>|" "${CFG}"; }
: "${SIGA_JWT_SECRET:?defina SIGA_JWT_SECRET}" "${SIGA_SINC_SENHA:?defina SIGA_SINC_SENHA}"
: "${REDIS_SENHA:?defina REDIS_SENHA}" "${MYSQL_SENHA:?defina MYSQL_SENHA}"
prop siga.jwt.secret "${SIGA_JWT_SECRET}"
prop siga.sinc.password "${SIGA_SINC_SENHA}"
prop sigaex.redis.password "${REDIS_SENHA}"
sed -i "s|<password>siga</password>|<password>${MYSQL_SENHA}</password>|g" "${CFG}"
# Carimbo de tempo: sem URL definida, a assinatura com senha funciona sem carimbo.
if [ -n "${SIGA_CARIMBO_URL:-}" ]; then prop sigaex.carimbo.url "${SIGA_CARIMBO_URL}"; else sed -i '/sigaex.carimbo.url/d' "${CFG}"; fi
# Atras de um proxy HTTPS, o servidor deve confiar no endereco e protocolo encaminhados.
sed -i 's|<http-listener name="default" socket-binding="http"|<http-listener name="default" socket-binding="http" proxy-address-forwarding="true"|' "${CFG}"
prop siga.cabecalho.titulo "${SIGA_TITULO:-Secretaria Municipal de Saúde}"
prop sigaex.modelos.cabecalho.titulo "${SIGA_MODELO_TITULO:-PREFEITURA MUNICIPAL}"
prop sigaex.modelos.cabecalho.subtitulo "${SIGA_MODELO_SUBTITULO:-SECRETARIA MUNICIPAL DE SAÚDE}"
prop siga.relat.titulo "${SIGA_MODELO_TITULO:-PREFEITURA MUNICIPAL}"
prop siga.relat.subtitulo "${SIGA_MODELO_SUBTITULO:-SECRETARIA MUNICIPAL DE SAÚDE}"
prop sigaex.carimbo.texto.superior "${SIGA_TITULO:-Secretaria Municipal de Saúde}"
if grep -v '<!--' "${CFG}" | grep -q 'REPLACE-WITH-RANDOM-GUID'; then echo "Ainda ha segredo padrao na configuracao" >&2; exit 1; fi
exec "${JBOSS_HOME}/bin/standalone.sh" -b 0.0.0.0
