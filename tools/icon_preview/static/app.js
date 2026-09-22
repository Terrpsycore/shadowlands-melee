let manifest = null;
let manifestGeneratedAt = null;
let selectedIconKey = null;
let selectedUnitSlug = null;
let selectedAbilitySlug = null;
let assignContext = null;
let pendingPick = null;

const UNIT_SECTIONS = [
  { title: "Heroes", class: "hero" },
  { title: "Units", class: "unit" },
  { title: "Buildings", class: "building" },
];

const els = {
  tabs: document.querySelectorAll(".tab"),
  pickerPanel: document.getElementById("picker-panel"),
  unitsPanel: document.getElementById("units-panel"),
  search: document.getElementById("search"),
  folderFilter: document.getElementById("folder-filter"),
  showUnavailable: document.getElementById("show-unavailable"),
  pickerCount: document.getElementById("picker-count"),
  iconGrid: document.getElementById("icon-grid"),
  pickerDetail: document.getElementById("picker-detail"),
  factionFilter: document.getElementById("faction-filter"),
  showParentOnly: document.getElementById("show-parent-only"),
  factionView: document.getElementById("faction-view"),
  unitDetail: document.getElementById("unit-detail"),
  reloadStatus: document.getElementById("reload-status"),
  assignBanner: document.getElementById("assign-banner"),
  assignTarget: document.getElementById("assign-target"),
  assignClear: document.getElementById("assign-clear"),
};

async function loadManifest() {
  const response = await fetch("/manifest.json", { cache: "no-store" });
  if (!response.ok) {
    throw new Error("manifest.json not found — run export.lua and build_cache.py");
  }
  manifest = await response.json();
  manifestGeneratedAt = manifest.generatedAt;
}

function findIcon(key) {
  if (!key || !manifest) {
    return null;
  }
  return manifest.icons.find((entry) => entry.key === key) || null;
}

function thumbUrl(key) {
  if (!key) {
    return "";
  }
  const icon = findIcon(key);
  const rel = icon?.thumb || `thumbs/${key}.png`;
  return `/.cache/${rel}?v=${encodeURIComponent(manifestGeneratedAt || "")}`;
}

function copyText(text) {
  navigator.clipboard.writeText(text).catch(() => {});
}

