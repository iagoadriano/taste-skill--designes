# Timbre do SICS nos documentos do SIGA-Doc

Os documentos gerados no SIGA-Doc (memorando, ofício, despacho e os demais modelos de cabeçalho centralizado) saem com o mesmo timbre configurado no SICS em "Documentos e Identidade Visual": faixa superior (Prefeitura de Araguaína / Secretaria da Saúde) e faixa inferior (endereço e SICS-Saúde).

| Arquivo | Função |
|---|---|
| `timbre-sics-cabecalho.png`, `timbre-sics-rodape.png` | Recortes do timbre retrato do SICS |
| `aplicar_timbre.py` | Roda na compilação (Dockerfile): copia as imagens para o SIGA e troca o cabeçalho e o rodapé dos modelos |

Aplicar ou atualizar na máquina:

```bash
git pull && sudo docker compose up -d --build
```

Vale para documentos novos e para a visualização dos antigos ainda não assinados. Documento já assinado guarda o PDF como foi assinado.

Se o timbre do SICS mudar, troque as duas imagens (mesma proporção: 1308×198 e 1308×162) e recompile. Para voltar ao padrão do SIGA: `sudo docker compose build --build-arg TIMBRE=nao appserver && sudo docker compose up -d`.

A marca-d'água do timbre do SICS não é aplicada: o gerador de PDF do SIGA não tem fundo de página.
