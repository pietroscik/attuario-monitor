# Pietro Scik · Portfolio & Monitor

Questa repo ospita due elementi:

- una landing page statica pubblicata da `/public/index.html` con le informazioni essenziali sul profilo professionale;
- il monitor pubblico raggiungibile da `/public/status.html`, che continua a leggere gli endpoint esposti nella cartella `api/`.

## Struttura

```
public/
├── index.html   → landing page
├── status.html  → monitor pubblico
└── styles.css   → stile condiviso della landing page
api/             → funzioni serverless per il monitor
```

## Sviluppo

Serve qualsiasi static file server. Con [Vercel](https://vercel.com/) o un'altra piattaforma, punta la directory `public/` come output. In locale puoi usare, ad esempio:

```bash
npx serve public
```

La pagina principale include un link costante a `status.html` per mantenere il monitor accessibile.

## Configurazione monitor

Le funzioni in `api/` leggono la variabile `MONITOR_TOKEN`. Su Vercel aggiungila nelle Environment Variables e passala come header `x-monitor-token` quando interroghi `/api/monitor`.

L'endpoint `/api/public` resta pensato per la pagina di stato e restituisce solo lo stato complessivo.
