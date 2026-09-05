<#
================================================================================
Script: setup_kernel.ps1
Purpose: Automatically create a venv and register kernel in Windows PowerShell
Usage: .\setup_kernel.ps1 -KernelName data -DisplayName "Python (Data)"
================================================================================
#>

param (
    [Parameter(Mandatory=$true)][string]$KernelName,
    [Parameter(Mandatory=$false)][string]$DisplayName = "Python ($KernelName)"
)

$ErrorActionPreference = "Stop"

$VenvsParent = Join-Path $HOME "venvs"
$VenvDir = Join-Path $VenvsParent $KernelName

if (-not (Test-Path $VenvsParent)) {
    New-Item -ItemType Directory -Path $VenvsParent | Out-Null
}

Write-Host "==> [1/4] Creating virtual environment at $VenvDir..." -ForegroundColor Cyan
python -m venv $VenvDir

$PipPath = Join-Path $VenvDir "Scripts\pip.exe"
$PythonPath = Join-Path $VenvDir "Scripts\python.exe"

Write-Host "==> [2/4] Upgrading pip and installing ipykernel..." -ForegroundColor Cyan
& $PythonPath -m pip install --upgrade pip
& $PipPath install ipykernel

Write-Host "==> [3/4] Registering kernel with Jupyter..." -ForegroundColor Cyan
& $PythonPath -m ipykernel install --user --name=$KernelName --display-name="$DisplayName"

Write-Host "`n[4/4] Success! Kernel '$DisplayName' is ready in Jupyter." -ForegroundColor Green
Write-Host "Activate anytime with: & `"$VenvDir\Scripts\Activate.ps1`"" -ForegroundColor Yellow
