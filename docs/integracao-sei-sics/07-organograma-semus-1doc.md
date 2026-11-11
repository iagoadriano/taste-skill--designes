# 07. Organograma da SEMUS no 1Doc

Transcrição das cinco capturas de tela do organograma do 1Doc enviadas pelo usuário. Este arquivo é a base para a tabela de de-para de unidades em qualquer cenário de substituição do 1Doc.

**Limites da transcrição:**

- As capturas são recortes: começam e terminam no meio da árvore e não se sobrepõem. Pode haver unidades entre uma captura e outra que não aparecem aqui.
- O nível de cada unidade foi lido pela indentação da imagem. Onde uma captura começa no meio de um ramo, o pai foi inferido (ver "Pontos a conferir").
- A contagem de usuários é a do selo ao lado de cada unidade. Uma pessoa pode estar em mais de uma unidade, então a soma não é o número de pessoas.
- O município não está escrito nas capturas; os nomes das UBS sugerem Araguaína. A confirmar.

## Números

| Indicador | Valor |
|---|---|
| Unidades transcritas | 165 |
| Soma dos selos de usuários | 329 |
| Unidades sem selo de usuário | 9 |
| Profundidade máxima da árvore | 10 níveis |
| Siglas repetidas | `SEMUS-DAF-FARM` (24 unidades), `SEMUS-COPEC` (5 unidades) |

## Achados que afetam a substituição do 1Doc

1. **Siglas não são únicas.** 24 farmácias compartilham `SEMUS-DAF-FARM` e 5 unidades compartilham `SEMUS-COPEC`. A sigla não pode ser chave de migração; é preciso o identificador interno do 1Doc ou uma sigla nova por unidade. No SEI, a sigla de unidade precisa ser única dentro do órgão (a confirmar na versão instalada).
2. **A raiz operacional está pendurada na comissão de suporte do 1Doc.** `SEMUS-EXEC` e tudo abaixo dela aparecem como filhos de `SEMUS-CSDOC` (Comissão de Suporte 1Doc). Isso parece um artefato do cadastro, não a hierarquia real. A árvore de destino deve ligar a Secretaria Executiva direto à `SEMUS`, e a comissão deixa de existir ou vira a equipe de suporte do novo sistema.
3. **Entidades externas cadastradas como unidades.** `SEMUS-ISAC/HMA`, `SEMUS-OLHAR` (com Faturamento e RH), `SEMUS-YANO` e `SEMUS-INST-PREV` parecem organizações parceiras ou contratadas. No sistema novo é preciso decidir se continuam como unidades internas ou passam a usuários externos.
4. **Unidades sem usuários:** `SEMUS-TRANSPARÊNCIA`, `SEMUS-MTO`, `SEMUS-DRH`, `SEMUS-CEROO`, `SEMUS-TELEMED`, `SEMUS-SAE-DADM`, `SEMUS-SAE-CLOG`, `SEMUS-SUPAE-ASSTEC`, `SEMUS-UBS`. Decidir uma a uma se migram, se são só agrupadoras ou se são extintas.
5. **Siglas com caracteres problemáticos:** `SEMUS-ISAC/HMA` e `SEMUS-SS/SUPAP` têm barra; `SEMUS-TRANSPARÊNCIA` tem acento; `ESPA-ASTEC` foge do prefixo `SEMUS-`. Padronizar antes de migrar.
6. **Grupos funcionais cadastrados como unidade:** `SEMUS-MOT` (25 motoristas), `SEMUS-OPMANUT`, `SEMUS-ENCMANUT`, `SEMUS-CAPSADIII-FISCAIS`. São grupos de pessoas, não setores; no destino podem virar perfis ou permanecer como unidades.
7. **Hierarquia funda em alguns ramos** (até 10 níveis, por exemplo Imunização: DIMUN → CIMUN → ATIMUN → IMUN-PEC-SIES-SIPNI → RF). Vale achatar onde cada nível tem um único usuário.
8. **Farmácias e UBS repetem as mesmas localidades** (Araguaína Sul, Dr Dantas, Couto Magalhães etc.) em dois ramos distintos. O de-para deve tratar farmácia e UBS da mesma localidade como unidades separadas.

## Pontos a conferir com o usuário

