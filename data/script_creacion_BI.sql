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

	-- HECHO_ENVIO TODO:REVISAR LOS ENVIOS CUMPLIDOS X FECHA PROGRAMADA
	INSERT INTO [QUICK_SORT].[BI_HECHO_ENVIO](TIEMPO_ID, SUCURSAL_ID, RANGO_ETAREO_ID, LOCALIDAD_ID, CANT_ENVIOS_CUMPLIDOS,
		CANT_ENVIOS, COSTO)
		SELECT t.TIEMPO_ID, sbi.SUCURSAL_ID, re.RANGO_ETAREO_ID, l.LOCALIDAD_ID, COUNT(DISTINCT e.ENVIO_FECHA_ENTREGA),
		COUNT(DISTINCT e.ENVIO_HORA_FIN), e.ENVIO_COSTO
		FROM [QUICK_SORT].[ENVIO] e
		JOIN [QUICK_SORT].[BI_TIEMPO] t ON t.ANIO = YEAR(e.ENVIO_FECHA_ENTREGA) AND t.MES = MONTH(e.ENVIO_FECHA_ENTREGA)
		JOIN [QUICK_SORT].[TICKET] ti ON ti.TICKET_ID = e.ENVIO_TICKET_ID
		JOIN [QUICK_SORT].[SUCURSAL] s ON s.SUCURSAL_ID = ti.TICKET_SUCURSAL_ID
		JOIN [QUICK_SORT].[BI_SUCURSAL] sbi ON sbi.SUCURSAL_NOMBRE = s.SUCURSAL_NOMBRE
		JOIN [QUICK_SORT].[CLIENTE] c ON c.CLIENTE_ID = e.ENVIO_CLIENTE_ID
		JOIN [QUICK_SORT].[BI_RANGO_ETAREO] re ON re.RANGO_MENOR <= DATEDIFF(YEAR, c.CLIENTE_FECHA_NACIMIENTO, GETDATE())
			AND re.RANGO_MAYOR > DATEDIFF(YEAR, c.CLIENTE_FECHA_NACIMIENTO, GETDATE())
		JOIN [QUICK_SORT].[DIRECCION] d ON d.DIRECCION_ID = c.CLIENTE_DIRECCION_ID
		JOIN [QUICK_SORT].[BI_LOCALIDAD] l ON l.LOCALIDAD_ID = d.LOCALIDAD_ID
		GROUP BY t.TIEMPO_ID, sbi.SUCURSAL_ID, re.RANGO_ETAREO_ID, l.LOCALIDAD_ID, e.ENVIO_COSTO


END
GO

EXEC [QUICK_SORT].[MIGRAR_BI]
GO


--VISTAS
