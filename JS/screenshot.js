const puppeteer = require('puppeteer');
import { argv } from 'node:process';

(async () => {
  
  const browser = await puppeteer.launch();
  
  try {
    
    const page = await browser.newPage();
  
    // set the viewport so we know the dimensions of the screen
    await page.setViewport({ width: 1800, height: 1200 });
    
    // go to the mastercard page 
    await page.goto('http://www.elcondorcambios.com/');

    
  
    await new Promise(r => setTimeout(r, 4000 + Math.random() * 3000));
    
    await page.screenshot({ path: 'logs/condor.png' });

    let bodyHTML = await page.evaluate(() => document.body.innerHTML);
    
    console.log(bodyHTML);
  
    await browser.close();
  } catch(e) {
    console.log('Error caught\n' + e);
    await browser.close();
  }

})();