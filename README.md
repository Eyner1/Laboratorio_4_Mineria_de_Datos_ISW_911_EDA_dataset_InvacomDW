# Laboratorio 4: análisis exploratorio de hogares

En este laboratorio exploramos las compras de 2.500 hogares. El notebook reúne
los gráficos, los hallazgos y las decisiones que seguimos para preparar los datos.

Integrantes:

- Eyner Lopez Aleman
- Neysa Alfaro
- Osvaldo Zúñiga Pérez
- José Alejandro Lopez Quesada

## Archivos

- `lab4_IC2025.ipynb`: desarrollo del laboratorio.
- `data_process.csv`: datos procesados que genera el notebook.
- `data/hogares_invacom.csv`: datos de entrada, con una fila por hogar.
- `sql/dataset_hogares.sql`: consulta para obtener los datos del DW.
- `sql/exportar_csv.ps1`: script para exportar el CSV o compararlo con el DW.

## Datos del proyecto

La fuente es `InvacomDW`, el DW del proyecto. Según lo indicado en el notebook,
el profesor autorizó su uso en lugar de los datos abiertos de Costa Rica que
solicita el enunciado.

La consulta combina información de `DimHogar`, `FactVenta`, `DimPeriodo`,
`DimProducto` y `coupon_redempt` para obtener una fila por hogar. La extracción y
el análisis son pasos separados: primero se exporta el CSV desde el DW y se
publica en el repositorio; después, el notebook lo lee desde GitHub.

El servidor está en `127.0.0.1:1433`. El script usa la dirección
`tcp:127.0.0.1,1433` y se conecta a `InvacomDW` con autenticación de Windows.
Para comparar el CSV con el DW sin sobrescribir el archivo, se ejecuta este
comando desde la raíz del repositorio:

```powershell
.\sql\exportar_csv.ps1 -SoloValidar
```

Si los datos del DW cambiaron, se puede generar de nuevo el archivo:

```powershell
.\sql\exportar_csv.ps1
```

Antes de volver a ejecutar el notebook, hay que subir el CSV actualizado a GitHub
para que el análisis lea la nueva versión.

## Cómo ejecutar el notebook

Se utilizó Python 3.14.3. Para preparar el entorno y ejecutar el análisis:

```powershell
py -3.14 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\Activate.ps1
jupyter nbconvert --to notebook --execute --inplace lab4_IC2025.ipynb --ExecutePreprocessor.timeout=180
```

También se puede abrir el notebook en el editor y seleccionar el intérprete de
`.venv`. Luego se reinicia el kernel y se ejecutan todas las celdas en orden.
El análisis necesita conexión a internet para leer el CSV de GitHub, pero se
puede ejecutar sin conectarse a SQL Server. Las dependencias están en
`requirements.txt`.

## Resultado y entrega

La última sección guarda `data_process.csv` con **2.500 filas, 31 columnas y ningún
nulo**. El archivo se sobrescribe cada vez que se ejecuta esa sección.

La columna `total_quantity` se conserva en el CSV de entrada para revisar sus
valores, pero se excluye del conjunto procesado: suma cantidades de departamentos
que usan unidades distintas, y recortar los valores altos no corrige esa mezcla.
El notebook también incluye la elección justificada de un modelo candidato, sin
entrenarlo.

En el campus se entrega únicamente `lab4_IC2025.ipynb`, con ese nombre.
`data_process.csv` queda publicado en este repositorio.
