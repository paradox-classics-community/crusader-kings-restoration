param(
    [Parameter(Mandatory = $false)]
    [string]$GameRoot = (Get-Location).Path
)

$ScriptVersion = "1.1.0"
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$GameRoot = (Resolve-Path -LiteralPath $GameRoot).Path.TrimEnd('\')
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$Desktop = [Environment]::GetFolderPath("Desktop")
$OutRoot = Join-Path $Desktop "CK1-inventory-$Timestamp"

New-Item -ItemType Directory -Path $OutRoot -Force | Out-Null

$ExeCandidates = @(
    Get-ChildItem -LiteralPath $GameRoot -File -Filter "*.exe" -ErrorAction SilentlyContinue
)

if (-not $ExeCandidates) {
    throw "No EXE file was found in '$GameRoot'. Run the script from the Crusader Kings Complete installation directory or pass -GameRoot."
}

Write-Host "CK1 Inventory $ScriptVersion" -ForegroundColor DarkCyan
Write-Host "Game directory: $GameRoot" -ForegroundColor Cyan
Write-Host "Calculating SHA-256 fingerprints..." -ForegroundColor Cyan

$Files = @(
    Get-ChildItem -LiteralPath $GameRoot -Recurse -File -Force |
        Sort-Object FullName
)

$Manifest = foreach ($File in $Files) {
    $RelativePath = $File.FullName.Substring($GameRoot.Length).TrimStart('\')
    $Hash = $null
    $HashError = $null

    try {
        $Hash = (Get-FileHash -LiteralPath $File.FullName -Algorithm SHA256).Hash
    }
    catch {
        $HashError = $_.Exception.Message
    }

    $IsMutable = $RelativePath -match '(?i)' +
        '(^|\\)(save games?|saved games?|saves?|logs?|screenshots?|cache|temp)(\\|$)|' +
        '\.log$|\.sav$|' +
        '^ck1-inventory.*\.ps1$|' +
        '^config\.eu$|^history\.txt$|^savedebug\.txt$|^settings\.txt$'

    [pscustomobject]@{
        RelativePath        = $RelativePath
        Extension           = $File.Extension.ToLowerInvariant()
        SizeBytes           = $File.Length
        LastWriteTimeUtc    = $File.LastWriteTimeUtc.ToString("o")
        SHA256              = $Hash
        HashError           = $HashError
        LikelyUserGenerated = $IsMutable
    }
}

$Manifest |
    Export-Csv -LiteralPath (Join-Path $OutRoot "manifest-all.csv") `
        -NoTypeInformation -Encoding UTF8

$Baseline = @(
    $Manifest | Where-Object { -not $_.LikelyUserGenerated }
)

$Baseline |
    Export-Csv -LiteralPath (Join-Path $OutRoot "manifest-baseline.csv") `
        -NoTypeInformation -Encoding UTF8

$BinaryVersions = foreach ($File in ($Files | Where-Object {
    $_.Extension -in @(".exe", ".dll")
})) {
    $RelativePath = $File.FullName.Substring($GameRoot.Length).TrimStart('\')
    $Version = $File.VersionInfo
    $Record = $Manifest |
        Where-Object { $_.RelativePath -eq $RelativePath } |
        Select-Object -First 1

    [pscustomobject]@{
        RelativePath   = $RelativePath
        FileVersion    = $Version.FileVersion
        ProductVersion = $Version.ProductVersion
        CompanyName    = $Version.CompanyName
        ProductName    = $Version.ProductName
        OriginalName   = $Version.OriginalFilename
        SizeBytes      = $File.Length
        SHA256         = $Record.SHA256
    }
}

$BinaryVersions |
    Export-Csv -LiteralPath (Join-Path $OutRoot "binary-versions.csv") `
        -NoTypeInformation -Encoding UTF8

# Publish only non-sensitive Steam identity fields.
$SteamSummary = $null
$GameFolderName = Split-Path $GameRoot -Leaf
$CommonFolder = Split-Path $GameRoot -Parent

if ((Split-Path $CommonFolder -Leaf) -ieq "common") {
    $SteamAppsFolder = Split-Path $CommonFolder -Parent
    $AppManifests = @(
        Get-ChildItem -LiteralPath $SteamAppsFolder -File `
            -Filter "appmanifest_*.acf" -ErrorAction SilentlyContinue
    )

    foreach ($AppManifest in $AppManifests) {
        $Raw = Get-Content -LiteralPath $AppManifest.FullName -Raw
        if ($Raw -notmatch [regex]::Escape($GameFolderName)) {
            continue
        }

        function Read-AcfValue([string]$Name) {
            $Match = [regex]::Match(
                $Raw,
                '"' + [regex]::Escape($Name) + '"\s+"([^"]+)"'
            )
            if ($Match.Success) {
                return $Match.Groups[1].Value
            }
            return $null
        }

        $SteamSummary = [pscustomobject]@{
            AppId      = Read-AcfValue "appid"
            Name       = Read-AcfValue "name"
            InstallDir = Read-AcfValue "installdir"
            BuildId    = Read-AcfValue "buildid"
            SizeOnDisk = Read-AcfValue "SizeOnDisk"
        }

        break
    }
}

if ($SteamSummary) {
    $SteamSummary |
        ConvertTo-Json -Depth 4 |
        Set-Content -LiteralPath (Join-Path $OutRoot "steam-summary.json") `
            -Encoding UTF8
}

$TotalSize = ($Manifest | Measure-Object -Property SizeBytes -Sum).Sum

$Summary = @(
    "# CK1 inventory",
    "",
    "- Script version: $ScriptVersion",
    "- Created: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
    "- Game directory: $GameRoot",
    "- Total files: $(@($Manifest).Count)",
    "- Baseline files: $(@($Baseline).Count)",
    "- Total size: $([math]::Round($TotalSize / 1MB, 2)) MB",
    "- Executables: $(($ExeCandidates.Name -join ', '))",
    "",
    "Review all output before publishing. The inventory contains metadata and hashes, not original game file content."
)

$Summary |
    Set-Content -LiteralPath (Join-Path $OutRoot "README.md") -Encoding UTF8

$ZipPath = "$OutRoot.zip"
Compress-Archive -Path (Join-Path $OutRoot "*") -DestinationPath $ZipPath -Force

Write-Host ""
Write-Host "Inventory completed." -ForegroundColor Green
Write-Host "Directory: $OutRoot" -ForegroundColor Green
Write-Host "Archive: $ZipPath" -ForegroundColor Green
