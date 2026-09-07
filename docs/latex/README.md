# HydroSmart — IEEE paper, LaTeX source

LaTeX source for *An AI-Integrated Hydroponics Management System with Edge pH
Telemetry and Gradient-Boosted Crop Recommendation*, matching the `.docx` and
PDF in `docs/`.

```
paper.tex        IEEEtran conference paper, self-contained (bibliography inline)
figures/         14 PNGs at 300 dpi, referenced by \includegraphics
```

## Building

**Overleaf** (easiest — `IEEEtran.cls` is already installed there):
upload `paper.tex` and the `figures/` folder, set the compiler to pdfLaTeX,
and compile.

**Locally**, with TeX Live or MiKTeX:

```bash
pdflatex paper
pdflatex paper      # second pass resolves \ref and \cite
```

Two passes are required. The first writes `paper.aux`; the second turns the
`??` placeholders into real figure, table and reference numbers.

No `.bib` file is needed — the references are a `thebibliography` environment
inside `paper.tex`.

### Packages used

`cite`, `amsmath`, `amssymb`, `graphicx`, `booktabs`, `textcomp`, `xcolor`,
`fontenc`, `inputenc`, `url`. All are in the standard TeX Live and MiKTeX
distributions. `IEEEtran.cls` ships with both; if a local install lacks it,
fetch it from CTAN (`https://ctan.org/pkg/ieeetran`) into this directory.

## Regenerating

`paper.tex` is generated, not hand-written:

```bash
python ../figure_scripts/make_latex.py
```

It reads `results.json` — the same file the `.docx` build consumes — so both
renderings report identical measured values. **Edit the generator, not
`paper.tex`**, or your changes will be overwritten and the two versions will
drift apart.

To regenerate the underlying numbers and figures from scratch:

```bash
python ../figure_scripts/experiments.py    # 11 experiments -> results.json + figures
python ../figure_scripts/diagrams.py       # architecture schematic
python ../figure_scripts/compact_figs.py   # compact pipeline / per-class figures
python ../figure_scripts/recm.py           # confusion matrix at print size
python ../figure_scripts/relatency.py      # single-threaded latency benchmark
python ../figure_scripts/refigs.py         # remaining redraws
```

Expect roughly 40 minutes; the cross-validation and repeated retraining
dominate. `SEED = 42` throughout, so results are reproducible.

## Verification status

Validated statically — brace balance, environment matching, all 14
`\includegraphics` targets present, 26 labels against 26 references with none
dangling, 15 citations against 15 bibliography entries with none orphaned,
tabular column counts consistent with their specs, and pure ASCII throughout
(no encoding surprises).

**Not compiled.** No TeX engine was available on the machine where this was
generated, so the PDF output has not been inspected. The `.docx` and PDF in
`docs/` were rendered and checked visually and run to seven pages; LaTeX
paginates differently, so verify the page count after your first build. If it
overruns, the usual levers are the `[!t]` float placements and the
`0.66\textwidth` on the confusion matrix.
