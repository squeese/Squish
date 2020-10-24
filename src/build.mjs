import { readFileSync, writeFileSync } from 'fs';
import prettier from 'prettier';
import { Context, GET, SET } from './context.mjs';

const scope = { GET, SET };

scope.include = filename => {
  const source = readFileSync(filename, { encoding: 'utf8' });
  function template(chunks, ...values) {
    const symbols = values.map(value => typeof value !== 'function' ? () => value : value);
    const write = index => {
      const value = symbols[index]();
      return (!value && typeof value !== "number") ? "" : value;
    };
    return chunks.reduceRight((next, prev, i) => `${prev}${write(i)}${next}`);
  }
  const keys = Object.keys(scope);
  const vals = Object.values(scope);
  return new Function("tag", ...keys, `return tag\`${source}\`;`)(template, ...vals);
};

scope.source = {
  set(name, ...args) {
    this[name] = args;
  },
  use(instance, name, ...setters) {
    return instance.Use(...this[name], ...setters);
  }
};

scope.block = value => `(function()
  ${value.trim()}
  return self
end)()`;

scope.ignore = () => ``;

scope.ctx = cb => {
  const instance = new Context();
  return cb(instance);
};

writeFileSync("Squish.out.lua", prettier.format(scope.include("./Squish.src.lua"), {parser: 'lua'}));
