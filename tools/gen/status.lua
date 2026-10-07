--- Usage: lua tools/gen/status.lua (or via tools/bake.lua)
--- Generates docs/generated/status.md — per-faction matrix:
--- ability slug → data row / scenario module / in-game test / TODO count.
--- Sources: data.units, data.abilities._sources, data.items,
--- scenario/generated/abilities_registry.lua, tests/generated/registry.lua.

local root = dofile("tools/_path.lua").setup()
local factionOrder = dofile("tools/gen/config/faction_order.lua")

local OUT_PATH = "docs/generated/status.md"
local COMMON = "common"
local CLASS_ORDER = { hero = 1, unit = 2, building = 3 }
local TODO_MARKERS = { "TODO", "FIXME", "HACK" }

local YES, NO = "✓", "·"

local function ensureDir(path)
    local winPath = path:gsub("/", "\\")
    os.execute('if not exist "' .. winPath .. '" mkdir "' .. winPath .. '"')
end

local function readFile(path)
    local f = io.open(path, "r")
    if not f then
        return nil
    end
    local src = f:read("*a")
    f:close()
    return src
end

local function modulePath(mod)
    return root .. "/src/" .. (mod:gsub("%.", "/")) .. ".lua"
end

local function countTodos(src)
    local count = 0
    for line in src:gmatch("[^\r\n]+") do
        for _, marker in ipairs(TODO_MARKERS) do
            if line:find(marker, 1, true) then
                count = count + 1
                break
            end
        end
    end
    return count
end

--- @return integer todo, table<string, boolean> referencedAbilities
local function scanModule(mod)
    local src = readFile(modulePath(mod))
    if not src then
        error("status: missing module file for " .. mod)
    end
    local refs = {}
    for slug in src:gmatch("Ids%.abilities%.(%w+)") do
        refs[slug] = true
    end
    return countTodos(src), refs
end

