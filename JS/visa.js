// npm i puppeteer-extra puppeteer-extra-plugin-stealth
const puppeteer = require('puppeteer-extra');
const StealthPlugin = require('puppeteer-extra-plugin-stealth');
puppeteer.use(StealthPlugin());

const site_url = process.argv[2];

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




(async () => {
  const browser = await puppeteer.launch({
    headless: 'new',
    userDataDir: './.mastercard-profile',
    args: [
      '--start-maximized',
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
      '--disable-gpu',
      '--lang=en-US,en;q=0.9,es;q=0.8',
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
  await page.setExtraHTTPHeaders({ 'Accept-Language': 'en-US,en;q=0.9,es;q=0.8' });
  await page.setUserAgent(randomUA);
  await page.setViewport({ width: 2048, height: 1000 });

  // load first the site
  const url = 'https://www.visa.co.uk/support/consumer/travel-support/exchange-rate-calculator.html';
  await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 60000 });

  await simulateHumanActivity(page);

  await page.keyboard.press('Enter');

  await simulateHumanActivity(page);

  // and now let's go to the site_url (parametrized url)
  await page.goto(site_url, { waitUntil: 'domcontentloaded', timeout: 60000 });

  await simulateHumanActivity(page);

  await simulateHumanActivity(page);

  // 8) Final snapshot to debug visually
  try {
    await page.screenshot({ path: 'logs/visa.png', fullPage: true });
  } catch { }

  // return everything
  let jsonText = await page.evaluate(() => document.body.textContent);
  console.log(jsonText);


  await browser.close();
})().catch(async (err) => {
  console.error('Script failed:', err);
  process.exit(1);
});
