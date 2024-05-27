USE [GD1C2024]
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'QUICK_SORT')
	EXEC('CREATE SCHEMA QUICK_SORT')
GO

IF NOT EXISTS(SELECT name FROM sys.procedures WHERE name = 'DROP_TABLES')
	EXEC('CREATE PROCEDURE [QUICK_SORT].[DROP_TABLES] AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE [QUICK_SORT].[DROP_TABLES]
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
	
	EXEC sp_MSforeachtable 'DROP TABLE ?', @whereand='AND schema_name(schema_id) = ''QUICK_SORT'' AND o.name NOT LIKE ''BI_%'''
END
GO

EXEC [QUICK_SORT].[DROP_TABLES]
GO


IF NOT EXISTS(SELECT name FROM sys.procedures WHERE name='CREATE_TABLES')
   EXEC('CREATE PROCEDURE [QUICK_SORT].[CREATE_TABLES] AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE [QUICK_SORT].[CREATE_TABLES]
AS
BEGIN

		CREATE TABLE [QUICK_SORT].[PROVINCIA](
			PROVINCIA_ID INTEGER IDENTITY(1,1) PRIMARY KEY,
			PROVINCIA NVARCHAR(255)
		);

		CREATE TABLE [QUICK_SORT].[LOCALIDAD](
			LOCALIDAD_ID INTEGER IDENTITY(1,1) PRIMARY KEY,
			PROVINCIA_ID INTEGER REFERENCES [QUICK_SORT].[PROVINCIA],
			LOCALIDAD NVARCHAR(255)
		);

		CREATE TABLE [QUICK_SORT].[DIRECCION](
			DIRECCION_ID INTEGER IDENTITY(1,1) PRIMARY KEY,
			LOCALIDAD_ID INTEGER REFERENCES [QUICK_SORT].[LOCALIDAD],
			DIRECCION NVARCHAR(255)
		);

		CREATE TABLE [QUICK_SORT].[DESCUENTO_MEDIO_PAGO](
			DESCUENTO_MEDIO_PAGO_CODIGO DECIMAL(18,0) PRIMARY KEY,
			--DESCUENTO_PAGO_MEDIO_PAGO_ID INTEGER REFERENCES [QUICK_SORT].[PAGO_MEDIO_PAGO],
			DESCUENTO_FECHA_INICIO DATETIME,
			DESCUENTO_FECHA_FIN DATETIME,
			DESCUENTO_PORCENTAJE DECIMAL(18,2),
			DESCUENTO_TOPE DECIMAL(18,2),
			DESCUENTO_DESCRIPCION NVARCHAR(255)
		); 

		CREATE TABLE [QUICK_SORT].[SUPERMERCADO](
			SUPER_CUIT NVARCHAR(255) PRIMARY KEY,
			SUPER_DIRECCION_ID INTEGER REFERENCES [QUICK_SORT].[DIRECCION],
			SUPER_NOMBRE NVARCHAR(255),
			SUPER_RAZON_SOC NVARCHAR(255),
			SUPER_IIBB NVARCHAR(255),
			SUPER_FECHA_INI_ACTIVIDAD DATETIME,
			SUPER_CONDICION_FISCAL NVARCHAR(255)
		);

		CREATE TABLE [QUICK_SORT].[SUCURSAL](
			SUCURSAL_ID INTEGER IDENTITY(1,1) PRIMARY KEY,
			SUCURSAL_SUPER_CUIT NVARCHAR(255) REFERENCES [QUICK_SORT].[SUPERMERCADO],
			SUCURSAL_DIRECCION_ID INTEGER REFERENCES [QUICK_SORT].[DIRECCION],
			SUCURSAL_NOMBRE NVARCHAR(255)
		);

		CREATE TABLE [QUICK_SORT].[EMPLEADO](
			EMPLEADO_LEGAJO INTEGER IDENTITY(1,1) PRIMARY KEY,
			EMPLEADO_SUCURSAL_ID INTEGER REFERENCES [QUICK_SORT].[SUCURSAL],
			EMPLEADO_NOMBRE NVARCHAR(255),
			EMPLEADO_APELLIDO NVARCHAR(255),
			EMPLEADO_FECHA_REGISTRO DATETIME,
			EMPLEADO_TELEFONO DECIMAL(18,0),
			EMPLEADO_MAIL NVARCHAR(255),
			EMPLEADO_FECHA_NACIMIENTO DATE,
			EMPLEADO_DNI DECIMAL(18,0)
		);

		CREATE TABLE [QUICK_SORT].[TICKET_TIPO_COMPROBANTE](
			TICKET_TIPO_COMPROBANTE_ID INTEGER IDENTITY(1,1) PRIMARY KEY,
			TICKET_TIPO_COMPROBANTE NVARCHAR(255)
		);

		CREATE TABLE [QUICK_SORT].[CAJA_TIPO](
			CAJA_TIPO_ID INTEGER IDENTITY(1,1) PRIMARY KEY,
			CAJA_TIPO NVARCHAR(255)
		);
		CREATE TABLE [QUICK_SORT].[ESTADO](
			ESTADO_ID INTEGER IDENTITY(1,1) PRIMARY KEY,
			ESTADO_TIPO NVARCHAR(255)
		);

		CREATE TABLE [QUICK_SORT].[CAJA](
			CAJA_ID INTEGER IDENTITY(1,1) PRIMARY KEY,
			CAJA_SUCURSAL_ID INTEGER REFERENCES [QUICK_SORT].[SUCURSAL],
			CAJA_TIPO_ID INTEGER REFERENCES [QUICK_SORT].[CAJA_TIPO],
			CAJA_NUMERO DECIMAL(18,0)
		);

		CREATE TABLE [QUICK_SORT].[ESTADO_POR_ENVIO](
			ESTADO_ID INTEGER REFERENCES [QUICK_SORT].[ESTADO] NOT NULL,
			ENVIO_ID INTEGER REFERENCES [QUICK_SORT].[ENVIO] NOT NULL,
			ESTADO_FECHA_INICIO DATETIME
			PRIMARY KEY(ESTADO_ID, ENVIO_ID)
			PRIMARY KEY(ESTADO_ID)
		);

		CREATE TABLE [QUICK_SORT].[TICKET](
			TICKET_ID INTEGER IDENTITY(1,1) PRIMARY KEY,
			TICKET_SUCURSAL_ID INTEGER REFERENCES [QUICK_SORT].[SUCURSAL],
			TICKET_EMPLEADO_LEGAJO INTEGER REFERENCES [QUICK_SORT].[EMPLEADO],
			TICKET_CAJA_ID INTEGER REFERENCES [QUICK_SORT].[CAJA],
			TICKET_TIPO_COMPROBANTE_ID INTEGER REFERENCES [QUICK_SORT].[TICKET_TIPO_COMPROBANTE],
			TICKET_NRO DECIMAL(18,0),
			TICKET_TOTAL DECIMAL(18,2),
			TICKET_FECHA_HORA DATETIME,
			TICKET_SUBTOTAL_PRODUCTOS DECIMAL(18,2),
			TICKET_DESCUENTO_MEDIO DECIMAL(18,2),
			TICKET_TOTAL_PROMOCIONES DECIMAL(18,2),
			TICKET_TOTAL_ENVIO DECIMAL(18,2)
		);

		CREATE TABLE [QUICK_SORT].[DETALLE_TICKET](
			DETALLE_TICKET_ID INTEGER IDENTITY(1,1) PRIMARY KEY,
			DETALLE_TICKET_TICKET_ID INTEGER REFERENCES [QUICK_SORT].[TICKET] NOT NULL,
			PRODUCTO_ID INTEGER REFERENCES [QUICK_SORT].[PRODUCTO] NOT NULL,
			DETALLE_CANTIDAD DECIMAL(18,0),
			DETALLE_PRECIO_UNITARIO DECIMAL(18,2),
			DETALLE_TOTAL_PRODUCTO DECIMAL(18,2)
		);
END
GO

EXEC [QUICK_SORT].[CREATE_TABLES]
GO

ALTER PROCEDURE [QUICK_SORT].[MIGRAR]
AS
BEGIN
	--provincia

	INSERT INTO [QUICK_SORT].[PROVINCIA] (PROVINCIA)
		SELECT DISTINCT SUCURSAL_PROVINCIA
		FROM [gd_esquema].[Maestra]
		WHERE SUCURSAL_PROVINCIA IS NOT NULL
		UNION
		SELECT DISTINCT SUPER_PROVINCIA
		FROM [gd_esquema].[Maestra]
		WHERE SUPER_PROVINCIA IS NOT NULL	
		UNION
		SELECT DISTINCT CLIENTE_PROVINCIA
		FROM [gd_esquema].Maestra
		WHERE CLIENTE_PROVINCIA IS NOT NULL
	
	-- LOCALIDAD

	INSERT INTO [QUICK_SORT].[LOCALIDAD] (PROVINCIA_ID, LOCALIDAD)
		SELECT DISTINCT PROVINCIA_ID, SUPER_LOCALIDAD
		FROM [gd_esquema].[Maestra]
		JOIN [QUICK_SORT].PROVINCIA ON SUPER_PROVINCIA = PROVINCIA
		WHERE SUPER_LOCALIDAD IS NOT NULL
		UNION
		SELECT DISTINCT PROVINCIA_ID, SUCURSAL_LOCALIDAD
		FROM [gd_esquema].[Maestra]
		JOIN [QUICK_SORT].PROVINCIA ON SUCURSAL_PROVINCIA = PROVINCIA
		WHERE SUPER_LOCALIDAD IS NOT NULL
		UNION
		SELECT DISTINCT PROVINCIA_ID, CLIENTE_LOCALIDAD
		FROM [gd_esquema].[Maestra]
		JOIN [QUICK_SORT].[PROVINCIA] ON CLIENTE_PROVINCIA = PROVINCIA
		WHERE CLIENTE_LOCALIDAD IS NOT NULL

		--TICKET_TIPO_COMPROBANTE	
	INSERT INTO [QUICK_SORT].[TICKET_TIPO_COMPROBANTE] (TICKET_TIPO_COMPROBANTE)
		SELECT DISTINCT TICKET_TIPO_COMPROBANTE
		FROM [gd_esquema].[Maestra]
		
		--ESTADO
	INSERT INTO [QUICK_SORT].[ESTADO] (ESTADO_TIPO)
		SELECT DISTINCT ENVIO_ESTADO
		FROM [gd_esquema].[Maestra]
		WHERE ENVIO_ESTADO IS NOT NULL

		--ESTADO POR ENVIO
	INSERT INTO [QUICK_SORT].[ESTADO_POR_ENVIO] (ESTADO_ID)
		SELECT DISTINCT es.ESTADO_ID, en.ENVIO_ID
		FROM [gd_esquema].[Maestra] m
		JOIN [QUICK_SORT].[ESTADO] es ON m.ENVIO_ESTADO = es.ESTADO_TIPO 
		JOIN [QUICK_SORT].[TICKET] t ON t.TICKET_NRO = m.TICKET_NUMERO 
		and t.TICKET_FECHA_HORA = m.TICKET_FECHA_HORA and t.TICKET_SUBTOTAL_PRODUCTOS = m.TICKET_SUBTOTAL_PRODUCTOS
		JOIN [QUICK_SORT].[ENVIO] en ON en.TICKET_ID = t.TICKET_ID

		-- DIRECCION

	INSERT INTO [QUICK_SORT].[DIRECCION] (LOCALIDAD_ID, DIRECCION)
		SELECT DISTINCT LOCALIDAD_ID, SUPER_DOMICILIO
		FROM [gd_esquema].[Maestra]
		JOIN [QUICK_SORT].[LOCALIDAD] ON SUPER_LOCALIDAD = LOCALIDAD
		WHERE SUPER_DOMICILIO IS NOT NULL
		UNION
		SELECT DISTINCT LOCALIDAD_ID, SUCURSAL_DIRECCION
		FROM [gd_esquema].[Maestra]
		JOIN [QUICK_SORT].[LOCALIDAD] ON SUCURSAL_LOCALIDAD = LOCALIDAD
		WHERE SUCURSAL_DIRECCION IS NOT NULL
		UNION
		SELECT DISTINCT LOCALIDAD_ID, CLIENTE_DOMICILIO
		FROM [gd_esquema].[Maestra]
		JOIN [QUICK_SORT].[LOCALIDAD] ON CLIENTE_LOCALIDAD = LOCALIDAD
		WHERE CLIENTE_DOMICILIO IS NOT NULL

	-- SUPERMERCADO

	INSERT INTO [QUICK_SORT].[SUPERMERCADO] (SUPER_CUIT, SUPER_DIRECCION_ID, SUPER_NOMBRE,
	SUPER_RAZON_SOC, SUPER_IIBB, SUPER_FECHA_INI_ACTIVIDAD, SUPER_CONDICION_FISCAL)
		SELECT DISTINCT SUPER_CUIT, DIRECCION_ID, SUPER_NOMBRE, SUPER_RAZON_SOC, SUPER_IIBB, SUPER_FECHA_INI_ACTIVIDAD,
		SUPER_CONDICION_FISCAL
		FROM [gd_esquema].[Maestra]
		JOIN [QUICK_SORT].[DIRECCION] ON SUPER_DOMICILIO = DIRECCION
		WHERE SUPER_CUIT IS NOT NULL 

	-- SUCURSAL
	
	INSERT INTO [QUICK_SORT].[SUCURSAL] (SUCURSAL_SUPER_CUIT, SUCURSAL_DIRECCION_ID, SUCURSAL_NOMBRE)
		SELECT DISTINCT s.SUPER_CUIT, d.DIRECCION_ID, m.SUCURSAL_NOMBRE
		FROM [gd_esquema].[Maestra] m
		JOIN [QUICK_SORT].[DIRECCION] d ON m.SUCURSAL_DIRECCION = d.DIRECCION
		JOIN [QUICK_SORT].[SUPERMERCADO] s ON s.SUPER_CUIT = m.SUPER_CUIT
		WHERE SUCURSAL_NOMBRE IS NOT NULL

	-- EMPLEADO (TODO: La FK de sucursal_id quedaria en null?)
	
	INSERT INTO [QUICK_SORT].[EMPLEADO] (EMPLEADO_SUCURSAL_ID, EMPLEADO_NOMBRE, EMPLEADO_APELLIDO, 
	EMPLEADO_FECHA_REGISTRO, EMPLEADO_TELEFONO, EMPLEADO_MAIL, EMPLEADO_FECHA_NACIMIENTO, EMPLEADO_DNI)
		SELECT DISTINCT s.SUCURSAL_ID, m.EMPLEADO_NOMBRE, m.EMPLEADO_APELLIDO, m.EMPLEADO_FECHA_REGISTRO, m.EMPLEADO_TELEFONO,
		m.EMPLEADO_MAIL, m.EMPLEADO_FECHA_NACIMIENTO, m.EMPLEADO_DNI
		FROM [gd_esquema].[Maestra] m
		JOIN [QUICK_SORT].[SUCURSAL] s ON s.SUCURSAL_NOMBRE = m.SUCURSAL_NOMBRE
		WHERE EMPLEADO_DNI IS NOT NULL

	-- DESCUENTO MEDIO PAGO (TODO:FK DESCUENTO PAGO MEDIO PAGO ID)

	INSERT INTO [QUICK_SORT].[DESCUENTO_MEDIO_PAGO](DESCUENTO_MEDIO_PAGO_CODIGO, DESCUENTO_FECHA_INICIO,
	DESCUENTO_FECHA_FIN, DESCUENTO_PORCENTAJE, DESCUENTO_TOPE, DESCUENTO_DESCRIPCION)
		SELECT DISTINCT m.DESCUENTO_CODIGO, m.DESCUENTO_FECHA_INICIO, m.DESCUENTO_FECHA_FIN, m.DESCUENTO_PORCENTAJE_DESC,
		m.DESCUENTO_TOPE, m.DESCUENTO_DESCRIPCION
		FROM [gd_esquema].[Maestra] m
		WHERE m.DESCUENTO_CODIGO IS NOT NULL

		--CAJA_TIPO
	INSERT INTO [QUICK_SORT].[CAJA_TIPO] (CAJA_TIPO)
		SELECT DISTINCT CAJA_TIPO
		FROM [gd_esquema].[Maestra]
		WHERE CAJA_TIPO IS NOT NULL		


		--CAJA
	INSERT INTO [QUICK_SORT].[CAJA] (CAJA_SUCURSAL_ID, CAJA_TIPO_ID, CAJA_NUMERO)
		SELECT DISTINCT s.SUCURSAL_ID, c.CAJA_TIPO_ID, m.CAJA_NUMERO FROM [QUICK_SORT].[SUCURSAL] s 
		JOIN [gd_esquema].[Maestra] m on s.sucursal_nombre = m.SUCURSAL_NOMBRE
		JOIN [QUICK_SORT].[CAJA_TIPO] c on c.CAJA_TIPO = m.CAJA_TIPO

		--TICKET
		--TODO: TICKET_TOTAL_PROMOCIONES
	INSERT INTO [QUICK_SORT].[TICKET](TICKET_NRO,TICKET_SUCURSAL_ID,TICKET_EMPLEADO_LEGAJO,TICKET_CAJA_ID,
			TICKET_TIPO_COMPROBANTE_ID,TICKET_TOTAL,TICKET_FECHA_HORA,TICKET_SUBTOTAL_PRODUCTOS,
			TICKET_DESCUENTO_MEDIO, TICKET_TOTAL_ENVIO)
		SELECT DISTINCT m.TICKET_NUMERO, s.SUCURSAL_ID, e.EMPLEADO_LEGAJO, c.CAJA_SUCURSAL_ID,
		(SELECT t.TICKET_TIPO_COMPROBANTE_ID FROM [QUICK_SORT].[TICKET_TIPO_COMPROBANTE] t WHERE t.TICKET_TIPO_COMPROBANTE = m.TICKET_TIPO_COMPROBANTE),
		m.TICKET_TOTAL_TICKET, m.TICKET_FECHA_HORA, m.TICKET_SUBTOTAL_PRODUCTOS, m.TICKET_TOTAL_DESCUENTO_APLICADO_MP, m.TICKET_TOTAL_ENVIO
		FROM gd_esquema.Maestra m 
		join [QUICK_SORT].[SUCURSAL] s on s.SUCURSAL_NOMBRE = m.SUCURSAL_NOMBRE 
		join [QUICK_SORT].[EMPLEADO] e on e.EMPLEADO_DNI = m.EMPLEADO_DNI
		join [QUICK_SORT].[CAJA] c on c.CAJA_SUCURSAL_ID = s.SUCURSAL_ID and c.CAJA_NUMERO = m.CAJA_NUMERO


		--DETALLE_TICKET
	INSERT INTO [QUICK_SORT].[DETALLE_TICKET](DETALLE_TICKET_TICKET_ID,PRODUCTO_ID, DETALLE_CANTIDAD,
				DETALLE_PRECIO_UNITARIO,DETALLE_TOTAL_PRODUCTO)
		SELECT DISTINCT t1.ticket_id,p.PRODUCTO_ID, m.TICKET_DET_CANTIDAD, m.TICKET_DET_PRECIO, m.TICKET_DET_TOTAL
		from [gd_esquema].[Maestra] m
		join [QUICK_SORT].[TICKET] t1 on t1.TICKET_NRO = m.TICKET_NUMERO
		and t1.TICKET_FECHA_HORA = m.TICKET_FECHA_HORA
		and t1.TICKET_SUBTOTAL_PRODUCTOS = m.TICKET_SUBTOTAL_PRODUCTOS
		JOIN [QUICK_SORT].[PRODUCTO] p ON p.PRODUCTO_NOMBRE = m.PRODUCTO_NOMBRE 
		and p.PRODUCTO_DESCRIPCION = m.PRODUCTO_DESCRIPCION
		and p.PRODUCTO_PRECIO = m.PRODUCTO_PRECIO and p.PRODUCTO_MARCA = m.PRODUCTO_MARCA


END
GO

EXEC [QUICK_SORT].[MIGRAR]
GO

SELECT DISTINCT m.PROMO_CODIGO, PROMOCION_DESCRIPCION,m.PROMOCION_FECHA_INICIO, m.PROMOCION_FECHA_FIN FROM [gd_esquema].Maestra m where PROMO_CODIGO is not null

SELECT DISTINCT ENVIO_ESTADO, ENVIO_HORA_INICIO, ENVIO_HORA_FIN FROM gd_esquema.Maestra

SELECT * FROM [QUICK_SORT].ESTADO