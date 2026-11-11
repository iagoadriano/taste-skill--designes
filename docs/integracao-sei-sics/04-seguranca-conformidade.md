# 04. Segurança e conformidade

Não é parecer jurídico: é orientação técnica, a validar com o jurídico e o encarregado (DPO) do órgão. As referências legais vêm de conhecimento geral e as premissas estão listadas ao final.

## 1. Enquadramento legal

| Norma | Relevância |
|---|---|
| **LGPD (Lei 13.709/2018)** | Bases prováveis: art. 7º, II (obrigação legal) e III (políticas públicas); para dados sensíveis, art. 11, II, "a" e "b". Arts. 23 a 26: finalidade pública, publicidade do tratamento e regras de uso compartilhado. Também art. 6º (necessidade), art. 37 (registro das operações), art. 38 (RIPD), arts. 46 a 49 (segurança e incidentes). |
| **LAI (Lei 12.527/2011)** | Art. 31 (informação pessoal), arts. 23 e 24 (classificação), art. 22 (outros sigilos legais), art. 25 (controle de acesso), art. 32 (responsabilização). |
| **Decreto 8.539/2015** | Processo eletrônico na administração federal; exige integridade, autenticidade e disponibilidade. |
| **Outros** | Lei 9.784/1999, Lei 14.129/2021 (Governo Digital), Lei 8.159/1991 (arquivos), Decreto 7.724/2012 (regulamenta a LAI no Executivo federal). |

**A confirmar com o jurídico/encarregado:**

- Esfera e poder do órgão: os decretos federais não se aplicam automaticamente a estados, municípios, Judiciário ou Legislativo.
- Aplicabilidade do Decreto 10.046/2019 (compartilhamento de dados) e do PPSI, e as normas internas do SEI no órgão.
- Se o SICS pertence ao mesmo controlador; se não, há uso compartilhado (art. 26) e é preciso instrumento formal.
- Base legal específica e hipóteses legais de restrição cadastradas no SEI local.

## 2. Tratamento por nível de acesso

| Nível | Recomendação padrão |
|---|---|
| **Público** | Sincronizar metadados e documentos. Ainda pode conter dados pessoais, então aplicar minimização. |
| **Restrito** | Primeira entrega: só metadados mínimos (número, tipo, unidade, nível, hipótese legal). Conteúdo só depois de RIPD e de o SICS comprovar controle de acesso equivalente. |
| **Sigiloso** | Fora do escopo: rejeitar e registrar. Inclusão futura só com autorização formal. |

Regras de propagação:

- Nível de acesso e hipótese legal são campos obrigatórios no SICS e aplicados no controle de acesso do destino.
- O nível efetivo é o mais restritivo entre o processo e o documento.
- **Fail-closed:** nível ausente ou desconhecido é tratado como sigiloso e não sincroniza.
- Reclassificação no SEI precisa refletir no SICS. Se ficar mais restritivo, revogar ou expurgar; isso exige ressincronização periódica.
- O "sigiloso" do SEI não equivale a informação classificada da LAI (reservado/secreto/ultrassecreto), que tem regime próprio (Decreto 7.845/2012). A confirmar.
- O manual 4.0 indica que os Web Services não retornam processos sigilosos. Mesmo assim, não confiar só no SEI: filtrar também no intermediário (defesa em profundidade, e o comportamento deve ser reconfirmado na versão instalada).

## 3. Gestão de credenciais

- **Cofre de segredos:** a Chave de Acesso (`IdentificacaoServico`) fica em cofre (Vault, KMS ou equivalente), nunca em código, repositório, imagem ou log. É injetada em tempo de execução.
- **Rotação:** periódica (por exemplo, 90 dias) e imediata em caso de incidente ou desligamento de pessoal. Ter procedimento documentado com o administrador do SEI.
- **Privilégio mínimo:** um Sistema/Serviço dedicado só a esta integração, com apenas operações de consulta, limitado às unidades e aos tipos de processo e documento necessários. Sem operações de escrita enquanto o retorno SICS → SEI não for aprovado.
- **Restrição de rede:** IP de saída fixo do intermediário, liberado no firewall do órgão. A autenticação do serviço deve ser por Chave de Acesso; o modo "Endereço" do SEI está marcado para remoção e não deve ser o único controle.
- **TLS:** versão 1.2 ou superior, com validação de certificado, nos dois trechos (SEI → intermediário e intermediário → SICS). Sem endpoint HTTP.
- **Credenciais distintas** por ambiente e para o SICS. Acesso administrativo ao intermediário com MFA.

