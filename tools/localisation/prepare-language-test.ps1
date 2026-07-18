[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$GamePath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-RelativeGamePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root,

        [Parameter(Mandatory = $true)]
        [string]$FullPath
    )

    return $FullPath.Substring($Root.Length).TrimStart('\', '/')
}

function Get-FileMetadata {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]$File,

        [Parameter(Mandatory = $true)]
        [string]$RelativePath
    )

    return [pscustomobject]@{
        RelativePath        = $RelativePath
        SizeBytes           = $File.Length
        SHA256              = (Get-FileHash -LiteralPath $File.FullName -Algorithm SHA256).Hash
        LastWriteTimeUtc    = $File.LastWriteTimeUtc.ToString('o')
    }
}

function Test-ContainsCrLf {
    param(
        [Parameter(Mandatory = $true)]
        [byte[]]$Bytes
    )

    for ($index = 0; $index -lt ($Bytes.Length - 1); $index++) {
        if ($Bytes[$index] -eq 13 -and $Bytes[$index + 1] -eq 10) {
            return $true
        }
    }

    return $false
}

function Test-HasUtf8Bom {
    param(
        [Parameter(Mandatory = $true)]
        [byte[]]$Bytes
    )

    return (($Bytes.Length -ge 3) -and
        ($Bytes[0] -eq 0xEF) -and
        ($Bytes[1] -eq 0xBB) -and
        ($Bytes[2] -eq 0xBF))
}

function ConvertFrom-SemicolonCsvLine {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Line
    )

    $fields = New-Object 'System.Collections.Generic.List[string]'
    $current = New-Object System.Text.StringBuilder
    $inQuotes = $false

    for ($index = 0; $index -lt $Line.Length; $index++) {
        $character = $Line[$index]

        if ($character -eq '"') {
            if ($inQuotes -and $index + 1 -lt $Line.Length -and $Line[$index + 1] -eq '"') {
                [void]$current.Append('"')
                $index++
            }
            else {
                $inQuotes = -not $inQuotes
            }
        }
        elseif ($character -eq ';' -and -not $inQuotes) {
            $fields.Add($current.ToString())
            [void]$current.Clear()
        }
        else {
            [void]$current.Append($character)
        }
    }

    if ($inQuotes) {
        throw 'Ligne CSV invalide : guillemet non fermé.'
    }

    $fields.Add($current.ToString())
    return $fields.ToArray()
}

function Get-CsvTargetChecks {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]$File,

        [Parameter(Mandatory = $true)]
        [string]$Root,

        [Parameter(Mandatory = $true)]
        [string[]]$Keys
    )

    $bytes = [System.IO.File]::ReadAllBytes($File.FullName)
    $encoding = [System.Text.Encoding]::GetEncoding(1252)
    $text = $encoding.GetString($bytes)
    $lines = $text -split "`r`n|`n|`r"
    $keyChecks = @()

    foreach ($key in $Keys) {
        $match = $null

        for ($lineNumber = 0; $lineNumber -lt $lines.Count; $lineNumber++) {
            if ([string]::IsNullOrWhiteSpace($lines[$lineNumber])) {
                continue
            }

            $fields = @(ConvertFrom-SemicolonCsvLine -Line $lines[$lineNumber])
            if ($fields.Count -gt 0 -and $fields[0].Trim() -ceq $key) {
                $match = [pscustomobject]@{
                    Key             = $key
                    Present         = $true
                    LineNumber      = $lineNumber + 1
                    ColumnCount     = $fields.Count
                    ExpectedColumns = 12
                    ColumnCountPass = ($fields.Count -eq 12)
                }
                break
            }
        }

        if ($null -eq $match) {
            $match = [pscustomobject]@{
                Key             = $key
                Present         = $false
                LineNumber      = $null
                ColumnCount     = $null
                ExpectedColumns = 12
                ColumnCountPass = $false
            }
        }

        $keyChecks += $match
    }

    $crLfPresent = Test-ContainsCrLf -Bytes $bytes
    $utf8BomAbsent = -not (Test-HasUtf8Bom -Bytes $bytes)
    $keysPass = @($keyChecks | Where-Object { -not $_.Present -or -not $_.ColumnCountPass }).Count -eq 0

    return [pscustomobject]@{
        RelativePath  = (Get-RelativeGamePath -Root $Root -FullPath $File.FullName)
        CrLfPresent   = $crLfPresent
        Utf8BomAbsent = $utf8BomAbsent
        Keys          = $keyChecks
        Passed        = ($crLfPresent -and $utf8BomAbsent -and $keysPass)
    }
}

