# Laboratorio 4: análisis exploratorio de hogares

Integrantes:

- Eyner Lopez Aleman
- Neysa Alfaro
- Osvaldo Zúñiga Pérez
- José Alejandro Lopez Quesada

## Archivos de entrega

- `lab4_IC2025.ipynb`: notebook con el desarrollo, las justificaciones y la evidencia gráfica.
- `data_process.csv`: resultado del EDA, generado al ejecutar el notebook.
- `data/hogares_invacom.csv`: extracción original de un registro por hogar.
- `sql/dataset_hogares.sql`: consulta de extracción de solo lectura.
- `sql/exportar_csv.ps1`: conexión, exportación y comparación del CSV con el DW.

El enunciado pide datos abiertos de Costa Rica. Este trabajo utiliza `InvacomDW`,
con la autorización docente indicada en la documentación del notebook; esa excepción
es necesaria para que el origen de los datos cumpla lo solicitado.

## Conexión con el proyecto

El DW es **InvacomDW**, en **127.0.0.1:1433**. En SqlClient se escribe
`tcp:127.0.0.1,1433`. El script usa autenticación de Windows y admite el certificado
autofirmado del servidor local, sin guardar contraseñas.

Desde PowerShell, en la raíz del repositorio:

```powershell
# Comprobar la conexión y que el CSV coincide con el DW, sin sobrescribirlo.
.\sql\exportar_csv.ps1 -SoloValidar

# Exportar de nuevo si se actualizó el DW.
.\sql\exportar_csv.ps1
```

La consulta utiliza `DimHogar`, `FactVenta`, `DimPeriodo`, `DimProducto` y
`coupon_redempt`. El notebook **lee el CSV publicado en GitHub**, como exige el
enunciado; la conexión al DW corresponde al paso previo de extracción. Tras cambiar
el CSV original hay que publicarlo en GitHub antes de ejecutar el notebook.

## Ejecutar el laboratorio

Se verificó con Python 3.14.3. Las versiones utilizadas están en `requirements.txt`.
Es necesario acceder a Internet para la lectura desde GitHub; ejecutar el notebook
no requiere conectarse a SQL Server.

```powershell
py -3.14 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\Activate.ps1
jupyter nbconvert --to notebook --execute --inplace lab4_IC2025.ipynb --ExecutePreprocessor.timeout=180
```

También se puede abrir el notebook en el editor y seleccionar el intérprete de
`.venv`, reiniciar el kernel y ejecutar todas las celdas en orden. La última sección
sobrescribe `data_process.csv` con el resultado de esa ejecución.

La cantidad original `total_quantity` combina unidades de distintos departamentos.
Se conserva en el CSV de origen para documentar el hallazgo y se excluye del
dataset limpio: acotar percentiles no homogeneiza unidades. El resultado esperado
es **2.500 filas, 31 columnas y ningún nulo**. El punto 13 se desarrolla como
identificación del objetivo y justificación del modelo candidato; no se atribuyen
métricas a modelos que no se han evaluado.

La entrega en el campus virtual es el notebook con el nombre exacto
`lab4_IC2025.ipynb` (punto 16 del enunciado). `data_process.csv` lo genera el propio
notebook y queda publicado en este repositorio.
