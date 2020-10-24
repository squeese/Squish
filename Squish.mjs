import { readFileSync, writeFileSync } from 'fs';
// import prettier from 'prettier';
// import UnitButton from './src/unitbutton.mjs';



const process = filename => {
  // const keys = Object.keys(params);
  // const vals = Object.values(params);
  // const source = readFileSync(filename, { encoding: 'utf8' });

  const source = "const v = ${val};";

  function fn(strings, ...symbols) {
    console.log(strings, symbols);
    return strings.reduceRight((b,a,i) => `${a}${symbols[i]}${b}`);
  }

  console.log(new Function("val", "tag", `return tag\`${source}\`;`)("10", fn));


  // return new Function(...keys, `return \`${source}\`;`)(...vals)
};

process("./src/test.lua");


//const process = (input, params) => {
  //const keys = Object.keys(params);
  //const vals = Object.values(params);
  //const source = readFileSync(input, { encoding: 'utf8' });
  //return new Function(...keys, `return \`${source}\`;`)(...vals)
//};

//const BACKDROP = "Interface\\\\Addons\\\\Squish\\\\media\\\\backdrop.tga";
//const MEDIA = {
  //BG_NOEDGE: `{ bgFile = [[${BACKDROP}]], edgeSize = 1, insets = { left = -1, right = -1, top = -1, bottom = -1 }}`,
  //BAR_FLAT: `[[Interface\\Addons\\Squish\\media\\flat.tga]]`,
  //FONT_VIXAR: `[[interface\\addons\\squish\\media\\vixar.ttf]]`,
//};

//writeFileSync("Squish.lua", prettier.format([
  //process("src/utils.lua", { MEDIA }),
  //process("src/onAttributeChange.lua", { MEDIA }),
  //process("src/castbar.lua", { MEDIA }),
  //process("src/root.lua", { MEDIA, UnitButton }),
//].join(""), { parser: 'lua' }));


//// class Aggregator {}
//// const aggregator = new Aggregator();

//class Scope {
  //cursor = 0;
  //events = {};
  //inputs = {};
  //GetEvent(name) {
    //if (!this.events[name])
      //this.events[name] = { ids: new Set(), codes: [] };
    //return this.events[name];
  //}
  //GetInput(ID, strings, symbols) {
    //if (!this.inputs[ID]) {
      //const ids = symbols.map(() => `__${this.cursor++}__`);
      //this.inputs[ID] = {
        //ids,
        //lua: strings.reduceRight((b, a, i) => `${a}${ids[i]}${b}`),
      //};
    //}
    //return this.inputs[ID];
  //};
//}

//let CURRENT = new Scope();


//function GET(strings, ...symbols) {
  //return {
    //ID: strings.reduceRight((b, a, i) => `${a}${i}${b}`),
    //strings,
    //symbols,
  //};
//}

//function SET(strings, ...symbols) {
  //return {
    //strings,
    //symbols,
    //args: [],
    //ids: {}
  //};
//}

//const USE = (events, ...templates) => {
  //const { strings, symbols, args, ids } = templates.reduceRight((code, { ID, strings, symbols }) => {
    //const input = CURRENT.GetInput(ID, strings, symbols);
    //symbols.forEach((name, index) => {
      //code.ids[name] = input.ids[index];
    //});
    //code.args.push(ID);
    //return code;
  //});
  //const code = strings.reduceRight((b, a, i) => {
    //return `${a}${ids[symbols[i]]}${b}`
  //});
  //events.split(" ").forEach(name => {
    //const event = CURRENT.GetEvent(name);
    //args.forEach(ID => event.ids.add(ID));
    //event.codes.push(code);
  //});
//}

//const FIRST = [
  //"UNIT_HEALTH UNIT_MAXHEALTH",
  //GET`local ${"val"}, ${"x"} = UnitHealth(self.unit)`,
  //GET`local ${"max"}, ${"y"} = UnitHealthMax(self.unit)`,
  //SET`self.healthBar:SetValue(${"val"})
      //self.healthBar:SetMinMaxValues(0, ${"max"})`
//];

//const OTHER = [
  //"UNIT_HEALTH UNIT_MAXHEALTH",
  //GET`local ${"X"}, ${"Y"} = UnitHealth(self.unit)`,
  //SET`self.healthBar:SetValue(${"X"})
      //self.healthBar:SetMinMaxValues(0, ${"Y"})`
//];

//USE(...FIRST);
//USE(...OTHER);

//console.log(CURRENT.inputs);
//console.log(CURRENT.events);



