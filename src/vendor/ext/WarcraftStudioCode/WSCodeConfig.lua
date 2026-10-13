if Debug then
    Debug.beginFile("WSCodeConfig")
end
do
    WSCodeConfig = {
        compiler = {
            --Disables the editor and all code alterations. Overwrites all settings below.
            RELEASE_VERSION = false         --when the function being debugged is halted. In addition, the complete traceback will be available on an error. This feature slows down code execution, even
            --with all WSCode wrappers removed, so set it to false for your release version. WARNING: This option breaks GUI waits.
, --If enabled, WSCode will wrap coroutines around everything, allowing it to yield from the parent function on a breakpoint insteayd of just the function that --was added to the debugger. This means that if an external function calls a function that is being debugged, the parent function will not continue executing
            WRAP_ALL_LUA_ENTRY_POINTS = true, --If WRAP_ALL_LUA_ENTRY_POINTS is enabled, GUI waits will break unless this option is also enabled. Enabling this will heavily slow down trigger actions.
            DO_NOT_BREAK_GUI_WAITS = false          --is kept in the map script, it should be placed above WSCode.
, --Overwrites all OnInit functions with the corresponding WSCode init funtions. The Require function is not supported and must be replaced with @require -- tokens manually. OnInit.root, OnInit.module, and OnInit.config must be removed if TotalInitialization is removed from the map script. If TotalInitialization
            OVERWRITE_TOTAL_INITIALIZATION = false, --Enable to allow the WSCode.Parse function to split GUI triggers into files. May sometimes cause scripts to be parsed incorrectly. To set up a wrap that --includes GUI triggers, you must create a GUI trigger at the very bottom with the custom script line "end ]===]) do" in it.
            PARSE_GUI_TRIGGERS = true           --launched regularly, which may have side effects. Only works if map script is wrapped by WSCode.Parse function. Recommended to use WSCode initializers when
            --using this feature.
, --Allows you to save the map script with changes made in-game to a file, then restart the map and load the modified map script. This is a powerful feature that --enables you to iterate your map much quicker. However, this option necessitates that the map script is suspended until main is called, even when the map is
            ENABLE_QUICK_RESTART = false, --Always load the map script from the preload file in the CustomMapData directory if it exists. The map script should be compiled externally before launching -- the map. Requires ENABLE_QUICK_RESTART.
            ALWAYS_QUICK_RESTART = false, --Enables debug mode across all parsed files. May drastically increase map loading time and reduce performance. Use with caution!
            GLOBAL_DEBUG = false            --top X contributors to floating handles (default 10). leakreport X-Y will print positions X to Y. The function creating the handle must be listed in
            --editor.CREATOR_DESTRUCTOR_PAIRS.
, --Tracks the script and linenumber at which each handle is created and displays it in the variable viewer when selecting it. In addition, counts all handles --created and not destroyed at each position in the code, detecting possible memory leaks. To show the report, type -leakreport. -leakreport X will print the
            STORE_HANDLE_ORIGIN = true, --If enabled, the traceback is preserved on TriggerExecute and TriggerEvaluate calls. Causes memory leaks.
            STORE_TRIGGER_TRACEBACK = false, --Automatically pauses a script that was compiled in debug mode if more than this many lines have been executed during one game tick. Set to nil to disable.
            EXECUTION_LIMIT = 1e7           --finalizer section. The MAP_SCRIPT_PREFIX will be added to the beginning of the map script. After exporting the script, you need to do various string
            --replacements before it is ready. Remove the preload prefix and suffix, then replace (without quotation marks):
            --'   call Preload( "' -> '', and '" \)\n' -> '\n' (to keep line breaks), or '" \)\n' -> '' (to remove line breaks). Make sure regular expressions are enabled.
            --If you keep line breaks, you now have to do additional replacements:
            --' --- @TODO START OF LONG LINE - CONCATENATE MULTILINES YOURSELF AND REMOVE THIS: ---\n(.*)\n--- @TODO END OF LONG LINE. REMOVE THIS TOO. ---' -> '$1'
            --This will remove all multilines exactly two lines long. To remove all multilines three lines long, you add another (.*)\n in the center, and change the
            --replacement string to '$1$2'. Keep adding lines this way until all multilines are removed.
, --Writes a transformed map script to the WSCodeMapScript.txt file. This map script can be used to replace all script files in the Trigger Editor. This step is --necessary to remove WSCode from the map if the WSCode initializers are used. You have access to map optimization and script obfuscation options in the
            FINALIZE_MAP_SCRIPT = false,
        },

        diagnostics = {
            --Throw a warning when a WSCode.Init function is called outside of the Parse wrapper. This may happen by accident when scripts or folders are moved around.
            INIT_OUTSIDE_OF_WRAP_WARNING = false            --WSCode.Parse function.
, --If enabled, writes the name of the last file being parsed by WSCode.Parse into the file WSCodeInitDump.txt, so that you gain information about which script --causes a crash on map initialization. Will not catch crashes occuring in TotalInitialization init functions. Only works if map script is wrapped by
            INIT_DUMP = false, --Prints the total initialization time of the map script and the individual contributions of the most expensive libraries.
            PROFILE_INIT = false, --Writes the transpiled scripts of files in debug mode into the file WSCodeTranspiled<FileName>.txt, so that you can check what the transpiler is actually --doing.
            DUMP_TRANSPILED_SCRIPTS = false,
        },

        editor = {
            --Enables the editor for the players with these names. Uses substring, therefore #XXXX not required and an empty string enables it for all players.
            MAP_CREATORS = { ---@constant string[]
                "",
            },
            NEXT_LINE_HOTKEY = "F3", ---@constant string | nil
            CONTINUE_HOTKEY = "F3", ---@constant string | nil
            TOGGLE_HIDE_EDITOR_HOTKEY = "F1", ---@constant string | nil --0 = None, 1 = Shift, 2 = Ctrl, 3 = Shift + Ctrl
            NEXT_LINE_METAKEY = 0, ---@constant integer
            CONTINUE_METAKEY = 2, ---@constant integer
            TOGGLE_HIDE_EDITOR_METAKEY = 2, ---@constant integer --Replaces the standard Friz Quadrata font with Consolas. This will ensure that all tab spaces remain aligned. Requires Consolas.ttf.
            USE_MONOSPACE_FONT = true, --Enable automatic export of script files into text files to be saved or imported again on a later session. Requires FileIO.
            ENABLE_SAVE_AND_LOAD = true, --The folder to which all text files are exported. The complete path is Warcraft III\CustomMapData\Subfolder\.
            EXPORT_SUBFOLDER = "WSCode" .. (MapName and ("_" .. MapName) or ""),
            ASSET_SUBFOLDER = "WSCodeAssets", --Automatically loads into the editor scripts that have been parsed by WSCode.Parse, but are not currently being debugged, when they produce an error.
            LOAD_EXTERNAL_SCRIPTS_ON_ERROR = true, --Always halt the ALICE cycle when stopping at a breakpoint. If disabled, it will only stop if halted within an ALICE function.
            ALWAYS_HALT_ALICE_ON_BREAKPOINT = true, --This function is called when the editor is shown or enabled.
            ON_ENABLE = function()
                ToggleUIIfNecessary()
                BlzEnableCursor(true)
                if RallyeUI then
                    RallyeUI.ShowDriverStandings(false)
                end
                if CinematicStudio then
                    CinematicStudio.BlackScreen(false)
                end
            end, --This function is called when the editor is hidden.
            ON_DISABLE = function()
                ToggleUIIfNecessary()
                if RallyeUI then
                    RallyeUI.ShowDriverStandings(true)
                end
            end, --This function is called when the editor is expanded.
            ON_EXPAND = function()
                ClearTextMessages()
            end, --This function is called when the editor is collapsed.
            ON_COLLAPSE = function() end, --This function is called when the script execution halts at a breakpoint.
            ON_BREAK = function(scriptName)
                if CinematicStudio then
                    CinematicStudio.BlackScreen(false)
                end
                if ALICE_Initialized then
                    ALICE_ForAllObjectsDo(PauseUnit, "unit", nil, true)
                end
                WSCode.LockEditor(false)
                ShowInterface(true, 0)
                EnableUserControl(true)
            end, --This function is called when the script execution resumes from a breakpoint.
            ON_RESUME = function(scriptName)
                if ALICE_Initialized then
                    ALICE_ForAllObjectsDo(PauseUnit, "unit", nil, false)
                end
            end, --This function is called when a script encounters an error.
            ON_ERROR = function(scriptName)
                if CinematicStudio then
                    CinematicStudio.BlackScreen(false)
                    if CinematicStudio.IsInCinematic() then
                        CinematicStudio.Abort()
                    end
                end
                EnableUserControl(true)
                ShowInterface(true, 0)
                WSCode.LockEditor(false)
            end, --This function is called when the editor text window is focused.
            ON_FOCUS = function() end, --This function is called when the editor text window is defocused.
            ON_DEFOCUS = function() end, --This function is called when a world object is viewed in the variable editor.
            ON_OBJECT_VIEW = function(whichObject, x, y)
                if EditorCameraEnabled then
                    if HandleType[whichObject] == "camerasetup" then
                        EditorCamera.Set(CinematicStudio.ConvertCameraSetup(whichObject))
                    elseif FreeCameraEnabled and CinematicStudio then
                        CinematicStudio.GameCamera.x = x
                        CinematicStudio.GameCamera.y = y
                        EditorCamera.Set(EditorCamera.ConvertToFreeCamera(CinematicStudio.GameCamera))
                    else
                        if CinematicStudio then
                            CinematicStudio.GameCamera.x = x
                            CinematicStudio.GameCamera.y = y
                            EditorCamera.Set(CinematicStudio.GameCamera)
                        end
                        if type(whichObject) == "table" then
                            EditorCamera.Set(whichObject)
                        else
                            EditorCamera.Set({ x = x, y = y })
                        end
                    end
                elseif HandleType[whichObject] == "camerasetup" then
                    CameraSetupApply(whichObject, true, true)
                else
                    ResetToGameCamera(0)
                    SetCameraPosition(x, y)
                    if
                        CinematicStudio
                        and type(whichObject) == "table"
                        and rawget(whichObject, "aoa")
                        and rawget(whichObject, "rot")
                    then
                        local setup = CinematicStudio.ConvertCameraData(whichObject)
                        CameraSetupApply(setup, true, true)
                    end
                end
            end, --This function is called when the back button is clicked while viewing a world object in the variable editor.
            ON_OBJECT_UNVIEW = function(whichObject) end, --Setting a list of legal characters protects you from messing up your code by accidently pressing the key of a character that cannot be displayed, --leading to compile errors from seemingly valid code. This list contains all utf8 1-byte characters except the grave accents. Set to nil to disable.
            LEGAL_CHARACTERS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!$&()[]=?:;,._#*~/{}<>^+-|'\"\\@% 1234567890\t", --If the user presses no key for this long, a new undo step is created.
            MIN_TIME_BETWEEN_UNDO_STEPS = 1.0,
            GET_PARENT = function()
                if FullScreenParent then
                    local parent = BlzCreateFrameByType("FRAME", "", FullScreenParent, "", 0)
                    BlzFrameSetLevel(parent, 6)
                    return parent
                end
                return BlzGetFrameByName("ConsoleUIBackdrop", 0)
            end, --These parameter control the layout of the code editor.
            COLLAPSED_X = 0.567,
            Y_TOP = 0.57,
            EXPANDED_X = 0.14,
            LINE_SPACING = 0.0085,
            MAX_LINES_ON_SCREEN = 50,
            COLLAPSED_WIDTH = 0.353,
            EXPANDED_WIDTH = 0.78,
            CODE_LEFT_INSET = 0.044,
            CODE_RIGHT_INSET = 0.025,
            CODE_TOP_INSET = 0.025,
            CODE_BOTTOM_INSET = 0.013,
            LINE_NUMBER_HORIZONTAL_INSET = 0.006,
            STOP_BUTTON_HORIZONTAL_INSET = 0.023,
            LINE_HIGHLIGHT_HORIZONTAL_INSET = 0.034,
            CODE_SCROLLER_HORIZONTAL_INSET = 0.01,
            CODE_SCROLLER_WIDTH = 0.011,
            CODE_HORIZONTAL_SCROLLER_LEFT_INSET = 0.02,
            CODE_HORIZONTAL_SCROLLER_VERTICAL_INSET = 0.004,
            CODE_HORIZONTAL_SCROLLER_RIGHT_INSET = 0.022,
            CODE_HORIZONTAL_SCROLLER_HEIGHT = 0.011,
            BOTTOM_BUTTON_SIZE = 0.0217,
            BOTTOM_BUTTON_VERTICAL_SHIFT = -0.022,
            CHECKBOX_HORIZONTAL_INSET = 0.032,
            CHECKBOX_VERTICAL_SHIFT = -0.007,
            CHECKBOX_TEXT_VERTICAL_SHIFT = -0.0015,
            CHECKBOX_TEXT_SPACING = 0.002,
            TEXT_CHECKBOX_SPACING = 0.008,
            DELETE_BUTTON_HORIZONTAL_INSET = 0.007,
            DELETE_BUTTON_HIGHLIGHT_INSET = 0.002,
            CLOSE_BUTTON_INSET = 0.005,
            CLOSE_BUTTON_SIZE = 0.017,
            TITLE_VERTICAL_SHIFT = -0.0085,
            LINE_NUMBER_SCALE = 0.9,
            MAX_HORIZONTAL_SCROLL_BUFFER = 5,
            PLUGIN_LIST_WIDTH = 0.12, --These parameters control the behavior of the fade when the editor is not focused.
            DEFOCUS_FADE_OUT_ALPHA = 75,
            DEFOCUS_FADE_OUT_DELAY = 2.0,
            DEFOCUS_FADE_TIME = 0.5,
            FOCUS_FADE_TIME = 0.2, --0-255
            BLACK_BACKDROP_ALPHA = 200, --The colors of syntax highlighting.
            KEYWORD_COLOR = "|cffff9d98",
            FUNCTION_NAME_COLOR = "|cff9aaaee",
            NATIVE_COLOR = "|cfff0a77e",
            COMMENT_COLOR = "|cff8a8a92",
            STRING_COLOR = "|cff77b9c3",
            VALUE_COLOR = "|cff8bbaf7", --The colors of currentTab navigators.
            TAB_NAVIGATOR_SELECTED_COLOR = "|cffffffff",
            TAB_NAVIGATOR_UNSELECTED_COLOR = "|cffaaaaaa",
            TAB_NAVIGATOR_SELECTED_NO_DEBUG_COLOR = "|cffaaaaff",
            TAB_NAVIGATOR_UNSELECTED_NO_DEBUG_COLOR = "|cff7171aa",
            TAB_NAVIGATOR_UNSAVED_COLOR = "|cffff0000", --The colors of line numbers.
            LINE_NUMBER_COLOR = "|cffaaaaaa",
            IDLE_LINE_NUMBER_COLOR = "|cff777777",
        },

        bottomBar = {
            ["Execute"] = 1,
            ["Flags"] = 2,
            ["Demolish"] = 3,
            ["Undo"] = 4,
            ["Redo"] = 5,
            ["Traceback"] = 6,
            ["View Global"] = 7,
            ["Hook"] = 8,
            ["Smart Evaluate"] = 9,
            ["Search"] = 10,
            ["Load Backup File"] = 11,
            ["Pull Script"] = 12,
            ["Quick Restart"] = 13,
            ["Benchmark"] = 14,
            ["Pause/Resume"] = 15,
            ["Plugins"] = 16,
            MAX_BUTTONS = 16,
        },

        finalizer = {
            --Include libraries that have a ---@development comment.
            DEVELOPMENT_BUILD = false, --If enabled, removes all comments and as much whitespace as possible.
            REMOVE_COMMENTS_AND_LINE_BREAKS = false,
        },

        --Links the name of a destructor function with the name of a creator function that is used to clean up objects created
        --by previous compilations of the code chunk when "Clean Handles" is enabled.
        CREATOR_DESTRUCTOR_PAIRS = { ---@constant table<string, string>
            CreateTimer = "DestroyTimer",
            CreateGroup = "DestroyGroup",
            CreateForce = "DestroyForce",
            CreateRegion = "RemoveRegion",
            CreateTrigger = "DestroyTrigger",
            CreateDestructable = "RemoveDestructable",
            CreateDestructableZ = "RemoveDestructable",
            CreateDeadDestructable = "RemoveDestructable",
            CreateDeadDestructableZ = "RemoveDestructable",
            CreateItem = "RemoveItem",
            CreateUnit = "RemoveUnit",
            CreateUnitByName = "RemoveUnit",
            CreateUnitAtLoc = "RemoveUnit",
            CreateUnitAtLocByName = "RemoveUnit",
            CreateCorpse = "RemoveUnit",
            CreateFogModifierRect = "DestroyFogModifier",
            CreateFogModifierRadius = "DestroyFogModifier",
            CreateFogModifierRadiusLoc = "DestroyFogModifier",
            DialogCreate = "DialogDestroy",
            CreateUnitPool = "DestroyUnitPool",
            CreateItemPool = "DestroyItemPool",
            CreateMinimapIconOnUnit = "DestroyMinimapIcon",
            CreateMinimapIconAtLoc = "DestroyMinimapIcon",
            CreateMinimapIcon = "DestroyMinimapIcon",
            CreateTextTag = "DestroyTextTag",
            CreateQuest = "DestroyQuest",
            CreateDefeatCondition = "DestroyDefeatCondition",
            CreateTimerDialog = "DestroyTimerDialog",
            CreateLeaderboard = "DestroyLeaderboard",
            CreateMultiboard = "DestroyMultiboard",
            CreateImage = "DestroyImage",
            CreateUbersplat = "DestroyUbersplat",
            BlzCreateFrame = "BlzDestroyFrame",
            BlzCreateSimpleFrame = "BlzDestroyFrame",
            BlzCreateFrameByType = "BlzDestroyFrame",
            CreateCommandButtonEffect = "DestroyCommandButtonEffect",
            CreateUpgradeCommandButtonEffect = "DestroyCommandButtonEffect",
            CreateLearnCommandButtonEffect = "DestroyCommandButtonEffect",
            BlzCreateItemWithSkin = "RemoveItem",
            BlzCreateUnitWithSkin = "RemoveUnit",
            BlzCreateDestructableWithSkin = "RemoveDestructable",
            BlzCreateDestructableZWithSkin = "RemoveDestructable",
            BlzCreateDeadDestructableWithSkin = "RemoveDestructable",
            BlzCreateDeadDestructableZWithSkin = "RemoveDestructable",
            AddSpecialEffect = "DestroyEffect",
            AddSpecialEffectTarget = "DestroyEffect",
            AddSpecialEffect3D = "DestroyEffect",
            EnableWeatherEffect = "RemoveWeatherEffect",
            AddLightning = "DestroyLightning",
            ALICE_Create = "ALICE_Destroy",
            ALICE_CallPeriodic = "ALICE_DisableCallback",
            ALICE_CallRepeated = "ALICE_DisableCallback",
            ALICE_CallDelayed = "ALICE_DisableCallback",
            ALICE_PairCallDelayed = "ALICE_DisableCallback",
            CreateSound = "",
            CreateSoundFilenameWithLabel = "",
            CreateSoundFromLabel = "",
            CreareMIDISound = "",
        },

        --Use this function to define automatic replacements within the Code Editor. The function takes the current line being edited and returns
        --the line with the replacements added.
        handleTextMacros = function(line)
            if not MouseScreen2World and not MouseTrigger then
                MouseTrigger = CreateTrigger()
                TriggerRegisterPlayerEvent(MouseTrigger, WSCode.GetUser(), EVENT_PLAYER_MOUSE_MOVE)
                TriggerAddAction(MouseTrigger, function()
                    MouseX = BlzGetTriggerPlayerMouseX()
                    MouseY = BlzGetTriggerPlayerMouseY()
                end)
            end

            local mouseX = MouseScreen2World and MouseScreen2World.x or MouseX or 0
            local mouseY = MouseScreen2World and MouseScreen2World.y or MouseY or 0

            if line:find("!COORDS") then
                if line:find("!COORDS!") then
                    return line:gsub("!COORDS!", math.floor(mouseX) .. ", " .. math.floor(mouseY))
                elseif line:find("!COORDS3D!") then
                    return line:gsub(
                        "!COORDS3D!",
                        math.floor(mouseX)
                            .. ", "
                            .. math.floor(mouseY)
                            .. ", "
                            .. math.floor(GetLocationZ(Location(mouseX, mouseY)))
                    )
                end
            elseif line:find("!CINPOINT!") then
                local x, y = GetCinLoc()
                return line:gsub(
                    "!CINPOINT!",
                    "GetCinLocOffset(" .. math.floor(mouseX - x) .. ", " .. math.floor(mouseY - y) .. ")"
                )
            elseif line:find("!SCREEN!") then
                local x, y = BlzPixelToFrameX(BlzGetMouseScreenPosX()), BlzPixelToFrameY(BlzGetMouseScreenPosY())
                return line:gsub("!SCREEN!", string.format("%.4f", x) .. ", " .. string.format("%.4f", y))
            elseif line:find("!UNIT!") then
                ---@diagnostic disable-next-line: lowercase-global
                wsunit = ALICE_GetClosestObject(mouseX, mouseY, "unit")
                return line:gsub("!UNIT!", "wsunit")
            elseif line:find("!OBJ!") then
                ---@diagnostic disable-next-line: lowercase-global
                wsobject = ALICE_GetClosestObject(mouseX, mouseY, { MATCHING_TYPE_ALL }, nil, function(whichObject)
                    return not ALICE_HasIdentifier(whichObject, "WSDebug.Mouse")
                        and not ALICE_HasIdentifier(whichObject, "camera")
                end)
                return line:gsub("!OBJ!", "wsobject")
            elseif line:find("!CAM!") then
                local fov = bj_RADTODEG * GetCameraField(CAMERA_FIELD_FIELD_OF_VIEW)
                local localYaw = bj_RADTODEG * GetCameraField(CAMERA_FIELD_LOCAL_YAW)
                local localPitch = bj_RADTODEG * GetCameraField(CAMERA_FIELD_LOCAL_PITCH)
                local localRoll = bj_RADTODEG * GetCameraField(CAMERA_FIELD_LOCAL_ROLL)
                local focalDistance = GetCameraField(CAMERA_FIELD_DEPTH_OF_FIELD_DISTANCE)
                local farZ = GetCameraField(CAMERA_FIELD_FARZ)
                local aoa = GetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK)
                local dist = GetCameraField(CAMERA_FIELD_TARGET_DISTANCE)
                local zAbs = GetCameraEyePositionZ() + math.sin(aoa) * dist

                return line:gsub(
                    "!CAM!",
                    "{x = "
                        .. math.floor(GetCameraTargetPositionX())
                        .. ", y = "
                        .. math.floor(GetCameraTargetPositionY())
                        .. ", aoa = "
                        .. string.format("%.2f", bj_RADTODEG * GetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK))
                        .. ", rot = "
                        .. string.format("%.2f", bj_RADTODEG * GetCameraField(CAMERA_FIELD_ROTATION))
                        .. ", dist = "
                        .. math.max(5, math.floor(dist))
                        .. ", zAbs = "
                        .. math.floor(zAbs)
                        .. (math.abs(CinematicStudio.DefaultFarZ - farZ) > 1 and (", farZ = " .. math.floor(farZ)) or "")
                        .. ((fov <= 69 or fov >= 71) and ", fov = " .. (math.abs(fov - math.floor(fov + 0.01)) < 0.01 and math.floor(
                            fov + 0.01
                        ) or string.format("%.2f", fov)) or "")
                        .. ((localYaw <= -1 or localYaw >= 1) and ", lYaw = " .. math.floor(localYaw) or "")
                        .. ((localPitch <= -1 or localPitch >= 1) and ", lPitch = " .. math.floor(localPitch) or "")
                        .. ((localRoll <= -1 or localRoll >= 1) and ", lRoll = " .. math.floor(localRoll) or "")
                        .. (
                            focalDistance > 0
                                and ", foc = " .. math.floor(focalDistance) .. ", dof = " .. math.floor(
                                    GetCameraField(CAMERA_FIELD_DEPTH_OF_FIELD_SCALE)
                                )
                            or ""
                        )
                ) .. "}"
            elseif line:find("!CAMSETUP!") then
                WSCode.OpenDialog("Enter Camera Name", nil, function(enteredName)
                    local cam = CreateCameraSetup()
                    CameraSetupSetDestPosition(cam, GetCameraTargetPositionX(), GetCameraTargetPositionY(), 0)
                    CameraSetupSetField(cam, CAMERA_FIELD_ZOFFSET, GetCameraField(CAMERA_FIELD_ZOFFSET), 0)
                    CameraSetupSetField(
                        cam,
                        CAMERA_FIELD_ROTATION,
                        bj_RADTODEG * GetCameraField(CAMERA_FIELD_ROTATION),
                        0
                    )
                    CameraSetupSetField(
                        cam,
                        CAMERA_FIELD_ANGLE_OF_ATTACK,
                        bj_RADTODEG * GetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK),
                        0
                    )
                    CameraSetupSetField(
                        cam,
                        CAMERA_FIELD_TARGET_DISTANCE,
                        GetCameraField(CAMERA_FIELD_TARGET_DISTANCE),
                        0
                    )
                    CameraSetupSetField(cam, CAMERA_FIELD_FARZ, GetCameraField(CAMERA_FIELD_FARZ), 0)
                    CameraSetupSetField(
                        cam,
                        CAMERA_FIELD_FIELD_OF_VIEW,
                        bj_RADTODEG * GetCameraField(CAMERA_FIELD_FIELD_OF_VIEW),
                        0
                    )
                    if enteredName:find("gg_cam_") then
                        _ENV[enteredName:gsub(" ", "_")] = cam
                    else
                        _ENV["gg_cam_" .. enteredName:gsub(" ", "_")] = cam
                    end
                end)
                return ""
            elseif line:find("!TRACK!") then
                return line:gsub("!TRACK!", math.floor(Road.GetTrackDistance(mouseX, mouseY)))
            end
        end,

        tabNavigator = {
            VERTICAL_SHIFT = -0.007,
            WIDTH = 0.062,
            HEIGHT = 0.028,
            OVERLAP = 0.007,
            TEXT_INSET = 0.008,
            CLOSE_BUTTON_INSET = 0.003,
            CLOSE_BUTTON_SIZE = 0.01,
            CLICK_BOX_INSET = 0.01,
        },

        variableViewer = {
            WIDTH = 0.24,
            LINE_HORIZONTAL_INSET = 0.01,
            LINE_VERTICAL_INSET = 0.025,
            BOTTOM_SPACE = 0.012,
            VARIABLE_MAX_STRING_LENGTH = 25,
            FUNCTION_CALL_SPACING = 0.007,
            FUNCTION_PARAM_MAX_STRING_LENGTH = 42,
            TEXT_SCALE = 0.9,
            GLOBAL_COLOR = "|cffaaaaff",
            LOCAL_COLOR = "|cffffffff",
            SCROLLER_VARIABLE_DISPLACEMENT = 0.009,
        },

        searchBar = {
            HORIZONTAL_INSET = 0.023,
            VERTICAL_INSET = 0.023,
            WIDTH = 0.15,
            HEIGHT = 0.04,
            SEARCH_FIELD_LEFT_INSET = 0.0,
            SEARCH_FIELD_RIGHT_INSET = 0.0,
            SEARCH_FIELD_TOP_INSET = 0.013,
            SEARCH_FIELD_BOTTOM_INSET = 0.0,
            SEARCH_BUTTON_INSET = 0.005,
            BUTTON_SIZE = 0.015,
            NUM_FINDS_LEFT_INSET = 0.009,
            NUM_FINDS_TOP_INSET = 0.01,
        },

        nameDialog = {
            WIDTH = 0.25,
            HEIGHT = 0.06,
            TITLE_VERTICAL_SHIFT = 0.012,
            ENTER_BOX_HORIZONTAL_INSET = 0.01,
            ENTER_BOX_VERTICAL_SHIFT = 0.025,
            ENTER_BOX_HEIGHT = 0.027,
        },

        flagsMenu = {
            WIDTH = 0.096,
            TEXT_INSET = 0.007,
            ARRAY_FIELD_OVERLAP = 0.005,
        },

        --This code gets appended to the beginning of the map script when enabling FINALIZE_MAP_SCRIPT. The default code consists of the WSCode initializers,
        --which is put here so that WSCode can be removed from the map without initialization breaking, as well as FileIO, as it is not supposed to be wrapped.
        MAP_SCRIPT_PREFIX = [=[
        if not WSCode then
            local init = {
                main = {},
                global = {},
                trig = {},
                map = {},
                essential = {},
                final = {},
                load = {},
                passes = {},
                highestPass = {
                    main = 1,
                    global = 1,
                    trig = 1,
                    map = 1,
                    final = 1,
                    load = 1
                }
            }

            local function ExecuteInitList(whichList)
                local passes = init.passes
                for i = 1, init.highestPass[whichList] or 1 do
                    for __, initializer in ipairs(init[whichList]) do
                        if passes[initializer] == i then
                            local success, err = pcall(initializer)
                            if not success and Debug then
                                Debug.throwError(err)
                            end
                        end
                    end
                end
            end

            local gmt = getmetatable(_G) or getmetatable(setmetatable(_G, {}))
            local rawIndex = gmt.__newindex or rawset

            local function hookMain(_G, key, fnOrDiscard)
                if key == "main" then
                    rawIndex(_G, key, function()
                        if gmt.__newindex == hookMain then
                            gmt.__newindex = rawIndex
                        end
                        ExecuteInitList("main")
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

                ExecuteInitList("global")

                if InitCustomTriggers then
                    local oldTrig = InitCustomTriggers
                    InitCustomTriggers = function()
                        oldTrig()
                        ExecuteInitList("trig")
                    end
                else
                    ExecuteInitList("trig")
                end

                if RunInitializationTriggers then
                    local oldMap = RunInitializationTriggers
                    RunInitializationTriggers = function()
                        oldMap()
                        ExecuteInitList("map")
                    end
                else
                    ExecuteInitList("map")
                end
            end

            local oldMark = MarkGameStarted
            MarkGameStarted = function()
                oldMark()
                ExecuteInitList("essential")
                ExecuteInitList("final")

                if #init.load > 0 then
                    local trig = CreateTrigger()
                    TriggerRegisterGameEvent(trig, EVENT_GAME_LOADED)
                    TriggerAddAction(trig, function()
                        local passes = init.passes
                        for i = 1, init.highestPass.load or 1 do
                            for __, initializer in ipairs(init.load) do
                                if passes[initializer] == i then
                                    initializer()
                                end
                            end
                        end
                    end)
                end
            end

            local function AddInit(whichFunc, onWhichPass, initPoint)
                init[initPoint][#init[initPoint] + 1] = whichFunc
                init.passes[whichFunc] = onWhichPass or 1
                if onWhichPass then
                    init.highestPass[initPoint] = onWhichPass > init.highestPass[initPoint] and onWhichPass or init.highestPass[initPoint]
                end
            end

            WSCode = {
                InitMain = function(whichFunc, onWhichPass, ...)
                    AddInit(whichFunc, onWhichPass, "main")
                end,

                InitGlobal = function(whichFunc, onWhichPass, ...)
                    AddInit(whichFunc, onWhichPass, "global")
                end,

                InitTrig = function(whichFunc, onWhichPass, ...)
                    AddInit(whichFunc, onWhichPass, "trig")
                end,

                InitMap = function(whichFunc, onWhichPass, ...)
                    AddInit(whichFunc, onWhichPass, "map")
                end,

                InitFinal = function(whichFunc, onWhichPass, ...)
                    AddInit(whichFunc, onWhichPass, "final")
                end,

                InitEssential = function(whichFunc, onWhichPass, ...)
                    AddInit(whichFunc, onWhichPass, "essential")
                end,

                InitLoad = function(whichFunc, onWhichPass)
                    AddInit(whichFunc, onWhichPass, "load")
                end
            }
        end
    ]=],
    }

    if not ToggleUIIfNecessary then
        function ToggleUIIfNecessary()
            local isVisible = not EditorCameraEnabled
                and not (CinematicStudio and CinematicStudio.IsInCinematic())
                and (not WSCode or not WSCode.IsVisible() or not WSCode.IsVisible())
                and not InCinematicStudioPluginAction
                and not (CarCamera and (CarCamera.IsLocked() or ReplayCamera.IsEnabled()))
            if not CarCamera or not CarCamera.IsLocked() then
                BlzHideOriginFrames(not isVisible)
            end
            for i = 0, 11 do
                BlzFrameSetVisible(BlzGetFrameByName("CommandButton_" .. i, 0), isVisible)
            end
            BlzFrameSetVisible(BlzFrameGetChild(BlzGetFrameByName("ConsoleUI", 0), 5), isVisible)
            BlzFrameSetEnable(BlzFrameGetChild(BlzGetFrameByName("ConsoleUI", 0), 5), isVisible)

            for i = 0, 5 do
                BlzFrameSetVisible(BlzGetOriginFrame(ORIGIN_FRAME_ITEM_BUTTON, i), isVisible)
                BlzFrameSetVisible(BlzGetFrameByName("InventoryButton_" .. i, 0), isVisible)
            end

            FogMaskEnable(isVisible)
            FogEnable(isVisible)

            local enableSelections = (isVisible or not CinematicStudio or not CinematicStudio.EditorEnabled)
                and not (CarCamera and CarCamera.IsLocked())
            EnableSelect(enableSelections, enableSelections)
            EnablePreSelect(enableSelections, enableSelections)
            EnableDragSelect(enableSelections, enableSelections)
            EnableOcclusion(enableSelections)

            if CarCamera and CarCamera.IsLocked() then
                CarCamera.Lock(USER_PLAYER, true)
            end

            if not enableSelections then
                ClearSelection()
            end
        end
    end
end