local function sortedKeys(t)
    local keys = {}
    for k in pairs(t) do
        keys[#keys + 1] = k
    end
    table.sort(keys)
    return keys
end

---@class StatusAbility
---@field data boolean
---@field class string|nil
---@field carriers string[]
---@field module string|nil
---@field usedBy table<string, boolean> scenario modules (basename) referencing Ids.abilities.<slug>
---@field todo integer

---@class StatusModule
---@field module string
---@field todo integer

---@class StatusFaction
---@field units table<string, any>
---@field abilities table<string, StatusAbility>
---@field mechanics table<string, StatusModule>
---@field tests table<string, StatusModule>

---@type table<string, StatusFaction>
local factions = {}

---@return StatusFaction
local function factionOf(name)
    local f = factions[name]
    if not f then
        f = { units = {}, abilities = {}, mechanics = {}, tests = {} }
        factions[name] = f
    end
    return f
end

---@type table<string, StatusAbility>
local abilityIndex = {}

---@return StatusAbility
local function abilityEntry(faction, slug)
    local f = factionOf(faction)
    local entry = f.abilities[slug]
    if not entry then
        entry = { data = false, carriers = {}, usedBy = {}, todo = 0 }
        f.abilities[slug] = entry
        abilityIndex[slug] = entry
    end
    return entry
end

-- 1. Data: abilities by source file (faction = file location)
for _, source in ipairs(require("data.abilities._sources")) do
    for slug in pairs(require(source.path)) do
        local entry = abilityEntry(source.faction or COMMON, slug)
        entry.data = true
        entry.class = source.class
    end
end

-- 2. Data: units + carriers
local function addCarrier(abilitySlug, carrierLabel)
    local entry = abilityIndex[abilitySlug]
    if entry then
        entry.carriers[#entry.carriers + 1] = carrierLabel
    end
end

for slug, row in pairs(require("data.units")) do
    factionOf(row.faction or COMMON).units[slug] = row
    for _, abilitySlug in ipairs(row.abilities or {}) do
        addCarrier(abilitySlug, slug)
    end
    for _, abilitySlug in ipairs(row.heroAbilities or {}) do
        addCarrier(abilitySlug, slug)
    end
end

for slug, row in pairs(require("data.items")) do
    for _, abilitySlug in ipairs(row.abilities or {}) do
        addCarrier(abilitySlug, slug .. " (item)")
    end
end

-- 3. Runtime: scenario registry (+ which data rows each module references)
local function markReferences(ownerName, refs)
    for slug in pairs(refs) do
        local entry = abilityIndex[slug]
        if entry and slug ~= ownerName then
            entry.usedBy[ownerName] = true
        end
    end
end

for _, mod in ipairs(require("scenario.generated.abilities_registry")) do
    local faction, rest = mod:match("^scenario%.factions%.(%w+)%.(.+)$")
    local name = mod:match("([^%.]+)$")
    local todo, refs = scanModule(mod)
    if faction and rest:match("^mechanics%.") then
        factionOf(faction).mechanics[name] = { module = mod, todo = todo }
    elseif faction then
        local entry = abilityEntry(faction, name)
        entry.module = mod
        entry.todo = todo
    elseif mod:match("^scenario%.common%.mechanics%.") then
        factionOf(COMMON).mechanics[name] = { module = mod, todo = todo }
    else
        error("status: unexpected scenario module path " .. mod)
    end
    markReferences(name, refs)
end

-- 4. Tests registry
for _, mod in ipairs(require("tests.generated.registry")) do
    local faction = mod:match("^tests%.factions%.(%w+)%.")
    local name = mod:match("([^%.]+)$")
    local todo = scanModule(mod)
    factionOf(faction or COMMON).tests[name] = { module = mod, todo = todo }
end

-- Faction order: configured first, then unknown (sorted), common last
local orderedFactions = {}
local seen = {}
for _, name in ipairs(factionOrder) do
    orderedFactions[#orderedFactions + 1] = name
    seen[name] = true
end
for _, name in ipairs(sortedKeys(factions)) do
    if not seen[name] and name ~= COMMON then
        orderedFactions[#orderedFactions + 1] = name
        seen[name] = true
    end
end
orderedFactions[#orderedFactions + 1] = COMMON

---@param f StatusFaction
local function summarize(f)
    local s = {
        hero = 0,
        unit = 0,
        building = 0,
        data = 0,
        runtime = 0,
        tests = 0,
        dataNoRuntime = 0,
        runtimeNoData = 0,
        runtimeNoTest = 0,
        todo = 0,
    }
    for _, row in pairs(f.units) do
        local class = row.class
        if s[class] then
            s[class] = s[class] + 1
        end
    end
    for slug, a in pairs(f.abilities) do
        local hasTest = f.tests[slug] ~= nil
        if a.data then
            s.data = s.data + 1
        end
        if a.module then
            s.runtime = s.runtime + 1
            if not a.data then
                s.runtimeNoData = s.runtimeNoData + 1
            end
            if not hasTest then
                s.runtimeNoTest = s.runtimeNoTest + 1
            end
        elseif a.data and not next(a.usedBy) then
            s.dataNoRuntime = s.dataNoRuntime + 1
        end
        s.todo = s.todo + a.todo
    end
    for _, m in pairs(f.mechanics) do
        s.todo = s.todo + m.todo
    end
    for _, t in pairs(f.tests) do
        s.tests = s.tests + 1
        s.todo = s.todo + t.todo
    end
    return s
end

local function mark(flag)
    return flag and YES or NO
end

---@param a StatusAbility
local function runtimeMark(a)
    if a.module then
        return YES
    end
    local owners = sortedKeys(a.usedBy)
    if #owners == 0 then
        return NO
    end
    return "→ " .. table.concat(owners, ", ")
end

local function num(n)
    return n > 0 and tostring(n) or ""
end

local function title(name)
    return name:sub(1, 1):upper() .. name:sub(2)
end

local out = {}
local function line(s)
    out[#out + 1] = s or ""
end

line("# Статус фракций")
line()
line("<!-- Autogenerated by tools/gen/status.lua — do not edit. Regenerate: lua tools/bake.lua -->")
line()
line("Матрица «data row → scenario-модуль → in-game тест» по фракциям.")
line("Источники: `src/data/*`, `src/scenario/generated/abilities_registry.lua`, `src/tests/generated/registry.lua`.")
line()
line(("Легенда: %s — есть, %s — нет. **TODO** — строки с `TODO` / `FIXME` / `HACK` в scenario-модуле и тесте."):format(YES, NO))
line()
line("- **Runtime** `→ slug` — своего модуля нет, но row используется модулем `slug` через `Ids.abilities.*` (вспомогательные buff/dummy/toggle rows).")
line("- **Data без Runtime** — ни своего модуля, ни ссылок из runtime: способность целиком на object data (пресет) либо runtime ещё не написан.")
line("- **Runtime без Data** — модуль не привязан к ability row (вспомогательный модуль, hero-логика и т.п.).")
line("- Модули из `tools/gen/config/*_excludes.lua` в реестры не попадают и здесь не показаны.")
line()

line("## Сводка")
line()
line("| Фракция | Герои | Юниты | Здания | Data | Runtime | Tests | Data без runtime | Runtime без data | Runtime без теста | TODO |")
line("|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|")
for _, name in ipairs(orderedFactions) do
    local s = summarize(factionOf(name))
    line(("| [%s](#%s) | %d | %d | %d | %d | %d | %d | %d | %d | %d | %d |"):format(
        title(name), name,
        s.hero, s.unit, s.building,
        s.data, s.runtime, s.tests,
        s.dataNoRuntime, s.runtimeNoData, s.runtimeNoTest,
        s.todo
    ))
end
line()

---@param f StatusFaction
local function renderUnits(f)
    local slugs = sortedKeys(f.units)
    if #slugs == 0 then
        return
    end
    table.sort(slugs, function(a, b)
        local ca = CLASS_ORDER[f.units[a].class] or 99
        local cb = CLASS_ORDER[f.units[b].class] or 99
        if ca ~= cb then
            return ca < cb
        end
        return a < b
    end)

    line("### Юниты")
    line()
    line("| Юнит | Класс | Способности |")
    line("|---|---|---|")
    for _, slug in ipairs(slugs) do
        local row = f.units[slug]
        local abilities = {}
        for _, a in ipairs(row.heroAbilities or {}) do
            abilities[#abilities + 1] = a
        end
        for _, a in ipairs(row.abilities or {}) do
            abilities[#abilities + 1] = a
        end
        line(("| %s | %s | %s |"):format(slug, row.class or "", table.concat(abilities, ", ")))
    end
    line()
end

---@param f StatusFaction
local function renderAbilities(f)
    local slugs = sortedKeys(f.abilities)
    if #slugs == 0 then
        return
    end

    line("### Способности")
    line()
    line("| Способность | Класс | Носители | Data | Runtime | Test | TODO |")
    line("|---|---|---|:-:|:-:|:-:|---:|")
    for _, slug in ipairs(slugs) do
        local a = f.abilities[slug]
        local test = f.tests[slug]
        local todo = a.todo + (test and test.todo or 0)
        table.sort(a.carriers)
        line(("| %s | %s | %s | %s | %s | %s | %s |"):format(
            slug,
            a.class or "",
            table.concat(a.carriers, ", "),
            mark(a.data),
            runtimeMark(a),
            mark(test),
            num(todo)
        ))
    end
    line()
end

---@param f StatusFaction
local function renderMechanics(f)
    local names = sortedKeys(f.mechanics)
    if #names == 0 then
        return
    end

    line("### Механики")
    line()
    line("| Модуль | Test | TODO |")
    line("|---|:-:|---:|")
    for _, name in ipairs(names) do
        local m = f.mechanics[name]
        local test = f.tests[name]
        line(("| %s | %s | %s |"):format(name, mark(test), num(m.todo + (test and test.todo or 0))))
    end
    line()
end

---@param f StatusFaction
local function renderOrphanTests(f)
    local orphans = {}
    for _, name in ipairs(sortedKeys(f.tests)) do
        if not f.abilities[name] and not f.mechanics[name] then
            orphans[#orphans + 1] = name
        end
    end
    if #orphans == 0 then
        return
    end

    line("### Тесты без модуля")
    line()
    line("| Тест | TODO |")
    line("|---|---:|")
    for _, name in ipairs(orphans) do
        local t = f.tests[name]
        line(("| %s | %s |"):format(t.module, num(t.todo)))
    end
    line()
end

for _, name in ipairs(orderedFactions) do
    local f = factionOf(name)
    line(("## %s"):format(title(name)))
    line()
    renderUnits(f)
    renderAbilities(f)
    renderMechanics(f)
    renderOrphanTests(f)
end

ensureDir(OUT_PATH:match("^(.*)/[^/]+$"))
local file = assert(io.open(OUT_PATH, "wb"))
file:write(table.concat(out, "\n"))
file:write("\n")
file:close()

local totalAbilities = 0
for _ in pairs(abilityIndex) do
    totalAbilities = totalAbilities + 1
end
print(("Generated %s (%d factions, %d abilities)"):format(OUT_PATH, #orderedFactions - 1, totalAbilities))
