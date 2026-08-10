HYDROSMART B.TECH THESIS — OVERLEAF PROJECT
==========================================

UPLOAD: Zip the folder HydroSmart_Thesis_LaTeX/ and upload to Overleaf as New Project -> Upload Project.

MAIN THESIS COMPILE:
  Menu: Menu -> Main document -> main.tex
  Compiler: pdfLaTeX
  Build: Recompile (pdfLaTeX -> BibTeX -> pdfLaTeX x2)

IEEE PAPER COMPILE (separate):
  Set main document to ieee/ieee_main.tex
  Same compiler chain; bibliography path is ../references.bib

CUSTOMIZE BEFORE SUBMISSION:
  Edit preamble.tex:
    \UniversityName, \StudentName, \StudentRoll, \SupervisorName

SCREENSHOTS:
  Add PNG files to figures/screenshots/
  Replace fbox placeholders in chapters/ch05_implementation.tex with:
    \includegraphics[width=0.85\textwidth]{figures/screenshots/home.png}

PAGE COUNT:
  Current source targets 100-120+ pages after screenshots and institution-specific front matter.
  Expand Chapter 2 or 5 prose on Overleaf if examiner requires 150 pages.

OLD MARKDOWN THESIS:
  docs/RESEARCH_THESIS/ is superseded by this LaTeX project for academic submission.
