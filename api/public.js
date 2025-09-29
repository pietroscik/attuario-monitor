import handlerMonitor from './monitor.js';

export default async function handler(req, res) {
  // Simula la chiamata al monitor con token
  const mockReq = { headers: { 'x-monitor-token': process.env.MONITOR_TOKEN } };
  const mockRes = {
    _json: null,
    status(code) { this._status = code; return this; },
    json(obj) { this._json = obj; return this; },
    setHeader() {}
  };

  await handlerMonitor(mockReq, mockRes);

  // Determina stato globale
  let overall = "online";
  if (!mockRes._json?.results) {
    overall = "offline";
  } else {
    for (const r of mockRes._json.results) {
      if (r.checks.some(c => c.status === "fail")) {
        overall = "offline";
        break;
      }
    }
  }

  res.setHeader("Content-Type", "application/json");
  res.status(200).json({ status: overall, checkedAt: new Date().toISOString() });
}
