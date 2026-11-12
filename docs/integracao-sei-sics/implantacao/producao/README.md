# Produção: scripts de operação

| Script | O que faz | Quando |
|---|---|---|
| `backup.sh` | Cópia do banco inteiro (documentos e PDFs incluídos), confere se a cópia está completa, guarda 30 dias e, se `BACKUP_REMOTO` estiver definido, envia para fora da máquina (rclone) | Todo dia, 2h |
| `restaurar-teste.sh` | Restaura a cópia num MySQL descartável e conta documentos, pessoas e unidades, sem tocar na produção | Antes do piloto, depois uma vez por mês |
| `verificar.sh` | SIGA respondendo, serviços no ar, disco abaixo de 85%, cópia com menos de 30h. Avisa em `ALERTA_URL` se algo falhar | A cada 5 minutos |
| `desligar-contas-teste.sh` | Cancela as contas ZZ… (senha pública). Sem `--aplicar` só mostra a lista, e recusa se não houver ao menos 2 contas reais | Uma vez, depois de criar o administrador real e a conta de integração |

Agendamento (`sudo crontab -e`), trocando o caminho:

```
0 2 * * *   /opt/sigadoc/implantacao/producao/backup.sh   >> /var/log/sigadoc-backup.log 2>&1
*/5 * * * * /opt/sigadoc/implantacao/producao/verificar.sh >> /var/log/sigadoc-verificar.log 2>&1
```

Variáveis no `.env` (todas opcionais): `SIGA_URL_PUBLICA`, `BACKUP_DIR`, `BACKUP_DIAS`, `BACKUP_REMOTO`, `ALERTA_URL`, e o e-mail real `SMTP_HOST`, `SMTP_PORTA`, `SMTP_USUARIO`, `SMTP_SENHA`, `SMTP_STARTTLS`, `SMTP_REMETENTE`.
