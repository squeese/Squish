import { readFileSync, writeFileSync } from 'fs';

const BACKDROP = `Interface\\\\Addons\\\\Squish\\\\media\\\\backdrop.tga`;
const textures = {
  backdrop: `{ bgFile = '${BACKDROP}', edgeSize = 1, insets = { left = -1, right = -1, top = -1, bottom = -1 }}`,
};

// const files = [];
const process = (input, params) => {
  const keys = Object.keys(params);
  const vals = Object.values(params);
  const source = readFileSync(input, { encoding: 'utf8' });
  return new Function(...keys, `return \`${source}\`;`)(...vals)
  // return result;
  // files.push(output);
  // writeFileSync(output, result);
};

writeFileSync("Squish.lua", [
  process("src/utils.lua", { textures }),
  //process("src/party.lua", {
    //textures,
    //name: 'Party',
    //width: 101,
    //height: 46,
    //event: Object.create({
      //vals: [],
      //add(val) {
        //this.vals.push(val);
        //return "";
      //},
      //show() {
        //return this.vals.join(",");
      //}
    //}),
  //}),
  process("src/root.lua", { textures }),
].join(""));


//const xml = `
//<Ui xmlns="http://www.blizzard.com/wow/ui/">
  //${files.map(file => `<Script file='${file}' />`).join("\n  ")}
//</Ui>`;

//writeFileSync("./Squish.xml", xml);
//console.log(xml);
