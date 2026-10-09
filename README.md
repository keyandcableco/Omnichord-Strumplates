# Omnichord Strumplate Reproduction

<img src="om84_strumplate/images/version1p0.jpg" alt="flex PCB version 1.0" width="500">

## 🎥 Demo Video

[![OM-84 Flex PCB Demo](https://img.youtube.com/vi/RykH0IlZ8lg/maxresdefault.jpg)](https://youtube.com/shorts/RykH0IlZ8lg)

This project is an effort to reproduce the strumplate for the Suzuki Omnichord. It started with the OM-84 because that's what we had on hand, and now also covers the OM-27.

### Repo Structure

- `om84_strumplate/` — OM-84 work (flex PCB design, gerbers, references)
- `om27_strumplate/` — OM-27 work (in progress)
- `lib/keyandcable_branding.pretty/` — silkscreen footprints for the Key & Cable Co. logo lockup and the keyandcable.com QR code, printed on the ribbon tail of both flex PCBs

### Background

The Omnichord strumplate is a large capacitive touch sensor that lets you strum chords. Over time these plates commonly fail — the conductive surface wears out, traces crack, or sections stop responding.

Because the original strumplate is a glued multi-layer assembly, repairing or replacing it is extremely difficult. Original parts are long discontinued, and good donor units are hard to find.

### Project Goal

We're working on modern reproductions that can be used to restore broken units, starting with the OM-84 and OM-27.

A [brave technician](https://www.reddit.com/user/adamjsp/) is working to restore his own strumplate and generously shared high-quality scans. Those references are the main reason this project exists — we're now using them to design new, buildable versions.

### Current Status

Early stage. The goal is to create drop-in replacements that match the original feel and response as closely as possible.

**OM-84** (see `om84_strumplate/`)

UPDATE (JUNE 25, 2026)
Version 1.0 of the flex PCB works very well, may be a bit thin at 0.11mm, but certainly works. GERBERS updated, should come back from JLCPCB with no issue during review.

UPDATE (OCTOBER 8, 2026)
Both flex PCBs now carry the Key & Cable Co. logo, name and a QR code to keyandcable.com in white silkscreen on the ribbon tail, away from the contacts and the gold fingers. F_Silkscreen Gerbers and the production zips are updated.

**OM-27** (see `om27_strumplate/`)

Just getting started — early files only, nothing tested yet.

### 3D Printable Parts

There are now SCAD and STL files in progress for both models. The curves aren't quite right yet, so treat these as a starting point rather than final, print-ready parts.

### How to Help

- Getting the SCAD/STL curves dialed in for an accurate fit
- Measurements and dimensions of other models (e.g. OM-36)
- High-res photos of working and failed strumplates, all models

### To-Do
- ~~Tighten up gold teeth pitch, insertion errors sometimes?~~ Done: OM-84 and OM-27 gold fingers are now on a uniform 1.25 mm pitch, centred on the tail
- Perfect bottom curves of plates in SCAD
- Build guide, compare conductive layer materials
- Update OM-84 Kicad with full stiffener
- Clean up left-side alignment of stiffener layer in OM-27. Edges, too.

Feel free to open issues or pull requests if you want to contribute.

---

Any feedback or suggestions on the README itself is also welcome.

## License

Copyright © 2026 Greg Miller / The Key & Cable Company.

The strumplate designs (KiCad files, Gerbers, OpenSCAD models and artwork) are licensed under the [CERN Open Hardware Licence Version 2 – Strongly Reciprocal (CERN-OHL-S-2.0)](LICENSE). You can make, modify, sell and share hardware from them. If you share a modified design, or ship hardware made from one, you have to publish your design files under the same licence.

Source location: <https://github.com/keyandcableco/Omnichord-Strumplates>

Not covered, because they aren't ours to license:

- `om84_strumplate/3dp/om84_strumplate_v2_flat.*` and `om84_strumplate_v2_raised.*`, contributed by [AJ-EPS](https://github.com/AJ-EPS). They remain theirs.
- The photographs of the original Suzuki strumplate in `om84_strumplate/images/` (`Strum plate bottom + Trace plate top.jpg`, `Trace plate contact side.jpg`, `Trace plate top + Strum plate top.jpg`).

Omnichord is a trademark of Suzuki; it is used here only to say what these parts fit.
