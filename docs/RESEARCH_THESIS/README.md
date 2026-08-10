# HydroSmart Research Thesis — Document Set

## Quick Start

1. Open **`00_MASTER_TABLE_OF_CONTENTS.md`** for the full table of contents.
2. Read volumes in order: `VOL1` → `VOL2` → `VOL3` → `VOL4`.
3. Use **`APPENDIX_F_COMPLETE_DART_FILE_CATALOG.md`** for per-file Dart documentation.

## Export on Windows (no Pandoc in PATH)

`pandoc` is not installed globally on this machine. Use one of these options:

### Option A — Script (recommended)

```powershell
cd "d:\hydroponics\hydro_smart\docs\RESEARCH_THESIS"
.\generate_thesis.ps1
```

This creates **`HydroSmart_Thesis_Complete.docx`** and **`.html`**.  
For PDF: open the DOCX in **Microsoft Word** → **File → Save As → PDF**.

Portable Pandoc (if missing): `D:\hydroponics\tools\pandoc\pandoc-3.6.4\pandoc.exe`

### Option B — Install Pandoc system-wide

1. Download installer: https://github.com/jgm/pandoc/releases/latest  
2. Restart PowerShell, then run `generate_thesis.ps1` or add PDF export after installing **MiKTeX** (for `pdflatex`).

### Option C — Direct PDF via Pandoc (needs LaTeX)

```powershell
$pandoc = "D:\hydroponics\tools\pandoc\pandoc-3.6.4\pandoc.exe"
cd "d:\hydroponics\hydro_smart\docs\RESEARCH_THESIS"
& $pandoc HydroSmart_Thesis_Complete.md -o HydroSmart_Thesis_Complete.pdf --toc --number-sections
```

Requires MiKTeX: https://miktex.org/download

Add screenshots from the Android emulator under Chapter 15 before final submission.

## Document Statistics (Approximate)

| File | Words (est.) | Pages (est.) |
|------|--------------|--------------|
| VOL1 | ~4,500 | 28 |
| VOL2 | ~4,200 | 26 |
| VOL3 | ~3,800 | 24 |
| VOL4 | ~4,000 | 26 |
| APPENDIX F | ~3,500 | 22 |
| **Total** | **~20,000** | **~126** |

*Page counts assume A4, 11pt, 1.5 spacing with diagrams.*

## Customization

Replace placeholders in `00_MASTER_TABLE_OF_CONTENTS.md`:
- `[Insert University Name]`
- `[Insert Guide Name]`

## Related Repository Docs

- `APP_FULL_TECHNICAL_DOCUMENTATION.md` — engineering runbook
- `RAG_IMPLEMENTATION_GUIDE.md` — RAG deep dive
- `ml_backend/ML_DEPLOYMENT_GUIDE.md` — ML deployment
