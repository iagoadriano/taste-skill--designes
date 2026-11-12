-- Inclui Araguaína/TO na tabela de municípios do SIGA (a carga inicial do SIGA só traz SP, RJ e ES).
-- Rodar com --default-character-set=utf8mb4, senão o acento é gravado errado.
INSERT INTO cp_localidade (NM_LOCALIDADE, ID_UF)
SELECT 'Araguaína', ID_UF FROM cp_uf WHERE NM_UF = 'TO'
  AND NOT EXISTS (SELECT 1 FROM cp_localidade l JOIN cp_uf u ON u.ID_UF = l.ID_UF WHERE u.NM_UF = 'TO' AND l.NM_LOCALIDADE LIKE 'Aragua%na');
SELECT l.ID_LOCALIDADE, l.NM_LOCALIDADE, u.NM_UF FROM cp_localidade l JOIN cp_uf u ON u.ID_UF = l.ID_UF WHERE u.NM_UF = 'TO';
