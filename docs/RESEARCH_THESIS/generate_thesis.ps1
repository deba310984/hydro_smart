# Generate thesis outputs (DOCX + HTML). PDF via Word or install MiKTeX for pdflatex.
$ErrorActionPreference = "Stop"
$here = $PSScriptRoot
$pandoc = "D:\hydroponics\tools\pandoc\pandoc-3.6.4\pandoc.exe"

if (-not (Test-Path $pandoc)) {
    Write-Host "Pandoc not found at $pandoc"
    Write-Host "Download: https://github.com/jgm/pandoc/releases"
    exit 1
}

$files = @(
    "00_MASTER_TABLE_OF_CONTENTS.md",
    "VOL1_CH01-05_REVERSE_ENGINEERING_AND_CODE.md",
    "VOL2_CH06-10_FRONTEND_BACKEND_FIREBASE_AI.md",
    "VOL3_CH11-15_ENGINEERING_TESTING_PERFORMANCE.md",
    "VOL4_CH16-20_IEEE_SCREEN_APPENDICES.md",
    "APPENDIX_F_COMPLETE_DART_FILE_CATALOG.md"
)

$merged = Join-Path $here "HydroSmart_Thesis_Complete.md"
if (Test-Path $merged) { Remove-Item $merged }
foreach ($f in $files) {
    Add-Content $merged "`n`n---`n`n"
    Get-Content (Join-Path $here $f) -Raw | Add-Content $merged
}

Set-Location $here
& $pandoc $merged -o "HydroSmart_Thesis_Complete.docx" --toc --number-sections
& $pandoc $merged -o "HydroSmart_Thesis_Complete.html" --toc --number-sections --standalone

Write-Host "Created:"
Write-Host "  $(Join-Path $here 'HydroSmart_Thesis_Complete.docx')"
Write-Host "  $(Join-Path $here 'HydroSmart_Thesis_Complete.html')"
Write-Host ""
Write-Host "PDF: Open the DOCX in Microsoft Word -> File -> Save As -> PDF"
Write-Host "Or install MiKTeX, then run:"
Write-Host "  & `"$pandoc`" HydroSmart_Thesis_Complete.md -o HydroSmart_Thesis_Complete.pdf --toc --number-sections"
