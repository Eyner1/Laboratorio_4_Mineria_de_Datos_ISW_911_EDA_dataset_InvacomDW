# Ejecuta dataset_hogares.sql contra InvacomDW y exporta el resultado a data/hogares_invacom.csv
$ErrorActionPreference = 'Stop'
$root  = Split-Path $PSScriptRoot -Parent
$query = Get-Content (Join-Path $PSScriptRoot 'dataset_hogares.sql') -Raw -Encoding UTF8
$out   = Join-Path $root 'data\hogares_invacom.csv'
New-Item -ItemType Directory -Force (Split-Path $out) | Out-Null

$cn = New-Object System.Data.SqlClient.SqlConnection 'Server=.\SQLEXPRESS;Database=InvacomDW;Integrated Security=True'
$cmd = $cn.CreateCommand(); $cmd.CommandText = $query; $cmd.CommandTimeout = 600
$dt = New-Object System.Data.DataTable
$cn.Open(); $dt.Load($cmd.ExecuteReader()); $cn.Close()

# Punto decimal invariante para que pandas lea los numeros correctamente
[System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::InvariantCulture
$dt | Select-Object ($dt.Columns | ForEach-Object ColumnName) |
    Export-Csv -Path $out -NoTypeInformation -Encoding UTF8
"Filas: $($dt.Rows.Count)  Columnas: $($dt.Columns.Count)  ->  $out"
