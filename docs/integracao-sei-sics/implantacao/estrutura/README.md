# Estrutura da SEMUS no SIGA-Doc

Cadastra no SIGA o órgão SEMUS, o cargo SERVIDOR, as 165 unidades do organograma do 1Doc (arquivo 07) com a hierarquia, e as pessoas informadas. Usa as mesmas telas de um administrador, e pode ser rodado de novo sem duplicar nada.

| Arquivo | Função |
|---|---|
| `gerar_estrutura.py` | Lê o organograma do arquivo 07 e gera `estrutura_semus.json`: siglas únicas (sem o prefixo SEMUS-, sem barra, até 20 caracteres), nomes nos caracteres aceitos pelo SIGA, Secretaria Executiva ligada direto à SEMUS (e não à comissão do 1Doc) |
| `estrutura_semus.json` | Resultado: 165 unidades, com sigla original do 1Doc, sigla no SIGA, nome e unidade-pai |
| `municipio-araguaina.sql` | Inclui Araguaína/TO, que não vem na carga inicial do SIGA e é obrigatória para cada unidade |
| `perm3.js` | Libera permissões de cadastro para o administrador pela tela de permissões do SIGA |
| `carregar_semus.js`, `sessao.js` | Fazem o cadastro |

No SIGA, a sigla completa da unidade é o órgão seguido da sigla: `GLICIT` vira `SEMUSGLICIT`.

Pessoas: passar um arquivo JSON com `nome`, `email`, `cpf` e `unidade` (sigla). O carregador cria a pessoa já com acesso; a senha vai por e-mail (no ambiente de teste, fica no servidor de e-mail interno). Para o SICS, a senha não é necessária.
