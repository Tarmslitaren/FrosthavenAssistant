#!/usr/bin/env python3
"""
Extract all translatable strings from edition JSON files and write
assets/i18n/en.json as the translation template.

Run from the frosthaven_assistant/ directory:
    python3 scripts/extract_i18n.py
"""

import json
import os
import re
import glob

EDITIONS_DIR = os.path.join("assets", "data", "editions")
OUTPUT = os.path.join("assets", "i18n", "en.json")

# Strings that are purely visual control markers, not human text.
_CONTROL_STRINGS = frozenset(
    ["*", "[r]", "[s]", "[c]", "[/r]", "[/s]", "[newLine]",
     "[subLineStart]", "[subLineEnd]", "[conditionalStart]"]
)


def _has_english_text(s: str) -> bool:
    """Return True if s contains letters outside of %token% placeholders."""
    if not isinstance(s, str):
        return False
    if s.startswith("*"):
        return False
    stripped = re.sub(r"%[^%]+%", "", s)
    stripped = re.sub(r"\[/?[a-zA-Z]+\]", "", stripped)
    stripped = stripped.lstrip("^*! ")
    return bool(re.search(r"[a-zA-Z]", stripped))


def _add(bucket: dict, s: str) -> None:
    if isinstance(s, str) and s not in bucket:
        bucket[s] = s


def extract(editions_dir: str) -> dict:
    result: dict = {
        "names": {},
        "cardText": {},
        "special": {},
        "perks": {},
        "messages": {},
    }

    for filepath in sorted(glob.glob(os.path.join(editions_dir, "*.json"))):
        with open(filepath, encoding="utf-8") as fh:
            data = json.load(fh)

        # --- ability deck names + card text ---
        for deck in data.get("monsterAbilities", []):
            name = deck.get("name", "")
            if name:
                _add(result["names"], name)
            for card in deck.get("cards", []):
                if not isinstance(card, list):
                    continue
                for idx, elem in enumerate(card):
                    if not isinstance(elem, str) or elem in _CONTROL_STRINGS:
                        continue
                    if idx == 0:
                        # Card title — always translatable
                        _add(result["cardText"], elem)
                    elif idx >= 4 and _has_english_text(elem):
                        _add(result["cardText"], elem)

        # --- monster display names + special text ---
        for monster in data.get("monsters", {}).values():
            display = monster.get("display", "")
            if display:
                _add(result["names"], display)
            for lvl in monster.get("levels", []):
                for fig_type in ("normal", "elite", "boss"):
                    fig = lvl.get(fig_type, {})
                    for field in ("special1", "special2", "attributes"):
                        for item in fig.get(field, []):
                            if isinstance(item, str) and _has_english_text(item):
                                _add(result["special"], item)

        # --- class names, summon names, perks ---
        for cc in data.get("classes", []):
            name = cc.get("name", "")
            if name:
                _add(result["names"], name)
            for summon_name in cc.get("summons", {}).keys():
                _add(result["names"], summon_name)
            for perk in cc.get("perks", []):
                text = perk.get("text", "")
                if text:
                    _add(result["perks"], text)

        # --- scenario names + initial messages ---
        scenarios = data.get("scenarios", {})
        if isinstance(scenarios, dict):
            for scenario_key, scenario_val in scenarios.items():
                if _has_english_text(scenario_key):
                    _add(result["names"], scenario_key)
                if isinstance(scenario_val, dict):
                    msg = scenario_val.get("initialMessage", "")
                    if msg and _has_english_text(msg):
                        _add(result["messages"], msg)

    return result


def main() -> None:
    result = extract(EDITIONS_DIR)
    for category, entries in result.items():
        print(f"  {category}: {len(entries)}")

    with open(OUTPUT, "w", encoding="utf-8") as fh:
        json.dump(result, fh, indent=2, ensure_ascii=False)
        fh.write("\n")

    total = sum(len(v) for v in result.values())
    print(f"Written {total} strings to {OUTPUT}")


if __name__ == "__main__":
    main()
