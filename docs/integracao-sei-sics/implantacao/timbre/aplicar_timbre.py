"""Aplica o timbre do SICS (Documentos e Identidade Visual) aos modelos do SIGA-Doc.

Roda na compilacao (Dockerfile), sobre o codigo-fonte do SIGA:
  python3 aplicar_timbre.py /src /timbre
- copia as imagens do timbre para o sigaex (ficam em /sigaex/imagens/);
- troca o cabecalho centralizado (brasao + titulos) pela faixa superior do timbre;
- acrescenta a faixa inferior do timbre no rodape da primeira pagina.
So mexe nos modelos de cabecalho centralizado (memorando, oficio, despacho etc.).
Se o codigo do SIGA mudar e um trecho nao for encontrado, a compilacao para com erro.
"""
import re, shutil, sys
from pathlib import Path

src, timbre = Path(sys.argv[1]), Path(sys.argv[2])
ftl = src / 'siga-ex/src/main/resources/br/gov/jfrj/siga/ex/util/default.ftl'
imagens = src / 'sigaex/src/main/webapp/imagens'
CAB = '<img src="contextpath/imagens/timbre-sics-cabecalho.png" width="530" height="80" />'
ROD = '<img src="contextpath/imagens/timbre-sics-rodape.png" width="530" height="66" />'

for nome in ('timbre-sics-cabecalho.png', 'timbre-sics-rodape.png'):
    shutil.copy(timbre / nome, imagens / nome)

t = ftl.read_text(encoding='utf-8')


def macro(nome):
    m = re.search(r'\[#macro ' + re.escape(nome) + r'[ \]].*?\[/#macro\]', t, re.S)
    if not m:
        sys.exit('timbre: macro nao encontrada: ' + nome)
    return m


def trocar(nome, fn):
    global t
    m = macro(nome)
    novo = fn(m.group(0))
    if novo == m.group(0):
        sys.exit('timbre: nada mudou na macro ' + nome)
    t = t[:m.start()] + novo + t[m.end():]


def sub1(padrao, novo, texto, flags=0):
    r, n = re.subn(padrao, lambda _m: novo, texto, count=1, flags=flags)
    if n != 1:
        sys.exit('timbre: trecho nao encontrado: ' + padrao)
    return r


def sem_titulos(c):
    c = sub1(r'\[#if _subtituloGeral\?has_content\]', '[#if false]', c)
    return sub1(r'\[#if orgaoCabecalho\?\? && orgaoCabecalho\]', '[#if false]', c)


def primeira(c):
    c = sub1(r'<img src="\$\{_pathBrasao\}"[^>]*/>', CAB, c)
    c = sub1(r'<tr>\s*<td width="100%" align="center">\s*<p[^>]*>\$\{_tituloGeral\}</p>\s*</td>\s*</tr>', '', c)
    return sem_titulos(c)


def demais(c):
    c = sub1(r'<p[^>]*>\$\{_tituloGeral\}</p>', CAB, c)
    return sem_titulos(c)


def rodape(c):
    # ultima ocorrencia de "[#if !somenteTR]\n</table>": fecha a tabela do rodape
    i = c.rfind('[#if !somenteTR]')
    if i < 0 or '</table>' not in c[i:]:
        sys.exit('timbre: fim do rodape nao encontrado')
    linha = '[#if !somenteTR]<tr><td colspan="2" align="center">' + ROD + '</td></tr>[/#if]\n'
    return c[:i] + linha + c[i:]


trocar('cabecalhoCentralizadoPrimeiraPagina', primeira)
trocar('cabecalhoCentralizado', demais)
trocar('rodapeClassificacaoDocumental', rodape)
ftl.write_text(t, encoding='utf-8')
print('timbre do SICS aplicado aos modelos do SIGA')
