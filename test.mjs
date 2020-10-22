import { readFileSync } from 'fs';
// const tmp = readFileSync("./test.lua", { encoding: 'utf8' });

const test = (filename, params) => {
  const data = readFileSync(filename, { encoding: 'utf8' });
  const keys = Object.keys(params);
  const vals = Object.values(params);
  return new Function(...keys, `return \`${data}\`;`)(...vals);
};

console.log(test("./test.lua", {
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
}));
