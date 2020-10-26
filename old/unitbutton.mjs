const VariableCode = fns => {
  const locals = fns.reduce((o, { vars }) => ({...o, ...vars }), {});
  return Object.keys(locals).map(key => `local ${key} = ${locals[key]}`).join("\n").trim();
};
const UpdateCode = fns => fns.map(({ code }) => code).join("\n").trim();
const OTHER_EVENTS = e => e.substr(0, 5) !== 'UNIT_';
const UNIT_EVENTS = e => e.substr(0, 5) === 'UNIT_';
const IfElse = (...args) => {
  const result = args.map(({ test, body }, index) => `
    ${index ? 'elseif' : 'if'} ${test} then
      ${body}
  `.trim()).join("\n").trim();
  return args.length ? `${result} \nend` : '';
};

// PARTY_MEMBER_ENABLE

const AddEvent = (events, initial) => (...args) => {
  const [code, vars, ...names] = args.reverse();
  if (names.length && names[names.length-1] === true)
    names[names.length-1] = initial;
  else
    names.pop();
  names.forEach(name => {
    if (!events[name])
      events[name] = [];
    events[name].push({ vars, code });
  });
  return "";
};

const AddScript = scripts => (name, code) => {
  if (!scripts[name]) {
    scripts[name] = [];
    if (name === "OnAttributeChanged")
      scripts[name].push(`local key, val = ...`);
  }
  scripts[name].push(code.trim());
  return "";
};

export default (unit, config) => {
  const events = {};
  const [initialEvent, addEvent] = (function() {
    if (unit === "player") {
      events.PLAYER_ENTERING_WORLD = [() => Object.keys(events).filter(e => e !== "PLAYER_ENTERING_WORLD").map(e => {
        return (UNIT_EVENTS(e))
          ? `self:RegisterUnitEvent("${e}", "${unit}")`
          : `self:RegisterEvent("${e}")`;
      }).join("\n").trim()];
      return [`self:RegisterEvent("PLAYER_ENTERING_WORLD")`, AddEvent(events, "PLAYER_ENTERING_WORLD")];
    } else if (unit === "target") {
      events.PLAYER_TARGET_CHANGED = [() => `
        if not UnitExists("target") then
          self:UnregisterAllEvents()
          self:RegisterEvent("PLAYER_TARGET_CHANGED")
          self.__active = nil
          return
        elseif not self.__active then
          ${Object.keys(events).filter(e => e !== "PLAYER_TARGET_CHANGED").map(e => {
            return (UNIT_EVENTS(e))
              ? `self:RegisterUnitEvent("${e}", "${unit}")`
              : `self:RegisterEvent("${e}")`;
          }).join("\n").trim()}
          self.__active = true
        end
      `.trim()];
      return [`self:RegisterEvent("PLAYER_TARGET_CHANGED")`, AddEvent(events, "PLAYER_TARGET_CHANGED")];
    } else if (unit === "focus") {
      events.PLAYER_FOCUS_CHANGED = [];
      return [`self:RegisterEvent("PLAYER_FOCUS_CHANGED")`, AddEvent(events, "PLAYER_FOCUS_CHANGED")];
    }
    return ["", () => ""];
  }());
  const scripts = {};
  return `(function(parent)
    local self = CreateFrame("button", nil, parent, "SecureUnitButtonTemplate,BackdropTemplate")
    self.unit = "${unit}"
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    self:RegisterForClicks("AnyUp")
    self:EnableMouseWheel(true)
    self:SetAttribute('*type1', 'target')
    self:SetAttribute('*type2', 'togglemenu')
    self:SetAttribute('toggleForVehicle', true)
    self:SetAttribute("unit", self.unit)
    RegisterUnitWatch(self)
    ${config(addEvent, AddScript(scripts)).trim()}
    ${initialEvent}
    self:SetScript("OnEvent", function(self, event, unit, ...)
      ${IfElse(
        ...Object.keys(events).filter(OTHER_EVENTS).map(name => ({
          test: `event == "${name}"`,
          body: `
            ${events[name].filter(obj => typeof obj === "function").map(fn => fn()).join("\n").trim()}
            ${VariableCode(events[name])}
            ${UpdateCode(events[name])}
          `
        })),
        ...Object.keys(events).filter(UNIT_EVENTS).map(name => ({
          test: `event == "${name}"`,
          body: `
            ${VariableCode(events[name])}
            ${UpdateCode(events[name])}
          `
        }))
      )}
    end)
    ${Object.keys(scripts).map(name => `self:SetScript("${name}", function(self, ...)
      ${scripts[name].join("\n").trim()}
    end)`).join("\n").trim()}
    return self
  end)`;
};
