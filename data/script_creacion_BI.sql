USE [GD1C2024]
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'QUICK_SORT')
	EXEC('CREATE SCHEMA QUICK_SORT')
GO

IF NOT EXISTS(SELECT name FROM sys.procedures WHERE name='DROP_TABLES_BI')
	EXEC('CREATE PROCEDURE [QUICK_SORT].[DROP_TABLES_BI] AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE [QUICK_SORT].[DROP_TABLES_BI]
AS
BEGIN
	DECLARE @sql NVARCHAR(500) = ''
	
	DECLARE cursorTablas CURSOR FOR
	SELECT DISTINCT 'ALTER TABLE [' + tc.TABLE_SCHEMA + '].[' +  tc.TABLE_NAME + '] DROP [' + rc.CONSTRAINT_NAME + '];'
	FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc
	LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	ON tc.CONSTRAINT_NAME = rc.CONSTRAINT_NAME
	WHERE tc.TABLE_SCHEMA = 'QUICK_SORT'

	OPEN cursorTablas
	FETCH NEXT FROM cursorTablas INTO @sql

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		EXEC sp_executesql @sql
		FETCH NEXT FROM cursorTablas INTO @Sql
	END

	CLOSE cursorTablas
	DEALLOCATE cursorTablas
	
	EXEC sp_MSforeachtable 'DROP TABLE ?', @whereand ='AND schema_name(schema_id) = ''QUICK_SORT'' AND o.name LIKE ''BI_%'''
END
GO

EXEC [QUICK_SORT].[DROP_TABLES_BI]
GO

IF NOT EXISTS(SELECT name FROM sys.procedures WHERE name='CREATE_TABLES_BI')
   EXEC('CREATE PROCEDURE [QUICK_SORT].[CREATE_TABLES_BI] AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE [QUICK_SORT].[CREATE_TABLES_BI] 
AS 
BEGIN
	
		
		CREATE TABLE [QUICK_SORT].[BI_CAJA_TIPO](
			CAJA_TIPO_ID INTEGER PRIMARY KEY,
			CAJA_TIPO NVARCHAR(255)
		);

		
		CREATE TABLE [QUICK_SORT].[BI_TURNO](
			TURNO_ID INTEGER IDENTITY(1,1) PRIMARY KEY,
			HORA_INICIAL TIME,
			HORA_FINAL TIME
		);

		CREATE TABLE [QUICK_SORT].[BI_TIEMPO](
			TIEMPO_ID INTEGER IDENTITY(1,1) PRIMARY KEY,
			ANIO NVARCHAR(4),
			MES NVARCHAR(2),
			CUATRIMESTRE NVARCHAR(1)
		);

		CREATE TABLE [QUICK_SORT].[BI_RANGO_ETAREO](
			RANGO_ETAREO_ID INTEGER IDENTITY(1,1) PRIMARY KEY,
			RANGO_MENOR INT,
			RANGO_MAYOR INT
		);

		CREATE TABLE [QUICK_SORT].[BI_PROVINCIA](
			PROVINCIA_ID INTEGER PRIMARY KEY,
			PROVINCIA NVARCHAR(255)
		);

		CREATE TABLE [QUICK_SORT].[BI_LOCALIDAD](
			LOCALIDAD_ID INTEGER PRIMARY KEY,
			PROVINCIA_ID INTEGER REFERENCES [QUICK_SORT].[PROVINCIA] NOT NULL,
			LOCALIDAD NVARCHAR(255)
		);

		CREATE TABLE [QUICK_SORT].[BI_HECHO_TICKET](
			HECHO_TICKET_ID INTEGER IDENTITY(1,1),
			TIEMPO_ID INTEGER REFERENCES [QUICK_SORT].[BI_TIEMPO],
			LOCALIDAD_ID INTEGER REFERENCES [QUICK_SORT].[BI_LOCALIDAD],
			RANGO_ETAREO_ID INTEGER REFERENCES [QUICK_SORT].[BI_RANGO_ETAREO],
			CAJA_TIPO_ID INTEGER REFERENCES [QUICK_SORT].[BI_CAJA_TIPO],
			TURNO_ID INTEGER REFERENCES [QUICK_SORT].[BI_TURNO],
			CANT_UNIDADES_ARTICULO DECIMAL(18,0),
			CANT_DESCUENTO_APLICADO DECIMAL(18,0),
			MONTO_TOTAL DECIMAL(18,2),
			CANTIDAD DECIMAL(18,0)
			PRIMARY KEY(HECHO_TICKET_ID, TIEMPO_ID, LOCALIDAD_ID, RANGO_ETAREO_ID, CAJA_TIPO_ID, TURNO_ID)
		);

		CREATE TABLE [QUICK_SORT].[BI_SUCURSAL](
			SUCURSAL_ID INTEGER IDENTITY(1,1) PRIMARY KEY,
			SUCURSAL_LOCALIDAD_ID INTEGER REFERENCES [QUICK_SORT].[BI_LOCALIDAD],
			SUCURSAL_NOMBRE NVARCHAR(255)
		);

		CREATE TABLE [QUICK_SORT].[BI_HECHO_ENVIO](
			HECHO_ENVIO_ID INTEGER IDENTITY(1,1) PRIMARY KEY,
			TIEMPO_ID INTEGER REFERENCES [QUICK_SORT].[BI_TIEMPO],
			SUCURSAL_ID INTEGER REFERENCES [QUICK_SORT].[BI_SUCURSAL],
			RANGO_ETAREO_ID INTEGER REFERENCES [QUICK_SORT].[BI_RANGO_ETAREO],
			LOCALIDAD_ID INTEGER REFERENCES [QUICK_SORT].[BI_LOCALIDAD],
			CANT_ENVIOS_CUMPLIDOS DECIMAL(18,0),
			CANT_ENVIOS DECIMAL(18,0),
			COSTO DECIMAL(18,2)
		);

		CREATE TABLE [QUICK_SORT].[BI_PRODUCTO_CATEGORIA](
			PRODUCTO_CATEGORIA_ID INTEGER IDENTITY(1,1) PRIMARY KEY,
			PRODUCTO_CATEGORIA NVARCHAR(255)
		);

		CREATE TABLE [QUICK_SORT].[BI_PRODUCTO_SUB_CATEGORIA](
			PRODUCTO_SUB_CATEGORIA_ID INTEGER IDENTITY(1,1) PRIMARY KEY,
			PRODUCTO_CATEGORIA_ID INTEGER REFERENCES [QUICK_SORT].[BI_PRODUCTO_CATEGORIA],
			PRODUCTO_SUB_CATEGORIA NVARCHAR(255)
		);

		CREATE TABLE [QUICK_SORT].[BI_HECHO_CATEGORIA](
			HECHO_CATEGORIA_ID INTEGER IDENTITY(1,1) PRIMARY KEY,
			TIEMPO_ID INTEGER REFERENCES [QUICK_SORT].[BI_TIEMPO],
			PRODUCTO_SUB_CATEGORIA_ID INTEGER REFERENCES [QUICK_SORT].[BI_PRODUCTO_SUB_CATEGORIA],
			DESCUENTO_APLICADO DECIMAL(18,2)
		);

		CREATE TABLE [QUICK_SORT].[BI_MEDIO_PAGO_TIPO](
			MEDIO_PAGO_TIPO_ID INTEGER IDENTITY(1,1) PRIMARY KEY,
			MEDIO_PAGO_TIPO NVARCHAR(255)
		);

		CREATE TABLE [QUICK_SORT].[BI_MEDIO_PAGO](
			MEDIO_PAGO_ID INTEGER IDENTITY(1,1) PRIMARY KEY,
			MEDIO_PAGO_TIPO_ID INTEGER REFERENCES [QUICK_SORT].[BI_MEDIO_PAGO_TIPO],
			MEDIO_PAGO NVARCHAR(255)
		);

		CREATE TABLE [QUICK_SORT].[BI_HECHO_PAGO](
			HECHO_PAGO_ID INTEGER IDENTITY(1,1) PRIMARY KEY,
			MEDIO_PAGO_ID INTEGER REFERENCES [QUICK_SORT].[BI_MEDIO_PAGO],
			TIEMPO_ID INTEGER REFERENCES [QUICK_SORT].[BI_TIEMPO],
			RANGO_ETAREO_ID INTEGER REFERENCES [QUICK_SORT].[BI_RANGO_ETAREO],
			SUCURSAL_ID INTEGER REFERENCES [QUICK_SORT].[BI_SUCURSAL],
			TOTAL_CUOTAS DECIMAL(18,2),
			CANTIDAD_CUOTAS DECIMAL(18,0),
			TOTAL_DESCUENTO DECIMAL(18,2)
		);
END
GO

EXEC [QUICK_SORT].[CREATE_TABLES_BI]
GO


IF NOT EXISTS(SELECT name FROM sys.procedures WHERE name='MIGRAR_BI')
	EXEC('CREATE PROCEDURE [QUICK_SORT].[MIGRAR_BI] AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE [QUICK_SORT].[MIGRAR_BI]
AS
BEGIN

	--CAJA_TIPO
	INSERT INTO [QUICK_SORT].[BI_CAJA_TIPO] (CAJA_TIPO_ID, CAJA_TIPO)
	SELECT DISTINCT * FROM [QUICK_SORT].[CAJA_TIPO]

	--TURNO
	INSERT INTO [QUICK_SORT].[BI_TURNO](HORA_INICIAL, HORA_FINAL)
	VALUES ('8:00:00', '12:00:00'),
		('12:00:00', '16:00:00'),
		('16:00:00', '20:00:00')

	--TIEMPO
	INSERT INTO [QUICK_SORT].[BI_TIEMPO](ANIO, MES, CUATRIMESTRE)
	SELECT DISTINCT
		YEAR(t.TICKET_FECHA_HORA),
		MONTH(t.TICKET_FECHA_HORA),
		CASE
			WHEN MONTH(t.TICKET_FECHA_HORA) <= 4 THEN '1'
			WHEN MONTH(t.TICKET_FECHA_HORA) <= 8 THEN '2'
			WHEN MONTH(t.TICKET_FECHA_HORA) <= 12 THEN '3'
		END 
		FROM [QUICK_SORT].[TICKET] t

	--RANGO ETAREO
	INSERT INTO [QUICK_SORT].[BI_RANGO_ETAREO](RANGO_MENOR, RANGO_MAYOR)
	VALUES (0,25),
		(25, 35),
		(35,50),
		(50, 200)
	
	--PROVINCIA
	INSERT INTO [QUICK_SORT].[BI_PROVINCIA]
		SELECT * FROM [QUICK_SORT].[PROVINCIA]
	
	--LOCALIDAD
	INSERT INTO [QUICK_SORT].[BI_LOCALIDAD]
		SELECT * FROM [QUICK_SORT].[LOCALIDAD]

	--HECHO_TICKET
	INSERT INTO [QUICK_SORT].[BI_HECHO_TICKET](TIEMPO_ID, LOCALIDAD_ID, RANGO_ETAREO_ID, CAJA_TIPO_ID,
		TURNO_ID, CANT_UNIDADES_ARTICULO, CANT_DESCUENTO_APLICADO, MONTO_TOTAL, CANTIDAD)
		SELECT tie.TIEMPO_ID, d.LOCALIDAD_ID, re.RANGO_ETAREO_ID, c.CAJA_TIPO_ID,
		tur.TURNO_ID,sum(dt.DETALLE_CANTIDAD) , sum(tic.TICKET_TOTAL_PROMOCIONES + TICKET_DESCUENTO_MEDIO), sum(tic.TICKET_TOTAL), count(*) 
		FROM [QUICK_SORT].[TICKET] tic
		JOIN [QUICK_SORT].[BI_TIEMPO] tie ON tie.ANIO = YEAR(tic.TICKET_FECHA_HORA) AND tie.MES = MONTH(tic.TICKET_FECHA_HORA)
		JOIN [QUICK_SORT].[SUCURSAL] s ON s.SUCURSAL_ID = tic.TICKET_SUCURSAL_ID
		JOIN [QUICK_SORT].[DIRECCION] d ON s.SUCURSAL_DIRECCION_ID = d.DIRECCION_ID 
		JOIN [QUICK_SORT].[CAJA] c ON c.CAJA_ID = tic.TICKET_CAJA_ID
		JOIN [QUICK_SORT].[EMPLEADO] e ON e.EMPLEADO_LEGAJO = tic.TICKET_EMPLEADO_LEGAJO 
		JOIN [QUICK_SORT].[BI_RANGO_ETAREO] re ON DATEDIFF(YEAR, e.EMPLEADO_FECHA_NACIMIENTO, GETDATE()) >= re.RANGO_MENOR
		 AND DATEDIFF(YEAR, e.EMPLEADO_FECHA_NACIMIENTO, GETDATE()) < re.RANGO_MAYOR
		JOIN [QUICK_SORT].[BI_TURNO] tur ON tur.HORA_INICIAL <= CONVERT(VARCHAR(8),tic.TICKET_FECHA_HORA,108)
		 AND tur.HORA_FINAL > CONVERT(VARCHAR(8),tic.TICKET_FECHA_HORA,108)
		 JOIN [QUICK_SORT].[DETALLE_TICKET] dt ON dt.DETALLE_TICKET_TICKET_ID = tic.TICKET_ID
		 GROUP BY tie.TIEMPO_ID, d.LOCALIDAD_ID, re.RANGO_ETAREO_ID, c.CAJA_TIPO_ID,
			tur.TURNO_ID

	-- SUCURSAL
	INSERT INTO [QUICK_SORT].[BI_SUCURSAL](SUCURSAL_LOCALIDAD_ID, SUCURSAL_NOMBRE)
		SELECT l.LOCALIDAD_ID, s.SUCURSAL_NOMBRE FROM [QUICK_SORT].[SUCURSAL] s
		JOIN [QUICK_SORT].[DIRECCION] d ON d.DIRECCION_ID = s.SUCURSAL_DIRECCION_ID
		JOIN [QUICK_SORT].[LOCALIDAD] l ON l.LOCALIDAD_ID = d.LOCALIDAD_ID

	-- HECHO_ENVIO
	INSERT INTO [QUICK_SORT].[BI_HECHO_ENVIO](TIEMPO_ID, SUCURSAL_ID, RANGO_ETAREO_ID, LOCALIDAD_ID, CANT_ENVIOS_CUMPLIDOS,
		CANT_ENVIOS, COSTO)
		SELECT t.TIEMPO_ID, sbi.SUCURSAL_ID, re.RANGO_ETAREO_ID, d.LOCALIDAD_ID, 
		COUNT(CASE WHEN (DATEDIFF(HOUR, e.ENVIO_FECHA_ENTREGA, e.ENVIO_FECHA_PROGRAMADA)>= 0 ) THEN 1 ELSE 0 END),
		COUNT(*), MAX(e.ENVIO_COSTO)
		FROM [QUICK_SORT].[ENVIO] e
		JOIN [QUICK_SORT].[BI_TIEMPO] t ON t.ANIO = YEAR(e.ENVIO_FECHA_ENTREGA) AND t.MES = MONTH(e.ENVIO_FECHA_ENTREGA)
		JOIN [QUICK_SORT].[TICKET] ti ON ti.TICKET_ID = e.ENVIO_TICKET_ID
		JOIN [QUICK_SORT].[SUCURSAL] s ON s.SUCURSAL_ID = ti.TICKET_SUCURSAL_ID
		JOIN [QUICK_SORT].[BI_SUCURSAL] sbi ON sbi.SUCURSAL_NOMBRE = s.SUCURSAL_NOMBRE
		JOIN [QUICK_SORT].[CLIENTE] c ON c.CLIENTE_ID = e.ENVIO_CLIENTE_ID
		JOIN [QUICK_SORT].[BI_RANGO_ETAREO] re ON re.RANGO_MENOR <= DATEDIFF(YEAR, c.CLIENTE_FECHA_NACIMIENTO, GETDATE())
			AND re.RANGO_MAYOR > DATEDIFF(YEAR, c.CLIENTE_FECHA_NACIMIENTO, GETDATE())
		JOIN [QUICK_SORT].[DIRECCION] d ON d.DIRECCION_ID = c.CLIENTE_DIRECCION_ID
		GROUP BY t.TIEMPO_ID, sbi.SUCURSAL_ID, re.RANGO_ETAREO_ID, d.LOCALIDAD_ID
		
	-- PRODUCTO_CATEGORIA
	INSERT INTO [QUICK_SORT].[BI_PRODUCTO_CATEGORIA](PRODUCTO_CATEGORIA)
		SELECT PRODUCTO_CATEGORIA FROM [QUICK_SORT].[PRODUCTO_CATEGORIA]

	-- PRODUCTO_SUB_CATEGORIA
	INSERT INTO [QUICK_SORT].[BI_PRODUCTO_SUB_CATEGORIA](PRODUCTO_CATEGORIA_ID, PRODUCTO_SUB_CATEGORIA)
		SELECT pc.PRODUCTO_CATEGORIA_ID, sc.PRODUCTO_SUB_CATEGORIA FROM [QUICK_SORT].[PRODUCTO_SUB_CATEGORIA] sc
		JOIN [QUICK_SORT].[BI_PRODUCTO_CATEGORIA] pc ON pc.PRODUCTO_CATEGORIA_ID = sc.PRODUCTO_CATEGORIA_ID

	-- HECHO_CATEGORIA TODO:PROMO TOTAL MODIFICADO POR LUCA, CHEQUEAR 
	INSERT INTO [QUICK_SORT].[BI_HECHO_CATEGORIA](TIEMPO_ID, PRODUCTO_SUB_CATEGORIA_ID, DESCUENTO_APLICADO)
		SELECT ti.TIEMPO_ID, ps.PRODUCTO_SUB_CATEGORIA_ID, SUM(dp.PROMO_TOTAL) FROM [QUICK_SORT].[TICKET] t
		JOIN [QUICK_SORT].[DETALLE_TICKET] dt ON dt.DETALLE_TICKET_TICKET_ID = t.TICKET_ID
		JOIN [QUICK_SORT].[BI_TIEMPO] ti ON ti.ANIO = YEAR(t.TICKET_FECHA_HORA) AND ti.MES = MONTH(t.TICKET_FECHA_HORA)
		JOIN [QUICK_SORT].[PRODUCTO] p ON p.PRODUCTO_ID = dt.PRODUCTO_ID
		JOIN [QUICK_SORT].[BI_PRODUCTO_SUB_CATEGORIA] ps ON ps.PRODUCTO_SUB_CATEGORIA_ID = p.PRODUCTO_SUB_CATEGORIA_ID
		JOIN [QUICK_SORT].[DETALLE_POR_PROMOCION] dp ON dp.DETALLE_TICKET_ID = dt.DETALLE_TICKET_ID
		GROUP BY ti.TIEMPO_ID, ps.PRODUCTO_SUB_CATEGORIA_ID

	-- MEDIO_PAGO_TIPO
	INSERT INTO [QUICK_SORT].[BI_MEDIO_PAGO_TIPO](MEDIO_PAGO_TIPO)
		SELECT MEDIO_PAGO_TIPO FROM [QUICK_SORT].[MEDIO_PAGO_TIPO]

	-- MEDIO_PAGO
	INSERT INTO [QUICK_SORT].[BI_MEDIO_PAGO](MEDIO_PAGO_TIPO_ID, MEDIO_PAGO)
		SELECT mpt.MEDIO_PAGO_TIPO_ID, mp.PAGO_MEDIO_PAGO FROM [QUICK_SORT].[PAGO_MEDIO_PAGO] mp
		JOIN [QUICK_SORT].[BI_MEDIO_PAGO_TIPO] mpt ON mpt.MEDIO_PAGO_TIPO_ID = mp.PAGO_MEDIO_PAGO_ID

	-- HECHO_PAGO
	INSERT INTO [QUICK_SORT].[BI_HECHO_PAGO](MEDIO_PAGO_ID, TIEMPO_ID, RANGO_ETAREO_ID, SUCURSAL_ID, TOTAL_CUOTAS,
		CANTIDAD_CUOTAS, TOTAL_DESCUENTO)
		SELECT mp.MEDIO_PAGO_ID, t.TIEMPO_ID, re.RANGO_ETAREO_ID, s.SUCURSAL_ID, SUM(p.PAGO_IMPORTE),
		SUM(dp.DET_PAGO_CUOTAS), SUM(P.PAGO_DESCUENTO_APLICADO)
		FROM PAGO p
		JOIN BI_MEDIO_PAGO mp ON mp.MEDIO_PAGO_ID = p.PAGO_MEDIO_PAGO_ID
		JOIN BI_TIEMPO t ON t.ANIO = YEAR(p.PAGO_FECHA) AND t.MES = MONTH(p.PAGO_FECHA)
		JOIN TICKET ti ON ti.TICKET_ID = p.PAGO_TICKET_ID
		JOIN ENVIO e ON e.ENVIO_TICKET_ID = ti.TICKET_ID
		JOIN CLIENTE c ON c.CLIENTE_ID = e.ENVIO_CLIENTE_ID
		JOIN BI_RANGO_ETAREO re ON re.RANGO_MENOR <= DATEDIFF(YEAR, c.CLIENTE_FECHA_NACIMIENTO, GETDATE())
			AND re.RANGO_MAYOR > DATEDIFF(YEAR, c.CLIENTE_FECHA_NACIMIENTO, GETDATE())
		JOIN CAJA ca ON ca.CAJA_ID = ti.TICKET_CAJA_ID
		JOIN BI_SUCURSAL s ON s.SUCURSAL_ID = ca.CAJA_SUCURSAL_ID
		JOIN DETALLE_PAGO dp ON dp.DETALLE_PAGO_ID = p.DETALLE_PAGO_ID
		WHERE p.DETALLE_PAGO_ID IS NOT NULL
		GROUP BY mp.MEDIO_PAGO_ID, t.TIEMPO_ID, re.RANGO_ETAREO_ID, s.SUCURSAL_ID

		
		
	
END
GO

EXEC [QUICK_SORT].[MIGRAR_BI]
GO


--VISTAS

-- 1 TICKET PROMEDIO MENSUAL

IF EXISTS(SELECT 1 FROM sys.views WHERE name='TICKET_PROMEDIO_MENSUAL' AND type='v')
	DROP VIEW [QUICK_SORT].[TICKET_PROMEDIO_MENSUAL]
GO

CREATE VIEW [QUICK_SORT].[TICKET_PROMEDIO_MENSUAL]
AS
SELECT 
	ht.LOCALIDAD_ID AS 'LOCALIDAD',
	t.ANIO AS 'ANIO',
	t.MES AS 'MES',
	CAST(SUM(ht.MONTO_TOTAL)/SUM(ht.CANTIDAD)  AS DECIMAL(12,2)) AS 'TICKET PROMEDIO'
FROM [QUICK_SORT].[BI_HECHO_TICKET] ht
JOIN [QUICK_SORT].[BI_TIEMPO] t ON ht.TIEMPO_ID = t.TIEMPO_ID
GROUP BY ht.LOCALIDAD_ID, t.ANIO, t.MES
GO	

--2 CANTIDAD UNIDADES PROMEDIO

IF EXISTS(SELECT 1 FROM sys.views WHERE name='CANTIDAD_UNIDADES_PROMEDIO' AND type='v')
	DROP VIEW [QUICK_SORT].[CANTIDAD_UNIDADES_PROMEDIO]
GO

CREATE VIEW [QUICK_SORT].[CANTIDAD_UNIDADES_PROMEDIO]
AS 
SELECT
	t.CUATRIMESTRE AS 'CUATRIMESTRE',
	ht.TURNO_ID AS 'TURNO',
	CAST(SUM(ht.CANT_UNIDADES_ARTICULO)/SUM(ht.CANTIDAD) AS DECIMAL (12,2)) AS 'UNIDADES PROMEDIO'
FROM [QUICK_SORT].[BI_HECHO_TICKET] ht
JOIN [QUICK_SORT].[BI_TIEMPO] t ON ht.TIEMPO_ID = t.TIEMPO_ID
GROUP BY t.CUATRIMESTRE, ht.TURNO_ID
GO

--3 PORCENTAJE ANUAL DE VENTAS

IF EXISTS(SELECT 1 FROM sys.views WHERE name='PORCENTAJE_ANUAL_VENTAS' AND type='v')
	DROP VIEW [QUICK_SORT].[PORCENTAJE_ANUAL_VENTAS]
GO

CREATE VIEW [QUICK_SORT].[PORCENTAJE_ANUAL_VENTAS]
AS
SELECT
	t.ANIO AS 'ANIO',
	t.CUATRIMESTRE AS 'CUATRIMESTRE',
	ht.RANGO_ETAREO_ID AS 'RANGO ETAREO',
	ht.CAJA_TIPO_ID AS 'CAJA TIPO',
	CAST(SUM(ht.CANTIDAD) * 100/(SELECT SUM(ht2.CANTIDAD) FROM [QUICK_SORT].[BI_HECHO_TICKET] ht2 
		JOIN [QUICK_SORT].[BI_TIEMPO] t2 ON ht2.TIEMPO_ID = t2.TIEMPO_ID 
		WHERE t2.ANIO = t.ANIO GROUP BY t2.ANIO) AS DECIMAL(12,2)) AS 'PORCENTAJE DE VENTAS'
FROM [QUICK_SORT].[BI_HECHO_TICKET] ht
JOIN [QUICK_SORT].[BI_TIEMPO] t ON ht.TIEMPO_ID = t.TIEMPO_ID
GROUP BY t.ANIO, t.CUATRIMESTRE, ht.RANGO_ETAREO_ID, ht.CAJA_TIPO_ID
GO

--4 CANTIDAD DE VENTAS REGISTRADAS POR TURNO

IF EXISTS(SELECT 1 FROM sys.views WHERE name='VENTAS_POR_TURNO' AND type='v')
	DROP VIEW [QUICK_SORT].[VENTAS_POR_TURNO]
GO

CREATE VIEW [QUICK_SORT].[VENTAS_POR_TURNO]
AS
SELECT
	t.ANIO AS 'ANIO',
	t.MES AS 'MES',
	ht.LOCALIDAD_ID AS 'LOCALIDAD',
	ht.TURNO_ID AS 'TURNO',
	SUM(CANTIDAD) AS 'CANTIDAD VENTAS'
FROM [QUICK_SORT].[BI_HECHO_TICKET] ht
JOIN [QUICK_SORT].[BI_TIEMPO] t ON ht.TIEMPO_ID = t.TIEMPO_ID
GROUP BY t.ANIO, t.MES,	ht.LOCALIDAD_ID, ht.TURNO_ID
GO

--5 PORCENTAJE DE DESCUENTO APLICADO TOCHECK: HABRIA QUE DIVIDIRLO POR EL SUBTOTAL?

IF EXISTS(SELECT 1 FROM sys.views WHERE name='PORCENTAJE_DESCUENTO_APLICADO' AND type='v')
	DROP VIEW [QUICK_SORT].[PORCENTAJE_DESCUENTO_APLICADO]
GO

CREATE VIEW [QUICK_SORT].[PORCENTAJE_DESCUENTO_APLICADO]
AS
SELECT
	t.ANIO AS 'ANIO',
	t.MES AS 'MES',
	CAST(SUM(ht.CANT_DESCUENTO_APLICADO) * 100 / SUM(ht.MONTO_TOTAL) AS DECIMAL(12,2)) AS 'PORCENTAJE DESCUENTO APLICADO'
FROM [QUICK_SORT].[BI_HECHO_TICKET] ht
JOIN [QUICK_SORT].[BI_TIEMPO] t ON ht.TIEMPO_ID = t.TIEMPO_ID
GROUP BY t.ANIO, t.MES
GO

--6 TRES CATEGORIAS DE PRODUCTOS CON MAYOR DESCUENTO APLICADO

IF EXISTS(SELECT 1 FROM sys.views WHERE name='TRES_CATEGORIAS_MAYOR_DESCUENTO' AND type='v')
	DROP VIEW [QUICK_SORT].[TRES_CATEGORIAS_MAYOR_DESCUENTO]
GO

CREATE VIEW [QUICK_SORT].[TRES_CATEGORIAS_MAYOR_DESCUENTO]
AS
SELECT
	t.ANIO AS 'ANIO',
	t.CUATRIMESTRE AS 'CUATRIMESTRE',
	psc.PRODUCTO_CATEGORIA_ID AS CATEGORIA
FROM [QUICK_SORT].[BI_HECHO_CATEGORIA] hc
JOIN [QUICK_SORT].[BI_TIEMPO] t ON hc.TIEMPO_ID = t.TIEMPO_ID
JOIN [QUICK_SORT].[BI_PRODUCTO_SUB_CATEGORIA] psc ON psc.PRODUCTO_SUB_CATEGORIA_ID = hc.PRODUCTO_SUB_CATEGORIA_ID
WHERE (SELECT COUNT(*)
     FROM [QUICK_SORT].[BI_HECHO_CATEGORIA] hc2
     JOIN [QUICK_SORT].[BI_TIEMPO] t2 ON hc2.TIEMPO_ID = t2.TIEMPO_ID
     WHERE t2.CUATRIMESTRE = t.CUATRIMESTRE
       AND t2.ANIO = t.ANIO
       AND hc2.DESCUENTO_APLICADO > hc.DESCUENTO_APLICADO
    ) < 3
GO

--7 PORCENTAJE DE CUMPLIMIENTO DE ENVIOS COMENTARIO: ESTA MAL EL BI_HECHO_ENVIO, Y SACA MAL EL PORCENTAJE

IF EXISTS(SELECT 1 FROM sys.views WHERE name='PORCENTAJE_CUMPLIMIENTO_ENVIOS' AND type='v')
	DROP VIEW [QUICK_SORT].[PORCENTAJE_CUMPLIMIENTO_ENVIOS]
GO

CREATE VIEW [QUICK_SORT].[PORCENTAJE_CUMPLIMIENTO_ENVIOS]
AS
SELECT
	t.ANIO AS 'ANIO',
	t.MES AS 'MES',
	he.SUCURSAL_ID AS 'SUCURSAL',
	CAST(SUM(he.CANT_ENVIOS_CUMPLIDOS) * 100 / SUM(he.CANT_ENVIOS) AS DECIMAL(12,2)) AS 'PORC ENVIOS CUMPLIDOS'
FROM [QUICK_SORT].[BI_HECHO_ENVIO] he
JOIN [QUICK_SORT].[BI_TIEMPO] t ON  he.TIEMPO_ID = t.TIEMPO_ID
GROUP BY t.ANIO, t.MES, he.SUCURSAL_ID
GO

--8 CANTIDAD DE ENVIOS POR RANGO ETARIO DE CLIENTES

IF EXISTS(SELECT 1 FROM sys.views WHERE name='ENVIOS_POR_RANGO' AND type='v')
	DROP VIEW [QUICK_SORT].[ENVIOS_POR_RANGO]
GO

CREATE VIEW [QUICK_SORT].[ENVIOS_POR_RANGO]
AS
SELECT 
	t.ANIO AS 'ANIO',
	t.CUATRIMESTRE AS 'CUATRIMESTRE',
	he.RANGO_ETAREO_ID AS 'RANGO ETAREO',
	SUM(he.CANT_ENVIOS) AS 'CANTIDAD DE ENVIOS'
FROM [QUICK_SORT].[BI_HECHO_ENVIO] he
JOIN [QUICK_SORT].[BI_TIEMPO] t ON he.TIEMPO_ID = t.TIEMPO_ID
GROUP BY t.ANIO, t.CUATRIMESTRE, he.RANGO_ETAREO_ID
GO

-- 9 TOP 5 LOCALIDADES CON MAYOR COSTO DE ENVIO -- NO ME QUEDA CLARO POR LO QUE SE ESTA ORDENANDO

IF EXISTS(SELECT 1 FROM sys.views WHERE name='TOP5_LOCALIDADES_COSTO_ENVIO' AND type='v')
	DROP VIEW [QUICK_SORT].[TOP5_LOCALIDADES_COSTO_ENVIO]
GO

CREATE VIEW [QUICK_SORT].[TOP5_LOCALIDADES_COSTO_ENVIO] AS
SELECT TOP 5
    l.LOCALIDAD,
    SUM(he.COSTO) AS TOTAL_COSTO_ENVIO
FROM QUICK_SORT.BI_HECHO_ENVIO he
JOIN QUICK_SORT.BI_LOCALIDAD l ON he.LOCALIDAD_ID = l.LOCALIDAD_ID
GROUP BY l.LOCALIDAD
ORDER BY SUM(he.COSTO) DESC

GO

--10 TOP 3 SUCURSALES CON MAYOR IMPORTE DE PAGO EN CUOTAS

IF EXISTS(SELECT 1 FROM sys.views WHERE name='TOP3_SUCURSALES_MAYOR_PAGO_CUOTA' AND type='v')
	DROP VIEW [QUICK_SORT].[TOP3_SUCURSALES_MAYOR_PAGO_CUOTA]
GO

CREATE VIEW [QUICK_SORT].[TOP3_SUCURSALES_MAYOR_PAGO_CUOTA] AS
SELECT TOP 3 hp.SUCURSAL_ID ,t.ANIO, t.MES, mp.MEDIO_PAGO
FROM [QUICK_SORT].[BI_HECHO_PAGO] hp 
JOIN [QUICK_SORT].[BI_TIEMPO] t ON t.TIEMPO_ID = hp.TIEMPO_ID
JOIN [QUICK_SORT].[BI_MEDIO_PAGO] mp ON mp.MEDIO_PAGO_ID = hp.MEDIO_PAGO_ID
GROUP BY hp.SUCURSAL_ID, t.ANIO, t.MES, mp.MEDIO_PAGO
ORDER BY SUM(hp.TOTAL_CUOTAS) DESC

GO


/*WHERE  (SELECT COUNT(*)
     FROM [QUICK_SORT].[BI_HECHO_PAGO] hp2
     JOIN [QUICK_SORT].[BI_TIEMPO] t2 ON hp2.TIEMPO_ID = t2.TIEMPO_ID
     WHERE t2.MES = t.MES
       AND t2.ANIO = t.ANIO
	   AND hp2.MEDIO_PAGO_ID = hp.MEDIO_PAGO_ID
	   GROUP BY t2.ANIO,t2.MES, hp2.MEDIO_PAGO_ID
	   HAVING SUM(hp2.TOTAL_CUOTAS) > SUM(hp.TOTAL_CUOTAS)
    ) < 3*/

--11 promedio importe cuota por rango etareo cliente

IF EXISTS(SELECT 1 FROM sys.views WHERE name='PROMEDIO_CUOTA_POR_RANGO' AND type='v')
	DROP VIEW [QUICK_SORT].[PROMEDIO_CUOTA_POR_RANGO]
GO

CREATE VIEW [QUICK_SORT].[PROMEDIO_CUOTA_POR_RANGO] AS 
SELECT
	hp.RANGO_ETAREO_ID AS 'RANGO ETAREO',
	SUM(hp.TOTAL_CUOTAS)/sum(hp.CANTIDAD_CUOTAS) AS 'PROMEDIO CUOTA'
FROM [QUICK_SORT].[BI_HECHO_PAGO] hp
GROUP BY hp.RANGO_ETAREO_ID
GO

--12 PORCENTAJE DESCUENTO APLICADO POR MEDIO PAGO

IF EXISTS(SELECT 1 FROM sys.views WHERE name='DESCUENTO_POR_MEDIO_PAGO' AND type='v')
	DROP VIEW [QUICK_SORT].[DESCUENTO_POR_MEDIO_PAGO]
GO

CREATE VIEW [QUICK_SORT].[DESCUENTO_POR_MEDIO_PAGO] AS
SELECT
	t.ANIO AS 'ANIO',
	t.CUATRIMESTRE AS 'CUATRIMESTRE',
	hp.MEDIO_PAGO_ID AS 'MEDIO PAGO',
	SUM(hp.TOTAL_DESCUENTO) * 100 /SUM(hp.TOTAL_CUOTAS + hp.TOTAL_DESCUENTO) AS 'PORCENTAJE DESCUENTO'
FROM [QUICK_SORT].[BI_HECHO_PAGO] hp
JOIN [QUICK_SORT].[BI_TIEMPO] t ON t.TIEMPO_ID = hp.TIEMPO_ID
GROUP BY t.ANIO, t.CUATRIMESTRE, hp.MEDIO_PAGO_ID

GO