import { readFileSync, writeFileSync } from 'fs';
import prettier from 'prettier';
import UnitButton from './src/unitbutton.mjs';


const process = (input, params) => {
  const keys = Object.keys(params);
  const vals = Object.values(params);
  const source = readFileSync(input, { encoding: 'utf8' });
  return new Function(...keys, `return \`${source}\`;`)(...vals)
};

const BACKDROP = "Interface\\\\Addons\\\\Squish\\\\media\\\\backdrop.tga";
const MEDIA = {
  BG_NOEDGE: `{ bgFile = [[${BACKDROP}]], edgeSize = 1, insets = { left = -1, right = -1, top = -1, bottom = -1 }}`,
  BAR_FLAT: `[[Interface\\Addons\\Squish\\media\\flat.tga]]`,
  FONT_VIXAR: `[[interface\\addons\\squish\\media\\vixar.ttf]]`,
};

writeFileSync("Squish.lua", prettier.format([
  process("src/utils.lua", { MEDIA }),
  process("src/castbar.lua", { MEDIA }),
  process("src/root.lua", { MEDIA, UnitButton }),
].join(""), { parser: 'lua' }));


