import path from 'path';
import { readFileSync, writeFileSync } from 'fs';

export default () => {
  const cleanup = JSON.parse(readFileSync("./SquishScan/cleanup.json"));
  const comment = / -- \[\d+\]\s$/
  const isString = /^".*"$/
  const entryBeg = /\t\{\r/
  const entryEnd = /\t\},/

  const saved = path.resolve("..", "..", "WTF", "Account", "SQUEESE2", "SavedVariables", "SquishScan.lua");
  const raw = readFileSync(saved, "utf8")

  const entries = [];
  let current
  let STATE
  const SearchBeg = line => {
    if (line.match(entryBeg)) {
      STATE = SearchNew
    }
  }
  const SearchNew = line => {
    const id = line.trim()
    current = { id: id.substr(1, id.length-3), data: [] }
    entries.push(current)
    STATE = SearchEnd
  }
  const SearchEnd = line => {
    if (line.match(entryEnd)) {
      STATE = SearchBeg
    } else {
      line = line.trim()
      line = line.substr(0, line.length-1);
      if (line.match(isString)) {
        //console.log("string", line);
        current.data.push(line.substr(1, line.length-2));
      } else if (line === "nil") {
        // console.log("nil", null);
        current.data.push(null);
      } else if (parseInt(line, 10).toString() === line) {
        current.data.push(parseInt(line, 10));
      } else if (line === 'true') {
        // console.log("line", true, line);
        current.data.push(true);
      } else if (line === 'false') {
        //console.log("line", false, line);
        current.data.push(false);
      } else {
        console.log("unknown?", line);
        current.data.push(line);
      }
    }
  }
  STATE = SearchBeg

  raw
    .split("\n")
    .map(line => line.replace(comment, ""))
    .forEach((line, index) => STATE(line, index))

  const cleanupRemaining = cleanup.filter(entry => entries.findIndex(e => e.id === entry) === 0);
  entries.forEach(entry => {
    writeFileSync(`./SquishScan/data/${entry.id}.json`, JSON.stringify(entry, null, 3));
    if (!cleanupRemaining.includes(entry.id))
      cleanupRemaining.push(entry.id);
  });
  console.log(cleanupRemaining);
  writeFileSync("./SquishScan/cleanup.json", JSON.stringify(cleanupRemaining, null, 3));
  writeFileSync("./SquishScan/cleanup.lua", `local CLEANUP = {\n${cleanupRemaining.map(name => `\t["${name}"] = true,`).join("\n")}\n}\n`);
}
