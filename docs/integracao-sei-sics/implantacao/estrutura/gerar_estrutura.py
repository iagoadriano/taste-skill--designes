"""Gera a lista de unidades da SEMUS para o SIGA a partir do organograma do 1Doc (arquivo 07)."""
import json, re, sys, unicodedata
txt = open(sys.argv[1], encoding='utf-8').read()
bloco = txt.split('```text', 1)[1].split('```', 1)[0]
linhas = [l for l in bloco.split('\n') if l.strip()]
NOME_OK = re.compile(r"[^'a-zA-ZàáâãéêíóôõúçÀÁÂÃÉÊÍÓÔÕÚÇ 0-9.,/-]")
def limpa_nome(n):
    n = n.replace('(', '- ').replace(')', '').replace('–', '-')
    n = unicodedata.normalize('NFC', n)
    n = ''.join(c if not NOME_OK.match(c) else (unicodedata.normalize('NFKD', c).encode('ascii', 'ignore').decode() or ' ') for c in n)
    return re.sub(r'\s+', ' ', n).strip().upper()[:100]
def base_sigla(s):
    s = re.sub(r'^SEMUS-', '', s.strip())
    s = unicodedata.normalize('NFKD', s).encode('ascii', 'ignore').decode().upper()
    s = re.sub(r'[^A-Z0-9-]', '', s.replace('/', '-'))
    return s or 'UNID'
STOP = {'DE','DA','DO','DOS','DAS','E','EM','A','O'}
def sufixo(nome, prefixo):
    palavras = [w for w in re.sub(r'[^A-Z0-9 ]', ' ', unicodedata.normalize('NFKD', nome).encode('ascii','ignore').decode().upper()).split() if w not in STOP]
    palavras = [w for w in palavras if w not in prefixo.split('-')]
    if prefixo.startswith('DAF-FARM'):
        palavras = [w for w in palavras if w not in ('FARMACIA',)]
        return ''.join(w[:4] if len(palavras) > 2 else w[:6] for w in palavras)[:11] or 'X'
    return ''.join(w[0] for w in palavras)[:6] or 'X'
itens, pilha, usadas = [], [], set()
for l in linhas:
    nivel = (len(l) - len(l.lstrip(' '))) // 2
    m = re.match(r'^(\S+) - (.*) \((\d+)\)$', l.strip())
    sigla_orig, nome, usuarios = m.group(1), m.group(2), int(m.group(3))
    s = base_sigla(sigla_orig)
    if s in usadas or sigla_orig == 'SEMUS-DAF-FARM' or (sigla_orig == 'SEMUS-COPEC' and any(i['sigla_1doc'] == sigla_orig for i in itens)):
        s = (s + '-' + sufixo(nome, s))[:20]
    n = 2
    while s in usadas:
        s = s[:18] + str(n); n += 1
    usadas.add(s)
    while len(pilha) > nivel: pilha.pop()
    pai = pilha[-1] if pilha else None
    itens.append({'sigla_1doc': sigla_orig, 'sigla': s, 'nome': limpa_nome(nome), 'pai': pai, 'usuarios_1doc': usuarios, 'nivel': nivel})
    pilha.append(s)
# Correcao estrutural apontada no arquivo 07: a Secretaria Executiva fica sob a SEMUS, nao sob a comissao do 1Doc.
for i in itens:
    if i['sigla'] == 'EXEC': i['pai'] = 'SEMUS'
raiz = next(i for i in itens if i['sigla'] == 'SEMUS'); raiz['sigla'] = 'GAB'; raiz['nome'] = 'SECRETARIA MUNICIPAL DE SAÚDE - GABINETE'
for i in itens:
    if i['pai'] == 'SEMUS': i['pai'] = 'GAB'
assert all(len(i['sigla']) <= 20 and re.fullmatch(r'[A-Z0-9-]+', i['sigla']) for i in itens)
assert len({i['sigla'] for i in itens}) == len(itens)
json.dump(itens, open(sys.argv[2], 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
print(len(itens), 'unidades')
for i in itens:
    if i['sigla_1doc'] in ('SEMUS-COPEC','SEMUS-DAF-FARM') or i['sigla'] in ('GAB','CSDOC','EXEC','GLICIT','ISAC/HMA'): print(' ', i['sigla_1doc'], '->', i['sigla'], '|', i['nome'][:45], '| pai', i['pai'])
