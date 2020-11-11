import path from 'path';
import { existsSync, mkdirSync, copyFileSync, readFileSync, writeFileSync } from 'fs';
import prettier from 'prettier';
import * as context from './context.mjs';

const AddonPathConfig = path.resolve("..", "AddOns", "SquishConfig");
const AddonPathUI = path.resolve("..", "AddOns", "SquishUI");
const AddonPathUIMedia = path.resolve("..", "AddOns", "SquishUI", "media");
if (!existsSync(AddonPathConfig))
  mkdirSync(AddonPathConfig)
if (!existsSync(AddonPathUI))
  mkdirSync(AddonPathUI)
if (!existsSync(AddonPathUIMedia))
  mkdirSync(AddonPathUIMedia)
copyFileSync(path.resolve("SquishConfig", "SquishConfig.toc"), path.resolve("..", "AddOns", "SquishConfig", "SquishConfig.toc"), 0)
copyFileSync(path.resolve("SquishUI", "SquishUI.toc"), path.resolve("..", "AddOns", "SquishUI", "SquishUI.toc"), 0)
copyFileSync(path.resolve("SquishUI", "Bindings.xml"), path.resolve("..", "AddOns", "SquishUI", "Bindings.xml"), 0)
copyFileSync(path.resolve("SquishUI", "media", "backdrop.tga"), path.resolve("..", "AddOns", "SquishUI", "media", "backdrop.tga"), 0)
copyFileSync(path.resolve("SquishUI", "media", "edgefile.tga"), path.resolve("..", "AddOns", "SquishUI", "media", "edgefile.tga"), 0)
copyFileSync(path.resolve("SquishUI", "media", "flat.tga"), path.resolve("..", "AddOns", "SquishUI", "media", "flat.tga"), 0)
copyFileSync(path.resolve("SquishUI", "media", "minimalist.tga"), path.resolve("..", "AddOns", "SquishUI", "media", "minimalist.tga"), 0)
copyFileSync(path.resolve("SquishUI", "media", "vixar.ttf"), path.resolve("..", "AddOns", "SquishUI", "media", "vixar.ttf"), 0)

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
  const entries = new Set();
  scope.locals = () => ([...entries]).join("\n");
  scope.locals.use = str => void entries.add(`local ${str.split(".").map(part => `${part.charAt(0).toUpperCase()}${part.slice(1)}`).join("_")} = ${str}`);
}());

(function() {
  const lines = [];
  scope.cleanup = () => lines.map(name => `${name} = nil`.trim()).join("\n");
  scope.cleanup.add = line => void lines.push(line);
}());

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

writeFileSync(path.resolve("..", "AddOns", "SquishUI", "SquishUI.lua"), prettier
  .format(scope.include("./src/SquishUI.lua"), {parser: 'lua', printWidth: 10000 })
  .split("\n")
  .filter(Boolean)
  .join("\n"));

writeFileSync(path.resolve("..", "AddOns", "SquishConfig", "SquishConfig.lua"), prettier
  .format(scope.include("./src/SquishConfig.lua"), {parser: 'lua', printWidth: 10000 })
  .split("\n")
  .filter(Boolean)
  .join("\n"));
