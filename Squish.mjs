import { readFileSync, writeFileSync } from 'fs';

const files = [];
const process = (input, output, params) => {
  const keys = Object.keys(params);
  const vals = Object.values(params);
  const source = readFileSync(input, { encoding: 'utf8' });
  const result = new Function(...keys, `return \`${source}\`;`)(...vals)
  files.push(output);
  writeFileSync(output, result);
};

process("src/utils.lua", "dist/utils.lua", {});
process("src/party.lua", "dist/party.lua", {
  name: 'Party',
  width: 101,
  height: 46,
  event: Object.create({
    vals: [],
    add(val) {
      this.vals.push(val);
      return "";
    },
    show() {
      return this.vals.join(",");
    }
  }),
});

const xml = `
<Ui xmlns="http://www.blizzard.com/wow/ui/">
  ${files.map(file => `<Script file='${file}' />`).join("\n  ")}
  <Script file='Squish.lua' />
</Ui>`;

writeFileSync("./Squish.xml", xml);
console.log(xml);
