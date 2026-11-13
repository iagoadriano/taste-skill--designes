# 17. Fase 5: expansão para as demais superintendências

Objetivo (arquivo 10, §3): todas as unidades ativas no SIGA-Doc, com treinamento. Critério de saída: todas as unidades ativas. Começa depois de o piloto rodar um mês sem pendência grave.

## 1. Ordem sugerida

Expandir por superintendência, uma de cada vez, para o suporte dar conta. Sugestão, a partir do organograma (arquivo 07):

1. Diretoria de Compras (é o piloto; serve de referência).
2. Superintendências que mais trocam documentos com Compras (licitação, contratos, almoxarifado).
3. Áreas-meio (administrativo, financeiro, RH).
4. Áreas-fim e unidades de saúde.

Fechar cada superintendência antes de abrir a próxima: todas as pessoas cadastradas, módulo liberado, uma semana de uso acompanhado.

## 2. Por superintendência (lista de verificação)

- [ ] Lista de servidores conferida (planilha da Fase 1, `fase1/preparar_pessoas.py`).
- [ ] Pessoas cadastradas no SIGA, com o e-mail do SICS e a unidade certa.
- [ ] Módulo "Mesa Virtual SIGA-Doc" liberado para cada um no SICS.
- [ ] Treinamento de 1 hora feito (roteiro abaixo).
- [ ] Primeiro documento real de cada equipe criado e tramitado.
- [ ] Uma semana de acompanhamento, com um ponto de contato para dúvidas.

## 3. Treinamento (roteiro de 1 hora)

Material: `manuais/servidor-mesa-virtual.md` (entregar antes).

1. **Por que mudou (5 min):** o SIGA-Doc substitui o 1Doc; tudo por dentro do SICS, no seu nome.
2. **Entrar e reconhecer a mesa (10 min):** abrir a Mesa Virtual, ver "Você está como…", os grupos, Usuário/Lotação.
3. **Receber (5 min):** receber um documento da Caixa de Entrada.
4. **Criar um memorando (15 min):** cada um cria um memorando de teste a partir de um dossiê, com destino a Unidade e a Pessoa, e anexa um PDF.
5. **Assinar e tramitar (10 min):** assinar o próprio documento e tramitar.
6. **Acompanhar (5 min):** mostrar o andamento aparecendo sozinho na linha do tempo do dossiê.
7. **Dúvidas e limites (10 min):** só memorando pela API; processos pela tela do SIGA; tramitar só depois de assinar.

## 4. Suporte ao administrador

Material: `manuais/administrador.md`. Cadastro de pessoa, liberação do módulo, ligação de contas, e os limites conhecidos.

## 5. Antes da expansão em escala

- Domínio da prefeitura com HTTPS no lugar do sslip.io (pendência da Fase 2).
- SMTP real confirmado (feito): as senhas chegam por e-mail.
- Cópia de segurança e monitoramento agendados e testados (Fase 2).

## 6. Depois da expansão: Fase 6

Encerramento do 1Doc (arquivo 10, §3): histórico tratado, acesso de consulta definido, contrato encerrado. Tratar quando todas as unidades estiverem ativas no SIGA-Doc.
