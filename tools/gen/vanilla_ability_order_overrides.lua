--- Parent rawcodes missing or empty in wc3_order_strings.csv but sharing cast orders with a sibling ability.
--- Merged into vanilla_ability_orders at bake time (does not overwrite CSV-derived entries).
return {
    -- Neutral immolation (AbilityIds.immolation) — same orders as AEim.
    ACim = { on = "immolation", off = "unimmolation" },
}
