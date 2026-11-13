# SIGA-Doc no SICS — guia do administrador

## Cadastrar um servidor no SIGA

No SIGA, **Cadastros > Pessoa > Incluir**:
- Nome, CPF, **e-mail (o mesmo que a pessoa usa no SICS)** e a unidade (lotação) correta.
- Marque o envio de e-mail: a pessoa recebe a senha inicial por e-mail (enviado pelo Resend, remetente `no-reply@sics-saude.com`).

A matrícula sai no formato `SEMUS` + número (ex.: `SEMUS10020`).

## Liberar o módulo no SICS

No perfil do usuário (ou no perfil personalizado dele), marque o módulo **"Mesa Virtual SIGA-Doc"**. Sem isso, a pessoa vê "Acesso restrito".

## Ligar conta do SICS à pessoa do SIGA

Se o e-mail do SICS for igual ao do SIGA, a ligação é automática. Se forem diferentes, abra **Mesa Virtual SIGA-Doc > Contas do SIGA** e ligue o e-mail do SICS à matrícula do SIGA.

> "Contas do SIGA" é só para administradores. Cada pessoa age sempre no próprio nome; ninguém usa a conta de integração.

## Permissões no SIGA

A pessoa comum não precisa de permissões especiais: cria, assina e tramita os próprios documentos. Permissões de cadastro (pessoa, unidade) são só para administradores.

> Achado da implantação: o SIGA às vezes não grava a permissão na primeira vez. Depois de conceder, confira na tela de permissões se o serviço aparece liberado; se não, conceda de novo.

## Acompanhamento automático

A rotina "Acompanhamento SIGA-Doc" (workflow do Base44) roda 4x por dia e traz o andamento dos documentos vinculados para a linha do tempo dos dossiês. Não precisa de ação; se algo falhar, aparece nos runs do workflow no Base44.

## Limites conhecidos

- Pela API só dá para criar **memorando**. Processo, despacho e documento externo continuam sendo abertos pela tela do SIGA (o SICS abre pelo link).
- Tramitação só depois da assinatura.
- Enquanto o endereço for sslip.io (sem domínio próprio com HTTPS), não use dados sensíveis reais.
