# Frosthaven Assistant — User Manual

A section-numbered HTML manual for Frosthaven Assistant. Section numbers
(`§N.M`) are stable identifiers; tests, bug reports, and cross-references
can cite them.

Open [`index.html`](index.html) in a browser to read.

## Layout

```
docs/
  manual/
    index.html                    TOC + status banner
    01-welcome.html
    02-quick-start.html           Black Barrow walkthrough (anchor scenario)
    03-anatomy.html               Top bar, main list, bottom bar, drawer
    04-setting-up.html
    05-round-step-by-step.html
    06-special-mechanics.html
    07-frosthaven.html            Loot, sanctuary, Buttons & Bugs
    08-edition-differences.html
    09-multiplayer.html
    10-mistakes-undo.html
    11-settings.html              Single grouped table
    12-walkthrough.html           Long-form Black Barrow narrative
    13-reference.html             Menu map, gestures, icons, shortcuts
    shared.css                    Single stylesheet linked from every chapter
    README.md                     This file
  screenshots/manual/
    sN-M-*.png                    Goldens, named after the manual section
                                  they illustrate
```

Each chapter file owns one top-level `<section id="sN">` and its
`<h3 id="sN-M">` (or `<th id="sN-M">`) sub-sections.

## Regenerating the manual

The manual's prose, sidebar/sub-TOC, and screenshot goldens are produced
by tooling kept on a separate branch and proposed as a follow-up PR. This
PR contains the rendered HTML + screenshots only. Edits to those rendered
files are fine, but the regenerator workflow (Flutter widget tests for
screenshots; Python scripts for nav injection and figure numbering) lives
outside this PR's scope.

## Conventions

- **Anchor scenario:** Black Barrow (Gloomhaven Scenario 1) with a Brute and
  optionally a Spellweaver. Most goldens use this roster. §4.4 (Add Section)
  switches to Gloomhaven 2E #19 *Military Outpost* because Black Barrow
  carries no sections.
- **Section numbers don't move.** If a chapter restructures, prefer adding
  new sub-section numbers over renumbering existing ones — external links
  (issues, BGG threads) cite `§X.Y`.
- **Table-only chapters use grouping rows** rather than `<h3>` headings.
  See `11-settings.html` for the pattern: `<tr class="group"><th colspan="N"
  id="sN-M">...</th></tr>`.
- **Don't duplicate rulebook content.** The manual covers the *app*; game
  rules belong to Cephalofair's rulebook. Cite, don't replicate.
