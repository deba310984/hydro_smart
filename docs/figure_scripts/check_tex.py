"""Static validation of the generated LaTeX, since no TeX engine is installed here."""
import re, unicodedata
from collections import Counter
from pathlib import Path

TEX = Path(r"C:\hydro_smart\docs\latex\paper.tex")
FIGDIR = TEX.parent
t = TEX.read_text(encoding="utf-8")
BS = chr(92)

print("=== BRACE BALANCE ===")
depth = 0
first_bad = None
for i, ch in enumerate(t):
    esc = i > 0 and t[i - 1] == BS
    if ch == "{" and not esc:
        depth += 1
    elif ch == "}" and not esc:
        depth -= 1
        if depth < 0 and first_bad is None:
            first_bad = i
print("  final depth:", depth, "| first unmatched close at:", first_bad)

print("\n=== ENVIRONMENTS ===")
cb = Counter(re.findall(r"\\begin\{([A-Za-z]+\*?)\}", t))
ce = Counter(re.findall(r"\\end\{([A-Za-z]+\*?)\}", t))
for k in sorted(set(cb) | set(ce)):
    print(f"  {k:16s} begin={cb[k]:2d} end={ce[k]:2d}  "
          f"{'ok' if cb[k] == ce[k] else 'MISMATCH'}")

print("\n=== GRAPHICS ===")
imgs = re.findall(r"\\includegraphics\[[^\]]*\]\{([^}]+)\}", t)
missing = [g for g in imgs
           if not (FIGDIR / (g + ".png")).exists() and not (FIGDIR / g).exists()]
print(f"  {len(imgs)} includegraphics | missing: {missing or 'none'}")

print("\n=== LABELS / REFS ===")
labels = set(re.findall(r"\\label\{([^}]+)\}", t))
refs = set(re.findall(r"\\ref\{([^}]+)\}", t))
print("  labels:", len(labels), "refs:", len(refs))
print("  dangling refs :", sorted(refs - labels) or "none")
print("  unused labels :", sorted(labels - refs) or "none")

print("\n=== CITATIONS ===")
cites = set()
for c in re.findall(r"\\cite\{([^}]+)\}", t):
    cites |= {x.strip() for x in c.split(",")}
bibs = set(re.findall(r"\\bibitem\{([^}]+)\}", t))
print("  cited:", len(cites), "bibitems:", len(bibs))
print("  cited but missing:", sorted(cites - bibs) or "none")
print("  uncited entries  :", sorted(bibs - cites) or "none")

print("\n=== NON-ASCII ===")
na = sorted({c for c in t if ord(c) > 127})
print("  ", [f"{c!r} U+{ord(c):04X} {unicodedata.name(c, '?')}" for c in na]
      or "pure ASCII")

print("\n=== UNESCAPED SPECIALS ===")
bad_pct, bad_amp = [], []
for n, line in enumerate(t.splitlines(), 1):
    if line.lstrip().startswith("%"):
        continue
    code = line
    if re.search(r"(?<!\\)%", code):
        bad_pct.append((n, code.strip()[:60]))
    # '&' is legal only as a tabular separator (those lines end in \\)
    if re.search(r"(?<!\\)&", code) and not code.rstrip().endswith(BS * 2):
        bad_amp.append((n, code.strip()[:60]))
print("  unescaped % :", bad_pct or "none")
print("  stray &     :", bad_amp or "none")

print("\n=== TABULAR COLUMN COUNTS ===")
for m in re.finditer(r"\\begin\{tabular\}\{@\{\}([^}]*)@\{\}\}(.*?)\\end\{tabular\}", t, re.S):
    spec, body = m.group(1), m.group(2)
    ncol = len(re.findall(r"[lcr]", spec))
    rows = [r for r in body.split(BS * 2) if r.strip() and "rule" not in r]
    counts = {len(re.findall(r"(?<!\\)&", r)) + 1 for r in rows}
    print(f"  spec {spec!r}: {ncol} cols, row widths {sorted(counts)} "
          f"{'ok' if counts <= {ncol} else 'MISMATCH'}")

print(f"\n  {len(t.splitlines())} lines, {len(t)} chars")
