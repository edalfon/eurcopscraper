// npm i puppeteer-extra puppeteer-extra-plugin-stealth
const puppeteer = require('puppeteer-extra');
const StealthPlugin = require('puppeteer-extra-plugin-stealth');
puppeteer.use(StealthPlugin());

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

const randomPause = (min = 300, max = 1200) => sleep(Math.floor(Math.random() * (max - min + 1)) + min);

async function simulateHumanActivity(page) {
  await page.mouse.move(100 + Math.random() * 50, 100 + Math.random() * 50);
  await randomPause();
  await page.mouse.move(300 + Math.random() * 50, 400 + Math.random() * 50);
  await page.evaluate(() => window.scrollBy(0, Math.floor(Math.random() * 300)));
  await page.keyboard.press('Tab');
  await randomPause();
}

async function acceptOneTrust(page) {
  // Try top-level
  const topBtn = await page.$('#onetrust-accept-btn-handler');
  if (topBtn) {
    await topBtn.click().catch(() => { });
    await sleep(400 + Math.random() * 300);
    return;
  }
  // Try in any iframe
  for (const frame of page.frames()) {
    const btn = await frame.$('#onetrust-accept-btn-handler');
    if (btn) {
      await btn.click().catch(() => { });
      await sleep(400 + Math.random() * 300);
      return;
    }
  }
}

async function findConverterContext(page, timeout = 30000) {
  const start = Date.now();
  while (Date.now() - start < timeout) {
    if (await page.$('#tCurrency')) return page;
    for (const frame of page.frames()) {
      if (await frame.$('#tCurrency')) return frame;
    }
    await sleep(400 + Math.random() * 300);
  }
  throw new Error('Currency converter not found in page or frames within timeout.');
}

// Wait for a visible element (page or frame context)
async function waitVisible(ctx, selector, timeout = 30000) {
  const handle = await ctx.waitForSelector(selector, { visible: true, timeout });
  return handle;
}

// Clear an input’s value via JS (more reliable than triple-click sometimes)
async function clearInput(ctx, selector) {
  await ctx.evaluate((sel) => {
    const el = document.querySelector(sel);
    if (el) {
      el.focus();
      if ('value' in el) el.value = '';
      const evts = ['input', 'change', 'keyup'];
      evts.forEach(t => el.dispatchEvent(new Event(t, { bubbles: true })));
    }
  }, selector);
}

// Find a visible option-like node by text and click it safely
async function clickOptionByText(ctx, text, timeout = 30000) {
  const start = Date.now();
  const upper = text.toUpperCase();

  while (Date.now() - start < timeout) {
    const handle = await ctx.evaluateHandle((tUpper) => {
      const isVisible = (el) =>
        el && el.ownerDocument && el.getClientRects().length > 0 &&
        getComputedStyle(el).visibility !== 'hidden' &&
        getComputedStyle(el).display !== 'none';

      // Common option containers/elements
      const candidates = Array.from(document.querySelectorAll(`
        [role="option"],
        [role="listbox"] [role="option"],
        ul li a, ul li, li a, a, button, div[role="button"]
      `));

      // Prefer items near open dropdowns
      const filtered = candidates.filter(el => {
        const txt = (el.innerText || el.textContent || '').toUpperCase().trim();
        return txt.includes(tUpper) && isVisible(el);
      });

      // Return the most specific anchor/button if available
      return (
        filtered.find(el => el.tagName === 'A') ||
        filtered.find(el => el.getAttribute('role') === 'option') ||
        filtered[0] ||
        null
      );
    }, upper);

    const el = await handle.asElement();
    if (el) {
      try {
        await el.scrollIntoViewIfNeeded?.().catch?.(() => { });
        await el.click({ delay: 10 });
        return true;
      } catch {
        // Fallback: click via JS (works around overlays)
        try {
          await ctx.evaluate((node) => {
            const rect = node.getBoundingClientRect();
            node.dispatchEvent(new MouseEvent('mousedown', { bubbles: true, clientX: rect.x + 5, clientY: rect.y + 5 }));
            node.dispatchEvent(new MouseEvent('mouseup', { bubbles: true, clientX: rect.x + 5, clientY: rect.y + 5 }));
            node.click();
          }, el);
          return true;
        } catch { }
      }
    }

    await sleep(400 + Math.random() * 300);
  }
  throw new Error(`Option with text "${text}" not found/clickable within timeout`);
}

