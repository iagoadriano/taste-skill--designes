# 15. Fase 3: piloto na Diretoria de Compras

Objetivo (arquivo 10, §3): a Diretoria de Compras passa a usar o SIGA-Doc, por dentro do SICS. Critério de saída: um mês sem pendência grave.

## 1. O que mudou no SICS para o piloto (12/11/2026)

- A Mesa Virtual SIGA-Doc deixou de ser só do administrador e virou um **módulo** do SICS ("Mesa Virtual SIGA-Doc", chave `SigaDoc`). Ele é concedido como os outros módulos: no perfil personalizado ou como módulo extra do usuário.
- Para usar, a pessoa precisa de duas coisas, conferidas pela função `sigaDoc` em toda chamada:
  1. ter o módulo SigaDoc (lido do banco, não do navegador);
  2. existir no SIGA com o mesmo e-mail do SICS, ou estar ligada em "Contas do SIGA".

  Ela age sempre em nome próprio. Quem não é administrador nunca usa a conta de integração.
- "Contas do SIGA" continua só para administradores.
- A aba SIGA-Doc do dossiê segue a mesma regra do módulo.
- Saíram os avisos de "homologação" e de "SIGA-Doc de teste".

## 2. Roteiro do piloto

| Passo | Quem | Como |
|---|---|---|
| 1. Cadastrar cada participante no SIGA | Administrador (SEMUS10013) | SIGA > Cadastros > Pessoa. Unidade certa, **mesmo e-mail do SICS**, e marcar o envio da senha por e-mail |
| 2. Liberar o módulo no SICS | Administrador do SICS | Perfil do usuário > módulos > "Mesa Virtual SIGA-Doc" |
| 3. Conferir | Participante | Entrar no SICS, abrir a Mesa Virtual e ver "Você está como: SEMUS… · NOME" |
| 4. Primeiro documento real | Participante | Criar documento > memorando, assinar e tramitar. O número esperado é `SEMUS-MEM-2026/00001` |
| 5. Uso diário | Equipe | Receber, assinar e tramitar pela Mesa, e documentos de licitação pela aba SIGA-Doc do dossiê |
| 6. Acompanhamento semanal | Administrador | Lista de problemas; ajustes no SICS |

## 3. O que observar no mês

- Documentos chegando à mesa certa (unidade e pessoa).
- PDFs anexados abrindo no SIGA e no SICS.
- E-mails do SIGA chegando (senha e avisos).
- Alertas do `verificar.sh` e cópia diária presente.
- O que a equipe ainda faz no 1Doc, e por quê.

## 4. Limites conhecidos (vindos da Fase 0)

- Processo, despacho e documento externo não são criados pela API do SIGA 11.5. Ficam na tela do SIGA, que o SICS abre pelo link. O SICS cria memorandos com PDFs anexados.
- A tramitação só é aceita depois da assinatura.
