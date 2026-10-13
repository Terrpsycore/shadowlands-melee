if Debug then Debug.beginFile "WarcraftStudioCode" end
do
---@diagnostic disable: redundant-return-value

    --[[
    =============================================================================================================================================================
                                                                    Warcraft Studio Code
                                                                         by Antares
                                                                            v5.0

                                                        An in-game Lua editor, compiler, and debugger.
                        
                                Requires:
                                DebugUtils (2.5+)               https://www.hiveworkshop.com/threads/.353720/
                                HandleType                      https://www.hiveworkshop.com/threads/.354436/
                                AsyncControlHandler             https://www.hiveworkshop.com/threads/.374260/
                                FileIO				            https://www.hiveworkshop.com/threads/.360424/
                                WSCodeConfig

                                FunctionPreviews (optional)     Included in Test Map.

                                ALICE (optional)                https://www.hiveworkshop.com/threads/.353126/

    =============================================================================================================================================================

    =============================================================================================================================================================
    ]]

    local compiler = WSCodeConfig.compiler
    local diagnostics = WSCodeConfig.diagnostics
    local editor = WSCodeConfig.editor
    local CREATOR_DESTRUCTOR_PAIRS = WSCodeConfig.CREATOR_DESTRUCTOR_PAIRS
    local HandleTextMacros = WSCodeConfig.handleTextMacros
    local tabNavigator = WSCodeConfig.tabNavigator
    local variableViewer = WSCodeConfig.variableViewer
    local searchBar = WSCodeConfig.searchBar
    local nameDialog = WSCodeConfig.nameDialog
    local flagsMenu = WSCodeConfig.flagsMenu
    local EXECUTION_LIMIT = WSCodeConfig.EXECUTION_LIMIT

    if not Debug then
        compiler.RELEASE_VERSION = true
    end

    if compiler.RELEASE_VERSION then
        compiler.WRAP_ALL_LUA_ENTRY_POINTS = false
        compiler.STORE_TRIGGER_TRACEBACK = false
        compiler.STORE_HANDLE_ORIGIN = false
        editor.LOAD_EXTERNAL_SCRIPTS_ON_ERROR = false
        diagnostics.INIT_DUMP = false
        diagnostics.INIT_OUTSIDE_OF_WRAP_WARNING = false
        compiler.ENABLE_QUICK_RESTART = false
        compiler.FINALIZE_MAP_SCRIPT = false
    end

    local tab2D                         = {__index = function(self, key) self[key] = {} return self[key] end}
    local tabWeak                       = {__mode = "kv"}

    local codeEditorParent
    local editBox
    local cursorFrame
    local codeLineFrames                = {}
    local lineNumberFrames              = {}
    local stopButtons                   = {}
    local indexFromFrame                = {}
    local duplicateHighlightFrames      = {}
    local codeScroller
    local codeHorizontalScroller
    local contextMenu = {
        customButtons = {},
        NUM_DEFAULT_BUTTONS             = 8
    }
    local tabMenu = {
        NUM_DEFAULT_BUTTONS             = 5
    }

    local codeLines                     = setmetatable({}, {
        __index = function(parent, parentKey)
            parent[parentKey] = setmetatable({}, {
                __index = function(self, key)
                    self[key] = setmetatable({}, {
                        __index = function(child, childKey)
                            child[childKey] = ""
                            return child[childKey]
                        end
                    })
                    return self[key]
                end
            })
            return parent[parentKey]
        end
    })
    local coloredCodeLines              = setmetatable({}, {
        __index = function(parent, parentKey)
            parent[parentKey] = setmetatable({}, {
                __index = function(self, key)
                    self[key] = {}
                    return self[key]
                end
            })
            return parent[parentKey]
        end
    })

    local cursor = {
        pos = nil,
        screenLineNumber = nil,
        codeLineNumber = nil,
        x = 0,
        isShowingVariableTooltip        = false,
        checkedForVariableDisplay       = false
    }

    variableViewer.frames               = {}
    variableViewer.valueFrames          = {}
    variableViewer.textFrames           = {}
    variableViewer.nameFromFrame        = {}
    variableViewer.viewedGlobals        = {}
    variableViewer.viewedValueTrace     = {}
    variableViewer.viewedVariableTrace  = {}
    variableViewer.lineNumberOffset     = setmetatable({}, {__index = function(self, key) self[key] = 0 return 0 end})
    variableViewer.isViewingGlobal      = false
    variableViewer.isViewingParams      = false
    variableViewer.isExpanded           = true
    variableViewer.hasNotBeenExpanded   = true
    variableViewer.numVisibleVarsTotal  = 0
    variableViewer.numVisibleVarsScreen = 0
    variableViewer.effects              = {}
    variableViewer.scrollerIsVisible    = false
    variableViewer.varNames             = {}
    variableViewer.varValues            = {}

    editor.frameIntrinsicAlpha          = {}
    editor.frameCurrentAlpha            = {}
    editor.fadeState                    = 1
    editor.fadeOutBlocked               = false

    local helper                        = {
        autoCompleteFrames = {},
        autoCompleteTextFrames = {},
        numSuggestionsVisible = 0,
        suggestions = {},
    }
    local widthTestFrame

    local buttons = {
        customArrayButtons = {},
        customButtons = {},
        subArrayButtons = {},
        defaultButtonPosition = {},
        maxButtons = 0,
        triggers = {}
    }

    local currentStop                   = setmetatable({}, {__index = function(self, key) self[key] = 0 return 0 end})
    local cursorCounter                 = 0
    local numFunctions                  = 0
    local doNotUpdateVariables          = {}
    local editBoxFocused                = false
    local globalLookupTable             = {}
    local localLookupTable              = {}
    local concatTable                   = setmetatable({}, {__concat = function(self, str) self[#self + 1] = str return self end})
    local editBoxText                  = " "
    local clipboard
    local canJumpToError                = true
    local user
    local lastHaltedCoroutine
    local initialized
    local coroutineWaitingForInit
    local executionCount                = 0
    local lineNumberWasExecuted         = setmetatable({}, tab2D)
    local clearMenu                     = {}
    local doNotCheckStop                = setmetatable({}, {
        __index = function(grandParent, grandParentKey)
            grandParent[grandParentKey] = setmetatable({}, {
                __index = function(parent, parentKey)
                    parent[parentKey] = {}
                    return parent[parentKey]
                end
            })
            return grandParent[grandParentKey]
        end
    })
    local breakCondition                = {}
    local breakEverywhere               = {}
    local breakOnlyHere

    local lineNumbers = {
        lastViewed = {},
        error = setmetatable({}, {__index = function(self, key) self[key] = 0 return 0 end}),
    }
    local lastLineNumber                = setmetatable({}, {__index = function(self, key) self[key] = 0 return 0 end})

    local lineByLine                    = false
    local highestNonEmptyLine           = setmetatable({}, {
        __index = function(self, key)
            self[key] = setmetatable({}, {
                __index = function()
                    return 0
                end
            })
            return self[key]
        end
    })

    local hooks = {
        original                        = {},
        hooked                          = {},
        triggerIsHooked                 = {},
        triggerName                     = {}
    }

    local lines = {
        endsInLongString                = setmetatable({}, tab2D),
        endsInLongComment               = setmetatable({}, tab2D),
        numEqualSigns                   = {},
        debugState                      = setmetatable({}, {__index = function(self, key) self[key] = setmetatable({}, {__index = function(child, childKey) child[childKey] = 0 return 0 end}) return self[key] end}),
        lastEdited                      = 0,
        injectedEvalStr                 = setmetatable({}, tab2D),
        injectedEvalFuncs               = setmetatable({}, tab2D)
    }

    local flags                         = {
        "debugMode",
        "runInit",
        "cleanHandles",
        "hideGlobals",
        "hideConstants",
        "hideFunctions",
        "smartPersist",
        "unfreezeViewer",
        "quickRestart",
    }
    local handles                       = setmetatable({}, {__index = function(self, key) self[key] = setmetatable({}, {__mode = "k"}) return self[key] end})
    local handleOrigin = {
        list = setmetatable({}, {__index = function(self, key) self[key] = {} return self[key] end}),
        tab = setmetatable({}, {__mode = "k"}),
        line = setmetatable({}, {__mode = "k"}),
        index = setmetatable({}, {__mode = "k"}),
        args = setmetatable({}, {__mode = "k"}),
    }

    local triggers = {
        tracebackFromKey = {},
        onUndoStepCreated = {}
    }
    local coroutineGenerationCounter    = {}

    local files                         = {}
    local fileNames                     = {}
    local existingFiles                 = {}
    local orderedFileNames              = {}

    local currentTab                    = "Main"
    local timeElapsed                   = 0
    local firstDifferentChar            = 0

    local step                          = setmetatable({}, {__index = function(self, key) self[key] = 1 return 1 end})
    local edit                          = {
        maxRedo                         = setmetatable({}, {__index = function(self, key) self[key] = 0 return 0 end}),
        lineNumber                      = setmetatable({}, tab2D),
        pos                             = setmetatable({}, tab2D),
        lastKeyStroke                   = 0
    }

    local wrapperFunc                   = setmetatable({}, tab2D)
    local wrappedFunc                   = setmetatable({}, tab2D)
    local wrapperGenerationCounter      = setmetatable({}, {__index = function(self, key) self[key] = setmetatable({}, {__index = function(child, childKey) child[childKey] = 0 return 0 end}) return self[key] end})

    local dragWindow                    = {
        WIDTH = 0.105,
        TOP_INSET = 0.01
    }

    local tabs = {
        amount                          = 1,
        names                           = {"Main"},
        numbers                         = {Main = 1},
        numberFromFrame                 = {},
        hasError                        = {},
        hasUnsavedChanges               = {},
        wasNotCompiledInDebugMode       = {},
        truncatedNames                  = {},
        wasPulledFromDebugToken         = {},
        lineNumberOffset                = setmetatable({}, {__index = function(self, key) self[key] = 0 return 0 end}),
        horizontalOffset                = setmetatable({}, {__index = function(self, key) self[key] = 0 return 0 end}),
        longestLineLength               = {},
        longestLineIndex                = {},
        breakNowhere                    = {}
    }
    local executionTab                  = "Main"
    local tabIsHalted                   = {}
    local currentCoroutine              = {}

    local plugins = {
        registered                      = {},
        activeIndex                     = 1,
        onEnable                        = {},
        onDisable                       = {},
        names                           = {"Warcraft Studio Code"},
        tooltips                        = {"Switch to the default Warcraft Studio Code tab."},
        titleSuffixes                   = {},
        visibleButtons                  = {},
        callbacks                       = {}
    }

    local noStop                        = false

    editor.CHARS_ON_SCREEN_COLLAPSED    = math.floor((editor.COLLAPSED_WIDTH - editor.CODE_LEFT_INSET - editor.CODE_SCROLLER_HORIZONTAL_INSET - 0.006)/0.003875)
    editor.CHARS_ON_SCREEN_EXPANDED     = math.floor((editor.EXPANDED_WIDTH - editor.CODE_LEFT_INSET - editor.CODE_SCROLLER_HORIZONTAL_INSET - 0.006)/0.003875)
    editor.textChangeMonitorFrozen      = false

    tabNavigator.frames                 = {}
    tabNavigator.titles                 = {}
    tabNavigator.highlights             = {}
    tabNavigator.closeButtons           = {}
    tabNavigator.widths                 = {tabNavigator.WIDTH}

    local varTable                      = setmetatable({}, tab2D)
    local visibleVarsOfLine             = setmetatable({}, {__index = function(self, key) self[key] = setmetatable({}, tab2D) return self[key] end})
    local varLevelExecution             = setmetatable({}, tab2D)

    local init = {
        main = {},
        global = {},
        trig = {},
        map = {},
        essential = {},
        final = {},
        load = {},
        names = {},
        passes = {},
        highestPass = {
            main = 1,
            global = 1,
            trig = 1,
            map = 1,
            final = 1,
            load = 1
        },
        completed = {},
        originalCreators = {},
        profiler = {totalTime = 0}
    }

    local highlights = {
        text                            = {},
        typeFromFrame                   = {},
        custom                          = {}
    }

    local selection                     = {
        lines = {}
    }

    searchBar.text                      = ""
    searchBar.numFinds                  = 0
    searchBar.highlights                = {}
    searchBar.lines                     = {}
    searchBar.startPos                  = {}
    searchBar.endPos                    = {}
    searchBar.current                   = 0

    local sub                           = string.sub
    local find                          = string.find
    local match                         = string.match
    local clock                         = os.clock
    local running                       = coroutine.running
    local isyieldable                   = coroutine.isyieldable
    local min                           = math.min
    local max                           = math.max

    local benchmark = {
        results                         = {}
    }

    local brackets = {
        highlights = {},
        lines = {},
        pos = {},
        IS_BRACKET = {
            ["("] = true,
            [")"] = true,
            ["["] = true,
            ["]"] = true,
            ["{"] = true,
            ["}"] = true
        },
        CORRESPONDING_BRACKET = {
            ["("] = ")",
            [")"] = "(",
            ["["] = "]",
            ["]"] = "[",
            ["{"] = "}",
            ["}"] = "{"
        }
    }

    local EnableEditor
    local UpdateVariableViewer
    local ToggleExpand
    local ToggleVariableViewerExpand
    local SetSelection
    local HideSelection
    local StoreCode
    local RenderSearchHighlights
    local FindSearchItems
    local JumpToError
    local Value2String
    local SaveSettings
    local SaveTabs
    local CreateControlTriggers
    local MainLoop
    local RenderLine
    local GetVariableViewerOffsetKey
    local ChangeCodeLine
    local wsdebug

    --Saving the game crashes the game with WSCode installed.
    SaveGameCheckpoint = DoNothing

    local LINE_STATE_ICONS = {
        [0] = editor.ASSET_SUBFOLDER .. "\\transparentmask.blp",
        [1] = editor.ASSET_SUBFOLDER .. "\\injecteval.blp",
        [2] = editor.ASSET_SUBFOLDER .. "\\stopButton.blp",
    }

    local LUA = {
        CONTROL_FLOW_STATEMENTS = {
            ["if"] = true,
            ["then"] = true,
            ["else"] = true,
            ["elseif"] = true,
            ["end"] = true,
            ["for"] = true,
            ["while"] = true,
            ["repeat"] = true,
            ["until"] = true,
            ["return"] = true,
            ["do"] = true,
            ["break"] = true
        },
        KEYWORDS = {
            ["if"] = true,
            ["then"] = true,
            ["else"] = true,
            ["elseif"] = true,
            ["end"] = true,
            ["for"] = true,
            ["while"] = true,
            ["repeat"] = true,
            ["until"] = true,
            ["return"] = true,
            ["do"] = true,
            ["break"] = true,
            ["or"] = true,
            ["and"] = true,
            ["not"] = true,
            ["function"] = true,
            ["in"] = true,
            ["local"] = true
        },
        OPERATORS = {
            ["+"] = true,
            ["-"] = true,
            ["*"] = true,
            ["/"] = true,
            ["//"] = true,
            ["%"] = true,
            ["{"] = true,
            ["}"] = true,
            ["["] = true,
            ["]"] = true,
            ["("] = true,
            [")"] = true,
            [","] = true,
            ["^"] = true,
            ["~="] = true,
            ["<"] = true,
            [">"] = true,
            ["<="] = true,
            [">="] = true,
            ["="] = true,
            ["=="] = true,
            [".."] = true,
            ["and"] = true,
            ["or"] = true,
            ["not"] = true,
            ["&"] = true,
            ["|"] = true,
            ["~"] = true,
            ["<<"] = true,
            [">>"] = true
        },
        BINARY_OPERATORS = {
            ["+"] = true,
            ["-"] = true,
            ["*"] = true,
            ["/"] = true,
            ["//"] = true,
            ["%"] = true,
            [","] = true,
            ["^"] = true,
            ["<"] = true,
            [">"] = true,
            ["~="] = true,
            ["=="] = true,
            ["<="] = true,
            [">="] = true,
            ["="] = true,
            [".."] = true,
            ["and"] = true,
            ["or"] = true,
            ["not"] = true,
            ["["] = true,
            ["&"] = true,
            ["|"] = true,
            ["~"] = true,
            ["<<"] = true,
            [">>"] = true
        },
        ONE_CHAR_OPERATORS = {
            ["+"] = true,
            ["-"] = true,
            ["*"] = true,
            ["/"] = true,
            ["%"] = true,
            ["{"] = true,
            ["}"] = true,
            ["["] = true,
            ["]"] = true,
            ["("] = true,
            [")"] = true,
            [","] = true,
            ["^"] = true,
            ["<"] = true,
            [">"] = true,
            ["="] = true,
            ["&"] = true,
            ["|"] = true,
            ["~"] = true,
        },
        TWO_CHAR_OPERATORS = {
            ["~="] = true,
            ["<="] = true,
            [">="] = true,
            ["=="] = true,
            [".."] = true,
            ["::"] = true,
            ["//"] = true,
            ["<<"] = true,
            [">>"] = true
        }
    }

    local END_OF_STATEMENT_IGNORED_CHARS = {
        ["."] = true,
        [":"] = true,
        ["'"] = true,
        ['"'] = true
    }

    local INIT_POINTS = {
        root = 1,
        config = 2,
        main = 3,
        global = 4,
        trig = 5,
        map = 6,
        final = 7
    }

    if Debug then
        ---@diagnostic disable-next-line: duplicate-set-field
        Debug.traceback = function(startDepth, endDepth)
            startDepth = (startDepth or 0) + 2 --The 0-level shall be the level where Debug.traceback is called by the user, so we must add 2 to get out of the pcall/error level below.
            endDepth = (endDepth or 200) + 2 --Same +2 logic. 200 is a level recommended to fetch the whole stack trace, including the final piece of stack overflow errors.
            local trace, separator = "", ""
            local _, currentFile, lastFile, tracePiece, lastTracePiece, piece
            for loopDepth = startDepth, endDepth do --get trace on different depth level
                _, tracePiece = pcall(error, "", loopDepth) ---@type boolean, string
                tracePiece = Debug.getLocalErrorMsg(tracePiece)
                tracePiece = tracePiece:gsub('%[string "(.-)"%]', "%1"):gsub("WSCode ", "")
                if #tracePiece > 0 and lastTracePiece ~= tracePiece then --some trace pieces can be empty, but there can still be valid ones beyond that
                    if find(tracePiece, "%.%.%.:") ~= nil then
                        local tracePieceTruncated = sub(tracePiece, 1, find(tracePiece, "%.%.%.:") - 1)
                        for i = 1, #fileNames do
                            if find(fileNames[i], tracePieceTruncated) ~= nil then
                                tracePiece = fileNames[i] .. sub(tracePiece, select(2, find(tracePiece, "%.%.%.:")))
                                break
                            end
                        end
                    end

                    currentFile = tracePiece:match("^.-:")

                    --Hide DebugUtils in the stack trace (except main reference), if settings.INCLUDE_DEBUGUTILS_INTO_TRACE is set to true.
                    if Debug.settings.INCLUDE_DEBUGUTILS_INTO_TRACE or (loopDepth == startDepth) or currentFile ~= "WarcraftStudioCode:" then
                        piece = (currentFile == lastFile) and tracePiece:match(":%d+"):sub(2,-1) or tracePiece:match("^.-:%d+")
                        trace = trace .. separator .. piece
                        lastFile, lastTracePiece, separator = currentFile, tracePiece, " <- "
                    end
                end
            end

            if ALICE_Traceback then
                trace = trace .. "\nALICE traceback:\n" .. ALICE_Traceback
            elseif ALICE and ALICE.Traceback then
                trace = trace .. "\nALICE traceback:\n" .. ALICE.Traceback
            end

            local corot = running()
            local key = tostring(corot) .. (coroutineGenerationCounter[corot] or "")
            local triggerTrace = triggers.tracebackFromKey[key]

            if triggerTrace then
                trace = trace .. "\nTrigger traceback:\n" .. triggerTrace
            end

            return trace
        end

        ---@diagnostic disable-next-line: duplicate-set-field
        Debug.errorHandler = function(errorMsg, startDepth, returnErrorMsg_yn)
            if find(errorMsg, "%.%.%.\"%]") ~= nil then
                local fileNameTruncated = sub(errorMsg, 1, find(errorMsg, "%.%.%.\"%]") - 1)
                local replacements
                fileNameTruncated, replacements = fileNameTruncated:gsub('%[string "WSCode ', "")
                for i = 1, #fileNames do
                    if find(fileNames[i], fileNameTruncated:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")) ~= nil then
                        if replacements ~= 0 then
                            errorMsg = '[string "WSCode ' .. fileNames[i] .. sub(errorMsg, select(2, find(errorMsg, "%.%.%.\"%]")) - 1)
                        else
                            errorMsg = fileNames[i] .. sub(errorMsg, select(2, find(errorMsg, "%.%.%.\"%]") - 1))
                        end
                        break
                    end
                end
            end

            local fileName = errorMsg:match('"(.-)"%]')

            if errorMsg:sub(1, 15) == '[string "WSCode' then
                fileName = fileName:gsub("WSCode ", "")
            end
            local lineNumber = tonumber(errorMsg:match("%]:(%d+):"))

            startDepth = (startDepth or 0)
            errorMsg = Debug.getLocalErrorMsg(errorMsg)

            --Original error message and stack trace.
            local toPrint = "|cff" .. Debug.settings.colors.error .. "ERROR at " .. errorMsg .. "|r"
            if Debug.settings.SHOW_TRACE_ON_ERROR then
                toPrint = toPrint .. "\n|cff" .. Debug.settings.colors.error .. "Traceback (most recent call first):|r\n|cff" .. Debug.settings.colors.error .. Debug.traceback(startDepth,202) .. "|r"
            end
            --Also print entries from param log, if there are any.
            for location, loggedParams in next, Debug.data.paramLog do
                toPrint = toPrint .. "\n|cff" .. Debug.settings.colors.log .. "Logged at " .. Debug.getLocalErrorMsg(location) .. loggedParams .. "|r"
                Debug.data.paramLog[location] = nil
            end
            toPrint = toPrint:gsub('%[string "(.-)"%]', "%1"):gsub("WSCode ", "")

            Debug.data.firstError = Debug.data.firstError or toPrint
            if Debug.data.printErrors_yn then --don't print error, if execution of Debug.firstError() has disabled it.
                print(toPrint)
            end

            errorMsg = toPrint
            if fileName and lineNumber then
                if initialized then
                    JumpToError(fileName, lineNumber)
                    noStop = true
                    editor.ON_ERROR(fileName)
                    noStop = false
                else
                    init.error = init.error or {
                        fileName = fileName,
                        lineNumber = lineNumber,
                    }
                end
            end

            return returnErrorMsg_yn and errorMsg
        end
    end

    if Debug and compiler.WRAP_ALL_LUA_ENTRY_POINTS then
        local eventResponseOfCoroutine = setmetatable({}, tab2D)

        local tryWrappers = setmetatable({}, {__mode = 'k'})
        local getTryWrapper
        getTryWrapper = function(func)
            if func then
                tryWrappers[func] = tryWrappers[func] or function(...) return select(2, xpcall(func, Debug.errorHandler,...)) end
            end
            return tryWrappers[func]
        end

        local originalCoroutineCreate = Debug.original.coroutine.create or coroutine.create
        local originalCoroutineWrap = Debug.original.coroutine.wrap or coroutine.wrap

        ---@diagnostic disable-next-line: duplicate-set-field
        coroutine.create = function(whichFunc)
            return originalCoroutineCreate(getTryWrapper(whichFunc))
        end

        ---@diagnostic disable-next-line: duplicate-set-field
        coroutine.wrap = function(whichFunc)
            return originalCoroutineWrap(getTryWrapper(whichFunc))
        end

        --Thread recycler
        local deadCorots = setmetatable({}, tab2D)
        local pack = table.pack
        local unpack = table.unpack

        local function getCoroutine(whichFunc)
            local corot
            if #deadCorots[whichFunc] == 0 then
                local wrapper = function(...)
                    local args = pack(...)
                    ::beginning::
                    local returnValue = whichFunc(unpack(args, 1, args.n))
                    deadCorots[whichFunc][#deadCorots[whichFunc] + 1] = corot
                    if corot == lastHaltedCoroutine then
                        lastHaltedCoroutine = nil
                    end
                    for key, __ in next, eventResponseOfCoroutine[corot] do
                        eventResponseOfCoroutine[corot][key] = nil
                    end
                    args = pack(coroutine.yield(returnValue))
                    goto beginning
                end
                corot = originalCoroutineCreate(wrapper)
                coroutineGenerationCounter[corot] = 1
            else
                corot = deadCorots[whichFunc][#deadCorots[whichFunc]]
                deadCorots[whichFunc][#deadCorots[whichFunc]] = nil
                coroutineGenerationCounter[corot] = coroutineGenerationCounter[corot] + 1
            end
            return corot
        end

        local originals = {
            triggerAddAction = Debug.original.TriggerAddAction or TriggerAddAction,
            condition = Debug.original.Condition or Condition,
            filter = Debug.original.Filter or Filter,
            forGroup = Debug.original.ForGroup or ForGroup,
            forForce = Debug.original.ForForce or ForForce,
            enumDestructables = Debug.original.EnumDestructablesInRect or EnumDestructablesInRect,
            enumItems = Debug.original.EnumItemsInRect or EnumItemsInRect,
            timerStart = Debug.original.TimerStart or TimerStart
        }

        if compiler.DO_NOT_BREAK_GUI_WAITS then
            local oldSleep = TriggerSleepAction
            TriggerSleepAction = function(duration)
                local corot = coroutine.running()
                if coroutine.isyieldable(corot) then
                    local timer = CreateTimer()
                    TimerStart(timer, duration, false, function()
                        DestroyTimer(timer)
                        coroutine.resume(corot)
                    end)
                    coroutine.yield()
                else
                    oldSleep(duration)
                end
            end

            local soundFinishedAt = {}

            local oldStartSound = StartSound
            StartSound = function(soundHandle)
                if soundHandle then
                    oldStartSound(soundHandle)
                    soundFinishedAt[soundHandle] = timeElapsed + GetSoundDuration(soundHandle)/1000
                end
            end

            local oldStopSound = StopSound
            StopSound = function(soundHandle, killWhenDone, fadeOut)
                oldStopSound(soundHandle, killWhenDone, fadeOut)
                if soundHandle then
                    soundFinishedAt[soundHandle] = timeElapsed
                end
            end

            local oldWaitForSound = TriggerWaitForSound
            TriggerWaitForSound = function(whichSound, offset)
                local corot = coroutine.running()
                if coroutine.isyieldable(corot) then
                    if soundFinishedAt[whichSound] and soundFinishedAt[whichSound] > timeElapsed + offset then
                        local timer = CreateTimer()
                        TimerStart(timer, soundFinishedAt[whichSound] - (timeElapsed + offset), false, function()
                            DestroyTimer(timer)
                            coroutine.resume(corot)
                        end)
                        coroutine.yield()
                    end
                else
                    oldWaitForSound(whichSound, offset)
                end
            end

            local eventResponses = {
                GetTriggeringTrigger = true,
                GetTriggerUnit = true,
                GetTriggerPlayer = true,
                GetTriggerDestructable = true,
                GetLevelingUnit = true,
                GetLearningUnit = true,
                GetLearnedSkill = true,
                GetLearnedSkillLevel = true,
                GetRevivableUnit = true,
                GetRevivingUnit = true,
                GetAttacker = true,
                GetRescuer = true,
                GetDyingUnit = true,
                GetKillingUnit = true,
                GetDecayingUnit = true,
                GetConstructingStructure = true,
                GetCancelledStructure = true,
                GetConstructedStructure = true,
                GetResearchingUnit = true,
                GetResearched = true,
                GetTrainedUnitType = true,
                GetTrainedUnit = true,
                GetDetectedUnit = true,
                GetSummoningUnit = true,
                GetSummonedUnit = true,
                GetTransportUnit = true,
                GetLoadedUnit = true,
                GetSellingUnit = true,
                GetSoldUnit = true,
                GetBuyingUnit = true,
                GetSoldItem = true,
                GetChangingUnit = true,
                GetChangingUnitPrevOwner = true,
                GetManipulatingUnit = true,
                GetManipulatedItem = true,
                BlzGetAbsorbingItem = true,
                BlzGetManipulatedItemWasAbsorbed = true,
                BlzGetStackingItemSource = true,
                BlzGetStackingItemTarget = true,
                BlzGetStackingItemTargetPreviousCharges = true,
                GetOrderedUnit = true,
                GetIssuedOrderId = true,
                GetOrderPointX = true,
                GetOrderPointY = true,
                GetOrderPointLoc = true,
                GetOrderTarget = true,
                GetOrderTargetDestructable = true,
                GetOrderTargetItem = true,
                GetOrderTargetUnit = true,
                GetSpellAbilityUnit = true,
                GetSpellAbilityId = true,
                GetSpellAbility = true,
                GetSpellTargetLoc = true,
                GetSpellTargetX = true,
                GetSpellTargetY = true,
                GetSpellTargetDestructable = true,
                GetSpellTargetItem = true,
                GetSpellTargetUnit = true,
                GetEventPlayerState = true,
                GetEventPlayerChatString = true,
                GetEventPlayerChatStringMatched = true,
                GetTriggeringRegion = true,
                GetEnteringUnit = true,
                GetLeavingUnit = true,
                GetTriggeringTrackable = true,
                GetClickedButton = true,
                GetClickedDialog = true,
                GetTournamentFinishSoonTimeRemaining = true,
                GetTournamentFinishNowRule = true,
                GetTournamentFinishNowPlayer = true,
                GetTournamentScore = true,
                GetSaveBasicFilename = true,
                GetEventUnitState = true,
                GetEventDamage = true,
                GetEventDamageSource = true,
                GetEventDetectingPlayer = true,
                GetEventTargetUnit = true,
            }

            for key, __ in next, eventResponses do
                originals[key] = _ENV[key]
                _ENV[key] = function()
                    return originals[key]() or eventResponseOfCoroutine[running()][key]
                end
            end

            TriggerAddAction = function(whichTrigger, actionFunc)
                return originals.triggerAddAction(whichTrigger, function()
                    local corot = getCoroutine(getTryWrapper(actionFunc))
                    for key, __ in next, eventResponses do
                        eventResponseOfCoroutine[corot][key] = originals[key]()
                    end
                    coroutine.resume(corot)
                end)
            end
        else
            TriggerAddAction = function(whichTrigger, actionFunc)
                return originals.triggerAddAction(whichTrigger, function()
                    coroutine.resume(getCoroutine(getTryWrapper(actionFunc)))
                end)
            end
        end

        Condition = function(whichFunction)
            if whichFunction then
                return originals.condition(function()
                    return select(2, coroutine.resume(getCoroutine(getTryWrapper(whichFunction))))
                end)
            else
                return originals.condition(whichFunction)
            end
        end

        Filter = function(whichFunction)
            if whichFunction then
                return originals.filter(function()
                    return select(2, coroutine.resume(getCoroutine(getTryWrapper(whichFunction))))
                end)
            else
                return originals.filter(whichFunction)
            end
        end

        ForGroup = function(whichGroup, actionFunc)
            if actionFunc then
                return originals.forGroup(whichGroup, function()
                    return coroutine.resume(getCoroutine(getTryWrapper(actionFunc)))
                end)
            else
                return originals.forGroup(whichGroup, actionFunc)
            end
        end

        ForForce = function(whichForce, actionFunc)
            if actionFunc then
                return originals.forForce(whichForce, function()
                    return coroutine.resume(getCoroutine(getTryWrapper(actionFunc)))
                end)
            else
                return originals.forForce(whichForce, actionFunc)
            end
        end

        EnumDestructablesInRect = function(r, filter, actionFunc)
            if actionFunc then
                return originals.enumDestructables(r, filter, function()
                    return coroutine.resume(getCoroutine(getTryWrapper(actionFunc)))
                end)
            else
                return originals.enumDestructables(r, filter, actionFunc)
            end
        end

        EnumItemsInRect = function(r, filter, actionFunc)
            if actionFunc then
                return originals.enumItems(r, filter, function()
                    return coroutine.resume(getCoroutine(getTryWrapper(actionFunc)))
                end)
            else
                return originals.enumItems(r, filter, actionFunc)
            end
        end

        local funcOfTimer = {}
        local function timerStartWrapper()
            local whichTimer = GetExpiredTimer()
            if funcOfTimer[whichTimer] then
                return coroutine.resume(getCoroutine(getTryWrapper(funcOfTimer[whichTimer])))
            end
        end

        TimerStart = function(whichTimer, timeout, periodic, actionFunc)
            if not whichTimer then
                return
            end
            funcOfTimer[whichTimer] = actionFunc
            return originals.timerStart(whichTimer, timeout, periodic, timerStartWrapper)
        end
    end

    --Must be above WRAP_ALL_LUA_ENTRY_POINTS
    if compiler.STORE_TRIGGER_TRACEBACK then
        local lastTraceback

        local function getTriggerWrapper(whichTrigger, callback)
            return function()
                if lastTraceback then
                    local corot = running()
                    local key = tostring(corot) .. (coroutineGenerationCounter[corot] or "")
                    triggers.tracebackFromKey[key] = lastTraceback
                    lastTraceback = nil
                    if hooks.triggerIsHooked[whichTrigger] then
                        if ALICE_TimeElapsed then
                            WSDebug.PrintForUser("\n|cffffcc00Trigger:|r " .. hooks.triggerName[whichTrigger] .. " |cffaaaaaa(" .. string.format("%.2f", ALICE_TimeElapsed) .. ")|r\n|cffffcc00Traceback:|r " .. lastTraceback .. "\n------------------------------------------")
                        elseif ALICE and ALICE.TimeElapsed then
                            WSDebug.PrintForUser("\n|cffffcc00Trigger:|r " .. hooks.triggerName[whichTrigger] .. " |cffaaaaaa(" .. string.format("%.2f", ALICE.TimeElapsed) .. ")|r\n|cffffcc00Traceback:|r " .. lastTraceback .. "\n------------------------------------------")
                        else
                            WSDebug.PrintForUser("\n|cffffcc00Trigger:|r " .. hooks.triggerName[whichTrigger] .. "\n|cffffcc00Traceback:|r " .. lastTraceback .. "\n------------------------------------------")
                        end
                    end
                elseif hooks.triggerIsHooked[whichTrigger] then
                    if ALICE_TimeElapsed then
                        WSDebug.PrintForUser("\n|cffffcc00Trigger:|r " .. hooks.triggerName[whichTrigger] .. " |cffaaaaaa(" .. string.format("%.2f", ALICE_TimeElapsed) .. ")|r\n------------------------------------------")
                    elseif ALICE and ALICE.TimeElapsed then
                        WSDebug.PrintForUser("\n|cffffcc00Trigger:|r " .. hooks.triggerName[whichTrigger] .. " |cffaaaaaa(" .. string.format("%.2f", ALICE.TimeElapsed) .. ")|r\n------------------------------------------")
                    else
                        WSDebug.PrintForUser("\n|cffffcc00Trigger:|r " .. hooks.triggerName[whichTrigger] .. "\n------------------------------------------")
                    end
                end
                callback()
            end
        end

        local oldTriggerAddAction = TriggerAddAction
        TriggerAddAction = function(whichTrigger, callback)
            oldTriggerAddAction(whichTrigger, getTriggerWrapper(whichTrigger, callback))
        end

        local callbackFromCondition = {}

        local oldCondition = Condition
        Condition = function(callback)
            local cond = oldCondition(callback)
            callbackFromCondition[cond] = callback
            return cond
        end
        local oldFilter = Filter
        Filter = function(callback)
            callbackFromCondition[oldFilter(callback)] = callback
        end

        local oldTriggerAddCondition = TriggerAddCondition
        TriggerAddCondition = function(whichTrigger, whichCondition)
            oldTriggerAddCondition(whichTrigger, oldCondition(getTriggerWrapper(whichTrigger, callbackFromCondition[whichCondition])))
        end

        local oldTriggerExecute = TriggerExecute
        TriggerExecute = function(whichTrigger)
            lastTraceback = Debug.traceback()
            oldTriggerExecute(whichTrigger)
        end

        local oldTriggerEvaluate = TriggerEvaluate
        TriggerEvaluate = function(whichTrigger)
            lastTraceback = Debug.traceback()
            oldTriggerEvaluate(whichTrigger)
        end
    end

    if WSCodeConfig.compiler.OVERWRITE_TOTAL_INITIALIZATION then
        OnInit = OnInit or {}
        local inits = {
            "main",
            "global",
            "trig",
            "map",
            "final"
        }
        for i = 1, #inits do
            local wscodeInit = "Init" .. inits[i]:sub(1, 1):upper() .. inits[i]:sub(2)
            OnInit[inits[i]] = function(funcOrFuncName, func)
                if type(funcOrFuncName) == "function" then
                    WSCode[wscodeInit](funcOrFuncName)
                else
                    WSCode[wscodeInit](func)
                end
            end
        end
        Require = function(libraryName)
            error("Require function is not supported by WSCode initializers. Replace with ---@require parser commands.")
        end
    end

    if WSCodeConfig.compiler.STORE_HANDLE_ORIGIN then
        local pack = table.pack

        for creator, destructor in next, CREATOR_DESTRUCTOR_PAIRS do
            _ENV[creator .. "WSOriginWrapper"] = function(whichTab, whichLine, whichFunc, ...)
                if _ENV[creator] ~= whichFunc then
                    return whichFunc(...)
                end
                local success, errOrHandle = pcall(_ENV[creator], ...)
                if not success then
                    error(errOrHandle, 2)
                end
                if not errOrHandle then
                    return
                end
                local list = handleOrigin.list[whichTab .. "WSLINE" .. whichLine]
                list[#list + 1] = errOrHandle
                handleOrigin.tab[errOrHandle] = whichTab
                handleOrigin.line[errOrHandle] = whichLine
                handleOrigin.index[errOrHandle] = #list
                handleOrigin.args[errOrHandle] = pack(...)
                return errOrHandle
            end

            if destructor then
                local originalDestructor = _ENV[destructor]
                if originalDestructor then
                    _ENV[destructor] = function(...)
                        local handle = select(1, ...)
                        if not handleOrigin.tab[handle] then
                            local success, errOrReturn = pcall(originalDestructor, ...)
                            if not success then
                                error(errOrReturn, 2)
                            end
                            return errOrReturn
                        end
                        local list = handleOrigin.list[handleOrigin.tab[handle] .. "WSLINE" .. handleOrigin.line[handle]]
                        list[handleOrigin.index[handle]] = list[#list]
                        handleOrigin.index[list[handleOrigin.index[handle]]] = handleOrigin.index[handle]
                        list[#list] = nil
                        handleOrigin.tab[handle] = nil
                        handleOrigin.line[handle] = nil
                        handleOrigin.index[handle] = nil
                        handleOrigin.args[handle] = nil
                        local success, errOrReturn =  pcall(originalDestructor, ...)
                        if not success then
                            error(errOrReturn, 2)
                        end
                        return errOrReturn
                    end
                end
            end
        end

        local old = MarkGameStarted
        MarkGameStarted = function()
            old()
            local trig = CreateTrigger()
            for i = 0, 23 do
                if user then
                    break
                end
                local player = Player(i)
                for __, creator in ipairs(editor.MAP_CREATORS) do
                    if find(GetPlayerName(player), creator) and GetPlayerController(player) == MAP_CONTROL_USER and GetPlayerSlotState(player) == PLAYER_SLOT_STATE_PLAYING then
                        user = Player(i)
                        break
                    end
                end
            end
            TriggerRegisterPlayerChatEvent(trig, user, "-leakreport", false)
            TriggerAddAction(trig, function()
                local entered = GetEventPlayerChatString()
                local suffix = entered:sub(13)
                local beginning, stop
                if suffix == "" then
                    beginning = 1
                    stop = 10
                elseif math.tointeger(suffix) then
                    beginning = 1
                    stop = math.tointeger(suffix)
                else
                    beginning = math.tointeger(suffix:match("(%d+)-"))
                    stop = math.tointeger(suffix:match("-(%d+)"))
                    if not beginning or not stop then
                        error("Invalid list positions specified.")
                    end
                end
                local orderedList = {}
                for listName, __ in next, handleOrigin.list do
                    orderedList[#orderedList + 1] = listName
                end
                table.sort(orderedList, function(a, b)
                    return #handleOrigin.list[a] > #handleOrigin.list[b]
                end)
                for i = 1, #concatTable do
                    concatTable[i] = nil
                end
                concatTable[1] = ("Breakdown of the lines with the most created handles |cffaaaaaa(" .. beginning .. " to " .. stop .. ")|r:")
                for i = beginning, stop do
                    concatTable = concatTable .. "\n|cffffcc00" .. orderedList[i]:match("^(.*)WSLINE") .. "|r |cffaaaaaa(line " .. orderedList[i]:match("WSLINE(.*)$") .. "):|r " .. #handleOrigin.list[orderedList[i]]
                end
                print(table.concat(concatTable))
            end)
        end
    end

    local function FinalizeScript(code)

        local function IsDevelopmentScript(thisFile)
            if not find(thisFile, "---@development") then
                return false
            end

            if not find(thisFile, "---@development:") then
                return true
            end

            local condition = match(thisFile, "---@development:%s*([^\n]*)")
            if not condition or match(condition, "^%s*$") then
                local scriptName = match(thisFile, "---@beginFile%s*([^\n]*)")
                error("Invalid development condition in script " .. (scriptName or "unknown") .. ".")
            end

            local func, loadError = load("return " .. condition)
            if not func then
                local scriptName = match(thisFile, "---@beginFile%s*([^\n]*)")
                error("Invalid development condition in script " .. (scriptName or "unknown") .. ". " .. loadError)
            end

            local success, returnValue = pcall(func)
            if not success then
                local scriptName = match(thisFile, "---@beginFile%s*([^\n]*)")
                error("Invalid development condition in script " .. (scriptName or "unknown") .. ". " .. returnValue)
            end

            return not not returnValue
        end

        if not WSCodeConfig.finalizer.DEVELOPMENT_BUILD then
            local pos = 1
            local searchStart = 1
            local beginFilePos
            local codeTable = {WSCodeConfig.MAP_SCRIPT_PREFIX}
            local thisFile
            repeat
                beginFilePos = find(code, "---@beginFile", searchStart)
                if beginFilePos then
                    thisFile = sub(code, pos, beginFilePos - 1)
                    if not IsDevelopmentScript(thisFile) then
                        codeTable[#codeTable + 1] = thisFile
                    end
                    pos = beginFilePos
                    searchStart = find(code, "\n", pos)
                    if searchStart then
                        searchStart = searchStart + 1
                    else
                        break
                    end
                else
                    thisFile = sub(code, pos)
                    if not IsDevelopmentScript(thisFile) then
                        codeTable[#codeTable + 1] = thisFile
                    end
                    pos = beginFilePos
                end
            until beginFilePos == nil

            code = table.concat(codeTable, "\n")
        else
            code = WSCodeConfig.MAP_SCRIPT_PREFIX .. code
        end

        if not WSCodeConfig.finalizer.REMOVE_COMMENTS_AND_LINE_BREAKS then
            if io then
                local file = io.open(LuaFileFolder .. "\\" .. "WSCodeMapScript.lua", "w")
                if file then
                    file:write(code)
                    file:close()
                    print("Map script written to file " .. LuaFileFolder .. "\\WSCodeMapScript.lua. You can now close the map.")
                else
                    print("|cffff5555ERROR: Failed to write file.|r")
                end
            else
                FileIO.Export(editor.EXPORT_SUBFOLDER .. "\\WSCodeMapScript.txt", code)
                print("Map script written to file " .. editor.EXPORT_SUBFOLDER .. "\\WSCodeMapScript.txt. You can now close the map.")
            end
            return
        end

        local codeTokens, lineNumberOfToken = WSCode.Tokenize(code)

        local stringDef = {}

        local stringDefTokens = WSCode.Tokenize(table.concat(stringDef))
        stringDefTokens[#stringDefTokens] = nil --last token is empty string
        local prefixTokens = WSCode.Tokenize(WSCodeConfig.MAP_SCRIPT_PREFIX)
        prefixTokens[#prefixTokens] = nil

        for i = 1, #concatTable do
            concatTable[i] = nil
        end

        local tokens = stringDefTokens
        for i = 1, #prefixTokens do
            tokens[#tokens + 1] = prefixTokens[i]
        end
        for i = 1, #codeTokens do
            tokens[#tokens + 1] = codeTokens[i]
        end

        concatTable[1] = tokens[1]
        local token, newLine
        for i = 2, #tokens do
            token = tokens[i]
            newLine = false
            if not newLine and
            ((find(token, "[%w_]") ~= nil and find(tokens[i - 1], "[%w_]") ~= nil)
            or (match(tokens[i - 1], "[%.%w]$") and sub(token, 1, 1) == "." and (match(tokens[i - 1], "%d$") or token ~= ".."))
            or (sub(tokens[i - 1], -1) == "." and find(token, "^%d"))
            or (tokens[i - 1] == "-" and sub(token, 1, 1) == "-")) then
                concatTable[#concatTable + 1] = " "
            end

            concatTable[#concatTable + 1] = token
        end

        code = table.concat(concatTable)

        FileIO.Export(editor.EXPORT_SUBFOLDER .. "\\WSCodeMapScript.txt", code)
        print("Map script written to file " .. editor.EXPORT_SUBFOLDER .. "\\WSCodeMapScript.txt. You can now close the map.")
    end

    --======================================================================================================================
    --Initialization
    --======================================================================================================================

    local function ExecuteInitList(whichList)
        if init.suspended and whichList ~= "essential" then
            return
        end

        if whichList == "main" then
            diagnostics.INIT_OUTSIDE_OF_WRAP_WARNING = nil
            if compiler.ENABLE_QUICK_RESTART then
                init.afterMain = true
                local flagsString = FileIO.Load(editor.EXPORT_SUBFOLDER .. "\\WSCodeFlags.txt")
                if flagsString then
                    for i = 1, #flags do
                        flags[flags[i]] = flagsString:sub(i, i) == "1"
                    end
                    if flags.quickRestart or compiler.ALWAYS_QUICK_RESTART then
                        flags.quickRestart = false
                        SaveSettings()
                        init.isQuickRestart = true
                        local script = FileIO.Load(editor.EXPORT_SUBFOLDER .. "\\WSCodeMapScript.txt")
                        if script then
                            print("Altered map script loaded successfully.")
                            WSCode.Parse(script)
                        else
                            print("Could not find " .. editor.EXPORT_SUBFOLDER .. "\\WSCodeMapScript.txt. Loading regular map script.")
                            WSCode.Parse(init.mapScript)
                        end
                    else
                        WSCode.Parse(init.mapScript)
                    end
                elseif compiler.ALWAYS_QUICK_RESTART then
                    local script = FileIO.Load(editor.EXPORT_SUBFOLDER .. "\\WSCodeMapScript.txt")
                    if script then
                        print("Altered map script loaded successfully.")
                        WSCode.Parse(script)
                    else
                        print("Could not find " .. editor.EXPORT_SUBFOLDER .. "\\WSCodeMapScript.txt. Loading regular map script.")
                        WSCode.Parse(init.mapScript)
                    end
                else
                    flags.debugMode = true
                    WSCode.Parse(init.mapScript)
                end
            elseif FileIO then
                local flagsString = FileIO.Load(editor.EXPORT_SUBFOLDER .. "\\WSCodeFlags.txt")
                if flagsString then
                    for i = 1, #flags do
                        flags[flags[i]] = flagsString:sub(i, i) == "1"
                    end
                else
                    flags.debugMode = true
                end
            else
                flags.debugMode = true
            end
        end

        init.completed[whichList] = true

        local startTime
        if diagnostics.PROFILE_INIT then
            startTime = clock()
        end

        local passes = init.passes
        for i = 1, init.highestPass[whichList] or 1 do
            for __, initializer in ipairs(init[whichList]) do
                if passes[initializer] == i then
                    if diagnostics.INIT_DUMP then
                        PreloadGenClear()
                        PreloadGenStart()
                        Preload("WSCode.Init" .. whichList:sub(1, 1):upper() .. whichList:sub(2) .. ": " .. (init.names[initializer] or "Unknown"))
                        PreloadGenEnd(editor.EXPORT_SUBFOLDER .. "\\WSCodeInitDump.txt")
                    end
                    if compiler.RELEASE_VERSION then
                        initializer()
                    elseif diagnostics.PROFILE_INIT then
                        local time = clock()
                        initializer()
                        local endTime = clock()
                        if init.names[initializer] then
                            init.profiler[init.names[initializer]] = (init.profiler[init.names[initializer]] or 0) + endTime - time
                        end
                    elseif Debug then
                        ---@diagnostic disable-next-line: param-type-mismatch
                        xpcall(initializer, Debug.errorHandler)
                    else
                        initializer()
                    end
                end
            end
        end

        if diagnostics.PROFILE_INIT then
            local endTime = clock()
            init.profiler.totalTime = init.profiler.totalTime + endTime - startTime
        end

        if init and init.suspended and whichList ~= "essential" then
            init.suspended = false
            if not init.completed.main then
                ExecuteInitList("main")
            end
            if not init.completed.global then
                ExecuteInitList("global")
            end
            if not init.completed.trig then
                ExecuteInitList("trig")
            end
            if not init.completed.map then
                ExecuteInitList("map")
            end
            if not init.completed.essential then
                ExecuteInitList("essential")
            end
            if not init.completed.final then
                ExecuteInitList("final")
            end
        end
    end

    do
        local gmt = getmetatable(_G) or getmetatable(setmetatable(_G, {}))
        local rawIndex = gmt.__newindex or rawset

        ---@param _G table
        ---@param key string
        ---@param fnOrDiscard unknown
        local function hookMain(_G, key, fnOrDiscard)
            if key == "main" then
                rawIndex(_G, key, function()
                    if gmt.__newindex == hookMain then
                        gmt.__newindex = rawIndex --restore the original __newindex if no further hooks on __newindex exist.
                    end
                    coroutine.resume(coroutine.create(ExecuteInitList), "main")

                    fnOrDiscard()
                end)
            else
                rawIndex(_G, key, fnOrDiscard)
            end
        end
        gmt.__newindex = hookMain

        local oldGlobals = InitGlobals
        InitGlobals = function()
            oldGlobals()

            if InitCustomTriggers then
                local oldTrig = InitCustomTriggers
                InitCustomTriggers = function()
                    oldTrig()
                    coroutine.resume(coroutine.create(ExecuteInitList), "trig")
                end
            else
                coroutine.resume(coroutine.create(ExecuteInitList), "trig")
            end

            if RunInitializationTriggers then
                local oldMap = RunInitializationTriggers
                RunInitializationTriggers = function()
                    oldMap()
                    coroutine.resume(coroutine.create(ExecuteInitList), "map")
                end
            else
                coroutine.resume(coroutine.create(ExecuteInitList), "map")
            end

            coroutine.resume(coroutine.create(ExecuteInitList), "global")
        end

        local oldMark = MarkGameStarted
        MarkGameStarted = function()
            oldMark()

            if compiler.FINALIZE_MAP_SCRIPT then
                FinalizeScript(table.concat(WSCode.SaveString, "\n"))
            end

            coroutine.resume(coroutine.create(ExecuteInitList), "essential")
            coroutine.resume(coroutine.create(ExecuteInitList), "final")

            if init and #init.load > 0 then
                local trig = CreateTrigger()
                TriggerRegisterGameEvent(trig, EVENT_GAME_LOADED)
                TriggerAddAction(trig, function()
                    local passes = init.passes
                    for i = 1, init.highestPass.load or 1 do
                        for __, initializer in ipairs(init.load) do
                            if passes[initializer] == i then
                                if compiler.RELEASE_VERSION then
                                    initializer()
                                elseif Debug then
                                    ---@diagnostic disable-next-line: param-type-mismatch
                                    xpcall(initializer, Debug.errorHandler)
                                else
                                    initializer()
                                end
                            end
                        end
                    end
                end)
            end

            if not compiler.RELEASE_VERSION then
                CreateControlTriggers()

                --Actions to be executed upon typing -exec
                local function ExecCommand()
                    if string.sub(GetEventPlayerChatString(), 1, 6) ~= "-exec " then
                        return
                    end

                    local input = string.sub(GetEventPlayerChatString(), 7, -1)
                    print("Executing input: |cffffff44" .. input .. "|r")
                    --try preceeding the input by a return statement (preparation for printing below)
                    local loadedFunc, errorMsg = load("return ".. input)
                    if not loadedFunc then --if that doesn't produce valid code, try without return statement
                        loadedFunc, errorMsg = load(input)
                    end
                    --execute loaded function in case the string defined a valid function. Otherwise print error.
                    if errorMsg then
                        if Debug then
                            print("|cffff5555Invalid Lua-statement: " .. Debug.getLocalErrorMsg(errorMsg) .. "|r")
                        else
                            print("|cffff5555Invalid Lua-statement.|r")
                        end
                    else
                        local results
                        if Debug then
                            ---@diagnostic disable-next-line: param-type-mismatch
                            results = table.pack(Debug.try(loadedFunc))
                        else
                            results = table.pack(loadedFunc)
                        end
                        if results[1] ~= nil or results.n > 1 then
                            for i = 1, results.n do
                                results[i] = tostring(results[i])
                            end
                            --concatenate all function return values to one colorized string
                            print("|cff00ffff" .. table.concat(results, '    ', 1, results.n) .. "|r")
                        end
                    end
                end

                local execTrigger = CreateTrigger()
                TriggerAddAction(execTrigger, ExecCommand)

                for i = 0, 23 do
                    if user then
                        break
                    end
                    local player = Player(i)
                    for __, creator in ipairs(editor.MAP_CREATORS) do
                        if find(GetPlayerName(player), creator) and GetPlayerController(player) == MAP_CONTROL_USER and GetPlayerSlotState(player) == PLAYER_SLOT_STATE_PLAYING then
                            user = Player(i)
                            break
                        end
                    end
                end

                TriggerRegisterPlayerChatEvent(execTrigger, user, "-exec ", false)

                if init.error then
                    JumpToError(init.error.fileName, init.error.lineNumber)
                    editor.ON_ERROR(init.error.fileName)
                elseif Debug and Debug.data.firstError then
                    local fileName = Debug.data.firstError:match("ERROR at (.+), line")
                    local lineNumber = tonumber(Debug.data.firstError:match("line (%d+):"))
                    if fileName and lineNumber then
                        JumpToError(fileName, lineNumber)
                        editor.ON_ERROR(init.error.fileName)
                    end
                end

                initialized = true
                if coroutineWaitingForInit then
                    coroutine.resume(coroutineWaitingForInit)
                end
                if init.error then
                    SaveTabs()
                end

                if diagnostics.PROFILE_INIT then
                    local totalTime = init.profiler.totalTime
                    local str = "Map script initialization profile complete:\n|cffaaaaffTotal time:|r " .. string.format("%.3f", totalTime) .. "s"
                    init.profiler.totalTime = nil
                    local orderedFiles = {}
                    for fileName, duration in next, init.profiler do
                        orderedFiles[#orderedFiles + 1] = fileName
                    end
                    table.sort(orderedFiles, function(a, b)
                        return init.profiler[a] > init.profiler[b]
                    end)
                    local scriptTime = 0
                    for i = 1, #orderedFiles do
                        scriptTime = scriptTime + init.profiler[orderedFiles[i]]
                    end
                    str = str .. "\n|cffaaaaffScript time:|r " .. string.format("%.3f", scriptTime) .. "s"
                    str = str .. "\n|cffaaaaffParser time:|r " .. string.format("%.3f", totalTime - scriptTime) .. "s"
                    str = str .. "\n--------------------"
                    local i = 1
                    while i <= min(10, #orderedFiles) do
                        local fraction = init.profiler[orderedFiles[i]]/totalTime
                        if fraction < 0.001 then
                            break
                        end
                        str = str .. "\n|cffffcc00" .. orderedFiles[i] .. ":|r " .. string.format("%.3f", init.profiler[orderedFiles[i]]) .. "s |cffaaaaaa(" .. string.format("%.1f", 100*fraction) .. "%)|r"

                        i = i + 1
                    end

                    print(str)
                end

                TimerStart(CreateTimer(), 0.01, true, MainLoop)
            else
                files = nil
                fileNames = nil
                init = nil
                initialized = true
            end
        end
    end

    local function InitTabs()
        local tabString = FileIO.Load(editor.EXPORT_SUBFOLDER .. "\\WSCodeTabs.txt")
        init.tabsInitialized = true
        if tabString then
            init.debugTabs = {}
            init.pullTabs = {}
            init.loadTabs = {}
            local commaPos
            local beginning = 1
            local tabName
            local filePulled
            repeat
                commaPos = tabString:find("[,;]", beginning)
                if commaPos then
                    filePulled = tabString:sub(commaPos, commaPos) == ";"
                    tabName = tabString:sub(beginning, commaPos - 1)
                    beginning = commaPos + 1

                    init.debugTabs[tabName] = true
                    if filePulled then
                        init.pullTabs[tabName] = true
                    else
                        init.loadTabs[tabName] = true
                    end
                end
            until not commaPos
        end
    end

    --======================================================================================================================
    --Code Editor
    --======================================================================================================================

    local function PlayError()
        local s = CreateSound("Sound\\Interface\\Error.flac" , false, false, false, 10, 10, "DefaultEAXON")
        if GetLocalPlayer() == user then
            SetSoundVolume(s, 127)
        else
            SetSoundVolume(s, 0)
        end
        StartSound(s)
        KillSoundWhenDone(s)
    end

    local function SetFrameAlpha(frame, alpha)
        local adjustedAlpha = ((editor.frameCurrentAlpha[BlzFrameGetParent(frame)] or 255)*alpha) // 255
        BlzFrameSetAlpha(frame, adjustedAlpha)
        editor.frameIntrinsicAlpha[frame] = alpha
        editor.frameCurrentAlpha[frame] = adjustedAlpha
        local child
        for i = 0, BlzFrameGetChildrenCount(frame) - 1 do
            child = BlzFrameGetChild(frame, i)
            SetFrameAlpha(child, editor.frameIntrinsicAlpha[child] or 255)
        end
    end

    SaveSettings = function()
        if not FileIO then
            return
        end

        local saveString = ""
        for i = 1, #flags do
            saveString = saveString .. (flags[flags[i]] and "1" or "0")
        end

        FileIO.Save(editor.EXPORT_SUBFOLDER .. "\\WSCodeFlags.txt", saveString)
    end

    SaveTabs = function()
        if not initialized then
            return
        end
        if editor.ENABLE_SAVE_AND_LOAD and FileIO then
            local saveString = ""
            for j = 1, tabs.amount do
                if not existingFiles[tabs.names[j]] then
                    saveString = saveString .. tabs.names[j] .. ","
                elseif not tabs.wasPulledFromDebugToken[tabs.names[j]] then
                    saveString = saveString .. tabs.names[j] .. ";"
                end
            end
            FileIO.Save(editor.EXPORT_SUBFOLDER .. "\\WSCodeTabs.txt", saveString)
        end
    end

    local function GetTextHighlightFrame(playerIndexString, alpha, type)
        local frame
        if #highlights.text > 0 then
            frame = highlights.text[#highlights.text]
            highlights.text[#highlights.text] = nil
            if highlights.typeFromFrame[frame] ~= type then
                highlights.typeFromFrame[frame] = type
                BlzFrameSetTexture(frame, "ReplaceableTextures\\TeamColor\\TeamColor" .. playerIndexString .. ".blp", 0, true)
                SetFrameAlpha(frame, alpha)
            end
            BlzFrameSetVisible(frame, true)
        else
            frame = BlzCreateFrameByType("BACKDROP", "", codeEditorParent, "", 0)
            BlzFrameSetTexture(frame, "ReplaceableTextures\\TeamColor\\TeamColor" .. playerIndexString .. ".blp", 0, true)
            SetFrameAlpha(frame, alpha)
            BlzFrameSetEnable(frame, false)
            highlights.typeFromFrame[frame] = type
        end
        return frame
    end

    local function ReturnTextHighlightFrame(whichFrame)
        BlzFrameSetVisible(whichFrame, false)
        highlights.text[#highlights.text + 1] = whichFrame
    end

    local function GetTextWidth(str)
        BlzFrameSetText(widthTestFrame, str:gsub("|", "||"))
        BlzFrameSetSize(widthTestFrame, 0, 0)
        return BlzFrameGetWidth(widthTestFrame)
    end

    local function ConvertSelectionToLines()
        local lower = max(selection.startLine, selection.endLine)
        local upper = min(selection.startLine, selection.endLine)

        if lower < upper then
            return {}
        end

        local currentLines = codeLines[currentTab][step[currentTab]]

        local left, right
        if lower == upper then
            left = min(selection.startPos, selection.endPos)
            right = max(selection.startPos, selection.endPos)
        else
            left = selection.startLine == upper and selection.startPos or selection.endPos
            right = selection.startLine == lower and selection.startPos or selection.endPos
        end

        local lines = {}

        if lower == upper then
            lines[1] = sub(currentLines[upper], left + 1, right)
        else
            lines[1] = sub(currentLines[upper], left + 1)
        end
        for i = upper + 1, lower do
            if i == lower then
                lines[#lines + 1] = sub(currentLines[lower], 1, right)
            else
                lines[#lines + 1] = currentLines[i]
            end
        end

        return lines
    end

    local function CreateContextSeparator(position)
        local separator = BlzCreateFrameByType("BACKDROP", "", contextMenu.parent, "", 0)
        BlzFrameSetEnable(separator, false)
        BlzFrameSetPoint(separator, FRAMEPOINT_BOTTOMLEFT, contextMenu.parent, FRAMEPOINT_TOPLEFT, flagsMenu.TEXT_INSET, -flagsMenu.TEXT_INSET - (position - 0.48)*editor.LINE_SPACING)
        BlzFrameSetPoint(separator, FRAMEPOINT_TOPRIGHT, contextMenu.parent, FRAMEPOINT_TOPLEFT, flagsMenu.WIDTH - flagsMenu.TEXT_INSET, -flagsMenu.TEXT_INSET - (position - 0.52)*editor.LINE_SPACING)
        BlzFrameSetTexture(separator, "ReplaceableTextures\\TeamColor\\TeamColor08.blp", 0, true)
    end

    local function CreateContextButton(position, name, tooltip, callback, isCustom, titleSuffix, parent)
        local button = BlzCreateFrame("VariableViewerButton", parent, 0, 0)
        local text = BlzFrameGetChild(button, 0)
        BlzFrameSetEnable(text, false)
        BlzFrameSetPoint(button, FRAMEPOINT_BOTTOMLEFT, parent, FRAMEPOINT_TOPLEFT, flagsMenu.TEXT_INSET, -flagsMenu.TEXT_INSET - position*editor.LINE_SPACING)
        BlzFrameSetPoint(button, FRAMEPOINT_TOPRIGHT, parent, FRAMEPOINT_TOPLEFT, flagsMenu.WIDTH - flagsMenu.TEXT_INSET, -flagsMenu.TEXT_INSET - (position - 1)*editor.LINE_SPACING)
        BlzFrameSetTextAlignment(text, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
        BlzFrameSetAllPoints(text, button)
        indexFromFrame[button] = position

        BlzFrameSetText(text, name)

        local trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, button, FRAMEEVENT_CONTROL_CLICK)
        if isCustom then
            TriggerAddAction(trig, function()
                BlzFrameSetVisible(parent, false)
                callback()
            end)
        else
            TriggerAddAction(trig, callback)
        end

        local tooltipFrame = BlzCreateFrame("CustomTooltip", codeEditorParent, 0, 0)

        if parent == contextMenu.parent then
            BlzFrameSetPoint(tooltipFrame, FRAMEPOINT_BOTTOMRIGHT, parent, FRAMEPOINT_TOPRIGHT, 0, 0)
        else
            BlzFrameSetPoint(tooltipFrame, FRAMEPOINT_TOPRIGHT, parent, FRAMEPOINT_BOTTOMRIGHT, 0, 0)
        end
        BlzFrameSetTooltip(button, tooltipFrame)

        local tooltipTitle = BlzFrameGetChild(tooltipFrame, 0)
        local tooltipText = BlzFrameGetChild(tooltipFrame, 1)
        BlzFrameSetText(tooltipTitle, "|cffffcc00" .. name .. (titleSuffix or "") .. "|r")
        BlzFrameSetText(tooltipText, tooltip)
        BlzFrameSetSize(tooltipText, 0.22 - 0.012, 0.0)
        BlzFrameSetSize(tooltipFrame, 0.22, BlzFrameGetHeight(tooltipText) + 0.035)
        BlzFrameSetVisible(tooltipFrame, false)

        return button
    end

    local function CreateSubArrayButton(parent, subParent, position, name, callback, parentWidth)
        local button = BlzCreateFrame("VariableViewerButton", subParent, 0, 0)
        local text = BlzFrameGetChild(button, 0)
        BlzFrameSetEnable(text, false)
        BlzFrameSetPoint(button, FRAMEPOINT_BOTTOMLEFT, subParent, FRAMEPOINT_TOPLEFT, flagsMenu.TEXT_INSET, -flagsMenu.TEXT_INSET - position*editor.LINE_SPACING)
        BlzFrameSetPoint(button, FRAMEPOINT_TOPRIGHT, subParent, FRAMEPOINT_TOPLEFT, (parentWidth or flagsMenu.WIDTH) - flagsMenu.TEXT_INSET, -flagsMenu.TEXT_INSET - (position - 1)*editor.LINE_SPACING)
        BlzFrameSetTextAlignment(text, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
        BlzFrameSetAllPoints(text, button)
        indexFromFrame[button] = position

        BlzFrameSetText(text, "|cffffcc00" .. name .. "|r")

        local trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, button, FRAMEEVENT_CONTROL_CLICK)

        TriggerAddAction(trig, function()
            BlzFrameSetVisible(parent, false)
            BlzFrameSetVisible(subParent, false)
            callback()
        end)

        return button
    end

    local function CreateArrayButton(parent, position, nameOrData, tooltip, highlighted, callback, buttonTable, width, titleSuffix, positionOfParent)
        local button = BlzCreateFrame("VariableViewerButton", parent, 0, 0)
        local text = BlzFrameGetChild(button, 0)
        BlzFrameSetEnable(text, false)
        BlzFrameSetPoint(button, FRAMEPOINT_BOTTOMLEFT, parent, FRAMEPOINT_TOPLEFT, flagsMenu.TEXT_INSET, -flagsMenu.TEXT_INSET - position*editor.LINE_SPACING)
        BlzFrameSetPoint(button, FRAMEPOINT_TOPRIGHT, parent, FRAMEPOINT_TOPLEFT, (width or flagsMenu.WIDTH) - flagsMenu.TEXT_INSET, -flagsMenu.TEXT_INSET - (position - 1)*editor.LINE_SPACING)
        BlzFrameSetTextAlignment(text, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
        BlzFrameSetAllPoints(text, button)
        indexFromFrame[button] = position

        local trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, button, FRAMEEVENT_CONTROL_CLICK)

        if type(callback) == "function" then
            BlzFrameSetText(text, (highlighted == false and "|cff999999" or "|cffffcc00") .. nameOrData .. "|r")

            TriggerAddAction(trig, function()
                BlzFrameSetVisible(parent, false)
                if buttons.subArrayButtons[parent] then
                    for i = 1, #buttons.subArrayButtons[parent] do
                        BlzFrameSetVisible(buttons.subArrayButtons[parent][i].parent, false)
                    end
                end
                callback()
            end)
        else
            BlzFrameSetText(text, (highlighted == false and "|cff999999" or "|cffffcc00") .. nameOrData.parent .. "|r")

            local subParent = BlzCreateFrame("CodeEditor", parent, 0, 0)
            BlzFrameSetLevel(subParent, 3)
            BlzFrameSetVisible(subParent, false)

            local backdrop = BlzFrameGetChild(subParent, 0)
            BlzFrameSetAllPoints(backdrop, subParent)
            SetFrameAlpha(backdrop, editor.BLACK_BACKDROP_ALPHA)

            local border = BlzFrameGetChild(subParent, 1)
            BlzFrameSetAllPoints(border, subParent)

            BlzFrameSetPoint(subParent, FRAMEPOINT_BOTTOMLEFT, parent, FRAMEPOINT_BOTTOMRIGHT, -flagsMenu.ARRAY_FIELD_OVERLAP, 0)
            BlzFrameSetSize(subParent, nameOrData.width or flagsMenu.WIDTH, 2*flagsMenu.TEXT_INSET + #nameOrData*editor.LINE_SPACING)

            local buttonData = {
                parent = subParent,
                minX = buttonTable.maxX - flagsMenu.ARRAY_FIELD_OVERLAP,
                maxX = buttonTable.maxX - flagsMenu.ARRAY_FIELD_OVERLAP + (nameOrData.width or flagsMenu.WIDTH),
                maxY = editor.Y_TOP - editor.CODE_TOP_INSET - editor.MAX_LINES_ON_SCREEN*editor.LINE_SPACING - editor.CODE_BOTTOM_INSET + BlzFrameGetHeight(subParent)
            }

            for i = 1, #callback do
                CreateSubArrayButton(parent, subParent, i, nameOrData[i], callback[i], nameOrData.width)
            end

            buttons.subArrayButtons[parent][#buttons.subArrayButtons[parent] + 1] = buttonData

            TriggerAddAction(trig, function()
                BlzFrameSetEnable(button, false)
                BlzFrameSetEnable(button, true)
                for i = 1, #buttons.subArrayButtons[parent] do
                    BlzFrameSetVisible(buttons.subArrayButtons[parent][i].parent, false)
                end
                BlzFrameSetVisible(subParent, true)
            end)
        end

        if tooltip then
            local tooltipFrame = BlzCreateFrame("CustomTooltip", codeEditorParent, 0, 0)

            if positionOfParent then
                local x = editor.COLLAPSED_WIDTH/2 + (positionOfParent - (WSCodeConfig.bottomBar.MAX_BUTTONS + 1)/2)*editor.BOTTOM_BUTTON_SIZE - (width or flagsMenu.WIDTH)/2
                local dx = editor.COLLAPSED_WIDTH - x
                if dx < 0.22 then
                    BlzFrameSetPoint(tooltipFrame, FRAMEPOINT_BOTTOMLEFT, parent, FRAMEPOINT_TOPLEFT, dx - 0.22, 0)
                else
                    BlzFrameSetPoint(tooltipFrame, FRAMEPOINT_BOTTOMLEFT, parent, FRAMEPOINT_TOPLEFT, 0, 0)
                end
            else
                BlzFrameSetPoint(tooltipFrame, FRAMEPOINT_BOTTOMLEFT, parent, FRAMEPOINT_TOPLEFT, 0, 0)
            end
            BlzFrameSetTooltip(button, tooltipFrame)

            local tooltipTitle = BlzFrameGetChild(tooltipFrame, 0)
            local tooltipText = BlzFrameGetChild(tooltipFrame, 1)
            BlzFrameSetText(tooltipTitle, "|cffffcc00" .. (type(nameOrData) == "string" and nameOrData or nameOrData.parent) .. (titleSuffix or "") .. "|r")
            BlzFrameSetText(tooltipText, tooltip)
            BlzFrameSetSize(tooltipText, 0.22 - 0.012, 0.0)
            BlzFrameSetSize(tooltipFrame, 0.22, BlzFrameGetHeight(tooltipText) + 0.035)
        end

        return button
    end

    local function IsQuotationMarkEscaped(code, pos)
        local numBackslashLiterals = 0
        pos = pos - 1
        while pos > 0 and sub(code, pos, pos) == "\\" do
            numBackslashLiterals = numBackslashLiterals + 1
            pos = pos - 1
        end
        return math.fmod(numBackslashLiterals, 2) ~= 0
    end

    local function GetMouseScreenCoordinates()
        return BlzPixelToFrameX(BlzGetMouseScreenPosX()), BlzPixelToFrameY(BlzGetMouseScreenPosY())
    end

    local function SetCursorX(str)
        local width = GetTextWidth(str)
        BlzFrameSetPoint(cursorFrame, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + width, -editor.CODE_TOP_INSET - cursor.screenLineNumber*editor.LINE_SPACING)
        cursor.x = width
        cursorCounter = 0
    end

    local function SetCursorPos(whichPos)
        cursor.pos = whichPos

        if not cursor.pos then
            return
        end

        local offset = BlzFrameGetValue(codeHorizontalScroller)
        local limit = editor.isExpanded and editor.CHARS_ON_SCREEN_EXPANDED or editor.CHARS_ON_SCREEN_COLLAPSED
        BlzFrameSetValue(codeHorizontalScroller, max(whichPos - limit, offset))

        local line = cursor.codeLineNumber
        local currentLines = codeLines[currentTab][step[currentTab]]
        local previousChar = sub(currentLines[line], cursor.pos, cursor.pos)
        local nextChar = sub(currentLines[line], cursor.pos + 1, cursor.pos + 1)
        local whichChar = brackets.IS_BRACKET[previousChar] and previousChar or brackets.IS_BRACKET[nextChar] and nextChar
        if whichChar and not selection.hasSelection then
            local originalPos = brackets.IS_BRACKET[previousChar] and cursor.pos or cursor.pos + 1
            local searchFor = brackets.CORRESPONDING_BRACKET[whichChar]
            local bracketFound = false

            if whichChar == ")" or whichChar == "]" or whichChar == "}" then
                local startPoint = originalPos - 1
                local bracketBalance = -1
                local char
                repeat
                    for i = startPoint, 1, -1 do
                        char = sub(currentLines[line], i, i)
                        if char == searchFor then
                            bracketBalance = bracketBalance + 1
                            if bracketBalance == 0 then
                                bracketFound = true
                                brackets.lines[1] = cursor.codeLineNumber
                                brackets.pos[1] = originalPos
                                brackets.lines[2] = line
                                brackets.pos[2] = i
                                break
                            end
                        elseif char == whichChar then
                            bracketBalance = bracketBalance - 1
                        end
                    end
                    line = line - 1
                    startPoint = #currentLines[line]
                until bracketFound or line < 1
            else
                local startPoint = originalPos + 1
                local bracketBalance = 1
                local char
                repeat
                    for i = startPoint, #currentLines[line] do
                        char = sub(currentLines[line], i, i)
                        if char == searchFor then
                            bracketBalance = bracketBalance - 1
                            if bracketBalance == 0 then
                                bracketFound = true
                                brackets.lines[1] = cursor.codeLineNumber
                                brackets.pos[1] = originalPos
                                brackets.lines[2] = line
                                brackets.pos[2] = i
                                break
                            end
                        elseif char == whichChar then
                            bracketBalance = bracketBalance + 1
                        end
                    end
                    line = line + 1
                    startPoint = 1
                until bracketFound or line > highestNonEmptyLine[currentTab][step[currentTab]]
            end

            if bracketFound then
                local screenLineNumber = brackets.lines[1] - tabs.lineNumberOffset[currentTab]
                if screenLineNumber >= 1 and screenLineNumber <= editor.MAX_LINES_ON_SCREEN then
                    BlzFrameSetVisible(brackets.highlights[1], true)
                    BlzFrameSetPoint(brackets.highlights[1], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[brackets.lines[1]], tabs.horizontalOffset[currentTab] + 1, brackets.pos[1] - 1)), -editor.CODE_TOP_INSET - screenLineNumber*editor.LINE_SPACING)
                    BlzFrameSetPoint(brackets.highlights[1], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[brackets.lines[1]], tabs.horizontalOffset[currentTab] + 1, brackets.pos[1])), -editor.CODE_TOP_INSET - (screenLineNumber - 1)*editor.LINE_SPACING)
                else
                    BlzFrameSetVisible(brackets.highlights[1], false)
                end
                screenLineNumber = brackets.lines[2] - tabs.lineNumberOffset[currentTab]
                if screenLineNumber >= 1 and screenLineNumber <= editor.MAX_LINES_ON_SCREEN then
                    BlzFrameSetVisible(brackets.highlights[2], true)
                    BlzFrameSetPoint(brackets.highlights[2], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[brackets.lines[2]], tabs.horizontalOffset[currentTab] + 1, brackets.pos[2] - 1)), -editor.CODE_TOP_INSET - screenLineNumber*editor.LINE_SPACING)
                    BlzFrameSetPoint(brackets.highlights[2], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[brackets.lines[2]], tabs.horizontalOffset[currentTab] + 1, brackets.pos[2])), -editor.CODE_TOP_INSET - (screenLineNumber - 1)*editor.LINE_SPACING)
                else
                    BlzFrameSetVisible(brackets.highlights[2], false)
                end
            else
                brackets.lines[1] = nil
                brackets.lines[2] = nil
                BlzFrameSetVisible(brackets.highlights[1], false)
                BlzFrameSetVisible(brackets.highlights[2], false)
            end
        else
            brackets.lines[1] = nil
            brackets.lines[2] = nil
            BlzFrameSetVisible(brackets.highlights[1], false)
            BlzFrameSetVisible(brackets.highlights[2], false)
        end
    end

    local function AdjustHorizontalLineScroller()
        local maxOnScreen = editor.isExpanded and editor.CHARS_ON_SCREEN_EXPANDED or editor.CHARS_ON_SCREEN_COLLAPSED
        if tabs.longestLineLength[currentTab] > maxOnScreen - editor.MAX_HORIZONTAL_SCROLL_BUFFER then
            BlzFrameSetVisible(codeHorizontalScroller, true)
            BlzFrameSetMinMaxValue(codeHorizontalScroller, 0, tabs.longestLineLength[currentTab] - maxOnScreen + editor.MAX_HORIZONTAL_SCROLL_BUFFER)
        else
            BlzFrameSetVisible(codeHorizontalScroller, false)
            BlzFrameSetMinMaxValue(codeHorizontalScroller, 0, 0)
            BlzFrameSetValue(codeHorizontalScroller, 0)
        end
    end

    ---@param lineNumber? integer
    local function CheckLongestLineLength(lineNumber)
        if not tabs.longestLineIndex[currentTab] then
            --Do full search if linenumber not specified
            local longestIndex = 0
            local longestLength = 0
            local currentLines = codeLines[currentTab][step[currentTab]]
            for i = 1, highestNonEmptyLine[currentTab][step[currentTab]] do
                if #currentLines[i] > longestLength then
                    longestIndex = i
                    longestLength = #currentLines[i]
                end
            end
            tabs.longestLineIndex[currentTab] = longestIndex
            tabs.longestLineLength[currentTab] = longestLength
            return true
        elseif lineNumber then
            local currentLines = codeLines[currentTab][step[currentTab]]
            local newLength = #currentLines[lineNumber]
            if tabs.longestLineIndex[currentTab] == lineNumber then
                if newLength > tabs.longestLineLength[currentTab] then
                    tabs.longestLineLength[currentTab] = newLength
                    return true
                else
                    tabs.longestLineIndex[currentTab] = nil
                    CheckLongestLineLength()
                    return true
                end
            elseif newLength > tabs.longestLineLength[currentTab] then
                tabs.longestLineIndex[currentTab] = lineNumber
                tabs.longestLineLength[currentTab] = newLength
                return true
            end
        end
        return false
    end

    local function SetLineOffset(whichOffset)
        BlzFrameSetValue(codeScroller, highestNonEmptyLine[currentTab][step[currentTab]] - whichOffset)
    end

    local function JumpWindow(whichLine, jumpToCenter, forceCenter)
        if forceCenter then
            SetLineOffset(max(0, min(whichLine - editor.MAX_LINES_ON_SCREEN // 2, highestNonEmptyLine[currentTab][step[currentTab]] - editor.MAX_LINES_ON_SCREEN + 4)))
            return true
        else
            if tabs.lineNumberOffset[currentTab] > whichLine - 4 and tabs.lineNumberOffset[currentTab] > 1 then
                if jumpToCenter then
                    SetLineOffset(max(0, min(whichLine - editor.MAX_LINES_ON_SCREEN // 2, highestNonEmptyLine[currentTab][step[currentTab]] - editor.MAX_LINES_ON_SCREEN+ 4)))
                else
                    SetLineOffset(max(0, whichLine - 4))
                end
                return true
            elseif tabs.lineNumberOffset[currentTab] < whichLine - editor.MAX_LINES_ON_SCREEN + 4 then
                if jumpToCenter then
                    SetLineOffset(max(0, min(whichLine - editor.MAX_LINES_ON_SCREEN // 2, highestNonEmptyLine[currentTab][step[currentTab]] - editor.MAX_LINES_ON_SCREEN + 4)))
                else
                    SetLineOffset(whichLine - editor.MAX_LINES_ON_SCREEN + 4)
                end
                return true
            else
                return false
            end
        end
    end

    local function SetCurrentLine()
        if currentStop[currentTab] - tabs.lineNumberOffset[currentTab] < 1 then
            BlzFrameSetPoint(highlights.currentLine, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.LINE_HIGHLIGHT_HORIZONTAL_INSET, -editor.CODE_TOP_INSET - editor.LINE_SPACING)
            BlzFrameSetPoint(highlights.currentLine, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.LINE_HIGHLIGHT_HORIZONTAL_INSET + editor.LINE_SPACING, -editor.CODE_TOP_INSET)
            BlzFrameSetTexture(highlights.currentLine, editor.ASSET_SUBFOLDER .. "\\currentLineUp.blp", 0, true)
        elseif currentStop[currentTab] - tabs.lineNumberOffset[currentTab] > editor.MAX_LINES_ON_SCREEN then
            BlzFrameSetPoint(highlights.currentLine, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.LINE_HIGHLIGHT_HORIZONTAL_INSET, -editor.CODE_TOP_INSET - editor.MAX_LINES_ON_SCREEN*editor.LINE_SPACING)
            BlzFrameSetPoint(highlights.currentLine, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.LINE_HIGHLIGHT_HORIZONTAL_INSET + editor.LINE_SPACING, -editor.CODE_TOP_INSET - (editor.MAX_LINES_ON_SCREEN - 1)*editor.LINE_SPACING)
            BlzFrameSetTexture(highlights.currentLine, editor.ASSET_SUBFOLDER .. "\\currentLineDown.blp", 0, true)
        else
            BlzFrameSetPoint(highlights.currentLine, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.LINE_HIGHLIGHT_HORIZONTAL_INSET, -editor.CODE_TOP_INSET - (currentStop[currentTab] - tabs.lineNumberOffset[currentTab])*editor.LINE_SPACING)
            BlzFrameSetPoint(highlights.currentLine, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.LINE_HIGHLIGHT_HORIZONTAL_INSET + editor.LINE_SPACING, -editor.CODE_TOP_INSET - (currentStop[currentTab] - tabs.lineNumberOffset[currentTab] - 1)*editor.LINE_SPACING)
            BlzFrameSetTexture(highlights.currentLine, editor.ASSET_SUBFOLDER .. "\\currentLine.blp", 0, true)
        end
    end

    local function SearchForDuplicates()
        local pos, endPos
        local currentLines = codeLines[currentTab][step[currentTab]]
        local start = min(selection.startPos, selection.endPos) + 1
        local stop = max(selection.startPos, selection.endPos)
        local selectString = sub(currentLines[selection.startLine], start, stop):gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1") --escape all special characters
        local numDuplicates = 0
        local offset
        if #selectString > 0 and selectString:find("^%s*$") == nil then --empty line
            for i = tabs.lineNumberOffset[currentTab] + 1, editor.MAX_LINES_ON_SCREEN + tabs.lineNumberOffset[currentTab] do
                pos, endPos = find(currentLines[i], selectString)
                while pos do
                    if i ~= selection.startLine or pos ~= start then
                        numDuplicates = numDuplicates + 1
                        duplicateHighlightFrames[numDuplicates] = duplicateHighlightFrames[numDuplicates] or GetTextHighlightFrame("09", 90, "duplicate")
                        BlzFrameSetPoint(duplicateHighlightFrames[numDuplicates], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[i], tabs.horizontalOffset[currentTab] + 1, pos - 1)), -editor.CODE_TOP_INSET - (i - tabs.lineNumberOffset[currentTab])*editor.LINE_SPACING)
                        BlzFrameSetPoint(duplicateHighlightFrames[numDuplicates], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[i], tabs.horizontalOffset[currentTab] + 1, endPos)), -editor.CODE_TOP_INSET - (i - 1 - tabs.lineNumberOffset[currentTab])*editor.LINE_SPACING)
                    end
                    offset = endPos
                    pos, endPos = find(sub(currentLines[i], endPos + 1), selectString)
                    if pos then
                        pos = pos + offset
                        endPos = endPos + offset
                    end
                end
            end
        end
        for i = numDuplicates + 1, #duplicateHighlightFrames do
            ReturnTextHighlightFrame(duplicateHighlightFrames[i])
            duplicateHighlightFrames[i] = nil
        end
    end

    local function RemoveDuplicates()
        for i = 1, #duplicateHighlightFrames do
            ReturnTextHighlightFrame(duplicateHighlightFrames[i])
            duplicateHighlightFrames[i] = nil
        end
    end

    local function ConvertAndValidateLines(lines, whichTab, duringInit, printError)
        local code
        if type(lines) == "table" then
            code = table.concat(lines, "\n"):gsub("Debug.beginFile", "DoNothing"):gsub("Debug.endFile", "DoNothing"):gsub("\n*$", "")
        elseif code then
            code = code:gsub("Debug.beginFile", "DoNothing"):gsub("Debug.endFile", "DoNothing"):gsub("\n*$", "")
        else
            code = ""
        end
        local func, err
        func, err = load(code, whichTab, "t")
        if not func then
            if not duringInit then
                if err then
                    local lineNumber = tonumber(err:match('"%]:(%d+):')) --"]:NUMBER:
                    if lineNumber then
                        tabs.hasError[whichTab] = true
                        lineNumbers.error[whichTab] = lineNumber
                        lineNumbers.lastViewed[whichTab] = lineNumber
                        BlzFrameSetVisible(highlights.error, lineNumbers.error[whichTab] - tabs.lineNumberOffset[whichTab] >= 1 and lineNumbers.error[whichTab] - tabs.lineNumberOffset[whichTab] <= editor.MAX_LINES_ON_SCREEN)
                        SetFrameAlpha(highlights.error, 128)
                        BlzFrameSetPoint(highlights.error, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET, -editor.CODE_TOP_INSET - editor.LINE_SPACING*(lineNumbers.error[whichTab] - tabs.lineNumberOffset[whichTab]))
                        BlzFrameSetPoint(highlights.error, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPRIGHT, -editor.CODE_RIGHT_INSET, -editor.CODE_TOP_INSET - editor.LINE_SPACING*(lineNumbers.error[whichTab] - tabs.lineNumberOffset[whichTab] - 1))
                        if printError then
                            WSDebug.PrintForUser("|cffff5555SYNTAX ERROR at " .. (whichTab or "Unknown") .. (err:match('"' .. whichTab .. '"%](.+)') or "") .. "|r")
                        end
                        return false
                    else
                        tabs.hasError[whichTab] = false
                        BlzFrameSetVisible(highlights.error, false)
                        return false
                    end
                else
                    tabs.hasError[whichTab] = false
                    BlzFrameSetVisible(highlights.error, false)
                    return false
                end
            elseif err then
                if printError then
                    WSDebug.PrintForUser("|cffff5555SYNTAX ERROR at " .. (whichTab or "Unknown") .. (err:match('"' .. whichTab .. '"%](.+)') or "") .. "|r")
                end
                if duringInit then
                    init.error = {
                        fileName = whichTab or "Unknown",
                        lineNumber = tonumber(err:match('"%]:(%d+):')) --"]:NUMBER:
                    }
                end
                return false
            end
        elseif not duringInit then
            tabs.hasError[whichTab] = false
            BlzFrameSetVisible(highlights.error, false)
        end
        return true, code, func
    end

    local function AddColors(prefix, match, suffix)
        if LUA.KEYWORDS[match] then
            return prefix .. editor.KEYWORD_COLOR .. match .. "|r" .. suffix
        elseif match == "false" or match == "true" or match == "nil" or tonumber(match) then
            return prefix .. editor.VALUE_COLOR .. match .. "|r" .. suffix
        elseif FUNCTION_PREVIEW and FUNCTION_PREVIEW[match] then
            return prefix .. editor.NATIVE_COLOR .. match .. "|r" .. suffix
        end
        return prefix .. match .. suffix
    end

    local function ColorFunctions(prefix, funcWord, funcName)
        return prefix .. " " .. editor.FUNCTION_NAME_COLOR .. funcName .. "|r"
    end

    local function GetColoredText(str, codeLineNumber, whichTab)
        local inSingleQuoteString
        local inDoubleQuoteString
        local inMultilineString
        local endsInLongComment
        local oldEqualSigns

        str = str:gsub("|", "||")

        local lineSegments = {}

        local restStr, commentStr
        if codeLineNumber > 1 and lines.endsInLongString[whichTab][codeLineNumber - 1] then
            inMultilineString = true
            lines.numEqualSigns[codeLineNumber] = lines.numEqualSigns[codeLineNumber - 1]
            restStr = str
            lineSegments[1] = ""
            commentStr = ""
        elseif codeLineNumber > 1 and lines.endsInLongComment[whichTab][codeLineNumber - 1] then
            lines.numEqualSigns[codeLineNumber] = lines.numEqualSigns[codeLineNumber - 1]
            restStr = ""
            commentStr = editor.COMMENT_COLOR .. str .. "|r"
            local matchStr = "]"
            for __ = 1, lines.numEqualSigns[codeLineNumber] do
                matchStr = matchStr .. "="
            end
            matchStr = matchStr .. "]"
            endsInLongComment = find(str, matchStr) == nil
        else
            local commentBegin = find(str, "%-%-")
            if commentBegin then
                commentStr =  editor.COMMENT_COLOR .. sub(str, commentBegin) .. "|r"
                restStr = sub(str, 1, commentBegin - 1)
                if sub(str, commentBegin):match("^%-%-%[") ~= nil then
                    oldEqualSigns = lines.numEqualSigns[codeLineNumber]
                    lines.numEqualSigns[codeLineNumber] = 0
                    local i = commentBegin + 3
                    while sub(str, i, i) == "=" do
                        lines.numEqualSigns[codeLineNumber] = lines.numEqualSigns[codeLineNumber] + 1
                        i = i + 1
                    end
                    if sub(str, i, i) == "[" then
                        local matchStr = "]"
                        for __ = 1, lines.numEqualSigns[codeLineNumber] do
                            matchStr = matchStr .. "="
                        end
                        if find(str, matchStr) == nil then
                            endsInLongComment = true
                        end
                    end
                end
            else
                restStr = str
                commentStr = ""
                endsInLongComment = nil
            end
        end

        local i = 1
        local beginningOfSegment = 1
        while i <= #restStr do
            local char = sub(restStr, i, i)
            if char == "'" then
                if not IsQuotationMarkEscaped(restStr, i) then
                    if not inDoubleQuoteString and not inMultilineString then
                        if inSingleQuoteString then
                            inSingleQuoteString = false
                            lineSegments[#lineSegments + 1] = editor.STRING_COLOR .. sub(restStr, beginningOfSegment, i) .. "|r"
                            beginningOfSegment = i + 1
                        elseif find(sub(restStr, i + 1), "'") then
                            inSingleQuoteString = true
                            lineSegments[#lineSegments + 1] = sub(restStr, beginningOfSegment, i - 1)
                            beginningOfSegment = i
                        end
                    end
                end
            elseif char == '"' then
                if not IsQuotationMarkEscaped(restStr, i) then
                    if not inSingleQuoteString and not inMultilineString then
                        if inDoubleQuoteString then
                            inDoubleQuoteString = false
                            lineSegments[#lineSegments + 1] = editor.STRING_COLOR .. sub(restStr, beginningOfSegment, i) .. "|r"
                            beginningOfSegment = i + 1
                        elseif find(sub(restStr, i + 1), '"') then
                            inDoubleQuoteString = true
                            lineSegments[#lineSegments + 1] = sub(restStr, beginningOfSegment, i - 1)
                            beginningOfSegment = i
                        end
                    end
                end
            elseif sub(restStr, i):match("^%[=*%[") and not inMultilineString then
                local j = i + 1
                lines.numEqualSigns[codeLineNumber] = 0
                while sub(restStr, j, j) == "=" do
                    lines.numEqualSigns[codeLineNumber] = lines.numEqualSigns[codeLineNumber] + 1
                    j = j + 1
                end
                if sub(restStr, j, j) == "[" then
                    inMultilineString = true
                    lineSegments[#lineSegments + 1] = sub(restStr, beginningOfSegment, i - 1)
                    beginningOfSegment = i
                end
                i = i + 1 + lines.numEqualSigns[codeLineNumber]
            elseif inMultilineString and sub(restStr, i, i + 1 + lines.numEqualSigns[codeLineNumber]):match("^%]=*%]$") then
                inMultilineString = false
                lineSegments[#lineSegments + 1] = editor.STRING_COLOR .. sub(restStr, beginningOfSegment, i + 1 + lines.numEqualSigns[codeLineNumber]) .. "|r"
                beginningOfSegment = i + 2 + lines.numEqualSigns[codeLineNumber]
                i = i + 1 + lines.numEqualSigns[codeLineNumber]
            end
            i = i + 1
        end

        if inMultilineString then
            lineSegments[#lineSegments + 1] = editor.STRING_COLOR .. sub(restStr, beginningOfSegment) .. "|r"
        else
            lineSegments[#lineSegments + 1] = sub(restStr, beginningOfSegment)
        end

        for i = 1, #lineSegments, 2 do
            lineSegments[i] = lineSegments[i]:gsub("(%f[%a_]function)(%f[%A])%s+([%a_][%w_]*)", ColorFunctions)
            lineSegments[i] = lineSegments[i]:gsub("(%f[%w_.-])([%w_.-]+)(%f[%W])", AddColors)
        end

        if (lines.endsInLongString[whichTab][codeLineNumber] == true) ~= (inMultilineString == true) then
            lines.endsInLongString[whichTab][codeLineNumber] = inMultilineString
            if codeLineNumber + 1 <= highestNonEmptyLine[whichTab][step[whichTab]] then
                coloredCodeLines[whichTab][step[whichTab]][codeLineNumber + 1] = nil
                if codeLineNumber + 1 - tabs.lineNumberOffset[whichTab] >= 1 and codeLineNumber + 1 - tabs.lineNumberOffset[whichTab] <= editor.MAX_LINES_ON_SCREEN then
                    RenderLine(codeLineNumber + 1 - tabs.lineNumberOffset[whichTab], codeLines[whichTab][step[whichTab]][codeLineNumber + 1], coloredCodeLines[whichTab][step[whichTab]][codeLineNumber + 1])
                end
            end
        elseif (lines.endsInLongComment[whichTab][codeLineNumber] == true) ~= (endsInLongComment == true) or (lines.endsInLongComment[whichTab][codeLineNumber] and oldEqualSigns ~= lines.numEqualSigns[codeLineNumber]) then
            lines.endsInLongComment[whichTab][codeLineNumber] = endsInLongComment
            if codeLineNumber + 1 <= highestNonEmptyLine[whichTab][step[whichTab]] then
                coloredCodeLines[whichTab][step[whichTab]][codeLineNumber + 1] = nil
                if codeLineNumber + 1 - tabs.lineNumberOffset[whichTab] >= 1 and codeLineNumber + 1 - tabs.lineNumberOffset[whichTab] <= editor.MAX_LINES_ON_SCREEN then
                    RenderLine(codeLineNumber + 1 - tabs.lineNumberOffset[whichTab], codeLines[whichTab][step[whichTab]][codeLineNumber + 1], coloredCodeLines[whichTab][step[whichTab]][codeLineNumber + 1])
                end
            end
        end

        return (table.concat(lineSegments) .. commentStr)
    end

    RenderLine = function(screenLineNumber, code, coloredCode)
        coloredCode = coloredCode or GetColoredText(code, screenLineNumber + tabs.lineNumberOffset[currentTab], currentTab)
        local totalLength = #coloredCode
        local maxLength = editor.isExpanded and editor.CHARS_ON_SCREEN_EXPANDED or editor.CHARS_ON_SCREEN_COLLAPSED
        if totalLength < maxLength and tabs.horizontalOffset[currentTab] == 0 then
            BlzFrameSetText(codeLineFrames[screenLineNumber], coloredCode)
        elseif tabs.horizontalOffset[currentTab] >= #code then
            BlzFrameSetText(codeLineFrames[screenLineNumber], "")
        else
            local len = 1
            local firstCharacter = tabs.horizontalOffset[currentTab] + 1
            local lastCharacter = maxLength + tabs.horizontalOffset[currentTab]
            local isScrolled = tabs.horizontalOffset[currentTab] > 0
            local i = 1
            local char = sub(coloredCode, i, i)
            local currentColor
            local beginningColor = ""
            local startCharPos = 1
            local stopCharPos
            while i <= totalLength do
                if char == "|" then
                    if currentColor then
                        if find(sub(coloredCode, i, i + 1), "|[rR]") then
                            currentColor = nil
                            i = i + 2
                        else
                            len = len + 1
                            i = i + 1
                            if sub(coloredCode, i, i) == "|" then
                                i = i + 1
                            end
                        end
                    elseif find(sub(coloredCode, i, i + 1), "|[cC]") then
                        currentColor = sub(coloredCode, i, i + 9)
                        i = i + 10
                    else
                        len = len + 1
                        i = i + 1
                        if sub(coloredCode, i, i) == "|" then
                            i = i + 1
                        end
                    end
                else
                    len = len + 1
                    i = i + 1
                end
                char = sub(coloredCode, i, i)
                if isScrolled and len == firstCharacter and (char ~= "|" or sub(coloredCode, i, i + 1) == "||") then
                    startCharPos = i
                    if currentColor then
                        beginningColor = currentColor
                    end
                end
                if len == lastCharacter and (char ~= "|" or sub(coloredCode, i, i + 1) == "||") then
                    stopCharPos = i
                    break
                end
            end

            if currentColor then
                BlzFrameSetText(codeLineFrames[screenLineNumber], beginningColor .. sub(coloredCode, startCharPos, stopCharPos) .. "|r")
            else
                BlzFrameSetText(codeLineFrames[screenLineNumber], beginningColor .. sub(coloredCode, startCharPos, stopCharPos))
            end
        end
    end

    local function UpdateAllLines()
        local currentLines = codeLines[currentTab][step[currentTab]]
        local currentColoredLines = coloredCodeLines[currentTab][step[currentTab]]
        for i = 1, editor.MAX_LINES_ON_SCREEN do
            RenderLine(i, currentLines[i + tabs.lineNumberOffset[currentTab]], currentColoredLines[i + tabs.lineNumberOffset[currentTab]])
        end

        local currentLines = codeLines[currentTab][step[currentTab]]
        for i = highestNonEmptyLine[currentTab][step[currentTab]], 0, -1 do
            if currentLines[i] ~= "" then
                highestNonEmptyLine[currentTab][step[currentTab]] = i
                BlzFrameSetMinMaxValue(codeScroller, 0, i)
                return
            end
        end
        highestNonEmptyLine[currentTab][step[currentTab]] = 0
        BlzFrameSetMinMaxValue(codeScroller, 0, 0)
    end

    local function SetLocalList(lineNumber)
        local str, vars, varName
        localLookupTable = {}
        local varDefLevels = {}
        local level = 0
        local isLocal, isAssignment, isFunctionDef
        local lines = codeLines[currentTab][step[currentTab]]

        for i = 1, lineNumber - 1 do
            str = lines[i]:gsub("'([^']+)'", ""):gsub('"([^"]+)"', "") --Remove string literals.

            isFunctionDef = find(str, "%f[%w_]function%f[^%w_]")

            if isFunctionDef or find(str, "%f[%w_]do%f[^%w_]") or find(str, "%f[%w_]if%f[^%w_]") or find(str, "%f[%w_]for%f[^%w_]") or find(str, "%f[%w_]while%f[^%w_]") or find(str, "%f[%w_]repeat%f[^%w_]") then
                level = level + 1
            end

            if isFunctionDef then
                vars = str:match("%((.+)%)") or "" --Get function arguments.
                vars = vars:gsub(" ", "")

                local pos = find(vars, ",")
                while pos do
                    varName = sub(vars, 1, pos - 1)
                    vars = sub(vars, pos + 1)
                    if not localLookupTable[varName] and not globalLookupTable[varName] then
                        localLookupTable[#localLookupTable + 1] = varName
                        localLookupTable[varName] = true
                        varDefLevels[#varDefLevels + 1] = level
                    end
                    pos = find(vars, ",")
                end
                if not localLookupTable[vars] and not globalLookupTable[vars] then
                    localLookupTable[#localLookupTable + 1] = vars
                    localLookupTable[vars] = true
                    varDefLevels[#varDefLevels + 1] = level
                end

                isLocal = find(str, "^%s*local ")
                isAssignment = find(str, "[^=<>~]=[^=<>~]") --single equal sign, not <= etc.
                if isAssignment then
                    vars = str:match("([%w_]+)%s*=") --name before equal sign
                else
                    vars = str:match("([%w_]+)%s*%(") --name before opening parenthesis
                end
                if vars and not localLookupTable[vars] and not globalLookupTable[vars] then
                    localLookupTable[#localLookupTable + 1] = vars
                    localLookupTable[vars] = true
                    varDefLevels[#varDefLevels + 1] = isLocal and level or -1
                end
            else
                isLocal = find(str, "^%s*local ")
                isAssignment = find(str, "[^=<>~]=[^=<>~]") --single equal sign, not <= etc.
                if isLocal or isAssignment then
                    if isLocal then
                        if isAssignment then
                            vars = str:match("local%s*(.+)="):gsub(" ", "") --Between local and =
                        else
                            vars = str:match("local%s*(.+)"):gsub(" ", "") --everthing after local
                        end
                    else
                        vars = str:match("(.+)="):gsub(" ", "")
                    end

                    if not find(vars, "%.") and not find(vars, "%[") then --ignore table assignments
                        local pos = find(vars, ",")
                        --Separate variable names by commas
                        while pos do
                            varName = sub(vars, 1, pos - 1)
                            vars = sub(vars, pos + 1)
                            if not localLookupTable[varName] and not globalLookupTable[varName] then
                                localLookupTable[#localLookupTable + 1] = varName
                                localLookupTable[varName] = true
                                varDefLevels[#varDefLevels + 1] = isLocal and level or -1
                            end
                            pos = find(vars, ",")
                        end
                        if not localLookupTable[vars] and not globalLookupTable[vars] then
                            localLookupTable[#localLookupTable + 1] = vars
                            localLookupTable[vars] = true
                            varDefLevels[#varDefLevels + 1] = isLocal and level or -1
                        end
                    end
                end
            end

            if find(str, "%f[%w_]end%f[^%w_]") or find(str, "%f[%w_]until%f[^%w_]") then
                for j = 1, #varDefLevels do
                    if varDefLevels[j] == level then
                        localLookupTable[localLookupTable[j]] = nil
                        localLookupTable[j] = localLookupTable[#localLookupTable]
                        localLookupTable[#localLookupTable] = nil
                        varDefLevels[j] = varDefLevels[#varDefLevels]
                        varDefLevels[#varDefLevels] = nil
                    end
                end
                level = level - 1
            end
        end

        table.sort(localLookupTable)
    end

    local function GetCursorPos(xs, ys)
        local lineNumber = math.floor(((editor.Y_TOP - editor.CODE_TOP_INSET) - ys)/editor.LINE_SPACING) + 1

        if lineNumber >= 1 and lineNumber <= editor.MAX_LINES_ON_SCREEN then
            local dx = editor.isExpanded and xs - (editor.EXPANDED_X + editor.CODE_LEFT_INSET) or xs - (editor.COLLAPSED_X + editor.CODE_LEFT_INSET)

            if dx < editor.STOP_BUTTON_HORIZONTAL_INSET + editor.LINE_SPACING - editor.CODE_LEFT_INSET then
                return lineNumber, -1, nil
            elseif dx > (editor.isExpanded and editor.EXPANDED_WIDTH - (editor.CODE_LEFT_INSET + editor.CODE_RIGHT_INSET) or editor.COLLAPSED_WIDTH - (editor.CODE_LEFT_INSET + editor.CODE_RIGHT_INSET)) then
                return lineNumber, math.huge, nil
            end

            local text = sub(codeLines[currentTab][step[currentTab]][lineNumber + tabs.lineNumberOffset[currentTab]], tabs.horizontalOffset[currentTab] + 1)

            if #text == 0 then
                return lineNumber, 0, 0
            end

            local testPos = 0
            local width = 0
            while width < dx do
                testPos = testPos + 1
                width = GetTextWidth(sub(text, 1, testPos))
                if testPos == #text then
                    break
                end
            end
            testPos = testPos - 1

            local diff1 = math.abs(GetTextWidth(sub(text, 1, testPos)) - dx)
            local diff2 = math.abs(GetTextWidth(sub(text, 1, testPos + 1)) - dx)
            if diff2 < diff1 then
                testPos = testPos + 1
            end
            width = GetTextWidth(sub(text, 1, testPos))

            return lineNumber, testPos + tabs.horizontalOffset[currentTab], width
        elseif lineNumber < 1 then
            return -1, nil, nil
        else
            return math.huge, nil, nil
        end
    end

    SetSelection = function()
        local lower = max(selection.startLine, selection.endLine) - tabs.lineNumberOffset[currentTab]
        local upper = min(selection.startLine, selection.endLine) - tabs.lineNumberOffset[currentTab]
        local currentLines = codeLines[currentTab][step[currentTab]]
        local offset = tabs.horizontalOffset[currentTab]
        local limit = editor.isExpanded and editor.CHARS_ON_SCREEN_EXPANDED or editor.CHARS_ON_SCREEN_COLLAPSED

        local j
        for i = 1, editor.MAX_LINES_ON_SCREEN do
            j = i + tabs.lineNumberOffset[currentTab]
            if i > lower or i < upper then
                if selection.lines[i] then
                    ReturnTextHighlightFrame(selection.lines[i])
                    selection.lines[i] = nil
                end
            else
                selection.lines[i] = selection.lines[i] or GetTextHighlightFrame("09", 150, "selection")
                if lower == upper then
                    if selection.endPos < selection.startPos then
                        BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[j], offset + 1, min(selection.endPos, offset + limit))), -editor.CODE_TOP_INSET - i*editor.LINE_SPACING)
                        BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[j], offset + 1, min(selection.startPos, offset + limit))), -editor.CODE_TOP_INSET - (i - 1)*editor.LINE_SPACING)
                    else
                        BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[j], offset + 1, min(selection.startPos, offset + limit))), -editor.CODE_TOP_INSET - i*editor.LINE_SPACING)
                        BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[j], offset + 1, min(selection.endPos, offset + limit))), -editor.CODE_TOP_INSET - (i - 1)*editor.LINE_SPACING)
                    end
                elseif i == lower then
                    if lower == selection.endLine - tabs.lineNumberOffset[currentTab] then
                        BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET, -editor.CODE_TOP_INSET - i*editor.LINE_SPACING)
                        BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[j], offset + 1, min(selection.endPos, offset + limit))), -editor.CODE_TOP_INSET - (i - 1)*editor.LINE_SPACING)
                    else
                        BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET, -editor.CODE_TOP_INSET - i*editor.LINE_SPACING)
                        BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[j], offset + 1, min(selection.startPos, offset + limit))), -editor.CODE_TOP_INSET - (i - 1)*editor.LINE_SPACING)
                    end
                elseif i == upper then
                    if upper == selection.endLine - tabs.lineNumberOffset[currentTab] then
                        BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[j], offset + 1, min(selection.endPos, offset + limit))), -editor.CODE_TOP_INSET - i*editor.LINE_SPACING)
                        BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[j], offset + 1, offset + limit)), -editor.CODE_TOP_INSET - (i - 1)*editor.LINE_SPACING)
                    else
                        BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[j], offset + 1, min(selection.startPos, offset + limit))), -editor.CODE_TOP_INSET - i*editor.LINE_SPACING)
                        BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[j], offset + 1, offset + limit)), -editor.CODE_TOP_INSET - (i - 1)*editor.LINE_SPACING)
                    end
                else
                    BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET, -editor.CODE_TOP_INSET - i*editor.LINE_SPACING)
                    BlzFrameSetPoint(selection.lines[i], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[j], offset + 1, offset + limit)), -editor.CODE_TOP_INSET - (i - 1)*editor.LINE_SPACING)
                end
            end
        end

        if lower == upper and selection.startPos ~= selection.endPos then
            SearchForDuplicates()
        else
            RemoveDuplicates()
        end
    end

    HideSelection = function()
        if selection.hasSelection then
            for i = 1, editor.MAX_LINES_ON_SCREEN do
                if selection.lines[i] then
                    ReturnTextHighlightFrame(selection.lines[i])
                    selection.lines[i] = nil
                end
            end
            RemoveDuplicates()
        end
    end

    local function OnMousePeriodic()
        local x, y = GetMouseScreenCoordinates()
        if x ~= WSDebug.Mouse.x or y ~= WSDebug.Mouse.y then
            WSDebug.Mouse.x = x
            WSDebug.Mouse.y = y
            WSDebug.Mouse.lastMove = timeElapsed
            cursor.checkedForVariableDisplay = false
            if cursor.isShowingVariableTooltip then
                BlzFrameSetVisible(helper.parent, false)
                cursor.isShowingVariableTooltip = false
            end
        end

        if not WSDebug.Mouse.leftButtonIsPressed then
            return
        end

        if dragWindow.isDragging then
            local dx = x - dragWindow.mouseX
            local dy = y - dragWindow.mouseY
            dragWindow.mouseX = x
            dragWindow.mouseY = y
            editor.COLLAPSED_X = editor.COLLAPSED_X + dx
            editor.EXPANDED_X = editor.EXPANDED_X + dx
            editor.Y_TOP = editor.Y_TOP + dy
            if editor.isExpanded then
                BlzFrameSetAbsPoint(codeEditorParent, FRAMEPOINT_TOPLEFT, editor.EXPANDED_X, editor.Y_TOP)
            else
                BlzFrameSetAbsPoint(codeEditorParent, FRAMEPOINT_TOPLEFT, editor.COLLAPSED_X, editor.Y_TOP)
            end
            return
        end

        local line, pos = GetCursorPos(x, y)
        local currentLines = codeLines[currentTab][step[currentTab]]

        if line == -1 then
            line = 1
            pos = 0
        elseif line == math.huge then
            line = editor.MAX_LINES_ON_SCREEN
            pos = #currentLines[line + tabs.lineNumberOffset[currentTab]]
        end
        if pos == -1 then
            pos = 0
        elseif pos == math.huge then
            pos = #currentLines[line + tabs.lineNumberOffset[currentTab]]
        end

        if line == (selection.endLine - tabs.lineNumberOffset[currentTab]) and pos == selection.endPos then
            return
        end

        local currentEndLine = selection.endLine

        selection.endLine = line + tabs.lineNumberOffset[currentTab]
        selection.endPos = pos
        selection.hasSelection = true

        if selection.endLine ~= currentEndLine then
            local len = #codeLines[currentTab][step[currentTab]][selection.endLine]
            if len < tabs.horizontalOffset[currentTab] then
                BlzFrameSetValue(codeHorizontalScroller, len)
            end
        end

        cursor.codeLineNumber = selection.endLine
        cursor.screenLineNumber = line
        SetCursorPos(pos)
        SetCursorX(sub(codeLines[currentTab][step[currentTab]][cursor.codeLineNumber], tabs.horizontalOffset[currentTab] + 1, pos))

        SetSelection()
    end

    local function OnMouseRelease()
        WSDebug.Mouse.leftButtonIsPressed = false
    end

    local function DefocusCodeEditor()
        BlzFrameSetFocus(editBox, false)
        BlzFrameSetEnable(editBox, false)
        BlzFrameSetEnable(editBox, true)
        BlzFrameSetFocus(searchBar.textField, false)
        if editBoxFocused then
            editBoxFocused = false
            editor.ON_DEFOCUS()
        end
        BlzFrameSetVisible(cursorFrame, false)
        BlzFrameSetVisible(brackets.highlights[1], false)
        BlzFrameSetVisible(brackets.highlights[2], false)
        brackets.lines[1] = nil
        brackets.lines[2] = nil
    end

    local function MoveCursor(pos, line, xc, shiftIsPressed)
        cursor.codeLineNumber = line + tabs.lineNumberOffset[currentTab]
        cursor.screenLineNumber = line
        SetCursorPos(pos)
        cursor.x = xc
        cursorCounter = 0
        if not editBoxFocused then
            editBoxFocused = true
            editor.ON_FOCUS()
        end
        BlzFrameSetVisible(cursorFrame, true)
        BlzFrameSetPoint(cursorFrame, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + cursor.x, -editor.CODE_TOP_INSET - cursor.screenLineNumber*editor.LINE_SPACING)
        editBoxText = " "
        BlzFrameSetText(editBox, " ")
        SetLocalList(cursor.codeLineNumber)

        if shiftIsPressed then
            selection.endLine = cursor.codeLineNumber
            selection.endPos = pos
            selection.hasSelection = true
            SetSelection()
        else
            selection.startLine = cursor.codeLineNumber
            selection.endLine = cursor.codeLineNumber
            selection.startPos = cursor.pos
            selection.endPos = cursor.pos
        end
    end

    local function OnMouseLeftClick()
        if not BlzFrameIsVisible(codeEditorParent) then
            return
        end

        if BlzFrameIsVisible(nameDialog.parent) then
            DefocusCodeEditor()
            return
        end

        if editor.isLocked then
            return
        end

        if WSDebug.Mouse.ignoreClickUntil > timeElapsed then
            return
        end

        cursor.posOfLineJumps = nil

        local x, y = GetMouseScreenCoordinates()

        --Check if click is over one of the popup menus.
        if BlzFrameIsVisible(helper.parent) and helper.numSuggestionsVisible > 0 then
            if x > helper.minX and x < helper.maxX and y > helper.minY and y < helper.maxY then
                DefocusCodeEditor()
                BlzFrameSetFocus(searchBar.textField, false)
                return
            end
        end

        BlzFrameSetVisible(helper.parent, false)

        if BlzFrameIsVisible(flags.parent) then
            if x > (editor.isExpanded and editor.EXPANDED_X + editor.EXPANDED_WIDTH/2 + flags.minX or editor.COLLAPSED_X + editor.COLLAPSED_WIDTH/2 + flags.minX)
            and x < (editor.isExpanded and editor.EXPANDED_X + editor.EXPANDED_WIDTH/2 + flags.maxX or editor.COLLAPSED_X + editor.COLLAPSED_WIDTH/2 + flags.maxX)
            and y < flags.maxY then
                DefocusCodeEditor()
                BlzFrameSetFocus(searchBar.textField, false)
                return
            else
                BlzFrameSetVisible(flags.parent, false)
            end
        end
        if BlzFrameIsVisible(clearMenu.parent) then
            if x > (editor.isExpanded and editor.EXPANDED_X + editor.EXPANDED_WIDTH/2 + clearMenu.minX or editor.COLLAPSED_X + editor.COLLAPSED_WIDTH/2 + clearMenu.minX)
            and x < (editor.isExpanded and editor.EXPANDED_X + editor.EXPANDED_WIDTH/2 + clearMenu.maxX or editor.COLLAPSED_X + editor.COLLAPSED_WIDTH/2 + clearMenu.maxX)
            and y < clearMenu.maxY then
                DefocusCodeEditor()
                BlzFrameSetFocus(searchBar.textField, false)
                return
            else
                BlzFrameSetVisible(clearMenu.parent, false)
            end
        end
        for __, buttonData in ipairs(buttons.customArrayButtons) do
            if BlzFrameIsVisible(buttonData.parent) then
                if x > (editor.isExpanded and editor.EXPANDED_X + editor.EXPANDED_WIDTH/2 + buttonData.minX or editor.COLLAPSED_X + editor.COLLAPSED_WIDTH/2 + buttonData.minX)
                and x < (editor.isExpanded and editor.EXPANDED_X + editor.EXPANDED_WIDTH/2 + buttonData.maxX or editor.COLLAPSED_X + editor.COLLAPSED_WIDTH/2 + buttonData.maxX)
                and y < buttonData.maxY then
                    DefocusCodeEditor()
                    BlzFrameSetFocus(searchBar.textField, false)
                    return
                else
                    for __, subButtonData in ipairs(buttons.subArrayButtons[buttonData.parent]) do
                        if BlzFrameIsVisible(subButtonData.parent) then
                            if x > (editor.isExpanded and editor.EXPANDED_X + editor.EXPANDED_WIDTH/2 + subButtonData.minX or editor.COLLAPSED_X + editor.COLLAPSED_WIDTH/2 + subButtonData.minX)
                            and x < (editor.isExpanded and editor.EXPANDED_X + editor.EXPANDED_WIDTH/2 + subButtonData.maxX or editor.COLLAPSED_X + editor.COLLAPSED_WIDTH/2 + subButtonData.maxX)
                            and y < subButtonData.maxY then
                                DefocusCodeEditor()
                                BlzFrameSetFocus(searchBar.textField, false)
                                return
                            end
                        end
                    end
                    BlzFrameSetVisible(buttonData.parent, false)
                    for __, subButtonData in ipairs(buttons.subArrayButtons[buttonData.parent]) do
                        BlzFrameSetVisible(subButtonData.parent, false)
                    end
                end
            end
        end

        if BlzFrameIsVisible(contextMenu.parent) then
            if x > contextMenu.minX and x < contextMenu.maxX and y > contextMenu.minY and y < contextMenu.maxY then
                DefocusCodeEditor()
                BlzFrameSetFocus(searchBar.textField, false)
                return
            else
                BlzFrameSetVisible(contextMenu.parent, false)
            end
        end

        if BlzFrameIsVisible(tabMenu.parent) then
            if x > tabMenu.minX and x < tabMenu.maxX and y > tabMenu.minY and y < tabMenu.maxY then
                DefocusCodeEditor()
                BlzFrameSetFocus(searchBar.textField, false)
                return
            else
                BlzFrameSetVisible(tabMenu.parent, false)
            end
        end

        if BlzFrameIsVisible(searchBar.parent) then
            local dx = x - (editor.isExpanded and editor.EXPANDED_X + editor.EXPANDED_WIDTH - searchBar.HORIZONTAL_INSET - searchBar.WIDTH or editor.COLLAPSED_X + editor.COLLAPSED_WIDTH - searchBar.HORIZONTAL_INSET - searchBar.WIDTH)
            local dy = y - (editor.Y_TOP - searchBar.VERTICAL_INSET - searchBar.HEIGHT)
            if dx > 0 and dx < searchBar.WIDTH and dy > 0 and dy < searchBar.HEIGHT then
                if editBoxFocused and selection.hasSelection and selection.startLine == selection.endLine
                and dx > searchBar.SEARCH_FIELD_LEFT_INSET and dx < searchBar.WIDTH - searchBar.SEARCH_FIELD_RIGHT_INSET
                and dy > searchBar.SEARCH_FIELD_BOTTOM_INSET and dy < searchBar.HEIGHT - searchBar.SEARCH_FIELD_TOP_INSET then
                    local text = sub(codeLines[currentTab][step[currentTab]][selection.startLine], min(selection.startPos, selection.endPos) + 1, max(selection.startPos, selection.endPos))
                    BlzFrameSetText(searchBar.textField, text)
                end
                DefocusCodeEditor()
                return
            end
        else
            BlzFrameSetFocus(searchBar.textField, false)
        end

        --Click is over drag-window (Warcraft Studio Code text)
        if x > (editor.isExpanded and (editor.EXPANDED_X + editor.EXPANDED_WIDTH/2) or (editor.COLLAPSED_X + editor.COLLAPSED_WIDTH/2)) - dragWindow.WIDTH/2
        and x < (editor.isExpanded and (editor.EXPANDED_X + editor.EXPANDED_WIDTH/2) or (editor.COLLAPSED_X + editor.COLLAPSED_WIDTH/2)) + dragWindow.WIDTH/2
        and y < editor.Y_TOP - dragWindow.TOP_INSET and y > editor.Y_TOP - editor.CODE_TOP_INSET then
            dragWindow.isDragging = true
            WSDebug.Mouse.leftButtonIsPressed = true
            dragWindow.mouseX = x
            dragWindow.mouseY = y
        else
            dragWindow.isDragging = false
        end

        local screenLine, pos, xc = GetCursorPos(x, y)
        if xc then
            HideSelection()
            selection.hasSelection = false

            local diff = timeElapsed - WSDebug.Mouse.lastClick
            WSDebug.Mouse.lastClick = timeElapsed

            if diff < 0.35 and cursor.pos == pos and cursor.screenLineNumber == screenLine then
                --Double click
                local text = codeLines[currentTab][step[currentTab]][screenLine + tabs.lineNumberOffset[currentTab]]
                local char = sub(text, pos, pos)
                if char == "" then
                    return
                end

                --Get bounds of token being selected
                local first, last = pos, pos
                if char:match("[%w_]") then
                    while sub(text, first, first):match("[%w_]") do
                        first = first - 1
                    end
                    while sub(text, last + 1, last + 1):match("[%w_]") do
                        last = last + 1
                    end
                elseif char == " " then
                    while sub(text, first, first) == " " do
                        first = first - 1
                    end
                    while sub(text, last + 1, last + 1) == " " do
                        last = last + 1
                    end
                else
                    while sub(text, first, first):match("[%w%s_]") == nil and first > 0 do
                        first = first - 1
                    end
                    while sub(text, last + 1, last + 1):match("[%w%s_]") == nil and last < #text do
                        last = last + 1
                    end
                end

                selection.startLine = cursor.codeLineNumber
                selection.endLine = cursor.codeLineNumber

                selection.startPos = first
                selection.endPos = last
                selection.hasSelection = true
                selection.lines[cursor.screenLineNumber] = GetTextHighlightFrame("09", 150, "selection")
                BlzFrameSetPoint(selection.lines[cursor.screenLineNumber], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(text, tabs.horizontalOffset[currentTab] + 1, first)), -editor.CODE_TOP_INSET - cursor.screenLineNumber*editor.LINE_SPACING)
                BlzFrameSetPoint(selection.lines[cursor.screenLineNumber], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(text, tabs.horizontalOffset[currentTab] + 1, last)), -editor.CODE_TOP_INSET - (cursor.screenLineNumber - 1)*editor.LINE_SPACING)

                SetCursorPos(last)
                SetCursorX(sub(codeLines[currentTab][step[currentTab]][cursor.codeLineNumber], tabs.horizontalOffset[currentTab] + 1, cursor.pos))

                SearchForDuplicates()
            else
                MoveCursor(pos, screenLine, xc, BlzIsMetaKeyPressed(METAKEY_SHIFT))
                WSDebug.Mouse.leftButtonIsPressed = true

                if #codeLines[currentTab][step[currentTab]][screenLine + tabs.lineNumberOffset[currentTab]] < tabs.horizontalOffset[currentTab] then
                    BlzFrameSetValue(codeHorizontalScroller, #codeLines[currentTab][step[currentTab]][screenLine + tabs.lineNumberOffset[currentTab]])
                end
            end
        else
            --If mouse is not over the scroller.
            if not (((editor.isExpanded and x >= editor.EXPANDED_X + editor.EXPANDED_WIDTH - editor.CODE_SCROLLER_HORIZONTAL_INSET - 0.006
            and x <= editor.EXPANDED_X + editor.EXPANDED_WIDTH - editor.CODE_SCROLLER_HORIZONTAL_INSET + 0.006)
            or (not editor.isExpanded and x >= editor.COLLAPSED_X + editor.COLLAPSED_WIDTH - editor.CODE_SCROLLER_HORIZONTAL_INSET - 0.006
            and x <= editor.COLLAPSED_X + editor.COLLAPSED_WIDTH - editor.CODE_SCROLLER_HORIZONTAL_INSET + 0.006))
            and y <= editor.Y_TOP - editor.CODE_TOP_INSET and y >= editor.Y_TOP - editor.CODE_TOP_INSET - editor.MAX_LINES_ON_SCREEN*editor.LINE_SPACING)
            --And is not over the horizontal scroller.
            and not (((editor.isExpanded and x >= editor.EXPANDED_X + editor.CODE_HORIZONTAL_SCROLLER_LEFT_INSET
            and x <= editor.EXPANDED_X + editor.EXPANDED_WIDTH - editor.CODE_HORIZONTAL_SCROLLER_RIGHT_INSET)
            or (not editor.isExpanded and x >= editor.COLLAPSED_X + editor.CODE_HORIZONTAL_SCROLLER_LEFT_INSET
            and x <= editor.COLLAPSED_X + editor.COLLAPSED_WIDTH - editor.CODE_HORIZONTAL_SCROLLER_RIGHT_INSET))
            and y <= editor.Y_TOP - editor.CODE_TOP_INSET - editor.CODE_BOTTOM_INSET - editor.MAX_LINES_ON_SCREEN*editor.LINE_SPACING + editor.CODE_HORIZONTAL_SCROLLER_VERTICAL_INSET + editor.CODE_HORIZONTAL_SCROLLER_HEIGHT
            and y >= editor.Y_TOP - editor.CODE_TOP_INSET - editor.CODE_BOTTOM_INSET - editor.MAX_LINES_ON_SCREEN*editor.LINE_SPACING + editor.CODE_HORIZONTAL_SCROLLER_VERTICAL_INSET) then
                DefocusCodeEditor()
                BlzFrameSetEnable(searchBar.textField, false)
                BlzFrameSetEnable(searchBar.textField, true)
            end
        end
    end

    local function PutStop(lineNumber, injectEval, whichTab)
        local currentLines = codeLines[whichTab][step[whichTab]]
        local hasWarning

        if not compiler.WRAP_ALL_LUA_ENTRY_POINTS then
            WSDebug.PrintForUser("|cffff5555ERROR: WRAP_ALL_LUA_ENTRY_POINTS must be enabled for breakpoints to be used.")
            PlayError()
            return
        end

        if lineNumber > highestNonEmptyLine[whichTab][step[whichTab]] and lines.debugState[whichTab][lineNumber] == 0 then
            PlayError()
            return
        end

        doNotUpdateVariables[whichTab] = false

        if lines.debugState[whichTab][lineNumber] == 0 then
            if find(currentLines[lineNumber], "^%s*$") ~= nil or find(currentLines[lineNumber], "^%s*do%s*$") ~= nil then
                hasWarning = true
            elseif find(currentLines[lineNumber], "%f[%a_]end%f[^%w_]") ~= nil then
                --Stop cannot be put on an end token if the previous line contains a return statement.
                if find(currentLines[lineNumber - 1], "%f[%a_]return%f[^%w_]") ~= nil then
                    hasWarning = true
                end
            else
                --Check if line is part of multiline function call or table def.
                local i = lineNumber - 1
                local level = 0
                local numRoundBrackets = 0
                local numSquareBrackets = 0
                local numCurlyBrackets = 0
                repeat
                    local line = currentLines[i]
                    line = line:gsub('"[^"]*"', "")
                    line = line:gsub("'[^']*'", "")
                    if find(line, "%f[%a_]for%f[^%w_]") ~= nil
                    or find(line, "%f[%a_]do%f[^%w_]") ~= nil
                    or find(line, "%f[%a_]if%f[^%w_]") ~= nil
                    or find(line, "%f[%a_]function%f[^%w_]") then
                        level = level - 1
                    end
                    if find(line, "%f[%a_]end%f[^%w_]") ~= nil
                    or find(line, "%f[%a_]until%f[^%w_]") ~= nil then
                        level = level + 1
                    end
                    if level < 0 then
                        break
                    end
                    numRoundBrackets = numRoundBrackets + select(2, line:gsub("%(", "")) - select(2, line:gsub("%)", ""))
                    numSquareBrackets = numSquareBrackets + select(2, line:gsub("%[", "")) - select(2, line:gsub("%]", ""))
                    numCurlyBrackets = numCurlyBrackets + select(2, line:gsub("{", "")) - select(2, line:gsub("}", ""))
                    if numRoundBrackets > 0 or numSquareBrackets > 0 or numCurlyBrackets > 0 then
                        hasWarning = true
                        break
                    end
                    i = i - 1
                until i <= 0
            end

            if hasWarning then
                WSDebug.PrintForUser("|cffff0000Warning:|r Breakpoint may not be reachable.")
            end
        end

        if lines.debugState[whichTab][lineNumber] ~= 0 then
            lines.debugState[whichTab][lineNumber] = 0
            if currentTab == whichTab and lineNumber - tabs.lineNumberOffset[whichTab] >= 0 and lineNumber - tabs.lineNumberOffset[whichTab] <= editor.MAX_LINES_ON_SCREEN then
                BlzFrameSetTexture(BlzFrameGetChild(stopButtons[lineNumber - tabs.lineNumberOffset[whichTab]], 0), LINE_STATE_ICONS[lines.debugState[whichTab][lineNumber]], 0, true)
            end
        elseif injectEval then
            ClearTextMessages()
            nameDialog.state = "injecteval"
            BlzFrameSetVisible(nameDialog.parent, true)
            if editBoxFocused then
                editBoxFocused = false
                editor.ON_DEFOCUS()
            end
            BlzFrameSetFocus(editBox, false)
            BlzFrameSetEnable(editBox, false)
            BlzFrameSetEnable(editBox, true)
            BlzFrameSetFocus(nameDialog.textField, true)
            BlzFrameSetText(nameDialog.title, "|cffffcc00Enter Expression|r")
            nameDialog.injectTab = whichTab
            nameDialog.injectLineNumber = lineNumber
        else
            lines.debugState[whichTab][lineNumber] = 2
            if currentTab == whichTab and lineNumber - tabs.lineNumberOffset[whichTab] >= 0 and lineNumber - tabs.lineNumberOffset[whichTab] <= editor.MAX_LINES_ON_SCREEN then
                BlzFrameSetTexture(BlzFrameGetChild(stopButtons[lineNumber - tabs.lineNumberOffset[whichTab]], 0), LINE_STATE_ICONS[lines.debugState[whichTab][lineNumber]], 0, true)
            end
        end
    end

    local function OnMouseRightClick()
        if not BlzFrameIsVisible(codeEditorParent) then
            return
        end

        if editor.isLocked then
            return
        end

        if WSDebug.Mouse.ignoreClickUntil > timeElapsed then
            return
        end

        cursor.posOfLineJumps = nil

        BlzFrameSetVisible(helper.parent, false)

        local x, y = GetMouseScreenCoordinates()

        if (editor.isExpanded and x < editor.EXPANDED_X)
        or (not editor.isExpanded and x < editor.COLLAPSED_X)
        or y > editor.Y_TOP
        or y < editor.Y_TOP - editor.LINE_SPACING*editor.MAX_LINES_ON_SCREEN - editor.CODE_TOP_INSET - editor.CODE_BOTTOM_INSET then
            DefocusCodeEditor()
            BlzFrameSetEnable(searchBar.textField, false)
            BlzFrameSetEnable(searchBar.textField, true)
        end

        --Right-click over stop button.
        if (editor.isExpanded and x >= editor.EXPANDED_X + editor.STOP_BUTTON_HORIZONTAL_INSET
        and x <= editor.EXPANDED_X + editor.STOP_BUTTON_HORIZONTAL_INSET + editor.LINE_SPACING)
        or (not editor.isExpanded and x >= editor.COLLAPSED_X + editor.STOP_BUTTON_HORIZONTAL_INSET
        and x <= editor.COLLAPSED_X + editor.STOP_BUTTON_HORIZONTAL_INSET + editor.LINE_SPACING) then
            local lineNumber = math.floor(((editor.Y_TOP - editor.CODE_TOP_INSET) - y)/editor.LINE_SPACING) + 1

            if lineNumber >= 1 and lineNumber <= editor.MAX_LINES_ON_SCREEN then
                PutStop(lineNumber + tabs.lineNumberOffset[currentTab], true, currentTab)
            end

            BlzFrameSetVisible(contextMenu.parent, false)
            BlzFrameSetVisible(tabMenu.parent, false)

        --Right-click to open tab menu.
        elseif ((editor.isExpanded and x >= editor.EXPANDED_X
        and x <= editor.EXPANDED_X + editor.EXPANDED_WIDTH)
        or (not editor.isExpanded and x >= editor.COLLAPSED_X
        and x <= editor.COLLAPSED_X + editor.COLLAPSED_WIDTH))
        and y > editor.Y_TOP
        and y < editor.Y_TOP + tabNavigator.HEIGHT - tabNavigator.CLICK_BOX_INSET then
            local spaceRequired = 0
            for i = 1, tabs.amount do
                spaceRequired = spaceRequired + tabNavigator.widths[tabs.names[i]]
            end

            local r = (editor.isExpanded and x - editor.EXPANDED_X) or (not editor.isExpanded and x - editor.COLLAPSED_X)
            local t = 0

            local spaceAlloted = (editor.isExpanded and editor.EXPANDED_WIDTH or editor.COLLAPSED_WIDTH) + tabs.amount*tabNavigator.OVERLAP - tabNavigator.HEIGHT
            for i = 1, tabs.amount do
                t = t + tabNavigator.widths[tabs.names[i]]*(spaceRequired > spaceAlloted and spaceAlloted/spaceRequired or 1) - tabNavigator.OVERLAP
                if t > r then
                    tabMenu.clickedTab = tabs.names[i]
                    break
                end
            end

            if not tabMenu.clickedTab then
                return
            end

            BlzFrameSetVisible(tabMenu.parent, true)
            BlzFrameClearAllPoints(tabMenu.parent)

            y = editor.Y_TOP
            if x > 0.9333 - flagsMenu.WIDTH then
                --Left of mouse
                tabMenu.minX = x - flagsMenu.WIDTH
                tabMenu.maxX = x
                BlzFrameSetAbsPoint(tabMenu.parent, FRAMEPOINT_TOPRIGHT, x, y)
            else
                --Right of mouse
                tabMenu.minX = x
                tabMenu.maxX = x + flagsMenu.WIDTH
                BlzFrameSetAbsPoint(tabMenu.parent, FRAMEPOINT_TOPLEFT, x, y)
            end
            tabMenu.minY = y - (tabMenu.NUM_DEFAULT_BUTTONS*editor.LINE_SPACING + 2*flagsMenu.TEXT_INSET)
            tabMenu.maxY = y

            BlzFrameSetSize(tabMenu.parent, flagsMenu.WIDTH, 2*flagsMenu.TEXT_INSET + tabMenu.NUM_DEFAULT_BUTTONS*editor.LINE_SPACING)
            BlzFrameSetText(BlzFrameGetChild(tabMenu.breakCondition, 0), breakCondition[tabMenu.clickedTab] and "|cffffcc00Break Condition|r" or "|cffaaaaaaBreak Condition|r")
            BlzFrameSetText(BlzFrameGetChild(tabMenu.breakEverywhere, 0), breakEverywhere[tabMenu.clickedTab] and "|cffffcc00Break Everywhere|r" or "|cffaaaaaaBreak Everywhere|r")
            BlzFrameSetText(BlzFrameGetChild(tabMenu.breakNowhere, 0), tabs.breakNowhere[tabMenu.clickedTab] and "|cffffcc00Break Nowhere|r" or "|cffaaaaaaBreak Nowhere|r")
            BlzFrameSetText(BlzFrameGetChild(tabMenu.breakOnlyHere, 0), (breakOnlyHere == tabMenu.clickedTab) and "|cffffcc00Break Only Here|r" or "|cffaaaaaaBreak Only Here|r")

            BlzFrameSetVisible(contextMenu.parent, false)

        --Right-click to open context menu.
        elseif (editor.isExpanded and x >= editor.EXPANDED_X + editor.CODE_LEFT_INSET
        and x <= editor.EXPANDED_X + editor.EXPANDED_WIDTH - editor.CODE_RIGHT_INSET)
        or (not editor.isExpanded and x >= editor.COLLAPSED_X + editor.CODE_LEFT_INSET
        and x <= editor.COLLAPSED_X + editor.COLLAPSED_WIDTH - editor.CODE_RIGHT_INSET) then

            BlzFrameSetVisible(tabMenu.parent, false)

            local line, pos, xc = GetCursorPos(x, y)
            if line >= 1 and line <= editor.MAX_LINES_ON_SCREEN then
                if not selection.hasSelection then
                    MoveCursor(pos, line, xc)
                end
                BlzFrameSetVisible(contextMenu.parent, true)

                local selectedText = sub(codeLines[currentTab][step[currentTab]][selection.startLine], min(selection.startPos + 1, selection.endPos), max(selection.startPos + 1, selection.endPos)):gsub("^%s*", ""):gsub("%s*$", "")

                if selection.hasSelection and selection.startLine == selection.endLine then
                    if match(selectedText, "^[%w_]+$") ~= nil and match(sub(selectedText, 1, 1), "%d") == nil and not LUA.KEYWORDS[selectedText] then
                        BlzFrameSetEnable(contextMenu.gotodef, true)
                        BlzFrameSetText(BlzFrameGetChild(contextMenu.gotodef, 0), "Go to Definition")
                    else
                        BlzFrameSetEnable(contextMenu.gotodef, false)
                        BlzFrameSetText(BlzFrameGetChild(contextMenu.gotodef, 0), "|cff999999Go to Definition|r")
                    end
                end

                BlzFrameSetEnable(contextMenu.paste, clipboard ~= nil)
                if clipboard ~= nil then
                    BlzFrameSetText(BlzFrameGetChild(contextMenu.paste, 0), "Paste")
                else
                    BlzFrameSetText(BlzFrameGetChild(contextMenu.paste, 0), "|cff999999Paste|r")
                end

                BlzFrameClearAllPoints(contextMenu.parent)
                if line < editor.MAX_LINES_ON_SCREEN/2 then
                    --Context menu below mouse
                    if x > 0.9333 - flagsMenu.WIDTH then
                        --Left of mouse
                        contextMenu.minX = x - flagsMenu.WIDTH
                        contextMenu.maxX = x
                        BlzFrameSetAbsPoint(contextMenu.parent, FRAMEPOINT_TOPRIGHT, x, y)
                    else
                        --Right of mouse
                        contextMenu.minX = x
                        contextMenu.maxX = x + flagsMenu.WIDTH
                        BlzFrameSetAbsPoint(contextMenu.parent, FRAMEPOINT_TOPLEFT, x, y)
                    end
                    BlzFrameSetSize(contextMenu.parent, flagsMenu.WIDTH, 2*flagsMenu.TEXT_INSET + (contextMenu.NUM_DEFAULT_BUTTONS + #contextMenu.customButtons)*editor.LINE_SPACING)
                    contextMenu.minY = y - 2*flagsMenu.TEXT_INSET - (contextMenu.NUM_DEFAULT_BUTTONS + #contextMenu.customButtons)*editor.LINE_SPACING
                    contextMenu.maxY = y
                else
                    --Above mouse
                    if x > 0.9333 - flagsMenu.WIDTH then
                        --Left of mouse
                        contextMenu.minX = x - flagsMenu.WIDTH
                        contextMenu.maxX = x
                        BlzFrameSetAbsPoint(contextMenu.parent, FRAMEPOINT_BOTTOMRIGHT, x, y)
                    else
                        --Right of mouse
                        contextMenu.minX = x
                        contextMenu.maxX = x + flagsMenu.WIDTH
                        BlzFrameSetAbsPoint(contextMenu.parent, FRAMEPOINT_BOTTOMLEFT, x, y)
                    end
                    BlzFrameSetSize(contextMenu.parent, flagsMenu.WIDTH, 2*flagsMenu.TEXT_INSET + (contextMenu.NUM_DEFAULT_BUTTONS + #contextMenu.customButtons)*editor.LINE_SPACING)
                    contextMenu.minY = y
                    contextMenu.maxY = y + 2*flagsMenu.TEXT_INSET + (contextMenu.NUM_DEFAULT_BUTTONS + #contextMenu.customButtons)*editor.LINE_SPACING
                end
            end
        end
    end

    local function HideHelperAndAllAutoCompleteFrames()
        for i = 1, helper.numSuggestionsVisible do
            BlzFrameSetVisible(helper.autoCompleteFrames[i], false)
        end
        BlzFrameSetVisible(helper.parent, false)
        BlzFrameSetVisible(helper.suggestionHighlightFrame, false)
        helper.numSuggestionsVisible = 0
        helper.selectedSuggestion = nil
    end

    local function InsertAutoCompleteSuggestion(index)
        index = index or indexFromFrame[BlzGetTriggerFrame()]
        HideHelperAndAllAutoCompleteFrames()

        if BlzFrameIsVisible(nameDialog.parent) then
            local text = BlzFrameGetText(nameDialog.textField)
            nameDialog.doNotShowHelper = true
            BlzFrameSetText(nameDialog.textField, text .. helper.suggestions[index]:sub(helper.lengthOfEnteredText + 1))
            BlzFrameSetFocus(nameDialog.textField, true)
        else
            ChangeCodeLine(helper.suggestions[index]:sub(helper.lengthOfEnteredText + 1), nil, true)
            BlzFrameSetFocus(editBox, true)
            if not editBoxFocused then
                editBoxFocused = true
                editor.ON_FOCUS()
            end
        end
    end

    local function IsInString(str)
        local inSingleQuoteString = false
        local inDoubleQuoteString = false

        for i = 1, #str do
            local char = sub(str, i, i)

            if char == "'" and not inDoubleQuoteString and not IsQuotationMarkEscaped(str, i) then
                inSingleQuoteString = not inSingleQuoteString

            elseif char == '"' and not inSingleQuoteString and not IsQuotationMarkEscaped(str, i) then
                inDoubleQuoteString = not inDoubleQuoteString
            end
        end

        return inSingleQuoteString or inDoubleQuoteString
    end

    local function CheckForAutoCompleteSuggestions(str, screenLineNumberNumber, showInDialogWindow, searchLocals, searchFileNames, separateByComma, customLookupTable)
        local shift = 0

        if separateByComma then
            local lastCommaPos = match(str, ".*(),")
            if lastCommaPos then
                local firstCharPos = lastCommaPos
                repeat
                    firstCharPos = firstCharPos + 1
                until sub(str, firstCharPos, firstCharPos) ~= " "
                str = sub(str, firstCharPos + 1)
            end
        end

        local entered, lookupTable, prefix, hasDot
        if showInDialogWindow then
            entered = str
            if str == "" then
                HideHelperAndAllAutoCompleteFrames()
                return false
            end

            if customLookupTable then
                lookupTable = customLookupTable
            elseif searchFileNames then
                lookupTable = orderedFileNames
            else
                lookupTable = globalLookupTable
            end
        else
            if cursor.pos < #str then
                local i = cursor.pos + 1
                while sub(str, i, i):match("[%w_]") do
                    i = i + 1
                    shift = shift + 1
                end
            end
            entered = match(sub(str, 1, cursor.pos), "([%w_%.:]+)$") --last word including dot or colon

            if entered == nil or #entered < 2 or find(str, "%-%-") or find(str, "[%w_]") == nil or find(str, "%.%.") ~= nil then
                HideHelperAndAllAutoCompleteFrames()
                return false
            end

            lookupTable = globalLookupTable
        end

        if lookupTable == globalLookupTable then
            --Check if in string.
            local num = 0
            for __ in str:gmatch("'") do
                num = num + 1
            end
            if math.fmod(num, 2) == 1 then
                HideHelperAndAllAutoCompleteFrames()
                return false
            end
            num = 0
            for __ in str:gmatch('"') do
                num = num + 1
            end
            if math.fmod(num, 2) == 1 then
                HideHelperAndAllAutoCompleteFrames()
                return false
            end

            hasDot = find(entered, "[%.:]") ~= nil

            prefix = ""
            for match in entered:gmatch("%s*([%w_]+)%s*[%.:]") do
                lookupTable = lookupTable[match]
                if type(lookupTable) ~= "table" then
                    HideHelperAndAllAutoCompleteFrames()
                    return false
                end
                prefix = prefix .. match .. "."
            end

            if hasDot then
                entered = entered:match("[%.:]%s*([%w_]+)%s*$") or "" --last table field after dots or colons
            end
        else
            prefix = ""
        end

        local low, high = 1, #lookupTable
        while low <= high do
            local mid = math.floor((low + high) / 2)
            if sub(lookupTable[mid], 1, #entered) < entered then
                low = mid + 1
            else
                high = mid - 1
            end
        end

        for i = 1, #helper.suggestions do
            helper.suggestions[i] = nil
        end

        while low <= #lookupTable and sub(lookupTable[low], 1, #entered) == entered and lookupTable[low]:find("WSOriginWrapper") == nil do
            helper.suggestions[#helper.suggestions + 1] = lookupTable[low]
            low = low + 1
        end

        if searchLocals and not hasDot then
            low, high = 1, #localLookupTable
            while low <= high do
                local mid = math.floor((low + high) / 2)
                if sub(localLookupTable[mid], 1, #entered) < entered then
                    low = mid + 1
                else
                    high = mid - 1
                end
            end

            while low <= #localLookupTable and sub(localLookupTable[low], 1, #entered) == entered do
                helper.suggestions[#helper.suggestions + 1] = localLookupTable[low]
                low = low + 1
            end
        end

        if #helper.suggestions > 0 then
            if #helper.suggestions == 1 and (not BlzFrameIsVisible(helper.parent) or helper.numSuggestionsVisible == 0) and #entered == #helper.suggestions[1] then
                HideHelperAndAllAutoCompleteFrames()
                return false
            end

            table.sort(helper.suggestions)

            local numVisibleSuggestions = min(#helper.suggestions, editor.MAX_LINES_ON_SCREEN)

            for i = #helper.autoCompleteFrames + 1, numVisibleSuggestions do
                helper.autoCompleteFrames[i] = BlzCreateFrame("VariableViewerButton", helper.parent, 0, 0)
                variableViewer.textFrames[helper.autoCompleteFrames[i]] = BlzFrameGetChild(helper.autoCompleteFrames[i], 0)
                BlzFrameSetEnable(variableViewer.textFrames[helper.autoCompleteFrames[i]], false)
                BlzFrameSetPoint(helper.autoCompleteFrames[i], FRAMEPOINT_TOPLEFT, helper.parent, FRAMEPOINT_TOPLEFT, 0.0045, (-0.0045 - (i - 1)*editor.LINE_SPACING))
                BlzFrameSetPoint(helper.autoCompleteFrames[i], FRAMEPOINT_BOTTOMRIGHT, helper.parent, FRAMEPOINT_TOPRIGHT, -0.0045, (-0.0045 - i*editor.LINE_SPACING))
                helper.autoCompleteTextFrames[i] = BlzFrameGetChild(helper.autoCompleteFrames[i], 0)
                BlzFrameSetPoint(helper.autoCompleteTextFrames[i], FRAMEPOINT_TOPLEFT, helper.autoCompleteFrames[i], FRAMEPOINT_TOPLEFT, 0, 0)
                BlzFrameSetEnable(helper.autoCompleteTextFrames[i], false)
                indexFromFrame[helper.autoCompleteFrames[i]] = i

                local trig = CreateTrigger()
                BlzTriggerRegisterFrameEvent(trig, helper.autoCompleteFrames[i], FRAMEEVENT_CONTROL_CLICK)
                TriggerAddAction(trig, InsertAutoCompleteSuggestion)
            end

            for i = numVisibleSuggestions + 1, helper.numSuggestionsVisible do
                BlzFrameSetVisible(helper.autoCompleteFrames[i], false)
            end

            for i = helper.numSuggestionsVisible + 1, numVisibleSuggestions do
                BlzFrameSetVisible(helper.autoCompleteFrames[i], true)
            end

            local maxWidth = 0

            helper.lengthOfEnteredText = #entered

            for i = 1, numVisibleSuggestions do
                BlzFrameSetText(helper.autoCompleteTextFrames[i], "|cffffcc00" .. prefix .. "|r" .. "|cffffcc00" .. entered .. "|r|cffaaaaaa" .. sub(helper.suggestions[i], #entered + 1) .. "|r")
                BlzFrameSetSize(helper.autoCompleteTextFrames[i], 0, 0)
                local width = BlzFrameGetWidth(helper.autoCompleteTextFrames[i])
                if width > maxWidth then
                    maxWidth = width
                end
            end

            local noSelectedSuggestion = not helper.selectedSuggestion or helper.selectedSuggestion < 1 or helper.selectedSuggestion > helper.numSuggestionsVisible
            helper.numSuggestionsVisible = numVisibleSuggestions

            BlzFrameSetText(helper.text, "")
            BlzFrameSetSize(helper.text, 0, 0)
            BlzFrameSetSize(helper.parent, maxWidth + 0.009, helper.numSuggestionsVisible*editor.LINE_SPACING + 0.009)
            BlzFrameSetVisible(helper.parent, true)
            BlzFrameSetVisible(helper.suggestionHighlightFrame, true)

            if showInDialogWindow then
                BlzFrameClearAllPoints(helper.parent)
                BlzFrameSetPoint(helper.parent, FRAMEPOINT_BOTTOMLEFT, nameDialog.parent, FRAMEPOINT_TOP, 0, 0)

                if helper.selectedSuggestion and not noSelectedSuggestion then
                    local selectionFound = false
                    for i = 1, helper.numSuggestionsVisible do
                        if helper.suggestions[i] == helper.selectedSuggestionText then
                            helper.selectedSuggestion = i
                            helper.selectedSuggestionText = helper.suggestions[helper.selectedSuggestion]
                            selectionFound = true
                            break
                        end
                    end
                    if not selectionFound then
                        if searchFileNames then
                            helper.selectedSuggestion = helper.numSuggestionsVisible
                            helper.selectedSuggestionText = helper.suggestions[helper.selectedSuggestion]
                        else
                            helper.selectedSuggestion = helper.numSuggestionsVisible + 1
                            BlzFrameSetVisible(helper.suggestionHighlightFrame, false)
                        end
                    end
                else
                    if searchFileNames then
                        helper.selectedSuggestion = helper.numSuggestionsVisible
                        helper.selectedSuggestionText = helper.suggestions[helper.selectedSuggestion]
                    else
                        helper.selectedSuggestion = helper.numSuggestionsVisible + 1
                        BlzFrameSetVisible(helper.suggestionHighlightFrame, false)
                    end
                end
            else
                local pos = cursor.pos + shift - #entered
                BlzFrameSetText(widthTestFrame, sub(str, 1, pos))
                BlzFrameSetSize(widthTestFrame, 0, 0)

                local x = min(editor.CODE_LEFT_INSET + BlzFrameGetWidth(widthTestFrame), (editor.isExpanded and editor.EXPANDED_WIDTH or editor.COLLAPSED_WIDTH) - BlzFrameGetWidth(helper.parent))
                if screenLineNumberNumber < editor.MAX_LINES_ON_SCREEN/2 then
                    BlzFrameClearAllPoints(helper.parent)

                    BlzFrameSetPoint(helper.parent, FRAMEPOINT_TOPLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, x, -editor.CODE_TOP_INSET - screenLineNumberNumber*editor.LINE_SPACING)
                    helper.minX = x + (editor.isExpanded and editor.EXPANDED_X or editor.COLLAPSED_X) + 0.01
                    helper.maxY = editor.Y_TOP - editor.CODE_TOP_INSET - screenLineNumberNumber*editor.LINE_SPACING - 0.01
                    helper.maxX = helper.minX + maxWidth + 0.009 - 0.01
                    helper.minY = helper.maxY - helper.numSuggestionsVisible*editor.LINE_SPACING - 0.009 + 0.01

                    if helper.selectedSuggestion then
                        local selectionFound = false
                        for i = 1, helper.numSuggestionsVisible do
                            if helper.suggestions[i] == helper.selectedSuggestionText then
                                helper.selectedSuggestion = i
                                helper.selectedSuggestionText = helper.suggestions[helper.selectedSuggestion]
                                selectionFound = true
                                break
                            end
                        end
                        if not selectionFound then
                            helper.selectedSuggestion = 1
                            helper.selectedSuggestionText = helper.suggestions[helper.selectedSuggestion]
                        end
                    else
                        helper.selectedSuggestion = 1
                        helper.selectedSuggestionText = helper.suggestions[helper.selectedSuggestion]
                    end
                else
                    BlzFrameClearAllPoints(helper.parent)
                    BlzFrameSetPoint(helper.parent, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, x, -editor.CODE_TOP_INSET - (screenLineNumberNumber-1)*editor.LINE_SPACING)

                    helper.minX = x + (editor.isExpanded and editor.EXPANDED_X or editor.COLLAPSED_X) + 0.01
                    helper.minY = editor.Y_TOP - editor.CODE_TOP_INSET - screenLineNumberNumber*editor.LINE_SPACING + 0.01
                    helper.maxX = helper.minX + maxWidth + 0.009 - 0.01
                    helper.maxY = helper.minY + helper.numSuggestionsVisible*editor.LINE_SPACING + 0.009 - 0.01

                    if helper.selectedSuggestion then
                        local selectionFound = false
                        for i = 1, helper.numSuggestionsVisible do
                            if helper.suggestions[i] == helper.selectedSuggestionText then
                                helper.selectedSuggestion = i
                                helper.selectedSuggestionText = helper.suggestions[helper.selectedSuggestion]
                                selectionFound = true
                                break
                            end
                        end
                        if not selectionFound then
                            helper.selectedSuggestion = helper.numSuggestionsVisible
                            helper.selectedSuggestionText = helper.suggestions[helper.selectedSuggestion]
                        end
                    else
                        helper.selectedSuggestion = helper.numSuggestionsVisible
                        helper.selectedSuggestionText = helper.suggestions[helper.selectedSuggestion]
                    end
                end
            end

            BlzFrameSetAllPoints(helper.suggestionHighlightFrame, helper.autoCompleteFrames[helper.selectedSuggestion])

            return true
        else
            HideHelperAndAllAutoCompleteFrames()
            return false
        end
    end

    local function CheckForFunctionPreviews(str, screenLineNumberNumber, cursorpos)
        str = sub(str, 1, cursorpos)
        local currentLevel = select(2, str:gsub("%(", "")) - select(2, str:gsub("%)", "")) --opened parentheses
        local loopLevel = currentLevel
        local char
        if currentLevel > 0 then
            for i = #str, 1, -1 do
                char = sub(str, i, i)
                if char == "(" then
                    loopLevel = loopLevel - 1
                    if loopLevel < currentLevel then
                        local funcName = sub(str, 1, i):match("([%w_%.:]+)%s*%($") --var name before (
                        if FUNCTION_PREVIEW[funcName] then
                            BlzFrameSetVisible(helper.parent, true)

                            local numCommas = 0
                            local nestedLevel = 0

                            for j = i + 1, #str do
                                local argChar = sub(str, j, j)

                                if argChar == "(" then
                                    nestedLevel = nestedLevel + 1
                                elseif argChar == ")" then
                                    nestedLevel = nestedLevel - 1
                                elseif argChar == "," and nestedLevel == 0 then
                                    numCommas = numCommas + 1
                                end
                            end

                            for j = 1, #concatTable do
                                concatTable[j] = nil
                            end
                            local j = 0
                            concatTable = (((concatTable .. "|cffaaaaaafunction|r ") .. funcName) .. "(")
                            for argName in FUNCTION_PREVIEW[funcName]:gmatch("([%w_]+)%s*,") do
                                if j == numCommas then
                                    if j > 0 then
                                        concatTable = (((concatTable .. ", |cffffcc00") .. argName) .. "|r")
                                    else
                                        concatTable = (((concatTable .. "|cffffcc00") .. argName) .. "|r")
                                    end
                                else
                                    if j > 0 then
                                        concatTable = ((concatTable .. ", ") .. argName)
                                    else
                                        concatTable = concatTable .. argName
                                    end
                                end
                                j = j + 1
                            end

                            BlzFrameSetText(widthTestFrame, sub(str, 1, i))
                            BlzFrameSetSize(widthTestFrame, 0, 0)

                            BlzFrameSetText(helper.text, table.concat(concatTable .. ")"))
                            BlzFrameSetSize(helper.text, 0, 0)
                            BlzFrameSetSize(helper.parent, BlzFrameGetWidth(helper.text) + 0.009, BlzFrameGetHeight(helper.text) + 0.009)
                            local x = min(editor.CODE_LEFT_INSET + BlzFrameGetWidth(widthTestFrame), (editor.isExpanded and editor.EXPANDED_WIDTH or editor.COLLAPSED_WIDTH) - BlzFrameGetWidth(helper.parent))
                            BlzFrameClearAllPoints(helper.parent)
                            BlzFrameSetPoint(helper.parent, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, x, -editor.CODE_TOP_INSET - (screenLineNumberNumber-1)*editor.LINE_SPACING)
                            return true
                        end
                    end
                elseif char == ")" then
                    loopLevel = loopLevel + 1
                end
            end
        else
            BlzFrameSetVisible(helper.parent, false)
            return false
        end
    end

    local function CheckForVariableDisplay(line, pos, executionLine, xs)
        local text = codeLines[currentTab][step[currentTab]][line]
        local char = sub(text, pos, pos)
        if char == "" then
            return
        end

        local stringList = {}
        text = text:gsub('"[^"]*"', function(str)
            stringList[#stringList + 1] = str
            return "__STRING" .. #stringList
        end)
        text = text:gsub("'[^']*'", function(str)
            stringList[#stringList + 1] = str
            return "__STRING" .. #stringList
        end)

        local first, last = pos, pos
        if char:match("[%w_%.%[%]]") == nil then
            return
        end

        while sub(text, first, first):match("[%w_%.%[%]]") do
            first = first - 1
        end
        while sub(text, last + 1, last + 1):match("[%w_%.%[%]]") do
            last = last + 1
        end

        local token = sub(text, first + 1, last)
        local tableTrace = {}
        local beginning = 1
        local tableVar
        repeat
            pos = find(token, "[%.%[]", beginning)
            if pos then
                tableVar = sub(token, beginning, pos - 1)
            else
                tableVar = sub(token, beginning)
            end

            if beginning == 1 then
                local level = visibleVarsOfLine[currentTab][executionLine][tableVar]
                if level then
                    tableTrace[#tableTrace + 1] = WSDebug.VarTable[currentTab][level][tableVar]
                elseif _ENV[tableVar] then
                    tableTrace[#tableTrace + 1] = _ENV[tableVar]
                else
                    return
                end
            elseif sub(tableVar, -1, -1) == "]" then
                tableVar = sub(tableVar, 1, -2)
                if tonumber(tableVar) then
                    tableTrace[#tableTrace + 1] = tonumber(tableVar)
                elseif sub(tableVar, 1, 1) == "'" or sub(tableVar, 1, 1) == '"' then
                    tableTrace[#tableTrace + 1] = sub(tableVar, 2, -2)
                else
                    local level = visibleVarsOfLine[currentTab][executionLine][tableVar]
                    if level then
                        tableTrace[#tableTrace + 1] = WSDebug.VarTable[currentTab][level][tableVar]
                    elseif _ENV[tableVar] then
                        tableTrace[#tableTrace + 1] = _ENV[tableVar]
                    else
                        return
                    end
                end
            else
                tableTrace[#tableTrace + 1] = tableVar
            end
            if pos then
                beginning = pos + 1
            end
        until pos == nil

        for i = 1, #stringList do
            for j = 1, #tableTrace do
                if type(tableTrace[j]) == "string" then
                    tableTrace[j] = tableTrace[j]:gsub("__STRING" .. i, sub(stringList[i], 2, -2))
                end
            end
            token = token:gsub("__STRING" .. i, stringList[i])
        end

        local var = tableTrace[1]
        for i = 2, #tableTrace do
            if type(var) ~= "table" then
                return
            end
            var = var[tableTrace[i]]
        end

        local str = Value2String(var, nil, 1000)
        local dx = xs - (editor.isExpanded and editor.EXPANDED_X or editor.COLLAPSED_X)

        HideHelperAndAllAutoCompleteFrames()
        BlzFrameSetVisible(helper.parent, true)
        BlzFrameClearAllPoints(helper.parent)
        BlzFrameSetText(helper.text, token .. ": " .. str)
        BlzFrameSetSize(helper.text, 0, 0)
        BlzFrameSetSize(helper.parent, BlzFrameGetWidth(helper.text) + 0.009, BlzFrameGetHeight(helper.text) + 0.009)
        local xEnd = xs + BlzFrameGetWidth(helper.parent)
        if xEnd > 0.9333 then
            dx = dx - xEnd + 0.9333
        end
        BlzFrameSetPoint(helper.parent, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, dx, -editor.CODE_TOP_INSET - (line - tabs.lineNumberOffset[currentTab] - 1)*editor.LINE_SPACING)

        cursor.isShowingVariableTooltip = true
    end

    local function LineOpensScope(whichLine)
        return find(whichLine, "%f[%a_]do%f[^%w_]")
        or find(whichLine, "%f[%a_]then%f[^%w_]")
        or find(whichLine, "%f[%a_]repeat%f[^%w_]")
        or find(whichLine, "%f[%a_]else%f[^%w_]")
        or find(whichLine, "%f[%a_]elseif%f[^%w_]")
        or find(whichLine, "[%(%[{]%s*$")
        or find(whichLine, "%f[%a_]function%f[^%w_]")
    end

    local function DeleteSelection()
        local lower = max(selection.startLine, selection.endLine)
        local upper = min(selection.startLine, selection.endLine)

        if not lower or not upper then
            return
        end

        local currentLines = codeLines[currentTab][step[currentTab]]

        local left, right
        if lower == upper then
            left = min(selection.startPos, selection.endPos)
            right = max(selection.startPos, selection.endPos)
        else
            left = selection.startLine == upper and selection.startPos or selection.endPos
            right = selection.startLine == lower and selection.startPos or selection.endPos
        end

        currentLines[upper] = sub(currentLines[upper], 1, left) .. sub(currentLines[lower], right + 1)
        coloredCodeLines[currentTab][step[currentTab]][upper] = nil

        local completeDeletes = lower - upper
        if completeDeletes > 0 then
            for i = upper + 1, highestNonEmptyLine[currentTab][step[currentTab]] do
                currentLines[i] = currentLines[i + completeDeletes]
                coloredCodeLines[currentTab][step[currentTab]][i] = nil
            end
            highestNonEmptyLine[currentTab][step[currentTab]] = highestNonEmptyLine[currentTab][step[currentTab]] - completeDeletes
            BlzFrameSetMinMaxValue(codeScroller, 0, highestNonEmptyLine[currentTab][step[currentTab]])
        end

        cursor.codeLineNumber = upper
        cursor.screenLineNumber = upper - tabs.lineNumberOffset[currentTab]
        SetCursorPos(upper == lower and left or upper == selection.startLine and selection.startPos or selection.endPos)
        SetCursorX(sub(currentLines[cursor.codeLineNumber], tabs.horizontalOffset[currentTab] + 1, cursor.pos))

        edit.lastKeyStroke = timeElapsed
        edit.lineNumber[currentTab][step[currentTab]] = upper
        edit.pos[currentTab][step[currentTab]] = cursor.pos

        HideSelection()
        selection.hasSelection = false
        UpdateAllLines()
    end

    local function GetFirstDifferentCharPos(str1, str2, firstLook)
        local found
        firstLook = min(#str2, firstLook)
        for i = firstLook, max(#str1, #str2) do
            if sub(str1, i, i) ~= sub(str2, i, i) then
                return i, true
            end
        end
        if not found then
            for i = 1, firstLook - 1 do
                if sub(str1, i, i) ~= sub(str2, i, i) then
                    return i, true
                end
            end
        end
        return firstLook, false
    end

    local function ShiftLines(amount, firstLine)
        local currentLines = codeLines[currentTab][step[currentTab]]
        local currentColoredLines = coloredCodeLines[currentTab][step[currentTab]]

        if amount > 0 then
            for i = highestNonEmptyLine[currentTab][step[currentTab]] + amount, firstLine + amount, -1 do
                currentLines[i] = currentLines[i - amount]
                currentColoredLines[i] = nil
                if lines.debugState[currentTab][i] ~= lines.debugState[currentTab][i - amount] then
                    lines.debugState[currentTab][i] = lines.debugState[currentTab][i - amount]
                    BlzFrameSetTexture(BlzFrameGetChild(stopButtons[i - tabs.lineNumberOffset[currentTab]], 0), LINE_STATE_ICONS[lines.debugState[currentTab][i]], 0, true)
                end
            end
            for i = firstLine, firstLine + amount do
                lines.debugState[currentTab][i] = 0
                BlzFrameSetTexture(BlzFrameGetChild(stopButtons[i - tabs.lineNumberOffset[currentTab]], 0), LINE_STATE_ICONS[0], 0, true)
            end
        else
            amount = -amount
            for i = firstLine + amount, highestNonEmptyLine[currentTab][step[currentTab]] + amount do
                currentLines[i - amount] = currentLines[i]
                currentColoredLines[i - amount] = nil
                if lines.debugState[currentTab][i - amount] ~= lines.debugState[currentTab][i] then
                    lines.debugState[currentTab][i - amount] = lines.debugState[currentTab][i]
                    BlzFrameSetTexture(BlzFrameGetChild(stopButtons[i - amount - tabs.lineNumberOffset[currentTab]], 0), LINE_STATE_ICONS[lines.debugState[currentTab][i - amount]], 0, true)
                end
            end
        end

        if tabs.longestLineIndex[currentTab] == firstLine then
            if CheckLongestLineLength() then
                AdjustHorizontalLineScroller()
            end
        elseif tabs.longestLineIndex[currentTab] > firstLine then
            tabs.longestLineIndex[currentTab] = tabs.longestLineIndex[currentTab] + amount
        end
    end

    local function CodeEditorOnAction()
        tabs.hasUnsavedChanges[currentTab] = true
        if editor.ENABLE_SAVE_AND_LOAD and FileIO then
            BlzFrameSetText(tabNavigator.titles[currentTab], editor.TAB_NAVIGATOR_UNSAVED_COLOR .. "*" .. tabs.truncatedNames[currentTab] .. "|r")
        end

        tabs.hasError[currentTab] = false
    end

    ChangeCodeLine = function(text, whichLine, skipAutoComplete)
        whichLine = whichLine or cursor.codeLineNumber

        local oldText = editBoxText
        if text then
            if text == "" then
                return
            end
            editBoxText = text
            BlzFrameSetText(editBox, text)
        else
            editBoxText = BlzFrameGetText(editBox)
            if oldText == editBoxText then
                return
            end
        end

        BlzFrameSetEnable(buttons["Undo"], true)
        BlzFrameSetEnable(buttons["Redo"], false)
        BlzFrameSetVisible(highlights.currentLine, false)
        BlzFrameSetVisible(highlights.error, false)
        BlzFrameSetVisible(variableViewer.parent, false)
        if not editBoxFocused then
            editBoxFocused = true
            editor.ON_FOCUS()
        end
        BlzFrameSetVisible(cursorFrame, true)
        lineNumbers.lastViewed[currentTab] = nil
        cursor.posOfLineJumps = nil

        if highlights.custom[currentTab] then
            BlzFrameSetVisible(highlights.custom.frame, false)
            highlights.custom[currentTab] = nil
        end

        local quickImport = find(editBoxText, "beginFile") ~= nil
        if quickImport then
            local fileName = match(editBoxText, "Debug%.beginFile%s*%(?%s*[\"']([^\"']+)[\"']") or match(editBoxText, "@beginFile%s*\"(.+)\"") or match(editBoxText, "@beginFile%s*'(.+)'") or match(editBoxText, "@beginFile%s*(.-)%s*\n")
            if fileName then
                if tabs.numbers[fileName] then
                    WSCode.SwitchToTab(fileName)
                    WSCode.IncrementStep()
                    local currentLines = codeLines[fileName][step[fileName]]
                    local currentColoredLines = coloredCodeLines[fileName][step[fileName]]
                    for i = 1, highestNonEmptyLine[fileName][step[fileName]] do
                        currentLines[i] = ""
                        currentColoredLines[i] = nil
                    end
                    highestNonEmptyLine[fileName][step[fileName]] = 0
                    SetLineOffset(0)
                else
                    WSCode.AddTab(fileName)
                    WSCode.SwitchToTab(fileName)
                end
                cursor.screenLineNumber = 1
                cursor.codeLineNumber = 1
                whichLine = 1
            else
                quickImport = false
            end
        end

        CodeEditorOnAction()

        if timeElapsed - edit.lastKeyStroke > editor.MIN_TIME_BETWEEN_UNDO_STEPS or whichLine ~= lines.lastEdited or selection.hasSelection and not quickImport then
            WSCode.IncrementStep()
        end

        local currentLines = codeLines[currentTab][step[currentTab]]

        if #editBoxText == 0 or #editBoxText == #oldText - 1 or (editor.LEGAL_CHARACTERS and not editor.LEGAL_CHARACTERS[sub(oldText, -1,-1) or sub(oldText, -2, -1) == "  "] and #editBoxText == #oldText - 2) then
            if selection.hasSelection and not quickImport then
                DeleteSelection()
            else
                --Backspace
                if cursor.pos > 0 then
                    if sub(currentLines[whichLine], 1, cursor.pos):match("^%s*$") then
                        local oldCursorPos = cursor.pos
                        SetCursorPos(math.floor((cursor.pos - 1)/4)*4)
                        currentLines[whichLine] = sub(currentLines[whichLine], 1, cursor.pos) .. sub(currentLines[whichLine], oldCursorPos + 1)
                    elseif brackets.lines[1] == whichLine and brackets.pos[1] == cursor.pos and brackets.lines[2] == whichLine and brackets.pos[2] == cursor.pos + 1 then
                        currentLines[whichLine] = sub(currentLines[whichLine], 1, cursor.pos - 1) .. sub(currentLines[whichLine], cursor.pos + 2)
                        SetCursorPos(cursor.pos - 1)
                    else
                        currentLines[whichLine] = sub(currentLines[whichLine], 1, cursor.pos - 1) .. sub(currentLines[whichLine], cursor.pos + 1)
                        SetCursorPos(cursor.pos - 1)
                    end
                    if cursor.pos < tabs.horizontalOffset[currentTab] + editor.MAX_HORIZONTAL_SCROLL_BUFFER then
                        BlzFrameSetValue(codeHorizontalScroller, math.max(0, cursor.pos - editor.MAX_HORIZONTAL_SCROLL_BUFFER))
                    end
                    if CheckLongestLineLength(whichLine) then
                        AdjustHorizontalLineScroller()
                    end
                --Backspace on empty line
                elseif whichLine > 1 then
                    SetCursorPos(#currentLines[whichLine - 1])
                    currentLines[whichLine - 1] = currentLines[whichLine - 1] .. currentLines[whichLine]
                    coloredCodeLines[currentTab][step[currentTab]][whichLine - 1] = nil
                    RenderLine(cursor.screenLineNumber - 1, currentLines[whichLine - 1], coloredCodeLines[currentTab][step[currentTab]][whichLine - 1])
                    ShiftLines(-1, whichLine)

                    UpdateAllLines()

                    cursor.screenLineNumber = cursor.screenLineNumber - 1
                    cursor.codeLineNumber = cursor.codeLineNumber - 1
                    whichLine = whichLine - 1

                    SetCursorX(sub(currentLines[whichLine], tabs.horizontalOffset[currentTab] + 1, cursor.pos))
                    SetFrameAlpha(cursorFrame, 255)

                    if #editBoxText == 0 or #editBoxText == 255 then
                        editBoxText = "          "
                        BlzFrameSetText(editBox, "          ")
                    end

                    SetLocalList(whichLine)

                    return
                end
            end

            local found
            firstDifferentChar, found = GetFirstDifferentCharPos(editBoxText, oldText, max(1, firstDifferentChar - 1))
            if found and firstDifferentChar == 1 then
                editBoxText = "          "
                BlzFrameSetText(editBox, "          ")
            end
        else
            --Entered char
            local found
            firstDifferentChar, found = GetFirstDifferentCharPos(editBoxText, oldText, firstDifferentChar)
            if not found then
                if #editBoxText == 0 or #editBoxText == 255 then
                    editBoxText = "          "
                    BlzFrameSetText(editBox, "          ")
                end
                return
            end

            local numChars = #editBoxText - #oldText
            if numChars < 1 then
                numChars = 1
            end

            if selection.hasSelection and not quickImport then
                DeleteSelection()
            end

            local newText

            if not text then
                if firstDifferentChar == 1 then
                    newText = sub(editBoxText, 1, numChars + 1)
                else
                    newText = sub(editBoxText, firstDifferentChar, firstDifferentChar + numChars - 1)
                end
            else
                newText = editBoxText
            end

            if find(newText, "\n") then
                --Copy & pasted code chunk
                local newLines = WSCode.ConvertStringToLines(newText)
                for i = 1, #newLines do
                    newLines[i] = newLines[i]:gsub("\t", "    "):gsub("\n", ""):gsub("\r", "")
                end

                local newCodeSize = #newLines
                ShiftLines(newCodeSize - 1, whichLine)
                highestNonEmptyLine[currentTab][step[currentTab]] = highestNonEmptyLine[currentTab][step[currentTab]] + newCodeSize

                local remainingText = sub(currentLines[whichLine], cursor.pos + 1)
                currentLines[whichLine] = sub(currentLines[whichLine], 1, cursor.pos) .. newLines[1]
                coloredCodeLines[currentTab][step[currentTab]][whichLine] = nil

                local j = whichLine + 1
                for i = 2, newCodeSize - 1 do
                    currentLines[j] = newLines[i]
                    coloredCodeLines[currentTab][step[currentTab]][j] = nil
                    j = j + 1
                end

                currentLines[j] = newLines[newCodeSize] .. remainingText
                coloredCodeLines[currentTab][step[currentTab]][j] = nil

                UpdateAllLines()

                cursor.codeLineNumber = j
                cursor.screenLineNumber = j - tabs.lineNumberOffset[currentTab]
                whichLine = j
                SetCursorPos(#newLines[#newLines])
                SetFrameAlpha(cursorFrame, 255)

                if CheckLongestLineLength() then
                    AdjustHorizontalLineScroller()
                end

                editBoxText = "          "
                BlzFrameSetText(editBox, "          ")
            else
                --Ctrl + backspace
                if #newText == 1 and string.byte(sub(newText, 1, 1)) == 127 then
                    if cursor.pos > 0 then
                        local first = cursor.pos - 1
                        local lineContent = currentLines[whichLine]
                        local trailingText = sub(lineContent, cursor.pos + 1)
                        local char = sub(lineContent, cursor.pos, cursor.pos)
                        if char:match("[%w_]") then
                            while sub(lineContent, first, first):match("[%w_]") do
                                first = first - 1
                            end
                        elseif char == " " then
                            while sub(lineContent, first, first) == " " do
                                first = first - 1
                            end
                        else
                            while sub(lineContent, first, first):match("[%w%s_]") == nil and first > 0 do
                                first = first - 1
                            end
                        end

                        currentLines[whichLine] = sub(lineContent, 1, first) .. trailingText
                        SetCursorPos(first)
                        if cursor.pos < tabs.horizontalOffset[currentTab] + editor.MAX_HORIZONTAL_SCROLL_BUFFER then
                            BlzFrameSetValue(codeHorizontalScroller, math.max(0, cursor.pos - editor.MAX_HORIZONTAL_SCROLL_BUFFER))
                        end
                        if CheckLongestLineLength(whichLine) then
                            AdjustHorizontalLineScroller()
                        end

                        editBoxText = "          "
                        BlzFrameSetText(editBox, "          ")
                    --Backspace on empty line
                    elseif whichLine > 1 then
                        SetCursorPos(#currentLines[whichLine - 1])
                        currentLines[whichLine - 1] = currentLines[whichLine - 1] .. currentLines[whichLine]
                        coloredCodeLines[currentTab][step[currentTab]][whichLine - 1] = nil
                        RenderLine(cursor.screenLineNumber - 1, currentLines[whichLine - 1], coloredCodeLines[currentTab][step[currentTab]][whichLine - 1])
                        ShiftLines(-1, whichLine)

                        UpdateAllLines()

                        cursor.screenLineNumber = cursor.screenLineNumber - 1
                        cursor.codeLineNumber = cursor.codeLineNumber - 1
                        whichLine = whichLine - 1

                        SetCursorX(sub(currentLines[whichLine], tabs.horizontalOffset[currentTab] + 1, cursor.pos))
                        SetFrameAlpha(cursorFrame, 255)

                        if #editBoxText == 0 or #editBoxText == 255 then
                            editBoxText = "          "
                            BlzFrameSetText(editBox, "          ")
                        end

                        SetLocalList(whichLine)

                        editBoxText = "          "
                        BlzFrameSetText(editBox, "          ")
                        return
                    end
                else
                    --Entered single line or character
                    if editor.LEGAL_CHARACTERS then
                        for i = 1, #newText do
                            if not editor.LEGAL_CHARACTERS[sub(newText, i, i)] and sub(newText, i, i) ~= "\n" then
                                PlayError()
                                editBoxText = "          "
                                BlzFrameSetText(editBox, "          ")
                                WSDebug.PrintForUser("|cffff5555Illegal character " .. sub(newText, i, i) .. ".|r")
                                return
                            end
                        end
                    end

                    currentLines[whichLine] = sub(currentLines[whichLine], 1, cursor.pos) .. newText .. sub(currentLines[whichLine], cursor.pos + 1)
                    SetCursorPos(cursor.pos + #newText)

                    if CheckLongestLineLength(whichLine) then
                        AdjustHorizontalLineScroller()
                    end
                end
            end
        end

        if #editBoxText == 0 or #editBoxText == 255 then
            editBoxText = "          "
            BlzFrameSetText(editBox, "          ")
        end

        if FUNCTION_PREVIEW then
            if not IsInString(sub(currentLines[whichLine], 1, cursor.pos)) and (skipAutoComplete or not CheckForAutoCompleteSuggestions(currentLines[whichLine], cursor.screenLineNumber, false, true, false)) then
                CheckForFunctionPreviews(currentLines[whichLine], cursor.screenLineNumber, cursor.pos)
            end
        end

        edit.lastKeyStroke = timeElapsed
        lines.lastEdited = whichLine

        if currentLines[whichLine]:match("^%s*nd$") then
            currentLines[whichLine] = currentLines[whichLine]:gsub("nd", "end")
            SetCursorPos(cursor.pos + 1)
        end

        --Auto-align on scope close.
        if cursor.pos == #currentLines[whichLine] and (currentLines[whichLine]:match("^%s*end") or currentLines[whichLine]:match("^%s*%}") or currentLines[whichLine]:match("^%s*%)") or currentLines[whichLine]:match("^%s*until") or currentLines[whichLine]:match("^%s*else")) then
            local numSpaces = 0
            local previousLine = currentLines[whichLine - 1]
            local i = 1
            while sub(previousLine, i, i) == " " do
                numSpaces = numSpaces + 1
                i = i + 1
            end
            if LineOpensScope(previousLine) then
                numSpaces = numSpaces + 4
            end
            numSpaces = max(0, numSpaces - 4)
            local whiteSpace = ""
            for __ = 1, numSpaces do
                whiteSpace = whiteSpace .. " "
            end

            local length = #currentLines[whichLine]
            currentLines[whichLine] = whiteSpace .. currentLines[whichLine]:gsub("^%s*", "")
            SetCursorPos(cursor.pos - (length - #currentLines[whichLine]))
        end

        --Textmacros
        local replacedCode = HandleTextMacros(currentLines[whichLine])
        if replacedCode and replacedCode ~= currentLines[whichLine] then
            local lengthDiff = #replacedCode - #currentLines[whichLine]
            currentLines[whichLine] = replacedCode
            SetCursorPos(cursor.pos + lengthDiff)
        end

        --Adjust code scroller and window position on new line.
        highestNonEmptyLine[currentTab][step[currentTab]] = max(highestNonEmptyLine[currentTab][step[currentTab]], whichLine)
        BlzFrameSetMinMaxValue(codeScroller, 0, highestNonEmptyLine[currentTab][step[currentTab]])
        SetLineOffset(tabs.lineNumberOffset[currentTab])
        JumpWindow(whichLine)

        coloredCodeLines[currentTab][step[currentTab]][whichLine] = nil

        SetCursorX(sub(currentLines[whichLine], tabs.horizontalOffset[currentTab] + 1, cursor.pos))

        --Set frame text.
        RenderLine(cursor.screenLineNumber, codeLines[currentTab][step[currentTab]][cursor.codeLineNumber], coloredCodeLines[currentTab][step[currentTab]][cursor.codeLineNumber])

        SetFrameAlpha(cursorFrame, 255)
    end

    local function AddEmptyLines(nl)
        local count = #nl
        return ("\nwsnewline"):rep(count - 1) .. "\n"
    end

    local function Export()
        if not FileIO then
            return
        end

        local currentLines = codeLines[currentTab][step[currentTab]]

        local hasCode = false
        for i = 1, highestNonEmptyLine[currentTab][step[currentTab]] do
            if currentLines[i]:find("^%s*$") == nil then
                hasCode = true
            end
        end

        if not hasCode then
            return
        end

        local saveString = setmetatable({}, {__concat = function(self, str) self[#self + 1] = str return self end})
        for i = 1, highestNonEmptyLine[currentTab][step[currentTab]] do
            if currentLines[i]:match("^%s*$") ~= nil then
                saveString = saveString .. "\n"
            else
                saveString = saveString .. currentLines[i] .. "\n"
            end
        end

        local saveStr = table.concat(saveString)
        FileIO.Save(editor.EXPORT_SUBFOLDER .. "\\WSCodeLoadFile" .. currentTab:gsub(" ", "") .. ".txt", saveStr)
        FileIO.Export(editor.EXPORT_SUBFOLDER .. "\\WSCodeExport" .. currentTab:gsub(" ", "") .. ".txt", saveStr:gsub("\n\n+", AddEmptyLines))
    end

    MainLoop = function()
        local newValue

        timeElapsed = timeElapsed + 0.01
        executionCount = 0

        OnMousePeriodic()

        for __, parent in next, doNotCheckStop do
            for __, child in next, parent do
                for childKey, __ in next, child do
                    child[childKey] = nil
                end
            end
        end

        if not BlzFrameIsVisible(codeEditorParent) then
            return
        end

        if not tabIsHalted[currentTab] and BlzFrameIsVisible(highlights.currentLine) then
            BlzFrameSetVisible(highlights.currentLine, false)
        end

        if BlzFrameGetText(editBox) ~= editBoxText and not editor.textChangeMonitorFrozen then
            ChangeCodeLine()
        end

        if lastLineNumber[currentTab] and flags.unfreezeViewer then
            UpdateVariableViewer(lastLineNumber[currentTab], true)
        end

        if tabNavigator.hoveringOver then
            if not BlzFrameIsVisible(tabNavigator.highlights[tabNavigator.hoveringOver]) and not BlzFrameIsVisible(BlzFrameGetChild(tabNavigator.closeButtons[tabNavigator.hoveringOver], 2)) then
                BlzFrameSetVisible(tabNavigator.closeButtons[tabNavigator.hoveringOver], false)
                tabNavigator.hoveringOver = nil
            end
        else
            for i = 1, tabs.amount do
                if BlzFrameIsVisible(tabNavigator.highlights[tabs.names[i]]) then
                    tabNavigator.hoveringOver = tabs.names[i]
                    BlzFrameSetVisible(tabNavigator.closeButtons[tabNavigator.hoveringOver], true)
                    break
                end
            end
        end

        local xs, ys
        if selection.hasSelection and WSDebug.Mouse.leftButtonIsPressed then
            xs, ys = GetMouseScreenCoordinates()
            local line, pos = GetCursorPos(xs, ys)
            if selection.hasSelection then
                if line > 0 and line <= editor.MAX_LINES_ON_SCREEN then
                    if pos == -1 then
                        BlzFrameSetValue(codeHorizontalScroller, tabs.horizontalOffset[currentTab] - 1)
                    elseif pos == math.huge then
                        BlzFrameSetValue(codeHorizontalScroller, tabs.horizontalOffset[currentTab] + 1)
                    end
                elseif line < 0 then
                    SetLineOffset(tabs.lineNumberOffset[currentTab] - 1)
                else
                    SetLineOffset(tabs.lineNumberOffset[currentTab] + 1)
                end
            end
        end

        newValue = BlzFrameGetValue(codeHorizontalScroller)
        if newValue ~= tabs.horizontalOffset[currentTab] then
            tabs.horizontalOffset[currentTab] = newValue
            UpdateAllLines()
            if selection.hasSelection then
                SetSelection()
            end
            if cursor.pos then
                SetCursorX(sub(codeLines[currentTab][step[currentTab]][cursor.codeLineNumber], tabs.horizontalOffset[currentTab] + 1, cursor.pos))
            end
            if BlzFrameIsVisible(searchBar.parent) then
                RenderSearchHighlights()
            end
        end

        if not cursor.checkedForVariableDisplay and timeElapsed - WSDebug.Mouse.lastMove > 0.35 then
            if not xs then
                xs, ys = GetMouseScreenCoordinates()
            end
            local line, pos, xc = GetCursorPos(xs, ys)
            line = line + tabs.lineNumberOffset[currentTab]
            if xc and line and pos and pos < #codeLines[currentTab][step[currentTab]][line] and
            (not BlzFrameIsVisible(helper.parent) or helper.numSuggestionsVisible == 0 or xs < helper.minX or xs > helper.maxX or ys < helper.minY or ys > helper.maxY) then
                CheckForVariableDisplay(line, pos, lineNumbers.lastViewed[currentTab] or lastLineNumber[currentTab], xs)
            end
            cursor.checkedForVariableDisplay = true
        end

        cursorCounter = cursorCounter + 1
        if math.fmod(math.floor(cursorCounter/50), 2) == 0 then
            SetFrameAlpha(cursorFrame, 255)
        else
            SetFrameAlpha(cursorFrame, 0)
        end

        if WSCode.IsFocused() or (variableViewer.isExpanded and BlzFrameIsVisible(variableViewer.parent)) or editor.fadeOutBlocked then
            if editor.fadeState < 1 then
                editor.fadeState = 1 --min(1, editor.fadeState + 0.01/editor.FOCUS_FADE_TIME)
                SetFrameAlpha(codeEditorParent, (editor.fadeState*255 + (1 - editor.fadeState)*editor.DEFOCUS_FADE_OUT_ALPHA) // 1)
                editor.timeOfDefocus = nil
            end
        else
            if not xs then
                xs, ys = GetMouseScreenCoordinates()
            end
            if (editor.isExpanded and xs < editor.EXPANDED_X and (xs < editor.EXPANDED_X - BlzFrameGetWidth(variableViewer.parent) or ys < editor.Y_TOP - BlzFrameGetHeight(variableViewer.parent)))
            or (not editor.isExpanded and xs < editor.COLLAPSED_X and (xs < editor.COLLAPSED_X - BlzFrameGetWidth(variableViewer.parent) or ys < editor.Y_TOP - BlzFrameGetHeight(variableViewer.parent))) then
                if not editor.timeOfDefocus then
                    editor.timeOfDefocus = timeElapsed
                elseif timeElapsed > editor.timeOfDefocus + editor.DEFOCUS_FADE_OUT_DELAY and editor.fadeState > 0 then
                    editor.fadeState = 0 --max(0, editor.fadeState - 0.01/editor.DEFOCUS_FADE_TIME)
                    SetFrameAlpha(codeEditorParent, (editor.fadeState*255 + (1 - editor.fadeState)*editor.DEFOCUS_FADE_OUT_ALPHA) // 1)
                end
            elseif editor.fadeState < 1 then
                editor.fadeState = 1 --min(1, editor.fadeState + 0.01/editor.FOCUS_FADE_TIME)
                SetFrameAlpha(codeEditorParent, (editor.fadeState*255 + (1 - editor.fadeState)*editor.DEFOCUS_FADE_OUT_ALPHA) // 1)
                editor.timeOfDefocus = nil
            end
        end

        if timeElapsed - edit.lastKeyStroke > editor.MIN_TIME_BETWEEN_UNDO_STEPS and tabs.hasUnsavedChanges[currentTab] and (not BlzFrameIsVisible(helper.parent) or helper.numSuggestionsVisible == 0) then
            local validCode = ConvertAndValidateLines(codeLines[currentTab][step[currentTab]], currentTab)
            tabs.hasUnsavedChanges[currentTab] = nil

            for i = 1, #triggers.onUndoStepCreated do
                triggers.onUndoStepCreated[i](validCode)
            end

            BlzFrameSetText(tabNavigator.titles[currentTab], editor.TAB_NAVIGATOR_SELECTED_COLOR .. tabs.truncatedNames[currentTab] .. "|r")

            if editor.ENABLE_SAVE_AND_LOAD and FileIO then
                Export()
            end
        end

        newValue = highestNonEmptyLine[currentTab][step[currentTab]] - BlzFrameGetValue(codeScroller)
        if newValue ~= tabs.lineNumberOffset[currentTab] then
            if selection.hasSelection then
                HideSelection()
            end
            tabs.lineNumberOffset[currentTab] = newValue
            HideHelperAndAllAutoCompleteFrames()

            for i = 1, editor.MAX_LINES_ON_SCREEN do
                RenderLine(i, codeLines[currentTab][step[currentTab]][i + tabs.lineNumberOffset[currentTab]], coloredCodeLines[currentTab][step[currentTab]][i + tabs.lineNumberOffset[currentTab]])
                if lineNumberWasExecuted[currentTab][i + tabs.lineNumberOffset[currentTab]] then
                    BlzFrameSetText(lineNumberFrames[i], editor.LINE_NUMBER_COLOR .. math.tointeger(i + tabs.lineNumberOffset[currentTab]) .. "|r")
                else
                    BlzFrameSetText(lineNumberFrames[i], editor.IDLE_LINE_NUMBER_COLOR .. math.tointeger(i + tabs.lineNumberOffset[currentTab]) .. "|r")
                end
                BlzFrameSetTexture(BlzFrameGetChild(stopButtons[i], 0), LINE_STATE_ICONS[lines.debugState[currentTab][i + tabs.lineNumberOffset[currentTab]]], 0, true)
            end

            SetCurrentLine()

            if cursor.codeLineNumber then
                cursor.screenLineNumber = cursor.codeLineNumber - tabs.lineNumberOffset[currentTab]
                BlzFrameSetPoint(cursorFrame, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + cursor.x, -editor.CODE_TOP_INSET - cursor.screenLineNumber*editor.LINE_SPACING)
                BlzFrameSetVisible(cursorFrame, editBoxFocused and cursor.screenLineNumber >= 1 and cursor.screenLineNumber <= editor.MAX_LINES_ON_SCREEN)
            end

            if tabs.hasError[currentTab] then
                BlzFrameSetPoint(highlights.error, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET, -editor.CODE_TOP_INSET - editor.LINE_SPACING*(lineNumbers.error[currentTab] - tabs.lineNumberOffset[currentTab]))
                BlzFrameSetPoint(highlights.error, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPRIGHT, -editor.CODE_RIGHT_INSET, -editor.CODE_TOP_INSET - editor.LINE_SPACING*(lineNumbers.error[currentTab] - tabs.lineNumberOffset[currentTab] - 1))
            end
            BlzFrameSetVisible(highlights.error, tabs.hasError[currentTab] and lineNumbers.error[currentTab] - tabs.lineNumberOffset[currentTab] >= 1 and lineNumbers.error[currentTab] - tabs.lineNumberOffset[currentTab] <= editor.MAX_LINES_ON_SCREEN)

            if highlights.custom[currentTab] then
                BlzFrameSetVisible(highlights.custom.frame, true)
                local minY = -editor.CODE_TOP_INSET - editor.LINE_SPACING*max(0, min(editor.MAX_LINES_ON_SCREEN, highlights.custom[currentTab].lastLine - tabs.lineNumberOffset[currentTab]))
                local maxY = -editor.CODE_TOP_INSET - editor.LINE_SPACING*max(0, min(editor.MAX_LINES_ON_SCREEN, highlights.custom[currentTab].firstLine - tabs.lineNumberOffset[currentTab] - 1))
                BlzFrameSetPoint(highlights.custom.frame, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET, minY)
                BlzFrameSetPoint(highlights.custom.frame, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPRIGHT, -editor.CODE_RIGHT_INSET, maxY)
            end

            if selection.hasSelection then
                SetSelection()
            end

            if selection.hasSelection and selection.startLine == selection.endLine then
                SearchForDuplicates()
            end

            if brackets.lines[1] then
                local screenLineNumber = brackets.lines[1] - tabs.lineNumberOffset[currentTab]
                if screenLineNumber >= 1 and screenLineNumber <= editor.MAX_LINES_ON_SCREEN then
                    BlzFrameSetVisible(brackets.highlights[1], true)
                    BlzFrameSetPoint(brackets.highlights[1], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(codeLines[currentTab][step[currentTab]][brackets.lines[1]], tabs.horizontalOffset[currentTab] + 1, brackets.pos[1] - 1)), -editor.CODE_TOP_INSET - screenLineNumber*editor.LINE_SPACING)
                    BlzFrameSetPoint(brackets.highlights[1], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(codeLines[currentTab][step[currentTab]][brackets.lines[1]], tabs.horizontalOffset[currentTab] + 1, brackets.pos[1])), -editor.CODE_TOP_INSET - (screenLineNumber - 1)*editor.LINE_SPACING)
                else
                    BlzFrameSetVisible(brackets.highlights[1], false)
                end
                screenLineNumber = brackets.lines[2] - tabs.lineNumberOffset[currentTab]
                if screenLineNumber >= 1 and screenLineNumber <= editor.MAX_LINES_ON_SCREEN then
                    BlzFrameSetVisible(brackets.highlights[2], true)
                    BlzFrameSetPoint(brackets.highlights[2], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(codeLines[currentTab][step[currentTab]][brackets.lines[2]], tabs.horizontalOffset[currentTab] + 1, brackets.pos[2] - 1)), -editor.CODE_TOP_INSET - screenLineNumber*editor.LINE_SPACING)
                    BlzFrameSetPoint(brackets.highlights[2], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(codeLines[currentTab][step[currentTab]][brackets.lines[2]], tabs.horizontalOffset[currentTab] + 1, brackets.pos[2])), -editor.CODE_TOP_INSET - (screenLineNumber - 1)*editor.LINE_SPACING)
                else
                    BlzFrameSetVisible(brackets.highlights[2], false)
                end
            end

            if BlzFrameIsVisible(searchBar.parent) then
                RenderSearchHighlights()
            end
        end

        --Variable Viewer Scroller
        local maxOffset = max(0, variableViewer.numVisibleVarsTotal - editor.MAX_LINES_ON_SCREEN)

        newValue = maxOffset - BlzFrameGetValue(variableViewer.scroller)

        local key = GetVariableViewerOffsetKey()

        if newValue ~= variableViewer.lineNumberOffset[key] then
            variableViewer.lineNumberOffset[key] = newValue
            UpdateVariableViewer(lineNumbers.lastViewed[currentTab] or lastLineNumber[currentTab], true, true)
        end
    end

    local function InsertCodeLine()
        if not editor.isLocked then
            BlzFrameSetFocus(editBox, true)
        end
        helper.selectedSuggestion = nil
        BlzFrameSetVisible(helper.parent, false)
        BlzFrameSetVisible(variableViewer.parent, false)

        WSCode.IncrementStep()
        local currentLines = codeLines[currentTab][step[currentTab]]

        tabs.hasError[currentTab] = false
        doNotUpdateVariables[currentTab] = false
        tabs.hasUnsavedChanges[currentTab] = true
        cursor.posOfLineJumps = nil
        edit.lastKeyStroke = timeElapsed
        if editor.ENABLE_SAVE_AND_LOAD and FileIO then
            BlzFrameSetText(tabNavigator.titles[currentTab], editor.TAB_NAVIGATOR_UNSAVED_COLOR .. "*" .. tabs.truncatedNames[currentTab] .. "|r")
        end

        local openTwoLines = brackets.IS_BRACKET[sub(currentLines[cursor.codeLineNumber], cursor.pos, cursor.pos)] and brackets.CORRESPONDING_BRACKET[sub(currentLines[cursor.codeLineNumber], cursor.pos, cursor.pos)] == sub(currentLines[cursor.codeLineNumber], cursor.pos + 1, cursor.pos + 1)
        local shift = openTwoLines and 2 or 1

        ShiftLines(shift, cursor.codeLineNumber + 1)

        currentLines[cursor.codeLineNumber + shift] = sub(currentLines[cursor.codeLineNumber], cursor.pos + 1)
        coloredCodeLines[currentTab][step[currentTab]][cursor.codeLineNumber + shift] = nil
        currentLines[cursor.codeLineNumber] = sub(currentLines[cursor.codeLineNumber], 1, cursor.pos)
        coloredCodeLines[currentTab][step[currentTab]][cursor.codeLineNumber] = nil

        if shift == 2 then
            currentLines[cursor.codeLineNumber + 1] = ""
            coloredCodeLines[currentTab][step[currentTab]][cursor.codeLineNumber + 1] = nil
        end

        lines.debugState[currentTab][cursor.codeLineNumber + shift] = 0
        BlzFrameSetTexture(BlzFrameGetChild(stopButtons[cursor.screenLineNumber + shift], 0), editor.ASSET_SUBFOLDER .. "\\transparentmask.blp", 0, true)

        local lastLine = currentLines[cursor.codeLineNumber]
        local __, numSpaces = find(lastLine, "^%s*")
        if LineOpensScope(lastLine) then
            numSpaces = numSpaces + 4
        end
        if currentLines[cursor.codeLineNumber + 1]:match("^%s*end")
        or currentLines[cursor.codeLineNumber + 1]:match("^%s*}")
        or currentLines[cursor.codeLineNumber + 1]:match("^%s*%)")
        or currentLines[cursor.codeLineNumber + 1]:match("^%s*until")
        or currentLines[cursor.codeLineNumber + 1]:match("^%s*else") then
            numSpaces = max(0, numSpaces - 4)
        end

        cursor.screenLineNumber = cursor.screenLineNumber + 1
        cursor.codeLineNumber = cursor.codeLineNumber + 1
        SetCursorPos(numSpaces)

        local offset = BlzFrameGetValue(codeHorizontalScroller)
        if offset > numSpaces then
            BlzFrameSetValue(codeHorizontalScroller, max(0, numSpaces - editor.MAX_HORIZONTAL_SCROLL_BUFFER))
        end

        highestNonEmptyLine[currentTab][step[currentTab]] = highestNonEmptyLine[currentTab][step[currentTab]] + shift
        for __ = 1, numSpaces do
            currentLines[cursor.codeLineNumber] = " " .. currentLines[cursor.codeLineNumber]
        end
        coloredCodeLines[currentTab][step[currentTab]][cursor.codeLineNumber] = nil
        if shift == 2 then
            for __ = 1, numSpaces - 4 do
                currentLines[cursor.codeLineNumber + 1] = " " .. currentLines[cursor.codeLineNumber + 1]
            end
            coloredCodeLines[currentTab][step[currentTab]][cursor.codeLineNumber + 1] = nil
        end

        SetCursorX(sub(currentLines[cursor.codeLineNumber], tabs.horizontalOffset[currentTab] + 1, cursor.pos))

        BlzFrameSetMinMaxValue(codeScroller, 0, highestNonEmptyLine[currentTab][step[currentTab]])

        SetLineOffset(tabs.lineNumberOffset[currentTab])
        if not JumpWindow(cursor.codeLineNumber) then
            UpdateAllLines()
        end

        SetLocalList(cursor.codeLineNumber)
    end

    --======================================================================================================================
    --Variable Viewer
    --======================================================================================================================

    Value2String = function(object, tableKey, maxLength, showFourCC)
        local returnstr
        local objectType = type(object)
        if object == WSDebug.Nil or object == nil then
            returnstr =  "nil"
        elseif objectType == "boolean" or object == nil then
            returnstr =  tostring(object)
        elseif objectType == "number" then
            if showFourCC and objectType == "number" and math.type(object) == "integer" and object >= 808464432 then
                returnstr = object .. " ('" .. string.pack(">I4", object) .. "')"
            else
                returnstr =  tostring(object)
            end
        elseif objectType == "string" then
            object = object:gsub("|", "||")
            if tableKey and not tonumber(object) then
                returnstr = sub(object, 1, maxLength)
            else
                returnstr =  '"' .. sub(object, 1, maxLength - 2) .. '"'
            end
        elseif objectType == "function" and WSDebug.FuncNames[object] then
            returnstr = "function: " .. WSDebug.FuncNames[object]
        elseif IsHandle[object] then
            if IsWidget[object] then
                if HandleType[object] == "unit" then
                    local str = string.gsub(tostring(object), "unit: ", "")
                    if sub(str, 1,1) == "0" then
                        returnstr =  GetUnitName(object) .. ": " .. sub(str, str:len() - 3, str:len())
                    else
                        returnstr =  str
                    end
                elseif HandleType[object] == "destructable" then
                    local str = string.gsub(tostring(object), "destructable: ", "")
                    if sub(str, 1,1) == "0" then
                        returnstr =  GetDestructableName(object) .. ": " .. sub(str, str:len() - 3, str:len())
                    else
                        returnstr =  str
                    end
                else
                    local str = string.gsub(tostring(object), "item: ", "")
                    if sub(str, 1,1) == "0" then
                        returnstr =  GetItemName(object) .. ": " .. sub(str, str:len() - 3, str:len())
                    else
                        returnstr =  str
                    end
                end
            else
                local str = tostring(object)
                local address = sub(str, (find(str, ":", nil, true) or 0) + 2, str:len())
                returnstr =  HandleType[object] .. (sub(address, 1,1) == "0" and (": " .. sub(address, address:len() - 3, address:len())) or (": " .. address))
            end
        elseif objectType == "table" and rawget(object, "__name") then
            local str = string.gsub(tostring(object), object.__name .. ": ", "")
            str = string.sub(str, #str - 3, #str)
            returnstr =  object.__name .. " " .. str
        else
            local str = tostring(object)
            local colonPos = find(str, ":")
            if sub(str, colonPos + 2, colonPos + 2) == "0" then
                returnstr =  sub(str, 1, colonPos) .. " " .. sub(str, #str - 3, #str)
            else
                returnstr =  str
            end
        end
        if tableKey and objectType ~= "string" then
            return "[" .. sub(returnstr, 1, maxLength - 2) .. "]"
        else
            return sub(returnstr, 1, maxLength)
        end
    end

    local function PadNumber(num)
        local tonum = tonumber(num)
        if tonum and tonum < math.maxinteger and tonum > math.mininteger then
            return ("%09d"):format(tonum)
        else
            return num
        end
    end

    local function NaturalSort(a, b)
        local aPad = a:gsub("(%d+)", PadNumber)
        local bPad = b:gsub("(%d+)", PadNumber)

        return aPad < bPad
    end

    local function SortTableKeys(a, b)
        local typeA, typeB = type(a), type(b)
        if typeA == typeB then
            return NaturalSort(tostring(a), tostring(b))
        elseif typeA == "number" or typeB == "number" then
            return typeA == "number"
        else
            return typeA < typeB
        end
    end

    local function ViewWorldObject(whichObject, doNotRedraw)
        if whichObject == nil then
            return
        end

        local x, y
        if IsWidget[whichObject] then
            x, y = GetWidgetX(whichObject), GetWidgetY(whichObject)
        elseif HandleType[whichObject] == "rect" then
            if not doNotRedraw then
                x, y = GetRectCenterX(whichObject), GetRectCenterY(whichObject)
                variableViewer.effects[1] = AddLightning("DRAM", false, GetRectMinX(whichObject), GetRectMinY(whichObject), GetRectMaxX(whichObject), GetRectMinY(whichObject))
                variableViewer.effects[2] = AddLightning("DRAM", false, GetRectMaxX(whichObject), GetRectMinY(whichObject), GetRectMaxX(whichObject), GetRectMaxY(whichObject))
                variableViewer.effects[3] = AddLightning("DRAM", false, GetRectMaxX(whichObject), GetRectMaxY(whichObject), GetRectMinX(whichObject), GetRectMaxY(whichObject))
                variableViewer.effects[4] = AddLightning("DRAM", false, GetRectMinX(whichObject), GetRectMaxY(whichObject), GetRectMinX(whichObject), GetRectMinY(whichObject))
            end
        elseif HandleType[whichObject] == "location" then
            if not doNotRedraw then
                x, y = GetLocationX(whichObject), GetLocationY(whichObject)
                variableViewer.effects[1] = AddSpecialEffect("Doodads\\Cinematic\\GlowingRunes\\GlowingRunes0.mdx", x, y)
            end
        elseif HandleType[whichObject] == "effect" then
            x, y = BlzGetLocalSpecialEffectX(whichObject), BlzGetLocalSpecialEffectY(whichObject)
        elseif HandleType[whichObject] == "camerasetup" then
            editor.ON_OBJECT_VIEW(whichObject, CameraSetupGetDestPositionX(whichObject), CameraSetupGetDestPositionY(whichObject))
        elseif type(whichObject) == "table" then
            if not doNotRedraw then
                if type(rawget(whichObject, "x")) == "number" and type(rawget(whichObject, "y")) == "number" then
                    x, y = rawget(whichObject, "x"), rawget(whichObject, "y")
                    if rawget(whichObject, "rot") and bj_RADTODEG*rawget(whichObject, "aoa") then
                        SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, bj_RADTODEG*rawget(whichObject, "aoa"), 0)
                        SetCameraField(CAMERA_FIELD_ROTATION, bj_RADTODEG*rawget(whichObject, "rot"), 0)
                        if rawget(whichObject, "zOff") then
                            SetCameraField(CAMERA_FIELD_ZOFFSET, rawget(whichObject, "zOff"), 0)
                        end
                        if rawget(whichObject, "dist") then
                            SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, rawget(whichObject, "dist"), 0)
                        end
                        if rawget(whichObject, "fov") then
                            SetCameraField(CAMERA_FIELD_FIELD_OF_VIEW, bj_RADTODEG*rawget(whichObject, "fov"), 0)
                        end
                        if rawget(whichObject, "localPitch") then
                            SetCameraField(CAMERA_FIELD_LOCAL_PITCH, bj_RADTODEG*rawget(whichObject, "localPitch"), 0)
                        end
                    else
                        variableViewer.effects[1] = AddSpecialEffect("Doodads\\Cinematic\\GlowingRunes\\GlowingRunes0.mdx", x, y)
                        local z = rawget(whichObject, "z")
                        if z then
                            BlzSetSpecialEffectZ(variableViewer.effects[1], z)
                        end
                    end
                elseif type(rawget(whichObject, "minX")) == "number" and type(rawget(whichObject, "minY")) == "number" and type(rawget(whichObject, "maxX")) == "number" and type(rawget(whichObject, "maxY")) == "number" then
                    x, y = (rawget(whichObject, "minX") + rawget(whichObject, "maxX"))/2, (rawget(whichObject, "minY") + rawget(whichObject, "maxY"))/2
                    variableViewer.effects[1] = AddLightning("DRAM", false, whichObject.minX, whichObject.minY, whichObject.maxX, whichObject.minY)
                    variableViewer.effects[2] = AddLightning("DRAM", false, whichObject.maxX, whichObject.minY, whichObject.maxX, whichObject.maxY)
                    variableViewer.effects[3] = AddLightning("DRAM", false, whichObject.maxX, whichObject.maxY, whichObject.minX, whichObject.maxY)
                    variableViewer.effects[4] = AddLightning("DRAM", false, whichObject.minX, whichObject.maxY, whichObject.minX, whichObject.minY)
                end
            end
        end
        if x and y and (x ~= 0 or y ~= 0) then
            editor.ON_OBJECT_VIEW(whichObject, x, y)
        end
    end

    local function ShowObjectProperties(whichObject, disableFrames)
        if whichObject == nil then
            return
        end

        if type(whichObject) == "function" then
            local sourceCodeIndex = WSDebug.SourceCodeIndex[whichObject]
            if sourceCodeIndex then
                local sourceCode = WSDebug.SourceCode[sourceCodeIndex]
                local deindent = #match(sourceCode[1], "(%s*)")
                if deindent > 0 then
                    for i = 1, #sourceCode do
                        sourceCode[i] = sub(sourceCode[i], deindent + 1)
                    end
                end
                local functionArgs = match(sourceCode[1], "function[%w%s_]*%((.*)")
                if functionArgs then
                    sourceCode[1] = "function(" .. functionArgs
                end
                for i = 1, min(#sourceCode, editor.MAX_LINES_ON_SCREEN) do
                    BlzFrameSetText(variableViewer.frames[i], sourceCode[i])
                    BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[i]], "")
                end
            end
        elseif HandleType[whichObject] == "unit" or HandleType[whichObject] == "destructable" or HandleType[whichObject] == "item" then
            BlzFrameSetText(variableViewer.frames[1], "fourCC")
            if HandleType[whichObject] == "unit" then
                BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[1]], string.pack(">I4", GetUnitTypeId(whichObject)))
            elseif HandleType[whichObject] == "destructable" then
                BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[1]], string.pack(">I4", GetDestructableTypeId(whichObject)))
            else
                BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[1]], string.pack(">I4", GetItemTypeId(whichObject)))
            end

            BlzFrameSetText(variableViewer.frames[2], "x")
            BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[2]], tostring(math.floor(GetUnitX(whichObject))))
            BlzFrameSetText(variableViewer.frames[3], "y")
            BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[3]], tostring(math.floor(GetUnitY(whichObject))))
        elseif HandleType[whichObject] == "framehandle" then
            if GetHandleId(whichObject) == 0 then
                BlzFrameSetText(variableViewer.frames[1], "|cffff0000INVALID FRAME|r")
                BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[1]], "")
            else
                local numChildren = BlzFrameGetChildrenCount(whichObject)
                BlzFrameSetText(variableViewer.frames[1], "parent")
                BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[1]], Value2String(BlzFrameGetParent(whichObject)))
                for i = 0, numChildren - 1 do
                    BlzFrameSetText(variableViewer.frames[i + 2], "child " .. i)
                    BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[i + 2]], Value2String(BlzFrameGetChild(whichObject, i)))
                end
            end
        elseif HandleType[whichObject] == "location" then
            BlzFrameSetText(variableViewer.frames[1], "x")
            BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[1]], tostring(math.floor(GetLocationX(whichObject))))
            BlzFrameSetText(variableViewer.frames[2], "y")
            BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[2]], tostring(math.floor(GetLocationY(whichObject))))
        elseif HandleType[whichObject] == "rect" then
            BlzFrameSetText(variableViewer.frames[1], "minX")
            BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[1]], tostring(math.floor(GetRectMinX(whichObject))))
            BlzFrameSetText(variableViewer.frames[2], "minY")
            BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[2]], tostring(math.floor(GetRectMinY(whichObject))))
            BlzFrameSetText(variableViewer.frames[3], "maxX|r")
            BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[3]], tostring(math.floor(GetRectMaxX(whichObject))))
            BlzFrameSetText(variableViewer.frames[4], "maxY|r")
            BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[4]], tostring(math.floor(GetRectMaxY(whichObject))))
        elseif HandleType[whichObject] == "group" then
            local size = BlzGroupGetSize(whichObject)
            if size > 0 then
                for i = 0, size - 1 do
                    BlzFrameSetText(variableViewer.frames[i + 1], "unit " .. i)
                    BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[i + 1]], Value2String(BlzGroupUnitAt(whichObject, i)))
                end
            else
                BlzFrameSetText(variableViewer.frames[1], "|cffaaaaaaEmpty Group|r")
                BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[1]], "")
            end
        elseif HandleType[whichObject] == "trigger" then
            BlzFrameSetText(variableViewer.frames[1], "Enabled")
            BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[1]], tostring(IsTriggerEnabled(whichObject)))
            BlzFrameSetText(variableViewer.frames[2], "Execution count")
            BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[2]], tostring(GetTriggerExecCount(whichObject)))
        elseif HandleType[whichObject] == "camerasetup" then
            BlzFrameSetText(variableViewer.frames[1], "x")
            BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[1]], tostring(math.floor(CameraSetupGetDestPositionX(whichObject))))
            BlzFrameSetText(variableViewer.frames[2], "y")
            BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[2]], tostring(math.floor(CameraSetupGetDestPositionY(whichObject))))
            BlzFrameSetText(variableViewer.frames[3], "zOffset")
            BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[3]], tostring(math.floor(CameraSetupGetField(whichObject, CAMERA_FIELD_ZOFFSET))))
            BlzFrameSetText(variableViewer.frames[4], "rotation")
            BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[4]], string.format("%.2f", CameraSetupGetField(whichObject, CAMERA_FIELD_ROTATION)))
            BlzFrameSetText(variableViewer.frames[5], "angle of attack")
            BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[5]], string.format("%.2f", CameraSetupGetField(whichObject, CAMERA_FIELD_ANGLE_OF_ATTACK)))
            BlzFrameSetText(variableViewer.frames[6], "target distance")
            BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[6]], tostring(math.floor(CameraSetupGetField(whichObject, CAMERA_FIELD_TARGET_DISTANCE))))
            BlzFrameSetText(variableViewer.frames[7], "field of view")
            BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[7]], string.format("%.2f", CameraSetupGetField(whichObject, CAMERA_FIELD_FIELD_OF_VIEW)))
            BlzFrameSetText(variableViewer.frames[8], "farZ")
            BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[8]], tostring(math.floor(CameraSetupGetField(whichObject, CAMERA_FIELD_FARZ))))
        end

        for i = 1, variableViewer.numVisibleVarsScreen do
            BlzFrameSetEnable(variableViewer.valueFrames[i], not disableFrames)
        end
    end

    local function InitObjectDisplay(whichObject)
        local numProperties = 1
        local displayObject = true
        local disableFrames = true
        if type(whichObject) == "function" then
            local sourceCodeIndex = WSDebug.SourceCodeIndex[whichObject]
            if sourceCodeIndex then
                local sourceCode = WSDebug.SourceCode[sourceCodeIndex]
                numProperties = #sourceCode
                displayObject = false
            else
                displayObject = true
            end
        elseif whichObject == nil then
            numProperties = 0
        elseif HandleType[whichObject] == "unit" or HandleType[whichObject] == "destructable" or HandleType[whichObject] == "item" then
            numProperties = 3
            displayObject = false
        elseif HandleType[whichObject] == "framehandle" then
            displayObject = false
            if GetHandleId(whichObject) == 0 then
                numProperties = 1
            else
                local numChildren = BlzFrameGetChildrenCount(whichObject)
                numProperties = numChildren + 1
            end
            disableFrames = false
        elseif HandleType[whichObject] == "location" then
            numProperties = 2
            displayObject = false
        elseif HandleType[whichObject] == "rect" then
            numProperties = 4
            displayObject = false
        elseif HandleType[whichObject] == "group" then
            numProperties = BlzGroupGetSize(whichObject)
            displayObject = false
            if numProperties == 0 then
                numProperties = 1
            else
                disableFrames = false
            end
        elseif HandleType[whichObject] == "trigger" then
            numProperties = 2
            displayObject = false
        elseif HandleType[whichObject] == "camerasetup" then
            numProperties = 8
            displayObject = false
        end

        return numProperties, displayObject, disableFrames
    end

    GetVariableViewerOffsetKey = function()
        local key = currentTab
        for i = 1, #variableViewer.viewedVariableTrace do
            key = key .. "_ws_" .. tostring(variableViewer.viewedVariableTrace[i])
        end
        return key
    end

    local function ViewVariable()
        local frame = BlzGetTriggerFrame()
        BlzFrameSetEnable(frame, false)
        BlzFrameSetEnable(frame, true)

        local whichVar = variableViewer.nameFromFrame[frame]
        local inRoot = #variableViewer.viewedVariableTrace == 0

        WSCode.DestroyAllWorldObjectVisualizers()

        if inRoot then
            variableViewer.isViewingGlobal = false
            for __, name in ipairs(variableViewer.viewedGlobals) do
                if name == whichVar then
                    variableViewer.isViewingGlobal = true
                    break
                end
            end
            if variableViewer.isViewingGlobal then
                variableViewer.viewedVariable = whichVar
                variableViewer.viewedVariableTrace[1] = whichVar
                variableViewer.viewedValueTrace[1] = _ENV[whichVar]
            else
                local level = visibleVarsOfLine[currentTab][lineNumbers.lastViewed[currentTab] or lastLineNumber[currentTab]][whichVar]
                variableViewer.viewedVariable = whichVar
                variableViewer.viewedVariableTrace[1] = whichVar
                variableViewer.viewedValueTrace[1] = WSDebug.VarTable[currentTab][level][whichVar]
            end
        elseif HandleType[variableViewer.viewedValueTrace[#variableViewer.viewedValueTrace]] == "framehandle" then
            local index = indexFromFrame[frame] + variableViewer.lineNumberOffset[GetVariableViewerOffsetKey()]
            if index == 1 then
                if find(variableViewer.viewedVariableTrace[#variableViewer.viewedVariableTrace], "__childFrame") then
                    variableViewer.viewedVariableTrace[#variableViewer.viewedVariableTrace] = nil
                    variableViewer.viewedValueTrace[#variableViewer.viewedValueTrace] = nil
                else
                    variableViewer.viewedVariableTrace[#variableViewer.viewedVariableTrace + 1] = "__parentFrame"
                    variableViewer.viewedValueTrace[#variableViewer.viewedValueTrace + 1] = BlzFrameGetParent(variableViewer.viewedValueTrace[#variableViewer.viewedValueTrace])
                end
            else
                variableViewer.viewedVariableTrace[#variableViewer.viewedVariableTrace + 1] = "__childFrame " .. (index - 2)
                variableViewer.viewedValueTrace[#variableViewer.viewedValueTrace + 1] = BlzFrameGetChild(variableViewer.viewedValueTrace[#variableViewer.viewedValueTrace], index - 2)
            end
        elseif HandleType[variableViewer.viewedValueTrace[#variableViewer.viewedValueTrace]] == "group" then
            local index = indexFromFrame[frame] + variableViewer.lineNumberOffset[GetVariableViewerOffsetKey()]
            variableViewer.viewedVariableTrace[#variableViewer.viewedVariableTrace + 1] = "__unit " .. (index - 1)
            variableViewer.viewedValueTrace[#variableViewer.viewedValueTrace + 1] = BlzGroupUnitAt(variableViewer.viewedValueTrace[#variableViewer.viewedValueTrace], index - 1)
        elseif whichVar == "__metatable" then
            variableViewer.viewedVariableTrace[#variableViewer.viewedVariableTrace + 1] = whichVar
            variableViewer.viewedValueTrace[#variableViewer.viewedValueTrace + 1] = getmetatable(variableViewer.viewedValueTrace[#variableViewer.viewedValueTrace])
        else
            variableViewer.viewedVariableTrace[#variableViewer.viewedVariableTrace + 1] = whichVar
            variableViewer.viewedValueTrace[#variableViewer.viewedValueTrace + 1] = variableViewer.viewedValueTrace[#variableViewer.viewedValueTrace][whichVar]
        end

        variableViewer.forceScrollerUpdate = true
        UpdateVariableViewer(lineNumbers.lastViewed[currentTab] or lastLineNumber[currentTab])
    end

    local function ToggleVariableViewerScrollerVisibility(enable)
        if enable == variableViewer.scrollerIsVisible then
            return
        end

        BlzFrameSetVisible(variableViewer.scroller, enable)

        variableViewer.scrollerIsVisible = enable
        local scale = variableViewer.TEXT_SCALE
        if enable then
            for i = 1, editor.MAX_LINES_ON_SCREEN do
                BlzFrameSetPoint(variableViewer.valueFrames[i], FRAMEPOINT_TOPRIGHT, variableViewer.parent, FRAMEPOINT_TOPRIGHT, -(variableViewer.LINE_HORIZONTAL_INSET + variableViewer.SCROLLER_VARIABLE_DISPLACEMENT)/scale, (-variableViewer.LINE_VERTICAL_INSET - (i - 1)*editor.LINE_SPACING)/scale)
            end
        else
            for i = 1, editor.MAX_LINES_ON_SCREEN do
                BlzFrameSetPoint(variableViewer.valueFrames[i], FRAMEPOINT_TOPRIGHT, variableViewer.parent, FRAMEPOINT_TOPRIGHT, -variableViewer.LINE_HORIZONTAL_INSET/scale, (-variableViewer.LINE_VERTICAL_INSET - (i - 1)*editor.LINE_SPACING)/scale)
            end
        end
    end

    UpdateVariableViewer = function(lineNumber, doNotRedraw, doNotReorder)
        if not codeEditorParent then
            return
        end

        if variableViewer.hasNotBeenExpanded and not variableViewer.isExpanded then
            ToggleVariableViewerExpand()
        end

        local inRoot = #variableViewer.viewedVariableTrace == 0
        local lastVariable, lastValue
        local numHiddenVars = 0

        BlzFrameSetVisible(variableViewer.parent, true)

        local oldNumVisible = variableViewer.numVisibleVarsTotal
        local oldNumVisibleOnScreen = variableViewer.numVisibleVarsScreen

        local varNames, varValues

        local isAlreadyViewed, showObject, disableFrames
        if not doNotReorder then
            variableViewer.varNames = {}
            variableViewer.varValues = {}

            varNames = variableViewer.varNames
            varValues = variableViewer.varValues

            if inRoot then
                variableViewer.numVisibleVarsTotal = #variableViewer.viewedGlobals
                variableViewer.isViewingParams = nil
                local visibleVars = visibleVarsOfLine[currentTab][lineNumber]
                for var, level in next, visibleVars do
                    if (not flags.hideConstants or #var == 1 or find(var, "%l")) and (not flags.hideGlobals or level ~= -1) and (not flags.hideFunctions or type(WSDebug.VarTable[currentTab][level][var]) ~= "function") then
                        if level == -1 then
                            WSDebug.VarTable[currentTab][level][var] = _ENV[var]
                            isAlreadyViewed = false
                            for i = 1, #variableViewer.viewedGlobals do
                                if variableViewer.viewedGlobals[i] == var then
                                    isAlreadyViewed = true
                                    break
                                end
                            end
                            if not isAlreadyViewed then
                                varNames[#varNames + 1] = var
                                varValues[var] = WSDebug.VarTable[currentTab][level][var]
                                varLevelExecution[currentTab][var] = level
                                variableViewer.numVisibleVarsTotal = variableViewer.numVisibleVarsTotal + 1
                            end
                        else
                            varNames[#varNames + 1] = var
                            varValues[var] = WSDebug.VarTable[currentTab][level][var]
                            varLevelExecution[currentTab][var] = level
                            variableViewer.numVisibleVarsTotal = variableViewer.numVisibleVarsTotal + 1
                        end
                    else
                        numHiddenVars = numHiddenVars + 1
                    end
                end
                table.sort(varNames, NaturalSort)
            else
                variableViewer.numVisibleVarsTotal = 0
                local viewedVariableIsVisible = variableViewer.isViewingParams or variableViewer.isViewingGlobal
                if not viewedVariableIsVisible then
                    for var, __ in next, visibleVarsOfLine[currentTab][lineNumber] do
                        if var == variableViewer.viewedVariable then
                            viewedVariableIsVisible = true
                            break
                        end
                    end
                end
                if viewedVariableIsVisible then
                    local viewedVar = variableViewer.viewedVariableTrace[1]
                    if variableViewer.isViewingGlobal then
                        variableViewer.viewedValueTrace[1] = _ENV[viewedVar]
                    else
                        local level = visibleVarsOfLine[currentTab][lineNumbers.lastViewed[currentTab] or lastLineNumber[currentTab]][viewedVar]
                        variableViewer.viewedValueTrace[1] = WSDebug.VarTable[currentTab][level][viewedVar]
                    end
                    for i = 2, #variableViewer.viewedVariableTrace do
                        local thisVar = variableViewer.viewedVariableTrace[i]
                        if type(thisVar) == "string" then
                            if thisVar == "__metatable" then
                                variableViewer.viewedValueTrace[i] = getmetatable(variableViewer.viewedValueTrace[i - 1])
                            elseif thisVar == "__parentFrame" then
                                variableViewer.viewedValueTrace[i] = BlzFrameGetParent(variableViewer.viewedValueTrace[i - 1])
                            elseif find(thisVar, "__childFrame") then
                                variableViewer.viewedValueTrace[i] = BlzFrameGetChild(variableViewer.viewedValueTrace[i - 1], tonumber(match(thisVar, "%d+$")))
                            elseif find(thisVar, "__unit") then
                                variableViewer.viewedValueTrace[i] = BlzGroupUnitAt(variableViewer.viewedValueTrace[i - 1], tonumber(match(thisVar, "%d+$")))
                            else
                                variableViewer.viewedValueTrace[i] = variableViewer.viewedValueTrace[i - 1][thisVar]
                            end
                        else
                            variableViewer.viewedValueTrace[i] = variableViewer.viewedValueTrace[i - 1][thisVar]
                        end
                        if not variableViewer.viewedValueTrace[i] then
                            viewedVariableIsVisible = false
                            break
                        end
                    end

                    if viewedVariableIsVisible then
                        lastVariable = variableViewer.viewedVariableTrace[#variableViewer.viewedVariableTrace]
                        if #variableViewer.viewedVariableTrace == 1 then
                            local level = visibleVarsOfLine[currentTab][lineNumber][lastVariable]
                            lastValue = level and WSDebug.VarTable[currentTab][level][lastVariable] or variableViewer.viewedValueTrace[#variableViewer.viewedValueTrace]
                        else
                            lastValue = variableViewer.viewedValueTrace[#variableViewer.viewedValueTrace]
                        end

                        if type(lastValue) == "table" then
                            if lastValue == WSDebug.Nil then
                                varNames[1] = "nil"
                                variableViewer.numVisibleVarsTotal = 1
                            else
                                for var, value in next, lastValue do
                                    varNames[#varNames + 1] = var
                                    varValues[var] = value
                                    variableViewer.numVisibleVarsTotal = variableViewer.numVisibleVarsTotal + 1
                                end

                                local mt = getmetatable(lastValue)
                                if mt then
                                    variableViewer.numVisibleVarsTotal = variableViewer.numVisibleVarsTotal + 1
                                    varNames[#varNames + 1] = "__metatable"
                                    varValues.__metatable = mt
                                end

                                if variableViewer.numVisibleVarsTotal == 0 then
                                    varNames[1] = "|cffaaaaaaEmpty Table|r"
                                    variableViewer.numVisibleVarsTotal = 1
                                else
                                    table.sort(varNames, SortTableKeys)
                                end
                            end
                        else
                            varNames[1] = lastVariable
                            varValues[1] = lastValue
                            variableViewer.numVisibleVarsTotal, showObject, disableFrames = InitObjectDisplay(varValues[1])
                        end
                    else
                        variableViewer.numVisibleVarsTotal = 0
                    end
                else
                    variableViewer.numVisibleVarsTotal = 0
                end
            end

            variableViewer.lastVariable = lastVariable
            variableViewer.lastValue = lastValue
            variableViewer.showObject = showObject
            variableViewer.disableFrames = disableFrames
            variableViewer.numHiddenVars = numHiddenVars
        else
            varNames = variableViewer.varNames
            varValues = variableViewer.varValues
            lastVariable = variableViewer.lastVariable
            lastValue = variableViewer.lastValue
            showObject = variableViewer.showObject
            disableFrames = variableViewer.disableFrames
            numHiddenVars = variableViewer.numHiddenVars
        end

        variableViewer.numVisibleVarsScreen = min(variableViewer.numVisibleVarsTotal, editor.MAX_LINES_ON_SCREEN)

        if not variableViewer.isExpanded then
            return
        end

        local key = GetVariableViewerOffsetKey()

        if oldNumVisible ~= variableViewer.numVisibleVarsTotal or variableViewer.forceScrollerUpdate then
            local maxOffset = max(0, variableViewer.numVisibleVarsTotal - editor.MAX_LINES_ON_SCREEN)

            variableViewer.lineNumberOffset[key] = min(variableViewer.lineNumberOffset[key], maxOffset)

            BlzFrameSetMinMaxValue(variableViewer.scroller, 0, maxOffset)
            BlzFrameSetValue(variableViewer.scroller, maxOffset - variableViewer.lineNumberOffset[key])
            ToggleVariableViewerScrollerVisibility(variableViewer.numVisibleVarsTotal > variableViewer.numVisibleVarsScreen)
        end

        for i = variableViewer.numVisibleVarsScreen + 1, oldNumVisibleOnScreen do
            BlzFrameSetVisible(variableViewer.frames[i], false)
            BlzFrameSetVisible(variableViewer.valueFrames[i], false)
        end

        variableViewer.forceScrollerUpdate = false

        BlzFrameSetVisible(buttons.back, not inRoot)

        local scale = variableViewer.TEXT_SCALE
        for i = oldNumVisibleOnScreen + 1, variableViewer.numVisibleVarsScreen do
            if not variableViewer.frames[i] then
                variableViewer.frames[i] = BlzCreateFrameByType("TEXT", "", variableViewer.parent, "", 0)
                BlzFrameSetPoint(variableViewer.frames[i], FRAMEPOINT_BOTTOMLEFT, variableViewer.parent, FRAMEPOINT_TOPLEFT, variableViewer.LINE_HORIZONTAL_INSET/scale, (-variableViewer.LINE_VERTICAL_INSET - i*editor.LINE_SPACING)/scale)
                BlzFrameSetPoint(variableViewer.frames[i], FRAMEPOINT_TOPRIGHT, variableViewer.parent, FRAMEPOINT_TOPRIGHT, -variableViewer.LINE_HORIZONTAL_INSET/scale, (-variableViewer.LINE_VERTICAL_INSET - (i - 1)*editor.LINE_SPACING)/scale)
                BlzFrameSetScale(variableViewer.frames[i], scale)
                BlzFrameSetTextAlignment(variableViewer.frames[i], TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
                indexFromFrame[variableViewer.frames[i]] = i
                BlzFrameSetEnable(variableViewer.frames[i], false)

                variableViewer.valueFrames[i] = BlzCreateFrame("VariableViewerButton", variableViewer.parent, 0, 0)
                variableViewer.textFrames[variableViewer.valueFrames[i]] = BlzFrameGetChild(variableViewer.valueFrames[i], 0)
                BlzFrameSetEnable(variableViewer.textFrames[variableViewer.valueFrames[i]], false)
                BlzFrameSetPoint(variableViewer.valueFrames[i], FRAMEPOINT_BOTTOMLEFT, variableViewer.parent, FRAMEPOINT_TOPLEFT, variableViewer.LINE_HORIZONTAL_INSET/scale, (-variableViewer.LINE_VERTICAL_INSET - i*editor.LINE_SPACING)/scale)
                BlzFrameSetPoint(variableViewer.valueFrames[i], FRAMEPOINT_TOPRIGHT, variableViewer.parent, FRAMEPOINT_TOPRIGHT, -(variableViewer.LINE_HORIZONTAL_INSET + (variableViewer.scrollerIsVisible and variableViewer.SCROLLER_VARIABLE_DISPLACEMENT or 0))/scale, (-variableViewer.LINE_VERTICAL_INSET - (i - 1)*editor.LINE_SPACING)/scale)
                BlzFrameSetScale(variableViewer.valueFrames[i], scale)
                BlzFrameSetTextAlignment(variableViewer.textFrames[variableViewer.valueFrames[i]], TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_RIGHT)
                BlzFrameSetAllPoints(variableViewer.textFrames[variableViewer.valueFrames[i]], variableViewer.valueFrames[i])
                indexFromFrame[variableViewer.valueFrames[i]] = i

                local trig = CreateTrigger()
                BlzTriggerRegisterFrameEvent(trig, variableViewer.valueFrames[i], FRAMEEVENT_CONTROL_CLICK)
                TriggerAddAction(trig, ViewVariable)

                BlzTriggerRegisterFrameEvent(variableViewer.scrollTrigger, variableViewer.valueFrames[i], FRAMEEVENT_MOUSE_WHEEL)
            else
                BlzFrameSetVisible(variableViewer.frames[i], true)
                BlzFrameSetVisible(variableViewer.valueFrames[i], true)
            end
        end

        BlzFrameSetSize(variableViewer.parent, variableViewer.WIDTH, editor.LINE_SPACING + variableViewer.LINE_VERTICAL_INSET + variableViewer.BOTTOM_SPACE + max(variableViewer.numVisibleVarsScreen - 1, 0)*editor.LINE_SPACING)

        local offset = variableViewer.lineNumberOffset[key]

        if inRoot then
            local j, f
            for i = 1 + offset, min(#varNames + #variableViewer.viewedGlobals, editor.MAX_LINES_ON_SCREEN + offset) do
                j = i - #variableViewer.viewedGlobals
                f = i - offset
                if j <= 0 then
                    BlzFrameSetText(variableViewer.frames[f], variableViewer.GLOBAL_COLOR .. variableViewer.viewedGlobals[i]:sub(1, variableViewer.VARIABLE_MAX_STRING_LENGTH) .. "|r")
                    BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[f]], variableViewer.GLOBAL_COLOR .. Value2String(_ENV[variableViewer.viewedGlobals[i]], false, variableViewer.VARIABLE_MAX_STRING_LENGTH))
                    BlzFrameSetEnable(variableViewer.valueFrames[f], true)
                    variableViewer.nameFromFrame[variableViewer.valueFrames[f]] = variableViewer.viewedGlobals[i]
                else
                    BlzFrameSetText(variableViewer.frames[f], (varLevelExecution[currentTab][varNames[j]] == -1 and variableViewer.GLOBAL_COLOR or variableViewer.LOCAL_COLOR) .. varNames[j]:sub(1, variableViewer.VARIABLE_MAX_STRING_LENGTH) .. "|r")
                    if varNames[j] == "..." then
                        BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[f]], "vararg")
                    else
                        BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[f]], (varLevelExecution[currentTab][varNames[j]] == -1 and variableViewer.GLOBAL_COLOR or variableViewer.LOCAL_COLOR) .. Value2String(varValues[varNames[j]], false, variableViewer.VARIABLE_MAX_STRING_LENGTH))
                    end
                    BlzFrameSetEnable(variableViewer.valueFrames[f], true)
                    variableViewer.nameFromFrame[variableViewer.valueFrames[f]] = varNames[j]
                end
            end

            if numHiddenVars == 0 then
                BlzFrameSetText(variableViewer.title, "|cffffcc00Variables|r")
            else
                BlzFrameSetText(variableViewer.title, "|cffffcc00Variables|r |cffaaaaaa(" .. numHiddenVars .. " hidden)")
            end
        elseif type(lastValue) == "table" then
            for i = 1 + offset, min(#varNames, editor.MAX_LINES_ON_SCREEN + offset) do
                local f = i - offset
                if varNames[i] == "|cffaaaaaaEmpty Table|r" or varNames[i] == "nil" then
                    BlzFrameSetText(variableViewer.frames[f], varNames[i])
                    BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[f]], "")
                    BlzFrameSetEnable(variableViewer.valueFrames[f], false)
                else
                    BlzFrameSetText(variableViewer.frames[f], variableViewer.LOCAL_COLOR .. Value2String(varNames[i], true, variableViewer.VARIABLE_MAX_STRING_LENGTH) .. "|r")
                    BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[f]], variableViewer.LOCAL_COLOR .. Value2String(varValues[varNames[i]], false, variableViewer.VARIABLE_MAX_STRING_LENGTH) .. "|r")
                    BlzFrameSetEnable(variableViewer.valueFrames[f], true)
                end
                variableViewer.nameFromFrame[variableViewer.valueFrames[f]] = varNames[i]
            end

            local origin = handleOrigin.tab[varValues[1]] and (" |cffaaaaaa(" .. handleOrigin.tab[varValues[1]] .. " " .. handleOrigin.line[varValues[1]] .. ")|r") or ""
            BlzFrameSetText(variableViewer.title, "|cffffcc00" .. tostring(lastVariable) .. "|r" .. origin)

            ViewWorldObject(lastValue, doNotRedraw)
        else
            if showObject then
                BlzFrameSetText(variableViewer.textFrames[variableViewer.valueFrames[1]], "")
                BlzFrameSetText(variableViewer.frames[1], Debug and Debug.original.tostring(varValues[1]) or tostring(varValues[1]))
                BlzFrameSetEnable(variableViewer.valueFrames[1], false)

                BlzFrameClearAllPoints(variableViewer.frames[1])
                BlzFrameSetPoint(variableViewer.frames[1], FRAMEPOINT_TOPLEFT, variableViewer.parent, FRAMEPOINT_TOPLEFT, variableViewer.LINE_HORIZONTAL_INSET/scale, -variableViewer.LINE_VERTICAL_INSET/scale)
                BlzFrameSetSize(variableViewer.frames[1], variableViewer.WIDTH - 2*variableViewer.LINE_HORIZONTAL_INSET, 0)
                BlzFrameSetSize(variableViewer.parent, variableViewer.WIDTH, math.min(editor.MAX_LINES_ON_SCREEN*editor.LINE_SPACING, BlzFrameGetHeight(variableViewer.frames[1])) + variableViewer.LINE_VERTICAL_INSET + variableViewer.BOTTOM_SPACE + (variableViewer.numVisibleVarsTotal - 1)*editor.LINE_SPACING)
            else
                ShowObjectProperties(varValues[1], disableFrames)
            end

            local origin = handleOrigin.tab[varValues[1]] and (" |cffaaaaaa(" .. handleOrigin.tab[varValues[1]] .. " " .. handleOrigin.line[varValues[1]] .. ")|r") or ""
            BlzFrameSetText(variableViewer.title, "|cffffcc00" .. tostring(lastVariable) .. "|r" .. origin)

            ViewWorldObject(varValues[1], doNotRedraw)
        end
    end

    local function GoBack()
        BlzFrameSetEnable(buttons.back, false)
        BlzFrameSetEnable(buttons.back, true)
        local whichObject = variableViewer.viewedValueTrace[#variableViewer.viewedValueTrace]
        variableViewer.viewedVariableTrace[#variableViewer.viewedVariableTrace] = nil
        variableViewer.viewedValueTrace[#variableViewer.viewedValueTrace] = nil

        WSCode.DestroyAllWorldObjectVisualizers()

        variableViewer.forceScrollerUpdate = true
        UpdateVariableViewer(lineNumbers.lastViewed[currentTab] or lastLineNumber[currentTab])
        if #variableViewer.viewedVariableTrace == 0 then
            editor.ON_OBJECT_UNVIEW(whichObject)
        end

        local s = CreateSound("Sound\\Interface\\BigButtonClick.flac" , false, false, false, 10, 10, "DefaultEAXON")
        SetSoundChannel(s, 0)
        StartSound(s)
        KillSoundWhenDone(s)
    end

    --======================================================================================================================
    --Tab Navigation
    --======================================================================================================================

    local function ClickTabButton()
        local whichFrame = BlzGetTriggerFrame()
        BlzFrameSetEnable(whichFrame, false)
        BlzFrameSetEnable(whichFrame, true)
        if tabs.numberFromFrame[whichFrame] ~= tabs.numbers[currentTab] then
            WSCode.SwitchToTab(tabs.numberFromFrame[whichFrame])
        end
    end

    local function AdjustTabWidths()
        local spaceRequired = 0
        for i = 1, tabs.amount do
            spaceRequired = spaceRequired + tabNavigator.widths[tabs.names[i]]
        end

        local spaceAlloted = (editor.isExpanded and editor.EXPANDED_WIDTH or editor.COLLAPSED_WIDTH) + tabs.amount*tabNavigator.OVERLAP - tabNavigator.HEIGHT
        if spaceRequired > spaceAlloted then
            for i = 1, tabs.amount do
                BlzFrameSetSize(tabNavigator.frames[tabs.names[i]], tabNavigator.widths[tabs.names[i]]*spaceAlloted/spaceRequired, tabNavigator.HEIGHT)
                if tabNavigator.widths[tabs.names[i]] > tabNavigator.WIDTH then
                    BlzFrameSetScale(tabNavigator.titles[tabs.names[i]], spaceAlloted/spaceRequired)
                else
                    BlzFrameSetScale(tabNavigator.titles[tabs.names[i]], 1)
                end
            end
        else
            for i = 1, tabs.amount do
                BlzFrameSetSize(tabNavigator.frames[tabs.names[i]], tabNavigator.widths[tabs.names[i]], tabNavigator.HEIGHT)
                BlzFrameSetScale(tabNavigator.titles[tabs.names[i]], 1)
            end
        end
    end

    --======================================================================================================================
    --Code Execution
    --======================================================================================================================

    JumpToError = function(fileName, lineNumber)
        if not editor.LOAD_EXTERNAL_SCRIPTS_ON_ERROR or not canJumpToError or not fileName or not lineNumber then
            return
        end

        local alreadyActive

        for j = 1, tabs.amount do
            if tabs.names[j] == fileName then
                alreadyActive = true
                break
            end
        end

        if not alreadyActive then
            local fileFound = false
            for i = 1, #fileNames do
                if fileNames[i] == fileName then
                    WSCode.Pull(fileName)
                    fileFound = true
                    break
                end
            end
            if not fileFound then
                return
            end
        end

        EnableEditor(user)
        WSCode.SwitchToTab(fileName)

        BlzFrameSetVisible(highlights.error, true)
        JumpWindow(lineNumber, true, true)

        lineNumbers.error[currentTab] = lineNumber
        BlzFrameSetPoint(highlights.error, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET, -editor.CODE_TOP_INSET - editor.LINE_SPACING*(lineNumbers.error[currentTab] - tabs.lineNumberOffset[currentTab]))
        BlzFrameSetPoint(highlights.error, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPRIGHT, -editor.CODE_RIGHT_INSET, -editor.CODE_TOP_INSET - editor.LINE_SPACING*(lineNumbers.error[currentTab] - tabs.lineNumberOffset[currentTab] - 1))

        lastLineNumber[currentTab] = lineNumber
        lineNumbers.lastViewed[currentTab] = lineNumber
        canJumpToError = false
        variableViewer.numVisibleVarsTotal = 0
        UpdateVariableViewer(lineNumbers.error[currentTab])

        for __, name in ipairs(tabs.names) do
            lineNumbers.lastViewed[name] = lastLineNumber[name]
        end

        tabs.hasError[currentTab] = true
        doNotUpdateVariables[currentTab] = true
        BlzFrameSetVisible(highlights.error, true)
    end

    local function Continue()
        if tabIsHalted[currentTab] and coroutine.status(currentCoroutine[currentTab]) == "suspended" then
            lastHaltedCoroutine = currentCoroutine[currentTab]
            canJumpToError = true
            coroutine.resume(currentCoroutine[currentTab])
        end
    end

    local function EvaluateBreakCondition(whichTab, lineNumber)
        if not breakCondition[whichTab].funcs then
            breakCondition[whichTab].funcs = {}
        end
        if not breakCondition[whichTab].funcs[lineNumber] then
            local generatorFunc = load("return function(lineNumber) " .. WSCode.GetLocalAccess(breakCondition[whichTab].funcStr, lineNumber, whichTab) .. " end", "BreakCondition", "t")
            if generatorFunc then
                breakCondition[whichTab].funcs[lineNumber] = generatorFunc()
                if type(breakCondition[whichTab].funcs[lineNumber]) ~= "function" then
                    WSDebug.PrintForUser("|cffff5555ERROR: Break condition did not compile into a valid function for tab " .. whichTab .. ", lineNumber " .. lineNumber .. ".")
                    breakCondition[whichTab].funcs[lineNumber] = load("return false")
                end
            else
                WSDebug.PrintForUser("|cffff5555ERROR: Invalid syntax in break condition function for tab " .. whichTab .. ", lineNumber " .. lineNumber .. ".")
                breakCondition[whichTab].funcs[lineNumber] = load("return false")
            end
        end
        return breakCondition[whichTab].funcs[lineNumber](lineNumber)
    end

    local function EvaluateInjectedEvalFunc(whichTab, lineNumber)
        if not lines.injectedEvalFuncs[whichTab][lineNumber] then
            if ALICE_TimeElapsed then
                lines.injectedEvalFuncs[whichTab][lineNumber] = load("local args = table.pack(" .. WSCode.GetLocalAccess(lines.injectedEvalStr[whichTab][lineNumber]) .. ") local str = '' for i = 1, args.n do if i > 1 then str = str .. ', ' end str = str .. tostring(args[i]) end print('" .. lines.injectedEvalStr[whichTab][lineNumber] .. " |cffaaaaaa(" .. whichTab .. ", line " .. lineNumber .. ", ' .. string.format('%.2f', ALICE_TimeElapsed) .. 's)|r\\n>> ' .. str)")
            elseif ALICE and ALICE.TimeElapsed then
                lines.injectedEvalFuncs[whichTab][lineNumber] = load("local args = table.pack(" .. WSCode.GetLocalAccess(lines.injectedEvalStr[whichTab][lineNumber]) .. ") local str = '' for i = 1, args.n do if i > 1 then str = str .. ', ' end str = str .. tostring(args[i]) end print('" .. lines.injectedEvalStr[whichTab][lineNumber] .. " |cffaaaaaa(" .. whichTab .. ", line " .. lineNumber .. ", ' .. string.format('%.2f', ALICE.TimeElapsed) .. 's)|r\\n>> ' .. str)")
            else
                lines.injectedEvalFuncs[whichTab][lineNumber] = load("local args = table.pack(" .. WSCode.GetLocalAccess(lines.injectedEvalStr[whichTab][lineNumber]) .. ") local str = '' for i = 1, args.n do if i > 1 then str = str .. ', ' end str = str .. tostring(args[i]) end print('" .. lines.injectedEvalStr[whichTab][lineNumber] .. " |cffaaaaaa(" .. whichTab .. ", line " .. lineNumber .. ")|r\\n>> ' .. str)")
            end
            if not lines.injectedEvalFuncs[whichTab][lineNumber] then
                WSDebug.PrintForUser("|cffff5555ERROR: Invalid syntax in injected eval function for tab " .. whichTab .. ", lineNumber " .. lineNumber .. ".")
                lines.injectedEvalFuncs[whichTab][lineNumber] = DoNothing
            end
        end

        lines.injectedEvalFuncs[whichTab][lineNumber]()
    end

    local function CompileCheckForStopFunc(whichTab)
        local doNotCheckStopTable = doNotCheckStop[whichTab]
        local lineNumberWasExecutedTable = lineNumberWasExecuted[whichTab]
        local debugStateTable = lines.debugState[whichTab]

        return function(lineNumber, generationCounter)
            local currentCorot = running()

            if doNotCheckStopTable[currentCorot][lineNumber] and not breakCondition[whichTab] then
                if EXECUTION_LIMIT then
                    executionCount = executionCount + 1
                    if executionCount > EXECUTION_LIMIT then
                        error("Execution limit reached.")
                    end
                end
                return true
            end

            executionTab = whichTab

            if not lineNumberWasExecutedTable[lineNumber] then
                lineNumberWasExecutedTable[lineNumber] = true
                if currentTab == whichTab then
                    local screenLineNumberNumber = math.tointeger(lineNumber - tabs.lineNumberOffset[whichTab])
                    if screenLineNumberNumber >= 1 and screenLineNumberNumber <= editor.MAX_LINES_ON_SCREEN then
                        BlzFrameSetText(lineNumberFrames[screenLineNumberNumber], editor.LINE_NUMBER_COLOR .. lineNumber .. "|r")
                    end
                end
            end

            if noStop then
                doNotCheckStopTable[currentCorot][lineNumber] = true
                return true
            end

            if tabIsHalted[whichTab] then
                return true
            end

            currentStop[whichTab] = lineNumber
            lastLineNumber[whichTab] = lineNumber
            currentCoroutine[whichTab] = currentCorot

            if EXECUTION_LIMIT then
                executionCount = executionCount + 1
                if executionCount > EXECUTION_LIMIT then
                    error("Execution limit reached.")
                end
            end

            if (debugStateTable[lineNumber] == 2 or (lineByLine and lastHaltedCoroutine == currentCoroutine[whichTab] and not tabs.breakNowhere[whichTab]) or breakEverywhere[whichTab])
            and (not breakCondition[whichTab] or EvaluateBreakCondition(whichTab, lineNumber))
            and (not breakOnlyHere or breakOnlyHere == whichTab) then
                if not isyieldable(currentCorot) or generationCounter ~= wsdebug.GenerationCounter[whichTab] then
                    if debugStateTable[lineNumber] == 2 then
                        if not isyieldable(currentCorot) then
                            WSDebug.PrintForUser("|cffff8800WSCode:|r breakpoint skipped (not yieldable) tab "
                                .. tostring(whichTab) .. " line " .. tostring(lineNumber))
                        elseif generationCounter ~= wsdebug.GenerationCounter[whichTab] then
                            WSDebug.PrintForUser("|cffff8800WSCode:|r breakpoint skipped (stale debug gen "
                                .. tostring(generationCounter) .. " vs " .. tostring(wsdebug.GenerationCounter[whichTab])
                                .. ") tab " .. tostring(whichTab) .. " line " .. tostring(lineNumber))
                        end
                    end
                    doNotCheckStopTable[currentCorot][lineNumber] = true
                    return true
                end

                if not BlzFrameIsVisible(codeEditorParent) then
                    EnableEditor(user)
                end
                if currentTab ~= whichTab then
                    if not tabs.numbers[whichTab] then
                        WSCode.Pull(whichTab)
                    end
                    WSCode.SwitchToTab(whichTab)
                end
                BlzFrameSetVisible(highlights.currentLine, true)
                BlzFrameSetVisible(highlights.error, false)
                JumpWindow(currentStop[whichTab], true, currentTab ~= whichTab)
                SetCurrentLine()

                lineNumbers.lastViewed[whichTab] = nil

                if doNotUpdateVariables[whichTab] then
                    print("|cffff0000Warning:|r Variables displayed in the variable viewer may not be accurate because variable tracking was frozen before this breakpoint was reached.")
                end

                UpdateVariableViewer(lineNumber)
                local aliceWasHalted
                if ALICE_Where and (ALICE_Where ~= "outsideofcycle" or editor.ALWAYS_HALT_ALICE_ON_BREAKPOINT) then
                    ALICE_Halt()
                    aliceWasHalted = true
                    BlzFrameSetEnable(buttons["Pause/Resume"], false)
                elseif ALICE and (ALICE.Where ~= "outsideofcycle" or editor.ALWAYS_HALT_ALICE_ON_BREAKPOINT) then
                    ALICE.Halt()
                    aliceWasHalted = true
                    BlzFrameSetEnable(buttons["Pause/Resume"], false)
                end
                BlzFrameSetEnable(buttons["Traceback"], true)
                tabIsHalted[whichTab] = true
                tabs.hasError[whichTab] = nil
                doNotUpdateVariables[whichTab] = true
                if Debug then
                    wsdebug.Traceback[whichTab] = Debug.traceback()
                end
                --wsdebug.TriggeringTrigger[currentCorot] = wsdebug.TriggeringTrigger[currentCorot] or GetTriggeringTrigger()

                noStop = true
                editor.ON_BREAK(tabs.names[whichTab])
                noStop = false
                coroutine.yield()

                tabIsHalted[whichTab] = false
                doNotUpdateVariables[whichTab] = false
                if aliceWasHalted then
                    (ALICE_Resume or ALICE.Resume)()
                    BlzFrameSetEnable(buttons["Pause/Resume"], true)
                end
                BlzFrameSetEnable(buttons["Traceback"], false)
                noStop = true
                editor.ON_RESUME(tabs.names[whichTab])
                noStop = false
                BlzFrameSetVisible(highlights.currentLine, false)
                executionTab = whichTab
            elseif debugStateTable[lineNumber] == 1 and (not breakCondition[whichTab] or EvaluateBreakCondition(whichTab, lineNumber)) then
                EvaluateInjectedEvalFunc(whichTab, lineNumber)
            else
                doNotCheckStop[whichTab][currentCorot][lineNumber] = true
            end
            return true
        end
    end

    local function CompileAssignVarFunc(tab, level)
        local levelTable = wsdebug.VarTable[tab][level]

        return function(value, varName)
            if doNotUpdateVariables[tab] then
                return
            end

            if value == nil then
                levelTable[varName] = wsdebug.Nil
            else
                levelTable[varName] = value
            end
        end
    end

    local function CompileGlobalAssignVarFunc(tab)
        local tabTable = wsdebug.VarTable[tab]
        local visibleVarsTable = visibleVarsOfLine[tab]

        return function(value, lineNumber, varName)
            if doNotUpdateVariables[tab] then
                return
            end

            local level = visibleVarsTable[lineNumber][varName] or -1

            if value == nil then
                tabTable[level][varName] = wsdebug.Nil
            else
                tabTable[level][varName] = value
            end
        end
    end

    local function CompileFunction(rawCode, settings)
        if compiler.RELEASE_VERSION then
            local __, __, originalFunc = ConvertAndValidateLines(rawCode, settings.tab, settings.duringInit, true)

            if originalFunc then
                originalFunc()
            end
            return
        end

        ------------------------------------------------------------------------------------------------------------------------
        --Initialization
        ------------------------------------------------------------------------------------------------------------------------

        local whichTab = settings.tab

        lineByLine = false
        canJumpToError = true
        executionTab = whichTab
        currentStop[whichTab] = 0
        lastLineNumber[whichTab] = 0
        lineNumbers.lastViewed[whichTab] = nil
        lineNumbers.error[whichTab] = 0
        tabs.hasError[whichTab] = false
        tabs.wasNotCompiledInDebugMode[whichTab] = not settings.debugMode
        tabIsHalted[whichTab] = false
        doNotUpdateVariables[whichTab] = false
        variableViewer.forceScrollerUpdate = true
        noStop = false

        if highlights.custom[whichTab] then
            if whichTab == currentTab then
                BlzFrameSetVisible(highlights.custom.frame, false)
            end
            highlights.custom[whichTab] = nil
        end

        if not settings.duringInit and currentTab == whichTab then
            if settings.debugMode then
                BlzFrameSetText(tabNavigator.titles[currentTab], editor.TAB_NAVIGATOR_SELECTED_COLOR .. tabs.truncatedNames[currentTab] .. "|r")
            else
                BlzFrameSetText(tabNavigator.titles[currentTab], editor.TAB_NAVIGATOR_SELECTED_NO_DEBUG_COLOR .. tabs.truncatedNames[currentTab] .. "|r")
            end
            for i = 1, highestNonEmptyLine[currentTab][step[currentTab]] do
                if lineNumberWasExecuted[currentTab][i] then
                    lineNumberWasExecuted[currentTab][i] = nil
                    local screenLineNumberNumber = math.tointeger(i - tabs.lineNumberOffset[currentTab])
                    if screenLineNumberNumber >= 1 and screenLineNumberNumber <= editor.MAX_LINES_ON_SCREEN then
                        BlzFrameSetText(lineNumberFrames[screenLineNumberNumber], editor.IDLE_LINE_NUMBER_COLOR .. i .. "|r")
                    end
                end
            end
        end

        if buttons["Pause/Resume"] then
            BlzFrameSetEnable(buttons["Pause/Resume"], true)
        end
        BlzFrameSetEnable(buttons["Traceback"], false)

        if not settings.compileOnly then
            WSDebug.GenerationCounter[whichTab] = WSDebug.GenerationCounter[whichTab] + 1
        end

        local tabAndGenStr = whichTab .. "_" .. WSDebug.GenerationCounter[whichTab] .. "_"

        for index, __ in next, varTable do
            for var, __ in next, varTable[index] do
                varTable[index][var] = nil
            end
        end
        for index, __ in next, visibleVarsOfLine[whichTab] do
            for var, __ in next, visibleVarsOfLine[whichTab][index] do
                visibleVarsOfLine[whichTab][index][var] = nil
            end
        end
        if settings.runInit then
            for i = 1, 7 do
                for j = 1, #WSDebug.FunctionsToInit[i] do
                    WSDebug.FunctionsToInit[i][j] = nil
                end
            end
        end
        for i = 1, #variableViewer.viewedVariableTrace do
            variableViewer.viewedVariableTrace[i] = nil
            variableViewer.viewedValueTrace[i] = nil
        end

        local success, code, originalFunc = ConvertAndValidateLines(rawCode, whichTab, settings.duringInit, true)

        if not success then
            return
        end

        local tokens, lineNumberOfToken, errorLineNumberOfToken = WSCode.Tokenize(code)

        ------------------------------------------------------------------------------------------------------------------------
        --Transpilation
        ------------------------------------------------------------------------------------------------------------------------

        local finalCode = setmetatable({}, {__concat = function(self, str) self[#self + 1] = str return self end})
        local executionTabString = "'" .. whichTab .. "'"
        local handleTab = executionTabString:gsub(" %(Execute%)", "")
        if not settings.duringInit then
            finalCode = finalCode ..
            "local OnInit = setmetatable({}, {__index = function() return function() end end}) " ..
            "local Require = setmetatable({}, {__index = function() return function() end end, __call = function() end}) " ..
            "local wsdebug_result " ..
            "local wsdebug_generationCounter = " .. WSDebug.GenerationCounter[whichTab] .. " " ..
            "local wsdebug_executionTab = " .. executionTabString .. " "
        else
            finalCode = finalCode .. "local wsdebug_result local wsdebug_generationCounter = " .. WSDebug.GenerationCounter[whichTab] .. " local wsdebug_executionTab = " .. executionTabString .. " "
        end

        local stateTrace = {"root"}
        local currentState = stateTrace[1]
        local stateOfToken
        local beginningOfStatementToken = {}
        local beginningOfStatementCode = {}
        local beginningLineOfFunction = {}
        local currentLevel = 0
        local nameOfFunction = {}
        local levelOfFunction = setmetatable({}, {__index = function() return -1 end})
        local upvalues = setmetatable({}, tab2D)
        local lineNumberOfFunction = {}
        local functionIsLocal = {}
        local tableTrace = {}
        local varName, args
        local untracedTables = 0
        local functionName
        local funcIsLocal
        local skip
        local token
        local currentLine = 1

        local checkForStopKey = "CheckForStop" .. whichTab

        if settings.debugMode and not WSDebug[checkForStopKey] then
            WSDebug[checkForStopKey] = CompileCheckForStopFunc(whichTab)
        end

        local function IsEndOfStatement(k)
            local firstToken = tokens[k - 1]
            local secondToken = tokens[k]
            return ((k == #tokens or LUA.CONTROL_FLOW_STATEMENTS[secondToken]) and not LUA.CONTROL_FLOW_STATEMENTS[firstToken]) or (firstToken ~= "local" and firstToken ~= "function" and not LUA.CONTROL_FLOW_STATEMENTS[firstToken] and not LUA.OPERATORS[secondToken] and not LUA.BINARY_OPERATORS[firstToken] and not END_OF_STATEMENT_IGNORED_CHARS[sub(secondToken, 1, 1)])
        end

        local function InsertCode(whichCode, index)
            table.insert(finalCode, index, whichCode)
            for i = 1, #stateTrace do
                if beginningOfStatementCode[i] and beginningOfStatementCode[i] >= index then
                    beginningOfStatementCode[i] = beginningOfStatementCode[i] + 1
                end
            end
        end

        local function ReduceLevel()
            for var, __ in next, varTable[currentLevel] do
                varTable[currentLevel][var] = nil
            end
            for key, __ in next, upvalues[currentLevel] do
                upvalues[currentLevel][key] = nil
            end
            currentLevel = currentLevel - 1
        end

        local function AddVariables(vars, isLocal, whichLevel, addUpvalues)
            for var in vars:gmatch("[^,]+") do
                var = var:gsub("^%s*local%s+", ""):gsub(" ", "")
                if find(var, "[.%[:]") == nil or var == "..." then
                    if isLocal then
                        varTable[whichLevel][var] = true
                        if addUpvalues then
                            upvalues[whichLevel][var] = true
                        end
                    else
                        for i = -1, whichLevel do
                            if varTable[i][var] then
                                return
                            end
                        end
                        varTable[-1][var] = true
                    end
                end
            end
        end

        local function SetVariables(lineNumber)
            for level = -1, currentLevel do
                for var, __ in next, varTable[level] do
                    visibleVarsOfLine[whichTab][lineNumber][var] = level
                end
            end
        end

        local function StoreSourceCode(startLine, endLine)
            local sourceCode = {}
            local j = 1
            for i = startLine, endLine do
                sourceCode[j] = rawCode[i]
                j = j + 1
            end
            WSDebug.SourceCode[#WSDebug.SourceCode + 1] = sourceCode
        end

        if settings.debugMode then
            ------------------------------------------------------------------------------------------------------------------------
            --Debug mode
            ------------------------------------------------------------------------------------------------------------------------

            local i = 1
            while i <= #tokens do
                token = tokens[i]

                ---@diagnostic disable-next-line: need-check-nil
                while errorLineNumberOfToken[i] > currentLine do
                    finalCode = finalCode .. "\n"
                    currentLine = currentLine + 1
                end

                if currentState == "assignment" and (i == #tokens or (not LUA.OPERATORS[token] and not LUA.BINARY_OPERATORS[tokens[i - 1]] and not END_OF_STATEMENT_IGNORED_CHARS[sub(token, 1, 1)])) then
                    local vars = ""
                    local isLocal

                    for j = beginningOfStatementToken[#stateTrace - 1], beginningOfStatementToken[#stateTrace] - 2 do
                        vars = vars .. tokens[j] .. " "
                    end

                    for j = beginningOfStatementCode[#stateTrace - 1], beginningOfStatementCode[#stateTrace] - 1 do
                        if finalCode[j] ~= "\n" then
                            finalCode[j] = ""
                        end
                    end

                    if i == #tokens then
                        finalCode = finalCode .. token
                        skip = true
                    end

                    isLocal = tokens[beginningOfStatementToken[#stateTrace - 1]] == "local"

                    local isPersistent = settings.smartPersist and stateTrace[#stateTrace - 1] == "root"

                    local isTableAssignment = find(vars, "%.") or find(vars, ":") or find(vars, "%[")
                    if isTableAssignment then
                        InsertCode(" WSDebug['" .. checkForStopKey .. "'](" .. lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]] .. ", wsdebug_generationCounter) " .. vars .. " = ", beginningOfStatementCode[#stateTrace - 1])
                        SetVariables(lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]])
                    else
                        if find(vars, ",") then
                            local varsAsStrings = vars:gsub("^local ", ""):gsub(" ", ""):gsub("%s*([^,]+)%s*", "'%1'")
                            if isPersistent then
                                InsertCode(" WSDebug['" .. checkForStopKey .. "'](" .. lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]] .. ", wsdebug_generationCounter)" .. " wsdebug_result = WSDebug.GetVarEx(wsdebug_executionTab, " .. (isLocal and currentLevel or -1) .. ", " .. varsAsStrings .. ", ", beginningOfStatementCode[#stateTrace - 1])
                            else
                                InsertCode(" WSDebug['" .. checkForStopKey .. "'](" .. lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]] .. ", wsdebug_generationCounter)" .. " wsdebug_result = table.pack(", beginningOfStatementCode[#stateTrace - 1])
                            end

                            finalCode = finalCode .. ") " .. vars .. "= WSDebug.Unpack(wsdebug_result)" .. " WSDebug.AssignVars(wsdebug_result, " .. (isLocal and currentLevel or -1) .. ", wsdebug_executionTab, " .. lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]] .. ", " .. varsAsStrings .. ") "
                            SetVariables(lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]])
                            AddVariables(vars, isLocal, currentLevel)

                            if stateTrace[#stateTrace - 1] == "root" and not vars:find("%[") and not vars:find("%.") then
                                local beginning = 1
                                local subvar
                                local cleanedVar = vars:gsub("^local ", ""):gsub(" ", "")
                                local commaPos = cleanedVar:find(",")
                                while commaPos do
                                    subvar = cleanedVar:sub(beginning, commaPos - 1)
                                    finalCode = finalCode .. " WSDebug.Injectors[wsdebug_executionTab]." .. subvar .. " = function(v) " .. subvar .. " = v end "
                                    beginning = commaPos + 1
                                    commaPos = cleanedVar:find(",", beginning)
                                end
                                subvar = cleanedVar:sub(beginning)
                                finalCode = finalCode .. " WSDebug.Injectors[wsdebug_executionTab]." .. subvar .. " = function(v) " .. subvar .. " = v "

                                if isLocal then
                                local funcKey = "AV" .. tabAndGenStr .. "ws" .. currentLevel
                                    if not WSDebug[funcKey] then
                                        WSDebug[funcKey] = CompileAssignVarFunc(whichTab, currentLevel)
                                    end
                                    finalCode = finalCode .. "WSDebug['" .. funcKey .. "'](v, '" .. subvar .. "') end "
                                else
                                    local funcKey = "AVG" .. tabAndGenStr
                                    if not WSDebug[funcKey] then
                                        WSDebug[funcKey] = CompileGlobalAssignVarFunc(whichTab)
                                    end
                                    finalCode = finalCode .. " WSDebug['" .. funcKey .. "'](v, " .. lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]] .. ", '" .. subvar .. "') end "
                                end
                            end
                        else
                            local varsAsStrings = vars:gsub("^local ", ""):gsub(" ", ""):gsub("%s*([^,]+)%s*", "'%1'")
                            if isPersistent then
                                InsertCode(" WSDebug['" .. checkForStopKey .. "'](" .. lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]] .. ", wsdebug_generationCounter) " .. vars .. " = WSDebug.GetVar(wsdebug_executionTab, " .. (isLocal and currentLevel or -1) .. ", " .. varsAsStrings .. ", ", beginningOfStatementCode[#stateTrace - 1])
                            else
                                InsertCode(" WSDebug['" .. checkForStopKey .. "'](" .. lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]] .. ", wsdebug_generationCounter) " .. vars .. " = ", beginningOfStatementCode[#stateTrace - 1])
                            end

                            if isPersistent then
                                finalCode = finalCode .. ") "
                            else
                                finalCode = finalCode .. " "
                            end

                            if isLocal then
                                local funcKey = "AV" .. tabAndGenStr .. "ws" .. currentLevel
                                if not WSDebug[funcKey] then
                                    WSDebug[funcKey] = CompileAssignVarFunc(whichTab, currentLevel)
                                end
                                finalCode = finalCode .. "WSDebug['" .. funcKey .. "'](" .. vars:gsub("^local ", "") .. ", " .. varsAsStrings .. ") "
                            else
                                local funcKey = "AVG" .. tabAndGenStr
                                if not WSDebug[funcKey] then
                                    WSDebug[funcKey] = CompileGlobalAssignVarFunc(whichTab)
                                end
                                finalCode = finalCode .. "WSDebug['" .. funcKey .. "'](" .. vars:gsub("^local ", "") .. ", " .. lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]] .. ", " .. varsAsStrings .. ") "
                            end

                            SetVariables(lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]])
                            AddVariables(vars, isLocal, currentLevel)

                            if stateTrace[#stateTrace - 1] == "root" and not vars:find("%[") and not vars:find("%.") then
                                local cleanedVar = vars:gsub("^local ", ""):gsub(" ", "")
                                finalCode = finalCode .. " WSDebug.Injectors[wsdebug_executionTab]." .. cleanedVar .. " = function(v) " .. cleanedVar .. " = v "

                                if isLocal then
                                    local funcKey = "AV" .. tabAndGenStr .. "ws" .. currentLevel
                                    if not WSDebug[funcKey] then
                                        WSDebug[funcKey] = CompileAssignVarFunc(whichTab, currentLevel)
                                    end
                                    finalCode = finalCode .. "WSDebug['" .. funcKey .. "'](v, '" .. cleanedVar .. "') end "
                                else
                                    local funcKey = "AVG" .. tabAndGenStr
                                    if not WSDebug[funcKey] then
                                        WSDebug[funcKey] = CompileGlobalAssignVarFunc(whichTab)
                                    end
                                    finalCode = finalCode .. " WSDebug['" .. funcKey .. "'](v, " .. lineNumberOfToken[beginningOfStatementToken[#stateTrace - 1]] .. ", '" .. cleanedVar .. "') end "
                                end
                            end
                        end
                    end

                    stateTrace[#stateTrace] = nil
                    currentState = stateTrace[#stateTrace]
                    beginningOfStatementToken[#stateTrace] = i
                    beginningOfStatementCode[#stateTrace] = #finalCode + 1
                end

                if token == "goto" then
                    finalCode = finalCode
                    .. " WSDebug['" .. checkForStopKey .. "'](" .. lineNumberOfToken[i] .. ", wsdebug_generationCounter) "
                    SetVariables(lineNumberOfToken[i])
                end

                if currentState == "root" or currentState == "functionbody" then
                    local firstChar = sub(token, 1, 1)
                    if firstChar == "." or firstChar == ":" or firstChar == "[" then
                        --Statement continues after function call in the middle of statement, do nothing
                    elseif stateOfToken ~= currentState and stateOfToken ~= "index" then
                        beginningOfStatementToken[#stateTrace] = i
                        beginningOfStatementCode[#stateTrace] = #finalCode + 1
                    elseif IsEndOfStatement(i) then
                        if tokens[i - 1] ~= "goto" and tokens[i - 2] ~= "goto" then
                            if (sub(tokens[i - 1], 1, 1) == '"' or sub(tokens[i - 1], 1, 1) == "'") then
                                InsertCode("WSDebug['" .. checkForStopKey .. "'](" .. lineNumberOfToken[i - 1] .. ", wsdebug_generationCounter) ", beginningOfStatementCode[#stateTrace])
                                SetVariables(lineNumberOfToken[i - 1])
                            else
                                local vars = ""
                                for j = beginningOfStatementToken[#stateTrace], i - 1 do
                                    if tokens[j] ~= "local" then
                                        vars = vars .. tokens[j]
                                    end
                                end
                                local isLocal = tokens[beginningOfStatementToken[#stateTrace]] == "local"
                                local varsAsStrings = vars:gsub("%s*([^,]+)%s*", "'%1'")

                                local isPersistent = settings.smartPersist and stateTrace[#stateTrace] == "root"

                                if isPersistent then
                                    finalCode = finalCode .. "wsdebug_result = WSDebug.GetVarNil(wsdebug_executionTab, " .. (isLocal and currentLevel or -1) .. ", " .. varsAsStrings .. ") "
                                    finalCode = finalCode .. vars .. " = WSDebug.Unpack(wsdebug_result)"
                                    .. " WSDebug['" .. checkForStopKey .. "'](" .. lineNumberOfToken[i - 1] .. ", wsdebug_generationCounter)"
                                    .. " WSDebug.AssignVars(wsdebug_result," .. currentLevel .. ", wsdebug_executionTab, 0, " .. varsAsStrings .. ") "
                                else
                                    if varsAsStrings == "'noClippingForgiveness'" then
                                        print(1, tokens[i], "!" .. tokens[i - 1] .. "!")
                                    end
                                    finalCode = finalCode
                                    .. " WSDebug['" .. checkForStopKey .. "'](" .. lineNumberOfToken[i - 1] .. ", wsdebug_generationCounter)"
                                    .. " WSDebug.AssignVars(nil, " .. currentLevel .. ", wsdebug_executionTab, 0, " .. varsAsStrings .. ") "
                                end
                                SetVariables(lineNumberOfToken[i - 1])
                                AddVariables(vars, isLocal, currentLevel)

                                if currentState == "root" then
                                    local var
                                    if find(vars, ",") then
                                        local beginning = 1
                                        local subvar
                                        local cleanedVar = vars:gsub("^local ", ""):gsub(" ", "")
                                        local commaPos = cleanedVar:find(",")
                                        while commaPos do
                                            subvar = cleanedVar:sub(beginning, commaPos - 1)
                                            finalCode = finalCode .. " WSDebug.Injectors[wsdebug_executionTab]." .. subvar .. " = function(v) " .. subvar .. " = v end "
                                            beginning = commaPos + 1
                                            commaPos = cleanedVar:find(",", beginning)
                                        end
                                        var = cleanedVar:sub(beginning)
                                        finalCode = finalCode .. " WSDebug.Injectors[wsdebug_executionTab]." .. var .. " = function(v) " .. var .. " = v "
                                    else
                                        var = vars:gsub("^local ", ""):gsub(" ", "")
                                        finalCode = finalCode .. " WSDebug.Injectors[wsdebug_executionTab]." .. vars .. " = function(v) " .. var .. " = v "
                                    end

                                    if isLocal then
                                        local funcKey = "AV" .. tabAndGenStr .. "ws" .. currentLevel
                                        if not WSDebug[funcKey] then
                                            WSDebug[funcKey] = CompileAssignVarFunc(whichTab, currentLevel)
                                        end
                                        finalCode = finalCode .. "WSDebug['" .. funcKey .. "'](v, '" .. var .. "') end "
                                    else
                                        local funcKey = "AVG" .. tabAndGenStr
                                        if not WSDebug[funcKey] then
                                            WSDebug[funcKey] = CompileGlobalAssignVarFunc(whichTab)
                                        end
                                        finalCode = finalCode .. " WSDebug['" .. funcKey .. "'](v, " .. lineNumberOfToken[beginningOfStatementToken[#stateTrace]] .. ", '" .. var .. "') end "
                                    end
                                end
                            end
                        end
                        beginningOfStatementToken[#stateTrace] = i
                        beginningOfStatementCode[#stateTrace] = #finalCode + 1
                    end
                elseif currentState == "until" and tokens[i - 1] ~= "until" and IsEndOfStatement(i) then
                    ReduceLevel()
                    finalCode = finalCode .. ") "
                    stateTrace[#stateTrace] = nil
                    currentState = stateTrace[#stateTrace]
                    beginningOfStatementToken[#stateTrace] = i
                    beginningOfStatementCode[#stateTrace] = #finalCode + 1
                end
                stateOfToken = currentState
                stateOfToken = currentState

                if currentState == "args" and token ~= ")" then
                    args = args .. token
                end

                if token == "::" then
                    if currentState == "gotodef" then
                        stateTrace[#stateTrace] = nil
                        currentState = stateTrace[#stateTrace]
                        finalCode = finalCode .. token
                    else
                        currentState = "gotodef"
                        stateTrace[#stateTrace + 1] = currentState
                        finalCode = finalCode .. token
                    end
                elseif currentState == "gotodef" then
                    finalCode = finalCode .. token
                elseif LUA.OPERATORS[token] or LUA.KEYWORDS[token] then
                    if token == "(" then
                        if currentState == "functiondef" or currentState == "reversefunctiondef" or currentState == "anonymousfunctiondef" or currentState == "wrappedfunctiondef" or currentState == "wrappedreversefunctiondef" then
                            currentState = "args"
                            stateTrace[#stateTrace + 1] = "args"
                            finalCode = finalCode .. token
                            args = ""
                        elseif (not LUA.OPERATORS[tokens[i - 1]] and not LUA.CONTROL_FLOW_STATEMENTS[tokens[i - 1]]) or tokens[i - 1] == "]" then
                            currentState = "params"
                            stateTrace[#stateTrace + 1] = currentState
                            if stateTrace[#stateTrace - 1] == "root" or stateTrace[#stateTrace - 1] == "functionbody" then
                                for j = #stateTrace, 1, -1 do
                                    if stateTrace[j] == "root" or stateTrace[j] == "functionbody" then
                                        InsertCode("WSDebug['" .. checkForStopKey .. "'](" .. lineNumberOfToken[i] .. ", wsdebug_generationCounter) ", beginningOfStatementCode[j])
                                        SetVariables(lineNumberOfToken[i])
                                        break
                                    end
                                end
                            end

                            if CREATOR_DESTRUCTOR_PAIRS[tokens[i - 1]] then
                                currentState = "handlewrapper"
                                stateTrace[#stateTrace + 1] = currentState
                                if compiler.STORE_HANDLE_ORIGIN and CREATOR_DESTRUCTOR_PAIRS[tokens[i - 1]] and tokens[i - 2] ~= "function" then
                                    if tokens[i + 1] == ")" then
                                        finalCode[#finalCode] = "WSDebug.StoreHandle('" .. tokens[i - 1] .. "', " .. tokens[i - 1] .. ", " .. handleTab .. ", " .. tokens[i - 1] .. "WSOriginWrapper" .. "('" .. whichTab .. "', " .. currentLine .. ", " .. tokens[i - 1]
                                    else
                                        finalCode[#finalCode] = "WSDebug.StoreHandle('" .. tokens[i - 1] .. "', " .. tokens[i - 1] .. ", " .. handleTab .. ", " .. tokens[i - 1] .. "WSOriginWrapper" .. "('" .. whichTab .. "', " .. currentLine .. ", " .. tokens[i - 1] .. ", "
                                    end
                                else
                                    finalCode[#finalCode] = "WSDebug.StoreHandle('" .. tokens[i - 1] .. "', " .. tokens[i - 1] .. ", " .. handleTab .. ", " .. tokens[i - 1] .. "("
                                end
                            elseif settings.runInit and tokens[i - 1]:match("Init") ~= nil and (tokens[i - 1]:match("^OnInit.") ~= nil or tokens[i - 1]:match("^WSCode.Init") ~= nil) then
                                finalCode[#finalCode] = "WSDebug.Execute('" .. tokens[i - 1]:match("%.(.*)") .. "', "
                                currentState = "onInitWrapper"
                                stateTrace[#stateTrace] = currentState
                            else
                                finalCode[#finalCode] = tokens[i - 1] .. "("
                            end
                        else
                            currentState = "parenthesis"
                            stateTrace[#stateTrace + 1] = currentState
                            finalCode = finalCode .. token
                        end

                    elseif token == ")" then
                        if currentState == "parenthesis" then
                            stateTrace[#stateTrace] = nil
                            currentState = stateTrace[#stateTrace]
                            finalCode = finalCode .. token .. " "
                        elseif currentState == "args" then
                            stateTrace[#stateTrace] = nil
                            currentState = "functionbody"
                            stateTrace[#stateTrace + 1] = currentState

                            levelOfFunction[#stateTrace] = currentLevel
                            nameOfFunction[#stateTrace] = functionName
                            functionIsLocal[#stateTrace] = funcIsLocal
                            lineNumberOfFunction[#stateTrace] = lineNumberOfToken[i]
                            currentLevel = currentLevel + 1

                            local argsAsStrings = args:gsub("%s*([^,]+)%s*", "'%1'")

                            if functionName then
                                finalCode = finalCode .. ") " .. (#args > 0 and (" WSDebug.AssignVars(WSDebug.Pack(" .. args .. "), " .. currentLevel .. ", wsdebug_executionTab, 0, " .. argsAsStrings .. ")") or "")

                                for l = 1, currentLevel - 1 do
                                    local funcKey = "AV" .. tabAndGenStr .. "ws" .. l
                                    if not WSDebug[funcKey] then
                                        WSDebug[funcKey] = CompileAssignVarFunc(whichTab, l)
                                    end
                                    for key, __ in next, upvalues[l] do
                                        finalCode = finalCode .. " WSDebug['" .. funcKey .. "'](" .. key .. ", '" .. key .. "') "
                                    end
                                end

                                if #args > 0 then
                                    AddVariables(args, true, currentLevel, true)
                                end
                                functionName = nil
                            else
                                numFunctions = numFunctions + 1

                                finalCode = finalCode .. ") " .. (#args > 0 and (" WSDebug.AssignVars(WSDebug.Pack(" .. args .. "), " .. currentLevel .. ", wsdebug_executionTab, 0, " .. argsAsStrings .. ")") or "")

                                for l = 1, currentLevel - 1 do
                                    local funcKey = "AV" .. tabAndGenStr .. "ws" .. l
                                    if not WSDebug[funcKey] then
                                        WSDebug[funcKey] = CompileAssignVarFunc(whichTab, l)
                                    end
                                    for key, __ in next, upvalues[l] do
                                        finalCode = finalCode .. " WSDebug['" .. funcKey .. "'](" .. key .. ", '" .. key .. "') "
                                    end
                                end

                                if #args > 0 then
                                    AddVariables(args, true, currentLevel, true)
                                end
                            end

                        elseif currentState == "params" or currentState == "handlewrapper" or currentState == "doublehandlewrapper" or currentState == "onInitWrapper" then
                            if currentState == "handlewrapper" then
                                finalCode = finalCode .. ") "
                                stateTrace[#stateTrace] = nil                     
                            elseif currentState == "doublehandlewrapper" then
                                finalCode = finalCode .. ")) "
                                stateTrace[#stateTrace] = nil
                            end
                            finalCode = finalCode .. ") "
                            stateTrace[#stateTrace] = nil
                            currentState = stateTrace[#stateTrace]
                        else
                            finalCode = finalCode .. token .. " "
                        end

                    elseif token == "function" then
                        if tokens[i + 1] == "(" then
                            if tokens[i - 1] == "=" then
                                currentState = "reversefunctiondef"
                                local tableStr = ""
                                for j = 1, #tableTrace do
                                    tableStr = tableStr .. tableTrace[j] .. "."
                                end
                                local name
                                if tokens[i - 2] == "]" then
                                    name = tokens[i - 4] .. tokens[i - 3]:gsub('"', '\\"'):gsub("'", "\\'") .. tokens[i - 2]
                                else
                                    name = tokens[i - 2]
                                end
                                if sub(name, 1, 2) ~= "__" then
                                    currentState = "wrappedreversefunctiondef"
                                    finalCode = finalCode .. "WSDebug.StoreSourceCode(WSDebug.GetWrapper('" .. tableStr .. name .. "', wsdebug_executionTab, wsdebug_generationCounter, function"
                                else
                                    finalCode = finalCode .. "WSDebug.StoreSourceCode(function"
                                end
                            else
                                currentState = "anonymousfunctiondef"
                                finalCode = finalCode .. "WSDebug.StoreSourceCode(function"
                            end
                        else
                            currentState = "functiondef"
                            funcIsLocal = tokens[i - 1] == "local"
                            finalCode = finalCode .. token .. " "
                        end
                        stateTrace[#stateTrace + 1] = currentState
                        beginningOfStatementToken[#stateTrace] = i + 1
                        beginningLineOfFunction[#stateTrace] = lineNumberOfToken[i]

                    elseif token == "if" or token == "while" then
                        currentState = "condition"
                        stateTrace[#stateTrace + 1] = currentState
                        finalCode = finalCode .. " " .. token .. " " .. "WSDebug['" .. checkForStopKey .. "'](" .. lineNumberOfToken[i] .. ", wsdebug_generationCounter) and ("
                        SetVariables(lineNumberOfToken[i])
                        currentLevel = currentLevel + 1

                    elseif token == "elseif" then
                        if currentState == "returnstatement" then
                            stateTrace[#stateTrace] = nil
                            currentState = stateTrace[#stateTrace]
                        end
                        currentState = "condition"
                        stateTrace[#stateTrace + 1] = currentState
                        finalCode = finalCode .. " " .. token .. " " .. "WSDebug['" .. checkForStopKey .. "'](" .. lineNumberOfToken[i] .. ", wsdebug_generationCounter) and ("
                        SetVariables(lineNumberOfToken[i])

                    elseif token == "until" then
                        currentState = "until"
                        stateTrace[#stateTrace + 1] = currentState
                        finalCode = finalCode .. " " .. token .. " " .. "WSDebug['" .. checkForStopKey .. "'](" .. lineNumberOfToken[i] .. ", wsdebug_generationCounter) and ("
                        SetVariables(lineNumberOfToken[i])

                    elseif token == "else" then
                        if currentState == "returnstatement" then
                            stateTrace[#stateTrace] = nil
                            currentState = stateTrace[#stateTrace]
                        end

                        finalCode = finalCode .. "elseif WSDebug['" .. checkForStopKey .. "'](" .. lineNumberOfToken[i] .. ", wsdebug_generationCounter) then "
                        SetVariables(lineNumberOfToken[i])
                        beginningOfStatementToken[#stateTrace] = i + 1
                        beginningOfStatementCode[#stateTrace] = #finalCode + 1

                    elseif token == "for" then
                        currentState = "loopheader"
                        stateTrace[#stateTrace + 1] = currentState
                        finalCode = finalCode .. "WSDebug['" .. checkForStopKey .. "'](" .. lineNumberOfToken[i] .. ", wsdebug_generationCounter) " .. token .. " "
                        SetVariables(lineNumberOfToken[i])
                        beginningOfStatementToken[#stateTrace] = i + 1
                        currentLevel = currentLevel + 1

                    elseif token == "then" or token == "do" then
                        if currentState == "condition" then
                            finalCode = finalCode .. ") " .. token .. " "
                            stateTrace[#stateTrace] = nil
                            currentState = stateTrace[#stateTrace]
                        elseif currentState == "loopheader" then
                            finalCode = finalCode .. " " .. token .. " "
                            if tokens[beginningOfStatementToken[#stateTrace] + 1] == "," then
                                varName = (tokens[beginningOfStatementToken[#stateTrace]] .. "," .. tokens[beginningOfStatementToken[#stateTrace] + 2])
                                local varsAsStrings = varName:gsub("%s*([^,]+)%s*", "'%1'"):gsub(" ", "")
                                finalCode = finalCode .. "WSDebug.AssignVars({" .. varName .. "}, " .. currentLevel .. ", wsdebug_executionTab, 0, " .. varsAsStrings .. ") "
                            else
                                varName = tokens[beginningOfStatementToken[#stateTrace]]
                                local varAsStrings = varName:gsub("%s*([^,]+)%s*", "'%1'"):gsub(" ", "")
                                local funcKey = "AV" .. tabAndGenStr .. "ws" .. currentLevel

                                if not WSDebug[funcKey] then
                                    WSDebug[funcKey] = CompileAssignVarFunc(whichTab, currentLevel)
                                end

                                finalCode = finalCode .. " WSDebug['" .. funcKey .. "'](" .. varName .. ", " .. varAsStrings .. ") "
                            end
                            stateTrace[#stateTrace] = nil
                            currentState = stateTrace[#stateTrace]
                            AddVariables(varName, true, currentLevel, true)
                        else
                            finalCode = finalCode .. "do "
                            currentLevel = currentLevel + 1
                            beginningOfStatementToken[#stateTrace] = i + 1
                            beginningOfStatementCode[#stateTrace] = #finalCode + 1
                        end

                    elseif token == "repeat" then
                        currentLevel = currentLevel + 1
                        finalCode = finalCode .. token
                        .. " WSDebug['" .. checkForStopKey .. "'](" .. lineNumberOfToken[i] .. ", wsdebug_generationCounter) "
                        SetVariables(lineNumberOfToken[i])
                        beginningOfStatementToken[#stateTrace] = i + 1
                        beginningOfStatementCode[#stateTrace] = #finalCode + 1

                    elseif token == "return" then
                        finalCode = finalCode
                        .. " WSDebug['" .. checkForStopKey .. "'](" .. lineNumberOfToken[i] .. ", wsdebug_generationCounter) "
                        .. " " ..  token .. " "
                        SetVariables(lineNumberOfToken[i])
                        currentState = "returnstatement"
                        stateTrace[#stateTrace + 1] = currentState

                    elseif token == "end" then
                        local noStop
                        if currentState == "returnstatement" then
                            stateTrace[#stateTrace] = nil
                            currentState = stateTrace[#stateTrace]
                            beginningOfStatementToken[#stateTrace] = i + 1
                            beginningOfStatementCode[#stateTrace] = #finalCode + 1
                            noStop = true
                        end

                        if currentLevel - 1 == levelOfFunction[#stateTrace] then
                            local name = nameOfFunction[#stateTrace]
                            local isLocal = functionIsLocal[#stateTrace]
                            local lineNumber = lineNumberOfFunction[#stateTrace]
                            levelOfFunction[#stateTrace] = -1
                            stateTrace[#stateTrace] = nil
                            currentState = stateTrace[#stateTrace]
                            if currentState == "reversefunctiondef" or currentState == "wrappedreversefunctiondef" or currentState == "anonymousfunctiondef" then
                                StoreSourceCode(beginningLineOfFunction[#stateTrace], lineNumberOfToken[i])
                                if noStop then
                                    if currentState == "wrappedfunctiondef" or currentState == "wrappedreversefunctiondef" then
                                        finalCode = finalCode ..  token .. "), " .. #WSDebug.SourceCode .. ")"
                                    else
                                        finalCode = finalCode ..  token .. ", " .. #WSDebug.SourceCode .. ")"
                                    end
                                else
                                    if currentState == "wrappedfunctiondef" or currentState == "wrappedreversefunctiondef" then
                                        finalCode = finalCode .. "WSDebug['" .. checkForStopKey .. "'](" .. lineNumberOfToken[i] .. ", wsdebug_generationCounter) " ..  token .. "), " .. #WSDebug.SourceCode .. ")"
                                    else
                                        finalCode = finalCode .. "WSDebug['" .. checkForStopKey .. "'](" .. lineNumberOfToken[i] .. ", wsdebug_generationCounter) " ..  token .. ", " .. #WSDebug.SourceCode .. ")"
                                    end
                                end
                            else
                                if noStop then
                                    finalCode = finalCode .. token .. " "
                                else
                                    finalCode = finalCode .. "WSDebug['" .. checkForStopKey .. "'](" .. lineNumberOfToken[i] .. ", wsdebug_generationCounter) end "
                                end
                                if currentState == "wrappedfunctiondef" or currentState == "wrappedreversefunctiondef" then
                                    StoreSourceCode(beginningLineOfFunction[#stateTrace], lineNumberOfToken[i])
                                    finalCode = finalCode .. "), " .. #WSDebug.SourceCode .. ")"
                                end
                            end
                            if (currentState == "functiondef" or currentState == "wrappedfunctiondef") and name then
                                if isLocal then
                                    local funcKey = "AV" .. tabAndGenStr .. "ws" .. (currentLevel - 1)
                                    if not WSDebug[funcKey] then
                                        WSDebug[funcKey] = CompileAssignVarFunc(whichTab, currentLevel - 1)
                                    end
                                    finalCode = finalCode .. " WSDebug['" .. funcKey .. "'](" .. name:gsub(":", ".") .. ", '" .. name:gsub(":", ".") .. "') "
                                else
                                    local funcKey = "AVG" .. tabAndGenStr
                                    if not WSDebug[funcKey] then
                                        WSDebug[funcKey] = CompileGlobalAssignVarFunc(whichTab)
                                    end
                                    finalCode = finalCode .. " WSDebug['" .. funcKey .. "'](" .. name:gsub(":", ".") .. ", " .. lineNumber .. ", '" .. name:gsub(":", ".") .. "') "
                                end
                                AddVariables(name, isLocal, currentLevel - 1)
                            end

                            if name then
                                finalCode = finalCode .. " WSDebug.FuncNames[" .. name .. "] = '" .. name .. "'"
                            end

                            stateTrace[#stateTrace] = nil
                            currentState = stateTrace[#stateTrace]
                            SetVariables(lineNumberOfToken[i])
                            if currentState == "functiondef" or currentState == "wrappedfunctiondef" then
                                beginningOfStatementToken[#stateTrace - 1] = i + 1
                                beginningOfStatementCode[#stateTrace - 1] = #finalCode + 1
                            elseif currentState == "functionbody" then
                                beginningOfStatementToken[#stateTrace] = i + 1
                                beginningOfStatementCode[#stateTrace] = #finalCode + 1
                            end
                        else
                            if noStop then
                                finalCode = finalCode .. " end "
                            else
                                finalCode = finalCode .. " WSDebug['" .. checkForStopKey .. "'](" .. lineNumberOfToken[i] .. ", wsdebug_generationCounter) end "
                            end
                            SetVariables(lineNumberOfToken[i])
                            beginningOfStatementToken[#stateTrace] = i + 1
                            beginningOfStatementCode[#stateTrace] = #finalCode + 1
                        end
                        ReduceLevel()

                    elseif token == "{" then
                        currentState = "tabledef"
                        stateTrace[#stateTrace + 1] = currentState
                        finalCode = finalCode .. token
                        if tokens[i - 1] == "=" then
                            if tokens[i - 2] == "]" then
                                tableTrace[#tableTrace + 1] = tokens[i - 4] .. tokens[i - 3]:gsub('"', '\\"'):gsub("'", "\\'") .. tokens[i - 2]
                            else
                                tableTrace[#tableTrace + 1] = tokens[i - 2]
                            end
                        else
                            untracedTables = untracedTables + 1
                        end

                    elseif token == "}" then
                        stateTrace[#stateTrace] = nil
                        currentState = stateTrace[#stateTrace]
                        finalCode = finalCode .. token
                        if untracedTables > 0 then
                            untracedTables = untracedTables - 1
                        else
                            tableTrace[#tableTrace] = nil
                        end

                    elseif token == "=" then
                        if currentState ~= "tabledef" and currentState ~= "loopheader" then
                            currentState = "assignment"
                            stateTrace[#stateTrace + 1] = currentState
                            finalCode = finalCode .. token .. " "
                            beginningOfStatementToken[#stateTrace] = i + 1
                            beginningOfStatementCode[#stateTrace] = #finalCode + 1
                        else
                            finalCode = finalCode .. token .. " "
                        end
                    elseif token == "[" and (currentState == "root" or currentState == "functionbody") then
                        currentState = "index"
                        stateTrace[#stateTrace + 1] = currentState
                        finalCode = finalCode .. token
                    elseif token == "]" and currentState == "index" then
                        stateTrace[#stateTrace] = nil
                        currentState = stateTrace[#stateTrace]
                        finalCode = finalCode .. token
                    elseif token == "," then
                        finalCode = finalCode .. token .. " "
                    elseif not skip then
                        if currentState == "functiondef" then
                            functionName = token
                            if find(functionName, ":") == nil then
                                if tokens[i - 2] == "local" then
                                    finalCode[#finalCode] = functionName
                                    currentState = "wrappedfunctiondef"
                                    stateTrace[#stateTrace] = currentState
                                    finalCode = finalCode .. " " .. functionName .. " = " .. "WSDebug.StoreSourceCode(WSDebug.GetWrapper('" .. functionName .. "', wsdebug_executionTab, wsdebug_generationCounter, function"
                                else
                                    finalCode[#finalCode] = functionName
                                    currentState = "wrappedfunctiondef"
                                    stateTrace[#stateTrace] = currentState
                                    finalCode = finalCode .. " = " .. "nil " .. functionName .. " = " .. "WSDebug.StoreSourceCode(WSDebug.GetWrapper('" .. functionName .. "', wsdebug_executionTab, wsdebug_generationCounter, function"
                                end
                            else
                                finalCode = finalCode .. token .. " "
                            end
                        else
                            finalCode = finalCode .. token .. " "
                        end
                    end
                elseif not skip then
                    if currentState == "functiondef" then
                        functionName = token
                        if find(functionName, ":") == nil then
                            if tokens[i - 2] == "local" then
                                finalCode[#finalCode] = functionName
                                currentState = "wrappedfunctiondef"
                                stateTrace[#stateTrace] = currentState
                                finalCode = finalCode .. " " .. functionName .. " = " .. "WSDebug.StoreSourceCode(WSDebug.GetWrapper('" .. functionName .. "', wsdebug_executionTab, wsdebug_generationCounter, function"
                            else
                                finalCode[#finalCode] = functionName
                                currentState = "wrappedfunctiondef"
                                stateTrace[#stateTrace] = currentState
                                finalCode = finalCode .. " = " .. "nil " .. functionName .. " = " .. "WSDebug.StoreSourceCode(WSDebug.GetWrapper('" .. functionName .. "', wsdebug_executionTab, wsdebug_generationCounter, function"
                            end
                        else
                            finalCode = finalCode .. token .. " "
                        end
                    else
                        finalCode = finalCode .. token .. " "
                    end
                end

                i = i + 1
            end

            SetVariables(lineNumberOfToken[#tokens] + 1)

            if settings.runInit then
                finalCode = finalCode .. [[
                for j = 1, 7 do
                    for k = 1, #WSDebug.FunctionsToInit[j] do
                        WSDebug.FunctionsToInit[j][k]()
                    end
                end
                ]]
            end

            if tokens[#tokens - 1] == "end" then
                finalCode = finalCode .. "WSDebug.End(" .. lineNumberOfToken[#tokens] .. ", wsdebug_executionTab, wsdebug_generationCounter)"
            else
                finalCode = finalCode .. "WSDebug.End(" .. lineNumberOfToken[#tokens] + 1 .. ", wsdebug_executionTab, wsdebug_generationCounter)"
            end

            ------------------------------------------------------------------------------------------------------------------------
            --Parse function names and args
            ------------------------------------------------------------------------------------------------------------------------

            --Executed after transpiling and executing a script in debug mode. Function args are parsed directly on the first run in
            --no debug mode.
            local localDefs = {}
            local openParentheses = 0
            currentState = "root"
            tableTrace = {}
            untracedTables = 0

            for i = 1, #tokens do
                token = tokens[i]

                if token == "(" then
                    openParentheses = openParentheses + 1
                elseif token == ")" then
                    if currentState == "functiondef" or currentState == "reversefunctiondef" then
                        currentState = "functionbody"
                        stateTrace[#stateTrace + 1] = currentState
                    end
                    openParentheses = openParentheses - 1
                elseif token == "{" then
                    if tokens[i - 1] == "=" then
                        if tokens[i - 2] == "]" then
                            tableTrace[#tableTrace + 1] = tokens[i - 4] .. tokens[i - 3]:gsub('"', '\\"'):gsub("'", "\\'") .. tokens[i - 2]
                        else
                            tableTrace[#tableTrace + 1] = tokens[i - 2]
                        end
                    else
                        untracedTables = untracedTables + 1
                    end
                elseif token == "}" then
                    if untracedTables > 0 then
                        untracedTables = untracedTables - 1
                    else
                        tableTrace[#tableTrace] = nil
                    end
                elseif token == "local" then
                    local j = i + 1
                    if tokens[j] == "function" then
                        j = j + 1
                    end
                    repeat
                        localDefs[tokens[j]] = true
                        j = j + 2
                    until tokens[j - 1] ~= ","
                elseif token == "function" then
                    if untracedTables == 0 then
                        local name
                        local j
                        if tokens[i - 1] == "=" then
                            name = tokens[i - 2]
                            j = i + 2
                        else
                            name = tokens[i + 1]
                            j = i + 3
                        end
                        if name ~= "(" then
                            for k = #tableTrace, 1, -1 do
                                name = tableTrace[k] .. "." .. name
                            end
                            local dotPoint = find(name, "%.")
                            if not (dotPoint and localDefs[sub(name, 1, dotPoint - 1)] or localDefs[name]) then
                                args = ""
                                while tokens[j] ~= ")" do
                                    if tokens[j] == "," then
                                        args = args .. ", "
                                    else
                                        args = args .. tokens[j]
                                    end
                                    j = j + 1
                                end
                                args = args .. ","
                                FUNCTION_PREVIEW[name] = args
                            end
                        end
                    end
                end
            end
        else
            ------------------------------------------------------------------------------------------------------------------------
            --No debug mode
            ------------------------------------------------------------------------------------------------------------------------

            local localDefs = {}
            local openParentheses = 0

            for i = 1, #tokens do
                token = tokens[i]

                while lineNumberOfToken[i] > currentLine do
                    finalCode = finalCode .. "\n"
                    currentLine = currentLine + 1
                end

                if token == "(" then
                    openParentheses = openParentheses + 1
                    if settings.runInit and tokens[i - 1]:match("Init") ~= nil and (tokens[i - 1]:match("^OnInit.") ~= nil or tokens[i - 1]:match("^WSCode.Init") ~= nil) then
                        finalCode[#finalCode] = "WSDebug.Execute('" .. tokens[i - 1]:match("%.(.*)") .. "', "
                    elseif compiler.STORE_HANDLE_ORIGIN and CREATOR_DESTRUCTOR_PAIRS[tokens[i - 1]] and tokens[i - 2] ~= "function" then
                        if tokens[i + 1] == ")" then
                            finalCode = finalCode .. "WSOriginWrapper" .. "('" .. whichTab .. "', " .. currentLine .. ", " .. tokens[i - 1]
                        else
                            finalCode = finalCode .. "WSOriginWrapper" .. "('" .. whichTab .. "', " .. currentLine .. ", " .. tokens[i - 1] .. ", "
                        end
                    else
                        finalCode = finalCode .. token
                    end
                elseif token == ")" then
                    if currentState == "functiondef" or currentState == "reversefunctiondef" then
                        currentState = "functionbody"
                        stateTrace[#stateTrace + 1] = currentState
                        finalCode = finalCode .. ") "
                    else
                        finalCode = finalCode .. ") "
                    end
                    openParentheses = openParentheses - 1
                elseif token == "{" then
                    if tokens[i - 1] == "=" then
                        if tokens[i - 2] == "]" then
                            tableTrace[#tableTrace + 1] = tokens[i - 4] .. tokens[i - 3]:gsub('"', '\\"'):gsub("'", "\\'") .. tokens[i - 2]
                        else
                            tableTrace[#tableTrace + 1] = tokens[i - 2]
                        end
                    else
                        untracedTables = untracedTables + 1
                    end
                    finalCode = finalCode .. "{"
                elseif token == "}" then
                    if untracedTables > 0 then
                        untracedTables = untracedTables - 1
                    else
                        tableTrace[#tableTrace] = nil
                    end
                    finalCode = finalCode .. "} "
                elseif token == "local" and settings.parse then
                    local j = i + 1
                    if tokens[j] == "function" then
                        j = j + 1
                    end
                    repeat
                        localDefs[tokens[j]] = true
                        j = j + 2
                    until tokens[j - 1] ~= ","

                    finalCode = finalCode .. "local "
                elseif token == "function" then
                    if settings.parse and untracedTables == 0 then
                        local name
                        local j
                        if tokens[i - 1] == "=" then
                            name = tokens[i - 2]
                            j = i + 2
                        else
                            name = tokens[i + 1]
                            j = i + 3
                        end
                        if name ~= "(" then
                            for k = #tableTrace, 1, -1 do
                                name = tableTrace[k] .. "." .. name
                            end
                            local dotPoint = find(name, "%.")
                            if not (dotPoint and localDefs[sub(name, 1, dotPoint - 1)] or localDefs[name]) then
                                args = ""
                                while tokens[j] ~= ")" do
                                    if tokens[j] == "," then
                                        args = args .. ", "
                                    else
                                        args = args .. tokens[j]
                                    end
                                    j = j + 1
                                end
                                args = args .. ","
                                FUNCTION_PREVIEW[name] = args
                            end
                        end
                    end
                    finalCode = finalCode .. "function "
                else
                    finalCode = finalCode .. token .. " "
                end
            end
        end

        ------------------------------------------------------------------------------------------------------------------------
        --Execute function
        ------------------------------------------------------------------------------------------------------------------------

        local functionString = table.concat(finalCode)

        if compiler.STORE_HANDLE_ORIGIN then
            functionString = functionString:gsub(" WSOriginWrapper", "WSOriginWrapper")
        end

        if (settings.debugMode or not settings.duringInit) and diagnostics.DUMP_TRANSPILED_SCRIPTS then
            if io then
                local file = io.open(LuaFileFolder .. "\\WSCodeTranspiled.lua", "w")
                if file then
                    file:write(functionString)
                    file:close()
                else
                    FileIO.Export(editor.EXPORT_SUBFOLDER .. "\\WSCodeTranspiled" .. whichTab:sub(1,1):upper() .. whichTab:sub(2):gsub(" ", "") .. ".txt", functionString)
                end
            else
                FileIO.Export(editor.EXPORT_SUBFOLDER .. "\\WSCodeTranspiled" .. whichTab:sub(1,1):upper() .. whichTab:sub(2):gsub(" ", "") .. ".txt", functionString)
            end
            WSDebug.PrintForUser("Transpiled script written to file WSCodeTranspiled" .. whichTab:sub(1,1):upper() .. whichTab:sub(2):gsub(" ", "") .. ".txt.")
        end

        local func, err
        local loadLabel = settings.chunkName or ("WSCode " .. (tabs.names[whichTab] or whichTab or "Unknown"))
        if diagnostics.PROFILE_INIT and settings.duringInit then
            local time = clock()
            func, err = load(functionString, loadLabel, "t")
            local endTime = clock()
            init.profiler[whichTab] = (init.profiler[whichTab] or 0) + endTime - time
        else
            func, err = load(functionString, loadLabel, "t")
        end
        if not func then
            if err and err:match("too many local variables") then
                WSDebug.PrintForUser("|cffff5555ERROR at WSCode  " .. (whichTab or "Unknown") .. ": Code chunk could not be transpiled because the local variable limit (200) was exceeded by adding debug variables. The function was compiled in raw form.|r")
            else
                WSDebug.PrintForUser("|cffff5555ERROR at WSCode  " .. (whichTab or "Unknown") .. err .. ": Raw code did compile, but transpiled code did not. Please report this bug along with the code chunk and settings that caused it. The function was compiled in raw form.|r")
            end
            if settings.duringInit then
                func = originalFunc
            else
                return
            end
        end

        if settings.compileOnly then
            return func
        end

        if settings.cleanHandles then
            for handle, creator in next, handles[whichTab] do
                if _ENV[CREATOR_DESTRUCTOR_PAIRS[creator]] then
                    _ENV[CREATOR_DESTRUCTOR_PAIRS[creator]](handle)
                end
                handles[whichTab][handle] = nil
            end
        end

        if settings.duringInit then
            if Debug then
                xpcall(func, Debug.errorHandler)
            else
                ---@diagnostic disable-next-line: need-check-nil
                func()
            end
        else
            currentCoroutine[whichTab] = coroutine.create(func)
            coroutine.resume(currentCoroutine[whichTab])
        end
    end

    --======================================================================================================================
    --Top Buttons
    --======================================================================================================================

    local function CreateToggleExpandButton(type, texture, whichParent)
        local button = BlzCreateFrame(type, whichParent, 0, 0)
        local icon = BlzFrameGetChild(button, 0)
        local iconClicked = BlzFrameGetChild(button, 1)
        local iconHighlight = BlzFrameGetChild(button, 2)
        BlzFrameSetAllPoints(icon, button)
        BlzFrameSetTexture(icon, texture, 0, true)
        BlzFrameSetTexture(iconClicked, texture, 0, true)
        BlzFrameClearAllPoints(iconHighlight)
        BlzFrameSetPoint(iconHighlight, FRAMEPOINT_BOTTOMLEFT, button, FRAMEPOINT_BOTTOMLEFT, 0.00375, 0.00375)
        BlzFrameSetPoint(iconHighlight, FRAMEPOINT_TOPRIGHT, button, FRAMEPOINT_TOPRIGHT, -0.00375, -0.00375)
        local trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, button, FRAMEEVENT_CONTROL_CLICK)
        if whichParent == codeEditorParent then
            BlzFrameSetPoint(button, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CLOSE_BUTTON_INSET, -editor.CLOSE_BUTTON_INSET - editor.CLOSE_BUTTON_SIZE)
            BlzFrameSetPoint(button, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CLOSE_BUTTON_INSET + editor.CLOSE_BUTTON_SIZE, -editor.CLOSE_BUTTON_INSET)
            TriggerAddAction(trig, ToggleExpand)
            buttons.expand = button
        else
            BlzFrameSetPoint(button, FRAMEPOINT_BOTTOMLEFT, variableViewer.parent, FRAMEPOINT_TOPRIGHT, -editor.CLOSE_BUTTON_INSET - editor.CLOSE_BUTTON_SIZE, -editor.CLOSE_BUTTON_INSET - editor.CLOSE_BUTTON_SIZE)
            BlzFrameSetPoint(button, FRAMEPOINT_TOPRIGHT, variableViewer.parent, FRAMEPOINT_TOPRIGHT, -editor.CLOSE_BUTTON_INSET, -editor.CLOSE_BUTTON_INSET)
            TriggerAddAction(trig, ToggleVariableViewerExpand)
            buttons.expandVariableViewer = button
        end
    end

    ToggleExpand = function()
        BlzFrameSetEnable(buttons.expand, false)
        BlzFrameSetEnable(buttons.expand, true)
        editor.isExpanded = not editor.isExpanded

        if editor.isExpanded then
            BlzFrameSetVisible(buttons.expand, false)
            CreateToggleExpandButton("CollapseEditorButton", editor.ASSET_SUBFOLDER .. "\\collapseEditor.blp", codeEditorParent)
            BlzFrameSetAbsPoint(codeEditorParent, FRAMEPOINT_TOPLEFT, editor.EXPANDED_X, editor.Y_TOP)
            BlzFrameSetSize(codeEditorParent, editor.EXPANDED_WIDTH, editor.MAX_LINES_ON_SCREEN*editor.LINE_SPACING + editor.CODE_TOP_INSET + editor.CODE_BOTTOM_INSET)
            UpdateAllLines()
            AdjustHorizontalLineScroller()
            BlzFrameSetSize(codeHorizontalScroller, editor.EXPANDED_WIDTH - editor.CODE_HORIZONTAL_SCROLLER_LEFT_INSET - editor.CODE_HORIZONTAL_SCROLLER_RIGHT_INSET, editor.CODE_HORIZONTAL_SCROLLER_HEIGHT)
            editor.ON_EXPAND()
        else
            BlzFrameSetVisible(buttons.expand, false)
            CreateToggleExpandButton("ExpandEditorButton", editor.ASSET_SUBFOLDER .. "\\expandEditor.blp", codeEditorParent)
            BlzFrameSetAbsPoint(codeEditorParent, FRAMEPOINT_TOPLEFT, editor.COLLAPSED_X, editor.Y_TOP)
            BlzFrameSetSize(codeEditorParent, editor.COLLAPSED_WIDTH, editor.MAX_LINES_ON_SCREEN*editor.LINE_SPACING + editor.CODE_TOP_INSET + editor.CODE_BOTTOM_INSET)
            UpdateAllLines()
            AdjustHorizontalLineScroller()
            BlzFrameSetSize(codeHorizontalScroller, editor.COLLAPSED_WIDTH - editor.CODE_HORIZONTAL_SCROLLER_LEFT_INSET - editor.CODE_HORIZONTAL_SCROLLER_RIGHT_INSET, editor.CODE_HORIZONTAL_SCROLLER_HEIGHT)
            editor.ON_COLLAPSE()
        end

        local spaceRequired = 0
        for i = 1, tabs.amount do
            spaceRequired = spaceRequired + tabNavigator.widths[tabs.names[i]] - tabNavigator.OVERLAP
        end

        AdjustTabWidths()
    end

    ToggleVariableViewerExpand = function()
        BlzFrameSetEnable(buttons.expandVariableViewer, false)
        BlzFrameSetEnable(buttons.expandVariableViewer, true)
        variableViewer.isExpanded = not variableViewer.isExpanded

        if variableViewer.isExpanded then
            BlzFrameSetVisible(buttons.expandVariableViewer, false)
            CreateToggleExpandButton("CollapseEditorButton", editor.ASSET_SUBFOLDER .. "\\collapseEditor.blp", variableViewer.parent)
            variableViewer.numVisibleVarsScreen = 0
            UpdateVariableViewer(lineNumbers.lastViewed[currentTab] or lastLineNumber[currentTab])
            BlzFrameSetVisible(variableViewer.title, true)
            BlzFrameSetVisible(buttons.back, #variableViewer.viewedVariableTrace > 0)
            ToggleVariableViewerScrollerVisibility(variableViewer.numVisibleVarsTotal > variableViewer.numVisibleVarsScreen)
        else
            BlzFrameSetVisible(buttons.expandVariableViewer, false)
            CreateToggleExpandButton("ExpandEditorButton", editor.ASSET_SUBFOLDER .. "\\expandEditor.blp", variableViewer.parent)
            BlzFrameSetSize(variableViewer.parent, editor.CLOSE_BUTTON_SIZE + 2*editor.CLOSE_BUTTON_INSET, editor.CLOSE_BUTTON_SIZE + 2*editor.CLOSE_BUTTON_INSET)
            for i = 1, variableViewer.numVisibleVarsScreen do
                BlzFrameSetVisible(variableViewer.frames[i], false)
                BlzFrameSetVisible(variableViewer.valueFrames[i], false)
            end
            ToggleVariableViewerScrollerVisibility(false)
            BlzFrameSetVisible(variableViewer.title, false)
            BlzFrameSetVisible(buttons.back, false)
            variableViewer.hasNotBeenExpanded = false
        end
    end

    --======================================================================================================================
    --Benchmark
    --======================================================================================================================

    local function BenchmarkLoop()
        local function GetMeanAndStdDev()
            local mean = 0
            local numResults = #benchmark.results
            for __, value in ipairs(benchmark.results) do
                mean = mean + value
            end

            mean = mean / numResults

            local varianceTotal = 0
            for __, value in ipairs(benchmark.results) do
                varianceTotal = varianceTotal + (value - mean)^2
            end

            local stddev = math.sqrt(1/(numResults - 1)*varianceTotal)
            local stddevOfMean = stddev/math.sqrt(numResults)

            return mean, stddevOfMean
        end

        local time = clock()
        if benchmark.gauge then
            local doNothing = DoNothing
            for __ = 1, benchmark.iterations do
                doNothing()
            end
        else
            local func = benchmark.func
            for __ = 1, benchmark.iterations do
                func()
            end
        end
        local elapsedTime = clock() - time
        if elapsedTime < 0.005 then
            benchmark.iterations = 10*benchmark.iterations
        elseif elapsedTime < 0.05 then
            benchmark.iterations = (benchmark.iterations*0.055/elapsedTime) // 1
        else
            if benchmark.gauge then
                benchmark.emptyFunctionNanoseconds = elapsedTime*10^9/benchmark.iterations
                benchmark.gauge = false
            else
                local executionTime = ((elapsedTime*10^9/benchmark.iterations) - benchmark.emptyFunctionNanoseconds) // 1
                table.insert(benchmark.results, executionTime)
                ClearTextMessages()
                local mean, stddev = GetMeanAndStdDev()
                if stddev > 0 then
                    if mean < 10000 then
                        WSDebug.PrintForUser("Execution time of code chunk is: " .. string.format("%.1f", mean) .. " +/- " .. string.format("%.1f", stddev) .. " |cff00ff00nano|rseconds.")
                    elseif mean < 10000000 then
                        WSDebug.PrintForUser("Execution time of code chunk is: " .. string.format("%.1f", mean/1000) .. " +/- " .. string.format("%.1f", stddev/1000) .. " |cffffff00micro|rseconds.")
                    else
                        WSDebug.PrintForUser("Execution time of code chunk is: " .. string.format("%.1f", mean/1000000) .. " +/- " .. string.format("%.1f", stddev/1000000) .. " |cffff8800milli|rseconds.")
                    end
                else
                    if mean < 10000 then
                        WSDebug.PrintForUser("Execution time of code chunk is: " .. mean .. " |cff00ff00nano|rseconds.")
                    elseif mean < 10000000 then
                        WSDebug.PrintForUser("Execution time of code chunk is: " .. mean//1000 .. " |cffffff00micro|rseconds.")
                    else
                        WSDebug.PrintForUser("Execution time of code chunk is: " .. mean//1000000 .. " |cffff8800milli|rseconds.")
                    end
                end
                benchmark.gauge = true
            end
            benchmark.iterations = 10
        end
        TimerStart(benchmark.TIMER, elapsedTime + 0.01, false, BenchmarkLoop)
    end

    --======================================================================================================================
    --Search Bar
    --======================================================================================================================

    local function ShowSearchBar()
        BlzFrameSetEnable(buttons["Search"], false)
        BlzFrameSetEnable(buttons["Search"], true)
        BlzFrameSetVisible(searchBar.parent, true)
        if selection.hasSelection then
            BlzFrameSetText(searchBar.textField, ConvertSelectionToLines()[1])
        else
            BlzFrameSetText(searchBar.textField, "")
        end
        BlzFrameSetFocus(editBox, false)
        BlzFrameSetFocus(searchBar.textField, true)
    end

    RenderSearchHighlights = function()
        local currentLines = codeLines[currentTab][step[currentTab]]
        local numVisible = 0
        for i = 1, searchBar.numFinds do
            if searchBar.lines[i] > tabs.lineNumberOffset[currentTab] and searchBar.lines[i] <= tabs.lineNumberOffset[currentTab] + editor.MAX_LINES_ON_SCREEN then
                numVisible = numVisible + 1
                searchBar.highlights[numVisible] = searchBar.highlights[numVisible] or GetTextHighlightFrame("05", 120, "searchHighlight")
                BlzFrameSetPoint(searchBar.highlights[numVisible], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[searchBar.lines[i]], tabs.horizontalOffset[currentTab] + 1, searchBar.startPos[i])), -editor.CODE_TOP_INSET - (searchBar.lines[i] - tabs.lineNumberOffset[currentTab])*editor.LINE_SPACING)
                BlzFrameSetPoint(searchBar.highlights[numVisible], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + GetTextWidth(sub(currentLines[searchBar.lines[i]], tabs.horizontalOffset[currentTab] + 1, searchBar.endPos[i])), -editor.CODE_TOP_INSET - (searchBar.lines[i] - tabs.lineNumberOffset[currentTab] - 1)*editor.LINE_SPACING)
                if i == searchBar.searchPos then
                    BlzFrameSetTexture(searchBar.highlights[numVisible], "ReplaceableTextures\\TeamColor\\TeamColor05.blp", 0, true)
                    SetFrameAlpha(searchBar.highlights[numVisible], 150)
                else
                    BlzFrameSetTexture(searchBar.highlights[numVisible], "ReplaceableTextures\\TeamColor\\TeamColor23.blp", 0, true)
                    SetFrameAlpha(searchBar.highlights[numVisible], 120)
                end
            end
        end

        for i = numVisible + 1, #searchBar.highlights do
            ReturnTextHighlightFrame(searchBar.highlights[i])
            searchBar.highlights[i] = nil
        end
    end

    FindSearchItems = function()
        if searchBar.text == "" then
            searchBar.numFinds = 0
            RenderSearchHighlights()
            BlzFrameSetEnable(searchBar.searchDownButton, false)
            BlzFrameSetEnable(searchBar.searchUpButton, false)
            BlzFrameSetText(searchBar.numResults, "|cffaaaaaaNo results|r")
            return
        end

        local text = searchBar.text:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1") --escape all special characters

        if sub(text, 1, 1) == ":" then
            local lineNumber = tonumber(sub(text, 2))
            if lineNumber then
                lineNumber = math.tointeger(lineNumber)
                if lineNumber then
                    JumpWindow(lineNumber, true)
                    searchBar.numFinds = 0
                    RenderSearchHighlights()
                    BlzFrameSetEnable(searchBar.searchDownButton, false)
                    BlzFrameSetEnable(searchBar.searchUpButton, false)
                    BlzFrameSetText(searchBar.numResults, "|cffaaaaaaNo results|r")
                    return
                end
            end
        end

        local currentLines = codeLines[currentTab][step[currentTab]]
        local str, j, start, stop
        local numFinds = 0
        local searchPos = 1
        for i = 1, highestNonEmptyLine[currentTab][step[currentTab]] do
            str = currentLines[i]
            j = 1
            start, stop = str:find(text)
            while start do
                numFinds = numFinds + 1
                searchBar.lines[numFinds] = i
                searchBar.startPos[numFinds] = start - 1
                searchBar.endPos[numFinds] = stop
                if cursor.codeLineNumber and (i < cursor.codeLineNumber or i == cursor.codeLineNumber and cursor.pos < stop) then
                    searchPos = searchPos + 1
                end
                j = j + 1
                start, stop = str:find(text, stop + 1)
            end
        end
        searchBar.numFinds = numFinds
        if searchBar.numFinds > 0 then
            if cursor.codeLineNumber then
                searchBar.searchPos = min(searchPos, numFinds)
            else
                searchBar.searchPos = 1
            end
            JumpWindow(searchBar.lines[searchBar.searchPos])
            BlzFrameSetText(searchBar.numResults, searchBar.searchPos .. " of " .. searchBar.numFinds)
            BlzFrameSetEnable(searchBar.searchDownButton, true)
            BlzFrameSetEnable(searchBar.searchUpButton, true)
        else
            searchBar.searchPos = nil
            BlzFrameSetText(searchBar.numResults, "|cffff0000No results|r")
            BlzFrameSetEnable(searchBar.searchDownButton, false)
            BlzFrameSetEnable(searchBar.searchUpButton, false)
        end
    end

    local function OnSearchBarEdit()
        searchBar.text = BlzGetTriggerFrameText()
        FindSearchItems()
        RenderSearchHighlights()
    end

    local function SearchUp()
        if searchBar.searchPos then
            searchBar.searchPos = searchBar.searchPos - 1
            if searchBar.searchPos == 0 then
                searchBar.searchPos = searchBar.numFinds
            end
            BlzFrameSetText(searchBar.numResults, searchBar.searchPos .. " of " .. searchBar.numFinds)
            JumpWindow(searchBar.lines[searchBar.searchPos])
            RenderSearchHighlights()
        end
    end

    local function SearchDown()
        if searchBar.searchPos then
            searchBar.searchPos = searchBar.searchPos + 1
            if searchBar.searchPos > searchBar.numFinds then
                searchBar.searchPos = 1
            end
            BlzFrameSetText(searchBar.numResults, searchBar.searchPos .. " of " .. searchBar.numFinds)
            JumpWindow(searchBar.lines[searchBar.searchPos])
            RenderSearchHighlights()
        end
    end

    --======================================================================================================================
    --Init
    --======================================================================================================================

    CreateControlTriggers = function()
        if not user then
            for i = 0, 23 do
                if user then
                    break
                end
                local player = Player(i)
                for __, creator in ipairs(editor.MAP_CREATORS) do
                    if find(GetPlayerName(player), creator) and GetPlayerController(player) == MAP_CONTROL_USER and GetPlayerSlotState(player) == PLAYER_SLOT_STATE_PLAYING then
                        user = Player(i)
                        break
                    end
                end
            end
        end

        local trig
        if editor.NEXT_LINE_HOTKEY then
            if AsyncControl then
                AsyncControl.Register({
                    oskey = _ENV["OSKEY_" .. editor.NEXT_LINE_HOTKEY],
                    metakey = WSCodeConfig.editor.NEXT_LINE_METAKEY,
                    exactMetakey = true,
                    onPress = function()
                        if WSCode.IsVisible() then
                            WSCode.ExecuteNextLine()
                        end
                    end,
                    whilePressed = "onPress",
                    delay = 0.5,
                    interval = 0.06
                })
            else
                trig = CreateTrigger()
                BlzTriggerRegisterPlayerKeyEvent(trig, user, _ENV["OSKEY_" .. editor.NEXT_LINE_HOTKEY], editor.NEXT_LINE_METAKEY, true)
                TriggerAddAction(trig, WSCode.ExecuteNextLine)
            end
        end

        if editor.CONTINUE_HOTKEY then
            if AsyncControl then
                AsyncControl.Register({
                    oskey = _ENV["OSKEY_" .. editor.CONTINUE_HOTKEY],
                    metakey = WSCodeConfig.editor.CONTINUE_METAKEY,
                    exactMetakey = true,
                    onPress = function()
                        if WSCode.IsVisible() then
                            WSCode.ContinueExecuting()
                        end
                    end,
                    whilePressed = "onPress",
                    delay = 0.5,
                    interval = 0.06
                })
            else
                trig = CreateTrigger()
                BlzTriggerRegisterPlayerKeyEvent(trig, user, _ENV["OSKEY_" .. editor.CONTINUE_HOTKEY], editor.CONTINUE_METAKEY, true)
                TriggerAddAction(trig, WSCode.ContinueExecuting)
            end
        end

        if editor.TOGGLE_HIDE_EDITOR_HOTKEY then
            if AsyncControl then
                AsyncControl.Register({
                    oskey = _ENV["OSKEY_" .. WSCodeConfig.editor.TOGGLE_HIDE_EDITOR_HOTKEY],
                    metakey = WSCodeConfig.editor.TOGGLE_HIDE_EDITOR_METAKEY,
                    exactMetakey = true,
                    onPress = function()
                        if not codeEditorParent or not BlzFrameIsVisible(codeEditorParent) then
                            EnableEditor(user)
                        else
                            BlzFrameSetVisible(codeEditorParent, false)
                            editor.ON_DISABLE()
                        end
                    end
                })
            else
                trig = CreateTrigger()
                BlzTriggerRegisterPlayerKeyEvent(trig, user, _ENV["OSKEY_" .. editor.TOGGLE_HIDE_EDITOR_HOTKEY], editor.TOGGLE_HIDE_EDITOR_METAKEY, true)
                TriggerAddAction(trig, function()
                    if not codeEditorParent or not BlzFrameIsVisible(codeEditorParent) then
                        EnableEditor(user)
                    else
                        BlzFrameSetVisible(codeEditorParent, false)
                        editor.ON_DISABLE()
                    end
                end)
            end
        end

        --Any registered key event means the enter box is not focused.
        trig = CreateTrigger()
        for name, oskey in next, _G do
            if find(name, "^OSKEY_") then
                for metakey = 0, 3 do
                    BlzTriggerRegisterPlayerKeyEvent(trig, user, oskey, metakey, true)
                end
            end
        end
        TriggerAddAction(trig, function()
            if editBoxFocused then
                editBoxFocused = false
                editor.ON_DEFOCUS()
            end
            BlzFrameSetVisible(cursorFrame, false)
        end)
    end

    EnableEditor = function(whichPlayer)
        whichPlayer = whichPlayer or GetTriggerPlayer()
        user = user or whichPlayer

        if not BlzLoadTOCFile(editor.ASSET_SUBFOLDER .. "\\CodeEditor.toc") then
            if Debug then
                Debug.throwError(editor.ASSET_SUBFOLDER .. "\\CodeEditor.toc failed to load.")
            end
        end

        if codeEditorParent then
            if GetLocalPlayer() == user then
                BlzFrameSetVisible(codeEditorParent, true)
                editor.timeOfDefocus = timeElapsed
                editor.fadeState = 1
                SetFrameAlpha(codeEditorParent, 255)
            end
            editor.ON_ENABLE()
            return
        end

        if not HandleType then
            if Debug then
                Debug.throwError("Missing requirement: HandleType.")
            end
            return
        end

        ------------------------------------------------------------------------------------------------------------------------
        --Code Editor
        ------------------------------------------------------------------------------------------------------------------------

        local parent = editor.GET_PARENT()
        if GetHandleId(parent) == 0 then
            if Debug then
                Debug.throwError("Invalid parent frame.")
            end
            return
        end

        codeEditorParent = BlzCreateFrame("CodeEditor", parent, 0, 0)
        if GetHandleId(codeEditorParent) == 0 then
            if Debug then
                Debug.throwError("Missing import: CodeEditor.fdf.")
            end
            return
        end
        BlzFrameSetVisible(codeEditorParent, GetLocalPlayer() == user)

        BlzFrameSetLevel(codeEditorParent, 2)

        local backdrop = BlzFrameGetChild(codeEditorParent, 0)
        BlzFrameSetAllPoints(backdrop, codeEditorParent)
        SetFrameAlpha(backdrop, editor.BLACK_BACKDROP_ALPHA)

        local border = BlzFrameGetChild(codeEditorParent, 1)
        BlzFrameSetAllPoints(border, codeEditorParent)

        local titleFrame = BlzCreateFrameByType("TEXT", "", codeEditorParent, "", 0)
        BlzFrameSetText(titleFrame, "|cffffcc00Warcraft Studio Code|r")
        BlzFrameSetEnable(titleFrame, false)
        BlzFrameSetSize(titleFrame, 0, 0)
        BlzFrameSetPoint(titleFrame, FRAMEPOINT_TOP, codeEditorParent, FRAMEPOINT_TOP, 0, editor.TITLE_VERTICAL_SHIFT)

        highlights.error = BlzCreateFrameByType("BACKDROP", "", codeEditorParent, "", 0)
        BlzFrameSetTexture(highlights.error, "ReplaceableTextures\\TeamColor\\TeamColor00.blp", 0, true)
        SetFrameAlpha(highlights.error, 128)
        BlzFrameSetEnable(highlights.error, false)
        BlzFrameSetVisible(highlights.error, false)

        codeScroller = BlzCreateFrame("VerticalSlider", codeEditorParent, 0, 0)
        if GetHandleId(codeScroller) == 0 then
            if Debug then
                Debug.throwError("Missing import: VerticalSlider.fdf.")
            end
            return
        end

        BlzFrameSetPoint(codeScroller, FRAMEPOINT_TOP, codeEditorParent, FRAMEPOINT_TOPRIGHT, -editor.CODE_SCROLLER_HORIZONTAL_INSET, -editor.CODE_TOP_INSET)
        BlzFrameSetSize(codeScroller, editor.CODE_SCROLLER_WIDTH, editor.MAX_LINES_ON_SCREEN*editor.LINE_SPACING)
        BlzFrameSetMinMaxValue(codeScroller, 0, highestNonEmptyLine[currentTab][step[currentTab]])
        BlzFrameSetValue(codeScroller, highestNonEmptyLine[currentTab][step[currentTab]])
        BlzFrameSetStepSize(codeScroller, 1)
        BlzFrameSetLevel(codeScroller, 3)

        CheckLongestLineLength()
        codeHorizontalScroller = BlzCreateFrame("EscMenuSliderTemplate",  codeEditorParent, 0, 0)
        BlzFrameSetPoint(codeHorizontalScroller, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_BOTTOMLEFT, editor.CODE_HORIZONTAL_SCROLLER_LEFT_INSET, editor.CODE_HORIZONTAL_SCROLLER_VERTICAL_INSET)
        BlzFrameSetSize(codeHorizontalScroller, editor.COLLAPSED_WIDTH - editor.CODE_HORIZONTAL_SCROLLER_LEFT_INSET - editor.CODE_HORIZONTAL_SCROLLER_RIGHT_INSET, editor.CODE_HORIZONTAL_SCROLLER_HEIGHT)
        BlzFrameSetValue(codeHorizontalScroller, 0)
        BlzFrameSetVisible(codeHorizontalScroller, tabs.longestLineLength[currentTab] > editor.CHARS_ON_SCREEN_COLLAPSED)
        BlzFrameSetMinMaxValue(codeHorizontalScroller, 0, max(0, tabs.longestLineLength[currentTab] - editor.CHARS_ON_SCREEN_COLLAPSED))
        BlzFrameSetStepSize(codeHorizontalScroller, 1)
        BlzFrameSetLevel(codeHorizontalScroller, 3)

        local trigStop = CreateTrigger()

        for i = 1, editor.MAX_LINES_ON_SCREEN do
            if editor.USE_MONOSPACE_FONT then
                codeLineFrames[i] = BlzCreateFrame("Consolas", codeEditorParent, 0, 0)
            else
                codeLineFrames[i] = BlzCreateFrameByType("TEXT", "", codeEditorParent, "", 0)
            end
            BlzFrameSetPoint(codeLineFrames[i], FRAMEPOINT_TOPLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET, -editor.CODE_TOP_INSET - (i-1)*editor.LINE_SPACING)
            BlzFrameSetPoint(codeLineFrames[i], FRAMEPOINT_BOTTOMRIGHT, codeEditorParent, FRAMEPOINT_TOPRIGHT, 1.0, -editor.CODE_TOP_INSET - i*editor.LINE_SPACING)
            BlzFrameSetTextAlignment(codeLineFrames[i], TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
            local currentLines = codeLines[currentTab][step[currentTab]]
            if i <= highestNonEmptyLine[currentTab][step[currentTab]] then
                coloredCodeLines[currentTab][step[currentTab]][i] = nil
                if i <= editor.MAX_LINES_ON_SCREEN then
                    RenderLine(i, currentLines[i], coloredCodeLines[currentTab][step[currentTab]][i])
                end
            else
                BlzFrameSetText(codeLineFrames[i], "")
            end
            BlzFrameSetLevel(codeLineFrames[i], 1)

            lineNumberFrames[i] = BlzCreateFrameByType("TEXT", "", codeEditorParent, "", 0)
            BlzFrameSetPoint(lineNumberFrames[i], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.LINE_NUMBER_HORIZONTAL_INSET/editor.LINE_NUMBER_SCALE, (-editor.CODE_TOP_INSET - i*editor.LINE_SPACING)/editor.LINE_NUMBER_SCALE)
            BlzFrameSetPoint(lineNumberFrames[i], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPRIGHT, -editor.CODE_LEFT_INSET/editor.LINE_NUMBER_SCALE, (-editor.CODE_TOP_INSET - (i - 1)*editor.LINE_SPACING)/editor.LINE_NUMBER_SCALE)
            BlzFrameSetTextAlignment(lineNumberFrames[i], TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
            BlzFrameSetEnable(lineNumberFrames[i], false)
            BlzFrameSetScale(lineNumberFrames[i], editor.LINE_NUMBER_SCALE)
            if lineNumberWasExecuted[currentTab][i] then
                BlzFrameSetText(lineNumberFrames[i], editor.LINE_NUMBER_COLOR .. i .. "|r")
            else
                BlzFrameSetText(lineNumberFrames[i], editor.IDLE_LINE_NUMBER_COLOR .. i .. "|r")
            end
            indexFromFrame[lineNumberFrames[i]] = i

            stopButtons[i] = BlzCreateFrame("CodeEditorButton", codeEditorParent, 0, 0)
            BlzFrameSetPoint(stopButtons[i], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.STOP_BUTTON_HORIZONTAL_INSET, -editor.CODE_TOP_INSET - i*editor.LINE_SPACING)
            BlzFrameSetPoint(stopButtons[i], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.STOP_BUTTON_HORIZONTAL_INSET + editor.LINE_SPACING, -editor.CODE_TOP_INSET - (i-1)*editor.LINE_SPACING)
            BlzFrameSetAllPoints(BlzFrameGetChild(stopButtons[i], 0), stopButtons[i])
            BlzFrameSetTexture(BlzFrameGetChild(stopButtons[i], 0), LINE_STATE_ICONS[lines.debugState[currentTab][i]], 0, true)
            BlzTriggerRegisterFrameEvent(trigStop, stopButtons[i], FRAMEEVENT_CONTROL_CLICK)
            indexFromFrame[stopButtons[i]] = i
        end

        editBox = BlzCreateFrame("EscMenuEditBoxTemplate", codeEditorParent, 0, 0)
        BlzFrameSetPoint(editBox, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_BOTTOMLEFT, editor.CODE_LEFT_INSET - 0.002, editor.CODE_BOTTOM_INSET - 0.002)
        BlzFrameSetPoint(editBox, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPRIGHT, -editor.CODE_RIGHT_INSET + 0.002, -editor.CODE_TOP_INSET + 0.002)
        BlzFrameSetLevel(editBox, 2)
        SetFrameAlpha(editBox, 0)
        BlzFrameSetText(editBox, " ")
        local trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, editBox, FRAMEEVENT_MOUSE_WHEEL)
        TriggerAddAction(trig, function()
            if BlzGetTriggerFrameValue() > 0 then
                BlzFrameSetValue(codeScroller, BlzFrameGetValue(codeScroller) + 2)
            else
                BlzFrameSetValue(codeScroller, BlzFrameGetValue(codeScroller) - 2)
            end
        end)

        cursorFrame = BlzCreateFrameByType("BACKDROP", "", codeEditorParent, "", 0)
        BlzFrameSetSize(cursorFrame, 0.0008, editor.LINE_SPACING)
        BlzFrameSetTexture(cursorFrame, "ReplaceableTextures\\TeamColor\\TeamColor21.blp", 0, true)
        BlzFrameSetEnable(cursorFrame, false)
        BlzFrameSetVisible(cursorFrame, false)

        TriggerAddAction(trigStop, function()
            local button = BlzGetTriggerFrame()
            BlzFrameSetEnable(button, false)
            BlzFrameSetEnable(button, true)
            local lineNumber = indexFromFrame[button] + tabs.lineNumberOffset[currentTab]
            PutStop(lineNumber, false, currentTab)
        end)

        helper.parent = BlzCreateFrame("TextMessage", codeEditorParent, 0, 0)
        if GetHandleId(helper.parent) == 0 then
            if Debug then
                Debug.throwError("Missing import: NeatTextMessage.fdf.")
            end
        end

        helper.text = BlzFrameGetChild(helper.parent, 0)
        helper.box = BlzFrameGetChild(helper.parent, 1)
        BlzFrameSetAllPoints(helper.box, helper.parent)
        BlzFrameSetVisible(helper.parent, false)
        BlzFrameSetLevel(helper.parent, 3)
        BlzFrameSetLevel(helper.text, 1)
        BlzFrameSetEnable(helper.parent, false)
        BlzFrameSetEnable(helper.text, false)
        BlzFrameSetEnable(helper.box, false)

        helper.suggestionHighlightFrame = BlzCreateFrameByType("BACKDROP", "", helper.parent, "", 0)
        SetFrameAlpha(helper.suggestionHighlightFrame, 128)
        BlzFrameSetTexture(helper.suggestionHighlightFrame, "ReplaceableTextures\\TeamColor\\TeamColor09.blp", 0, true)
        BlzFrameSetEnable(helper.suggestionHighlightFrame, false)
        BlzFrameSetVisible(helper.suggestionHighlightFrame, false)

        if editor.USE_MONOSPACE_FONT then
            widthTestFrame = BlzCreateFrame("Consolas", BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME, 0), 0, 0)
        else
            widthTestFrame = BlzCreateFrameByType("TEXT", "", BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME, 0), "", 0)
        end
        BlzFrameSetVisible(widthTestFrame, false)

        highlights.currentLine = BlzCreateFrameByType("BACKDROP", "", codeEditorParent, "", 0)
        BlzFrameSetTexture(highlights.currentLine, editor.ASSET_SUBFOLDER .. "\\currentLine.blp", 0, true)
        BlzFrameSetVisible(highlights.currentLine, false)

        BlzFrameSetAbsPoint(codeEditorParent, FRAMEPOINT_TOPLEFT, editor.COLLAPSED_X, editor.Y_TOP)
        BlzFrameSetSize(codeEditorParent, editor.COLLAPSED_WIDTH, editor.MAX_LINES_ON_SCREEN*editor.LINE_SPACING + editor.CODE_TOP_INSET + editor.CODE_BOTTOM_INSET)

		CreateToggleExpandButton("ExpandEditorButton", editor.ASSET_SUBFOLDER .. "\\expandEditor.blp", codeEditorParent)

		local closeButton = BlzCreateFrame("CloseEditorButton", codeEditorParent, 0, 0)
		BlzFrameSetPoint(closeButton, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPRIGHT, -editor.CLOSE_BUTTON_INSET - editor.CLOSE_BUTTON_SIZE, -editor.CLOSE_BUTTON_INSET - editor.CLOSE_BUTTON_SIZE)
		BlzFrameSetPoint(closeButton, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPRIGHT, -editor.CLOSE_BUTTON_INSET, -editor.CLOSE_BUTTON_INSET)
        local icon = BlzFrameGetChild(closeButton, 0)
        local iconClicked = BlzFrameGetChild(closeButton, 1)
        local iconHighlight = BlzFrameGetChild(closeButton, 2)
        BlzFrameSetAllPoints(icon, closeButton)
		BlzFrameSetTexture(icon, editor.ASSET_SUBFOLDER .. "\\closeEditor.blp", 0, true)
		BlzFrameSetTexture(iconClicked, editor.ASSET_SUBFOLDER .. "\\closeEditor.blp", 0, true)
        BlzFrameClearAllPoints(iconHighlight)
        BlzFrameSetPoint(iconHighlight, FRAMEPOINT_BOTTOMLEFT, closeButton, FRAMEPOINT_BOTTOMLEFT, 0.00375, 0.00375)
        BlzFrameSetPoint(iconHighlight, FRAMEPOINT_TOPRIGHT, closeButton, FRAMEPOINT_TOPRIGHT, -0.00375, -0.00375)
        trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, closeButton, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(trig, function()
            BlzFrameSetEnable(buttons.hideEditor, false)
            BlzFrameSetEnable(buttons.hideEditor, true)
            BlzFrameSetVisible(codeEditorParent, false)
            editor.ON_DISABLE()
        end)

        ------------------------------------------------------------------------------------------------------------------------
        --Bottom Bar
        ------------------------------------------------------------------------------------------------------------------------

        if WSCodeConfig.bottomBar.LOAD_FROM_FILE_BUTTON and (not editor.ENABLE_SAVE_AND_LOAD or not FileIO) then
            WSCodeConfig.bottomBar.MAX_BUTTONS = WSCodeConfig.bottomBar.MAX_BUTTONS - 1
        end
        if WSCodeConfig.bottomBar.HALT_ALICE_BUTTON and not ALICE_Config then
            WSCodeConfig.bottomBar.MAX_BUTTONS = WSCodeConfig.bottomBar.MAX_BUTTONS - 1
        end
        if WSCodeConfig.bottomBar.QUICK_RESTART_BUTTON and not FileIO then
            WSCodeConfig.bottomBar.MAX_BUTTONS = WSCodeConfig.bottomBar.MAX_BUTTONS - 1
        end

        local INDEX_OF_BUTTON = {}

        for buttonName, index in next, WSCodeConfig.bottomBar do
            INDEX_OF_BUTTON[buttonName] = index
        end

        for __, buttonData in ipairs(buttons.customButtons) do
            INDEX_OF_BUTTON[buttonData.title] = buttonData.index
        end
        local function CreateBottomButton(index, texture, callback, tooltip, extendedTooltip, initiallyHidden, titleSuffix)

            local button = BlzCreateFrame("BottomBarButton", codeEditorParent, 0, 0)
            BlzFrameSetPoint(button, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_BOTTOM, (index - 1 - WSCodeConfig.bottomBar.MAX_BUTTONS/2)*editor.BOTTOM_BUTTON_SIZE, editor.BOTTOM_BUTTON_VERTICAL_SHIFT)
            BlzFrameSetPoint(button, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_BOTTOM, (index - WSCodeConfig.bottomBar.MAX_BUTTONS/2)*editor.BOTTOM_BUTTON_SIZE, editor.BOTTOM_BUTTON_VERTICAL_SHIFT + editor.BOTTOM_BUTTON_SIZE)

            local icon = BlzFrameGetChild(button,0)
            local iconClicked = BlzFrameGetChild(button,1)
            BlzFrameClearAllPoints(iconClicked)
            BlzFrameSetPoint(iconClicked, FRAMEPOINT_BOTTOMLEFT, icon, FRAMEPOINT_BOTTOMLEFT, 0.0005, 0.0005)
            BlzFrameSetPoint(iconClicked, FRAMEPOINT_TOPRIGHT, icon, FRAMEPOINT_TOPRIGHT, -0.0005, -0.0005)

            BlzFrameSetTexture(icon, texture, 0, true)
            BlzFrameSetTexture(iconClicked, texture, 0, true)

            trig = CreateTrigger()
            BlzTriggerRegisterFrameEvent(trig, button, FRAMEEVENT_CONTROL_CLICK)
            TriggerAddAction(trig, function()
                BlzFrameSetEnable(button, false)
                BlzFrameSetEnable(button, true)
                if buttons.triggers[tooltip] then
                    for i = 1, #buttons.triggers[tooltip] do
                        buttons.triggers[tooltip][i]()
                    end
                end
                callback()
            end)

            local tooltipFrame = BlzCreateFrame("CustomTooltip", codeEditorParent, 0, 0)
            if GetHandleId(tooltipFrame) == 0 then
                error("Missing import: CustomTooltip.fdf.")
            end

            BlzFrameSetPoint(tooltipFrame, FRAMEPOINT_BOTTOMRIGHT, codeEditorParent, FRAMEPOINT_BOTTOMRIGHT, -editor.BOTTOM_BUTTON_VERTICAL_SHIFT - editor.BOTTOM_BUTTON_SIZE, editor.BOTTOM_BUTTON_VERTICAL_SHIFT + editor.BOTTOM_BUTTON_SIZE)
            BlzFrameSetTooltip(button, tooltipFrame)

            local title = BlzFrameGetChild(tooltipFrame, 0)
            local text = BlzFrameGetChild(tooltipFrame, 1)
            BlzFrameSetText(title, "|cffffcc00" .. tooltip .. (titleSuffix or "") .. "|r")
            if extendedTooltip then
                BlzFrameSetText(text, extendedTooltip)
                BlzFrameSetSize(text, 0.22 - 0.012, 0.0)
                BlzFrameSetSize(tooltipFrame, 0.22, BlzFrameGetHeight(text) + 0.035)
            else
                BlzFrameSetSize(title, 0, 0)
                BlzFrameSetVisible(text, false)
                BlzFrameSetVisible(BlzFrameGetChild(tooltipFrame, 2), false)
                BlzFrameSetSize(text, 0.22 - 0.012, 0.0)
                BlzFrameSetSize(tooltipFrame, BlzFrameGetWidth(title) + 0.012, 0.024)
            end

            if initiallyHidden then
                BlzFrameSetVisible(button, false)
            end

            buttons.defaultButtonPosition[tooltip] = index

            return button
        end

        local function Execute()
            BlzFrameSetEnable(buttons["Execute"], false)
            BlzFrameSetEnable(buttons["Execute"], true)

            BlzFrameSetVisible(highlights.currentLine, false)
            BlzFrameSetVisible(highlights.error, false)
            BlzFrameSetVisible(variableViewer.parent, flags.debugMode)

            for i = 1, variableViewer.numVisibleVarsTotal do
                BlzFrameSetVisible(variableViewer.frames[i], false)
                BlzFrameSetVisible(variableViewer.valueFrames[i], false)
            end
            variableViewer.numVisibleVarsTotal = 0
            variableViewer.numVisibleVarsScreen = 0
            if variableViewer.isExpanded then
                BlzFrameSetSize(variableViewer.parent, variableViewer.WIDTH, editor.LINE_SPACING + 2*variableViewer.LINE_VERTICAL_INSET)
            end

            for i = 1, editor.MAX_LINES_ON_SCREEN do
                BlzFrameSetFocus(codeLineFrames[i], false)
                BlzFrameSetEnable(codeLineFrames[i], false)
                BlzFrameSetEnable(codeLineFrames[i], true)
            end

            local lines = {}
            local currentLines = codeLines[currentTab][step[currentTab]]
            for i = 1, highestNonEmptyLine[currentTab][step[currentTab]] do
                lines[i] = currentLines[i]
            end

            CompileFunction(lines, {
                debugMode = flags.debugMode,
                runInit = flags.runInit,
                smartPersist = flags.smartPersist,
                cleanHandles = flags.cleanHandles,
                tab = currentTab
            })
        end

        local function ShowFlagsMenu()
            BlzFrameSetEnable(buttons["Flags"], false)
            BlzFrameSetEnable(buttons["Flags"], true)
            BlzFrameSetVisible(flags.parent, not BlzFrameIsVisible(flags.parent))
            BlzFrameSetVisible(clearMenu.parent, false)
            for i = 1, #buttons.customArrayButtons do
                BlzFrameSetVisible(buttons.customArrayButtons[i].parent, false)
            end
        end

        local function ShowClearMenu()
            BlzFrameSetEnable(buttons["Demolish"], false)
            BlzFrameSetEnable(buttons["Demolish"], true)
            BlzFrameSetVisible(clearMenu.parent, not BlzFrameIsVisible(clearMenu.parent))
            BlzFrameSetVisible(flags.parent, false)
            for i = 1, #buttons.customArrayButtons do
                BlzFrameSetVisible(buttons.customArrayButtons[i].parent, false)
            end
        end

        local function ToggleHaltAlice()
            BlzFrameSetEnable(buttons["Pause/Resume"], false)
            BlzFrameSetEnable(buttons["Pause/Resume"], true)
            if not WSDebug.ALICEhalted then
                (ALICE_Halt or ALICE.Halt)()
            else
                (ALICE_Resume or ALICE.Resume)()
            end
        end

        local function LoadFileButton()
            BlzFrameSetEnable(buttons["Load Backup File"], false)
            BlzFrameSetEnable(buttons["Load Backup File"], true)

            if not BlzFrameIsVisible(nameDialog.parent) then
                ClearTextMessages()
                nameDialog.state = "loadfromfile"
                BlzFrameSetVisible(nameDialog.parent, true)
                BlzFrameSetFocus(nameDialog.textField, true)
                BlzFrameSetText(nameDialog.title, "|cffffcc00Enter File Name|r")
            end
        end

        local function PullButton()
            BlzFrameSetEnable(buttons["Pull Script"], false)
            BlzFrameSetEnable(buttons["Pull Script"], true)
            if not BlzFrameIsVisible(nameDialog.parent) then
                ClearTextMessages()
                nameDialog.state = "pullscript"
                BlzFrameSetVisible(nameDialog.parent, true)
                BlzFrameSetFocus(nameDialog.textField, true)
                BlzFrameSetText(nameDialog.title, "|cffffcc00Enter Script Name|r")
                BlzFrameSetText(nameDialog.textField, "")
            end
        end

        local function ViewGlobalButton()
            BlzFrameSetEnable(buttons["View Global"], false)
            BlzFrameSetEnable(buttons["View Global"], true)
            if not BlzFrameIsVisible(nameDialog.parent) then
                ClearTextMessages()
                nameDialog.state = "viewglobal"
                BlzFrameSetVisible(nameDialog.parent, true)
                BlzFrameSetFocus(nameDialog.textField, true)
                BlzFrameSetText(nameDialog.title, "|cffffcc00Enter Global Name|r")
                BlzFrameSetText(nameDialog.textField, "")
            end
        end

        local function PrintTraceback()
            BlzFrameSetEnable(buttons["Traceback"], false)
            BlzFrameSetEnable(buttons["Traceback"], true)
            if tabIsHalted[currentTab] then
                WSDebug.PrintForUser(">>Traceback:\n" .. WSDebug.Traceback[currentTab])
            end
        end

        local function TracebackHook()
            BlzFrameSetEnable(buttons["Hook"], false)
            BlzFrameSetEnable(buttons["Hook"], true)
            ClearTextMessages()
            nameDialog.state = "hook"
            BlzFrameSetVisible(nameDialog.parent, true)
            BlzFrameSetFocus(nameDialog.textField, true)
            BlzFrameSetText(nameDialog.title, "|cffffcc00Enter Function or Trigger|r")
            BlzFrameSetText(nameDialog.textField, "")
        end

        local function QuickRestartButton()
            local function ExportModifiedScript()
                flags.quickRestart = true
                SaveSettings()

                local mapScript = {}

                local fileTable
                local thisFile
                for i = 1, #fileNames do
                    if tabs.numbers[fileNames[i]] then
                        thisFile = codeLines[fileNames[i]][step[fileNames[i]]]
                    else
                        thisFile = files[i]
                    end

                    fileTable = {"\n", thisFile[1]}
                    for k = 2, #thisFile do
                        fileTable[#fileTable + 1] = "\n"
                        fileTable[#fileTable + 1] = thisFile[k]
                    end
                    mapScript[#mapScript + 1] = table.concat(fileTable)
                end

                SaveTabs()
                FileIO.Save(editor.EXPORT_SUBFOLDER .. "\\WSCodeMapScript.txt", table.concat(mapScript))
            end

            BlzFrameSetEnable(buttons["Quick Restart"], false)
            BlzFrameSetEnable(buttons["Quick Restart"], true)

            local dialog = DialogCreate()
            DialogSetMessage(dialog, "Restart map (Y/N)")
            local yes = DialogAddButton(dialog, "Yes", 89)
            local no = DialogAddButton(dialog, "No", 78)
            DialogAddButton(dialog, "Cancel", 67)
            local trigYes = CreateTrigger()
            local trigNo = CreateTrigger()
            TriggerRegisterDialogButtonEvent(trigYes, yes)
            TriggerRegisterDialogButtonEvent(trigNo, no)
            TriggerAddAction(trigYes, function()
                ExportModifiedScript()
                RestartGame(false)
            end)
            TriggerAddAction(trigNo, function()
                ExportModifiedScript()
                WSDebug.PrintForUser("Modified script has been exported. It will be loaded the next time you start the map.")
            end)
            DialogDisplay(GetTriggerPlayer(), dialog, true)
        end

        local function SmartEvaluate()
            BlzFrameSetEnable(buttons["Smart Evaluate"], false)
            BlzFrameSetEnable(buttons["Smart Evaluate"], true)
            ClearTextMessages()
            nameDialog.state = "smarteval"
            BlzFrameSetVisible(nameDialog.parent, true)
            BlzFrameSetFocus(nameDialog.textField, true)
            BlzFrameSetText(nameDialog.title, "|cffffcc00Enter Expression|r")

            local lines
            if selection.hasSelection then
                lines = ConvertSelectionToLines()
            end

            BlzFrameSetText(nameDialog.textField, lines and #lines == 1 and lines[1] or "")
        end

        if WSCodeConfig.bottomBar["Execute"] then
            buttons["Execute"] = CreateBottomButton(INDEX_OF_BUTTON["Execute"], "ReplaceableTextures\\CommandButtons\\BTNCleavingAttack.blp", Execute, "Execute", "Executes the code in the current tab after applying transformations based on the flags set.")
        end
        if WSCodeConfig.bottomBar["Flags"] then
            buttons["Flags"] = CreateBottomButton(INDEX_OF_BUTTON["Flags"], "ReplaceableTextures\\CommandButtons\\BTNRallyPoint.blp", ShowFlagsMenu, "Flags", "Set various flags that influence code execution and variable display.")
        end
        if WSCodeConfig.bottomBar["Demolish"] then
            buttons["Demolish"] = CreateBottomButton(INDEX_OF_BUTTON["Demolish"], "ReplaceableTextures\\CommandButtons\\BTNDemolish.blp",  ShowClearMenu, "Demolish", "Clear all breakpoints, delete all code, reset all line highlights, close all tabs, or destroy all handles created in this tab.")
        end
        if WSCodeConfig.bottomBar["Undo"] then
            buttons["Undo"] = CreateBottomButton(INDEX_OF_BUTTON["Undo"], "ReplaceableTextures\\CommandButtons\\BTNReplay-Loop.blp", WSCode.Undo, "Undo", "Undo the last edit.", false, "|r |cffaaaaaa(Ctrl + Z)")
            BlzFrameSetEnable(buttons["Undo"], false)
            BlzFrameSetTexture(BlzFrameGetChild(buttons["Undo"], 2), "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNReplay-Loop.blp", 0, true)
        end
        if WSCodeConfig.bottomBar["Redo"] then
            buttons["Redo"] = CreateBottomButton(INDEX_OF_BUTTON["Redo"], "ReplaceableTextures\\CommandButtons\\BTNPatrol.blp", WSCode.Redo, "Redo", "Redo the last edit.", false, "|r |cffaaaaaa(Ctrl + Y)")
            BlzFrameSetEnable(buttons["Redo"], false)
            BlzFrameSetTexture(BlzFrameGetChild(buttons["Redo"], 2), "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNPatrol.blp", 0, true)
        end
        if WSCodeConfig.bottomBar["Traceback"] then
            buttons["Traceback"] = CreateBottomButton(INDEX_OF_BUTTON["Traceback"], "ReplaceableTextures\\CommandButtons\\BTNHealingWave.blp", PrintTraceback, "Show Traceback", "If a thread in the current tab is halted, prints the traceback for that thread.")
            BlzFrameSetTexture(BlzFrameGetChild(buttons["Traceback"], 2), "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNHealingWave.blp", 0, true)
            BlzFrameSetEnable(buttons["Traceback"], false)
        end
        if WSCodeConfig.bottomBar["View Global"] then
            buttons["View Global"] = CreateBottomButton(INDEX_OF_BUTTON["View Global"], "ReplaceableTextures\\CommandButtons\\BTNCrystalBall.blp", ViewGlobalButton, "View Global", "Adds a global variable to the variable viewer.")
        end
        if WSCodeConfig.bottomBar["Hook"] then
            buttons["Hook"] = CreateBottomButton(INDEX_OF_BUTTON["Hook"], "ReplaceableTextures\\CommandButtons\\BTNThorns.blp", TracebackHook, "Hook",  "Hooks a global function, printing the traceback and arguments each time it is called. A hook added this way can be removed by entering that function a second time.")
        end
        if WSCodeConfig.bottomBar["Smart Evaluate"] then
            buttons["Smart Evaluate"] = CreateBottomButton(INDEX_OF_BUTTON["Smart Evaluate"], "ReplaceableTextures\\CommandButtons\\BTNBansheeMaster.blp", SmartEvaluate, "Smart Evaluate", "Executes the entered code if possible, accessing any local variables in the current tab that are referenced in the expression. Globals, upvalues, and table fields can be assigned new values, but local variables cannot. Prints the entered object, the assigned value, or the return value of the expression. Executes any trigger entered this way.\n\nIf a single line of code is selected, the selection will be copied to the dialog.", nil, "|r |cffaaaaaa(Ctrl + E)")
        end
        if WSCodeConfig.bottomBar["Search"] then
            buttons["Search"] = CreateBottomButton(INDEX_OF_BUTTON["Search"], "ReplaceableTextures\\CommandButtons\\BTNScout.blp", ShowSearchBar, "Search", "Opens the search bar. Go to a specific line by typing :X.")
        end
        if WSCodeConfig.bottomBar["Load Backup File"] then
            buttons["Load Backup File"] = CreateBottomButton(INDEX_OF_BUTTON["Load Backup File"], "ReplaceableTextures\\CommandButtons\\BTNLoad.blp", LoadFileButton, "Load Backup File", "Loads the code automatically saved to a file on an earlier session.")
        end
        if WSCodeConfig.bottomBar["Pull Script"] then
            buttons["Pull Script"] = CreateBottomButton(INDEX_OF_BUTTON["Pull Script"], "ReplaceableTextures\\CommandButtons\\BTNNagaUnBurrow.blp", PullButton, "Pull Script", "Loads a script file into a new tab. The script file must have been parsed by WSCode.Parse and is referenced by its name set in the Debug.beginFile call.")
        end
        if WSCodeConfig.bottomBar["Quick Restart"] then
            if compiler.ENABLE_QUICK_RESTART then
                buttons["Quick Restart"] = CreateBottomButton(INDEX_OF_BUTTON["Quick Restart"], "ReplaceableTextures\\CommandButtons\\BTNReincarnation.blp", QuickRestartButton, "Quick Restart", "Stores the map script in a text file, respecting all changes you have made within the editor. Then you may restart the map to load the map script from that file. All scripts added to the editor are automatically transpiled into debug mode.\n\nIf you don't restart the map, the modified script will still be loaded on the next map launch, including if the map is launched as a replay. This allows you to retroactively add print statements to better investigate a bug while viewing that replay.")
            else
                buttons["Quick Restart"] = CreateBottomButton(INDEX_OF_BUTTON["Quick Restart"], "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNReincarnation.blp", QuickRestartButton, "Quick Restart", "Stores the map script in a text file, respecting all changes you have made within the editor. Then you may restart the map to load the map script from that file. All scripts added to the editor are automatically transpiled into debug mode.\n\nIf you don't restart the map, the modified script will still be loaded on the next map launch, including if the map is launched as a replay. This allows you to retroactively add print statements to better investigate a bug while viewing that replay.\n\n|cffff0000Quick Restart needs to be enabled in the config to use this feature.|r")
                BlzFrameSetTexture(BlzFrameGetChild(buttons["Quick Restart"], 2), "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNReincarnation.blp", 0, true)
                BlzFrameSetEnable(buttons["Quick Restart"], false)
            end
        end
        if WSCodeConfig.bottomBar["Benchmark"] then
            buttons["Benchmark"] = CreateBottomButton(INDEX_OF_BUTTON["Benchmark"], "ReplaceableTextures\\CommandButtons\\BTNWindWalkOn.blp", WSCode.Benchmark, "Benchmark", "Evaluates the execution time of the code in the current tab with no transformations. Do not create any leaking handles within the code you are benchmarking. Stop the benchmark by pressing this button again.")
        end
        if WSCodeConfig.bottomBar["Pause/Resume"] then
            buttons["Pause/Resume"] = CreateBottomButton(INDEX_OF_BUTTON["Pause/Resume"], "ReplaceableTextures\\CommandButtons\\BTNReplay-Pause.blp", ToggleHaltAlice, "Pause/Resume", "Pause or resume the ALICE cycle.")
            BlzFrameSetTexture(BlzFrameGetChild(buttons["Pause/Resume"], 2), "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNReplay-Pause.blp", 0, true)
        end

        local function CreateBottomArrayButton(buttonData)
            local arrayParent = BlzCreateFrame("CodeEditor", codeEditorParent, 0, 0)
            BlzFrameSetLevel(arrayParent, 3)
            BlzFrameSetVisible(arrayParent, false)

            local backdrop = BlzFrameGetChild(arrayParent, 0)
            BlzFrameSetAllPoints(backdrop, arrayParent)
            SetFrameAlpha(backdrop, editor.BLACK_BACKDROP_ALPHA)

            local border = BlzFrameGetChild(arrayParent, 1)
            BlzFrameSetAllPoints(border, arrayParent)

            local buttonTable = {parent = arrayParent, name = buttonData.title}
            buttons.customArrayButtons[#buttons.customArrayButtons + 1] = buttonTable

            buttons.subArrayButtons[arrayParent] = {}

            if buttonData.alignment == "center" then
                buttonTable.minX = (INDEX_OF_BUTTON[buttonData.title] - WSCodeConfig.bottomBar.MAX_BUTTONS/2 - 0.5)*editor.BOTTOM_BUTTON_SIZE - flagsMenu.WIDTH/2
                buttonTable.maxX = (INDEX_OF_BUTTON[buttonData.title] - WSCodeConfig.bottomBar.MAX_BUTTONS/2 - 0.5)*editor.BOTTOM_BUTTON_SIZE + flagsMenu.WIDTH/2
            elseif buttonData.alignment == "left" then
                buttonTable.minX = (INDEX_OF_BUTTON[buttonData.title] - WSCodeConfig.bottomBar.MAX_BUTTONS/2 - 1)*editor.BOTTOM_BUTTON_SIZE
                buttonTable.maxX = (INDEX_OF_BUTTON[buttonData.title] - WSCodeConfig.bottomBar.MAX_BUTTONS/2 - 1)*editor.BOTTOM_BUTTON_SIZE + flagsMenu.WIDTH
            else
                buttonTable.minX = (INDEX_OF_BUTTON[buttonData.title] - WSCodeConfig.bottomBar.MAX_BUTTONS/2)*editor.BOTTOM_BUTTON_SIZE - flagsMenu.WIDTH
                buttonTable.maxX = (INDEX_OF_BUTTON[buttonData.title] - WSCodeConfig.bottomBar.MAX_BUTTONS/2)*editor.BOTTOM_BUTTON_SIZE
            end

            for i = 1, #buttonData.subTitles do
                local initiallyHighlighted = buttonData.initiallyHighlighted and buttonData.initiallyHighlighted[i]
                buttonTable[i] = {
                    parent = CreateArrayButton(arrayParent, i, buttonData.subTitles[i], buttonData.subTooltips and buttonData.subTooltips[i], initiallyHighlighted, buttonData.callbacks[i], buttonTable, buttonData.width, buttonData.subTitleSuffixes and buttonData.subTitleSuffixes[i], INDEX_OF_BUTTON[buttonData.title]),
                    text = buttonData.subTitles[i]
                }
            end

            BlzFrameSetSize(arrayParent, (buttonData.width or flagsMenu.WIDTH), 2*flagsMenu.TEXT_INSET + #buttonData.subTitles*editor.LINE_SPACING)

            local function ShowButtonArray()
                BlzFrameSetEnable(buttons[buttonData.title], false)
                BlzFrameSetEnable(buttons[buttonData.title], true)
                BlzFrameSetVisible(flags.parent, false)
                BlzFrameSetVisible(clearMenu.parent, false)
                for i = 1, #buttons.customArrayButtons do
                    if buttons.customArrayButtons[i].parent ~= arrayParent then
                        BlzFrameSetVisible(buttons.customArrayButtons[i].parent, false)
                    end
                end
                if BlzFrameIsVisible(arrayParent) then
                    for i = 1, #buttons.subArrayButtons[arrayParent] do
                        BlzFrameSetVisible(buttons.subArrayButtons[arrayParent][i].parent, false)
                    end
                    BlzFrameSetVisible(arrayParent, false)
                else
                    BlzFrameSetVisible(arrayParent, true)
                end
            end

            buttons[buttonData.title] = CreateBottomButton(INDEX_OF_BUTTON[buttonData.title], buttonData.icon, ShowButtonArray, buttonData.title, buttonData.tooltip, buttonData.initiallyHidden, buttonData.titleSuffix)

            if buttonData.alignment == "center" then
                BlzFrameSetPoint(arrayParent, FRAMEPOINT_BOTTOM, buttons[buttonData.title], FRAMEPOINT_TOP, 0, 0)
            elseif buttonData.alignment == "left" then
                BlzFrameSetPoint(arrayParent, FRAMEPOINT_BOTTOMLEFT, buttons[buttonData.title], FRAMEPOINT_TOPLEFT, 0, 0)
            else
                BlzFrameSetPoint(arrayParent, FRAMEPOINT_BOTTOMRIGHT, buttons[buttonData.title], FRAMEPOINT_TOPRIGHT, 0, 0)
            end
            buttonTable.maxY = editor.Y_TOP - editor.CODE_TOP_INSET - editor.MAX_LINES_ON_SCREEN*editor.LINE_SPACING - editor.CODE_BOTTOM_INSET + BlzFrameGetHeight(arrayParent)
        end

        if WSCodeConfig.bottomBar["Plugins"] then
            local initiallyHighlighted = {true}

            plugins.visibleButtons[1] = {}
            for i = 1, #WSCodeConfig.bottomBar do
                if WSCodeConfig.bottomBar[i] then
                    plugins.visibleButtons[1][#plugins.visibleButtons[1] + 1] = WSCodeConfig.bottomBar[i]
                end
            end

            for i = 1, #plugins.names do
                plugins.callbacks[i] = function()
                    for j = 1, #plugins.visibleButtons[plugins.activeIndex] do
                        BlzFrameSetVisible(buttons[plugins.visibleButtons[plugins.activeIndex][j]], false)
                    end
                    if plugins.onDisable[plugins.activeIndex] then
                        plugins.onDisable[plugins.activeIndex](plugins.activeIndex, i)
                    end

                    WSCode.HighlightArrayButton("Plugins", plugins.activeIndex, false)

                    for j = 1, #plugins.visibleButtons[i] do
                        BlzFrameSetVisible(buttons[plugins.visibleButtons[i][j]], true)
                    end
                    if plugins.onEnable[i] then
                        plugins.onEnable[i](plugins.activeIndex, i)
                    end
                    plugins.activeIndex = i

                    WSCode.HighlightArrayButton("Plugins", i, true)

                    BlzFrameSetVisible(buttons["Plugins"], true)
                end
            end

            for i = 2, #plugins.names do
                initiallyHighlighted[i] = false
            end

            CreateBottomArrayButton({
                icon = "ReplaceableTextures\\CommandButtons\\BTNAdvStruct.blp",
                title = "Plugins",
                titleSuffix = "|r |r |cffaaaaaa(Alt + F1)",
                tooltip = "Navigate between different installed Warcraft Studio Code plugins. Plugins can be created with WSCode.RegisterPlugin.",
                subTitles = plugins.names,
                subTooltips = plugins.tooltips,
                subTitleSuffixes = plugins.titleSuffixes,
                alignment = "right",
                callbacks = plugins.callbacks,
                index = INDEX_OF_BUTTON["Plugins"],
                initiallyHighlighted = initiallyHighlighted,
                initiallyHidden = false,
                width = editor.PLUGIN_LIST_WIDTH
            })
            BlzFrameSetTexture(BlzFrameGetChild(buttons["Plugins"], 2), "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNAdvStruct.blp", 0, true)
            if #plugins.names == 1 then
                BlzFrameSetEnable(buttons["Plugins"], false)
            end
        end

        for __, buttonData in ipairs(buttons.customButtons) do
            if buttonData.isArray then
                CreateBottomArrayButton(buttonData)
            else
                buttons[buttonData.title] = CreateBottomButton(INDEX_OF_BUTTON[buttonData.title], buttonData.icon, buttonData.callback, buttonData.title, buttonData.tooltip, buttonData.initiallyHidden, buttonData.titleSuffix)
            end
        end

        if ALICE_Config then
            if ALICE_Halt then
                local oldHalt = ALICE_Halt
                ALICE_Halt = function(pauseGame)
                    oldHalt(pauseGame)
                    WSDebug.ALICEhalted = true
                    BlzFrameSetTexture(BlzFrameGetChild(buttons["Pause/Resume"], 0), "ReplaceableTextures\\CommandButtons\\BTNReplay-SpeedUp.blp", 0, true)
                    BlzFrameSetTexture(BlzFrameGetChild(buttons["Pause/Resume"], 1), "ReplaceableTextures\\CommandButtons\\BTNReplay-SpeedUp.blp", 0, true)
                    BlzFrameSetTexture(BlzFrameGetChild(buttons["Pause/Resume"], 2), "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNReplay-SpeedUp.blp", 0, true)
                end

                local oldResume = ALICE_Resume
                ALICE_Resume = function()
                    oldResume()
                    WSDebug.ALICEhalted = false
                    BlzFrameSetTexture(BlzFrameGetChild(buttons["Pause/Resume"], 0), "ReplaceableTextures\\CommandButtons\\BTNReplay-Pause.blp", 0, true)
                    BlzFrameSetTexture(BlzFrameGetChild(buttons["Pause/Resume"], 1), "ReplaceableTextures\\CommandButtons\\BTNReplay-Pause.blp", 0, true)
                    BlzFrameSetTexture(BlzFrameGetChild(buttons["Pause/Resume"], 2), "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNReplay-Pause.blp", 0, true)
                end
            else
                local oldHalt = ALICE.Halt
                ALICE.Halt = function(pauseGame)
                    oldHalt(pauseGame)
                    WSDebug.ALICEhalted = true
                    BlzFrameSetTexture(BlzFrameGetChild(buttons["Pause/Resume"], 0), "ReplaceableTextures\\CommandButtons\\BTNReplay-SpeedUp.blp", 0, true)
                    BlzFrameSetTexture(BlzFrameGetChild(buttons["Pause/Resume"], 1), "ReplaceableTextures\\CommandButtons\\BTNReplay-SpeedUp.blp", 0, true)
                    BlzFrameSetTexture(BlzFrameGetChild(buttons["Pause/Resume"], 2), "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNReplay-SpeedUp.blp", 0, true)
                end

                local oldResume = ALICE.Resume
                ALICE.Resume = function()
                    oldResume()
                    WSDebug.ALICEhalted = false
                    BlzFrameSetTexture(BlzFrameGetChild(buttons["Pause/Resume"], 0), "ReplaceableTextures\\CommandButtons\\BTNReplay-Pause.blp", 0, true)
                    BlzFrameSetTexture(BlzFrameGetChild(buttons["Pause/Resume"], 1), "ReplaceableTextures\\CommandButtons\\BTNReplay-Pause.blp", 0, true)
                    BlzFrameSetTexture(BlzFrameGetChild(buttons["Pause/Resume"], 2), "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNReplay-Pause.blp", 0, true)
                end
            end
        end

        ------------------------------------------------------------------------------------------------------------------------
        --Flags Menu
        ------------------------------------------------------------------------------------------------------------------------

        flags.parent = BlzCreateFrame("CodeEditor", codeEditorParent, 0, 0)
        BlzFrameSetLevel(flags.parent, 3)
        BlzFrameSetVisible(flags.parent, false)

        backdrop = BlzFrameGetChild(flags.parent, 0)
        BlzFrameSetAllPoints(backdrop, flags.parent)
        SetFrameAlpha(backdrop, editor.BLACK_BACKDROP_ALPHA)

        border = BlzFrameGetChild(flags.parent, 1)
        BlzFrameSetAllPoints(border, flags.parent)

        BlzFrameSetPoint(flags.parent, FRAMEPOINT_BOTTOM, buttons["Flags"], FRAMEPOINT_TOP, 0, 0)

        local function CreateFlagsButton(position, name, tooltip, initiallyEnabled, callback)
            local button = BlzCreateFrame("VariableViewerButton", flags.parent, 0, 0)
            local text = BlzFrameGetChild(button, 0)
            BlzFrameSetEnable(text, false)
            BlzFrameSetPoint(button, FRAMEPOINT_BOTTOMLEFT, flags.parent, FRAMEPOINT_TOPLEFT, flagsMenu.TEXT_INSET, -flagsMenu.TEXT_INSET - position*editor.LINE_SPACING)
            BlzFrameSetPoint(button, FRAMEPOINT_TOPRIGHT, flags.parent, FRAMEPOINT_TOPLEFT, flagsMenu.WIDTH - flagsMenu.TEXT_INSET, -flagsMenu.TEXT_INSET - (position - 1)*editor.LINE_SPACING)
            BlzFrameSetTextAlignment(text, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
            BlzFrameSetAllPoints(text, button)
            indexFromFrame[button] = position

            BlzFrameSetText(text, initiallyEnabled and "|cffffcc00" .. name .. "|r" or "|cff999999" .. name .. "|r")
            local isEnabled = initiallyEnabled

            trig = CreateTrigger()
            BlzTriggerRegisterFrameEvent(trig, button, FRAMEEVENT_CONTROL_CLICK)
            TriggerAddAction(trig, function()
                callback()
                isEnabled = not isEnabled
                BlzFrameSetText(text, isEnabled and "|cffffcc00" .. name .. "|r" or "|cff999999" .. name .. "|r")
            end)

            local tooltipFrame = BlzCreateFrame("CustomTooltip", codeEditorParent, 0, 0)

            BlzFrameSetPoint(tooltipFrame, FRAMEPOINT_BOTTOMLEFT, flags.parent, FRAMEPOINT_TOPLEFT, 0, 0)
            BlzFrameSetTooltip(button, tooltipFrame)

            local tooltipTitle = BlzFrameGetChild(tooltipFrame, 0)
            local tooltipText = BlzFrameGetChild(tooltipFrame, 1)
            BlzFrameSetText(tooltipTitle, "|cffffcc00" .. name .. "|r")
            BlzFrameSetText(tooltipText, tooltip)
            BlzFrameSetSize(tooltipText, 0.22 - 0.012, 0.0)
            BlzFrameSetSize(tooltipFrame, 0.22, BlzFrameGetHeight(tooltipText) + 0.035)
        end

        CreateFlagsButton(1, "Debug Mode", "Toggles whether the code in the current tab will be transpiled into its debug form when you press Execute.\n\nDebug mode is required to view variables and use breakpoints.", flags.debugMode, function()
            flags.debugMode = not flags.debugMode
            SaveSettings()
        end)
        CreateFlagsButton(2, "Run OnInit", "Toggles whether function wrapped in OnInit or WSCode.Init calls will be executed when you press Execute.", flags.runInit, function()
            flags.runInit = not flags.runInit
            SaveSettings()
        end)
        CreateFlagsButton(3, "Auto-Clean Handles", "If enabled, all handles created by previous executions of the code in the current tab will be destroyed when you press Execute.\n\nHandle creators and their associated destructors are defined in the config.", flags.cleanHandles, function()
            flags.cleanHandles = not flags.cleanHandles
            SaveSettings()
        end)

        CreateFlagsButton(4, "Persist Upvalues", "If enabled, local variables and table fields defined by the previous execution of the code in the current tab may be copied over to the new environment when you press Execute.\n\nA variable or field will be copied when it's declared as uninitialized or nil in the new environment.", flags.smartPersist, function()
            flags.smartPersist = not flags.smartPersist
            SaveSettings()
        end)

        CreateFlagsButton(5, "Hide Globals", "Hides all global variables from the variable viewer.", flags.hideGlobals, function()
            flags.hideGlobals = not flags.hideGlobals
            UpdateVariableViewer(lineNumbers.lastViewed[currentTab] or lastLineNumber[currentTab])
            SaveSettings()
        end)

        CreateFlagsButton(6, "Hide Constants", "Hides all variables with a SCREAMING_SNAKE_CASE format from the variable viewer.", flags.hideConstants, function()
            flags.hideConstants = not flags.hideConstants
            UpdateVariableViewer(lineNumbers.lastViewed[currentTab] or lastLineNumber[currentTab])
            SaveSettings()
        end)

        CreateFlagsButton(7, "Hide Functions", "Hides all functions from the variable viewer.", flags.hideFunctions, function()
            flags.hideFunctions = not flags.hideFunctions
            UpdateVariableViewer(lineNumbers.lastViewed[currentTab] or lastLineNumber[currentTab])
            SaveSettings()
        end)

        CreateFlagsButton(8, "Unfreeze Viewer", "When enabled, continuously updates the variable viewer instead of only when navigating the viewer, and at each spyglass or breakpoint.", flags.unfreezeViewer, function()
            flags.unfreezeViewer = not flags.unfreezeViewer
            SaveSettings()
        end)

        BlzFrameSetSize(flags.parent, flagsMenu.WIDTH, 2*flagsMenu.TEXT_INSET + 8*editor.LINE_SPACING)

        flags.minX = (2 - WSCodeConfig.bottomBar.MAX_BUTTONS/2 - 0.5)*editor.BOTTOM_BUTTON_SIZE - flagsMenu.WIDTH/2
        flags.maxX = (2 - WSCodeConfig.bottomBar.MAX_BUTTONS/2 - 0.5)*editor.BOTTOM_BUTTON_SIZE + flagsMenu.WIDTH/2
        flags.maxY = editor.Y_TOP - editor.CODE_TOP_INSET - editor.MAX_LINES_ON_SCREEN*editor.LINE_SPACING - editor.CODE_BOTTOM_INSET + BlzFrameGetHeight(flags.parent)

        ------------------------------------------------------------------------------------------------------------------------
        --Clear Menu
        ------------------------------------------------------------------------------------------------------------------------

        clearMenu.parent = BlzCreateFrame("CodeEditor", codeEditorParent, 0, 0)
        BlzFrameSetLevel(clearMenu.parent, 3)
        BlzFrameSetVisible(clearMenu.parent, false)

        backdrop = BlzFrameGetChild(clearMenu.parent, 0)
        BlzFrameSetAllPoints(backdrop, clearMenu.parent)
        SetFrameAlpha(backdrop, editor.BLACK_BACKDROP_ALPHA)

        border = BlzFrameGetChild(clearMenu.parent, 1)
        BlzFrameSetAllPoints(border, clearMenu.parent)

        BlzFrameSetPoint(clearMenu.parent, FRAMEPOINT_BOTTOM, buttons["Demolish"], FRAMEPOINT_TOP, 0, 0)

        CreateArrayButton(clearMenu.parent, 1, "Delete Code", nil, nil, WSCode.DeleteCode)
        CreateArrayButton(clearMenu.parent, 2, "Clear Breakpoints", nil, nil, WSCode.ClearBreakpoints)
        CreateArrayButton(clearMenu.parent, 3, "Reset Lines", nil, nil, WSCode.ResetLineHighlights)
        CreateArrayButton(clearMenu.parent, 4, "Close All Tabs", nil, nil, WSCode.CloseAllTabs)
        CreateArrayButton(clearMenu.parent, 5, "Destroy Handles", nil, nil, WSCode.DestroyHandles)

        BlzFrameSetSize(clearMenu.parent, flagsMenu.WIDTH, 2*flagsMenu.TEXT_INSET + 5*editor.LINE_SPACING)

        clearMenu.minX = (4 - WSCodeConfig.bottomBar.MAX_BUTTONS/2 - 0.5)*editor.BOTTOM_BUTTON_SIZE - flagsMenu.WIDTH/2
        clearMenu.maxX = (4 - WSCodeConfig.bottomBar.MAX_BUTTONS/2 - 0.5)*editor.BOTTOM_BUTTON_SIZE + flagsMenu.WIDTH/2
        clearMenu.maxY = editor.Y_TOP - editor.CODE_TOP_INSET - editor.MAX_LINES_ON_SCREEN*editor.LINE_SPACING - editor.CODE_BOTTOM_INSET + BlzFrameGetHeight(clearMenu.parent)

        ------------------------------------------------------------------------------------------------------------------------
        --Variable Viewer
        ------------------------------------------------------------------------------------------------------------------------

        variableViewer.parent = BlzCreateFrame("CodeEditor", codeEditorParent, 0, 0)
        BlzFrameSetLevel(variableViewer.parent, 2)
        BlzFrameSetPoint(variableViewer.parent, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPLEFT, 0, 0)
        BlzFrameSetSize(variableViewer.parent, variableViewer.WIDTH, editor.LINE_SPACING + 2*variableViewer.LINE_VERTICAL_INSET)
        BlzFrameSetVisible(variableViewer.parent, init.hasCode)

        backdrop = BlzFrameGetChild(variableViewer.parent, 0)
        BlzFrameSetAllPoints(backdrop, variableViewer.parent)
        SetFrameAlpha(backdrop, editor.BLACK_BACKDROP_ALPHA)

        border = BlzFrameGetChild(variableViewer.parent, 1)
        BlzFrameSetAllPoints(border, variableViewer.parent)

        buttons.back = BlzCreateFrameByType("GLUETEXTBUTTON", "", variableViewer.parent, "ScriptDialogButton", 0)
        BlzFrameSetPoint(buttons.back, FRAMEPOINT_BOTTOMLEFT, variableViewer.parent, FRAMEPOINT_BOTTOMLEFT, variableViewer.WIDTH/2/0.8 - 0.025, -0.01)
        BlzFrameSetPoint(buttons.back, FRAMEPOINT_TOPRIGHT, variableViewer.parent, FRAMEPOINT_BOTTOMLEFT, variableViewer.WIDTH/2/0.8 + 0.025, 0.015)
        BlzFrameSetText(buttons.back, "Back")
        BlzFrameSetScale(buttons.back, 0.8)
        trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, buttons.back, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(trig, GoBack)
        BlzFrameSetVisible(buttons.back, false)

        CreateToggleExpandButton("CollapseEditorButton", editor.ASSET_SUBFOLDER .. "\\collapseEditor.blp", variableViewer.parent)

        variableViewer.title = BlzCreateFrameByType("TEXT", "", variableViewer.parent, "", 0)
        BlzFrameSetText(variableViewer.title, "|cffffcc00Variables")
        BlzFrameSetSize(variableViewer.title, 0, 0)
        BlzFrameSetPoint(variableViewer.title, FRAMEPOINT_TOPLEFT, variableViewer.parent, FRAMEPOINT_TOPLEFT, variableViewer.LINE_HORIZONTAL_INSET, editor.CHECKBOX_VERTICAL_SHIFT + editor.CHECKBOX_TEXT_VERTICAL_SHIFT)
        BlzFrameSetEnable(variableViewer.title, false)

        variableViewer.scroller = BlzCreateFrame("VerticalSlider", variableViewer.parent, 0, 0)

        BlzFrameSetPoint(variableViewer.scroller, FRAMEPOINT_TOP, variableViewer.parent, FRAMEPOINT_TOPRIGHT, -editor.CODE_SCROLLER_HORIZONTAL_INSET, -variableViewer.LINE_VERTICAL_INSET)
        BlzFrameSetSize(variableViewer.scroller, editor.CODE_SCROLLER_WIDTH, editor.MAX_LINES_ON_SCREEN*editor.LINE_SPACING)

        BlzFrameSetMinMaxValue(variableViewer.scroller, 0, 0)
        BlzFrameSetValue(variableViewer.scroller, 0)
        BlzFrameSetStepSize(variableViewer.scroller, 1)
        BlzFrameSetLevel(variableViewer.scroller, 3)
        BlzFrameSetVisible(variableViewer.scroller, false)

        variableViewer.scrollTrigger = CreateTrigger()
        TriggerAddAction(variableViewer.scrollTrigger, function()
            if BlzGetTriggerFrameValue() > 0 then
                BlzFrameSetValue(variableViewer.scroller, BlzFrameGetValue(variableViewer.scroller) + 2)
            else
                BlzFrameSetValue(variableViewer.scroller, BlzFrameGetValue(variableViewer.scroller) - 2)
            end
        end)

        ------------------------------------------------------------------------------------------------------------------------
        --Context Menu
        ------------------------------------------------------------------------------------------------------------------------

        contextMenu.parent = BlzCreateFrame("CodeEditor", codeEditorParent, 0, 0)
        BlzFrameSetLevel(contextMenu.parent, 3)
        BlzFrameSetVisible(contextMenu.parent, false)
        BlzFrameSetSize(contextMenu.parent, flagsMenu.WIDTH, 2*flagsMenu.TEXT_INSET + (contextMenu.NUM_DEFAULT_BUTTONS + #contextMenu.customButtons)*editor.LINE_SPACING)

        backdrop = BlzFrameGetChild(contextMenu.parent, 0)
        BlzFrameSetAllPoints(backdrop, contextMenu.parent)
        SetFrameAlpha(backdrop, editor.BLACK_BACKDROP_ALPHA)

        border = BlzFrameGetChild(contextMenu.parent, 1)
        BlzFrameSetAllPoints(border, contextMenu.parent)

        for i = 1, #contextMenu.customButtons do
            if contextMenu.customButtons[i] == "separator" then
                CreateContextSeparator(i)
            else
                CreateContextButton(i, contextMenu.customButtons[i].title, contextMenu.customButtons[i].tooltip, contextMenu.customButtons[i].callback, true, contextMenu.customButtons[i].titleSuffix, contextMenu.parent)
            end
        end

        local function GoToDefinition(scriptName, word)
            local currentLines
            local lineLimit
            if scriptName then
                if tabs.numbers[scriptName] then
                    currentLines = codeLines[scriptName][step[scriptName]]
                    lineLimit = highestNonEmptyLine[scriptName][step[scriptName]]
                else
                    currentLines = files[existingFiles[scriptName]]
                    lineLimit = #currentLines
                end
            else
                currentLines = codeLines[currentTab][step[currentTab]]
                lineLimit = highestNonEmptyLine[currentTab][step[currentTab]]
            end
            word = word or sub(currentLines[selection.startLine], min(selection.startPos, selection.endPos) + 1, max(selection.startPos, selection.endPos))
            local start, stop
            for i = 1, lineLimit do
                --local var1, var, word / word = / function word
                if (not scriptName and find(currentLines[i], "local%s+([%w_%s,]-)%f[%a]" .. word .. "%f[^%w_]") ~= nil)
                or (find(currentLines[i], word .. "%s*=[^=]") ~= nil and (not scriptName or find(currentLines[i], "local%s+" .. word .. "%s*=[^=]") == nil))
                or (find(currentLines[i], "function%s+" .. word) ~= nil and (not scriptName or find(currentLines[i], "local%s+function%s+" .. word) == nil)) then
                    start, stop = find(currentLines[i], word)
                end
                if start then
                    selection.startLine = i
                    selection.endLine = i
                    selection.startPos = start - 1
                    selection.endPos = stop
                    local limit = editor.isExpanded and editor.CHARS_ON_SCREEN_EXPANDED or editor.CHARS_ON_SCREEN_COLLAPSED
                    BlzFrameSetValue(codeHorizontalScroller, max(min(tabs.horizontalOffset[currentTab], start - 1), stop - limit))
                    SetSelection()
                    cursor.codeLineNumber = selection.startLine
                    cursor.screenLineNumber = selection.startLine - tabs.lineNumberOffset[currentTab]
                    SetCursorPos(selection.endPos)
                    SetCursorX(sub(codeLines[currentTab][step[currentTab]][cursor.codeLineNumber], tabs.horizontalOffset[currentTab] + 1, selection.endPos))
                    if scriptName then
                        if not tabs.numbers[scriptName] then
                            WSCode.Pull(scriptName)
                        end
                        WSCode.SwitchToTab(scriptName)
                    end
                    JumpWindow(i, scriptName ~= nil, scriptName ~= nil)
                    BlzFrameSetVisible(contextMenu.parent, false)
                    if not editor.isLocked then
                        BlzFrameSetFocus(editBox, true)
                        if not editBoxFocused then
                            editBoxFocused = true
                            editor.ON_FOCUS()
                        end
                        BlzFrameSetVisible(cursorFrame, true)
                    end
                    return true
                end
            end

            if not scriptName then
                for name, index in next, existingFiles do
                    if GoToDefinition(name, word) then
                        return
                    end
                end
                PlayError()
                BlzFrameSetVisible(contextMenu.parent, false)
            end

            return false
        end

        contextMenu.gotodef = CreateContextButton(#contextMenu.customButtons + 1, "Go to Definition", "Go to the declaration of the selected variable within this file.", GoToDefinition, false, "|r |cffaaaaaa(F12)", contextMenu.parent)

        local function Comment()
            BlzFrameSetVisible(contextMenu.parent, false)
            if selection.hasSelection then
                WSCode.IncrementStep()
                local lowerLine = min(selection.startLine, selection.endLine)
                local upperLine = max(selection.startLine, selection.endLine)
                for i = lowerLine, upperLine do
                    local line = codeLines[currentTab][step[currentTab]][i]
                    codeLines[currentTab][step[currentTab]][i] = line:match("^%s*") .. "--" .. line:match("^%s*(.*)")
                    coloredCodeLines[currentTab][step[currentTab]][i] = nil
                end
                if selection.startLine == selection.endLine then
                    if selection.endPos > selection.startPos then
                        selection.endPos = selection.endPos + 2
                    else
                        selection.startPos = selection.startPos + 2
                    end
                elseif selection.endLine > selection.startLine then
                    selection.endPos = selection.endPos + 2
                else
                    selection.startPos = selection.startPos + 2
                end
            else
                if not cursor.codeLineNumber then
                    return
                end
                WSCode.IncrementStep()
                local line = codeLines[currentTab][step[currentTab]][cursor.codeLineNumber]
                codeLines[currentTab][step[currentTab]][cursor.codeLineNumber] = line:match("^%s*") .. "--" .. line:match("^%s*(.*)")
                coloredCodeLines[currentTab][step[currentTab]][cursor.codeLineNumber] = nil
            end
            UpdateAllLines()
            SetSelection()
        end

        local function Uncomment()
            BlzFrameSetVisible(contextMenu.parent, false)
            if selection.hasSelection then
                WSCode.IncrementStep()
                local lowerLine = min(selection.startLine, selection.endLine)
                local upperLine = max(selection.startLine, selection.endLine)
                for i = lowerLine, upperLine do
                    local line = codeLines[currentTab][step[currentTab]][i]
                    if line:match("^(%s*)%-%-") then
                        codeLines[currentTab][step[currentTab]][i] = line:match("^(%s*)%-%-") .. line:match("^%s*%-%-(.*)")
                        coloredCodeLines[currentTab][step[currentTab]][i] = nil
                    end
                end
                if selection.startLine == selection.endLine then
                    if selection.endPos > selection.startPos then
                        selection.endPos = selection.endPos + 2
                    else
                        selection.startPos = selection.startPos + 2
                    end
                elseif selection.endLine > selection.startLine then
                    selection.endPos = selection.endPos + 2
                else
                    selection.startPos = selection.startPos + 2
                end
            else
                if not cursor.codeLineNumber then
                    return
                end
                WSCode.IncrementStep()
                local line = codeLines[currentTab][step[currentTab]][cursor.codeLineNumber]
                if line:match("^(%s*)%-%-") then
                    codeLines[currentTab][step[currentTab]][cursor.codeLineNumber] = line:match("^(%s*)%-%-") .. line:match("^%s*%-%-(.*)")
                    coloredCodeLines[currentTab][step[currentTab]][cursor.codeLineNumber] = nil
                end
            end
            UpdateAllLines()
            SetSelection()
        end

        contextMenu.comment = CreateContextButton(#contextMenu.customButtons + 2, "Comment", "Comment out the selected code or the current line of the cursor if no code is selected.", Comment, false, "|r |cffaaaaaa(Ctrl-Shift + R)", contextMenu.parent)

        contextMenu.uncomment = CreateContextButton(#contextMenu.customButtons + 3, "Uncomment", "Uncomment the selected code or the current line of the cursor if no code is selected.", Uncomment, false, "|r |cffaaaaaa(Ctrl-Shift + T)", contextMenu.parent)

        contextMenu.autoIndent = CreateContextButton(#contextMenu.customButtons + 4, "Auto-Indent", "Automatically indent the selected text or, if no text is selected, the entire text in the current tab.", function()
            if selection.hasSelection then
                local lowerLine = min(selection.startLine, selection.endLine)
                local upperLine = max(selection.startLine, selection.endLine)
                WSCode.AutoIndent(currentTab, lowerLine, upperLine)
            else
                WSCode.AutoIndent(currentTab)
            end
            BlzFrameSetVisible(contextMenu.parent, false)
        end, nil, false, contextMenu.parent)

        local function ContextExecute()
            local lines
            if selection.hasSelection then
                lines = ConvertSelectionToLines()
                WSDebug.PrintForUser("Executing selection...")
            else
                lines = {codeLines[currentTab][step[currentTab]][cursor.codeLineNumber]}
                WSDebug.PrintForUser("Executing line " .. math.tointeger(cursor.codeLineNumber) .. "...")
            end
            CompileFunction(lines, {
                tab = currentTab .. " (Execute)",
                debugMode = flags.debugMode
            })
            BlzFrameSetVisible(contextMenu.parent, false)
        end

        contextMenu.execute = CreateContextButton(#contextMenu.customButtons + 5, "Execute", "Executes the selected code in a new thread and environment. If no code is selected, executes the current line of the cursor instead.", ContextExecute, false, "|r |cffaaaaaa(Ctrl + Q)|r", contextMenu.parent)

        local function Cut()
            if not selection.hasSelection then
                selection.startLine = cursor.codeLineNumber
                selection.endLine = cursor.codeLineNumber
                selection.startPos = 0
                selection.endPos = #codeLines[currentTab][step[currentTab]][cursor.codeLineNumber]
            end
            clipboard = ConvertSelectionToLines()
            WSCode.IncrementStep()
            DeleteSelection()
            BlzFrameSetVisible(contextMenu.parent, false)
            editBoxText = "     "
            BlzFrameSetText(editBox, "     ")
        end

        contextMenu.cut = CreateContextButton(#contextMenu.customButtons + 6, "Cut", "Cuts the selected text and adds it to the internal buffer. If no text is selected, the entire line at the cursor position will be cut. Does not add the text to the OS clipboard.", Cut, false, "|r |cffaaaaaa(Ctrl + X)", contextMenu.parent)

        local function Copy()
            if selection.hasSelection then
                clipboard = ConvertSelectionToLines()
            else
                clipboard = {codeLines[currentTab][step[currentTab]][cursor.codeLineNumber]}
            end
            BlzFrameSetVisible(contextMenu.parent, false)
        end

        contextMenu.copy = CreateContextButton(#contextMenu.customButtons + 7, "Copy", "Adds the selected text to the internal buffer. If no text is selected, the entire line at the cursor position will be added. Does not add the text to the OS clipboard.", Copy, false, "|r |cffaaaaaa(Ctrl + C)", contextMenu.parent)

        local function PasteCallback()
            WSCode.IncrementStep()
            if selection.hasSelection then
                DeleteSelection()
            end
            local text = clipboard[1]
            for i = 2, #clipboard do
                text = text .. "\n" .. clipboard[i]
            end
            ChangeCodeLine(text)
            if not editor.isLocked then
                BlzFrameSetFocus(editBox, true)
                if not editBoxFocused then
                    editBoxFocused = true
                    editor.ON_FOCUS()
                end
                BlzFrameSetVisible(cursorFrame, true)
            end

            editBoxText = "     "
            BlzFrameSetText(editBox, "     ")
            editor.textChangeMonitorFrozen = false
        end

        local function UnfreezeTextChangeMonitor()
            clipboard = nil
            editor.textChangeMonitorFrozen = false
        end

        local function Paste()
            if BlzIsMetaKeyPressed(METAKEY_ALT) then
                editor.lastOsClipboardText = nil
                return
            end
            if clipboard and #clipboard > 0 then
                local newText = BlzFrameGetText(editBox)
                if math.abs(#newText - #editBoxText) > 1 then
                    if not editor.lastOsClipboardText or newText:gsub("^%s*", "") ~= editor.lastOsClipboardText:gsub("^%s*", "") then
                        editor.textChangeMonitorFrozen = true

                        local dialog = DialogCreate()
                        DialogSetMessage(dialog, "Which clipboard?")

                        local osbutton = DialogAddButton(dialog, "OS Clipboard (S)", 83)
                        local ostrig = CreateTrigger()
                        TriggerRegisterDialogButtonEvent(ostrig, osbutton)
                        TriggerAddAction(ostrig, UnfreezeTextChangeMonitor)

                        local wscodebutton = DialogAddButton(dialog, "WSCode Clipboard (W)", 87)
                        local wscodetrig = CreateTrigger()
                        TriggerRegisterDialogButtonEvent(wscodetrig, wscodebutton)
                        TriggerAddAction(wscodetrig, function()
                            editor.lastOsClipboardText = newText
                            PasteCallback()
                        end)

                        DialogDisplay(user, dialog, true)
                    else
                        if not editor.autoPasteWarningGiven then
                            WSDebug.PrintForUser("Auto-pasting WSCode clipboard. Press Ctrl + Alt + V to override.")
                            editor.autoPasteWarningGiven = true
                        end
                        PasteCallback()
                    end
                else
                    PasteCallback()
                end
            end
            BlzFrameSetVisible(contextMenu.parent, false)
        end

        contextMenu.paste = CreateContextButton(#contextMenu.customButtons + 8, "Paste", "Inserts the text stored in the internal buffer. To paste text from the OS clipboard, press Ctrl + V instead.", Paste, false, "|r |cffaaaaaa(Ctrl + V)", contextMenu.parent)

        ------------------------------------------------------------------------------------------------------------------------
        --Tab Navigators
        ------------------------------------------------------------------------------------------------------------------------

        trig = CreateTrigger()
        TriggerAddAction(trig, ClickTabButton)

        local name = tabs.names[1]
        tabs.truncatedNames[name] = find(name, "\\\\") ~= nil and sub(name, match(name, ".*()\\\\") + 2, nil) or name
        tabNavigator.frames[name] = BlzCreateFrame("TabNavigator", codeEditorParent, 0, 0)
        tabNavigator.titles[name] = BlzFrameGetChild(tabNavigator.frames[name], 2)
        tabNavigator.highlights[name] = BlzFrameGetChild(tabNavigator.frames[name], 3)
        SetFrameAlpha(tabNavigator.highlights[name], 0)
        if tabs.wasNotCompiledInDebugMode[name] then
            BlzFrameSetText(tabNavigator.titles[name], editor.TAB_NAVIGATOR_SELECTED_NO_DEBUG_COLOR .. tabs.truncatedNames[name] .. "|r")
        else
            BlzFrameSetText(tabNavigator.titles[name], editor.TAB_NAVIGATOR_SELECTED_COLOR .. tabs.truncatedNames[name] .. "|r")
        end
        BlzFrameSetSize(tabNavigator.titles[name], 0, 0)
        local width = BlzFrameGetWidth(tabNavigator.titles[name])
        tabNavigator.widths[name] = max(tabNavigator.WIDTH, width + 2*tabNavigator.TEXT_INSET)
        BlzFrameSetAllPoints(tabNavigator.titles[name], tabNavigator.frames[name])
        BlzFrameSetTextAlignment(tabNavigator.titles[name], TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
        BlzFrameSetEnable(tabNavigator.titles[name], false)
        BlzFrameSetSize(tabNavigator.frames[name], tabNavigator.widths[name], tabNavigator.HEIGHT)
        BlzFrameSetPoint(tabNavigator.frames[name], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, 0, tabNavigator.VERTICAL_SHIFT)
        BlzFrameSetAllPoints(BlzFrameGetChild(tabNavigator.frames[name], 1), tabNavigator.frames[name])
        SetFrameAlpha(BlzFrameGetChild(tabNavigator.frames[name], 1), editor.BLACK_BACKDROP_ALPHA)
        BlzTriggerRegisterFrameEvent(trig, tabNavigator.frames[name], FRAMEEVENT_CONTROL_CLICK)
        tabs.numberFromFrame[tabNavigator.frames[name]] = 1

        for t = 2, tabs.amount do
            name = tabs.names[t]
            tabs.truncatedNames[name] = find(name, "\\\\") ~= nil and sub(name, match(name, ".*()\\\\") + 2, nil) or name
            tabNavigator.frames[name] = BlzCreateFrame("TabNavigator", codeEditorParent, 0, 0)
            tabNavigator.titles[name] = BlzFrameGetChild(tabNavigator.frames[name], 2)
            tabNavigator.highlights[name] = BlzFrameGetChild(tabNavigator.frames[name], 3)
            if tabs.wasNotCompiledInDebugMode[name] then
                BlzFrameSetText(tabNavigator.titles[name], editor.TAB_NAVIGATOR_UNSELECTED_NO_DEBUG_COLOR .. tabs.truncatedNames[name] .. "|r")
            else
                BlzFrameSetText(tabNavigator.titles[name], editor.TAB_NAVIGATOR_UNSELECTED_COLOR .. tabs.truncatedNames[name] .. "|r")
            end
            BlzFrameSetSize(tabNavigator.titles[name], 0, 0)
            width = BlzFrameGetWidth(tabNavigator.titles[name])
            tabNavigator.widths[name] = max(tabNavigator.WIDTH, width + 2*tabNavigator.TEXT_INSET)
            BlzFrameSetAllPoints(tabNavigator.titles[name], tabNavigator.frames[name])
            BlzFrameSetTextAlignment(tabNavigator.titles[name], TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
            BlzFrameSetEnable(tabNavigator.titles[name], false)
            BlzFrameSetSize(tabNavigator.frames[name], tabNavigator.widths[name], tabNavigator.HEIGHT)
            BlzFrameSetPoint(tabNavigator.frames[name], FRAMEPOINT_BOTTOMLEFT, tabNavigator.frames[tabs.names[t - 1]], FRAMEPOINT_BOTTOMRIGHT, -tabNavigator.OVERLAP, 0)
            BlzFrameSetAllPoints(BlzFrameGetChild(tabNavigator.frames[name], 1), tabNavigator.frames[name])
            SetFrameAlpha(BlzFrameGetChild(tabNavigator.frames[name], 1), editor.BLACK_BACKDROP_ALPHA)
            BlzTriggerRegisterFrameEvent(trig, tabNavigator.frames[name], FRAMEEVENT_CONTROL_CLICK)
            tabs.numberFromFrame[tabNavigator.frames[name]] = t
        end

        for t = 1, tabs.amount do
            closeButton = BlzCreateFrame("CloseEditorButton", tabNavigator.frames[tabs.names[t]], 0, 0)
            BlzFrameSetPoint(closeButton, FRAMEPOINT_BOTTOMLEFT, tabNavigator.frames[tabs.names[t]], FRAMEPOINT_TOPRIGHT, -tabNavigator.CLOSE_BUTTON_INSET - tabNavigator.CLOSE_BUTTON_SIZE, -tabNavigator.CLOSE_BUTTON_INSET - tabNavigator.CLOSE_BUTTON_SIZE)
            BlzFrameSetPoint(closeButton, FRAMEPOINT_TOPRIGHT, tabNavigator.frames[tabs.names[t]], FRAMEPOINT_TOPRIGHT, -tabNavigator.CLOSE_BUTTON_INSET, -tabNavigator.CLOSE_BUTTON_INSET)
            icon = BlzFrameGetChild(closeButton, 0)
            iconClicked = BlzFrameGetChild(closeButton, 1)
            iconHighlight = BlzFrameGetChild(closeButton, 2)
            BlzFrameSetAllPoints(icon, closeButton)
            BlzFrameSetTexture(icon, editor.ASSET_SUBFOLDER .. "\\closeEditor.blp", 0, true)
            BlzFrameSetTexture(iconClicked, editor.ASSET_SUBFOLDER .. "\\closeEditor.blp", 0, true)
            BlzFrameClearAllPoints(iconHighlight)
            BlzFrameSetPoint(iconHighlight, FRAMEPOINT_BOTTOMLEFT, closeButton, FRAMEPOINT_BOTTOMLEFT, 0.00375, 0.00375)
            BlzFrameSetPoint(iconHighlight, FRAMEPOINT_TOPRIGHT, closeButton, FRAMEPOINT_TOPRIGHT, -0.00375, -0.00375)
            BlzFrameSetVisible(closeButton, false)
            trig = CreateTrigger()
            BlzTriggerRegisterFrameEvent(trig, closeButton, FRAMEEVENT_CONTROL_CLICK)
            TriggerAddAction(trig, WSCode.CloseTab)
            tabs.numberFromFrame[closeButton] = t
            tabNavigator.closeButtons[tabs.names[t]] = closeButton
        end

        tabs.addTabFrame = BlzCreateFrame("TabNavigator", codeEditorParent, 0, 0)
        tabs.addTabTitle = BlzFrameGetChild(tabs.addTabFrame, 2)
        BlzFrameSetText(tabs.addTabTitle, editor.TAB_NAVIGATOR_SELECTED_COLOR .. "+" .. "|r")
        BlzFrameSetAllPoints(tabs.addTabTitle, tabs.addTabFrame)
        BlzFrameSetTextAlignment(tabs.addTabTitle, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
        BlzFrameSetEnable(tabs.addTabTitle, false)
        BlzFrameSetSize(tabs.addTabFrame, tabNavigator.HEIGHT, tabNavigator.HEIGHT)
        BlzFrameSetPoint(tabs.addTabFrame, FRAMEPOINT_BOTTOMLEFT, tabNavigator.frames[tabs.names[tabs.amount]], FRAMEPOINT_BOTTOMRIGHT, -tabNavigator.OVERLAP, 0)
        BlzFrameSetAllPoints(BlzFrameGetChild(tabs.addTabFrame, 1), tabs.addTabFrame)
        SetFrameAlpha(BlzFrameGetChild(tabs.addTabFrame, 1), editor.BLACK_BACKDROP_ALPHA)

        AdjustTabWidths()

        trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, tabs.addTabFrame, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(trig, function()
            BlzFrameSetEnable(tabs.addTabFrame, false)
            BlzFrameSetEnable(tabs.addTabFrame, true)
            if not BlzFrameIsVisible(nameDialog.parent) then
                ClearTextMessages()
                nameDialog.state = "addtab"
                BlzFrameSetVisible(nameDialog.parent, true)
                BlzFrameSetFocus(nameDialog.textField, true)
                BlzFrameSetText(nameDialog.title, "|cffffcc00Enter Tab Name|r")
                for i = tabs.amount + 1, 1, -1 do
                    local occupado = false
                    for j = 1, tabs.amount do
                        if tabs.names[j] == "Tab " .. i then
                            occupado = true
                            break
                        end
                    end
                    if not occupado then
                        BlzFrameSetText(nameDialog.textField, "Tab " .. i)
                        return
                    end
                end
            end
        end)

        ------------------------------------------------------------------------------------------------------------------------
        --Tab Menu
        ------------------------------------------------------------------------------------------------------------------------

        tabMenu.parent = BlzCreateFrame("CodeEditor", codeEditorParent, 0, 0)
        BlzFrameSetLevel(tabMenu.parent, 3)
        BlzFrameSetVisible(tabMenu.parent, false)
        BlzFrameSetSize(tabMenu.parent, flagsMenu.WIDTH, 2*flagsMenu.TEXT_INSET + (tabMenu.NUM_DEFAULT_BUTTONS)*editor.LINE_SPACING)

        backdrop = BlzFrameGetChild(tabMenu.parent, 0)
        BlzFrameSetAllPoints(backdrop, tabMenu.parent)
        SetFrameAlpha(backdrop, editor.BLACK_BACKDROP_ALPHA)

        border = BlzFrameGetChild(tabMenu.parent, 1)
        BlzFrameSetAllPoints(border, tabMenu.parent)

        local function SetBreakCondition()
            if currentTab ~= tabMenu.clickedTab then
                if WSCode.SetBreakCondition(WSCode.ConvertLinesToString(WSCode.GetCodeInTab()), tabMenu.clickedTab) then
                    WSDebug.PrintForUser(currentTab .. " has been set as the break condition for tab " .. tabMenu.clickedTab .. ".")
                else
                    WSDebug.PrintForUser("|cffff5555ERROR: Tab content does not constitute a valid function body.")
                end
            else
                WSDebug.PrintForUser("Break condition has been removed for tab " .. tabMenu.clickedTab .. ".")
                WSCode.RemoveBreakCondition(tabMenu.clickedTab)
            end
            BlzFrameSetVisible(tabMenu.parent, false)
        end

        tabMenu.breakCondition = CreateContextButton(1, "Break Condition", "Sets the code in the currently opened tab as the condition for breakpoints to activate in the clicked tab. The code must be the function body of a function that returns a boolean. The current line number is passed into the function as the variable lineNumber. Remove a break condition by clicking this button while the selected tab is opened.", SetBreakCondition, false, nil, tabMenu.parent)

        local function BreakEverywhere()
            BlzFrameSetVisible(tabMenu.parent, false)
            breakEverywhere[tabMenu.clickedTab] = not breakEverywhere[tabMenu.clickedTab]
            if breakEverywhere[tabMenu.clickedTab] then
                print("Breaking on every line in tab " .. tabMenu.clickedTab .. "...")
            else
                print("No longer breaking on every line in tab " .. tabMenu.clickedTab .. "...")
            end
        end

        tabMenu.breakEverywhere = CreateContextButton(2, "Break Everywhere", "Toggles whether code execution should halt at every single line in the clicked tab.", BreakEverywhere, false, nil, tabMenu.parent)

        local function BreakNowhere()
            BlzFrameSetVisible(tabMenu.parent, false)
            tabs.breakNowhere[tabMenu.clickedTab] = not tabs.breakNowhere[tabMenu.clickedTab]
            if tabs.breakNowhere[tabMenu.clickedTab] then
                print("Line-by-line code execution will no longer halt in tab " .. tabMenu.clickedTab .. "...")
            else
                print("Line-by-line code execution will once again halt in tab " .. tabMenu.clickedTab .. "...")
            end
        end

        local function BreakOnlyHere()
            BlzFrameSetVisible(tabMenu.parent, false)
            if breakOnlyHere == tabMenu.clickedTab then
                breakOnlyHere = nil
            else
                breakOnlyHere = tabMenu.clickedTab
            end
            if breakOnlyHere then
                print("Line-by-line code execution will only halt in tab " .. tabMenu.clickedTab .. "...")
            else
                print("Line-by-line code execution will once again halt in every tab...")
            end
        end

        tabMenu.breakNowhere = CreateContextButton(3, "Break Nowhere", "Toggles whether WSCode should ignore this tab when stepping through code line-by-line. In addition, disables all WSCode.BreakHere statements.", BreakNowhere, false, nil, tabMenu.parent)

        tabMenu.breakOnlyHere = CreateContextButton(4, "Break Only Here", "Toggles whether WSCode should ignore all other tabs when stepping through code line-by-line.", BreakOnlyHere, false, nil, tabMenu.parent)

        local function SaveAs()
            BlzFrameSetVisible(tabMenu.parent, false)
            if not BlzFrameIsVisible(nameDialog.parent) then
                ClearTextMessages()
                nameDialog.state = "saveas"
                BlzFrameSetVisible(nameDialog.parent, true)
                BlzFrameSetFocus(nameDialog.textField, true)
                BlzFrameSetText(nameDialog.title, "|cffffcc00Enter File Name|r")
            end
        end

        tabMenu.saveAs = CreateContextButton(5, "Save As...", "Saves this tab to the WSCode folder in Custom Map Data under the specified name. The file can later be loaded using the Load Backup File button.", SaveAs, false, nil, tabMenu.parent)
        ------------------------------------------------------------------------------------------------------------------------
        --Enter Name Dialog
        ------------------------------------------------------------------------------------------------------------------------

        nameDialog.parent = BlzCreateFrame("CodeEditor", parent, 0, 0)
        BlzFrameSetLevel(nameDialog.parent, 3)
        BlzFrameSetAbsPoint(nameDialog.parent, FRAMEPOINT_CENTER, 0.4, 0.3)
        BlzFrameSetSize(nameDialog.parent, nameDialog.WIDTH, nameDialog.HEIGHT)

        backdrop = BlzFrameGetChild(nameDialog.parent, 0)
        BlzFrameSetAllPoints(backdrop, nameDialog.parent)
        SetFrameAlpha(backdrop, editor.BLACK_BACKDROP_ALPHA)

        border = BlzFrameGetChild(nameDialog.parent, 1)
        BlzFrameSetAllPoints(border, nameDialog.parent)

        nameDialog.title = BlzCreateFrameByType("TEXT", "", nameDialog.parent, "", 0)
        BlzFrameSetPoint(nameDialog.title, FRAMEPOINT_TOPRIGHT, nameDialog.parent, FRAMEPOINT_TOPRIGHT, 0, -nameDialog.TITLE_VERTICAL_SHIFT)
        BlzFrameSetPoint(nameDialog.title, FRAMEPOINT_BOTTOMLEFT, nameDialog.parent, FRAMEPOINT_BOTTOMLEFT, 0, nameDialog.TITLE_VERTICAL_SHIFT)
        BlzFrameSetTextAlignment(nameDialog.title, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_CENTER)
        BlzFrameSetEnable(nameDialog.title, false)

        nameDialog.textField = BlzCreateFrame("EscMenuEditBoxTemplate", nameDialog.parent, 0, 0)
        BlzFrameSetPoint(nameDialog.textField, FRAMEPOINT_BOTTOMLEFT, nameDialog.parent, FRAMEPOINT_TOPLEFT, nameDialog.ENTER_BOX_HORIZONTAL_INSET, -nameDialog.ENTER_BOX_VERTICAL_SHIFT - nameDialog.ENTER_BOX_HEIGHT)
        BlzFrameSetPoint(nameDialog.textField, FRAMEPOINT_TOPRIGHT, nameDialog.parent, FRAMEPOINT_TOPRIGHT, -nameDialog.ENTER_BOX_HORIZONTAL_INSET,  -nameDialog.ENTER_BOX_VERTICAL_SHIFT)

        local nameDialogCallbacks = {
            addtab = function(enteredName)
                for i = 1, #fileNames do
                    if fileNames[i] == enteredName then
                        WSDebug.PrintForUser("|cffff5555ERROR: A file with that name already exists. If you want to add that script to the editor, use Pull Script button instead.|r")
                        PlayError()
                        return
                    end
                end
                for i = 1, tabs.amount do
                    if tabs.names[i] == enteredName then
                        WSDebug.PrintForUser("|cffff5555ERROR: A tab with that name already exists.")
                        PlayError()
                        return
                    end
                end
                WSCode.AddTab(enteredName)
                WSCode.SwitchToTab(enteredName)
            end,

            viewglobal = WSCode.ViewGlobal,

            smarteval = function(expression)
                local rawExpression = expression

                local stringList = {}
                expression = expression:gsub('"[^"]*"', function(str)
                    stringList[#stringList + 1] = str
                    return "__STRING" .. #stringList
                end)
                expression = expression:gsub("'[^']*'", function(str)
                    stringList[#stringList + 1] = str
                    return "__STRING" .. #stringList
                end)

                local numReplaced
                --Replace . and : with [""] so that tokenizer splits table fields into separate tokens.
                repeat
                    expression, numReplaced = expression:gsub("([%a_][%w_]*)%.([%w_]+)", "%1[\"%2\"]")
                until numReplaced == 0
                repeat
                    expression, numReplaced = expression:gsub("([%a_][%w_]*):([%w_]+)%(", "%1[\"%2\"](%1,")
                until numReplaced == 0

                for i = #stringList, 1, -1 do
                    expression = expression:gsub("__STRING" .. i, stringList[i])
                end

                local tokens = WSCode.Tokenize(expression)

                local isAssignment = false
                local isSimpleExpression = true
                local inject = false
                local injectedVar
                local equalSignPos

                for i = 1, #tokens do
                    if LUA.KEYWORDS[tokens[i]] or LUA.OPERATORS[tokens[i]] then
                        isSimpleExpression = false
                        if tokens[i] == "=" then
                            isAssignment = true
                            equalSignPos = i
                            break
                        end
                    end
                end

                local lineNumber = lineNumbers.lastViewed[currentTab] or lastLineNumber[currentTab]

                if isAssignment then
                    inject = true
                    for i = 1, equalSignPos - 1 do
                        if find(tokens[i], "%[") then
                            inject = false
                            break
                        end
                    end
                    if inject then
                        injectedVar = tokens[1]
                        local level = visibleVarsOfLine[currentTab][lineNumber][injectedVar]
                        if level and level ~= -1 then
                            if not WSDebug.Injectors[currentTab][injectedVar] then
                                PlayError()
                                WSDebug.PrintForUser("|cffff5555ERROR: Variable cannot be reassigned.|r")
                                return
                            end
                        else
                            inject = false
                        end
                    end
                end

                for i = 1, #tokens do
                    if not LUA.KEYWORDS[tokens[i]] and not LUA.OPERATORS[tokens[i]] and find(tokens[i], "^#?%s*[%w_]*$") then
                        local prefix, adjustedToken = match(tokens[i], "^(#)%s*([%w_]+)$")
                        local level = visibleVarsOfLine[currentTab][lineNumber][adjustedToken or tokens[i]]
                        if level and level ~= -1 then
                            if prefix then
                                tokens[i] = "#(WSDebug.VarTable[\"" .. currentTab .. "\"][" .. level .. "][\"" .. adjustedToken .. "\"] ~= nil and WSDebug.VarTable[\"" .. currentTab .. "\"][" .. level .. "][\"" .. adjustedToken .. "\"] ~= WSDebug.Nil and " .. "WSDebug.VarTable[\"" .. currentTab .. "\"][" .. level .. "][\"" .. adjustedToken .. "\"] or _ENV[\"" .. adjustedToken .. "\"])"
                            else
                                tokens[i] = "(WSDebug.VarTable[\"" .. currentTab .. "\"][" .. level .. "][\"" .. tokens[i] .. "\"] ~= nil and WSDebug.VarTable[\"" .. currentTab .. "\"][" .. level .. "][\"" .. tokens[i] .. "\"] ~= WSDebug.Nil and " .. "WSDebug.VarTable[\"" .. currentTab .. "\"][" .. level .. "][\"" .. tokens[i] .. "\"] or _ENV[\"" .. tokens[i] .. "\"])"
                            end
                        end
                    end
                end

                if not isAssignment then
                    local funcString = WSCode.Detokenize(tokens)

                    local func = load("return " .. funcString, "WSCode SmartEval", "t")
                    if not func then
                        PlayError()
                        WSDebug.PrintForUser("|cffff5555ERROR: Invalid expression.|r")
                        return
                    end
                    local returnValues = table.pack(func())
                    if isSimpleExpression and returnValues and #returnValues == 1 and HandleType[returnValues[1]] == "trigger" then
                        WSDebug.PrintForUser("Executing trigger " .. expression .. "...")
                        TriggerExecute(returnValues[1])
                    else
                        for i = 1, #returnValues do
                            returnValues[i] = tostring(returnValues[i])
                        end
                        if #returnValues >= 1 then
                            returnValues[1] = rawExpression .. "\n>> " .. returnValues[1]
                            WSDebug.PrintForUser(table.unpack(returnValues))
                        else
                            WSDebug.PrintForUser(rawExpression .. "\n>> nil")
                        end
                    end
                elseif inject then
                    local funcString = WSCode.Detokenize(tokens, equalSignPos + 1)

                    local func = load("return " .. funcString, "WSCode SmartEval", "t")
                    if not func then
                        PlayError()
                        WSDebug.PrintForUser("|cffff5555ERROR: Invalid expression.|r")
                        return
                    end

                    local returnValue = func()
                    WSDebug.PrintForUser(rawExpression .. "\n>> " .. tostring(returnValue))

                    WSDebug.Injectors[currentTab][injectedVar](returnValue)
                    UpdateVariableViewer(lastLineNumber[currentTab], true)
                else
                    local assignedVarString = WSCode.Detokenize(tokens, 1, equalSignPos - 1)
                    local assignmentString = WSCode.Detokenize(tokens, equalSignPos + 1)

                    local func = load("local returnValue = " .. assignmentString .. " " .. assignedVarString .. " = returnValue return returnValue", "WSCode SmartEval", "t")
                    if not func then
                        PlayError()
                        WSDebug.PrintForUser("|cffff5555ERROR: Invalid expression.|r")
                        return
                    end

                    local returnValue = func()
                    WSDebug.PrintForUser(rawExpression .. "\n>> " .. tostring(returnValue))
                    UpdateVariableViewer(lastLineNumber[currentTab], true)
                end
            end,

            injecteval = WSCode.InjectEval,

            pullscript = function(enteredName)
                if WSCode.Pull(enteredName) then
                    WSCode.SwitchToTab(enteredName)
                end
            end,

            loadfromfile = function(enteredName)
                WSCode.LoadBackupFile(enteredName)
            end,

            saveas = function(enteredName)
                FileIO.Save(editor.EXPORT_SUBFOLDER .. "\\WSCodeLoadFile" .. enteredName .. ".txt", WSCode.ConvertLinesToString(codeLines[tabMenu.clickedTab][step[tabMenu.clickedTab]]))
                print("Tab " .. tabMenu.clickedTab .. " saved to " .. editor.EXPORT_SUBFOLDER .. "\\WSCodeLoadFile" .. enteredName .. ".txt.")
            end,

            hook = function(enteredName)
                WSCode.Hook(enteredName)
            end,

            custom = function(enteredName)
                nameDialog.callback(enteredName)
            end
        }

        trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, nameDialog.textField, FRAMEEVENT_EDITBOX_ENTER)
        TriggerAddAction(trig, function()
            if BlzFrameIsVisible(helper.parent) and helper.numSuggestionsVisible > 0 and helper.selectedSuggestion > 0 and helper.selectedSuggestion <= helper.numSuggestionsVisible then
                if nameDialog.state == "pullscript" then
                    HideHelperAndAllAutoCompleteFrames()
                    BlzFrameSetVisible(nameDialog.parent, false)
                    BlzFrameSetFocus(nameDialog.textField, false)

                    nameDialogCallbacks[nameDialog.state](helper.selectedSuggestionText)
                else
                    InsertAutoCompleteSuggestion(helper.selectedSuggestion)
                end
                return
            end

            HideHelperAndAllAutoCompleteFrames()
            BlzFrameSetVisible(nameDialog.parent, false)
            BlzFrameSetFocus(nameDialog.textField, false)

            local enteredName = BlzGetTriggerFrameText():gsub("\\", "\\\\")

            nameDialogCallbacks[nameDialog.state](enteredName)
        end)

        trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, nameDialog.textField, FRAMEEVENT_EDITBOX_TEXT_CHANGED)
        TriggerAddAction(trig, function()
            if nameDialog.doNotShowHelper then
                nameDialog.doNotShowHelper = false
                return
            end
            if nameDialog.state ~= "loadfromfile" and (nameDialog.state ~= "custom" or nameDialog.lookupTable) then
                CheckForAutoCompleteSuggestions(
                    BlzGetTriggerFrameText(),
                    nil, --screenLineNumbernumber
                    true, --show in dialog window
                    false, --search locals
                    nameDialog.state == "pullscript", --searchFileNames
                    nameDialog.state == "call", --separateByComma
                    nameDialog.lookupTable --custom lookup table
                )
            end
        end)

        local closeNameDialogButton = BlzCreateFrame("CloseEditorButton", nameDialog.parent, 0, 0)
		BlzFrameSetPoint(closeNameDialogButton, FRAMEPOINT_BOTTOMLEFT, nameDialog.parent, FRAMEPOINT_TOPRIGHT, -searchBar.SEARCH_BUTTON_INSET - searchBar.BUTTON_SIZE, -searchBar.SEARCH_BUTTON_INSET - searchBar.BUTTON_SIZE)
		BlzFrameSetPoint(closeNameDialogButton, FRAMEPOINT_TOPRIGHT, nameDialog.parent, FRAMEPOINT_TOPRIGHT, -searchBar.SEARCH_BUTTON_INSET, -searchBar.SEARCH_BUTTON_INSET)
        icon = BlzFrameGetChild(closeNameDialogButton, 0)
        iconClicked = BlzFrameGetChild(closeNameDialogButton, 1)
        iconHighlight = BlzFrameGetChild(closeNameDialogButton, 2)
        BlzFrameSetAllPoints(icon, closeNameDialogButton)
		BlzFrameSetTexture(icon, editor.ASSET_SUBFOLDER .. "\\closeEditor.blp", 0, true)
		BlzFrameSetTexture(iconClicked, editor.ASSET_SUBFOLDER .. "\\closeEditor.blp", 0, true)
        BlzFrameClearAllPoints(iconHighlight)
        BlzFrameSetPoint(iconHighlight, FRAMEPOINT_BOTTOMLEFT, closeNameDialogButton, FRAMEPOINT_BOTTOMLEFT, 0.00375, 0.00375)
        BlzFrameSetPoint(iconHighlight, FRAMEPOINT_TOPRIGHT, closeNameDialogButton, FRAMEPOINT_TOPRIGHT, -0.00375, -0.00375)

        trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, closeNameDialogButton, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(trig, function()
            BlzFrameSetVisible(nameDialog.parent, false)
            helper.selectedSuggestion = nil
            BlzFrameSetVisible(helper.parent, false)
            BlzFrameSetFocus(nameDialog.textField, false)
        end)

        BlzFrameSetVisible(nameDialog.parent, false)

        ------------------------------------------------------------------------------------------------------------------------
        --Search Bar
        ------------------------------------------------------------------------------------------------------------------------

        searchBar.parent = BlzCreateFrame("CodeEditor", codeEditorParent, 0, 0)
        BlzFrameSetLevel(searchBar.parent, 2)
        BlzFrameSetPoint(searchBar.parent, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPRIGHT, -searchBar.HORIZONTAL_INSET, -searchBar.VERTICAL_INSET)
        BlzFrameSetSize(searchBar.parent, searchBar.WIDTH, searchBar.HEIGHT)
        BlzFrameSetVisible(searchBar.parent, false)

        backdrop = BlzFrameGetChild(searchBar.parent, 0)
        BlzFrameSetAllPoints(backdrop, searchBar.parent)
        SetFrameAlpha(backdrop, editor.BLACK_BACKDROP_ALPHA)

        border = BlzFrameGetChild(searchBar.parent, 1)
        BlzFrameSetAllPoints(border, searchBar.parent)
        BlzFrameSetVisible(border, false)

        searchBar.textField = BlzCreateFrame("SearchBarEditBox", searchBar.parent, 0, 0)
        BlzFrameSetPoint(searchBar.textField, FRAMEPOINT_BOTTOMLEFT, searchBar.parent, FRAMEPOINT_BOTTOMLEFT, searchBar.SEARCH_FIELD_LEFT_INSET, searchBar.SEARCH_FIELD_BOTTOM_INSET)
        BlzFrameSetPoint(searchBar.textField, FRAMEPOINT_TOPRIGHT, searchBar.parent, FRAMEPOINT_TOPRIGHT, -searchBar.SEARCH_FIELD_RIGHT_INSET,  -searchBar.SEARCH_FIELD_TOP_INSET)
        BlzFrameSetVisible(BlzFrameGetChild(searchBar.textField, 0), false)
        trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, searchBar.textField, FRAMEEVENT_EDITBOX_TEXT_CHANGED)
        TriggerAddAction(trig, OnSearchBarEdit)

        local closeSearchBarButton = BlzCreateFrame("CloseEditorButton", searchBar.parent, 0, 0)
		BlzFrameSetPoint(closeSearchBarButton, FRAMEPOINT_BOTTOMLEFT, searchBar.parent, FRAMEPOINT_TOPRIGHT, -searchBar.SEARCH_BUTTON_INSET - searchBar.BUTTON_SIZE, -searchBar.SEARCH_BUTTON_INSET - searchBar.BUTTON_SIZE)
		BlzFrameSetPoint(closeSearchBarButton, FRAMEPOINT_TOPRIGHT, searchBar.parent, FRAMEPOINT_TOPRIGHT, -searchBar.SEARCH_BUTTON_INSET, -searchBar.SEARCH_BUTTON_INSET)
        icon = BlzFrameGetChild(closeSearchBarButton, 0)
        iconClicked = BlzFrameGetChild(closeSearchBarButton, 1)
        iconHighlight = BlzFrameGetChild(closeSearchBarButton, 2)
        BlzFrameSetAllPoints(icon, closeSearchBarButton)
		BlzFrameSetTexture(icon, editor.ASSET_SUBFOLDER .. "\\closeEditor.blp", 0, true)
		BlzFrameSetTexture(iconClicked, editor.ASSET_SUBFOLDER .. "\\closeEditor.blp", 0, true)
        BlzFrameClearAllPoints(iconHighlight)
        BlzFrameSetPoint(iconHighlight, FRAMEPOINT_BOTTOMLEFT, closeSearchBarButton, FRAMEPOINT_BOTTOMLEFT, 0.00375, 0.00375)
        BlzFrameSetPoint(iconHighlight, FRAMEPOINT_TOPRIGHT, closeSearchBarButton, FRAMEPOINT_TOPRIGHT, -0.00375, -0.00375)
        trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, closeSearchBarButton, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(trig, function()
            BlzFrameSetVisible(searchBar.parent, false)
            BlzFrameSetFocus(searchBar.textField, false)
            for i = 1, #searchBar.highlights do
                ReturnTextHighlightFrame(searchBar.highlights[i])
                searchBar.highlights[i] = nil
            end
        end)

        searchBar.searchDownButton = BlzCreateFrame("SearchDownButton", searchBar.parent, 0, 0)
		BlzFrameSetPoint(searchBar.searchDownButton, FRAMEPOINT_BOTTOMLEFT, searchBar.parent, FRAMEPOINT_TOPRIGHT, -searchBar.SEARCH_BUTTON_INSET - 2*searchBar.BUTTON_SIZE, -searchBar.SEARCH_BUTTON_INSET - searchBar.BUTTON_SIZE)
		BlzFrameSetPoint(searchBar.searchDownButton, FRAMEPOINT_TOPRIGHT, searchBar.parent, FRAMEPOINT_TOPRIGHT, -searchBar.SEARCH_BUTTON_INSET - searchBar.BUTTON_SIZE, -searchBar.SEARCH_BUTTON_INSET)
        icon = BlzFrameGetChild(searchBar.searchDownButton, 0)
        iconClicked = BlzFrameGetChild(searchBar.searchDownButton, 1)
        iconHighlight = BlzFrameGetChild(searchBar.searchDownButton, 2)
        BlzFrameSetAllPoints(icon, searchBar.searchDownButton)
		BlzFrameSetTexture(icon, editor.ASSET_SUBFOLDER .. "\\searchArrowDown.blp", 0, true)
		BlzFrameSetTexture(iconClicked, editor.ASSET_SUBFOLDER .. "\\searchArrowDown.blp", 0, true)
        BlzFrameClearAllPoints(iconHighlight)
        BlzFrameSetPoint(iconHighlight, FRAMEPOINT_BOTTOMLEFT, searchBar.searchDownButton, FRAMEPOINT_BOTTOMLEFT, 0.00375, 0.00375)
        BlzFrameSetPoint(iconHighlight, FRAMEPOINT_TOPRIGHT, searchBar.searchDownButton, FRAMEPOINT_TOPRIGHT, -0.00375, -0.00375)
        BlzFrameSetEnable(searchBar.searchDownButton, false)
        trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, searchBar.searchDownButton, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(trig, SearchDown)

        searchBar.searchUpButton = BlzCreateFrame("SearchUpButton", searchBar.parent, 0, 0)
		BlzFrameSetPoint(searchBar.searchUpButton, FRAMEPOINT_BOTTOMLEFT, searchBar.parent, FRAMEPOINT_TOPRIGHT, -searchBar.SEARCH_BUTTON_INSET - 3*searchBar.BUTTON_SIZE, -searchBar.SEARCH_BUTTON_INSET - searchBar.BUTTON_SIZE)
		BlzFrameSetPoint(searchBar.searchUpButton, FRAMEPOINT_TOPRIGHT, searchBar.parent, FRAMEPOINT_TOPRIGHT, -searchBar.SEARCH_BUTTON_INSET - 2*searchBar.BUTTON_SIZE, -searchBar.SEARCH_BUTTON_INSET)
        icon = BlzFrameGetChild(searchBar.searchUpButton, 0)
        iconClicked = BlzFrameGetChild(searchBar.searchUpButton, 1)
        iconHighlight = BlzFrameGetChild(searchBar.searchUpButton, 2)
        BlzFrameSetAllPoints(icon, searchBar.searchUpButton)
		BlzFrameSetTexture(icon, editor.ASSET_SUBFOLDER .. "\\searchArrowUp.blp", 0, true)
		BlzFrameSetTexture(iconClicked, editor.ASSET_SUBFOLDER .. "\\searchArrowUp.blp", 0, true)
        BlzFrameClearAllPoints(iconHighlight)
        BlzFrameSetPoint(iconHighlight, FRAMEPOINT_BOTTOMLEFT, searchBar.searchUpButton, FRAMEPOINT_BOTTOMLEFT, 0.00375, 0.00375)
        BlzFrameSetPoint(iconHighlight, FRAMEPOINT_TOPRIGHT, searchBar.searchUpButton, FRAMEPOINT_TOPRIGHT, -0.00375, -0.00375)
        BlzFrameSetEnable(searchBar.searchUpButton, false)
        trig = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trig, searchBar.searchUpButton, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(trig, SearchUp)

        searchBar.numResults = BlzCreateFrameByType("TEXT", "", searchBar.parent, "", 0)
        BlzFrameSetPoint(searchBar.numResults, FRAMEPOINT_BOTTOMLEFT, searchBar.parent, FRAMEPOINT_BOTTOMLEFT, searchBar.NUM_FINDS_LEFT_INSET/0.825, searchBar.NUM_FINDS_TOP_INSET/0.825)
        BlzFrameSetPoint(searchBar.numResults, FRAMEPOINT_TOPRIGHT, searchBar.parent, FRAMEPOINT_TOPRIGHT, -searchBar.NUM_FINDS_LEFT_INSET/0.825, -searchBar.NUM_FINDS_TOP_INSET/0.825)
        BlzFrameSetScale(searchBar.numResults, 0.825)
        BlzFrameSetEnable(searchBar.numResults, false)
        BlzFrameSetTextAlignment(searchBar.numResults, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
        BlzFrameSetText(searchBar.numResults, "|cffaaaaaaNo results|r")

        ------------------------------------------------------------------------------------------------------------------------
        --Load Tabs
        ------------------------------------------------------------------------------------------------------------------------

        if editor.ENABLE_SAVE_AND_LOAD and FileIO and not init.tabsInitialized then
            InitTabs()

            if init.pullTabs then
                for fileName, __ in next, init.pullTabs do
                    if existingFiles[fileName] then
                        if init then
                            local code = table.concat(files[existingFiles[fileName]])
                            if (not code or (not find(code, "@debug") and not find(code, "@store"))) and (not init.debugTabs or not init.debugTabs[fileName]) then
                                WSCode.Pull(fileName)
                            end
                        else
                            WSCode.Pull(fileName)
                        end
                    end
                end
            end

            if init.loadTabs then
                for fileName, __ in next, init.loadTabs do
                    local code = FileIO.Load(editor.EXPORT_SUBFOLDER .. "\\WSCodeLoadFile" .. fileName:gsub(" ", "") .. ".txt")
                    if code then
                        StoreCode(fileName, code)
                    end
                end
            end
        end

        ------------------------------------------------------------------------------------------------------------------------
        --Misc
        ------------------------------------------------------------------------------------------------------------------------

        local tableTrace = ""
        local level = 0
        local function GetAllTableFields(source, target)
            level = level + 1
            for key, value in next, source do
                if type(key) == "string" and key ~= "_G" and level <= 4 then
                    target[#target + 1] = key
                    if type(value) == "table" then
                        target[key] = {}
                        tableTrace = tableTrace .. "." .. key
                        GetAllTableFields(value, target[key])
                    end
                end
            end
            table.sort(target)
            level = level - 1
        end

        GetAllTableFields(_G, globalLookupTable)
        for i = 1, #globalLookupTable do
            if not globalLookupTable[globalLookupTable[i]] then
                --globalLookupTable has both a sequence and a dictionary. A table key means global is a table. Otherwise, true.
                globalLookupTable[globalLookupTable[i]] = true
            end
        end

        if not GetTerrainZ then
            local moveableLoc = Location(0, 0)
            GetTerrainZ = function(x, y)
                MoveLocation(moveableLoc, x, y)
                return GetLocationZ(moveableLoc)
            end
        end

        brackets.highlights[1] = GetTextHighlightFrame("08", 130, "bracketHighlight")
        BlzFrameSetVisible(brackets.highlights[1], false)
        brackets.highlights[2] = GetTextHighlightFrame("08", 130, "bracketHighlight")
        BlzFrameSetVisible(brackets.highlights[2], false)

        if init.hasCode then
            UpdateVariableViewer(lineNumbers.lastViewed[currentTab] or lastLineNumber[currentTab])
            ToggleVariableViewerExpand()
            variableViewer.hasNotBeenExpanded = true
        end

        if editor.LEGAL_CHARACTERS then
            local legalCharacters = editor.LEGAL_CHARACTERS
            editor.LEGAL_CHARACTERS = {}
            for i = 1, #legalCharacters do
                editor.LEGAL_CHARACTERS[sub(legalCharacters, i, i)] = true
            end
        end

        if AsyncControl then
            AsyncControl.Register({
                oskey = OSKEY_D,
                metakey = METAKEY_CTRL,
                exactMetakey = true,
                onPress = function()
                    if WSCode.IsVisible() then
                        ToggleExpand()
                    end
                end,
            })

            AsyncControl.Register({
                oskey = OSKEY_Z,
                metakey = METAKEY_CTRL,
                exactMetakey = true,
                onPress = function()
                    if WSCode.IsVisible() then
                        WSCode.Undo()
                    end
                end,
                whilePressed = "onPress",
                delay = 0.5,
                interval = 0.06
            })

            AsyncControl.Register({
                oskey = OSKEY_Y,
                metakey = METAKEY_CTRL,
                exactMetakey = true,
                onPress = function()
                    if WSCode.IsVisible() then
                        WSCode.Redo()
                    end
                end,
                whilePressed = "onPress",
                delay = 0.5,
                interval = 0.06
            })

            AsyncControl.Register({
                oskey = OSKEY_F,
                metakey = METAKEY_CTRL,
                exactMetakey = true,
                onPress = function()
                    if WSCode.IsVisible() then
                        editBoxFocused = false
                        BlzFrameSetFocus(editBox, false)
                        BlzFrameSetEnable(editBox, false)
                        BlzFrameSetEnable(editBox, true)
                        ShowSearchBar()
                    end
                end
            })

            AsyncControl.Register({
                oskey = OSKEY_R,
                metakey = METAKEY_CTRL + METAKEY_SHIFT,
                exactMetakey = true,
                onPress = function()
                    if WSCode.IsVisible() then
                        Comment()
                    end
                end
            })

            AsyncControl.Register({
                oskey = OSKEY_T,
                metakey = METAKEY_CTRL + METAKEY_SHIFT,
                exactMetakey = true,
                onPress = function()
                    if WSCode.IsVisible() then
                        Uncomment()
                    end
                end
            })

            AsyncControl.Register({
                oskey = OSKEY_X,
                metakey = METAKEY_CTRL,
                exactMetakey = true,
                onPress = function()
                    if WSCode.IsVisible() then
                        Cut()
                    end
                end
            })

            AsyncControl.Register({
                oskey = OSKEY_C,
                metakey = METAKEY_CTRL,
                exactMetakey = true,
                onPress = function()
                    if WSCode.IsVisible() then
                        Copy()
                    end
                end
            })

            AsyncControl.Register({
                oskey = OSKEY_V,
                metakey = METAKEY_CTRL,
                exactMetakey = true,
                onPress = function()
                    if WSCode.IsVisible() and editBoxFocused then
                        Paste()
                    end
                end
            })

            AsyncControl.Register({
                oskey = OSKEY_A,
                metakey = METAKEY_CTRL,
                exactMetakey = true,
                onPress = function()
                    if WSCode.IsVisible() and WSCode.IsFocused() then
                        selection.startLine = 1
                        selection.endLine = highestNonEmptyLine[currentTab][step[currentTab]]
                        selection.startPos = 0
                        selection.endPos = #codeLines[currentTab][step[currentTab]][selection.endLine]
                        selection.hasSelection = true
                        SetSelection()
                    end
                end
            })

            AsyncControl.Register({
                oskey = OSKEY_E,
                metakey = METAKEY_CTRL,
                exactMetakey = true,
                onPress = function()
                    if WSCode.IsVisible() and (WSCode.IsFocused() or selection.hasSelection) then
                        editBoxFocused = false
                        BlzFrameSetFocus(editBox, false)
                        BlzFrameSetEnable(editBox, false)
                        BlzFrameSetEnable(editBox, true)
                        BlzFrameSetVisible(cursorFrame, false)
                        SmartEvaluate()
                    end
                end
            })

            AsyncControl.Register({
                oskey = OSKEY_F12,
                metakey = 0,
                onPress = function()
                    if WSCode.IsVisible() and editBoxFocused then
                        GoToDefinition()
                    end
                end
            })

            AsyncControl.Register({
                oskey = OSKEY_TAB,
                metakey = 0,
                onPress = function()
                    if WSCode.IsVisible() and editBoxFocused then
                        if BlzFrameIsVisible(helper.parent) and helper.numSuggestionsVisible > 0 and helper.selectedSuggestion > 0 and helper.selectedSuggestion <= helper.numSuggestionsVisible then
                            InsertAutoCompleteSuggestion(helper.selectedSuggestion)
                            return
                        end

                        WSCode.IncrementStep()
                        CodeEditorOnAction()
                        BlzFrameSetFocus(editBox, true)
                        cursor.posOfLineJumps = nil

                        HideHelperAndAllAutoCompleteFrames()

                        local newText
                        local currentLines = codeLines[currentTab][step[currentTab]]
                        if selection.hasSelection then
                            local cursorShift = 0
                            local lowerLine = min(selection.startLine, selection.endLine)
                            local upperLine = max(selection.startLine, selection.endLine)
                            for i = lowerLine, upperLine do
                                local precedingSpaces = match(currentLines[i], "^%s*")
                                local newNumSpaces = math.floor(#precedingSpaces/4)*4 + 4
                                local newSpaces = ""
                                for __ = #precedingSpaces + 1, newNumSpaces do
                                    newSpaces = newSpaces .. " "
                                end

                                if i == cursor.codeLineNumber then
                                    cursorShift = #newSpaces
                                end

                                if i == upperLine then
                                    if upperLine == selection.endLine then
                                        selection.endPos = selection.endPos + #newSpaces
                                    else
                                        selection.startPos = selection.startPos + #newSpaces
                                    end
                                end

                                currentLines[i] = newSpaces .. currentLines[i]
                                coloredCodeLines[currentTab][step[currentTab]][i] = nil
                            end

                            UpdateAllLines()
                            SetCursorPos(cursor.pos + cursorShift)
                            SetCursorX(sub(currentLines[cursor.codeLineNumber], tabs.horizontalOffset[currentTab] + 1, cursor.pos))
                            SetSelection()
                            if upperLine > highestNonEmptyLine[currentTab][step[currentTab]] then
                                highestNonEmptyLine[currentTab][step[currentTab]] = upperLine
                                BlzFrameSetMinMaxValue(codeScroller, 0, upperLine)
                                SetLineOffset(tabs.lineNumberOffset[currentTab])
                            end

                            if CheckLongestLineLength() then
                                AdjustHorizontalLineScroller()
                            end
                        else
                            local numSpaces = math.floor((cursor.pos)/4)*4 - cursor.pos + 4
                            newText = ""
                            for __ = 1, numSpaces do
                                newText = newText .. " "
                            end
                            currentLines[cursor.codeLineNumber] = sub(currentLines[cursor.codeLineNumber], 1, cursor.pos) .. newText .. sub(currentLines[cursor.codeLineNumber], cursor.pos + 1)
                            coloredCodeLines[currentTab][step[currentTab]][cursor.codeLineNumber] = nil
                            RenderLine(cursor.screenLineNumber, currentLines[cursor.codeLineNumber])
                            SetCursorPos(cursor.pos + #newText)
                            SetCursorX(sub(currentLines[cursor.codeLineNumber], tabs.horizontalOffset[currentTab] + 1, cursor.pos))
                            if cursor.codeLineNumber > highestNonEmptyLine[currentTab][step[currentTab]] then
                                highestNonEmptyLine[currentTab][step[currentTab]] = cursor.codeLineNumber
                                BlzFrameSetMinMaxValue(codeScroller, 0, cursor.codeLineNumber)
                                SetLineOffset(tabs.lineNumberOffset[currentTab])
                            end
                        end
                    end
                end,
                whilePressed = "onPress",
                delay = 0.5,
                interval = 0.06
            })

            AsyncControl.Register({
                oskey = OSKEY_ESCAPE,
                metakey = 0,
                exactMetakey = true,
                onPress = function()
                    if WSCode.IsVisible() and BlzFrameIsVisible(helper.parent) and helper.numSuggestionsVisible > 0 then
                        HideHelperAndAllAutoCompleteFrames()
                    end
                end
            })

            AsyncControl.Register({
                oskey = OSKEY_TAB,
                metakey = METAKEY_SHIFT,
                exactMetakey = true,
                onPress = function()
                    if WSCode.IsVisible() and editBoxFocused then
                        WSCode.IncrementStep()
                        CodeEditorOnAction()
                        BlzFrameSetFocus(editBox, true)
                        cursor.posOfLineJumps = nil

                        local currentLines = codeLines[currentTab][step[currentTab]]
                        local lowerLine, upperLine
                        local cursorShift = 0
                        if selection.hasSelection then
                            lowerLine = min(selection.startLine, selection.endLine)
                            upperLine = max(selection.startLine, selection.endLine)
                        else
                            lowerLine = cursor.codeLineNumber
                            upperLine = cursor.codeLineNumber
                        end

                        for i = lowerLine, upperLine do
                            local precedingSpaces = match(currentLines[i], "^%s*")
                            local removedSpaces = math.min(#precedingSpaces, #precedingSpaces - math.ceil(#precedingSpaces/4 - 0.01)*4 + 4)

                            if not selection.hasSelection or i == selection.endLine then
                                cursorShift = removedSpaces
                            end

                            if i == upperLine then
                                if upperLine == selection.endLine then
                                    selection.endPos = selection.endPos - removedSpaces
                                else
                                    selection.startPos = selection.startPos - removedSpaces
                                end
                            end

                            currentLines[i] = sub(currentLines[i], removedSpaces + 1)
                            coloredCodeLines[currentTab][step[currentTab]][i] = nil
                        end

                        UpdateAllLines()
                        SetCursorPos(cursor.pos - cursorShift)
                        SetCursorX(sub(currentLines[cursor.codeLineNumber], tabs.horizontalOffset[currentTab] + 1, cursor.pos))
                        if selection.hasSelection then
                            SetSelection()
                        end

                        if CheckLongestLineLength() then
                            AdjustHorizontalLineScroller()
                        end
                    end
                end,
                whilePressed = "onPress",
                delay = 0.5,
                interval = 0.06
            })

            AsyncControl.Register({
                oskey = OSKEY_LEFT,
                metakey = 0,
                onPress = function()
                    if WSCode.IsVisible() and editBoxFocused then
                        SetCursorPos(max(cursor.pos - 1, 0))
                        if cursor.pos < tabs.horizontalOffset[currentTab] then
                            BlzFrameSetValue(codeHorizontalScroller, tabs.horizontalOffset[currentTab] - 1)
                        end
                        SetCursorX(sub(codeLines[currentTab][step[currentTab]][cursor.codeLineNumber], tabs.horizontalOffset[currentTab] + 1, cursor.pos))
                        editBoxText = "          "
                        BlzFrameSetText(editBox, "          ")
                        cursor.posOfLineJumps = nil
                    end
                end,
                whilePressed = "onPress",
                delay = 0.5,
                interval = 0.04
            })

            AsyncControl.Register({
                oskey = OSKEY_RIGHT,
                metakey = 0,
                onPress = function()
                    if WSCode.IsVisible() and editBoxFocused then
                        if not cursor.codeLineNumber then
                            return
                        end
                        local currentLines = codeLines[currentTab][step[currentTab]]
                        SetCursorPos(min(cursor.pos + 1, #currentLines[cursor.codeLineNumber]))
                        SetCursorX(sub(currentLines[cursor.codeLineNumber], tabs.horizontalOffset[currentTab] + 1, cursor.pos))
                        cursor.posOfLineJumps = nil
                    end
                end,
                whilePressed = "onPress",
                delay = 0.5,
                interval = 0.04
            })

            AsyncControl.Register({
                oskey = OSKEY_UP,
                metakey = 0,
                onPress = function()
                    if WSCode.IsVisible() then
                        if BlzFrameIsVisible(helper.parent) and helper.numSuggestionsVisible > 0 then
                            helper.selectedSuggestion = helper.selectedSuggestion - 1
                            if helper.selectedSuggestion < 1 then
                                helper.selectedSuggestion = helper.numSuggestionsVisible
                            end
                            helper.selectedSuggestionText = helper.suggestions[helper.selectedSuggestion]
                            BlzFrameSetVisible(helper.suggestionHighlightFrame, true)
                            BlzFrameSetAllPoints(helper.suggestionHighlightFrame, helper.autoCompleteFrames[helper.selectedSuggestion])
                        elseif editBoxFocused then
                            if cursor.codeLineNumber == 1 then
                                return
                            end
                            cursor.posOfLineJumps = cursor.posOfLineJumps or cursor.pos
                            cursor.codeLineNumber = cursor.codeLineNumber - 1
                            if cursor.screenLineNumber > 1 then
                                cursor.screenLineNumber = cursor.screenLineNumber - 1
                            else
                                SetLineOffset(tabs.lineNumberOffset[currentTab] - 1)
                            end

                            local currentLines = codeLines[currentTab][step[currentTab]]
                            cursor.pos = math.min(#currentLines[cursor.codeLineNumber], cursor.posOfLineJumps)
                            SetCursorPos(cursor.pos)
                            SetCursorX(sub(currentLines[cursor.codeLineNumber], tabs.horizontalOffset[currentTab] + 1, cursor.pos))
                        end
                    end
                end,
                whilePressed = "onPress",
                delay = 0.5,
                interval = 0.04
            })

            AsyncControl.Register({
                oskey = OSKEY_DOWN,
                metakey = 0,
                onPress = function()
                    if WSCode.IsVisible() then
                        if BlzFrameIsVisible(helper.parent) and helper.numSuggestionsVisible > 0 then
                            helper.selectedSuggestion = helper.selectedSuggestion + 1
                            if helper.selectedSuggestion > helper.numSuggestionsVisible then
                                helper.selectedSuggestion = 1
                            end
                            helper.selectedSuggestionText = helper.suggestions[helper.selectedSuggestion]
                            BlzFrameSetVisible(helper.suggestionHighlightFrame, true)
                            BlzFrameSetAllPoints(helper.suggestionHighlightFrame, helper.autoCompleteFrames[helper.selectedSuggestion])
                        elseif editBoxFocused then
                            cursor.posOfLineJumps = cursor.posOfLineJumps or cursor.pos
                            cursor.codeLineNumber = cursor.codeLineNumber + 1
                            if cursor.screenLineNumber < editor.MAX_LINES_ON_SCREEN then
                                cursor.screenLineNumber = cursor.screenLineNumber + 1
                            else
                                SetLineOffset(tabs.lineNumberOffset[currentTab] + 1)
                            end

                            local currentLines = codeLines[currentTab][step[currentTab]]
                            cursor.pos = math.min(#currentLines[cursor.codeLineNumber], cursor.posOfLineJumps)
                            SetCursorPos(cursor.pos)
                            SetCursorX(sub(currentLines[cursor.codeLineNumber], tabs.horizontalOffset[currentTab] + 1, cursor.pos))
                        end
                    end
                end,
                whilePressed = "onPress",
                delay = 0.5,
                interval = 0.04
            })

            AsyncControl.Register({
                oskey = OSKEY_UP,
                metakey = METAKEY_ALT,
                exactMetakey = true,
                onPress = function()
                    if not BlzFrameIsVisible(codeEditorParent) then
                        return
                    end

                    local code = WSCode.GetCodeInTab()
                    local lineNumber = WSCode.GetCursorPosition()

                    if not lineNumber or lineNumber == 1 then
                        return
                    end

                    local previousLine = code[lineNumber - 1]
                    local thisLine = code[lineNumber]

                    WSCode.EditLine(lineNumber - 1, thisLine, nil, nil, true)
                    WSCode.EditLine(lineNumber, previousLine, nil, nil, true)

                    cursor.codeLineNumber = cursor.codeLineNumber - 1
                    if cursor.screenLineNumber > 1 then
                        cursor.screenLineNumber = cursor.screenLineNumber - 1
                    else
                        SetLineOffset(tabs.lineNumberOffset[currentTab] - 1)
                    end

                    SetCursorPos(cursor.pos)
                    SetCursorX(sub(codeLines[currentTab][step[currentTab]][cursor.codeLineNumber], tabs.horizontalOffset[currentTab] + 1, cursor.pos))
                end,
                whilePressed = "onPress",
                delay = 0.5,
                interval = 0.06
            })

            AsyncControl.Register({
                oskey = OSKEY_DOWN,
                metakey = METAKEY_ALT,
                exactMetakey = true,
                onPress = function()
                    if not BlzFrameIsVisible(codeEditorParent) then
                        return
                    end

                    local code = WSCode.GetCodeInTab()
                    local lineNumber = WSCode.GetCursorPosition()

                    if not lineNumber or lineNumber == highestNonEmptyLine[currentTab][step[currentTab]] then
                        return
                    end

                    local thisLine = code[lineNumber]
                    local nextLine = code[lineNumber + 1]

                    WSCode.EditLine(lineNumber, nextLine, nil, nil, true)
                    WSCode.EditLine(lineNumber + 1, thisLine, nil, nil, true)

                    cursor.codeLineNumber = cursor.codeLineNumber + 1
                    if cursor.screenLineNumber < editor.MAX_LINES_ON_SCREEN then
                        cursor.screenLineNumber = cursor.screenLineNumber + 1
                    else
                        SetLineOffset(tabs.lineNumberOffset[currentTab] + 1)
                    end

                    SetCursorPos(cursor.pos)
                    SetCursorX(sub(codeLines[currentTab][step[currentTab]][cursor.codeLineNumber], tabs.horizontalOffset[currentTab] + 1, cursor.pos))
                end,
                whilePressed = "onPress",
                delay = 0.5,
                interval = 0.06
            })

            AsyncControl.Register({
                oskey = OSKEY_DELETE,
                metakey = 0,
                onPress = function()
                    if WSCode.IsVisible() and editBoxFocused then
                        if selection.hasSelection then
                            WSCode.IncrementStep()
                            DeleteSelection()
                            editBoxText = "     "
                            BlzFrameSetText(editBox, "     ")
                            return
                        end

                        local whichLine = cursor.codeLineNumber
                        if not whichLine then
                            return
                        end
                        WSCode.IncrementStep()
                        local currentLines = codeLines[currentTab][step[currentTab]]
                        currentLines[whichLine] = sub(currentLines[whichLine], 1, cursor.pos) .. sub(currentLines[whichLine], cursor.pos + 2)
                        coloredCodeLines[currentTab][step[currentTab]][whichLine] = nil
                        RenderLine(cursor.screenLineNumber, codeLines[currentTab][step[currentTab]][cursor.codeLineNumber], coloredCodeLines[currentTab][step[currentTab]][cursor.codeLineNumber])
                        SetCursorPos(cursor.pos)
                        cursor.posOfLineJumps = nil
                        editBoxText = "     "
                        BlzFrameSetText(editBox, "     ")
                    end
                end,
                whilePressed = "onPress",
                delay = 0.5,
                interval = 0.04
            })

            AsyncControl.Register({
                mouseButton = MOUSE_BUTTON_TYPE_LEFT,
                onPress = OnMouseLeftClick,
                onRelease = OnMouseRelease,
                interval = 0.02
            })

            AsyncControl.Register({
                mouseButton = MOUSE_BUTTON_TYPE_RIGHT,
                onPress = OnMouseRightClick,
            })

            AsyncControl.Register({
                oskey = OSKEY_RETURN,
                onPress = function()
                    if WSCode.IsVisible() then
                        if BlzFrameIsVisible(nameDialog.parent) then
                            return
                        elseif BlzFrameIsVisible(helper.parent) and helper.numSuggestionsVisible > 0 then
                            InsertAutoCompleteSuggestion(helper.selectedSuggestion)
                        elseif editBoxFocused then
                            InsertCodeLine()
                        elseif BlzFrameIsVisible(searchBar.parent) and not BlzFrameIsVisible(nameDialog.parent) then
                            SearchDown()
                        end
                    end
                end,
                whilePressed = "onPress",
                delay = 0.5,
                interval = 0.06
            })

            AsyncControl.Register({
                oskey = OSKEY_Q,
                metakey = METAKEY_CTRL,
                exactMetakey = true,
                onPress = function()
                    if WSCode.IsVisible() and (WSCode.IsFocused() or selection.hasSelection) then
                        ContextExecute()
                    end
                end
            })

            AsyncControl.Register({
                oskey = OSKEY_F1,
                metakey = METAKEY_ALT,
                exactMetakey = true,
                onPress = function()
                    if WSCode.IsVisible() then
                        local index = plugins.activeIndex + 1
                        if index > #plugins.callbacks then
                            index = 1
                        end
                        plugins.callbacks[index]()
                    end
                end
            })
        else
            local trigEnter = CreateTrigger()
            BlzTriggerRegisterFrameEvent(trigEnter, editBox, FRAMEEVENT_EDITBOX_ENTER)
            TriggerAddAction(trigEnter, InsertCodeLine)
        end

        benchmark.TIMER = CreateTimer()

        editor.ON_ENABLE()
    end

    local function AddInit(whichFunc, onWhichPass, initPoint)
        if init == nil then
            return
        end
        if not init.inWrap and diagnostics.INIT_OUTSIDE_OF_WRAP_WARNING then
            print("|cffff0000Warning:|r WSCode Init function called from outside of map script wrap.")
        end
        if type(whichFunc) ~= "function" then
            if Debug then
                Debug.throwError("Invalid type passed for whichFunc. Expected function, but type was " .. type(whichFunc) .. ".")
            end
            return
        end

        init[initPoint][#init[initPoint] + 1] = whichFunc
        init.names[whichFunc] = init.currentFunctionName
        init.passes[whichFunc] = onWhichPass or 1
        if onWhichPass then
            if type(onWhichPass) ~= "number" or math.type(onWhichPass) ~= "integer" or onWhichPass < 2 then
                if Debug then
                    Debug.throwError("Invalid type passed for onWhichPass. Must be integer >= 2.")
                end
                return
            end
            init.highestPass[initPoint] = onWhichPass > init.highestPass[initPoint] and onWhichPass or init.highestPass[initPoint]
        end
    end

    --This table is global so that it is accessible within the executed code. Not part of the API.
    WSDebug = {
        AssignVars = function(valueTable, level, codeTab, lineNumber, ...)
            if doNotUpdateVariables[codeTab] then
                return
            end

            local whichVar
            local adjustedLevel
            for i = 1, select("#", ...) do
                whichVar = select(i, ...)
                if whichVar == "..." then
                    local packedVararg = {}
                    if valueTable then
                        for j = i, #valueTable do
                            packedVararg[j - i + 1] = valueTable[j]
                        end
                        wsdebug.VarTable[codeTab][level][whichVar] = packedVararg
                    else
                        wsdebug.VarTable[codeTab][level][whichVar] = packedVararg
                    end
                else
                    if level == -1 then
                        adjustedLevel = visibleVarsOfLine[codeTab][lineNumber][whichVar] or -1
                    else
                        adjustedLevel = level
                    end
                    if valueTable and valueTable[i] ~= nil then
                        wsdebug.VarTable[codeTab][adjustedLevel][whichVar] = valueTable[i]
                    else
                        wsdebug.VarTable[codeTab][adjustedLevel][whichVar] = wsdebug.Nil
                    end
                end
            end
        end,

        GetVar = function(codeTab, level, varName, value)
            local val = wsdebug.VarTable[codeTab][level][varName]
            if type(val) == "table" and type(value) == "table" then
                for key, entry in next, value do
                    val[key] = entry
                end
                return val
            elseif value == nil then
                if val == wsdebug.Nil then
                    return nil
                else
                    return val
                end
            else
                return value
            end
        end,

        GetVarEx = function(codeTab, level, ...)
            local numVars = select("#", ...)//2
            local varName
            local valueTable = {}
            for i = 1, numVars do
                varName = select(i, ...)
                valueTable[i] = wsdebug.GetVar(codeTab, level, varName, select(i + numVars, ...))
            end
            return valueTable
        end,

        GetVarNil = function(codeTab, level, ...)
            local numVars = select("#", ...)
            local varName
            local valueTable = {}
            for i = 1, numVars do
                varName = select(i, ...)
                valueTable[i] = wsdebug.GetVar(codeTab, level, varName)
            end
            return valueTable
        end,

        HandleCoroutine = function(whichFunc, whichTab, ...)
            currentCoroutine[whichTab] = coroutine.create(whichFunc)
            local result = table.pack(coroutine.resume(currentCoroutine[whichTab], ...))
            return select(2, table.unpack(result))
        end,

        GetWrapper = function(funcName, whichTab, whichGenCounter, whichFunc)
            if whichGenCounter > wrapperGenerationCounter[whichTab][funcName] then
                wrapperFunc[whichTab][funcName] = wrapperFunc[whichTab][funcName] or function(...) return wrappedFunc[whichTab][funcName](...) end
                wrappedFunc[whichTab][funcName] = whichFunc
                wrapperGenerationCounter[whichTab][funcName] = whichGenCounter
            elseif wrapperFunc[whichTab][funcName] then
                return whichFunc
            else
                wrapperFunc[whichTab][funcName] = function(...) return wrappedFunc[whichTab][funcName](...) end
                wrappedFunc[whichTab][funcName] = whichFunc
            end
            return wrapperFunc[whichTab][funcName]
        end,

        Execute = function(initPoint, ...)
            --Convert WSCode init name into TotalInit init name.
            initPoint = initPoint:gsub("Init", "")
            initPoint = initPoint:sub(1, 1):lower() .. initPoint:sub(2)
            wsdebug.FunctionsToInit[INIT_POINTS[initPoint]][#wsdebug.FunctionsToInit[INIT_POINTS[initPoint]] + 1] = select(-1, ...)
        end,

        FunctionsToInit = setmetatable({}, tab2D),

        StoreHandle = function(creator, creatorFunc, whichTab, ...)
            if _ENV[creator] == creatorFunc then
                local handle = select(1, ...)
                if handle then
                    handles[whichTab][handle] = creator
                end
            end
            return ...
        end,

        StoreSourceCode = function(whichFunction, sourceCodeIndex)
            wsdebug.SourceCodeIndex[whichFunction] = sourceCodeIndex
            return whichFunction
        end,

        SourceCode = setmetatable({}, {__mode = "k"}),
        SourceCodeIndex = setmetatable({}, {__mode = "k"}),

        FuncNames = {},

        End = function(lineNumber, whichTab, generationCounter)
            lastLineNumber[whichTab] = lineNumber
            lineNumbers.lastViewed[whichTab] = lineNumbers.lastViewed[whichTab] or lineNumber
            if variableViewer.isExpanded and generationCounter == wsdebug.GenerationCounter[whichTab] then
                UpdateVariableViewer(lineNumbers.lastViewed[whichTab])
            end
        end,

        PrintForUser = function(...)
            if user == nil or GetLocalPlayer() == user then
                print(...)
            end
        end,

        Nil = {},

        GenerationCounter = setmetatable({}, {__index = function(self, key) self[key] = 0 return 0 end}),

        Vars = {},

        VarTable = setmetatable({}, {__index = function(self, key) self[key] = setmetatable({}, {__index = function(child, childKey) child[childKey] = setmetatable({}, tabWeak) return child[childKey] end}) return self[key] end}),

        Traceback = {},

        Pack = table.pack,
        Unpack = table.unpack,

        Injectors = setmetatable({}, tab2D),

        Mouse = {
            x                       = 0,
            y                       = 0,
            lastMove                = 0,
            ignoreClickUntil        = 0,
            lastClick               = 0,
            leftButtonIsPressed     = false
        }
    }

    wsdebug = WSDebug

    --======================================================================================================================
    --API
    --======================================================================================================================

    StoreCode = function(tabName, functionBody)
        if not tabs.numbers[tabName] then
            if codeEditorParent then
                WSCode.AddTab(tabName)
            elseif tabs.names[1] == "Main" then
                tabs.names[1] = tabName
                tabs.numbers[tabName] = 1
                tabs.numbers.Main = nil
                if currentTab == "Main" then
                    currentTab = tabName
                end
            else
                tabs.amount = tabs.amount + 1
                tabs.numbers[tabName] = tabs.amount
                tabs.names[tabs.amount] = tabName
            end
        end

        local newLines
        if type(functionBody) == "string" then
            newLines = WSCode.ConvertStringToLines(functionBody)
            for i = 1, #newLines do
                newLines[i] = newLines[i]:gsub("\t", "    "):gsub("\n", ""):gsub("\r", "")
            end
        else
            newLines = functionBody
        end

        local oldCodeSize = highestNonEmptyLine[tabName][step[tabName]]
        if oldCodeSize > 0 then
            for i = oldCodeSize + 2, #newLines + oldCodeSize + 1 do
                codeLines[tabName][step[tabName]][i] = newLines[i - (oldCodeSize + 1)]
                coloredCodeLines[tabName][step[tabName]][i] = nil
            end
            codeLines[tabName][step[tabName]][oldCodeSize + 1] = ""
            coloredCodeLines[tabName][step[tabName]][oldCodeSize + 1] = nil
            highestNonEmptyLine[tabName][step[tabName]] = #newLines + oldCodeSize + 1
        else
            for i = 1, #newLines do
                codeLines[tabName][step[tabName]][i] = newLines[i]
                coloredCodeLines[tabName][step[tabName]][i] = nil
            end
            highestNonEmptyLine[tabName][step[tabName]] = #newLines
        end

        return newLines, tabName
    end

    local function Parse(functionBody, suspendExecution)
        if (compiler.ENABLE_QUICK_RESTART or compiler.FINALIZE_MAP_SCRIPT) and not init.afterMain or suspendExecution then
            if init.mapScript then
                init.mapScript = init.mapScript .. functionBody
            else
                init.mapScript = functionBody
            end
            return
        end

        init.mapScript = nil
        init.inWrap = true

        local loadedTabsToParse = {}
        local loadedTabNames = {}
        local tabWasStored = {}
        if compiler.ENABLE_QUICK_RESTART then
            InitTabs()

            if init.pullTabs then
                for fileName, __ in next, init.pullTabs do
                    if existingFiles[fileName] then
                        if init then
                            local code = table.concat(files[existingFiles[fileName]])
                            if (not code or (not find(code, "@debug") and not find(code, "@store"))) and (not init.debugTabs or not init.debugTabs[fileName]) then
                                WSCode.Pull(fileName)
                            end
                        else
                            WSCode.Pull(fileName)
                        end
                    end
                end
            end
        end

        local newLines = WSCode.ConvertStringToLines(functionBody)
        for i = 1, #newLines do
            newLines[i] = newLines[i]:gsub("\t", "    ")
        end

        local beginningOfFile = 1
        local anonymousCounter = 0
        local fileName = "anonymous"
        local debug = {}
        local transpile = {}
        local store = {}
        local add = {}
        local versionOfFile = {}
        local requirementTable = {}
        local requirementIsOptionalTable = {}
        local inGuiTrigger = false

        ----------------------------------------------------------------------
        --Parse Individual Script
        ----------------------------------------------------------------------

        local function ParseFile(whichLines, beginning, endOfFile, autoIndent, checkForExecute, isLoadedFile)
            local debugthis = init.debugTabs and init.debugTabs[fileName]
            local donotdebugthis = false
            local transpilethis = compiler.GLOBAL_DEBUG
            local storethis
            local addthis
            local atSign
            local lines = {}
            requirementTable[#requirementTable + 1] = {}
            requirementIsOptionalTable[#requirementIsOptionalTable + 1] = {}
            local requirements = requirementTable[#requirementTable]
            local requirementIsOptional = requirementIsOptionalTable[#requirementIsOptionalTable]
            local overrideVersion
            local executeScript = false

            local k = 1
            for j = beginning, endOfFile do
                lines[k] = whichLines[j]
                atSign = find(lines[k], "@") ~= nil
                if atSign then
                    if find(lines[k], "@map") then
                        if MapName and (lines[k]:find("@map !") == nil) == (lines[k]:match("@map !?(.+)%s*$") ~= MapName) then
                            lines = {}
                            fileName = "@" .. fileName
                            break
                        end
                    elseif FileIO and find(lines[k], "@loadfile") and not isLoadedFile and (not init.isQuickRestart or compiler.ALWAYS_QUICK_RESTART) and not compiler.FINALIZE_MAP_SCRIPT then
                        local file = FileIO.Load(editor.EXPORT_SUBFOLDER .. "\\WSCodeLoadFile" .. fileName:gsub(" ", "") .. ".txt")
                        if file then
                            local loadedLines = WSCode.ConvertStringToLines(file)
                            requirementTable[#requirementTable] = nil
                            requirementIsOptionalTable[#requirementIsOptionalTable] = nil
                            if #loadedLines ~= (endOfFile - beginning + 1) then
                                print(fileName .. " was loaded from save file. To override, manually paste code into the editor.")
                            else
                                for i = 1, #loadedLines do
                                    if whichLines[i + beginningOfFile - 1] ~= loadedLines[i] then
                                        print(fileName .. " was loaded from save file. To override, manually paste code into the editor.")
                                        break
                                    end
                                end
                            end
                            for i = 1, #loadedTabNames do
                                if loadedTabNames[i] == fileName then
                                    table.remove(loadedTabsToParse, i)
                                    table.remove(loadedTabNames, i)
                                    break
                                end
                            end
                            ParseFile(loadedLines, 1, #loadedLines, false, false, true)
                            return
                        end
                    elseif find(lines[k], "@require") then
                        local requireString = lines[k]:match("@require(.+)")
                        if requireString then
                            local pos
                            local startPos = 1
                            repeat
                                pos = requireString:find(",", startPos)
                                if pos then
                                    requirements[#requirements + 1] = requireString:sub(startPos, pos - 1):gsub("^%s*", ""):gsub("%s*$", "")
                                    if requirements[#requirements]:sub(1, 1) == "\"" or requirements[#requirements]:sub(1, 1) == "'" then
                                        requirements[#requirements] = requirements[#requirements]:sub(2, -2)
                                    end
                                    if requirements[#requirements]:sub(-1) == "?" then
                                        requirements[#requirements] = requirements[#requirements]:sub(1, -2)
                                        requirementIsOptional[#requirementIsOptional + 1] = true
                                    else
                                        requirementIsOptional[#requirementIsOptional + 1] = false
                                    end
                                    startPos = pos + 1
                                end
                            until not pos
                            requirements[#requirements + 1] = requireString:sub(startPos):gsub("^%s*", ""):gsub("$%s*", "")
                            if requirements[#requirements]:sub(1, 1) == "\"" or requirements[#requirements]:sub(1, 1) == "'" then
                                requirements[#requirements] = requirements[#requirements]:sub(2, -2)
                            end
                            if requirements[#requirements]:sub(-1) == "?" then
                                requirements[#requirements] = requirements[#requirements]:sub(1, -2)
                                requirementIsOptional[#requirementIsOptional + 1] = true
                            else
                                requirementIsOptional[#requirementIsOptional + 1] = false
                            end
                        end
                    elseif find(lines[k], "@version") then
                        local newVersion = match(lines[k], "@version%s*([%w%.]+)%s*$")
                        if versionOfFile[fileName] then
                            local currentVersion = versionOfFile[fileName]

                            local __, dotsCurrent = currentVersion:gsub("%.", "")
                            local __, dotsNew = newVersion:gsub("%.", "")
                            for __ = dotsCurrent, dotsNew - 1 do
                                currentVersion = currentVersion .. ".0"
                            end
                            for __ = dotsNew, dotsCurrent - 1 do
                                newVersion = newVersion .. ".0"
                            end

                            local currentVersionConverted = currentVersion:gsub("(%d%d)%.", "%1"):gsub("(%d)%.", "0%1")
                            local newVersionConverted = newVersion:gsub("(%d%d)%.", "%1"):gsub("(%d)%.", "0%1")

                            overrideVersion = tonumber(newVersionConverted) > tonumber(currentVersionConverted)
                        end
                        versionOfFile[fileName] = newVersion
                    elseif checkForExecute and find(lines[k], "@execute") then
                        executeScript = true
                    end
                end
                if atSign and not compiler.RELEASE_VERSION then
                    local hasToken = find(lines[k], "@debug") ~= nil
                    debugthis = debugthis or hasToken or inGuiTrigger and find(lines[k], "udg_wsdebug = true")  ~= nil
                    if hasToken then
                        tabs.wasPulledFromDebugToken[fileName] = true
                    end
                    if (debugthis or transpilethis) and (find(lines[k], "nodebug") and (find(lines[k], "@nodebug") or find(lines[k], "udg_wsnodebug = true"))) then
                        addthis = debugthis
                        debugthis = false
                        transpilethis = false
                        donotdebugthis = true
                    end
                    transpilethis = not donotdebugthis and (transpilethis or find(lines[k], "transpile") ~= nil and (find(lines[k], "@transpile") or find(lines[k], "udg_wstranspile = true")))
                    storethis = storethis or find(lines[k], "@store") ~= nil
                end
                k = k + 1
            end

            if checkForExecute and not executeScript then
                requirementTable[#requirementTable] = nil
                requirementIsOptionalTable[#requirementIsOptionalTable] = nil
                return
            end

            if existingFiles[fileName] then
                if not versionOfFile[fileName] then
                    print("|cffff0000Warning:|r Multiple files exist with the file name " .. fileName .. ". Second occurrence was ignored.")
                    fileName = "@" .. fileName
                    lines = {}
                elseif not overrideVersion then
                    fileName = "@" .. fileName .. versionOfFile[fileName]
                    lines = {}
                else
                    for i = #files, 1, -1 do
                        if fileNames[i] == fileName then
                            fileNames[i] = "overwrittenBy" .. fileName .. versionOfFile[fileName]
                            files[i] = {}
                        end
                    end
                end
            end

            files[#files + 1] = lines
            fileNames[#files] = fileName
            if not checkForExecute then
                existingFiles[fileName] = #files
            end
            add[#files] = addthis
            debug[#files] = debugthis
            store[#files] = storethis
            transpile[#files] = transpilethis

            local fourSpaces = "    "
            if autoIndent then
                for i = 1, #lines do
                    lines[i] = match(lines[i], "^%s*(.*)") --remove eventual indentation
                end
                local level = 0

                for i = 1, #lines do
                    if find(lines[i], "%f[%a_]end%s*$") ~= nil
                    or find(lines[i], "%f[%a_]until%s*") ~= nil then
                        level = level - 1
                    end
                    if find(lines[i], "%s*else%*") ~= nil or find(lines[i], "%s*elseif[%s%(]") ~= nil then
                        for __ = 1, level - 1 do
                            lines[i] = fourSpaces .. lines[i]
                        end
                    else
                        for __ = 1, level do
                            lines[i] = fourSpaces .. lines[i]
                        end
                    end
                    if find(lines[i], "%f[%a_]for[%s%(]") ~= nil
                    or find(lines[i], "%f[%a_]do%f[^%w_]") ~= nil
                    or find(lines[i], "%f[%a_]if[%s%(]") ~= nil
                    or find(lines[i], "%f[%a_]function%f[%s%(]") then
                        level = level + 1
                    end
                end
            end
        end

        ----------------------------------------------------------------------
        --Separate Scripts
        ----------------------------------------------------------------------

        newLines[#newLines + 1] = ""

        local size = #newLines

        local thisFileName

        for i = 1, size do
            if find(newLines[i], "beginFile") and (find(newLines[i], "Debug.beginFile%s*[\"'%(][^%)]") or find(newLines[i], "@beginFile")) then
                thisFileName = newLines[i]:match("Debug%.beginFile%s*%(?%s*[\"']([^\"']+)[\"']") or newLines[i]:match("@beginFile%s*\"(.+)\"") or newLines[i]:match("@beginFile%s*'(.+)'")
                if not thisFileName then
                        thisFileName = newLines[i]:match("@beginFile%s*(.+)")
                        if thisFileName then
                        thisFileName = thisFileName:gsub("\\", "\\\\")
                        end
                end
                if thisFileName then
                    if beginningOfFile <= i - 1 then
                        if fileName == "anonymous" then
                            anonymousCounter = anonymousCounter + 1
                            fileName = "anonymous" .. anonymousCounter
                        end
                        ParseFile(newLines, beginningOfFile, i - 1, false, false, false)
                    end
                    beginningOfFile = i
                    fileName = thisFileName
                end
                inGuiTrigger = false
            elseif find(newLines[i], "endFile") and (find(newLines[i], "Debug.endFile%s*%(%s*%)") or find(newLines[i], "@endFile")) or i == size then
                ParseFile(newLines, beginningOfFile, i, false, false, false)
                beginningOfFile = i + 1
                fileName = "anonymous"
                inGuiTrigger = false
            elseif compiler.PARSE_GUI_TRIGGERS and find(newLines[i], "function Trig_") then
                local newFileName = match(newLines[i], 'function Trig_([%w_]+)_Actions') or match(newLines[i], 'function Trig_([%w_]+)_Conditions') or match(newLines[i], 'function Trig_([%w_]+)_Func')
                if newFileName then
                    newFileName = newFileName:gsub("_", " ")
                    if newFileName ~= fileName then
                        if beginningOfFile <= i - 1 then
                            if fileName == "anonymous" then
                                anonymousCounter = anonymousCounter + 1
                                fileName = "anonymous" .. anonymousCounter
                            end
                            ParseFile(newLines, beginningOfFile, i - 1, true, false, false)
                        end
                        beginningOfFile = i
                        fileName = newFileName
                        inGuiTrigger = true
                    end
                end
            end
        end

        ----------------------------------------------------------------------
        --Handle scripts that only exist as save files
        ----------------------------------------------------------------------

        if FileIO and compiler.ENABLE_QUICK_RESTART and init.loadTabs then
            for fileName, __ in next, init.loadTabs do
                if not existingFiles[fileName] then
                    local code = FileIO.Load(editor.EXPORT_SUBFOLDER .. "\\WSCodeLoadFile" .. fileName:gsub(" ", "") .. ".txt")
                    if code then
                        loadedTabsToParse[#loadedTabsToParse + 1] = code
                        loadedTabNames[#loadedTabNames + 1] = fileName
                        tabWasStored[fileName] = true
                    end
                end
            end
        end

        local loadedLines
        for i = 1, #loadedTabsToParse do
            loadedLines = WSCode.ConvertStringToLines(loadedTabsToParse[i])
            for j = 1, #loadedLines do
                loadedLines[j] = loadedLines[j]:gsub("\t", "    ")
            end
            fileName = loadedTabNames[i]
            if not existingFiles[fileName] then
                StoreCode(fileName, loadedLines)
                ParseFile(loadedLines, 1, #loadedLines, false, true, true)
            end
        end

        ----------------------------------------------------------------------
        --Execute Scripts
        ----------------------------------------------------------------------

        local function ExecuteScript()
            local completedFunctions = {}
            local skip, noFunctionWasInitialized, everyFunctionWasInitialized

            if compiler.FINALIZE_MAP_SCRIPT then
                WSCode.SaveString = {}
            end

            repeat
                noFunctionWasInitialized = true
                everyFunctionWasInitialized = true
                for i = 1, #files do
                    if not completedFunctions[fileNames[i]] then
                        for j = 1, #files[i] do
                            if find(files[i][j], "^%s*$") == nil then
                                skip = false
                                for k = 1, #requirementTable[i] do
                                    if not completedFunctions[requirementTable[i][k]] and (not requirementIsOptionalTable[i][k] or existingFiles[requirementTable[i][k]]) then
                                        skip = true
                                        break
                                    end
                                end
                                if not skip then
                                    if compiler.FINALIZE_MAP_SCRIPT then
                                        for k = 1, #files[i] do
                                            WSCode.SaveString[#WSCode.SaveString + 1] = files[i][k]
                                        end
                                    end
                                    init.currentFunctionName = fileNames[i]
                                    if diagnostics.INIT_DUMP then
                                        PreloadGenClear()
                                        PreloadGenStart()
                                        Preload(fileNames[i])
                                        PreloadGenEnd(editor.EXPORT_SUBFOLDER .. "\\WSCodeInitDump.txt")
                                    end
                                    if store[i] then
                                        if not tabWasStored[fileNames[i]] then
                                            StoreCode(fileNames[i], files[i])
                                        end
                                        init.hasCode = true
                                    elseif debug[i] then
                                        if not tabWasStored[fileNames[i]] then
                                            StoreCode(fileNames[i], files[i])
                                        end
                                        init.hasCode = true
                                        CompileFunction(files[i], {
                                            tab = fileNames[i],
                                            parse = FUNCTION_PREVIEW ~= nil,
                                            duringInit = true,
                                            debugMode = true
                                        })
                                    elseif transpile[i] then
                                        CompileFunction(files[i], {
                                            tab = fileNames[i],
                                            parse = FUNCTION_PREVIEW ~= nil,
                                            duringInit = true,
                                            debugMode = true
                                        })
                                    else
                                        if add[i] and not tabWasStored[fileNames[i]] then
                                            StoreCode(fileNames[i], files[i])
                                        end
                                        CompileFunction(files[i], {
                                            tab = fileNames[i],
                                            parse = FUNCTION_PREVIEW ~= nil,
                                            duringInit = true
                                        })
                                    end

                                    completedFunctions[fileNames[i]] = true
                                    noFunctionWasInitialized = false
                                else
                                    everyFunctionWasInitialized = false
                                end
                                break
                            else
                                completedFunctions[fileNames[i]] = true
                            end
                        end
                    end
                    variableViewer.numVisibleVarsTotal = 0
                    variableViewer.numVisibleVarsScreen = 0
                end
            until noFunctionWasInitialized or everyFunctionWasInitialized

            if noFunctionWasInitialized and not everyFunctionWasInitialized then
                local missingFunctionString = ""
                local first = true
                for i = 1, #fileNames do
                    if not completedFunctions[fileNames[i]] and fileNames[i] ~= "anonymous" then
                        if not first then
                            missingFunctionString = missingFunctionString .. ", "
                        else
                            first = false
                        end
                        missingFunctionString = missingFunctionString .. fileNames[i]
                        local firstReq = true
                        for __, requirement in ipairs(requirementTable[i]) do
                            if not completedFunctions[requirement] then
                                if firstReq then
                                    missingFunctionString = missingFunctionString .. " (missing "
                                    firstReq = false
                                else
                                    missingFunctionString = missingFunctionString .. ", "
                                end
                                missingFunctionString = missingFunctionString .. requirement
                            end
                        end
                        if not firstReq then
                            missingFunctionString = missingFunctionString .. ")"
                        end
                    end
                end
                if Debug then
                    Debug.throwError("Initialization failed: There may be circular or missing dependencies. Failed functions: " .. missingFunctionString .. ".")
                end
            end

            if diagnostics.INIT_DUMP then
                PreloadGenClear()
                PreloadGenStart()
                Preload("Init successful.")
                PreloadGenEnd(editor.EXPORT_SUBFOLDER .. "\\WSCodeInitDump.txt")
            end

            orderedFileNames = table.pack(table.unpack(fileNames))
            table.sort(orderedFileNames)

            for i = 1, #variableViewer.frames do
                variableViewer.frames[i] = nil
            end

            if init.suspended then
                init.suspended = false
                if not init.completed.main then
                    ExecuteInitList("main")
                end
                if not init.completed.global then
                    ExecuteInitList("global")
                end
                if not init.completed.trig then
                    ExecuteInitList("trig")
                end
                if not init.completed.map then
                    ExecuteInitList("map")
                end
                if not init.completed.final then
                    ExecuteInitList("final")
                end
            end
        end

        ----------------------------------------------------------------------
        --Main
        ----------------------------------------------------------------------

        local startTime
        if diagnostics.PROFILE_INIT then
            startTime = clock()
        end

        local corot = coroutine.create(ExecuteScript)
        coroutine.resume(corot)

        if diagnostics.PROFILE_INIT then
            local endTime = clock()
            init.profiler.totalTime = init.profiler.totalTime + endTime - startTime
        end

        init.inWrap = nil
    end

    WSCode = {
        ---Parses the provided code, searching for function definitions to generate function previews, then executes the code in chunks delimited by either Debug.beginFile or @beginFile tokens, which must be followed by the script name. Parsed scripts can be added to the editor with the Pull Script button. A script will automatically be transpiled into debug form and added to the editor if a @debug token is found anywhere in the script. Designed to read in the entire map script.
        ---@param functionBody string
        ---@param suspendExecution? boolean
        Parse = function(functionBody, suspendExecution)
            local success, err = pcall(Parse, functionBody, suspendExecution)
            if not success then
                print("|cffff5555ERROR: WSCode.Parse failed due to internal error: " .. err .. "|r")
            end
        end,

        ---Adds a breakpoint to a line in the specified tab. The script in that tab must be compiled in debug mode for the breakpoint to work.
        ---@param whichTab string
        ---@param lineNumber integer
        AddBreakPoint = function(whichTab, lineNumber)
            if not whichTab then
                if Debug then
                    Debug.throwError("Unrecognized tab name " .. whichTab .. ".")
                end
                return
            end

            lines.debugState[whichTab][lineNumber] = 2

            if BlzFrameIsVisible(codeEditorParent) and currentTab == whichTab and tabs.lineNumberOffset[currentTab] < lineNumber and tabs.lineNumberOffset[currentTab] >= lineNumber - editor.MAX_LINES_ON_SCREEN then
                local screenLine = lineNumber - tabs.lineNumberOffset[whichTab]
                BlzFrameSetTexture(BlzFrameGetChild(stopButtons[screenLine], 0), LINE_STATE_ICONS[2], 0, true)
            end
        end,

        ---Halts exeuction of the code when it reaches this line and switches to the tab it is executed in. Script must be compiled in debug mode. A breakpoint added this way cannot be disabled.
        ---@param stopCondition? boolean
        BreakHere = function(stopCondition)
            if stopCondition == false then
                return
            end

            if not coroutine.isyieldable(running()) then
                if Debug then
                    Debug.throwError("Coroutine is not yieldable.")
                end
                return
            end

            local thisTab = executionTab
            local lineNumber = lastLineNumber[thisTab]
            if thisTab == "anonymous" or not lineNumber then
                if Debug then
                    Debug.throwError("Could not identify breakpoint location.")
                end
                return
            end

            if not initialized then
                init.suspended = true
            end

            if tabIsHalted[thisTab] then
                return
            end

            if breakCondition[thisTab] and not EvaluateBreakCondition(thisTab, lineNumber) or tabs.breakNowhere[thisTab] then
                return
            end

            tabIsHalted[thisTab] = true
            doNotUpdateVariables[thisTab] = true
            if Debug then
                WSDebug.Traceback[thisTab] = Debug.traceback()
            end
            if not initialized then
                coroutineWaitingForInit = running()
                coroutine.yield()
            end

            local alreadyActive
            local tabIndex
            for j = 1, tabs.amount do
                if tabs.names[j] == thisTab then
                    alreadyActive = true
                    tabIndex = j
                    break
                end
            end

            for i = 0, 23 do
                if user then
                    break
                end
                local player = Player(i)
                for __, creator in ipairs(editor.MAP_CREATORS) do
                    if find(GetPlayerName(player), creator) and GetPlayerController(player) == MAP_CONTROL_USER and GetPlayerSlotState(player) == PLAYER_SLOT_STATE_PLAYING then
                        user = Player(i)
                        break
                    end
                end
            end

            if alreadyActive then
                EnableEditor(user)
                if currentTab ~= tabIndex then
                    WSCode.SwitchToTab(tabIndex)
                end
            else
                local found
                for i = 1, #fileNames do
                    if fileNames[i] == thisTab then
                        EnableEditor(user)
                        WSCode.Pull(thisTab)
                        found = true
                        break
                    end
                end
                if not found then
                    return
                end
            end

            currentStop[thisTab] = lineNumber

            BlzFrameSetVisible(highlights.currentLine, true)
            BlzFrameSetVisible(highlights.error, false)
            JumpWindow(currentStop[thisTab], true, currentTab ~= thisTab)
            SetCurrentLine()
            lineNumbers.lastViewed[thisTab] = nil

            if doNotUpdateVariables[thisTab] then
                print("|cffff0000Warning:|r Variables displayed in the variable viewer may not be accurate because variable tracking was frozen before this breakpoint was reached.")
            end

            UpdateVariableViewer(lineNumber)

            local aliceWasHalted
            if ALICE_Where and (ALICE_Where ~= "outsideofcycle" or editor.ALWAYS_HALT_ALICE_ON_BREAKPOINT) then
                aliceWasHalted = true
                ALICE_Halt()
            elseif ALICE and (ALICE.Where ~= "outsideofcycle" or editor.ALWAYS_HALT_ALICE_ON_BREAKPOINT) then
                aliceWasHalted = true
                ALICE.Halt()
            end

            editor.ON_BREAK(tabs.names[thisTab])

            coroutine.yield()

            editor.ON_RESUME(tabs.names[thisTab])

            tabIsHalted[thisTab] = false
            doNotUpdateVariables[thisTab] = false
            if aliceWasHalted then
                (ALICE_Resume or ALICE.Resume)()
            end
            BlzFrameSetVisible(highlights.currentLine, false)
        end,

        ---Break at every line in the specified tab. The script in that tab must be compiled in debug mode for breakpoints to work.
        ---@param whichTab string
        ---@param enable boolean
        BreakEverywhere = function(whichTab, enable)
            breakEverywhere[whichTab] = enable
        end,

        ---Shows or hides the code editor.
        ---@param enable boolean
        Show = function(enable)
            if enable then
                EnableEditor(user)
            else
                BlzFrameSetFocus(editBox, false)
                BlzFrameSetEnable(editBox, false)
                BlzFrameSetEnable(editBox, true)
                BlzFrameSetVisible(codeEditorParent, false)
            end
        end,

        ---Initializes the editor if it hasn't been initialized yet.
        Initialize = function()
            if codeEditorParent then
                return
            end
            EnableEditor(user)
            BlzFrameSetVisible(codeEditorParent, false)
        end,

        ---Returns whether the code editor has been created.
        ---@return boolean
        IsEnabled = function()
            return codeEditorParent ~= nil
        end,

        ---Returns whether the code editor is visible.
        ---@return boolean
        IsVisible = function()
            return BlzFrameIsVisible(codeEditorParent)
        end,

        ---Returns whether the code editor is expanded.
        ---@return boolean
        IsExpanded = function()
            return editor.isExpanded
        end,

        ---Returns whether the code editor is visible, and the main text window is focused, or the prompt dialog or search bar is visible.
        ---@return boolean
        IsFocused = function()
            return BlzFrameIsVisible(codeEditorParent) and (editBoxFocused or BlzFrameIsVisible(nameDialog.parent)) or BlzFrameIsVisible(searchBar.parent)
        end,

        ---Returns whether the mouse is currently hovering over the main text window.
        ---@return boolean
        IsHovered = function()
            if not BlzFrameIsVisible(codeEditorParent) then
                return false
            end

            local xs, ys = GetMouseScreenCoordinates()

            if (editor.isExpanded and xs < editor.EXPANDED_X)
            or (not editor.isExpanded and xs < editor.COLLAPSED_X)
            or ys > editor.Y_TOP + tabNavigator.HEIGHT - tabNavigator.CLICK_BOX_INSET
            or ys < editor.Y_TOP - editor.LINE_SPACING*editor.MAX_LINES_ON_SCREEN - editor.CODE_TOP_INSET - editor.CODE_BOTTOM_INSET - editor.BOTTOM_BUTTON_SIZE then
                return false
            end

            return true
        end,

        ---@param compiledCode string | string[]
        ---@param shownCode string | string[]
        ---@param whichTab string
        ---@param openTab? boolean
        ---@param switchToTab? boolean
        RunInDebugger = function(compiledCode, shownCode, whichTab, openTab, switchToTab)
            CompileFunction(compiledCode, {
                tab = whichTab,
                debugMode = true
            })
            if openTab and not WSCode.TabIsOpen(whichTab) then
                WSCode.AddTab(whichTab)
            end
            WSCode.DeleteCode(whichTab)
            StoreCode(whichTab, shownCode)
            if switchToTab then
                WSCode.SwitchToTab(whichTab)
            end
        end,

        ---Returns the user player.
        ---@return player
        GetUser = function()
            if not user then
                for i = 0, 23 do
                    if user then
                        break
                    end
                    local player = Player(i)
                    for __, creator in ipairs(editor.MAP_CREATORS) do
                        if find(GetPlayerName(player), creator) and GetPlayerController(player) == MAP_CONTROL_USER and GetPlayerSlotState(player) == PLAYER_SLOT_STATE_PLAYING then
                            user = Player(i)
                            break
                        end
                    end
                end
            end
            return user
        end,

        ---@param dialogTitle string
        ---@param lookupTable? string[]
        ---@param callback fun(enteredString: string)
        ---@param presetContent? string
        OpenDialog = function(dialogTitle, lookupTable, callback, presetContent)
            if not codeEditorParent then
                EnableEditor(user)
            end
            BlzFrameSetVisible(codeEditorParent, true)
            if editBoxFocused then
                editBoxFocused = false
                editor.ON_DEFOCUS()
            end
            BlzFrameSetFocus(editBox, false)
            BlzFrameSetEnable(editBox, false)
            BlzFrameSetEnable(editBox, true)
            BlzFrameSetVisible(cursorFrame, false)

            nameDialog.state = "custom"
            nameDialog.lookupTable = lookupTable
            nameDialog.callback = callback
            BlzFrameSetVisible(nameDialog.parent, true)
            BlzFrameSetFocus(nameDialog.textField, true)
            BlzFrameSetText(nameDialog.title, "|cffffcc00" .. dialogTitle .. "|r")
            if presetContent then
                BlzFrameSetText(nameDialog.textField, presetContent)
            else
                BlzFrameSetText(nameDialog.textField, "")
            end
        end,

        ---Creates a new button in the right-click context menu. The cursor position can be retrieved with WSCode.GetCursorPosition. Custom context buttons are inserted at the top of the context menu in the order in which they were created.
        ---@param buttonTitle string
        ---@param tooltip string
        ---@param callback function
        ---@param titleSuffix? string
        CreateContextButton = function(buttonTitle, tooltip, callback, titleSuffix)
            contextMenu.customButtons[#contextMenu.customButtons + 1] = {
                title = buttonTitle,
                tooltip = tooltip,
                callback = callback,
                titleSuffix = titleSuffix
            }
        end,

        ---Creates a horizontal line in the right-click context menu. Custom context buttons and separators are inserted at the top of the context menu in the order in which they were created.
        CreateContextSeparator = function()
            contextMenu.customButtons[#contextMenu.customButtons + 1] = "separator"
        end,

        ---Creates a new button in the WSCode bottom bar. The bottomRowPosition is the position within the bar from the left. If not set, the button will be appended on the right.
        ---@param icon string
        ---@param buttonTitle string
        ---@param tooltip string
        ---@param callback function
        ---@param bottomRowPosition integer
        ---@param initiallyHidden? boolean
        ---@param titleSuffix? string
        CreateBottomBarButton = function(icon, buttonTitle, tooltip, callback, bottomRowPosition, initiallyHidden, titleSuffix)
            buttons.customButtons[#buttons.customButtons + 1] = {
                icon = icon,
                title = buttonTitle,
                tooltip = tooltip,
                callback = callback,
                index = bottomRowPosition,
                initiallyHidden = initiallyHidden,
                titleSuffix = titleSuffix
            }
        end,

        ---Creates a new array button in the WSCode bottom bar. An array button opens a list with all available sub-buttons when pressed. All sub-button data tables are arrays where the first entry stores data for the top-most sub-button. The bottomRowPosition is the position within the bar from the left. If not set, the button will be appended on the right.
        ---@param icon string
        ---@param buttonTitle string
        ---@param buttonTooltip? string
        ---@param alignment "left" | "center" | "right"
        ---@param subButtonTitles string[] | table<"parent" | integer, string>
        ---@param subButtonTooltips? string[]
        ---@param subButtonTitleSuffixes? string[]
        ---@param callbacks function[] | function[][]
        ---@param bottomRowPosition integer
        ---@param initiallyHighlighted? table<integer, boolean>
        ---@param initiallyHidden? boolean
        ---@param width? number
        CreateBottomBarArrayButton = function(icon, buttonTitle, buttonTooltip, alignment, subButtonTitles, subButtonTooltips, subButtonTitleSuffixes, callbacks, bottomRowPosition, initiallyHighlighted, initiallyHidden, width)
            buttons.customButtons[#buttons.customButtons + 1] = {
                icon = icon,
                title = buttonTitle,
                tooltip = buttonTooltip,
                subTitles = subButtonTitles,
                subTooltips = subButtonTooltips,
                subTitleSuffixes = subButtonTitleSuffixes,
                alignment = alignment,
                callbacks = callbacks,
                isArray = true,
                index = bottomRowPosition,
                initiallyHighlighted = initiallyHighlighted,
                initiallyHidden = initiallyHidden,
                width = width
            }
        end,

        ---Changes the texture of the bottom bar button with the specified name.
        ---@param whichButton string
        ---@param newTexture string
        SetBottomBarButtonTexture = function(whichButton, newTexture)
            local parent = buttons[whichButton]
            BlzFrameSetTexture(BlzFrameGetChild(parent, 0), newTexture, 0, true)
            BlzFrameSetTexture(BlzFrameGetChild(parent, 1), newTexture, 0, true)
        end,

        ---Toggles whether the bottom bar button with the specified name is visible.
        ---@param whichButton string
        ---@param enable boolean
        ShowBottomBarButton = function(whichButton, enable)
            local parent = buttons[whichButton]
            BlzFrameSetVisible(parent, enable)
        end,

        ---Toggles whether the bottom bar button with the specified name is enabled.
        ---@param whichButton string
        ---@param enable boolean
        ---@param texture? string
        EnableBottomBarButton = function(whichButton, enable, texture)
            local parent = buttons[whichButton]
            if texture then
                BlzFrameSetTexture(BlzFrameGetChild(parent, 2), texture, 0, true)
            end
            BlzFrameSetEnable(parent, enable)
        end,

        ---Changes the position of a bottom bar button with the specified name.
        ---@param whichButton string
        ---@param newPosition integer
        MoveBottomBarButton = function(whichButton, newPosition)
            BlzFrameSetPoint(buttons[whichButton], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_BOTTOM, (newPosition - 1 - WSCodeConfig.bottomBar.MAX_BUTTONS/2)*editor.BOTTOM_BUTTON_SIZE, editor.BOTTOM_BUTTON_VERTICAL_SHIFT)
            BlzFrameSetPoint(buttons[whichButton], FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_BOTTOM, (newPosition - WSCodeConfig.bottomBar.MAX_BUTTONS/2)*editor.BOTTOM_BUTTON_SIZE, editor.BOTTOM_BUTTON_VERTICAL_SHIFT + editor.BOTTOM_BUTTON_SIZE)
        end,

        ---Adds an additional callback to the bottom bar button with the specified name.
        ---@param whichButton string
        ---@param callback function
        OnBottomBarButtonPress = function(whichButton, callback)
            buttons.triggers[whichButton] = buttons.triggers[whichButton] or {}
            buttons.triggers[whichButton][#buttons.triggers[whichButton] + 1] = callback
        end,

        ---@param pluginName string
        ---@param tooltip string
        ---@param titleSuffix? string
        ---@param visibleButtons string[]
        ---@param onEnable? function
        ---@param onDisable? function
        RegisterPlugin = function(pluginName, tooltip, titleSuffix, visibleButtons, onEnable, onDisable)
            if codeEditorParent then
                error("WSCode plugins must be registered before the editor is initialized.")
            end

            local index = #plugins.names + 1
            plugins.names[index] = pluginName
            plugins.tooltips[index] = tooltip
            plugins.titleSuffixes[index] = titleSuffix
            plugins.visibleButtons[index] = visibleButtons
            plugins.onEnable[index] = onEnable
            plugins.onDisable[index] = onDisable
        end,

        ---@param onEnable function | nil
        ---@param onDisable function | nil
        SetWSCodePluginToggleCallbacks = function(onEnable, onDisable)
            plugins.onEnable[1] = onEnable
            plugins.onDisable[1] = onDisable
        end,

        ---@param pluginName string
        SwitchToPlugin = function(pluginName)
            for i = 1, #plugins.names do
                if plugins.names[i] == pluginName then
                    plugins.callbacks[i]()
                end
            end
        end,

        ---Removes a callback that was added with WSCode.OnBottomBarButtonPress from a bottom bar button with the specified name.
        ---@param whichButton string
        ---@param callback function
        RemoveBottomBarButtonTrigger = function(whichButton, callback)
            if not buttons.triggers[whichButton] then
                return
            end
            for index, thisCallback in ipairs(buttons.triggers[whichButton]) do
                if thisCallback == callback then
                    table.remove(buttons.triggers[whichButton], index)
                    return
                end
            end
        end,

        ---Adds a callback that is executed whenever a new undo step is created within the current tab.
        ---@param callback function
        OnUndoStepCreated = function(callback)
            triggers.onUndoStepCreated[#triggers.onUndoStepCreated + 1] = callback
        end,

        ---Removes a callback that was added with WSCode.OnUndoStepCreated.
        ---@param callback function
        RemoveUndoStepCreatedTrigger = function(callback)
            for index, thisCallback in ipairs(triggers.onUndoStepCreated) do
                if thisCallback == callback then
                    table.remove(triggers.onUndoStepCreated, index)
                    return
                end
            end
        end,

        ---Toggles whether the sub-button at the specified arrayIndex for a bottom bar array button is displayed as gold (highlighted) or gray (disabled).
        ---@param buttonName string
        ---@param arrayIndex integer
        ---@param highlight boolean
        HighlightArrayButton = function(buttonName, arrayIndex, highlight)
            local buttonData
            for __, data in ipairs(buttons.customArrayButtons) do
                if data.name == buttonName then
                    buttonData = data
                end
            end
            if not buttonData then
                error("Button with the specified name does not exist.")
            end
            local arrayButtonData = buttonData[arrayIndex]
            if not arrayButtonData then
                error("Index out of bounds for array button.")
            end
            local textFrame = BlzFrameGetChild(arrayButtonData.parent, 0)
            if highlight then
                BlzFrameSetText(textFrame, "|cffffcc00" .. arrayButtonData.text .. "|r")
            else
                BlzFrameSetText(textFrame, "|cff999999" .. arrayButtonData.text .. "|r")
            end
        end,

        ---Adds an empty tab with the specified name to the editor.
        ---@param tabName string
        AddTab = function(tabName)
            if tabs.numbers[tabName] then
                return
            end

            tabs.amount = tabs.amount + 1

            tabs.names[tabs.amount] = tabName
            tabs.truncatedNames[tabName] = find(tabName, "\\\\") ~= nil and sub(tabName, match(tabName, ".*()\\\\") + 2, nil) or tabName

            tabNavigator.frames[tabName] = BlzCreateFrame("TabNavigator", codeEditorParent, 0, 0)
            tabNavigator.titles[tabName] = BlzFrameGetChild(tabNavigator.frames[tabName], 2)
            tabNavigator.highlights[tabName] = BlzFrameGetChild(tabNavigator.frames[tabName], 3)
            BlzFrameSetText(tabNavigator.titles[tabName], editor.TAB_NAVIGATOR_UNSELECTED_COLOR .. tabs.truncatedNames[tabName] .. "|r")
            BlzFrameSetSize(tabNavigator.titles[tabName], 0, 0)
            local width = BlzFrameGetWidth(tabNavigator.titles[tabName])
            tabNavigator.widths[tabName] = max(tabNavigator.WIDTH, width + 2*tabNavigator.TEXT_INSET)
            BlzFrameSetAllPoints(tabNavigator.titles[tabName], tabNavigator.frames[tabName])
            BlzFrameSetTextAlignment(tabNavigator.titles[tabName], TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
            BlzFrameSetEnable(tabNavigator.titles[tabName], false)
            BlzFrameSetSize(tabNavigator.frames[tabName], tabNavigator.widths[tabName], tabNavigator.HEIGHT)
            if tabs.amount == 1 then
                BlzFrameSetPoint(tabNavigator.frames[tabName], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, 0, tabNavigator.VERTICAL_SHIFT)
            else
                BlzFrameSetPoint(tabNavigator.frames[tabName], FRAMEPOINT_BOTTOMLEFT, tabNavigator.frames[tabs.names[tabs.amount - 1]], FRAMEPOINT_BOTTOMRIGHT, -tabNavigator.OVERLAP, 0)
            end
            BlzFrameSetAllPoints(BlzFrameGetChild(tabNavigator.frames[tabName], 1), tabNavigator.frames[tabName])
            SetFrameAlpha(BlzFrameGetChild(tabNavigator.frames[tabName], 1), editor.BLACK_BACKDROP_ALPHA)

            tabs.numbers[tabName] = tabs.amount
            tabs.numberFromFrame[tabNavigator.frames[tabs.names[tabs.amount]]] = tabs.amount

            local closeButton = BlzCreateFrame("CloseEditorButton", tabNavigator.frames[tabs.names[tabs.amount]], 0, 0)
            BlzFrameSetPoint(closeButton, FRAMEPOINT_BOTTOMLEFT, tabNavigator.frames[tabs.names[tabs.amount]], FRAMEPOINT_TOPRIGHT, -tabNavigator.CLOSE_BUTTON_INSET - tabNavigator.CLOSE_BUTTON_SIZE, -tabNavigator.CLOSE_BUTTON_INSET - tabNavigator.CLOSE_BUTTON_SIZE)
            BlzFrameSetPoint(closeButton, FRAMEPOINT_TOPRIGHT, tabNavigator.frames[tabs.names[tabs.amount]], FRAMEPOINT_TOPRIGHT, -tabNavigator.CLOSE_BUTTON_INSET, -tabNavigator.CLOSE_BUTTON_INSET)
            local icon = BlzFrameGetChild(closeButton, 0)
            local iconClicked = BlzFrameGetChild(closeButton, 1)
            local iconHighlight = BlzFrameGetChild(closeButton, 2)
            BlzFrameSetAllPoints(icon, closeButton)
            BlzFrameSetTexture(icon, editor.ASSET_SUBFOLDER .. "\\closeEditor.blp", 0, true)
            BlzFrameSetTexture(iconClicked, editor.ASSET_SUBFOLDER .. "\\closeEditor.blp", 0, true)
            BlzFrameClearAllPoints(iconHighlight)
            BlzFrameSetPoint(iconHighlight, FRAMEPOINT_BOTTOMLEFT, closeButton, FRAMEPOINT_BOTTOMLEFT, 0.00375, 0.00375)
            BlzFrameSetPoint(iconHighlight, FRAMEPOINT_TOPRIGHT, closeButton, FRAMEPOINT_TOPRIGHT, -0.00375, -0.00375)
            BlzFrameSetVisible(closeButton, false)
            local trig = CreateTrigger()
            BlzTriggerRegisterFrameEvent(trig, closeButton, FRAMEEVENT_CONTROL_CLICK)
            TriggerAddAction(trig, WSCode.CloseTab)
            tabs.numberFromFrame[closeButton] = tabs.amount
            tabNavigator.closeButtons[tabs.names[tabs.amount]] = closeButton

            AdjustTabWidths()

            trig = CreateTrigger()
            BlzTriggerRegisterFrameEvent(trig, tabNavigator.frames[tabs.names[tabs.amount]], FRAMEEVENT_CONTROL_CLICK)
            TriggerAddAction(trig, ClickTabButton)

            BlzFrameSetPoint(tabs.addTabFrame, FRAMEPOINT_BOTTOMLEFT, tabNavigator.frames[tabs.names[tabs.amount]], FRAMEPOINT_BOTTOMRIGHT, -tabNavigator.OVERLAP, 0)

            SaveTabs()
        end,

        ---Switches the main window to the specified tab.
        ---@param whichTab integer | string
        SwitchToTab = function(whichTab)
            whichTab = type(whichTab) == "number" and tabs.names[whichTab] or whichTab

            if not tabNavigator.frames[whichTab] then
                return
            end

            if selection.hasSelection then
                HideSelection()
            end

            SetFrameAlpha(tabNavigator.highlights[currentTab], 255)
            local color = tabs.wasNotCompiledInDebugMode[currentTab] and editor.TAB_NAVIGATOR_UNSELECTED_NO_DEBUG_COLOR or editor.TAB_NAVIGATOR_UNSELECTED_COLOR
            BlzFrameSetText(tabNavigator.titles[currentTab], color .. tabs.truncatedNames[currentTab] .. "|r")
            if tabs.hasUnsavedChanges[currentTab] and editor.ENABLE_SAVE_AND_LOAD and FileIO then
                Export()
            end

            local oldTab = currentTab
            currentTab = whichTab
            color = tabs.wasNotCompiledInDebugMode[currentTab] and editor.TAB_NAVIGATOR_SELECTED_NO_DEBUG_COLOR or editor.TAB_NAVIGATOR_SELECTED_COLOR
            BlzFrameSetText(tabNavigator.titles[currentTab], color .. tabs.truncatedNames[currentTab] .. "|r")

            BlzFrameSetMinMaxValue(codeScroller, 0, highestNonEmptyLine[currentTab][step[currentTab]])
            SetLineOffset(tabs.lineNumberOffset[currentTab])

            UpdateAllLines()
            if BlzFrameIsVisible(searchBar.parent) then
                FindSearchItems()
                RenderSearchHighlights()
            end

            BlzFrameSetEnable(buttons["Redo"], step[currentTab] < edit.maxRedo[currentTab])
            BlzFrameSetEnable(buttons["Undo"], step[currentTab] > 1)

            if tabIsHalted[whichTab] then
                BlzFrameSetVisible(highlights.currentLine, true)
                BlzFrameSetEnable(buttons["Traceback"], true)
                SetCurrentLine()
            else
                BlzFrameSetVisible(highlights.currentLine, false)
                BlzFrameSetEnable(buttons["Traceback"], false)
            end

            if tabs.hasError[currentTab] then
                BlzFrameSetPoint(highlights.error, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET, -editor.CODE_TOP_INSET - editor.LINE_SPACING*(lineNumbers.error[currentTab] - tabs.lineNumberOffset[currentTab]))
                BlzFrameSetPoint(highlights.error, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPRIGHT, -editor.CODE_RIGHT_INSET, -editor.CODE_TOP_INSET - editor.LINE_SPACING*(lineNumbers.error[currentTab] - tabs.lineNumberOffset[currentTab] - 1))
            end
            BlzFrameSetVisible(highlights.error, tabs.hasError[currentTab] and lineNumbers.error[currentTab] - tabs.lineNumberOffset[currentTab] >= 1 and lineNumbers.error[currentTab] - tabs.lineNumberOffset[currentTab] <= editor.MAX_LINES_ON_SCREEN)

            if highlights.custom.frame and not highlights.custom[currentTab] then
                BlzFrameSetVisible(highlights.custom.frame, false)
            end

            for i = 1, editor.MAX_LINES_ON_SCREEN do
                if lineNumberWasExecuted[currentTab][i + tabs.lineNumberOffset[currentTab]] then
                    BlzFrameSetText(lineNumberFrames[i], editor.LINE_NUMBER_COLOR .. math.tointeger(i + tabs.lineNumberOffset[currentTab]) .. "|r")
                else
                    BlzFrameSetText(lineNumberFrames[i], editor.IDLE_LINE_NUMBER_COLOR .. math.tointeger(i + tabs.lineNumberOffset[currentTab]) .. "|r")
                end
                if lines.debugState[currentTab][i + tabs.lineNumberOffset[currentTab]] ~= lines.debugState[oldTab][i + tabs.lineNumberOffset[oldTab]] then
                    BlzFrameSetTexture(BlzFrameGetChild(stopButtons[i], 0), LINE_STATE_ICONS[lines.debugState[currentTab][i + tabs.lineNumberOffset[currentTab]]], 0, true)
                end
            end

            BlzFrameSetVisible(variableViewer.parent, not tabs.wasNotCompiledInDebugMode[currentTab])
            if variableViewer.isExpanded then
                variableViewer.forceScrollerUpdate = true
                UpdateVariableViewer(lineNumbers.lastViewed[currentTab] or lastLineNumber[currentTab], true)
            end

            BlzFrameSetValue(codeHorizontalScroller, tabs.horizontalOffset[currentTab])
            selection.hasSelection = false

            CheckLongestLineLength()
            AdjustHorizontalLineScroller()

            ConvertAndValidateLines(codeLines[currentTab][step[currentTab]], currentTab)
        end,

        ---Closes the specified tab and removes it from the editor.
        ---@param tabIndexOrName integer | string
        CloseTab = function(tabIndexOrName)
            local index = type(tabIndexOrName) == "number" and tabIndexOrName or type(tabIndexOrName) == "string" and tabs.numbers[tabIndexOrName] or tabs.numberFromFrame[BlzGetTriggerFrame()]
            local tabName = tabs.names[index]

            BlzFrameSetVisible(tabNavigator.frames[tabName], false)

            if index == tabs.amount then
                BlzFrameSetPoint(tabs.addTabFrame, FRAMEPOINT_BOTTOMLEFT, tabNavigator.frames[tabs.names[index - 1]], FRAMEPOINT_BOTTOMRIGHT, -tabNavigator.OVERLAP, 0)
            elseif index == 1 then
                BlzFrameSetPoint(tabNavigator.frames[tabs.names[index + 1]], FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, 0, tabNavigator.VERTICAL_SHIFT)
            else
                BlzFrameSetPoint(tabNavigator.frames[tabs.names[index + 1]], FRAMEPOINT_BOTTOMLEFT, tabNavigator.frames[tabs.names[index - 1]], FRAMEPOINT_BOTTOMRIGHT, -tabNavigator.OVERLAP, 0)
            end

            for i = index + 1, tabs.amount do
                tabs.numbers[tabs.names[i]] = i - 1
                tabs.numberFromFrame[tabNavigator.frames[tabs.names[i]]] = i - 1
                tabs.numberFromFrame[tabNavigator.closeButtons[tabs.names[i]]] = i - 1
                tabs.names[i - 1] = tabs.names[i]
            end

            local currentLines = codeLines[tabName][step[tabName]]
            for i = 1, highestNonEmptyLine[tabName][step[tabName]] do
                currentLines[i] = ""
                coloredCodeLines[tabName][step[tabName]][i] = nil
            end
            highestNonEmptyLine[tabName][step[tabName]] = 0

            tabs.names[tabs.amount] = nil
            tabs.numbers[tabName] = nil

            tabs.hasError[tabName] = nil
            doNotUpdateVariables[tabName] = nil
            tabIsHalted[tabName] = nil

            if tabs.amount == 1 then
                tabs.amount = tabs.amount - 1
                WSCode.AddTab("Main")
                WSCode.SwitchToTab("Main")
            else
                if currentTab == tabName then
                    if index == tabs.amount then
                        WSCode.SwitchToTab(tabs.names[index - 1])
                    else
                        WSCode.SwitchToTab(tabs.names[index])
                    end
                end
                tabs.amount = tabs.amount - 1

                AdjustTabWidths()
            end

            SaveTabs()
        end,

        ---Returns whether a tab with the specified name currently exists within the editor.
        ---@param tabName string
        ---@return boolean
        TabIsOpen = function(tabName)
            return tabs.numbers[tabName] ~= nil
        end,

        ---Pulls a script file with the specified name from the parsed map script and stores it within a tab of the same name.
        ---@param fileName string
        Pull = function(fileName)
            for i = 1, #fileNames do
                if fileNames[i] == fileName then
                    if not existingFiles[fileName] then
                        WSDebug.PrintForUser("|cffff5555ERROR: " .. fileName .. " does not appear to be part of the regular map script, but may exist as a backup file.|r")
                        return false
                    end
                    tabs.wasPulledFromDebugToken[fileName] = nil
                    StoreCode(fileName, files[i])
                    return true
                end
            end
            WSDebug.PrintForUser("|cffff5555ERROR: No file found with the name " .. fileName .. ".|r")
            return false
        end,

        ---Loads a backup file with the specified name from the CustomMapData folder and stores it within a tab of the same name.
        ---@param fileName string
        LoadBackupFile = function(fileName)
            local str = FileIO.Load(editor.EXPORT_SUBFOLDER .. "\\WSCodeLoadFile" .. fileName:gsub(" ", "") .. ".txt")
            if not str then
                WSDebug.PrintForUser("|cffff5555ERROR: No file found at path " .. editor.EXPORT_SUBFOLDER .. "\\WSCodeLoadFile" .. fileName:gsub(" ", "") .. ".|r")
                return
            end

            tabs.wasPulledFromDebugToken[fileName] = nil
            StoreCode(fileName, str)
            WSCode.SwitchToTab(fileName)
        end,

        ---Deletes all code within the specified tab or the current tab if it is not specified.
        ---@param whichTab? string
        DeleteCode = function(whichTab)
            whichTab = whichTab or currentTab
            WSCode.IncrementStep(whichTab)
            local currentLines = codeLines[whichTab][step[whichTab]]
            local currentColoredLines = coloredCodeLines[whichTab][step[whichTab]]
            for i = 1, highestNonEmptyLine[whichTab][step[whichTab]] do
                currentLines[i] = ""
                currentColoredLines[i] = nil
            end
            highestNonEmptyLine[whichTab][step[whichTab]] = 0
            if whichTab == currentTab then
                UpdateAllLines()
                SetLineOffset(0)
            end
        end,

        ---Clears all breakpoints within the specified tab or the current tab if it is not specified.
        ---@param whichTab? string
        ClearBreakpoints = function(whichTab)
            whichTab = whichTab or currentTab
            for i = 1, highestNonEmptyLine[whichTab][step[whichTab]] do
                if lines.debugState[whichTab][i] ~= 0 then
                    lines.debugState[whichTab][i] = 0
                    if whichTab == currentTab then
                        BlzFrameSetTexture(BlzFrameGetChild(stopButtons[i - tabs.lineNumberOffset[whichTab]], 0), LINE_STATE_ICONS[0], 0, true)
                    end
                end
            end
        end,

        ---Destroys all handles created within the specified tab or the current tab if it is not specified.
        ---@param whichTab string
        DestroyHandles = function(whichTab)
            whichTab = whichTab or currentTab
            for handle, creator in next, handles[whichTab] do
                _ENV[CREATOR_DESTRUCTOR_PAIRS[creator]](handle)
                handles[whichTab][handle] = nil
            end
        end,

        ---Resets all linenumber highlights within the specified tab or the current tab if it is not specified.
        ---@param whichTab string
        ResetLineHighlights = function(whichTab)
            whichTab = whichTab or currentTab
            for i = 1, highestNonEmptyLine[whichTab][step[whichTab]] do
                lineNumberWasExecuted[whichTab][i] = nil
            end
            if whichTab == currentTab then
                for i = 1, editor.MAX_LINES_ON_SCREEN do
                    BlzFrameSetText(lineNumberFrames[i], editor.IDLE_LINE_NUMBER_COLOR .. math.tointeger(i + tabs.lineNumberOffset[whichTab]) .. "|r")
                end
            end
        end,

        ---Closes all tabs currently active in the editors.
        CloseAllTabs = function()
            for i = tabs.amount, 1, -1 do
                WSCode.CloseTab(i)
            end
        end,

        ---Undo the last edit in the current tab.
        Undo = function()
            if step[currentTab] == 1 then
                BlzFrameSetEnable(buttons["Undo"], false)
                return
            end
            BlzFrameSetEnable(buttons["Undo"], false)
            BlzFrameSetEnable(buttons["Undo"], true)
            BlzFrameSetVisible(variableViewer.parent, false)
            BlzFrameSetVisible(highlights.error, false)
            tabs.hasError[currentTab] = false
            doNotUpdateVariables[currentTab] = false
            tabs.hasUnsavedChanges[currentTab] = true
            edit.lastKeyStroke = timeElapsed
            cursor.posOfLineJumps = nil
            if editor.ENABLE_SAVE_AND_LOAD and FileIO then
                BlzFrameSetText(tabNavigator.titles[currentTab], editor.TAB_NAVIGATOR_UNSAVED_COLOR .. "*" .. tabs.truncatedNames[currentTab] .. "|r")
            end

            if step[currentTab] > 1 then
                step[currentTab] = step[currentTab] - 1
                UpdateAllLines()
                BlzFrameSetEnable(buttons["Redo"], true)
                if step[currentTab] == 1 then
                    BlzFrameSetEnable(buttons["Undo"], false)
                end

                BlzFrameSetMinMaxValue(codeScroller, 0, highestNonEmptyLine[currentTab][step[currentTab]])
            end

            SetLineOffset(tabs.lineNumberOffset[currentTab])
            JumpWindow(edit.lineNumber[currentTab][step[currentTab] + 1])

            cursor.codeLineNumber = edit.lineNumber[currentTab][step[currentTab] + 1]
            SetCursorPos(edit.pos[currentTab][step[currentTab] + 1])
            cursor.screenLineNumber = cursor.codeLineNumber - tabs.lineNumberOffset[currentTab]
            SetCursorX(sub(codeLines[currentTab][step[currentTab]][cursor.codeLineNumber], tabs.horizontalOffset[currentTab] + 1))
            if not editor.isLocked then
                BlzFrameSetFocus(editBox, true)
                if not editBoxFocused then
                    editBoxFocused = true
                    editor.ON_FOCUS()
                end
                BlzFrameSetVisible(cursorFrame, true)
            end
        end,

        ---Redo the last edit in the current tab.
        Redo = function()
            if step[currentTab] == edit.maxRedo[currentTab] then
                BlzFrameSetEnable(buttons["Redo"], false)
                return
            end
            BlzFrameSetEnable(buttons["Redo"], false)
            BlzFrameSetEnable(buttons["Redo"], true)
            BlzFrameSetVisible(variableViewer.parent, false)
            BlzFrameSetVisible(highlights.error, false)
            tabs.hasError[currentTab] = false
            doNotUpdateVariables[currentTab] = false
            tabs.hasUnsavedChanges[currentTab] = true
            edit.lastKeyStroke = timeElapsed
            cursor.posOfLineJumps = nil
            if editor.ENABLE_SAVE_AND_LOAD and FileIO then
                BlzFrameSetText(tabNavigator.titles[currentTab], editor.TAB_NAVIGATOR_UNSAVED_COLOR .. "*" .. tabs.truncatedNames[currentTab] .. "|r")
            end

            if step[currentTab] < edit.maxRedo[currentTab] then
                step[currentTab] = step[currentTab] + 1
                UpdateAllLines()
                if step[currentTab] == edit.maxRedo[currentTab] then
                    BlzFrameSetEnable(buttons["Redo"], false)
                end
                BlzFrameSetEnable(buttons["Undo"], true)
                BlzFrameSetMinMaxValue(codeScroller, 0, highestNonEmptyLine[currentTab][step[currentTab]])
            end

            SetLineOffset(tabs.lineNumberOffset[currentTab])
            JumpWindow(edit.lineNumber[currentTab][step[currentTab]])

            cursor.codeLineNumber = edit.lineNumber[currentTab][step[currentTab]]
            SetCursorPos(edit.pos[currentTab][step[currentTab]])
            cursor.screenLineNumber = cursor.codeLineNumber - tabs.lineNumberOffset[currentTab]
            SetCursorX(sub(codeLines[currentTab][step[currentTab]][cursor.codeLineNumber], tabs.horizontalOffset[currentTab] + 1))
            if not editor.isLocked then
                BlzFrameSetFocus(editBox, true)
                if not editBoxFocused then
                    editBoxFocused = true
                    editor.ON_FOCUS()
                end
                BlzFrameSetVisible(cursorFrame, true)
            end
        end,

        ---Creates an undo step within the specified tab or the current tab if it is not specified.
        ---@param whichTab? string
        IncrementStep = function(whichTab)
            whichTab = whichTab or currentTab
            step[whichTab] = step[whichTab] + 1
            local lastLines = codeLines[whichTab][step[whichTab] - 1]
            local currentLines = codeLines[whichTab][step[whichTab]]

            for i = 1, highestNonEmptyLine[whichTab][step[whichTab] - 1] do
                currentLines[i] = lastLines[i]
                coloredCodeLines[whichTab][step[whichTab]][i] = coloredCodeLines[whichTab][step[whichTab] - 1][i]
            end
            for i = highestNonEmptyLine[whichTab][step[whichTab] - 1] + 1, highestNonEmptyLine[whichTab][step[whichTab]] do
                currentLines[i] = ""
                coloredCodeLines[whichTab][step[whichTab]][i] = nil
            end

            highestNonEmptyLine[whichTab][step[whichTab]] = highestNonEmptyLine[whichTab][step[whichTab] - 1]
            if whichTab == currentTab then
                BlzFrameSetVisible(highlights.currentLine, false)
                BlzFrameSetVisible(highlights.error, false)
            end

            lineNumbers.lastViewed[whichTab] = nil
            cursor.posOfLineJumps = nil

            BlzFrameSetEnable(buttons["Undo"], true)
            BlzFrameSetEnable(buttons["Redo"], false)

            edit.maxRedo[whichTab] = step[whichTab]
            edit.lineNumber[whichTab][step[whichTab]] = cursor.codeLineNumber or 1
            edit.pos[whichTab][step[whichTab]] = cursor.pos

            for i = 1, highestNonEmptyLine[whichTab][step[whichTab]] do
                if lineNumberWasExecuted[whichTab][i] then
                    lineNumberWasExecuted[whichTab][i] = nil
                    local screenLineNumberNumber = math.tointeger(i - tabs.lineNumberOffset[whichTab])
                    if whichTab == currentTab and screenLineNumberNumber >= 1 and screenLineNumberNumber <= editor.MAX_LINES_ON_SCREEN then
                        BlzFrameSetText(lineNumberFrames[screenLineNumberNumber], editor.IDLE_LINE_NUMBER_COLOR .. i .. "|r")
                    end
                end
            end
        end,

        ---While stepping through code, execute the next line and break.
        ExecuteNextLine = function()
            lineByLine = true
            Continue()
        end,

        ---While stepping through code, continue executing until the next breakpoint.
        ContinueExecuting = function()
            lineByLine = false
            Continue()
        end,

        ---Returns the currently opened tab.
        ---@return string
        GetCurrentTab = function()
            return currentTab
        end,

        ---Returns, as a line array, the code within the specified tab or the current tab if it is not specified. The contents of the returned table should not be altered. Instead, use WSCode.EditLine or WSCode.SetTabContent to edit the existing code.
        ---@param whichTab? string
        ---@return string[]
        GetCodeInTab = function(whichTab)
            whichTab = whichTab or currentTab
            if not codeLines[whichTab] then
                return {}
            end
            return codeLines[whichTab][step[whichTab]]
        end,

        ---Returns whether the specified tab is empty or the current tab if it is not specified.
        ---@param whichTab? string
        ---@return boolean
        IsTabEmpty = function(whichTab)
            whichTab = whichTab or currentTab
            for i = 1, highestNonEmptyLine[whichTab][step[whichTab]] do
                if not find(codeLines[whichTab][step[whichTab]][i], "^%s*$") then
                    return false
                end
            end
            return true
        end,

        ---Returns the value or content of the variable currently viewed in the variable viewer.
        ---@return any
        GetViewedVariableValue = function()
            local value = variableViewer.viewedValueTrace[#variableViewer.viewedValueTrace]
            return value == WSDebug.Nil and nil or value
        end,

        ---Returns the content of the current selection as a line array. Returns nil if there is no selection.
        ---@return string[]|nil
        GetSelection = function()
            if selection.hasSelection then
                return ConvertSelectionToLines()
            end
            return nil
        end,

        ---Returns the current line number and the current position within that line of the cursor. Returns nil if the editor has not yet been focused.
        ---@return integer|nil, integer|nil
        GetCursorPosition = function()
            return cursor.codeLineNumber, cursor.pos
        end,

        ---Sets the cursor position to the specified line number and to the specified position within that line. Moves the cursor to the end of the line if whichPosition is not specified.
        ---@param whichLine integer
        ---@param whichPosition? integer
        SetCursorPosition = function(whichLine, whichPosition)
            cursor.codeLineNumber = whichLine
            cursor.screenLineNumber = cursor.codeLineNumber - tabs.lineNumberOffset[currentTab]
            if whichPosition then
                cursor.pos = min(whichPosition, #codeLines[currentTab][step[currentTab]][whichLine] or 0)
            else
                cursor.pos = #codeLines[currentTab][step[currentTab]][whichLine] or 0
            end
            SetCursorPos(cursor.pos)
            SetCursorX(sub(codeLines[currentTab][step[currentTab]][whichLine], tabs.horizontalOffset[currentTab] + 1, cursor.pos))
            BlzFrameSetPoint(cursorFrame, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET + cursor.x, -editor.CODE_TOP_INSET - cursor.screenLineNumber*editor.LINE_SPACING)
            if not editor.isLocked then
                BlzFrameSetEnable(editBox, true)
                BlzFrameSetFocus(editBox, true)
                if not editBoxFocused then
                    editBoxFocused = true
                    editor.ON_FOCUS()
                end
            end
            BlzFrameSetVisible(cursorFrame, true)
        end,

        ---Returns the line number at which code execution was last halted by a breakpoint within the current tab.
        ---@return integer|nil
        GetCurrentBreakpoint = function()
            return currentStop[currentTab]
        end,

        ---Sets a break condition for the specified tab. The break condition must be the function body of a function that returns a boolean, for example "return a > 3". The condition function is called with the arguments (whichTab, lineNumber). The break condition function must return true for a breakpoint within that tab to activate.
        ---@param functionBody string
        ---@param whichTab string
        ---@return boolean
        SetBreakCondition = function(functionBody, whichTab)
            local func = load("return function(whichTab, lineNumber) " .. functionBody .. " end")
            if func then
                breakCondition[whichTab] = {
                    funcStr = functionBody,
                    funcs = {}
                }
                return true
            else
                return false
            end
        end,

        ---Removes the break condition for the specified tab.
        ---@param whichTab string
        RemoveBreakCondition = function(whichTab)
            breakCondition[whichTab] = nil
        end,

        ---Sets a global break condition and sets all parsed script files to Break Everywhere. The break condition must be the function body of a function that returns a boolean, for example "return a > 3". The condition function is called with the arguments (whichTab, lineNumber). The break condition function must return true for a breakpoint to activate.
        ---@param functionBody string
        SetGlobalBreakCondition = function(functionBody)
            for i = 1, #fileNames do
                WSCode.SetBreakCondition(functionBody, fileNames[i])
                breakEverywhere[fileNames[i]] = true
            end
        end,

        ---Removes all break conditions from all tabs.
        RemoveAllBreakConditions = function()
            for i = 1, #fileNames do
                breakCondition[fileNames[i]] = nil
                breakEverywhere[fileNames[i]] = nil
            end
        end,

        ---Replaces all patterns toReplace with the specified replacement in the specified tab or in the current tab if not specified. Patterns and replacement strings are limited to a single line.
        ---@param toReplace string
        ---@param replacement string
        ---@param whichTab? string
        Gsub = function(toReplace, replacement, whichTab)
            whichTab = whichTab or currentTab
            if not codeLines[whichTab] then
                return
            end
            for i = 1, highestNonEmptyLine[whichTab][step[whichTab]] do
                codeLines[whichTab][step[whichTab]][i] = codeLines[whichTab][step[whichTab]][i]:gsub(toReplace, replacement)
                coloredCodeLines[whichTab][step[whichTab]][i] = nil
            end
            if whichTab == currentTab then
                UpdateAllLines()
            end
        end,

        ---Alters the provided code such that all references to existing local variables within the specified tab (or the current tab if not specified) are replaced with lookups within the WSCode variable tracker tables. For example, the string "return a" is transformed into "return WSDebug.VarTable[whichTab][2][whichLine]", if the variable a exists at level 2 within the specified tab. If the returned string is compiled into a function, that function thereby gains access to the values of those variables.
        ---@param whichExpression string
        ---@param whichLine? integer
        ---@param whichTab? string
        ---@return string
        GetLocalAccess = function(whichExpression, whichLine, whichTab)
            whichTab = whichTab or currentTab
            local stringList = {}
            whichExpression = whichExpression:gsub('"[^"]*"', function(str)
                stringList[#stringList + 1] = str
                return "__STRING" .. #stringList
            end)
            whichExpression = whichExpression:gsub("'[^']*'", function(str)
                stringList[#stringList + 1] = str
                return "__STRING" .. #stringList
            end)

            local numReplaced
            --Replace . and : with [""] so that tokenizer splits table fields into separate tokens.
            repeat
                whichExpression, numReplaced = whichExpression:gsub("([%a_][%w_]*)%.([%w_]+)", "%1[\"%2\"]")
            until numReplaced == 0
            repeat
                whichExpression, numReplaced = whichExpression:gsub("([%a_][%w_]*):([%w_]+)%(", "%1[\"%2\"](%1,")
            until numReplaced == 0

            for i = #stringList, 1, -1 do
                whichExpression = whichExpression:gsub("__STRING" .. i, stringList[i])
            end

            local tokens, tokenLineNumbers = WSCode.Tokenize(whichExpression)

            local ignoredTokens = {}

            for i = 1, #tokens do
                if not LUA.KEYWORDS[tokens[i]] and not LUA.OPERATORS[tokens[i]] and find(tokens[i], "^#?%s*[%w_]*$") and not ignoredTokens[tokens[i]] then
                    if tokens[i - 1] == "function" or tokens[i - 1] == "for" or tokens[i - 1] == "," and tokens[i - 3] == "for" then
                        ignoredTokens[tokens[i]] = true
                    else
                        local j = i - 1
                        while tokens[j] == "," do
                            j = j - 2
                        end
                        if tokens[j] == "(" and (tokens[j - 1] == "function" or tokens[j - 2] == "function") then
                            ignoredTokens[tokens[i]] = true
                        else
                            j = i + 1
                            while tokens[j] == "," do
                                j = j + 2
                            end
                            if tokens[j] == "=" then
                                ignoredTokens[tokens[i]] = true
                            else
                                local prefix, adjustedToken = match(tokens[i], "^(#)%s*([%w_]+)$")
                                local level = visibleVarsOfLine[whichTab][whichLine or lastLineNumber[whichTab]][adjustedToken or tokens[i]]
                                if level then
                                    if prefix then
                                        tokens[i] = "#WSDebug.VarTable[\"" .. whichTab .. "\"][" .. level .. "][\"" .. adjustedToken .. "\"]"
                                    else
                                        tokens[i] = "WSDebug.VarTable[\"" .. whichTab .. "\"][" .. level .. "][\"" .. tokens[i] .. "\"]"
                                    end
                                else
                                    local executeTab =  whichTab .. " (Execute)"
                                    level = visibleVarsOfLine[executeTab][lastLineNumber[executeTab]][adjustedToken or tokens[i]]
                                    if level then
                                        if prefix then
                                            tokens[i] = "#WSDebug.VarTable[\"" .. executeTab .. "\"][" .. level .. "][\"" .. adjustedToken .. "\"]"
                                        else
                                            tokens[i] = "WSDebug.VarTable[\"" .. executeTab .. "\"][" .. level .. "][\"" .. tokens[i] .. "\"]"
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            return WSCode.Detokenize(tokens, nil, nil, tokenLineNumbers)
        end,

        ---Attempts to return the object identified by the provided expression after granting access to local variables within the current tab.
        ---@param whichExpression string
        ---@return any
        GetObjectFromExpression = function(whichExpression)
            local funcString = WSCode.GetLocalAccess(whichExpression)
            local func = load("return " .. funcString, "WSCode Parser", "t")
            if not func then
                return nil
            end
            return func()
        end,

        ---Converts a long string into a line array.
        ---@param whichString string
        ---@return string[]
        ConvertStringToLines = function(whichString)
            local lines = {}

            local k = 1
            local beginning = 1
            local pos = whichString:find("\n")
            while pos do
                lines[k] = sub(whichString, beginning, pos - 1)
                beginning = pos + 1
                pos = whichString:find("\n", pos + 1)
                k = k + 1
            end

            if beginning <= #whichString then
                lines[#lines + 1] = sub(whichString, beginning)
            end

            return lines
        end,

        ---Converts a line array into a long string.
        ---@param lines string[]
        ---@return string
        ConvertLinesToString = function(lines)
            return table.concat(lines, "\n")
        end,

        ---Forces an update of the variable viewer, displaying all variables that are visible at the specified line number.
        ---@param lineNumber integer
        UpdateVariableViewer = function(lineNumber)
            UpdateVariableViewer(lineNumber, true)
        end,

        ---Edits a single line in a tab, either by replacing it or appending it. The tab will default to the current tab if not specified.
        ---@param whichLine integer
        ---@param entry string
        ---@param whichTab? string
        ---@param append? boolean
        ---@param createUndoStep? boolean
        EditLine = function(whichLine, entry, whichTab, append, createUndoStep)
            whichTab = whichTab or currentTab

            if createUndoStep then
                WSCode.IncrementStep()
            end

            if append then
                codeLines[whichTab][step[currentTab]][whichLine] = codeLines[whichTab][step[currentTab]][whichLine] .. entry
            else
                codeLines[whichTab][step[currentTab]][whichLine] = entry
            end

            coloredCodeLines[whichTab][step[whichTab]][whichLine] = nil
            if highestNonEmptyLine[whichTab][step[whichTab]] < whichLine then
                highestNonEmptyLine[whichTab][step[whichTab]] = whichLine
            end
            if whichTab == currentTab then
                BlzFrameSetMinMaxValue(codeScroller, 0, highestNonEmptyLine[whichTab][step[whichTab]])
                SetLineOffset(tabs.lineNumberOffset[whichTab])
                UpdateAllLines()
            end

            tabs.hasUnsavedChanges[whichTab] = true

            if editor.ENABLE_SAVE_AND_LOAD and FileIO then
                BlzFrameSetText(tabNavigator.titles[whichTab], editor.TAB_NAVIGATOR_UNSAVED_COLOR .. "*" .. tabs.truncatedNames[whichTab] .. "|r")
            end

            if CheckLongestLineLength(whichLine) then
                AdjustHorizontalLineScroller()
            end

            tabIsHalted[whichTab] = false
            tabs.hasError[whichTab] = false
            doNotUpdateVariables[whichTab] = false
        end,

        ---Sets the content of a tab to the provided long string or line array.
        ---@param whichTab string
        ---@param fileContent string | string[]
        SetTabContent = function(whichTab, fileContent)
            local lines = type(fileContent) == "string" and WSCode.ConvertStringToLines(fileContent) or fileContent

            WSCode.IncrementStep()

            local currentLines = codeLines[whichTab][step[whichTab]]
            local currentColoredLines = coloredCodeLines[whichTab][step[whichTab]]
            for i = 1, #lines do
                currentLines[i] = lines[i]
                currentColoredLines[i] = nil
            end

            for i = #lines + 1, highestNonEmptyLine[whichTab][step[whichTab]] do
                currentLines[i] = ""
                currentColoredLines[i] = nil
            end

            highestNonEmptyLine[whichTab][step[whichTab]] = #lines

            if whichTab == currentTab then
                BlzFrameSetMinMaxValue(codeScroller, 0, highestNonEmptyLine[whichTab][step[whichTab]])
                SetLineOffset(tabs.lineNumberOffset[whichTab])
                UpdateAllLines()
            end

            tabs.hasUnsavedChanges[whichTab] = true

            if editor.ENABLE_SAVE_AND_LOAD and FileIO then
                BlzFrameSetText(tabNavigator.titles[whichTab], editor.TAB_NAVIGATOR_UNSAVED_COLOR .. "*" .. tabs.truncatedNames[whichTab] .. "|r")
            end

            tabs.hasError[whichTab] = false
            doNotUpdateVariables[whichTab] = false
        end,

        ---Inserts empty lines below the specified line in a tab. The number of lines defaults to 1 if not specified. The tab will default to the current tab if not specified.
        ---@param whichLine integer
        ---@param amount? integer
        ---@param whichTab? string
        ---@param createUndoStep? boolean
        InsertEmptyLines = function(whichLine, amount, whichTab, createUndoStep)
            whichTab = whichTab or currentTab
            amount = amount or 1

            if createUndoStep then
                WSCode.IncrementStep()
            end

            local lastLine = whichLine - 1

            local __, numSpaces = find(codeLines[whichTab][step[whichTab]][lastLine], "^%s*")
            if LineOpensScope(lastLine) then
                numSpaces = numSpaces + 4
            end

            local spaceStr = ""
            for __ = 1, numSpaces do
                spaceStr = spaceStr .. " "
            end

            ShiftLines(amount, whichLine)

            for i = 0, amount - 1 do
                codeLines[whichTab][step[whichTab]][whichLine + i] = spaceStr
                coloredCodeLines[whichTab][step[whichTab]][whichLine + i] = nil
            end

            highestNonEmptyLine[whichTab][step[whichTab]] = highestNonEmptyLine[whichTab][step[whichTab]] + amount

            if whichTab == currentTab then
                BlzFrameSetMinMaxValue(codeScroller, 0, highestNonEmptyLine[whichTab][step[whichTab]])
                SetLineOffset(tabs.lineNumberOffset[whichTab])
                UpdateAllLines()
            end
        end,

        ---Highlights the specified line within a tab. If endLine is provided, both whichLine and endLine as well as all lines in between are highlighted. The tab will default to the current tab if not specified. teamColorPlayerNumber controls the color of the highlight. Only one highlight can be active at any time within a tab.
        ---@param whichLine integer
        ---@param teamColorPlayerNumber integer
        ---@param endLine? integer
        ---@param whichTab? string
        HighlightLines = function(whichLine, teamColorPlayerNumber, endLine, whichTab)
            whichTab = whichTab or currentTab
            local indexString = teamColorPlayerNumber < 10 and ("0" .. teamColorPlayerNumber) or teamColorPlayerNumber
            local texture = "ReplaceableTextures\\TeamColor\\TeamColor" .. indexString .. ".blp"
            if not highlights.custom.frame then
                highlights.custom.frame = BlzCreateFrameByType("BACKDROP", "", codeEditorParent, "", 0)
                SetFrameAlpha(highlights.custom.frame, 128)
                BlzFrameSetEnable(highlights.custom.frame, false)
            end
            highlights.custom[whichTab] = {
                firstLine = whichLine,
                lastLine = endLine or whichLine,
                texture = texture
            }
            if whichTab == currentTab then
                BlzFrameSetTexture(highlights.custom.frame, texture, 0, true)
                BlzFrameSetVisible(highlights.custom.frame, true)
                local minY = -editor.CODE_TOP_INSET - editor.LINE_SPACING*max(0, min(editor.MAX_LINES_ON_SCREEN, highlights.custom[currentTab].lastLine - tabs.lineNumberOffset[currentTab]))
                local maxY = -editor.CODE_TOP_INSET - editor.LINE_SPACING*max(0, min(editor.MAX_LINES_ON_SCREEN, highlights.custom[currentTab].firstLine - tabs.lineNumberOffset[currentTab] - 1))
                BlzFrameSetPoint(highlights.custom.frame, FRAMEPOINT_BOTTOMLEFT, codeEditorParent, FRAMEPOINT_TOPLEFT, editor.CODE_LEFT_INSET, minY)
                BlzFrameSetPoint(highlights.custom.frame, FRAMEPOINT_TOPRIGHT, codeEditorParent, FRAMEPOINT_TOPRIGHT, -editor.CODE_RIGHT_INSET, maxY)
            else
                BlzFrameSetVisible(highlights.custom.frame, false)
            end
        end,

        ---Removes the highlight created with WSCode.HighlightLines within the specified tab or the current tab if not specified.
        ---@param whichTab? string
        RemoveHighlight = function(whichTab)
            whichTab = whichTab or currentTab
            if highlights.custom[whichTab] and whichTab == currentTab then
                BlzFrameSetVisible(highlights.custom.frame, false)
            end
            highlights.custom[whichTab] = nil
        end,

        ---Jumps the editor to the specified line number.
        ---@param lineNumber integer
        ---@param forceCenter? boolean
        JumpToLine = function(lineNumber, forceCenter)
            lineNumber = min(lineNumber, highestNonEmptyLine[currentTab][step[currentTab]])
            JumpWindow(lineNumber, false, forceCenter)
        end,

        ---Stores source into a tab (used by project require → WSCode error jump).
        ---@param tabName string
        ---@param functionBody string | string[]
        StoreCode = StoreCode,

        ---Enable debug UI flags (variable viewer) for require-transpiled scenario tabs.
        ForceDebugUI = function()
            flags.debugMode = true
            flags.unfreezeViewer = true
            if codeEditorParent and variableViewer.parent then
                BlzFrameSetVisible(variableViewer.parent, true)
            end
        end,

        ---Debug-transpile preload module source for require (returns loadable chunk, does not run).
        ---@param tabName string WSCode tab name (Debug.beginFile)
        ---@param source string module source
        ---@param chunkName? string load chunk name for errors (e.g. @scenario/.../file.lua)
        ---@return function?
        ---@return string? err
        CompileRequireModule = function(tabName, source, chunkName)
            if compiler.RELEASE_VERSION then
                return nil, "RELEASE_VERSION"
            end
            if type(source) ~= "string" or source == "" then
                return nil, "empty source"
            end
            local lines = WSCode.ConvertStringToLines(source)
            for i = 1, #lines do
                lines[i] = lines[i]:gsub("\t", "    "):gsub("\r", "")
            end
            StoreCode(tabName, lines)
            flags.debugMode = true
            flags.unfreezeViewer = true
            doNotUpdateVariables[tabName] = false
            if not existingFiles[tabName] then
                files[#files + 1] = lines
                fileNames[#files] = tabName
                existingFiles[tabName] = #files
                add[#files] = false
                debug[#files] = true
                store[#files] = true
                transpile[#files] = false
            end
            local func = CompileFunction(lines, {
                tab = tabName,
                debugMode = true,
                duringInit = true,
                compileOnly = true,
                chunkName = chunkName,
            })
            if not func then
                return nil, "transpile failed"
            end
            return func
        end,

        ---Automatically adjusts indentation. whichLines can be either the name of a tab or the line array directly that should be adjusted.
        ---@param whichLines string | string[]
        ---@param startLine? integer
        ---@param endLine? integer
        AutoIndent = function(whichLines, startLine, endLine)
            local whichTab
            if type(whichLines) == "string" then
                WSCode.IncrementStep()
                whichLines = codeLines[currentTab][step[currentTab]]
                whichTab = currentTab
            end

            local tempLines = {}
            local fourSpaces = "    "
            for i = 1, #whichLines do
                tempLines[i] = match(whichLines[i], "^%s*(.*)") --remove existing indentation
            end
            local level = 0

            local tokens, lineNumberOfTokens = WSCode.Tokenize(WSCode.ConvertLinesToString(tempLines))

            local j = 1
            for i = 1, #tempLines do
                local token
                local thisLevel = level
                while lineNumberOfTokens[j] == i do
                    token = tokens[j]
                    if token == "end" or token == "until" then
                        level = level - 1
                        thisLevel = thisLevel - 1
                    elseif (token == ")" or token == "}") and lineNumberOfTokens[j-1] ~= i then
                        level = level - 1
                        thisLevel = thisLevel - 1
                    elseif token == "else" or token == "elseif" then
                        thisLevel = thisLevel - 1
                    elseif token == "repeat" or token == "do" or token == "then" or token == "function" then
                        level = level + 1
                    elseif (token == "(" or token == "{") and lineNumberOfTokens[j+1] ~= i then
                        level = level + 1
                    end

                    j = j + 1
                end

                for __ = 1, thisLevel do
                    tempLines[i] = fourSpaces .. tempLines[i]
                end
            end

            for i = startLine or 1, endLine or #whichLines do
                whichLines[i] = tempLines[i]
            end

            if whichTab then
                for i = 1, #whichLines do
                    coloredCodeLines[whichTab][step[whichTab]][i] = nil
                end
                if whichTab == currentTab then
                    UpdateAllLines()
                end

                tabs.hasUnsavedChanges[whichTab] = true

                if editor.ENABLE_SAVE_AND_LOAD and FileIO then
                    BlzFrameSetText(tabNavigator.titles[whichTab], editor.TAB_NAVIGATOR_UNSAVED_COLOR .. "*" .. tabs.truncatedNames[whichTab] .. "|r")
                end
            end
        end,

        ---Jumps the camera to the specified world object and visualizes it if necessary.
        ---@param whichObject any
        ViewWorldObject = function(whichObject)
            WSCode.DestroyAllWorldObjectVisualizers()
            ViewWorldObject(whichObject, false)
        end,

        ---Destroys all handle visualization lightnings and effects.
        DestroyAllWorldObjectVisualizers = function()
            for i = 1, #variableViewer.effects do
                if HandleType[variableViewer.effects[i]] == "effect" then
                    DestroyEffect(variableViewer.effects[i])
                elseif HandleType[variableViewer.effects[i]] == "lightning" then
                    DestroyLightning(variableViewer.effects[i])
                end
                variableViewer.effects[i] = nil
            end
        end,

        ---Returns the last executed line number within the specified tab or the current tab if not specified.
        ---@param whichTab? string
        ---@return integer
        GetLineNumber = function(whichTab)
            return lastLineNumber[whichTab or currentTab]
        end,

        ---Enables or disables the editor main window and tab navigator buttons.
        ---@param enable boolean
        LockEditor = function(enable)
            editor.isLocked = enable
            if enable then
                for name, frame in next, tabNavigator.frames do
                    BlzFrameSetEnable(frame, false)
                end
            else
                for name, frame in next, tabNavigator.frames do
                    BlzFrameSetEnable(frame, true)
                end
            end
            if enable then
                BlzFrameSetFocus(editBox, false)
            end
            BlzFrameSetEnable(editBox, not enable)
        end,

        ---Prevents the editor from fading out when not focused and hovered.
        ---@param enable boolean
        BlockFadeOut = function(enable)
            editor.fadeOutBlocked = enable
        end,

        ---Adds a traceback hook to a global function or removes it. The hook will print the traceback, call arguments, and the current elapsed game time whenever the hooked function is called. Will toggle the hook on and off based on the current state if enable is not explicitly set to true or false.
        ---@param functionName string
        ---@param enable? boolean
        Hook = function(functionName, enable)
            local hostTable = _ENV
            local pos = 1
            local dotPos
            repeat
                dotPos = functionName:find("[%.:]", pos)
                if dotPos then
                    hostTable = hostTable[functionName:sub(pos, dotPos - 1)]
                    pos = dotPos + 1
                end
            until dotPos == nil

            local funcName = functionName:sub(pos)
            local func = hostTable[funcName]

            if funcName == "print" then
                WSCode.PrintForUser("|cffff5555ERROR: You don't wanna do that.|r")
                return
            end

            if type(func) == "function" then
                for i = 1, #hooks.hooked do
                    if hooks.hooked[i] == func then
                        if enable == true then
                            return
                        end
                        hostTable[funcName] = hooks.original[i]
                        hooks.original[i] = hooks.original[#hooks.original]
                        hooks.original[#hooks.original] = nil
                        hooks.hooked[i] = hooks.hooked[#hooks.hooked]
                        hooks.hooked[#hooks.hooked] = nil
                        if enable == nil then
                            WSDebug.PrintForUser("Traceback hook removed for function " .. functionName .. ".")
                        end
                        return
                    end
                end

                if enable == false then
                    return
                end

                hooks.original[#hooks.original + 1] = func
                hostTable[funcName] = function(...)
                    local argString
                    if select("#", ...) > 0 then
                        argString = tostring(select(1, ...))
                        for i = 2, select("#", ...) do
                            argString = argString .. ", " .. tostring(select(i, ...))
                        end
                    end
                    if argString then
                        argString = "\n|cffffcc00Args:|r " .. argString .. "|r"
                    else
                        argString = ""
                    end
                    if ALICE_TimeElapsed then
                        WSDebug.PrintForUser("\n|cffffcc00Function:|r " .. functionName .. " |cffaaaaaa(" .. string.format("%.2f", ALICE_TimeElapsed) .. ")|r\n|cffffcc00Traceback:|r " .. Debug.traceback() .. argString .. "\n------------------------------------------")
                    elseif ALICE and ALICE.TimeElapsed then
                        WSDebug.PrintForUser("\n|cffffcc00Function:|r " .. functionName .. " |cffaaaaaa(" .. string.format("%.2f", ALICE.TimeElapsed) .. ")|r\n|cffffcc00Traceback:|r " .. Debug.traceback() .. argString .. "\n------------------------------------------")
                    else
                        WSDebug.PrintForUser("\n|cffffcc00Function:|r " .. functionName .. "\n|cffffcc00Traceback:|r " .. Debug.traceback() .. "\n|cffffcc00Args:|r " .. argString .. "\n------------------------------------------")
                    end
                    func(...)
                end
                hooks.hooked[#hooks.hooked + 1] = hostTable[funcName]

                if enable == nil then
                    WSDebug.PrintForUser("Traceback hook added to function " .. functionName .. ".")
                end
            elseif HandleType[func] == "trigger" then
                if hooks.triggerIsHooked[func] then
                    hooks.triggerIsHooked[func] = nil
                    hooks.triggerName[func] = nil
                    if enable == nil then
                        WSDebug.PrintForUser("Traceback hook removed for trigger " .. functionName .. ".")
                    end
                else
                    hooks.triggerIsHooked[func] = true
                    hooks.triggerName[func] = functionName
                    WSDebug.PrintForUser("Traceback hook removed for trigger " .. functionName .. ".")
                end
            end
        end,

        ---Adds a global variable with the specified name to the variable viewer.
        ---@param globalName string
        ViewGlobal = function(globalName)
            if _ENV[globalName] == nil then
                WSDebug.PrintForUser("|cffff5555ERROR: No global with that name exists.|r")
                PlayError()
                return
            end
            for __, name in ipairs(variableViewer.viewedGlobals) do
                if name == globalName then
                    BlzFrameSetVisible(variableViewer.parent, true)
                    return
                end
            end
            variableViewer.viewedGlobals[#variableViewer.viewedGlobals + 1] = globalName
            UpdateVariableViewer(lastLineNumber[currentTab])
        end,

        ---Adds a breakpoint or eval injection to the specified line.  The tab will default to the current tab if not specified.
        ---@param lineNumber integer
        ---@param whichTab? string
        PutStop = function(lineNumber, whichTab)
            PutStop(lineNumber, false, whichTab or currentTab)
        end,

        ---@param expression string
        ---@param whichLine integer
        ---@param whichTab? string
        InjectEval = function(expression, whichLine, whichTab)
            whichTab = whichTab or currentTab
            local tab = nameDialog.injectTab
            local lineNumber = whichLine or nameDialog.injectLineNumber

            local func = load("return " .. expression, "InjectedEvalFunc", "t")
            if not func then
                WSDebug.PrintForUser("|cff5555ERROR: Invalid syntax in injected eval function.|r")
                return
            end

            lines.injectedEvalStr[tab][lineNumber] = expression
            lines.injectedEvalFuncs[tab][lineNumber] = nil

            lines.debugState[tab][lineNumber] = 1
            local screenLine = lineNumber - tabs.lineNumberOffset[whichTab]
            if currentTab == tab and screenLine >= 1 and screenLine <= editor.MAX_LINES_ON_SCREEN then
                BlzFrameSetTexture(BlzFrameGetChild(stopButtons[screenLine], 0), LINE_STATE_ICONS[1], 0, true)
            end

            WSDebug.PrintForUser("Expression set as injected eval function for tab " .. tab .. ", line " .. lineNumber .. ".")
        end,

        ---Continuously benchmarks the provided function or the content of the current tab if not provided.
        ---@param callback? function
        Benchmark = function(callback)
            if benchmark.func then
                PauseTimer(benchmark.TIMER)
                for i = 1, #benchmark.results do
                    benchmark.results[i] = nil
                end
                BlzFrameSetTexture(BlzFrameGetChild(buttons["Benchmark"], 0), "ReplaceableTextures\\CommandButtons\\BTNWindWalkOn.blp", 0, true)
                BlzFrameSetTexture(BlzFrameGetChild(buttons["Benchmark"], 1), "ReplaceableTextures\\CommandButtons\\BTNWindWalkOn.blp", 0, true)
                WSDebug.PrintForUser("\nBenchmark aborted.")
                benchmark.func = nil
            elseif callback then
                BlzFrameSetTexture(BlzFrameGetChild(buttons["Benchmark"], 0), "ReplaceableTextures\\CommandButtons\\BTNWindWalkOff.blp", 0, true)
                BlzFrameSetTexture(BlzFrameGetChild(buttons["Benchmark"], 1), "ReplaceableTextures\\CommandButtons\\BTNWindWalkOff.blp", 0, true)

                benchmark.iterations = 10
                benchmark.func = callback
                benchmark.gauge = true
                BenchmarkLoop()
            else
                local adjustedCodeLines = {}
                local currentLines = codeLines[currentTab][step[currentTab]]
                adjustedCodeLines[1] = currentLines[1]
                for i = 2, highestNonEmptyLine[currentTab][step[currentTab]] do
                    adjustedCodeLines[i] = "\n" .. currentLines[i]
                end

                local func, error = load(table.concat(adjustedCodeLines), "WSCode " .. (tabs.names[currentTab] or "Main"), "t")
                if not func then
                    if Debug then
                        Debug.throwError(error)
                    end
                    return
                end

                BlzFrameSetTexture(BlzFrameGetChild(buttons["Benchmark"], 0), "ReplaceableTextures\\CommandButtons\\BTNWindWalkOff.blp", 0, true)
                BlzFrameSetTexture(BlzFrameGetChild(buttons["Benchmark"], 1), "ReplaceableTextures\\CommandButtons\\BTNWindWalkOff.blp", 0, true)

                benchmark.iterations = 10
                benchmark.func = func
                benchmark.gauge = true
                BenchmarkLoop()
            end
        end,

        ---Splits the provided long string or line array into individual variables, Lua keywords, and operators. Returns the line numbers at which the tokens appeared originally as a separate array. If the tokens are recombined with WSCode.Detokenize, the errorLineNumbers should be passed instead so that error tracebacks display the correct line numbers.
        ---@param code string | string[]
        ---@return string[] tokens, integer[] tokenLineNumbers, integer[] errorLineNumbers
        Tokenize = function(code)
            if type(code) == "table" then
                code = WSCode.ConvertLinesToString(code)
            end

            local length = #code
            local word
            local currentLineNumber = 1
            local currentErrorLineNumber = 1
            local beginningOfString
            local inComment, inSingleQuoteString, inDoubleQuoteString, inMultilineString, numEqualSigns
            local tokens = {}
            local lineNumberOfToken = {}
            local errorLineNumberOfToken = {}
            local numTokens = 0

            local pos = 1
            while pos <= length do
                local oneChar
                local twoChars
                ::begin::

                if pos > length then
                    break
                end

                oneChar = sub(code, pos, pos)

                if oneChar == " " then
                    pos = find(code, "[%S\n]", pos + 1)
                    if not pos then
                        break
                    end
                    goto begin
                elseif oneChar == "\n" then
                    currentLineNumber = currentLineNumber + 1
                    if not inMultilineString then
                        currentErrorLineNumber = currentErrorLineNumber + 1
                        pos = pos + 1
                        inComment = false
                    else
                        if inComment then
                            currentErrorLineNumber = currentErrorLineNumber + 1
                        end
                        pos = find(code, "[\n%]]", pos + 1)
                        if not pos then
                            break
                        end
                    end
                    goto begin
                end

                if oneChar == "[" and not inComment and not inSingleQuoteString and not inDoubleQuoteString and not inMultilineString then
                    local i = pos + 1
                    numEqualSigns = 0
                    beginningOfString = pos
                    while sub(code, i, i) == "=" do
                        numEqualSigns = numEqualSigns + 1
                        i = i + 1
                    end
                    if sub(code, i, i) == "[" then
                        inMultilineString = true
                        pos = find(code, "[\n%]]", pos + 1)
                        if not pos then
                            break
                        end
                        goto begin
                    else
                        numTokens = numTokens + 1
                        tokens[numTokens] = "["
                        lineNumberOfToken[numTokens] = currentLineNumber
                        errorLineNumberOfToken[numTokens] = currentErrorLineNumber
                        pos = pos + 1
                        goto begin
                    end
                elseif oneChar == ";" and not inComment and not inSingleQuoteString and not inDoubleQuoteString and not inMultilineString then
                    pos = pos + 1
                    goto begin
                else
                    twoChars = sub(code, pos, pos + 1)
                    if twoChars == "--" and not inComment and not inSingleQuoteString and not inDoubleQuoteString and not inMultilineString then
                        inComment = true
                        if sub(code, pos, pos + 2) == "--[" then
                            local i = pos + 3
                            numEqualSigns = 0
                            while sub(code, i, i) == "=" do
                                numEqualSigns = numEqualSigns + 1
                                i = i + 1
                            end
                            if sub(code, i, i) == "[" then
                                inMultilineString = true
                                pos = i + 1
                            else
                                pos = i
                            end
                            pos = find(code, "[\n%]]", pos)
                            if not pos then
                                break
                            end
                            goto begin
                        else
                            pos = find(code, "\n", pos + 2)
                            if not pos then
                                break
                            end
                            goto begin
                        end
                    end
                end

                if inMultilineString then
                    if match(sub(code, pos, pos + 1 + numEqualSigns), "^%]%=*%]$") then
                        inMultilineString = false
                        if not inComment then
                            numTokens = numTokens + 1
                            tokens[numTokens] = sub(code, beginningOfString, pos + 1 + numEqualSigns)
                            lineNumberOfToken[numTokens] = currentLineNumber
                            errorLineNumberOfToken[numTokens] = currentErrorLineNumber
                        end
                        inComment = false
                        pos = pos + 2 + numEqualSigns
                        goto begin
                    else
                        pos = find(code, "[\n%]]", pos + 1)
                        if not pos then
                            break
                        end
                        goto begin
                    end
                elseif inComment then
                    if inMultilineString then
                        pos = find(code, "[\n%]]", pos + 1)
                        if not pos then
                            break
                        end
                    else
                        pos = find(code, "\n", pos + 1)
                        if not pos then
                            break
                        end
                    end
                    goto begin
                elseif oneChar == '"' and not IsQuotationMarkEscaped(code, pos) then
                    if not inSingleQuoteString and not inMultilineString then
                        if not inDoubleQuoteString then
                            beginningOfString = pos
                            repeat
                                pos = find(code, '"', pos + 1)
                            until not pos or not IsQuotationMarkEscaped(code, pos)
                            inDoubleQuoteString = true
                            if not pos then
                                break
                            end
                            goto begin
                        else
                            numTokens = numTokens + 1
                            tokens[numTokens] = sub(code, beginningOfString, pos)
                            lineNumberOfToken[numTokens] = currentLineNumber
                            errorLineNumberOfToken[numTokens] = currentErrorLineNumber
                            inDoubleQuoteString = false
                        end
                    end
                    pos = pos + 1
                    goto begin
                elseif oneChar == "'" and not IsQuotationMarkEscaped(code, pos) then
                    if not inDoubleQuoteString and not inMultilineString then
                        if not inSingleQuoteString then
                            beginningOfString = pos
                            repeat
                                pos = find(code, "'", pos + 1)
                            until not pos or not IsQuotationMarkEscaped(code, pos)
                            inSingleQuoteString = true
                            if not pos then
                                break
                            end
                            goto begin
                        else
                            numTokens = numTokens + 1
                            tokens[numTokens] = sub(code, beginningOfString, pos)
                            lineNumberOfToken[numTokens] = currentLineNumber
                            errorLineNumberOfToken[numTokens] = currentErrorLineNumber
                            inSingleQuoteString = false
                        end
                    end
                    pos = pos + 1
                    goto begin
                end

                if sub(code, pos, pos + 2) == "..." then
                    numTokens = numTokens + 1
                    tokens[numTokens] = "..."
                    lineNumberOfToken[numTokens] = currentLineNumber
                    errorLineNumberOfToken[numTokens] = currentErrorLineNumber
                    pos = pos + 3
                    goto begin
                end

                if LUA.TWO_CHAR_OPERATORS[twoChars] then
                    numTokens = numTokens + 1
                    tokens[numTokens] = twoChars
                    lineNumberOfToken[numTokens] = currentLineNumber
                    errorLineNumberOfToken[numTokens] = currentErrorLineNumber
                    pos = pos + 2
                    goto begin
                end

                if LUA.ONE_CHAR_OPERATORS[oneChar] then
                    numTokens = numTokens + 1
                    tokens[numTokens] = oneChar
                    lineNumberOfToken[numTokens] = currentLineNumber
                    errorLineNumberOfToken[numTokens] = currentErrorLineNumber
                    pos = pos + 1
                    goto begin
                end

                if oneChar >= "0" and oneChar <= "9" then
                    if oneChar == "0" then
                        local nextChar = sub(code, pos + 1, pos + 1)
                        if nextChar == "x" or nextChar == "X" then --number is hexadecimal, ignore scientific notation
                            word = match(code, "^#?%s*[%w_.:]*", pos)
                        else
                            word = match(code, "^[%w_.:#]*[eE][%-%+]?%d+", pos) or match(code, "^[%w_.:#]*", pos) --scientific notation
                        end
                    else
                        word = match(code, "^[%w_.:#]*[eE][%-%+]?%d+", pos) or match(code, "^[%w_.:#]*", pos) --scientific notation
                    end
                else
                    word = match(code, "^#?%s*[%w_.:]*", pos)
                end

                if word then
                    if find(word, "::") then
                        numTokens = numTokens + 1
                        tokens[numTokens] = sub(word, 1, -3)
                        lineNumberOfToken[numTokens] = currentLineNumber
                        errorLineNumberOfToken[numTokens] = currentErrorLineNumber
                        pos = pos + #word - 2
                        goto begin
                    end

                    numTokens = numTokens + 1
                    tokens[numTokens] = word
                    lineNumberOfToken[numTokens] = currentLineNumber
                    errorLineNumberOfToken[numTokens] = currentErrorLineNumber
                    if #word == 0 then
                        pos = pos + 1
                    end
                    pos = pos + #word
                    goto begin
                end

                pos = pos + 1
            end

            tokens[#tokens + 1] = ""
            lineNumberOfToken[#tokens] = lineNumberOfToken[#tokens - 1] or 1
            errorLineNumberOfToken[#tokens] = errorLineNumberOfToken[#tokens - 1] or 1

            return tokens, lineNumberOfToken, errorLineNumberOfToken
        end,

        ---Recombines the Lua token array created with WSCode.Tokenize into a long string. If tokenLineNumbers are provided, line breaks are inserted so that the tokens are placed in the correct lines.
        ---@param tokens string[]
        ---@param start? integer
        ---@param stop? integer
        ---@param tokenLineNumbers? integer[]
        ---@return string
        Detokenize = function(tokens, start, stop, tokenLineNumbers)
            if tokenLineNumbers then
                local strTable = {}
                local currentLine = 1
                for i = start or 1, stop or #tokens do
                    while tokenLineNumbers[i] > currentLine do
                        strTable[#strTable + 1] = "\n"
                        currentLine = currentLine + 1
                    end
                    strTable[#strTable + 1] = " " .. tokens[i]
                end
                return table.concat(strTable)
            else
                return table.concat(tokens, " ", start, stop)
            end
        end,

        ---Returns the line number at which the function or scope opened within the provided line array at the specified line closes. Defaults to the first line if not specified.
        ---@param code string[]
        ---@param startLineNumber? integer
        ---@return integer | nil
        GetEndOfScopeLineNumber = function(code, startLineNumber)
            local chunk
            if startLineNumber then
                for i = 1, startLineNumber - 1 do
                    chunk[i] = ""
                end

                for i = startLineNumber, #code do
                    chunk[i] = code[i]
                end
            else
                chunk = code
            end

            local tokens, tokenLineNumbers = WSCode.Tokenize(chunk)

            local level = 0

            for i = 1, #tokens do
                local token = tokens[i]
                if token == "do" or token == "repeat" or token == "then" or token == "function" then
                    level = level + 1
                elseif token == "end" or token == "until" then
                    level = level - 1
                    if level == 0 then
                        return tokenLineNumbers[i]
                    end
                end
            end

            return nil
        end,

        ButtonList = {
            "Execute",
            "Flags",
            "Demolish",
            "Undo",
            "Redo",
            "Traceback",
            "View Global",
            "Hook",
            "Smart Evaluate",
            "Search",
            "Load Backup File",
            "Pull Script",
            "Quick Restart",
            "Benchmark",
            "Pause/Resume"
        },

        Buttons = buttons,

        ---Called before main. The earliest point to initialize outside the Lua root.  
        ---@param whichFunc function
        ---@param onWhichPass? integer
        InitMain = function(whichFunc, onWhichPass)
            AddInit(whichFunc, onWhichPass, "main")
        end,

        ---Called after InitGlobals. The standard point to initialize.
        ---@param whichFunc function
        ---@param onWhichPass? integer
        InitGlobal = function(whichFunc, onWhichPass)
            AddInit(whichFunc, onWhichPass, "global")
        end,

        ---Called after InitCustomTriggers. Useful for removing hooks that should only apply to GUI events.
        ---@param whichFunc function
        ---@param onWhichPass? integer
        InitTrig = function(whichFunc, onWhichPass)
            AddInit(whichFunc, onWhichPass, "trig")
        end,

        ---Called at the last point in initialization before the loading screen is completed.
        ---@param whichFunc function
        ---@param onWhichPass? integer
        InitMap = function(whichFunc, onWhichPass)
            AddInit(whichFunc, onWhichPass, "map")
        end,

        ---Called immediately after the loading screen has disappeared, and the game has started.
        ---@param whichFunc function
        ---@param onWhichPass? integer
        InitFinal = function(whichFunc, onWhichPass)
            AddInit(whichFunc, onWhichPass, "final")
        end,

        ---Called immediately before InitFinal. Will execute even if initialization was halted.
        ---@param whichFunc function
        ---@param onWhichPass? integer
        InitEssential = function(whichFunc, onWhichPass, ...)
            AddInit(whichFunc, onWhichPass, "essential")
        end,

        ---Called when a saved game is loaded.
        ---@param whichFunc function
        ---@param onWhichPass? integer
        InitLoad = function(whichFunc, onWhichPass)
            AddInit(whichFunc, onWhichPass, "load")
        end
    }
end