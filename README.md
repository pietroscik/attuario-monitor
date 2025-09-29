# Attuario Monitor (Secure Version 2)

Questa versione mostra lo **stato globale** online/offline.

## Endpoint
- `api/monitor` → protetto da token (`x-monitor-token`). Restituisce dettagli.  
- `api/public` → calcola lo stato globale (se almeno un check fallisce → offline).

## Configurazione
1. Su Vercel → Settings → Environment Variables aggiungi:
   - `MONITOR_TOKEN` con un valore segreto.

2. Per UptimeRobot → imposta header `x-monitor-token` con il tuo token e punta a `api/monitor`.

3. La pagina `/status.html` mostra solo 🟢 ONLINE o 🔴 OFFLINE.
