import { readFileSync, writeFileSync } from 'fs';
import prettier from 'prettier';
import * as context from './context.mjs';

const scope = { ...context };

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

(function() {
  function templates() {}
  const trim = val => typeof val === 'string' ? val.trim() : val;
  scope.template = new Proxy(templates, {
    apply: (target, _, [name, value, filler]) => {
      if (target[name] !== undefined) {
        console.log(`Error: setting template '${name}' twice.`);
        process.exit(1);
      }
      target[name] = typeof value === 'function'
        ? (...args) => trim(value(...args))
        : trim(value);
      global[name] = target[name];
      return filler
    }
  });
}());

writeFileSync("Squish.lua", prettier
  .format(scope.include("./src/ui.lua"), {parser: 'lua', printWidth: 10000 })
  .split("\n")
  .filter(Boolean)
  .join("\n"));

/*
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


(function() {
  const lines = [];
  scope.setDefer = val => void lines.push(val.trim());
  scope.incDefer = () => lines.join("/n");
}());

scope.ctx = cb => {
  const instance = new Context();
  return cb(instance);
};
*/
