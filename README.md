# Laboratorio 4: análisis exploratorio de hogares

Este laboratorio analiza las compras de 2.500 hogares. El notebook contiene la
exploración de los datos, los gráficos y las decisiones de limpieza.

Integrantes:

- Eyner Lopez Aleman
- Neysa Alfaro
- Osvaldo Zúñiga Pérez
- José Alejandro Lopez Quesada

## Archivos

- `lab4_IC2025.ipynb`: desarrollo del laboratorio.
- `data_process.csv`: datos procesados que genera el notebook.
- `data/hogares_invacom.csv`: datos originales, con una fila por hogar.
- `sql/dataset_hogares.sql`: consulta para obtener los datos del DW.
- `sql/exportar_csv.ps1`: script para exportar el CSV o compararlo con el DW.

## Datos del proyecto

Los datos vienen de `InvacomDW`, el DW del proyecto. El notebook indica que el
profesor autorizó esta fuente en lugar de los datos abiertos de Costa Rica que
pide el enunciado.

La consulta reúne información de `DimHogar`, `FactVenta`, `DimPeriodo`,
`DimProducto` y `coupon_redempt`. Primero se exporta el CSV desde el DW y se sube
al repositorio; después, el notebook lo lee desde GitHub.

El servidor está en `127.0.0.1:1433`. El script se conecta a `InvacomDW` con
autenticación de Windows y usa la dirección `tcp:127.0.0.1,1433`.
Para comprobar que el CSV coincide con el DW, sin sobrescribirlo, se ejecuta desde
la raíz del repositorio:

```powershell
.\sql\exportar_csv.ps1 -SoloValidar
```

Si cambiaron los datos del DW, se puede exportar el archivo de nuevo:

```powershell
.\sql\exportar_csv.ps1
```

El CSV actualizado debe subirse a GitHub antes de volver a ejecutar el notebook.

## Cómo ejecutar el notebook

Se utilizó Python 3.14.3. Para preparar el entorno y ejecutar el análisis:

```powershell
py -3.14 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\Activate.ps1
jupyter nbconvert --to notebook --execute --inplace lab4_IC2025.ipynb --ExecutePreprocessor.timeout=180
```

También se puede abrir el notebook en el editor, seleccionar el intérprete de
`.venv`, reiniciar el kernel y ejecutar todas las celdas en orden. Hace falta
conexión a Internet para leer el CSV de GitHub; no es necesario tener SQL Server
conectado para este paso. Las dependencias están en `requirements.txt`.

## Resultado y entrega

La última sección guarda `data_process.csv` con **2.500 filas, 31 columnas y ningún
nulo**. El archivo se sobrescribe cada vez que se ejecuta esa sección.

Se excluye `total_quantity` del conjunto procesado porque suma cantidades de
departamentos que usan unidades distintas. Recortar los valores altos no corrige
esa diferencia. La columna se conserva en el CSV original para revisar el problema.
El notebook también justifica un modelo candidato, sin entrenarlo.

En el campus se entrega únicamente `lab4_IC2025.ipynb`, con ese nombre.
`data_process.csv` queda publicado en este repositorio.