function Test-SameFileMetadata {
    param(
        [Parameter(Mandatory = $true)]
        $Before,

        [Parameter(Mandatory = $true)]
        $After
    )

    return $Before.SizeBytes -eq $After.SizeBytes -and
        $Before.SHA256 -eq $After.SHA256 -and
        $Before.LastWriteTimeUtc -eq $After.LastWriteTimeUtc
}

try {
    $resolvedGamePath = (Resolve-Path -LiteralPath $GamePath).ProviderPath.TrimEnd('\', '/')
}
catch {
    throw "Le chemin de jeu ne peut pas être résolu : '$GamePath'."
}

if ($resolvedGamePath -match '(?i)(^|[\\/])ck1-vanilla-reference([\\/]|$)') {
    throw "Refus de sécurité : le chemin cible contient 'ck1-vanilla-reference'."
}

if (-not ((Split-Path -Leaf $resolvedGamePath) -ieq 'ck1-testing')) {
    throw "Refus de sécurité : le dossier cible doit être nommé exactement 'ck1-testing'."
}

$gameDirectory = Get-Item -LiteralPath $resolvedGamePath
if (($gameDirectory.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
    throw 'Refus de sécurité : le dossier ck1-testing ne doit pas être un point de réanalyse.'
}

$requiredPaths = @(
    'Crusaders.exe',
    'config\text.csv',
    'config\world_names.csv'
)

foreach ($relativePath in $requiredPaths) {
    $candidate = Join-Path $resolvedGamePath $relativePath
    if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) {
        throw "Fichier requis introuvable : '$relativePath'."
    }
}

$sourceRelativePaths = @(
    'config\text.csv',
    'config\world_names.csv',
    'config.eu',
    'settings.txt'
)

$sources = @()
foreach ($relativePath in $sourceRelativePaths) {
    $sourcePath = Join-Path $resolvedGamePath $relativePath
    if (Test-Path -LiteralPath $sourcePath -PathType Leaf) {
        $sources += [pscustomobject]@{
            RelativePath = $relativePath
            File         = Get-Item -LiteralPath $sourcePath
        }
    }
}

$textChecks = Get-CsvTargetChecks -File (Get-Item -LiteralPath (Join-Path $resolvedGamePath 'config\text.csv')) -Root $resolvedGamePath -Keys @('FEOPT_OK')
$worldNameChecks = Get-CsvTargetChecks -File (Get-Item -LiteralPath (Join-Path $resolvedGamePath 'config\world_names.csv')) -Root $resolvedGamePath -Keys @('CULTURE_SWEDISH', 'LANG')

if (-not $textChecks.Passed -or -not $worldNameChecks.Passed) {
    Write-Host 'Contrôles CSV échoués ; aucune sauvegarde n’a été créée.' -ForegroundColor Red
    foreach ($check in @($textChecks, $worldNameChecks)) {
        Write-Host ("  {0} : CRLF={1}, BOM UTF-8 absent={2}, clés valides={3}" -f $check.RelativePath, $check.CrLfPresent, $check.Utf8BomAbsent, (@($check.Keys | Where-Object { $_.Present -and $_.ColumnCountPass }).Count -eq @($check.Keys).Count))
    }
    throw 'La validation des CSV ciblés a échoué.'
}

$backupRoot = Join-Path $resolvedGamePath '.localisation-backups'
if (Test-Path -LiteralPath $backupRoot) {
    $backupRootItem = Get-Item -LiteralPath $backupRoot
    if (($backupRootItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw 'Refus de sécurité : .localisation-backups ne doit pas être un point de réanalyse.'
    }
}

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupDirectory = Join-Path $backupRoot $timestamp
if (Test-Path -LiteralPath $backupDirectory) {
    throw "Le dossier de sauvegarde existe déjà : '$backupDirectory'."
}

New-Item -ItemType Directory -Path $backupDirectory | Out-Null

$beforeMetadata = @()
$manifestFiles = @()
foreach ($source in $sources) {
    $sourceMetadata = Get-FileMetadata -File $source.File -RelativePath $source.RelativePath
    $beforeMetadata += $sourceMetadata

    $backupPath = Join-Path $backupDirectory $source.RelativePath
    $backupParent = Split-Path -Parent $backupPath
    if (-not (Test-Path -LiteralPath $backupParent)) {
        New-Item -ItemType Directory -Path $backupParent | Out-Null
    }

    Copy-Item -LiteralPath $source.File.FullName -Destination $backupPath -ErrorAction Stop
    $backupFile = Get-Item -LiteralPath $backupPath
    $backupHash = (Get-FileHash -LiteralPath $backupFile.FullName -Algorithm SHA256).Hash

    if ($backupHash -ne $sourceMetadata.SHA256) {
        throw "La copie binaire a échoué pour '$($source.RelativePath)'."
    }

    $manifestFiles += [pscustomobject]@{
        RelativePath       = $sourceMetadata.RelativePath
        SizeBytes          = $sourceMetadata.SizeBytes
        SHA256             = $sourceMetadata.SHA256
        LastWriteTimeUtc   = $sourceMetadata.LastWriteTimeUtc
        BackupRelativePath = Get-RelativeGamePath -Root $backupDirectory -FullPath $backupFile.FullName
        BackupSHA256       = $backupHash
    }
}

$afterMetadata = @()
foreach ($source in $sources) {
    $afterMetadata += Get-FileMetadata -File (Get-Item -LiteralPath $source.File.FullName) -RelativePath $source.RelativePath
}

$sourceFilesUnchanged = $true
foreach ($before in $beforeMetadata) {
    $after = $afterMetadata | Where-Object { $_.RelativePath -eq $before.RelativePath } | Select-Object -First 1
    if ($null -eq $after -or -not (Test-SameFileMetadata -Before $before -After $after)) {
        $sourceFilesUnchanged = $false
    }
}

$manifest = [pscustomobject]@{
    CreatedAtUtc          = (Get-Date).ToUniversalTime().ToString('o')
    GamePath              = $resolvedGamePath
    BackupDirectory       = $backupDirectory
    SourceFiles           = $manifestFiles
    CsvChecks             = @($textChecks, $worldNameChecks)
    SourceFilesUnchanged  = $sourceFilesUnchanged
    Notes                 = 'Le manifeste ne contient aucune valeur de localisation, uniquement des métadonnées, clés techniques et résultats de contrôles.'
}

$manifestPath = Join-Path $backupDirectory 'manifest.localisation.json'
$manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $manifestPath -Encoding UTF8

Write-Host ''
Write-Host 'Préparation du test de langue terminée.' -ForegroundColor Green
Write-Host "Dossier de sauvegarde : $backupDirectory" -ForegroundColor Green
Write-Host 'Fichiers sauvegardés et SHA-256 :' -ForegroundColor Cyan
foreach ($file in $manifestFiles) {
    Write-Host ("  {0} | {1}" -f $file.RelativePath, $file.SHA256)
}

Write-Host 'Contrôles CSV :' -ForegroundColor Cyan
foreach ($check in @($textChecks, $worldNameChecks)) {
    Write-Host ("  [PASS] {0} | CRLF={1} | BOM UTF-8 absent={2}" -f $check.RelativePath, $check.CrLfPresent, $check.Utf8BomAbsent)
    foreach ($keyCheck in $check.Keys) {
        Write-Host ("         clé={0} | présente={1} | ligne={2} | colonnes={3}" -f $keyCheck.Key, $keyCheck.Present, $keyCheck.LineNumber, $keyCheck.ColumnCount)
    }
}

if ($sourceFilesUnchanged) {
    Write-Host 'Confirmation : aucun fichier source du jeu n’a été modifié.' -ForegroundColor Green
}
else {
    Write-Host 'ÉCHEC : au moins un fichier source a changé pendant l’exécution.' -ForegroundColor Red
    throw 'Les fichiers source ne correspondent plus à leurs métadonnées initiales.'
}
