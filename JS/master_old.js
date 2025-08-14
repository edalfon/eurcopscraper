const puppeteer = require('puppeteer'); // v23.0.0 or later

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  const timeout = 5000;
  page.setDefaultTimeout(timeout);

  {
    const targetPage = page;
    await targetPage.setViewport({
      width: 1558,
      height: 1150
    })
  }
  {
    const targetPage = page;
    await targetPage.goto('https://www.mastercard.com/global/en/personal/get-support/convert-currency.html');
  }
  {
    const targetPage = page;
    await puppeteer.Locator.race([
      targetPage.locator('::-p-aria(From)'),
      targetPage.locator('#tCurrency'),
      targetPage.locator('::-p-xpath(//*[@id=\\"tCurrency\\"])'),
      targetPage.locator(':scope >>> #tCurrency'),
      targetPage.locator('::-p-text(Transaction Currency)')
    ])
      .setTimeout(timeout)
      .click({
        offset: {
          x: 300,
          y: 17.600006103515625,
        },
      });
  }
  {
    const targetPage = page;
    await puppeteer.Locator.race([
      targetPage.locator('#currencyConverterForm > div > div:nth-of-type(2) li:nth-of-type(36) > a'),
      targetPage.locator('::-p-xpath(//*[@id=\\"mczRowC\\"]/div[1]/ul/li[36]/a)'),
      targetPage.locator(':scope >>> #currencyConverterForm > div > div:nth-of-type(2) li:nth-of-type(36) > a')
    ])
      .setTimeout(timeout)
      .click({
        offset: {
          x: 135.1999969482422,
          y: 9.2249755859375,
        },
      });
  }
  {
    const targetPage = page;
    await puppeteer.Locator.race([
      targetPage.locator('::-p-aria(To Required)'),
      targetPage.locator('#cardCurrency'),
      targetPage.locator('::-p-xpath(//*[@id=\\"cardCurrency\\"])'),
      targetPage.locator(':scope >>> #cardCurrency'),
      targetPage.locator('::-p-text(Your Card Currency)')
    ])
      .setTimeout(timeout)
      .click({
        offset: {
          x: 183,
          y: 17.5999755859375,
        },
      });
  }
  {
    const targetPage = page;
    await puppeteer.Locator.race([
      targetPage.locator('div:nth-of-type(3) li:nth-of-type(49) > a'),
      targetPage.locator('::-p-xpath(//*[@id=\\"mczRowD\\"]/div[1]/ul/li[49]/a)'),
      targetPage.locator(':scope >>> div:nth-of-type(3) li:nth-of-type(49) > a')
    ])
      .setTimeout(timeout)
      .click({
        offset: {
          x: 45.19999694824219,
          y: 10.38751220703125,
        },
      });
  }
  {
    const targetPage = page;
    await puppeteer.Locator.race([
      targetPage.locator('::-p-aria(Amount)'),
      targetPage.locator('#txtTAmt'),
      targetPage.locator('::-p-xpath(//*[@id=\\"txtTAmt\\"])'),
      targetPage.locator(':scope >>> #txtTAmt')
    ])
      .setTimeout(timeout)
      .click({
        offset: {
          x: 86.39999389648438,
          y: 20.600006103515625,
        },
      });
  }
  {
    const targetPage = page;
    await puppeteer.Locator.race([
      targetPage.locator('::-p-aria(Amount)'),
      targetPage.locator('#txtTAmt'),
      targetPage.locator('::-p-xpath(//*[@id=\\"txtTAmt\\"])'),
      targetPage.locator(':scope >>> #txtTAmt')
    ])
      .setTimeout(timeout)
      .fill('789');
  }
  {
    const targetPage = page;
    await puppeteer.Locator.race([
      targetPage.locator('::-p-aria(Bank Fee in % Required)'),
      targetPage.locator('#BankFee'),
      targetPage.locator('::-p-xpath(//*[@id=\\"BankFee\\"])'),
      targetPage.locator(':scope >>> #BankFee')
    ])
      .setTimeout(timeout)
      .click({
        offset: {
          x: 91.39999389648438,
          y: 24.5999755859375,
        },
      });
  }
  {
    const targetPage = page;
    await puppeteer.Locator.race([
      targetPage.locator('::-p-aria(Bank Fee in % Required)'),
      targetPage.locator('#BankFee'),
      targetPage.locator('::-p-xpath(//*[@id=\\"BankFee\\"])'),
      targetPage.locator(':scope >>> #BankFee')
    ])
      .setTimeout(timeout)
      .fill('0');
  }
  {
    const targetPage = page;
    await targetPage.keyboard.down('Tab');
  }
  {
    const targetPage = page;
    await targetPage.keyboard.up('Tab');
  }
  {
    const targetPage = page;
    await puppeteer.Locator.race([
      targetPage.locator('::-p-aria(Select date of transaction)'),
      targetPage.locator('#getDate'),
      targetPage.locator('::-p-xpath(//*[@id=\\"getDate\\"])'),
      targetPage.locator(':scope >>> #getDate'),
      targetPage.locator('::-p-text(28-July-2025)')
    ])
      .setTimeout(timeout)
      .click({
        offset: {
          x: 11.712493896484375,
          y: 18.5999755859375,
        },
      });
  }
  {
    const targetPage = page;
    await puppeteer.Locator.race([
      targetPage.locator('::-p-aria(27 July 2025, Sunday)'),
      targetPage.locator('tr:nth-of-type(5) > td:nth-of-type(1) > a'),
      targetPage.locator('::-p-xpath(//*[@id=\\"transactiondatepicker\\"]/div/table/tbody/tr[5]/td[1]/a)'),
      targetPage.locator(':scope >>> tr:nth-of-type(5) > td:nth-of-type(1) > a'),
      targetPage.locator('::-p-text(27)')
    ])
      .setTimeout(timeout)
      .click({
        offset: {
          x: 21.331253051757812,
          y: 17.125,
        },
      });
  }

  await browser.close();

})().catch(err => {
  console.error(err);
  process.exit(1);
});
