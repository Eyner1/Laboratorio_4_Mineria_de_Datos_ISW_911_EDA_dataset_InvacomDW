# Consulta de solo lectura al DW. -SoloValidar compara con el CSV sin sobrescribirlo.
[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$Servidor = 'tcp:127.0.0.1,1433',
    [switch]$SoloValidar
)

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$out = Join-Path $root 'data\hogares_invacom.csv'
$query = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'dataset_hogares.sql') -Raw -Encoding UTF8
$culturaAnterior = [System.Threading.Thread]::CurrentThread.CurrentCulture

# Autenticacion de Windows; no se guardan usuarios ni contrasenas en el repositorio.
# El certificado autofirmado se admite para el SQL Server local del proyecto.
$conexion = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
$conexion['Data Source'] = $Servidor
$conexion['Initial Catalog'] = 'InvacomDW'
$conexion['Integrated Security'] = $true
$conexion['Encrypt'] = $true
$conexion['TrustServerCertificate'] = $true
$conexion['Connect Timeout'] = 15
$conexion['Application Name'] = 'Laboratorio04-EDA'
$cn = New-Object System.Data.SqlClient.SqlConnection $conexion.ConnectionString
$cmd = $null
$reader = $null
$dt = New-Object System.Data.DataTable

try {
    $cn.Open()
    if ($cn.Database -ne 'InvacomDW') {
        throw "La conexion no apunta a InvacomDW: $($cn.Database)"
    }
    Write-Output "Conexion verificada: $($cn.DataSource) / $($cn.Database)"

    $cmd = $cn.CreateCommand()
    $cmd.CommandText = $query
    $cmd.CommandTimeout = 600
    $reader = $cmd.ExecuteReader()
    $dt.Load($reader)

    if ($dt.Rows.Count -eq 0 -or $dt.Columns.Count -ne 21) {
        throw "Extraccion inesperada: $($dt.Rows.Count) filas y $($dt.Columns.Count) columnas."
    }
    $ids = @($dt.Rows | ForEach-Object { $_.household_key })
    if (@($ids | Select-Object -Unique).Count -ne $dt.Rows.Count) {
        throw 'La extraccion contiene identificadores de hogar duplicados.'
    }

    # Mantiene los puntos decimales aunque Windows use una configuracion regional distinta.
    [System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::InvariantCulture
    $filasCsv = @($dt | Select-Object ($dt.Columns | ForEach-Object ColumnName) |
        ConvertTo-Csv -NoTypeInformation)

    if ($SoloValidar) {
        if (-not (Test-Path -LiteralPath $out)) {
            throw "No existe el CSV que se quiere validar: $out"
        }
        $existente = @(Get-Content -LiteralPath $out -Encoding UTF8)
        if ($existente.Count -ne $filasCsv.Count) {
            throw 'El CSV local y el DW tienen diferente cantidad de filas.'
        }
        for ($i = 0; $i -lt $filasCsv.Count; $i++) {
            if ($existente[$i] -cne $filasCsv[$i]) {
                throw "El CSV local difiere del DW en la linea $($i + 1). Vuelva a exportar."
            }
        }
        Write-Output 'Validacion correcta: el CSV local coincide con la consulta actual del DW.'
    }
    else {
        New-Item -ItemType Directory -Force (Split-Path $out) | Out-Null
        $filasCsv | Set-Content -LiteralPath $out -Encoding UTF8
        Write-Output "CSV exportado: $out"
    }
    Write-Output "Filas: $($dt.Rows.Count)  Columnas: $($dt.Columns.Count)"
}
finally {
    [System.Threading.Thread]::CurrentThread.CurrentCulture = $culturaAnterior
    if ($null -ne $reader) { $reader.Dispose() }
    if ($null -ne $cmd) { $cmd.Dispose() }
    $dt.Dispose()
    $cn.Dispose()
}
