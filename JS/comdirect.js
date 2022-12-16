const puppeteer = require('puppeteer');


(async () => {
  
  const browser = await puppeteer.launch();
  
  try {
    
    const page = await browser.newPage();
  
    // set the viewport so we know the dimensions of the screen
    await page.setViewport({ width: 1800, height: 1200 });
    
    // go to the commerzbank page, originally in this link
    // https://www.commerzbank.com/de/hauptnavigation/kunden/kursinfo/devisenk/weitere_waehrungen___indikative_kurse/indikative_kurse.html
    // but this one has actually an iframe, pointing to this other link
    await page.goto('https://commander.commerzbank.com/efx-rates/pages/de/fixing-rates-other.html');
  
    await new Promise(r => setTimeout(r, 4000 + Math.random() * 3000));
    
    await page.screenshot({ path: 'logs/comdirect.png' });

    let bodyHTML = await page.evaluate(() => document.body.innerHTML);
    
    console.log(bodyHTML);
  
    await browser.close();
  } catch(e) {
    console.log('Error caught\n' + e);
    await browser.close();
  }

})();

