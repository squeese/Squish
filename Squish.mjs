import { readFileSync, writeFileSync } from 'fs';
import prettier from 'prettier';


const process = (input, params) => {
  const keys = Object.keys(params);
  const vals = Object.values(params);
  const source = readFileSync(input, { encoding: 'utf8' });
  return new Function(...keys, `return \`${source}\`;`)(...vals)
};

const BACKDROP = "Interface\\\\Addons\\\\Squish\\\\media\\\\backdrop.tga";
const MEDIA = {
  BG_NOEDGE: `{ bgFile = [[${BACKDROP}]], edgeSize = 1, insets = { left = -1, right = -1, top = -1, bottom = -1 }}`,
  BAR_FLAT: `[[Interface\\Addons\\Squish\\media\\flat.tga]]`
};

class Context {
  events = {};
  event(name, vars, code) {
    if (!this.events[name])
      this.events[name] = [];
    this.events[name].push({ vars, code });
  };
};

let CURRENT_CONTEXT = null;

const UnitButton = (unit, config) => {
  CURRENT_CONTEXT = new Context();
  const result = `(function(parent)
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
    self:SetBackdrop(${MEDIA.BG_NOEDGE})
    self:SetBackdropColor(0, 0, 0, 0.75)
    self:SetBackdropBorderColor(0, 0, 0, 1)
    ${config(CURRENT_CONTEXT).trim()}
    ${Object.keys(CURRENT_CONTEXT.events).map(event =>
      `self:RegisterEvent("${event}")`).join("\n").trim()}
    self:SetScript("OnEvent", function(self, event, unit, ...)
      ${(function() {
        const NEvents = Object.keys(CURRENT_CONTEXT.events).filter(event => event.substr(0, 5) !== 'UNIT_');
        const UEvents = Object.keys(CURRENT_CONTEXT.events).filter(event => event.substr(0, 5) === 'UNIT_');
        let cond = "";
        let result = ``;
        NEvents.forEach(event => {
          const locals = CURRENT_CONTEXT.events[event].reduce((o, { vars }) => ({...o, ...vars }), {});
          result += `
            ${cond || 'if'} event == "${event}" then
              ${Object.keys(locals).map(key => `local ${key} = ${locals[key]}`).join("\n").trim()}
              ${CURRENT_CONTEXT.events[event].map(({ code }) => code).join("\n").trim()}
          `;
          cond = 'elseif';
        });
        if (UEvents.length) {
          result += `
            ${cond || 'if'} unit ~= nil and self.unit ~= unit then return
          `;
          result += UEvents.map(event => {
            const locals = CURRENT_CONTEXT.events[event].reduce((o, { vars }) => ({...o, ...vars }), {});
            return `
              elseif event == "${event}" then
                ${Object.keys(locals).map(key => `local ${key} = ${locals[key]}`).join("\n").trim()}
                ${CURRENT_CONTEXT.events[event].map(({ code }) => code).join("\n").trim()}
            `;
          }).join("\n").trim();
          cond = 'elseif';
        }
        return `${result} ${cond && "end"}`;
      })()}
    end)
    return self
  end)`;
  CURRENT_CONTEXT = null;
  return result;
};

const StatusBar = config => `(function(parent)
  local bar = CreateFrame("statusbar", nil, parent)
  bar:SetStatusBarTexture(${MEDIA.BAR_FLAT})
  ${config(CURRENT_CONTEXT).trim()}
  return bar
end)`;

const UnitCurHealth = (...args) => {
  const config = args.pop();
  args.forEach(event => CURRENT_CONTEXT.event(event, { curHealth: 'UnitHealth(self.unit)' }, config));
  CURRENT_CONTEXT.event("UNIT_HEALTH", { curHealth: 'UnitHealth(self.unit)' }, config);
  return "";
};

const UnitMaxHealth = (...args) => {
  const config = args.pop();
  args.forEach(event => CURRENT_CONTEXT.event(event, { maxHealth: 'UnitHealthMax(self.unit)' }, config));
  CURRENT_CONTEXT.event("UNIT_MAXHEALTH", { maxHealth: 'UnitHealthMax(self.unit)' }, config);
  return "";
};

const UnitColor = (event, config) => {
  CURRENT_CONTEXT.event(event, { color: 'ClassColor(self.unit)' }, config);
  return "";
};

const Event = (...args) => {
  const [config, vars, ...events] = args.reverse();
  events.forEach(event => CURRENT_CONTEXT.event(event, vars, config.trim()));
  return "";
};


writeFileSync("Squish.lua", prettier.format([
  process("src/utils.lua", { MEDIA }),
  process("src/root.lua", { MEDIA, UnitButton, StatusBar, UnitCurHealth, UnitMaxHealth, UnitColor, Event }),
].join(""), { parser: 'lua' }));

/*
  CURRENT_CONTEXT.event('PLAYER_ENTERING_WORLD', {
    unitCurHealth: `UnitHealth(self.unit)`,
    unitMaxHealth: `UnitHealthMax(self.unit)`,
  }, `
    self.${name}:SetMinMaxValues(0, unitMaxHealth)
    self.${name}:SetValue(unitCurHealth)
  `);

  CURRENT_CONTEXT.event('UNIT_MAXHEALTH', {
    unitMaxHealth: `UnitHealthMax(self.unit)`,
  }, `
    self.${name}:SetMinMaxValues(0, unitMaxHealth)
  `);

  CURRENT_CONTEXT.event('UNIT_HEALTH', {
    unitCurHealth: `UnitHealth(self.unit)`,
  }, `
    self.${name}:SetValue(unitCurHealth)
  `);
  return "";
  ${UpdateUnitHealth("health")}
const HealthBar = (context, name, config) => {
  context.event('PLAYER_ENTERING_WORLD', {
    unitCurHealth: `UnitHealth(self.unit)`,
    unitMaxHealth: `UnitHealthMax(self.unit)`,
  }, `
    self.${name}:SetMinMaxValues(0, unitMaxHealth)
    self.${name}:SetValue(unitCurHealth)
  `);
  context.event('UNIT_MAXHEALTH', {
    unitMaxHealth: `UnitHealthMax(self.unit)`,
  }, `
    self.${name}:SetMinMaxValues(0, unitMaxHealth)
  `);
  context.event('UNIT_HEALTH', {
    unitCurHealth: `UnitHealth(self.unit)`,
  }, `
    self.${name}:SetValue(unitCurHealth)
  `);

  return `local ${name} = (function(parent)
    local bar = CreateFrame("statusbar", nil, parent)
    ${config.trim()}
    parent.${name} = bar;
    return bar
  end)`;
};

*/


