-- Refs values: raw id strings via Ids.abilities.* / Ids.units.* / …
-- Validation: AbilityConfig.compile() at module load (nil id → error)

---@alias FourCCId integer

---@class RefsSpec
---@field abilities? table<string, string>
---@field buffs? table<string, string>
---@field units? table<string, string|string[]>
---@field items? table<string, string|string[]>

---@class AbilityScenarioSpec
---@field refs RefsSpec
---@field balance? table

---@class RefsCompiled
---@field abilities table<string, FourCCId>
---@field buffs table<string, FourCCId>
---@field units table<string, FourCCId|FourCCId[]>
---@field items table<string, FourCCId>

---@class AbilityScenarioConfig
---@field refs RefsCompiled
---@field balance table

return {}
