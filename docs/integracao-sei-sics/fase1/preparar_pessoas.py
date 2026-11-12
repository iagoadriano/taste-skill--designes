"""Fase 1: confere a planilha de servidores e gera pessoas.json para o carregador do SIGA.

Uso: python3 preparar_pessoas.py servidores.csv [saida.json]
Planilha (CSV, separador ; ou ,): nome;cpf;email;unidade
  unidade = sigla do 1Doc (ex.: SEMUS-GLICIT) ou sigla no SIGA (ex.: GLICIT).
Nada é enviado a lugar nenhum: só lê a planilha e aponta os problemas linha a linha.
"""
import csv, json, os, re, sys, unicodedata

AQUI = os.path.dirname(os.path.abspath(__file__))
UNIDADES = json.load(open(os.path.join(AQUI, '..', 'implantacao', 'estrutura', 'estrutura_semus.json'), encoding='utf-8'))
POR_SIGLA = {}
for u in UNIDADES:
    POR_SIGLA[u['sigla'].upper()] = u['sigla']
    POR_SIGLA[u['sigla_1doc'].upper()] = u['sigla']


def cpf_valido(c):
    if len(c) != 11 or c == c[0] * 11:
        return False
    for n in (9, 10):
        s = sum(int(c[i]) * (n + 1 - i) for i in range(n))
        if (s * 10 % 11) % 10 != int(c[n]):
            return False
    return True


def nome_siga(n):
    # O SIGA aceita só letras sem acento estranho, espaço e alguns sinais; guarda em maiúsculas.
    n = re.sub(r'\s+', ' ', n).strip().upper()
    return ''.join(ch for ch in n if ch.isalpha() or ch in " '-.")


def main(entrada, saida):
    texto = open(entrada, encoding='utf-8-sig').read()
    dialeto = csv.Sniffer().sniff(texto.splitlines()[0], delimiters=';,')
    linhas = list(csv.DictReader(texto.splitlines(), dialect=dialeto))
    pessoas, erros, vistos_cpf, vistos_email = [], [], set(), set()
    for i, l in enumerate(linhas, start=2):
        l = {k.strip().lower(): (v or '').strip() for k, v in l.items() if k}
        nome = nome_siga(l.get('nome', ''))
        cpf = re.sub(r'\D', '', l.get('cpf', ''))
        email = l.get('email', '').lower()
        un = POR_SIGLA.get(l.get('unidade', '').upper().replace(' ', ''))
        prob = []
        if len(nome.split()) < 2: prob.append('nome completo')
        if not cpf_valido(cpf): prob.append('CPF inválido')
        elif cpf in vistos_cpf: prob.append('CPF repetido')
        if not re.fullmatch(r'[^\s@]+@[^\s@]+\.[^\s@]+', email): prob.append('e-mail inválido')
        elif email in vistos_email: prob.append('e-mail repetido')
        if not un: prob.append(f"unidade '{l.get('unidade', '')}' não existe no organograma")
        if prob:
            erros.append(f'linha {i} ({nome or "sem nome"}): ' + ', '.join(prob))
            continue
        vistos_cpf.add(cpf); vistos_email.add(email)
        pessoas.append({'nome': nome, 'cpf': cpf, 'email': email, 'unidade': un})
    json.dump(pessoas, open(saida, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    print(f'{len(pessoas)} pessoa(s) prontas em {saida}; {len(erros)} linha(s) com problema.')
    for e in erros:
        print('  -', e)
    return 1 if erros else 0


if __name__ == '__main__':
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    sys.exit(main(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else 'pessoas.json'))