// Type into a combo input and select an option by visible text
async function typeAndSelect(ctx, page, inputSelector, query, optionText) {
  await waitVisible(ctx, inputSelector);
  await clearInput(ctx, inputSelector);
  // Ensure focus, then type slowly to trigger app filters
  await ctx.click(inputSelector, { delay: 10 }).catch(() => { });
  await ctx.focus?.(inputSelector).catch?.(() => { });
  // If ctx is a Frame, use page.keyboard (the focused element is within the frame)
  await page.keyboard.type(query, { delay: 40 });


  await simulateHumanActivity(page);

  // Try selecting exact option text
  try {
    await clickOptionByText(ctx, optionText, 15000);
    return;
  } catch { }

  // Fallback: Enter to accept the first highlighted option
  try {
    await page.keyboard.press('Enter');
    return;
  } catch { }

  throw new Error(`Could not select option "${optionText}" after typing "${query}"`);
}

(async () => {
  const browser = await puppeteer.launch({
    headless: 'new',
    userDataDir: './.mastercard-profile',
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
      '--disable-gpu',
      '--lang=en-US,en;q=0.9',
    ],
  });

  const userAgents = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 13_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Safari/605.1.15',
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:115.0) Gecko/20100101 Firefox/115.0',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 13_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.5735.198 Safari/537.36',
  ];

  const randomUA = userAgents[Math.floor(Math.random() * userAgents.length)];


  const page = await browser.newPage();
  await page.setExtraHTTPHeaders({ 'Accept-Language': 'en-US,en;q=0.9,de;q=0.8' });
  await page.setUserAgent(randomUA);
  await page.setViewport({ width: 2048, height: 1000 });

  await page.goto(
    'https://latam.mastercard.com/es-region-lac/consumidores/soporte/convertidor-moneda.html',
    { waitUntil: 'domcontentloaded', timeout: 60000 }
  );
  await simulateHumanActivity(page);

  await page.setViewport({
    width: 1280 + Math.floor(Math.random() * 200),
    height: 800 + Math.floor(Math.random() * 200),
  });
  await page.keyboard.press('Tab');
  await page.waitForTimeout(300 + Math.random() * 500);


  await acceptOneTrust(page);
  await simulateHumanActivity(page);

  // add some mouse movement
  await page.mouse.move(100, 100);
  await page.mouse.move(200, 300);
  await page.mouse.move(400, 500);
  await page.mouse.click(400, 500);
  await page.evaluate(() => window.scrollBy(0, 200));

  const ctx = await findConverterContext(page, 30000);

  // FROM currency (Transaction Currency): select COP
  await waitVisible(ctx, '#tCurrency', 30000);
  await ctx.click('#tCurrency');
  await typeAndSelect(ctx, page, '#transactionCurr', 'eur', 'EUR');

  await simulateHumanActivity(page);

  // Amount
  await waitVisible(ctx, '#txtTAmt', 30000);
  await clearInput(ctx, '#txtTAmt');
  await ctx.click('#txtTAmt').catch(() => { });
  const randomValue = Math.floor(500 * Math.random()) + 500;
  await page.keyboard.type(randomValue.toString(), { delay: 30 });

  await simulateHumanActivity(page);

  // TO currency (Your Card Currency): select EUR
  await waitVisible(ctx, '#cardCurrency', 30000);
  await ctx.click('#cardCurrency');
  await typeAndSelect(ctx, page, '#cardCurr', 'cop', 'COP');

  await simulateHumanActivity(page);

  // Bank fee -> 0
  await waitVisible(ctx, '#BankFee', 30000);
  await clearInput(ctx, '#BankFee');
  await ctx.click('#BankFee').catch(() => { });
  await page.keyboard.type('0', { delay: 20 });
  await sleep(200 + Math.random() * 200);
  await page.keyboard.press('Enter');

  await simulateHumanActivity(page);



  // Date picker: select "Current Rate" if available
  /*
  try {
    await waitVisible(ctx, '#getDate', 10000);
    await ctx.click('#getDate');
    await sleep(400 + Math.random() * 300);
    try {
      await clickOptionByText(ctx, 'Current Rate', 10000);
    } catch { }
  } catch { }

  await sleep(400 + Math.random() * 300);
  */


  // Convert/Calculate (button label may vary)
  /*
  try {
    const convertBtn =
      (await ctx.$('#btnConvert')) ||
      (await ctx.$x("//button[contains(., 'Convert') or contains(., 'Calculate')]")).then(xs => xs[0]);
    if (convertBtn) await convertBtn.click();
  } catch { }

  await sleep(400 + Math.random() * 300);
  */

  // 8) Final snapshot to debug visually
  try {
    await page.screenshot({ path: 'logs/master_nu.png', fullPage: true });
  } catch { }

  // Optional: scrape a visible result summary
  try {
    await sleep(1400 + Math.random() * 300);
    const result = await ctx.evaluate(() => {
      const el = document.querySelector('#exchangeRateDiv');
      return el ? el.innerText.trim() : null;
    });
    if (result) console.log(result);
  } catch { }

  await browser.close();
})().catch(async (err) => {
  console.error('Script failed:', err);
  process.exit(1);
});

