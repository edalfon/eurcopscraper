const puppeteer = require('puppeteer');


(async () => {
  
    /*   
    const browser = await puppeteer.launch({
      headless: false,
      slowMo: 250 // slow down by 250ms
    });
   */
  const browser = await puppeteer.launch();
  
  /*
  browser.on('targetchanged', async target => {
    const targetPage = await target.page();
    const client = await targetPage.target().createCDPSession();
    await client.send('Runtime.evaluate', {
      expression: `Date.now = function() { return 1556668800000; }`
    });
  });
  */

  try {
    
    const page = await browser.newPage();
  
    // set the viewport so we know the dimensions of the screen
    await page.setViewport({ width: 1800, height: 1200 });
    
    // go to the mastercard page 
    await page.goto('https://www.mastercard.co.uk/en-gb/consumers/get-support/convert-currency.html');
  
    //await page.screenshot({ path: 'logs/master_0.png' });
    
    // We need to get pass the cookies disclaimer, clicking the accept button
    await page.waitForSelector('#onetrust-accept-btn-handler');
    await page.click('#onetrust-accept-btn-handler');
    
    // They use some trick here, that I did not fully investigate, but after
    // accepting the disclaimer, the page refreshes with some lag.
    // This workaround just waits a few seconds. We cannot simply wait for a
    // specific DOM element, 'cause they are all already there
    await new Promise(r => setTimeout(r, 4000 + Math.random() * 3000));
    
    //await page.screenshot({ path: 'logs/master_1.png' });

    //await page.waitFor(10); would fail
    // This did not work. 
    //await page.select('#firstID', 'COLOMBIAN PESO � COP');
    //await page.select('#newID', 'EURO � EUR');
    
    await page.waitForSelector('#tCurrency')
    await page.click('#tCurrency')
    
    await page.waitForSelector('#mczRowC > .dropdown-block > .dropdown-menu > .ng-scope:nth-child(35) > .ng-binding')
    await page.click('#mczRowC > .dropdown-block > .dropdown-menu > .ng-scope:nth-child(35) > .ng-binding')
    
    await page.waitForSelector('#txtTAmt')
    await page.click('#txtTAmt')
    
    await page.waitForSelector('#cardCurrency')
    await page.click('#cardCurrency')
    
    await page.waitForSelector('#mczRowD > .dropdown-block > .dropdown-menu > .ng-scope:nth-child(49) > .ng-binding')
    await page.click('#mczRowD > .dropdown-block > .dropdown-menu > .ng-scope:nth-child(49) > .ng-binding')
        
    
    await page.type('#BankFee', '0');
    await page.type('#txtTAmt', '7777777');
    
    // There's no submit button anymore, it just updates when you click the date
    await page.waitForSelector('#getDate')
    await page.click('#getDate')
    
    await page.waitForSelector('.hydrated > .dxp-theme-white > .dxp-cta-with-icon > .dxp-btn > span')
    await page.click('.hydrated > .dxp-theme-white > .dxp-cta-with-icon > .dxp-btn > span')
        
    // Again, we cannot wait for a DOM element after clicking submit, 'cause
    // they are all there. Only its value gets updated. So we need to hard-wait
    await new Promise(r => setTimeout(r, 4000 + Math.random() * 3000));
  
    // the screenshot should show feedback from the page that right part was clicked.
    await page.screenshot({ path: 'logs/master.png' });
    
    // Finally we get the text (using selector)  
    await page.waitForSelector('#exchangeRateDiv .ng-binding+ .ng-binding')
    let rate_element = await page.$('#exchangeRateDiv .ng-binding+ .ng-binding')
    let rate = await page.evaluate(el => el.textContent, rate_element);
    
    console.log(rate);
  
    await browser.close();
  } catch(e) {
    console.log('Error caught\n' + e);
    await browser.close();
    throw e; // let it fail again!
  }

})();

