const puppeteer = require('puppeteer');
const fs = require('fs');

(async () => {

  const browser = await puppeteer.launch();

  try {
    const page = await browser.newPage();

    // set the viewport so we know the dimensions of the screen
    await page.setViewport({ width: 1800, height: 2800 });

    // go to page (process.argv[0] should be node itself, process.argv[1] this script)
    await page.goto(process.argv[2]);

    await new Promise(r => setTimeout(r, 4000 + Math.random() * 3000));

    await page.screenshot({ path: process.argv[3] });

    // Wait for the content to load (adjust the selector as needed)
    //await page.waitForSelector('body');

    //let bodyHTML = await page.evaluate(() => document.body.innerHTML);

    const bodyHandle = await page.$('body');
    const bodyHTML = await page.evaluate(body => body.innerHTML, bodyHandle);

    fs.writeFile(process.argv[3] + '.html', bodyHTML, (err) => {
      if (err) {
        console.error(err);
      }
    });

    console.log(bodyHTML);

    await browser.close();
  } catch (e) {
    console.log('Error caught\n' + e);
    await browser.close();
  }

})();