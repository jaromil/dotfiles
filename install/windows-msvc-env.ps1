## usage: source with leading dot
## . ./install/windows-msvc-env.ps1

$ErrorActionPreference = "Stop"

$roots = @(
  "C:\Program Files\Microsoft Visual Studio",
  "C:\Program Files (x86)\Microsoft Visual Studio"
)

Write-Host "Looking for vcvars64.bat..."

$vcvars = Get-ChildItem $roots `
  -Recurse `
  -Filter vcvars64.bat `
  -ErrorAction SilentlyContinue |
  Select-Object -First 1 -ExpandProperty FullName

if (!$vcvars) {
  Write-Host "vcvars64.bat not found. Looking for cl.exe..."

  $cl = Get-ChildItem "C:\Program Files", "C:\Program Files (x86)" `
    -Recurse `
    -Filter cl.exe `
    -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match '\\VC\\Tools\\MSVC\\.*\\bin\\Hostx64\\x64\\cl\.exe$' } |
    Select-Object -First 1 -ExpandProperty FullName

  if (!$cl) {
    throw "Could not find vcvars64.bat or cl.exe. Install Visual Studio C++ build tools: Desktop development with C++."
  }

  Write-Host "Found cl.exe:"
  Write-Host $cl

  $vcRoot = $cl -replace '\\VC\\Tools\\MSVC\\.*$', '\VC'
  $vcvars = Join-Path $vcRoot "Auxiliary\Build\vcvars64.bat"

  if (!(Test-Path $vcvars)) {
    throw "Found cl.exe, but could not derive vcvars64.bat path: $vcvars"
  }
}

Write-Host "Using:"
Write-Host $vcvars

cmd /c "`"$vcvars`" && set" | ForEach-Object {
  if ($_ -match '^(.*?)=(.*)$') {
    [Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
  }
}

Write-Host ""
Write-Host "Checking cl.exe..."

$clPath = where.exe cl 2>$null | Select-Object -First 1

if (!$clPath) {
  throw "MSVC environment loaded, but cl.exe is still not on PATH."
}

Write-Host "Found:"
Write-Host $clPath

Write-Host ""
cl

Write-Host ""
Write-Host "MSVC environment ready."