- As diretorias da segunda captura (`SEMUS-DMANUT` até `SEMUS-DTRANSP`) foram colocadas sob `SEMUS-SUPADM` por continuidade; a captura não mostra o pai.
- `SEMUS-DTEC` e as unidades `SEMUS-SAE-*` / `SEMUS-SUPAE-*` da terceira captura foram colocadas sob `SEMUS-SUPAE` pelo mesmo motivo.
- `SEMUS-CICLOS`, `SEMUS-DAF`, `SEMUS-DIMUN`, `SEMUS-DINF` e `SEMUS-DITEC` aparecem indentadas sob `SEMUS-SUPAP-ASSTEC`; pode ser que pertençam direto à `SEMUS-SUPAP`.
- Selos de `SEMUS-UBS-DRAESMERALDA`, `SEMUS-UBS-DRFRANCISCO` e `SEMUS-UBS-DRRAIMUNDO` estavam quebrados para a margem da imagem; os valores 1, 2 e 1 foram atribuídos pela ordem.
- A árvore mostra só a SEMUS. Há outras secretarias no mesmo 1Doc que entram no escopo?

## Árvore transcrita

Formato: `SIGLA - Nome (usuários)`.

```text
SEMUS - Secretaria Municipal de Saúde (1)
  SEMUS-CSDOC - Comissão de Suporte 1Doc - SEMUS (4)
    SEMUS-EXEC - Secretaria Executiva (1)
      SEMUS-ASTEC - Assessoria Técnica (5)
      SEMUS-CMS - Conselho Municipal de Saúde (4)
      SEMUS-COPEC - Presidência (1)
        SEMUS-COPEC - Análise Técnica e Documental (4)
        SEMUS-COPEC - Análise Econômico Financeira e Contábil (3)
        SEMUS-COPEC - Apoio Jurídico Consultivo (2)
        SEMUS-COPEC - Gestão de Credenciados (2)
      SEMUS-DIROUVSUS - Diretoria de Ouvidoria do SUS (1)
        SEMUS-ATOUVSUS - Área Técnica Ouvidoria do SUS (3)
      SEMUS-ESPA - Superintendência Escola de Saúde Pública (1)
        ESPA-ASTEC - Assessoria Técnica (1)
        SEMUS-ESPA-ASADM - Assessoria Administrativa (1)
        SEMUS-ESPA-ASCOM - Assessoria de Comunicação (1)
        SEMUS-ESPA-ASOPE - Assessoria Operacional (1)
        SEMUS-NAP - Núcleo de Apoio Psicológico (1)
        SEMUS-NEP - Núcleo de Educação Permanente (3)
      SEMUS-NAT - Núcleo de Apoio Técnico (3)
      SEMUS-SAAC - Superintendência Auditoria, Avaliação e Controle (1)
        SEMUS-DAAC - Diretoria de Auditoria, Avaliação e Controle (2)
      SEMUS-SUPADM - Superintendência Administrativa e Financeira (1)
        SEMUS-DADM - Diretoria Administrativa (1)
          SEMUS-ATADM - Área Técnica Administrativa (1)
          SEMUS-CDSI - Coordenação DSI (4)
          SEMUS-LSUPDAM - Logística SUPADM (2)
          SEMUS-PROTG - Protocolo Geral da SMS (1)
        SEMUS-DCOMP - Diretoria de Compras (1)
          SEMUS-ATDCOMP - Área Técnica da Diretoria de Compras (2)
          SEMUS-GEXEC - Gerência de Execução (1)
            SEMUS-ATGEXEC - Área Técnica da Gerência de Execução (14)
          SEMUS-GLICIT - Gerência de Licitação (6)
          SEMUS-TRANSPARÊNCIA - Transparência (0)
        SEMUS-DFIN - Diretoria Financeira (1)
          SEMUS-CFIN - Coordenação Financeira (1)
        SEMUS-DMANUT - Diretoria de Manutenção (1)
          SEMUS-CMANUT - Coordenação de Manutenção (1)
            SEMUS-ENCMANUT - Encarregados de Manutenção (5)
              SEMUS-OPMANUT - Operacionais de Manutenção (8)
        SEMUS-DOC - Diretoria de Obras e Convênios (5)
        SEMUS-DPL - Diretoria de Patrimônio e Logística (1)
          SEMUS-CCL - Coordenação do Centro Logístico (5)
            SEMUS-MTO - Manutenção Odontológica (0)
          SEMUS-CPT - Coordenação de Patrimônio (3)
          SEMUS-DCLP - Diretoria do Centro Logístico e Patrimônio (1)
        SEMUS-DPLAN - Diretoria de Planejamento (1)
          SEMUS-CPLAN - Coordenação de Planejamento (2)
        SEMUS-DRH - Diretoria de Recursos Humanos (0)
          SEMUS-CRH - Coordenação de Recursos Humanos (9)
        SEMUS-DTI - Diretoria de T.I. (1)
          SEMUS-ATCELK - Área Técnica CELK (1)
          SEMUS-CTI - Coordenação de T.I. (1)
        SEMUS-DTRANSP - Diretoria de Transporte (1)
          SEMUS-CTRANSP - Coordenação de Transporte (5)
          SEMUS-MOT - SEMUS Motoristas (25)
      SEMUS-SUPAE - Superintendência de Atenção Especializada (1)
        SEMUS-DREAB - Diretoria de Reabilitação (1)
          SEMUS-CERIV - Centro Especializado em Reabilitação (1)
            SEMUS-SUP-CERIV - Supervisão CERIV (1)
          SEMUS-CEROO - CER / Oficina Ortopédica (0)
          SEMUS-DCEMA - Diretor da Clínica Escola Mundo Autista (2)
          SEMUS-DCF - Diretoria do Centro de Fisioterapia (2)
        SEMUS-DSM - Diretoria de Saúde Mental (1)
          SEMUS-CAPSADIII - Coordenação do CAPS AD III (3)
            SEMUS-CAPSADIII-FISCAIS - Fiscais de Contratos (2)
          SEMUS-CAPSII - Coordenação do CAPS II (2)
            SEMUS-CAPSII-FARM - Farmácia CAPS II (2)
            SEMUS-CAPSII-SRT - Serviço Residencial Terapêutico (1)
          SEMUS-CAPSINFANT - Coordenação do CAPS Infantil (3)
          SEMUS-DUAA - Diretoria da Unidade de Acolhimento Adulto (2)
        SEMUS-DTEC - Diretoria Técnica (1)
          SEMUS-ATEC - Área Técnica (1)
          SEMUS-CSAD - Coordenação do Serviço de Atendimento Domiciliar (SAD) (1)
          SEMUS-DGSAMU - Diretor Geral SAMU (2)
            SEMUS-CALSAMU - Coordenação de Almoxarifado do SAMU (1)
            SEMUS-DTSAMU - Diretor Técnico do SAMU (1)
              SEMUS-CENF - Coordenação de Enfermagem (1)
              SEMUS-CFSAMU - Coordenação de Frota do SAMU (3)
              SEMUS-CNEU - Coordenação do NEU (2)
            SEMUS-SAMU-ADMESTAT - Administrativo Estatística (1)
          SEMUS-DRM - Diretoria de Regulação Municipal (1)
            SEMUS-CTFD - Coordenação de TFD (3)
          SEMUS-INST-PREV - Instituto de Prevenção (2)
          SEMUS-ISAC/HMA - ISAC/HMA (3)
            SEMUS-AME - Ambulatório Municipal de Especialidades (1)
            SEMUS-PAI - Pronto Atendimento Infantil (2)
            SEMUS-UPA - Unidade de Pronto Atendimento (1)
          SEMUS-NAG - Núcleo de Apoio à Gestão (3)
          SEMUS-OLHAR - Instituto Olhar (1)
            SEMUS-OLHAR-FATURAMENTO - Instituto Olhar Faturamento (4)
            SEMUS-OLHAR-RH - Instituto Olhar Recursos Humanos (2)
          SEMUS-TELEMED - Telemedicina (0)
          SEMUS-YANO - YANO (3)
        SEMUS-SAE-DADM - Diretoria Administrativa SUPAE (0)
          SEMUS-SAE-CLOG - Coordenação de Logística (0)
          SEMUS-SUPAE-DJUD - Demandas Judiciais SUPAE (4)
          SEMUS-SUPAE-RH - Recursos Humanos SUPAE (1)
        SEMUS-SUPAE-ADM - Administrativo Operacional (3)
        SEMUS-SUPAE-ASSTEC - Assessoria Técnica SUPAE (0)
        SEMUS-SUPAE-COORDADM - Coordenação Administrativa SUPAE (1)
        SEMUS-SUPAE-NAG - Coordenação NAG (1)
      SEMUS-SUPAP - Superintendência de Atenção Primária (1)
        SEMUS-CNRUA - Consultório na Rua (4)
        SEMUS-SUPAP-ADM - Administrativo (1)
        SEMUS-SUPAP-ASSTEC - Assessoria Técnica (1)
          SEMUS-CICLOS - Ciclos de Vida (1)
            SEMUS-ATECICLOS - Área Técnica Ciclos de Vida (4)
              SEMUS-CICLOS-SCEI - Saúde da Criança na Educação Infantil (1)
          SEMUS-DAF - Diretoria Assistência Farmacêutica (1)
            SEMUS-DAF-COORD - Coordenação Assistência Farmacêutica (1)
            SEMUS-DAF-FARM - Farmácia CAPS AD (1)
            SEMUS-DAF-FARM - Farmácia CAPS II (1)
            SEMUS-DAF-FARM - Farmácia José Rezende (1)
            SEMUS-DAF-FARM - Farmácia Eurico Carneiro (1)
            SEMUS-DAF-FARM - Farmácia Palmeiras do Norte (1)
            SEMUS-DAF-FARM - Farmácia Bairro de Fátima (1)
            SEMUS-DAF-FARM - Farmácia Couto Magalhães (1)
            SEMUS-DAF-FARM - Farmácia Dr Antônio Catini (1)
            SEMUS-DAF-FARM - Farmácia Dr Cesar Delgado (1)
            SEMUS-DAF-FARM - Farmácia Araguaína Sul (2)
            SEMUS-DAF-FARM - Farmácia Maria dos Reis (2)
            SEMUS-DAF-FARM - Farmácia Dra Esmeralda Medrado (1)
            SEMUS-DAF-FARM - Farmácia Lago Azul (2)
            SEMUS-DAF-FARM - Farmácia Manoel Alves (1)
            SEMUS-DAF-FARM - Farmácia José Ronaldo (1)
            SEMUS-DAF-FARM - Farmácia Avany Galdino (2)
            SEMUS-DAF-FARM - Assistência Farmacêutica (2)
            SEMUS-DAF-FARM - Farmácia Manoel Maria (2)
            SEMUS-DAF-FARM - Farmácia Dr Raimundo (2)
            SEMUS-DAF-FARM - Farmácia Senador Benedito (1)
            SEMUS-DAF-FARM - Farmácia Dr Francisco (2)
            SEMUS-DAF-FARM - Farmácia Manoel dos Reis (1)
            SEMUS-DAF-FARM - Farmácia Pedro Pacífico (2)
            SEMUS-DAF-FARM - Farmácia Dr Dantas (4)
          SEMUS-DIMUN - Diretoria Imunização (1)
            SEMUS-CIMUN - Coordenação Imunização (1)
              SEMUS-ATIMUN - Área Técnica Imunização (1)
                SEMUS-IMUN-PEC-SIES-SIPNI - Imunização (PEC/SIES/SIPNI) (1)
                  SEMUS-RF - Rede de Frio (1)
          SEMUS-DINF - Diretoria de Informação (2)
            SEMUS-AMS - Aplicativo Mais Saúde (2)
            SEMUS-SS/SUPAP - Serviço Social/SUPAP (3)
          SEMUS-DITEC - Diretoria Técnica (1)
            SEMUS-CESF - Coordenação Estratégia Saúde da Família (ESF) (1)
              SEMUS-ADESF - Administrativo ESF (1)
              SEMUS-ATEBF - Área Técnica Bolsa Família (1)
              SEMUS-CRESF - Coordenadora de Região da ESF (5)
                SEMUS-CME - Central de Materiais e Esterilização (3)
                SEMUS-EAGS - Encarregado dos Agentes de Saúde - ACS (2)
                SEMUS-UBS - Unidades Básicas de Saúde (0)
                  SEMUS-UBS-ALBENY - UBS Albeny Soares de Paula (2)
                  SEMUS-UBS-ARAGUAINASUL - UBS Araguaína Sul (1)
                  SEMUS-UBS-AVANY - UBS Avany Galdino da Silva (2)
                  SEMUS-UBS-BARRADAGROTA - UBS Barra da Grota (1)
                  SEMUS-UBS-BARROS - UBS Maria dos Reis (1)
                  SEMUS-UBS-COUTO - UBS Couto Magalhães (1)
                  SEMUS-UBS-DRAESMERALDA - UBS Dra Esmeralda Medrado (1)
                  SEMUS-UBS-DRANTONIO - UBS Dr Antonio Catini (2)
                  SEMUS-UBS-DRCESAR - UBS Dr Cesar Augusto Delgado (2)
                  SEMUS-UBS-DRDANTAS - UBS Dr Dantas (2)
                  SEMUS-UBS-DRFRANCISCO - UBS Dr Francisco Barbosa de Brito (2)
                  SEMUS-UBS-DRRAIMUNDO - UBS Dr Raimundo Gomes Marinho (1)
                  SEMUS-UBS-FATIMA - UBS Bairro de Fátima (1)
                  SEMUS-UBS-JK - UBS JK Araguaína (1)
```
