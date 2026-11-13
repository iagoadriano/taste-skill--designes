# 16. Fase 4: integração completa (etapas D3, D4 e D5)

Objetivo (arquivo 10, §3): documentos do SICS chegando ao SIGA sem digitação repetida, e o acompanhamento voltando sozinho para o dossiê. Critério de saída atendido no SICS; falta o uso real do piloto confirmar.

## 1. Situação das etapas

| Etapa | O que é | Situação |
|---|---|---|
| D3 | Acompanhamento agendado: lê as movimentações do SIGA e grava na linha do tempo do dossiê | **Pronto** (13/11/2026) |
| D4 | Criar memorando a partir do dossiê, anexar PDFs e tramitar | Pronto antes (arquivo 10, §11) |
| D5 | O SIGA passa a valer como protocolo oficial onde antes se exigia o 1Doc | **Pronto** (13/11/2026) |

## 2. D3 — acompanhamento agendado

- Nova função de backend `sigaAcompanhar`. Para cada dossiê que tem um número do SIGA vinculado (referência do tipo `siga`), ela lê as movimentações no SIGA com a conta de integração e grava as novidades na linha do tempo do dossiê (`ProcessEvent`). Cada movimentação entra uma única vez (dedup por `event_key`). **Só leitura**; não escreve nada no SIGA.
- Também registra a situação atual ("onde está") quando muda.
- Rodada por um workflow agendado do Base44, "Acompanhamento SIGA-Doc", às 8h, 11h, 14h e 17h de Araguaína (`0 11,14,17,20 * * *` UTC). A função confere um segredo próprio (só o hash SHA-256 fica no código, no padrão das outras rotinas do SICS); o segredo em claro fica no workflow e fora do repositório.
- Verificado: a função foi criada, o workflow executado à mão terminou com sucesso (HTTP 200) e devolveu o resumo `{dossies, consultados, novidades, falhas}`. Como ainda não há dossiê com documento do SIGA vinculado, o primeiro resultado foi `dossies:0`. Quando o piloto vincular um documento, a rotina o capta.

## 3. D5 — SIGA como protocolo oficial

- O tipo de referência `siga` ("SIGA-Doc") deixou de ficar escondido e agora pode ser registrado no bloco de referências do dossiê, ao lado do 1Doc. O texto do bloco diz que o SIGA-Doc vale como protocolo oficial onde antes se exigia o 1Doc.
- Os campos de "protocolo / ofício no 1Doc" nos fluxos de credenciamento e afins são texto livre e já aceitam um número do SIGA; nenhuma trava obrigava o 1Doc.
- A aba SIGA-Doc do dossiê continua com o vínculo que confere o número no SIGA antes de gravar; o bloco geral permite o registro manual, como no 1Doc.
- Verificado: 27 testes passando (referências e cliente do SIGA), lint sem erros, compilação do SICS concluída.

## 4. Pendências para fechar a fase

- Uso real do piloto por um período, confirmando movimentações chegando ao dossiê sozinhas.
- HTTPS por domínio da prefeitura antes de dados reais (a conta de integração ainda trafega por sslip.io).
