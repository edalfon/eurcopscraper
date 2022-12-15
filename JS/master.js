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
  
    await page.screenshot({ path: 'master_0.png' });
    
    // We need to get pass the cookies disclaimer, clicking the accept button
    const element = await page.$('#onetrust-accept-btn-handler');
    await element.click();
    
    // They use some trick here, that I did not fully investigate, but after
    // accepting the disclaimer, the page refreshes with some lag.
    // This workaround just waits a few seconds. We cannot simply wait for a
    // specific DOM element, 'cause they are all already there
    await page.waitFor(4000 + Math.random() * 3000);
    
    // This did not work. 
    //await page.select('#firstID', 'COLOMBIAN PESO � COP');
    //await page.select('#newID', 'EURO � EUR');
    
    await page.waitForSelector('.mczfields > #mczRowC > .btn-group > .btn > .filter-option');
    await page.click('.mczfields > #mczRowC > .btn-group > .btn > .filter-option');
    await page.waitForSelector('#mczRowC > .btn-group > .dropdown-menu > .dropdown-menu > li:nth-child(35) > .ng-binding');
    await page.click('#mczRowC > .btn-group > .dropdown-menu > .dropdown-menu > li:nth-child(35) > .ng-binding');
    
    await page.waitForSelector('.mczfields > #mczRowD > .btn-group > .btn > .filter-option');
    await page.click('.mczfields > #mczRowD > .btn-group > .btn > .filter-option');
    await page.waitForSelector('#mczRowD > .btn-group > .dropdown-menu > .dropdown-menu > li:nth-child(49) > .ng-binding');
    await page.click('#mczRowD > .btn-group > .dropdown-menu > .dropdown-menu > li:nth-child(49) > .ng-binding');
    
    
    await page.type('#BankFee', '0');
    await page.type('.carousel > .mczfields > #mczRowE > div > .required', '7777777');
    
    //await page.$eval('#getDate', el => el.value = '07-Jan-2019');

    await page.click('#btnSubmit');
    
    // Again, we cannot wait for a DOM element after clicking submit, 'cause
    // they are all there. Only its value gets updated. So we need to hard-wait
    await page.waitFor(4000 + Math.random() * 3000);
  
    // the screenshot should show feedback from the page that right part was clicked.
    await page.screenshot({ path: 'master.png' });
    
    
    //await page.waitForSelector('.currency-converter > .ng-scope > .ng-scope > #content > .mczLoading');
    //await page.click('.currency-converter > .ng-scope > .ng-scope > #content > .mczLoading');
    
    //const rate_element = await page.$('#mczRowF > div > input');
    //const rate = await rate_element.getProperty('value');
  
    let rate = await page.evaluate(() => {
       return document.getElementsByName('txtCardAmt')[0].value;
    });
    
    console.log(rate);
  
    await browser.close();
  } catch(e) {
    console.log('Error caught\n' + e);
    await browser.close();
  }

})();

