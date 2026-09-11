---@meta

---@alias TestWait "WAIT"
---@alias TestReporterFn fun(testName: string, ok: boolean, err?: string)
---@alias TestFn fun(case: TestCase): TestWait|nil

---@class TestCase
---@field run fun(self: TestCase)
---@field delay fun(self: TestCase, delta: number, callback: fun()): TestWait
---@field finish fun(self: TestCase, ok: boolean, err: any)
---@field ok fun(self: TestCase)
---@field fail fun(self: TestCase, msg: string)
---@field createItem fun(self: TestCase, itemTypeId: string): item
---@field createUnit fun(self: TestCase, unitTypeId: string, player?: player, collision?: boolean): unit
---@field applyDummyOrder fun(self: TestCase, owner: player, target: unit, abilityId: integer, order: string, level?: integer)
---@field flush fun(self: TestCase): boolean
---@field addFlushCallback fun(self: TestCase, callback: fun())

---@class TestResult
---@field ok boolean
---@field err? string

---@class TestSuite
---@field name string
---@field names table<string, boolean>
---@field results table<string, TestResult>
---@field order string[]
---@field pending integer
---@field total integer
---@field registerTest fun(self: TestSuite, name: string)
---@field record fun(self: TestSuite, name: string, ok: boolean, err?: string)
---@field flush fun(self: TestSuite)

---@class TestRunner
---@field test fun(self: TestRunner, name: string, testFunc: TestFn)
---@field run fun(self: TestRunner)

---@class ReporterModeEnum
---@field summary ReporterMode
---@field errors ReporterMode
---@field verbose ReporterMode

---@class TestReporter
---@field mode ReporterMode
---@field Mode ReporterModeEnum
---@field immediate fun(testName: string, ok: boolean, err?: string)
---@field flushSuite fun(suite: TestSuite)

---@class CaseModule
---@field new fun(testName: string, testFunc: TestFn, x: number, y: number, reporter: TestReporterFn): TestCase

---@class SuiteModule
---@field new fun(name: string): TestSuite

---@class RunnerModule
---@field suite fun(name: string): TestRunner
---@field runAll fun()
