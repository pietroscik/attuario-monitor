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

## Script R e Python inclusi
- `public/scripts/chain-ladder.R` → Chain Ladder con fattori di sviluppo, completamento triangolo e report IBNR.
- `public/scripts/experience-study.R` → studio di esperienza con credibilità e calcolo di A/E aggregato.
- `public/scripts/loss_ratio.py` → monitoraggio loss/combined ratio e trend cumulati a livello di portafoglio.
- `public/scripts/severity_scenario.py` → generatore di scenari severity misti lognormale/Pareto per stress test.

Ogni file è servito anche via interfaccia web (`/scripts/...`) così puoi scaricarlo direttamente dalla sezione *Progetti*.
