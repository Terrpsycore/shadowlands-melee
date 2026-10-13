---Bootstrap toggles (edit + rebuild map; no runtime UI).
return {
    ---When false: skip WSCode preinit (A/B vs nil-global / sourceMap size).
    ENABLE_WSCODE = true,
    ---Experimental: WSCode debug transpile for scenario/ (breakpoints often still flaky). Off = raw require.
    ENABLE_WSCODE_SCENARIO_DEBUG = false,
}