## 4. Auditoria e logs

- Registrar por operação: data e hora (NTP), ID de correlação, serviço, operação, unidade, identificador do processo ou documento, nível de acesso, resultado e hash do conteúdo transferido.
- Não registrar conteúdo, nomes de interessados, CPF, payloads SOAP nem credenciais. Mascarar mensagens de erro. A dead-letter guarda referência e hash, não o payload em claro.
- Logs imutáveis (append-only ou WORM), enviados a um SIEM, com acesso segregado da equipe de operação.
- Retenção conforme a tabela de temporalidade do órgão (a confirmar). Sugestão inicial: no mínimo 12 meses online, mais arquivo.
- **Não repúdio:** hash SHA-256 por documento na origem e no destino, credencial exclusiva por sistema e encadeamento ou assinatura dos lotes de log.
- Alertas para volume anômalo, tentativa de acesso a sigiloso e falhas de autenticação.

## 5. Segregação de ambientes

- Desenvolvimento e homologação usam apenas o SEI de homologação ou treinamento. A credencial de produção só existe no cofre de produção.
- Redes e contas separadas, com bloqueio de rota entre homologação e o SEI de produção.
- Dados de teste sintéticos ou anonimizados. É proibido copiar a base de produção sem anonimização e autorização.
- Promoção para produção por pipeline, com aprovação.

## 6. Modelo de ameaças

| Ameaça | Impacto | Controle |
|---|---|---|
| Vazamento da chave do serviço | Leitura indevida do SEI | Cofre, restrição de rede, rotação, escopo mínimo |
| Perda do nível de acesso na sincronização | Exposição de restrito no SICS | Campo obrigatório, fail-closed, testes automatizados |
| Reclassificação não propagada | Dado restrito visível como público | Ressincronização e expurgo |
| Escopo excessivo do serviço | Coleta além da finalidade | Limite por unidade e tipo, revisão periódica |
| Interceptação ou adulteração em trânsito | Quebra de sigilo e integridade | TLS, hashes |
| Dados pessoais em logs | Vazamento secundário | Lista de campos permitidos, mascaramento |
| Comprometimento do intermediário | Acesso em massa | Hardening, cifragem em repouso, segmentação de rede |
| Dados reais em homologação | Exposição | Dados sintéticos, credenciais separadas |
| Abuso por pessoal interno | Extração indevida | Segregação de funções, auditoria |
| Sobrecarga do SEI | Indisponibilidade | Limite de taxa, janelas de execução, backoff |

## 7. Checklist de go-live e artefatos

- [ ] Autorização formal do gestor do SEI e cadastro do Sistema/Serviço com escopo documentado
- [ ] Termo de responsabilidade do sistema integrador e de seus operadores
- [ ] RIPD aprovado pelo encarregado; registro das operações (art. 37) atualizado
- [ ] Instrumento de compartilhamento, se os controladores forem distintos (art. 26)
- [ ] Matriz nível de acesso × hipótese legal × regra no SICS, validada
- [ ] Testes: fail-closed, rejeição de sigiloso, reclassificação e integridade por hash
- [ ] Teste de segurança (pentest ou varredura) sem pendências críticas
- [ ] Procedimento de rotação testado; plano de resposta a incidentes com comunicação à ANPD e aos titulares (art. 48)
- [ ] Política de retenção e descarte no SICS e no intermediário
- [ ] Logs e alertas ativos; homologação concluída no SEI de homologação
- [ ] Documento de arquitetura e inventário de dados

## Premissas a validar

1. Esfera do órgão e versão do SEI.
2. Se o SICS é do mesmo controlador e qual é o seu modelo de controle de acesso.
3. Finalidade exata da integração e quais unidades e tipos de processo são necessários.
4. Quais dados o intermediário persiste.
5. Hospedagem (nuvem ou on-premises; se houver transferência internacional).
6. Se o fluxo é só leitura.
