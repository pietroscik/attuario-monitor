import { chromium } from 'playwright';

export default async function handler(req, res) {
  // Controllo token segreto
  if (req.headers['x-monitor-token'] !== process.env.MONITOR_TOKEN) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  const browser = await chromium.launch();
  const page = await browser.newPage();

  const targets = [
    {
      name: "home",
      url: "https://attuario.club",
      checks: [
        { type: "waitForSelector", selector: "header" },
        { type: "elementVisible", selector: "main" }
      ]
    },
    {
      name: "contact",
      url: "https://attuario.club/contact",
      checks: [
        { type: "waitForSelector", selector: "form#contact" }
      ]
    }
  ];

  const results = [];

  for (const t of targets) {
    const result = { name: t.name, url: t.url, checks: [] };
    try {
      await page.goto(t.url, { waitUntil: "networkidle" });
      for (const c of t.checks) {
        try {
          if (c.type === "waitForSelector") {
            await page.waitForSelector(c.selector, { timeout: 5000 });
            result.checks.push({ type: c.type, selector: c.selector, status: "ok" });
          } else if (c.type === "elementVisible") {
            const el = await page.$(c.selector);
            const vis = await el?.isVisible();
            result.checks.push({ type: c.type, selector: c.selector, status: vis ? "ok" : "fail" });
          }
        } catch (err) {
          result.checks.push({ type: c.type, selector: c.selector, status: "fail" });
        }
      }
    } catch (err) {
      result.error = "Page load failed";
    }
    results.push(result);
  }

  await browser.close();

  res.setHeader("Content-Type", "application/json");
  res.status(200).json({ runAt: new Date().toISOString(), results });
}
