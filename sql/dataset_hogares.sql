-- Dataset para el Laboratorio 4: un registro por hogar (InvacomDW)
-- Une la demografia (DimHogar) con metricas de compra agregadas de FactVenta.
-- "No informado" (relleno del ETL) se convierte en NULL para reflejar el dato faltante real.
SET NOCOUNT ON;

WITH ventas AS (
    SELECT
        f.HogarKey,
        SUM(f.SALES_VALUE)                         AS total_sales,
        COUNT(DISTINCT f.BASKET_ID)                AS num_baskets,
        SUM(f.QUANTITY)                            AS total_quantity,
        COUNT(DISTINCT f.ProductoKey)              AS distinct_products,
        COUNT(DISTINCT f.TiendaKey)                AS distinct_stores,
        COUNT(DISTINCT p.WEEK_NO)                  AS active_weeks,
        MIN(p.[DAY])                               AS first_day,
        MAX(p.[DAY])                               AS last_day,
        SUM(f.RETAIL_DISC)                         AS total_retail_disc,
        SUM(f.COUPON_DISC)                         AS total_coupon_disc
    FROM dbo.FactVenta f
    JOIN dbo.DimPeriodo p ON p.PeriodoKey = f.PeriodoKey
    GROUP BY f.HogarKey
),
depto AS (
    -- Departamento donde mas gasta cada hogar
    SELECT HogarKey, DEPARTMENT AS top_department
    FROM (
        SELECT f.HogarKey, d.DEPARTMENT,
               ROW_NUMBER() OVER (PARTITION BY f.HogarKey ORDER BY SUM(f.SALES_VALUE) DESC) AS rn
        FROM dbo.FactVenta f
        JOIN dbo.DimProducto d ON d.ProductoKey = f.ProductoKey
        GROUP BY f.HogarKey, d.DEPARTMENT
    ) x
    WHERE rn = 1
),
cupones AS (
    SELECT TRY_CAST(household_key AS int) AS household_key,
           COUNT(*) AS coupons_redeemed
    FROM dbo.coupon_redempt
    GROUP BY TRY_CAST(household_key AS int)
)
SELECT
    h.household_key,
    NULLIF(h.AGE_DESC,            'No informado') AS age_desc,
    NULLIF(h.MARITAL_STATUS_CODE, 'No informado') AS marital_status_code,
    NULLIF(h.INCOME_DESC,         'No informado') AS income_desc,
    NULLIF(h.HOMEOWNER_DESC,      'No informado') AS homeowner_desc,
    NULLIF(h.HH_COMP_DESC,        'No informado') AS hh_comp_desc,
    NULLIF(h.HOUSEHOLD_SIZE_DESC, 'No informado') AS household_size_desc,
    NULLIF(h.KID_CATEGORY_DESC,   'No informado') AS kid_category_desc,
    v.total_sales,
    v.num_baskets,
    CAST(v.total_sales / NULLIF(v.num_baskets, 0) AS decimal(12,2)) AS avg_basket_value,
    v.total_quantity,
    v.distinct_products,
    v.distinct_stores,
    v.active_weeks,
    v.first_day,
    v.last_day,
    v.total_retail_disc,
    v.total_coupon_disc,
    c.coupons_redeemed,
    dp.top_department
FROM dbo.DimHogar h
LEFT JOIN ventas  v  ON v.HogarKey  = h.HogarKey
LEFT JOIN depto   dp ON dp.HogarKey = h.HogarKey
LEFT JOIN cupones c  ON c.household_key = h.household_key
ORDER BY h.household_key;
