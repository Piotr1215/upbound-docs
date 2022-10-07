const { applyTheme } = require("./colorTheme");
const { clipboardListener } = require("./clipboardEventListener");
const { getKeywords } = require("./hover-highlight-element.js");

(() => {
  applyTheme();
  clipboardListener();
  getKeywords();
})();
