const REGISTER_NORM = event => `self:RegisterEvent("${event}")`;
const REGISTER_UNIT = event => `self:RegisterUnitEvent("${event}", self.unit)`
const NOT = (...args) => event => !args.includes(event);
const UNREGISTER = event => `self:UnregisterEvent("${event}")`;
const EVENTS_ALL = event => {
  if (event === "GUID_SET") return false;
  if (event === "GUID_MOD") return false;
  if (event === "GUID_REM") return false;
  if (event === "UNIT_SET") return false;
  if (event === "UNIT_MOD") return false;
  if (event === "UNIT_REM") return false;
  return true;
};
const EVENTS_NORM = event => {
  if (event === "GUID_SET") return false;
  if (event === "GUID_MOD") return false;
  if (event === "GUID_REM") return false;
  return event.substr(0, 5) !== "UNIT_";
};
const EVENTS_UNIT = event => {
  if (event.substr(0, 5) !== "UNIT_") return false;
  if (event === "UNIT_SET") return false;
  if (event === "UNIT_MOD") return false;
  if (event === "UNIT_REM") return false;
  return true;
};

export function GET(strings, ...symbols) {
  return strings.reduceRight((b, a, i) => {
    const value = symbols[i];
    return typeof value === 'function'
      ? `${a}${value(i)}${b}`
      : `${a}${value}${b}`;
  });
}

const event = (context, name) => {
  const event = context.events[name];
  if (!event) return "";
  const getters = {};
  const code = [];
  const symbols = [];
  const next = () => {
    const symbol = `__${symbols.length}`;
    symbols.push(symbol);
    return symbol;
  };
  event.forEach(action => {
    const args = [];
    action.getters.forEach(fn => {
      if (!getters[fn.ident]) {
        const index = symbols.length;
        code.push(fn(next).trim());
        fn.symbols = symbols.slice(index, symbols.length).reverse();
        getters[fn.ident] = fn;
      }
      args.push(...getters[fn.ident].symbols);
    });
    code.push(action.setter(...args).trim());
  });
  return code.join("\n");
}

const ident = v => v;
export class Context {
  events = {};
  use(...actions) {
    const setter = actions.pop();
    const events = new Set();
    const getters = new Map();
    actions.forEach(([actionEvents, ...actionGetters]) => {
      actionEvents.split(" ").forEach(event => events.add(event));
      actionGetters.forEach(getter => {
        getter.ident = getter(ident);
        getters.set(getter.ident, getter);
      });
    });
    events.forEach(name => {
      if (!this.events[name])
        this.events[name] = [];
      const event = this.events[name];
      event.push({ getters, setter });
    });
    return "";
  }
  compile() {
    const events = Object.keys(this.events);
    return `
      if event == "UNIT_SET" then
        ${events.filter(EVENTS_NORM).map(REGISTER_NORM).join("\n").trim()}
        ${events.filter(EVENTS_UNIT).map(REGISTER_UNIT).join("\n").trim()}
        ${event(this, "UNIT_SET")}
      elseif event == "UNIT_MOD" then
        ${events.filter(EVENTS_UNIT).map(REGISTER_UNIT).join("\n").trim()}
        ${event(this, "UNIT_MOD")}
      elseif event == "UNIT_REM" then
        ${events.filter(EVENTS_ALL).map(UNREGISTER).join("\n").trim()}
        ${event(this, "UNIT_REM")}
      ${events.filter(NOT("UNIT_SET", "UNIT_MOD", "UNIT_REM")).map(name => `
        elseif event == "${name}" then
          ${event(this, name)}
      `).join("\n")}
      end
    `.trim();
  }
}
