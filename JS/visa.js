const puppeteer = require('puppeteer');


(async () => {

  const browser = await puppeteer.launch();

  try {

    const page = await browser.newPage();

    // set the viewport so we know the dimensions of the screen
    await page.setViewport({ width: 1800, height: 1200 });

    // go to the mastercard page 
    await page.goto('https://www.visa.de/cmsapi/fx/rates?amount=8201936&fee=0&utcConvertedDate=04%2F17%2F2024&exchangedate=04%2F17%2F2024&fromCurr=EUR&toCurr=COP');

    await new Promise(r => setTimeout(r, 4000 + Math.random() * 3000));

    await page.screenshot({ path: 'logs/visa.png' });

    let bodyHTML = await page.evaluate(() => document.body.innerHTML);

    console.log(bodyHTML);

    await browser.close();
  } catch (e) {
    console.log('Error caught\n' + e);
    await browser.close();
  }

})();
