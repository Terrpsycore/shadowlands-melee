---@meta

---@alias TestWait "WAIT"

---@class TestCase
---@field run fun(self: TestCase)
---@field delay fun(self: TestCase, delta: number, callback: fun()): TestWait
---@field finish fun(self: TestCase, ok: boolean, err: any)
---@field ok fun(self: TestCase)
---@field fail fun(self: TestCase, msg: string)
---@field report fun(self: TestCase, msg: string)
---@field createItem fun(self: TestCase, itemTypeId: string): item
---@field createUnit fun(self: TestCase, unitTypeId: string, player?: player, collision?: boolean): unit
---@field applyDummyOrder fun(self: TestCase, owner: player, target: unit, abilityId: integer, order: string, level?: integer)
---@field flush fun(self: TestCase): boolean
---@field addFlushCallback fun(self: TestCase, callback: fun())

---@alias TestFn fun(case: TestCase): TestWait|nil

---@class TestRunner
---@field test fun(self: TestRunner, name: string, testFunc: TestFn)
---@field createCase fun(self: TestRunner, name: string, testFunc: TestFn): TestCase
---@field freeCell fun(self: TestRunner, i: integer)

---@class CaseModule
---@field new fun(testName: string, testFunc: TestFn, x: number, y: number): TestCase
