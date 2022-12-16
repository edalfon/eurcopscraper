const puppeteer = require('puppeteer');

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

    let bodyHTML = await page.evaluate(() => document.body.innerHTML);
    
    console.log(bodyHTML);
  
    await browser.close();
  } catch(e) {
    console.log('Error caught\n' + e);
    await browser.close();
  }

})();