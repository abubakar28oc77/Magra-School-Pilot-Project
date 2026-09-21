$outputFile = "database/full_database_setup.sql"
$files = @("database/schema.sql")
$files += Get-ChildItem -Path "database/migrations/*.sql" | Sort-Object Name | ForEach-Object { $_.FullName }
$files += "database/pilot/pilot_seed.sql"

$allText = @()
foreach ($f in $files) {
    if (Test-Path $f) {
        $allText += "-- ========================================="
        $allText += "-- FILE: $f"
        $allText += "-- ========================================="
        $allText += Get-Content $f -Raw -Encoding UTF8
        $allText += ""
    }
}

Set-Content -Path $outputFile -Value ($allText -join "`n") -Encoding UTF8
Write-Host "Created $outputFile successfully!"
