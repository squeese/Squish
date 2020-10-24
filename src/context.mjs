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


export class Context {
  cursor = 0;
  events = {};
  inputs = {};
  GetEvent(name) {
    if (!this.events[name])
      this.events[name] = { ids: new Set(), codes: [] };
    return this.events[name];
  }
  GetInput(ID, strings, symbols) {
    if (!this.inputs[ID]) {
      const ids = symbols.map(() => `__${this.cursor++}__`);
      this.inputs[ID] = {
        ids,
        lua: strings.reduceRight((b, a, i) => `${a}${ids[i]}${b}`),
      };
    }
    return this.inputs[ID];
  };
  Use(events, ...templates) {
    const { strings, symbols, args, ids } = templates.reduceRight((code, { ID, strings, symbols }) => {
      const input = this.GetInput(ID, strings, symbols);
      symbols.forEach((name, index) => {
        code.ids[name] = input.ids[index];
      });
      code.args.push(ID);
      return code;
    });
    const code = strings.reduceRight((b, a, i) => {
      return `${a}${ids[symbols[i]]}${b}`
    });
    events.split(" ").forEach(name => {
      const event = this.GetEvent(name);
      args.forEach(ID => event.ids.add(ID));
      event.codes.push(code);
    });
  };
  Getters(event) {
    return [...(this.events[event]?.ids || [])].map(ID => this.inputs[ID].lua);
  }
  Setters(event) {
    return this.events[event]?.codes || [];
  }
  OnEventHandler() {
    console.log(this.events.UNIT_HEALTH)
    // console.log(this.inputs);
    console.log(this.Setters("UNIT_HEALTH"));
    const events = Object.keys(this.events);
    return `
      if event == "UNIT_SET" then
        ${events.filter(EVENTS_NORM).map(REGISTER_NORM).join("\n").trim()}
        ${events.filter(EVENTS_UNIT).map(REGISTER_UNIT).join("\n").trim()}
        ${this.Getters("UNIT_SET").join("\n").trim()}
        ${this.Setters("UNIT_SET").join("\n").trim()}

      elseif event == "UNIT_MOD" then
        ${events.filter(EVENTS_UNIT).map(REGISTER_UNIT).join("\n").trim()}
        ${this.Getters("UNIT_MOD").join("\n").trim()}
        ${this.Setters("UNIT_MOD").join("\n").trim()}

      elseif event == "UNIT_REM" then
        ${events.filter(EVENTS_ALL).map(UNREGISTER).join("\n").trim()}

      ${events.filter(NOT("UNIT_SET", "UNIT_MOD", "UNIT_REM")).map(name => `
        elseif event == "${name}" then
          ${this.Getters(name).join("\n").trim()}
          ${this.Setters(name).join("\n").trim()}
      `).join("\n").trim()}
      end
    `.trim();
  }
}

export function GET(strings, ...symbols) {
  return {
    ID: strings.reduceRight((b, a, i) => `${a}${i}${b}`),
    strings,
    symbols,
  };
}

export function SET(strings, ...symbols) {
  return {
    strings,
    symbols,
    args: [],
    ids: {}
  };
}

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