function escapeHtml(value) {
  return String(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function activateTab(name) {
  els.tabs.forEach((tab) => {
    tab.classList.toggle("active", tab.dataset.tab === name);
  });
  els.pickerPanel.classList.toggle("active", name === "picker");
  els.unitsPanel.classList.toggle("active", name === "units");
}

function renderTabs() {
  els.tabs.forEach((tab) => {
    tab.addEventListener("click", () => {
      activateTab(tab.dataset.tab);
      syncUrl();
    });
  });
}

function buildAssignContext(unitSlug, abilitySlug) {
  const unit = manifest.units.find((entry) => entry.slug === unitSlug);
  if (!unit) {
    return null;
  }
  if (!abilitySlug) {
    return { kind: "unit", unitSlug, unit };
  }
  const group = unit.groups.find((entry) => entry.slots.some((slot) => slot.ability === abilitySlug));
  const slot = group?.slots.find((entry) => entry.ability === abilitySlug);
  return { kind: "ability", unitSlug, abilitySlug, unit, group, slot };
}

function rehydrateAssignContext() {
  if (!assignContext) {
    return;
  }
  const next = buildAssignContext(assignContext.unitSlug, assignContext.abilitySlug);
  assignContext = next;
  if (assignContext) {
    els.assignTarget.textContent = assignContext.abilitySlug
      ? `${assignContext.unitSlug} → ${assignContext.abilitySlug}`
      : `${assignContext.unitSlug} (portrait)`;
    els.assignBanner.classList.remove("hidden");
  } else {
    els.assignBanner.classList.add("hidden");
  }
}

function rehydrateContext() {
  if (selectedUnitSlug) {
    const unit = manifest.units.find((entry) => entry.slug === selectedUnitSlug);
    if (!unit) {
      selectedUnitSlug = null;
      selectedAbilitySlug = null;
    } else if (selectedAbilitySlug) {
      const hasAbility = unit.groups.some((group) =>
        group.slots.some((slot) => slot.ability === selectedAbilitySlug));
      if (!hasAbility) {
        selectedAbilitySlug = null;
      }
    }
    if (unit && els.factionFilter.value !== unit.faction) {
      els.factionFilter.value = unit.faction;
    }
  }

  if (selectedIconKey && !findIcon(selectedIconKey)) {
    selectedIconKey = null;
  }

  rehydrateAssignContext();
}

function syncUrl() {
  const params = new URLSearchParams();
  if (selectedUnitSlug) {
    params.set("u", selectedUnitSlug);
  }
  if (selectedAbilitySlug) {
    params.set("a", selectedAbilitySlug);
  }
  if (selectedIconKey) {
    params.set("i", selectedIconKey);
  }
  if (assignContext) {
    const pick = assignContext.abilitySlug
      ? `${assignContext.unitSlug}/${assignContext.abilitySlug}`
      : assignContext.unitSlug;
    params.set("p", pick);
  }
  const query = params.toString();
  history.replaceState(null, "", query ? `?${query}` : location.pathname);
}

function readUrl() {
  const params = new URLSearchParams(location.search);
  selectedUnitSlug = params.get("u");
  selectedAbilitySlug = params.get("a");
  selectedIconKey = params.get("i");
  pendingPick = params.get("p");

  if (selectedUnitSlug || pendingPick) {
    activateTab("units");
  } else if (selectedIconKey) {
    activateTab("picker");
  }
}

function applyUrlState() {
  if (pendingPick) {
    const slash = pendingPick.indexOf("/");
    const unitSlug = slash >= 0 ? pendingPick.slice(0, slash) : pendingPick;
    const abilitySlug = slash >= 0 ? pendingPick.slice(slash + 1) : null;
    assignContext = buildAssignContext(unitSlug, abilitySlug || null);
    if (assignContext) {
      selectedUnitSlug = unitSlug;
      selectedAbilitySlug = abilitySlug || null;
      els.assignTarget.textContent = abilitySlug
        ? `${unitSlug} → ${abilitySlug}`
        : `${unitSlug} (portrait)`;
      els.assignBanner.classList.remove("hidden");
    }
    pendingPick = null;
  }
}

function applyUrlFaction() {
  if (!selectedUnitSlug || !manifest) {
    return;
  }
  const unit = manifest.units.find((entry) => entry.slug === selectedUnitSlug);
  if (unit?.faction) {
    els.factionFilter.value = unit.faction;
  }
}

function iconButtonStem(path) {
  const name = (path || "").split(/[/\\]/).pop() || "";
  return name.replace(/\.(blp|dds)$/i, "");
}

function isAutocastIcon(icon) {
  const stem = iconButtonStem(icon.path);
  const btnMatch = stem.match(/^BTN(.+)$/i);
  if (btnMatch) {
    const name = btnMatch[1];
    if (/(?:OnOff|On|Off)$/.test(name)) {
      return true;
    }
    if (/(?:onoff|off)$/i.test(name)) {
      return true;
    }
    if (/on$/i.test(name) && !/(?:tion|moon|dragon|peon|mon|ion|son|gon|don|con)$/i.test(name)) {
      return true;
    }
  }
  return /(?:OnOff|On|Off)$/.test(icon.key || "");
}

function iconPickerFolder(icon) {
  if (isAutocastIcon(icon)) {
    return "AutocastButtons";
  }
  return icon.folder;
}

function iconMatchesFolder(icon, folder) {
  if (folder === "all") {
    return true;
  }
  if (folder === "AutocastButtons") {
    return isAutocastIcon(icon);
  }
  if (folder === "CommandButtons") {
    return icon.folder === "CommandButtons" && !isAutocastIcon(icon);
  }
  return icon.folder === folder;
}

function iconMatchesSearch(icon, query) {
  if (!query) {
    return true;
  }
  const haystack = `${icon.key} ${icon.path}`.toLowerCase();
  return haystack.includes(query);
}

function filteredIcons() {
  const query = els.search.value.trim().toLowerCase();
  const folder = els.folderFilter.value;
  const showUnavailable = els.showUnavailable.checked;
  return manifest.icons.filter((icon) => {
    if (!showUnavailable && icon.available === false) {
      return false;
    }
    if (!iconMatchesFolder(icon, folder)) {
      return false;
    }
    return iconMatchesSearch(icon, query);
  });
}

function iconExpr(icon) {
  return icon.iconExpr || `Icons.${icon.key}`;
}

function renderPickerDetail(icon) {
  if (!icon) {
    els.pickerDetail.innerHTML = '<div class="detail-empty">Выберите иконку</div>';
    return;
  }

  const expr = iconExpr(icon);
  const snippet = `art = { icon = ${expr} },`;
  const assignBlock = assignContext
    ? `<p>Контекст: <code>${escapeHtml(assignContext.unitSlug)}</code>${assignContext.abilitySlug ? ` → <code>${escapeHtml(assignContext.abilitySlug)}</code>` : " (portrait)"}</p>`
    : "";
  const unavailableBlock =
    icon.available === false
      ? `<p class="warn">Недоступна в dump (${escapeHtml(icon.missingReason || "missing")})</p>`
      : "";

  els.pickerDetail.innerHTML = `
    <img class="preview" src="${thumbUrl(icon.key)}" alt="">
    <dl>
      <dt>Key</dt><dd>${escapeHtml(icon.key)}</dd>
      <dt>Path</dt><dd>${escapeHtml(icon.path)}</dd>
      <dt>Folder</dt><dd>${escapeHtml(iconPickerFolder(icon))}</dd>
    </dl>
    ${unavailableBlock}
    ${assignBlock}
    <pre>${escapeHtml(snippet)}</pre>
    <button type="button" data-copy="${escapeHtml(expr)}">Copy ${escapeHtml(expr)}</button>
    <button type="button" data-copy="${escapeHtml(icon.path)}">Copy path</button>
    <button type="button" data-copy="${escapeHtml(snippet)}">Copy snippet</button>
  `;

  els.pickerDetail.querySelectorAll("[data-copy]").forEach((button) => {
    button.addEventListener("click", () => copyText(button.dataset.copy));
  });

  if (assignContext?.kind === "unit") {
    const unit = manifest.units.find((entry) => entry.slug === assignContext.unitSlug);
    if (unit) {
      renderUnitDetail(unit, icon);
    }
  } else if (assignContext?.kind === "ability") {
    selectedUnitSlug = assignContext.unitSlug;
    selectedAbilitySlug = assignContext.abilitySlug;
    renderFactionView();
    renderUnitDetail(assignContext.unit, icon);
    syncUrl();
  }
}

function renderIconGrid() {
  const icons = filteredIcons();
  const hiddenCount = manifest.icons.filter((icon) => icon.available === false).length;
  const hiddenSuffix =
    hiddenCount > 0 && !els.showUnavailable.checked ? ` (${hiddenCount} hidden)` : "";
  els.pickerCount.textContent = `${icons.length} icons${hiddenSuffix}`;
  els.iconGrid.innerHTML = "";

  for (const icon of icons) {
    const cell = document.createElement("button");
    cell.type = "button";
    cell.className =
      "icon-cell" +
      (selectedIconKey === icon.key ? " selected" : "") +
      (icon.available === false ? " unavailable" : "");
    cell.innerHTML = `
      ${iconPickerFolder(icon) === "PassiveButtons" ? '<span class="badge">PAS</span>' : ""}
      ${iconPickerFolder(icon) === "AutocastButtons" ? '<span class="badge badge-autocast">AC</span>' : ""}
      <img loading="lazy" src="${thumbUrl(icon.key)}" alt="">
      <div class="key">${escapeHtml(icon.key)}</div>
    `;
    cell.addEventListener("click", () => {
      selectedIconKey = icon.key;
      renderIconGrid();
      renderPickerDetail(icon);
      syncUrl();
    });
    els.iconGrid.appendChild(cell);
  }

  if (selectedIconKey) {
    renderPickerDetail(findIcon(selectedIconKey));
  }
}

function manifestFactions() {
  const factions = [];
  const seen = new Set();
  for (const unit of manifest.units) {
    if (unit.faction && !seen.has(unit.faction)) {
      seen.add(unit.faction);
      factions.push(unit.faction);
    }
  }
  return factions;
}

function populateFactionFilter() {
  const factions = manifestFactions();

  const current = els.factionFilter.value;
  els.factionFilter.innerHTML = "";

  for (const faction of factions) {
    const option = document.createElement("option");
    option.value = faction;
    option.textContent = faction;
    els.factionFilter.appendChild(option);
  }

  if (current && [...factions].includes(current)) {
    els.factionFilter.value = current;
  } else if (els.factionFilter.options.length > 0) {
    els.factionFilter.selectedIndex = 0;
  }
}

function factionUnits(faction, unitClass) {
  return manifest.units.filter((unit) => unit.faction === faction && unit.class === unitClass);
}

function renderFactionView() {
  const faction = els.factionFilter.value;
  if (!faction) {
    els.factionView.innerHTML = '<div class="detail-empty">No factions</div>';
    return;
  }

  let html = "";
  for (const section of UNIT_SECTIONS) {
    const units = factionUnits(faction, section.class);
    if (units.length === 0) {
      continue;
    }

    html += `<div class="section-title">${section.title}</div><div class="unit-grid">`;
    for (const unit of units) {
      const selected = selectedUnitSlug === unit.slug ? " selected" : "";
      const portrait = unit.iconKey
        ? `<img loading="lazy" src="${thumbUrl(unit.iconKey)}" alt="">`
        : `<div class="no-portrait">?</div>`;
      html += `
        <button type="button" class="unit-tile${selected}" data-slug="${escapeHtml(unit.slug)}">
          ${portrait}
          <div class="unit-name">${escapeHtml(unit.name)}</div>
          <div class="unit-slug">${escapeHtml(unit.slug)}</div>
        </button>
      `;
    }
    html += "</div>";
  }

  els.factionView.innerHTML = html || '<div class="detail-empty">No units in faction</div>';

  els.factionView.querySelectorAll(".unit-tile").forEach((button) => {
    button.addEventListener("click", () => {
      selectedUnitSlug = button.dataset.slug;
      selectedAbilitySlug = null;
      renderFactionView();
      const unit = manifest.units.find((entry) => entry.slug === selectedUnitSlug);
      renderUnitDetail(unit, selectedIconKey ? findIcon(selectedIconKey) : null);
      syncUrl();
    });
  });
}

function buildGridSlots(group) {
  const grid = Array.from({ length: 3 }, () => Array.from({ length: 4 }, () => null));
  for (const slot of group.slots) {
    if (slot.y >= 0 && slot.y < 3 && slot.x >= 0 && slot.x < 4) {
      grid[slot.y][slot.x] = slot;
    }
  }
  return grid;
}

function renderCommandCardHtml(unit) {
  const group = unit.groups?.[0];
  if (!group || group.slots.length === 0) {
    return '<div class="detail-empty">No abilities</div>';
  }

  const highlightParent = els.showParentOnly.checked;
  const grid = buildGridSlots(group);
  let html = '<div class="command-card-section"><div class="command-grid">';

  for (let y = 0; y < 3; y += 1) {
    for (let x = 0; x < 4; x += 1) {
      const slot = grid[y][x];
      if (!slot) {
        html += `<div class="slot empty"></div>`;
        continue;
      }

      const img = slot.iconKey
        ? `<img src="${thumbUrl(slot.iconKey)}" alt="">`
        : "";

      if (slot.kind === "order") {
        html += `
          <div class="slot order" title="${escapeHtml(slot.name)}">
            ${img}
          </div>
        `;
        continue;
      }

      const classes = ["slot"];
      if (
        selectedUnitSlug === unit.slug
        && selectedAbilitySlug === slot.ability
      ) {
        classes.push("selected");
      }
      if (highlightParent && slot.iconSource === "parent") {
        classes.push("parent-only");
      }

      html += `
        <button type="button" class="${classes.join(" ")}" data-ability="${escapeHtml(slot.ability)}" title="${escapeHtml(slot.ability)} — dblclick: Pick icon">
          ${img}
        </button>
      `;
    }
  }

  html += "</div></div>";
  return html;
}

function unitWarnings(unit) {
  return manifest.warnings.filter((warning) => warning.unit === unit.slug);
}

function abilityDetailData(slot, pickedIcon) {
  const currentExpr = slot.iconExpr || (slot.iconKey ? `Icons.${slot.iconKey}` : "—");
  const pickedExpr = pickedIcon ? iconExpr(pickedIcon) : null;
  const snippet = `art = { icon = ${pickedExpr || currentExpr} },`;
  const buttonInfo = slot.declaredButton
    ? `${slot.declaredButton[0]}, ${slot.declaredButton[1]}${slot.shifted ? ` → display ${slot.x}, ${slot.y}` : ""}`
    : `${slot.x}, ${slot.y}`;
  return { currentExpr, pickedExpr, snippet, buttonInfo };
}

function renderAbilityDetail(slot, pickedIcon) {
  if (!slot) {
    return "";
  }

  const { currentExpr, pickedExpr, snippet, buttonInfo } = abilityDetailData(slot, pickedIcon);

  return `
    <div class="ability-detail">
      <div class="subsection-title">${escapeHtml(slot.ability)}</div>
      <div class="ability-detail-actions">
        <button type="button" class="open-picker pick-primary" data-kind="ability" data-ability="${escapeHtml(slot.ability)}">Pick icon…</button>
        <button type="button" class="copy-snippet" data-copy="${escapeHtml(snippet)}">Copy snippet</button>
      </div>
      <dl>
        <dt>Button</dt><dd>${escapeHtml(buttonInfo)}</dd>
        <dt>Current icon</dt><dd>${escapeHtml(currentExpr)} <span class="muted">[${escapeHtml(slot.iconSource)}]</span></dd>
        ${pickedExpr ? `<dt>Selected</dt><dd>${escapeHtml(pickedExpr)}</dd>` : ""}
      </dl>
      <pre>${escapeHtml(snippet)}</pre>
    </div>
  `;
}

function renderAbilityActionBar(slot, pickedIcon) {
  if (!slot) {
    return "";
  }

  const { currentExpr, snippet } = abilityDetailData(slot, pickedIcon);

  return `
    <div class="ability-action-bar">
      <div class="ability-label"><strong>${escapeHtml(slot.ability)}</strong> · ${escapeHtml(currentExpr)}</div>
      <button type="button" class="open-picker pick-primary" data-kind="ability" data-ability="${escapeHtml(slot.ability)}">Pick icon…</button>
      <button type="button" class="copy-snippet" data-copy="${escapeHtml(snippet)}">Copy snippet</button>
    </div>
  `;
}

function openPickerForUnit(unit, kind, abilitySlug) {
  if (kind === "unit") {
    assignContext = buildAssignContext(unit.slug, null);
    els.assignTarget.textContent = `${unit.slug} (portrait)`;
  } else {
    assignContext = buildAssignContext(unit.slug, abilitySlug);
    els.assignTarget.textContent = `${unit.slug} → ${abilitySlug}`;
  }
  els.assignBanner.classList.remove("hidden");
  activateTab("picker");
  syncUrl();
  els.search.focus();
}

function renderUnitDetail(unit, pickedIcon) {
  if (!unit) {
    els.unitDetail.innerHTML = '<div class="detail-empty">Выберите юнита</div>';
    return;
  }

  const portraitExpr = unit.iconExpr || (unit.iconKey ? `Icons.${unit.iconKey}` : "—");
  const pickedExpr = pickedIcon ? iconExpr(pickedIcon) : null;
  const portraitSnippet = portraitExpr !== "—"
    ? `art = { icon = ${pickedExpr || portraitExpr} },`
    : null;

  const warnings = unitWarnings(unit);
  const warningsHtml = warnings.length
    ? warnings.map((warning) => `<div class="warning">${escapeHtml(warning.message)}</div>`).join("")
    : "";

  const selectedSlot = selectedAbilitySlug
    ? unit.groups.flatMap((group) => group.slots).find((slot) => slot.ability === selectedAbilitySlug)
    : null;

  let scrollHtml = `
    <div class="unit-header">
      ${unit.iconKey ? `<img class="preview" src="${thumbUrl(unit.iconKey)}" alt="">` : ""}
      <div>
        <h2>${escapeHtml(unit.name)}</h2>
        <div class="meta">${escapeHtml(unit.slug)} · ${escapeHtml(unit.faction)} · ${escapeHtml(unit.class)}</div>
      </div>
    </div>
  `;

  scrollHtml += warningsHtml;
  scrollHtml += renderCommandCardHtml(unit);

  if (selectedSlot) {
    scrollHtml += renderAbilityDetail(selectedSlot, pickedIcon);
  }

  scrollHtml += `
    <details class="portrait-meta"${selectedSlot ? "" : " open"}>
      <summary>Portrait · ${escapeHtml(portraitExpr)}</summary>
      <dl>
        <dt>Path</dt><dd>${escapeHtml(portraitExpr)} <span class="muted">[${escapeHtml(unit.iconSource || "missing")}]</span></dd>
        ${unit.parent ? `<dt>Parent</dt><dd>${escapeHtml(unit.parent)}</dd>` : ""}
        ${pickedExpr ? `<dt>Selected</dt><dd>${escapeHtml(pickedExpr)}</dd>` : ""}
      </dl>
  `;

  if (portraitSnippet) {
    scrollHtml += `
      <pre>${escapeHtml(portraitSnippet)}</pre>
      <div class="meta-actions">
        <button type="button" class="copy-snippet" data-copy="${escapeHtml(portraitSnippet)}">Copy portrait snippet</button>
        <button type="button" class="open-picker" data-kind="unit">Pick portrait…</button>
      </div>
    `;
  }

  scrollHtml += "</details>";

  els.unitDetail.innerHTML = `
    <div class="unit-detail-scroll">${scrollHtml}</div>
    ${selectedSlot ? renderAbilityActionBar(selectedSlot, pickedIcon) : ""}
  `;

  els.unitDetail.querySelectorAll(".copy-snippet").forEach((button) => {
    button.addEventListener("click", () => copyText(button.dataset.copy));
  });

  els.unitDetail.querySelectorAll(".open-picker").forEach((button) => {
    button.addEventListener("click", () => {
      openPickerForUnit(unit, button.dataset.kind, button.dataset.ability);
    });
  });

  els.unitDetail.querySelectorAll(".slot:not(.empty):not(.order)").forEach((button) => {
    button.addEventListener("click", () => {
      selectedAbilitySlug = button.dataset.ability;
      renderUnitDetail(unit, selectedIconKey ? findIcon(selectedIconKey) : null);
      syncUrl();
    });
    button.addEventListener("dblclick", (event) => {
      event.preventDefault();
      selectedAbilitySlug = button.dataset.ability;
      renderUnitDetail(unit, selectedIconKey ? findIcon(selectedIconKey) : null);
      openPickerForUnit(unit, "ability", button.dataset.ability);
    });
  });

  syncUrl();
}

function rerenderAll({ preserveScroll = false } = {}) {
  const unitDetailScrollEl = els.unitDetail.querySelector(".unit-detail-scroll");
  const factionScroll = preserveScroll ? els.factionView.scrollTop : 0;
  const iconScroll = preserveScroll ? els.iconGrid.scrollTop : 0;
  const unitDetailScroll = preserveScroll && unitDetailScrollEl ? unitDetailScrollEl.scrollTop : 0;

  populateFactionFilter();
  applyUrlFaction();
  rehydrateContext();
  renderIconGrid();
  renderFactionView();
  if (selectedUnitSlug) {
    const unit = manifest.units.find((entry) => entry.slug === selectedUnitSlug);
    if (unit) {
      renderUnitDetail(unit, selectedIconKey ? findIcon(selectedIconKey) : null);
    } else {
      selectedUnitSlug = null;
      selectedAbilitySlug = null;
      els.unitDetail.innerHTML = '<div class="detail-empty">Выберите юнита</div>';
      syncUrl();
    }
  }

  if (preserveScroll) {
    els.factionView.scrollTop = factionScroll;
    els.iconGrid.scrollTop = iconScroll;
    const scrollEl = els.unitDetail.querySelector(".unit-detail-scroll");
    if (scrollEl) {
      scrollEl.scrollTop = unitDetailScroll;
    }
  }
}

function wireFilters() {
  els.search.addEventListener("input", renderIconGrid);
  els.folderFilter.addEventListener("change", renderIconGrid);
  els.showUnavailable.addEventListener("change", renderIconGrid);
  els.factionFilter.addEventListener("change", () => {
    selectedUnitSlug = null;
    selectedAbilitySlug = null;
    renderFactionView();
    els.unitDetail.innerHTML = '<div class="detail-empty">Выберите юнита</div>';
    syncUrl();
  });
  els.showParentOnly.addEventListener("change", () => {
    if (selectedUnitSlug) {
      const unit = manifest.units.find((entry) => entry.slug === selectedUnitSlug);
      renderUnitDetail(unit, selectedIconKey ? findIcon(selectedIconKey) : null);
    }
  });
}

function wireAssignBanner() {
  els.assignClear.addEventListener("click", () => {
    assignContext = null;
    els.assignBanner.classList.add("hidden");
    syncUrl();
  });
}

async function pollManifest() {
  try {
    const response = await fetch("/manifest.json", { cache: "no-store" });
    if (!response.ok) {
      return;
    }
    const data = await response.json();
    if (data.generatedAt && data.generatedAt !== manifestGeneratedAt) {
      manifest = data;
      manifestGeneratedAt = data.generatedAt;
      els.reloadStatus.textContent = "updated";
      rerenderAll({ preserveScroll: true });
      window.setTimeout(() => {
        els.reloadStatus.textContent = "";
      }, 2000);
    }
  } catch {
    // ignore transient fetch errors while server rebuilds
  }
}

async function init() {
  renderTabs();
  wireFilters();
  wireAssignBanner();
  readUrl();
  await loadManifest();
  applyUrlState();
  rerenderAll();
  window.setInterval(pollManifest, 1500);
}

init().catch((error) => {
  document.body.innerHTML = `<pre style="padding:24px;color:#ffb454">${escapeHtml(error.message)}</pre>`;
});
