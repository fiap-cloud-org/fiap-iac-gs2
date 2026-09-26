#!/usr/bin/env bash
# Roda os scripts de user-data num container Amazon Linux 2 (a mesma base da AMI)
# e confere o resultado: Nagios Core compilado, login da interface web e agentes NCPA/SNMP.
# Uso: bash tests/user-data.sh [porta-local]   (padrão 18470)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPTS="$ROOT/terraform/modules/compute/scripts"
PORT="${1:-18470}"
PASSWORD="senha-de-teste-forte"
COMMUNITY="community-de-teste"
WORK="$(mktemp -d)"
CORE="fiap-iac-gs2-test-core"
AGENT="fiap-iac-gs2-test-agent"
trap 'docker rm -f "$CORE" "$AGENT" >/dev/null 2>&1 || true; rm -rf "$WORK"' EXIT

# Renderiza os templates como o templatefile() do Terraform faria
sed "s/\${nagios_admin_password}/$PASSWORD/" "$SCRIPTS/nagios-core.sh" > "$WORK/core.sh"
sed -e "s/\${snmp_community}/$COMMUNITY/" -e "s#\${snmp_source_cidr}#10.0.0.0/16#" "$SCRIPTS/nagios-agent.sh" > "$WORK/agent.sh"

# O container não tem systemd nem SELinux, e a imagem é mais enxuta que a AMI do EC2
cat > "$WORK/prepare.sh" <<'PREP'
for c in systemctl service setenforce; do printf '#!/bin/sh\necho "[stub] %s $*"\n' "$c" > "/usr/local/bin/$c"; chmod +x "/usr/local/bin/$c"; done
yum install -y -q shadow-utils procps-ng tar gzip iptables findutils which file >/dev/null 2>&1
PREP

ok() { echo "  ok   $1"; }
fail() { echo "  FALHA $1"; exit 1; }

echo "== agente (NCPA + SNMP)"
docker run -d --name "$AGENT" -v "$WORK":/ud amazonlinux:2 sleep 1800 >/dev/null
docker exec "$AGENT" bash -c 'source /ud/prepare.sh; bash /ud/agent.sh > /tmp/agent.log 2>&1'
docker exec "$AGENT" rpm -q ncpa >/dev/null && ok "NCPA instalado" || fail "NCPA não instalado"
docker exec "$AGENT" rpm -q net-snmp >/dev/null && ok "net-snmp instalado" || fail "net-snmp não instalado"
docker exec "$AGENT" grep -q "^rocommunity $COMMUNITY 10.0.0.0/16$" /etc/snmp/snmpd.conf && ok "community SNMP restrita à VPC do Nagios" || fail "community SNMP"

echo "== Nagios Core (compilação leva alguns minutos)"
docker run -d --name "$CORE" -p "127.0.0.1:$PORT:80" -v "$WORK":/ud amazonlinux:2 sleep 1800 >/dev/null
docker exec "$CORE" bash -c 'source /ud/prepare.sh; bash /ud/core.sh > /tmp/core.log 2>&1'
docker exec "$CORE" /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg | grep -q "Things look okay" && ok "configuração do Nagios válida (nagios -v)" || fail "nagios -v"
plugins=$(docker exec "$CORE" sh -c 'ls /usr/local/nagios/libexec | wc -l')
[ "$plugins" -gt 40 ] && ok "$plugins plugins instalados" || fail "plugins"
docker exec "$CORE" bash -c '/usr/sbin/httpd -k start 2>/dev/null; /usr/local/nagios/bin/nagios -d /usr/local/nagios/etc/nagios.cfg'
sleep 3
code() { curl -s -o /dev/null -w '%{http_code}' "$@"; }
[ "$(code "http://127.0.0.1:$PORT/")" = 200 ] && ok "GET / responde 200 (health check do ALB)" || fail "GET /"
[ "$(code "http://127.0.0.1:$PORT/nagios/")" = 401 ] && ok "/nagios sem senha: 401" || fail "/nagios sem senha"
[ "$(code -u nagiosadmin:nagiosadmin "http://127.0.0.1:$PORT/nagios/")" = 401 ] && ok "senha padrão nagiosadmin recusada" || fail "senha padrão aceita"
[ "$(code -u "nagiosadmin:$PASSWORD" "http://127.0.0.1:$PORT/nagios/")" = 200 ] && ok "/nagios com a senha da variável: 200" || fail "login"
curl -s -u "nagiosadmin:$PASSWORD" "http://127.0.0.1:$PORT/nagios/cgi-bin/statusjson.cgi?query=programstatus" | grep -q '"type_text": "Success"' && ok "CGI de status do Nagios respondendo" || fail "statusjson.cgi"

echo "Tudo certo."
