// https://github.com/puppeteer/puppeteer
// "Puppeteer uses several defaults that can be customized through configuration files.
// For example, to change the default cache directory Puppeteer uses to install browsers, you can add a .puppeteerrc.cjs (or puppeteer.config.cjs) at the root of your application with the contents"
// This was required to make it work in codespaces bzw. github actions

const {join} = require('path');

/**
 * @type {import("puppeteer").Configuration}
 */
module.exports = {
  // Changes the cache location for Puppeteer.
  cacheDirectory: join(__dirname, '.cache', 'puppeteer'),
};
